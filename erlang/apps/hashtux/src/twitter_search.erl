%% @author Marco Trifance <marco.trifance@gmail.com>
%% @doc Handle Twitter API search requests according to HashTux filters and parameters.

-module(twitter_search).

-export([search_hash_tag/2]).

%% Twitter Search API Endpoint
-define(URL, "https://api.twitter.com/1.1/search/tweets.json").

%% @doc     Sends a GET request to the 'Twitter Search API'.
%% @return  A list of two tuples in the following format: [{filtered, FilteredRes}, {unfiltered, LangResult}].
%%          UnfilteredRes: a list of tweets in internal representation matching the specified values
%%          for language and history timestamp params;
%%          FilteredRes: a list of all tweets from UnfilteredRes that match the content_type requestedby the client. 
%% @params  Types: a list of types [text, image, video] of feeds requested by the client.
%% @params  Lang: the langauge of the feeds the query will request
%% @params  HistoryTimestamp: the publication date of the feeds the query will request (epoch timestamp)
search_hash_tag(Keyword, [{content_type, Types}, {language, Lang}, {history_timestamp, HistoryTimestamp}]) -> 

    HashTag = "#" ++ Keyword,

    % generate Keyword + hisotry_timestamp parameters
    QParam = apis_aux:generate_twitter_q_param(HashTag, HistoryTimestamp),

    % List of available Languages
    LangParams = [<<"en">>, <<"es">>, <<"fr">>, <<"de">>, <<"sv">>, <<"bg">>, <<"it">>, <<"am">>],

    % Set API request parameters
    Options = case lists:member(Lang, LangParams) of
        true -> [{q, QParam}, {lang, binary_to_atom(Lang, latin1)}, {count, 30}, {result_type, recent}];        %% Set 'language' and 'count' params
        false -> [{q, QParam}, {result_type, recent}]
    end,

    % Set content_type filter
    TypeFilter = [binary_to_list(Z) || Z <- Types],  

    % Get Authorization Credentials
    {AccessToken, AccessTokenSecret, ConsumerKey, ConsumerKeySecret} = apis_aux:get_twitter_keys(),
    Consumer = {ConsumerKey, ConsumerKeySecret, hmac_sha1},  

    % Use oauth:sign/6 to generate a list of signed OAuth parameters, 
    SignedParams = oauth:sign("GET", ?URL, Options, Consumer, AccessToken, AccessTokenSecret),

    % Send authorized GET request and get result as binary
    Res = ibrowse:send_req(oauth:uri(?URL,SignedParams), [], get,[], [{response_format, binary}]),

    {ok, Status, _ResponseHeaders, ResponseBody} = Res,

    print_response_info(Status),

    % Decode response body 
    DecodedBody = jsx:decode(ResponseBody),
    
    % Get a List of Internal JSX objects mined for a specified language (all languages if not specified)
    LangResult = parser:parse_twitter_response_body(Keyword, DecodedBody),

    % Debug Filtered Result size
    LangResLength = length(LangResult),
    io:format("TWITTER SIMPLE SEARCH RETURNED ~p TWEETS~n", [LangResLength]),

    % FILTER LangResult by content_type
    FilteredRes = [H || H <- LangResult, parser:filter_by_content_type(H, TypeFilter)],

    % Debug Filtered Result size
    ResLength = length(FilteredRes),
    io:format("TWITTER ADVANCED SEARCH RETURNED ~p TWEETS~n", [ResLength]),

    % Return Filtered Result
    [{filtered, FilteredRes}, {unfiltered, LangResult}].         %% Return Result

%% Print Twitter API request status information
%%
print_response_info(Status) ->
    case Status of
        "200" -> io:format("Twitter Request was fulfilled\n");
        _Other -> io:format("Twitter Request got non-200 response\n")
    end.