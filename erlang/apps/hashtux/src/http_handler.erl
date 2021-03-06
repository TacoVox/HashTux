%% @author Jerker Ersare <jerker@soundandvision.se>
%% @doc This module handles requests from the frontend web server.
%%
%% It logs user habit detals about the request and then lets main_flow modules take
%% care of the request. It then returns the reply from main_flow to the web server.
%%
%% The request from the web server supplies a number of details about the user, session
%% and client options.
%%
%% The code in http_handler and main_flow* is very agnostic about what is in the options or 
%% user habit data. The only thing that matters is that we can get the request_type value 
%% from the options.
%%
%% Notes on cowboy:
%% URL: the full url, including http://
%% {URL, _} =  cowboy_req:url(Req),	
%% QueryString: all the query stuff after the ?
%% {Qs, _} = cowboy_req:qs(Req),
%%	
%% TODO: try/catch on malformed jsx?


-module(http_handler).
-behaviour(cowboy_http_handler).

%% ====================================================================
%% API functions
%% ====================================================================

-export([init/3, handle/2, terminate/3]).


%% @doc Leaving the init function as proposed by Cowboy example code.
init(_Type, Req, []) ->
   {ok, Req, undefined}.


%% @doc Handles a HTTP request.
handle(Req, State) ->	
	% Extract the request path (a string starting with /, we then remove this character)
	{Path, _} = cowboy_req:path(Req),
	[_ | Term] = binary:bin_to_list(Path),
	io:format("~nhttp_handler: Handling term ~p~n", [Term]),
	
	% Get the request body - will be json [options, user_habit_data]
	% Pattern match the distinct sublists against the decoded JSON.
	% Force JSX to turn keys in key-value pairs to atoms.
	{ok, RequestBody, _Req} = cowboy_req:body(Req),	
	[Options, UserHabitData] = jsx:decode(RequestBody, [{labels, atom}]),

	% Store user habit data - includes the options
	user_habits:store(Options, UserHabitData),
	
	% Send the search term, request type and the options to the main flow by making a call
	% to main flow server - get the PID of the worker back and wait for a reply from it
	io:format("http_handler: Options: ~p~n", [Options]),
	RequestType = aux_functions:bin_to_atom(aux_functions:get_value(request_type, Options)),
	{ok, HandlerPid} = gen_server:call(main_flow_server, {RequestType, Term, Options}),
	io:format("~nhttp_handler: Made main_flow_server call, received worker PID: ~p~n", [HandlerPid]),
	
	receive 
		{HandlerPid, Reply} -> 
			io:format("~nhttp_handler: Receved a reply from worker ~p handling term ~p."
					 ++ " Sending reply to client...~n", [HandlerPid, Term])
		after 20000 ->
			io:format("~nhttp_handler: Timeout from worker~p handling term ~p~n", [HandlerPid, Term]),
			Reply = []
		end,	
	
	% Send the reply from the main flow call, which should be
	% a list of social media posts. We encode it with jsx and send it out.
	{ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"application/json">>}],
								  jsx:encode(Reply), Req), 
	{ok, Req2, State}.


%% @doc No particular action taken. We don't keep a state in this module.
terminate(_Reason, _Req, _State) ->
    ok.