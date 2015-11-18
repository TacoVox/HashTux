%% @author Jonas Kahler <jonas@derkahler.de> [www.derkahler.de]
%% @author Niklas le Comte niklas.lecomte@hotmail.com [www.hashtux.com/niklas]
%% %% @doc Initial database actions module
%% %% @version 0.3
%% -----------------------------------------------------------------------------
%% | Sprint 1 // v0.1                                                          |
%% | Created first as a normal module where the diffrent write operations was  |
%% | functions. Then made it into a gen_server which handled a lot of calls.   |
%% | It used every write operation defind in couch_operation.                  |
%% -----------------------------------------------------------------------------
%% | Sprint 2 // v0.2                                                          |
%% | Changed the module to only do two different operations, get_posts and     |
%% | hash_exists to fit the new changes on how we will store data and what to  |
%% | get from the database.                                                    |
%% -----------------------------------------------------------------------------
%% | Sprint 4 // v0.3                                                          |
%% | Added options to the advance search that will handle the different ones   |
%% | that is sent. It fetch all the result from the DB and the filters it      |
%% | Added the new calls to the new options handler module                     |
%% | Applied the new general calls to the connector module                     |
%% | Cleaned up the whole code and created detailed documentation              |
%% -----------------------------------------------------------------------------
-module(db_hash_reader).
-version(0.3).

-behavior(gen_server).

-export([start_link/0, stop/0, state/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).
-export([code_change/3, terminate/2]).

%% Local database credentials
-define(ADDR, fun() -> {ok, {ADDR, _, _}} =
              application:get_env(db_conf, localdb), ADDR end).
-define(USER, fun() -> {ok, {_, USER, _}} =
              application:get_env(db_conf, localdb), USER end).
-define(PASS, fun() -> {ok, {_, _, PASS}} =
              application:get_env(db_conf, localdb), PASS end).

%% -----------------------------------------------------------------------------
%% | Public API                                                                |
%% -----------------------------------------------------------------------------
%% @doc Starts the server and creates a link.
start_link() ->
    gen_server:start_link(?MODULE, [], []).

%% @doc Stops the server. Normal termination.
stop(Module) ->
    gen_server:call(Module, stop).
stop() ->
    stop(self()).

%% @doc Getting the current state of the server.
state(Module) ->
    gen_server:call(Module, state).
state() ->
    state(self()).

%% -----------------------------------------------------------------------------
%% | Server implementation                                                     |
%% -----------------------------------------------------------------------------
%% @doc Init function. Starts the server with an empty state.
init([]) ->
    {ok, []}.

%% -----------------------------------------------------------------------------
%% | Implementation of different casts to the server.                          |
%% -----------------------------------------------------------------------------
%% @doc Fetch all results for a search term. Without options.
handle_cast({get_posts, Hashtag, Rec}, State) ->
    Result =  couch_operations:doc_get_map_cont({
              ?ADDR() ++ "hashtux/_design/post/_view/by_hashtag?key=\"" ++
              Hashtag ++  "\"", ?USER(), ?PASS()}),
    Rec ! {self(), Result},
    {stop, normal, State};

%% @doc Fetch results for a given search term with different options.
handle_cast({get_posts, Hashtag, Options, Rec}, State) ->
    Hash_Result = couch_operations:doc_get_map_cont({
                  ?ADDR() ++ "hashtux/_design/post/_view/by_hashtag?key=\"" ++
                  Hashtag ++ "\"", ?USER(), ?PASS()}),
    Result = db_options_handler:handle_options(Hash_Result, Options),
    case(Result) of
        [] ->
            Rec ! {self(), db_filter:check_results(Hash_Result, Options)};
        Res ->
            Rec ! {self(), Res}
    end,
        {stop, normal, State};

%% @doc Check if a hashtag is existing in the database.
handle_cast({posts_exist, Hashtag, Rec}, State) ->
    Result = couch_operations:doc_exist({
             ?ADDR() ++ "hashtux/_design/post/_view/by_hashtag?key=\"" ++
             Hashtag ++ "\"", ?USER(), ?PASS()}),
    Rec ! {self(), Result},
    {stop, normal, State}.

%% -----------------------------------------------------------------------------
%% | Implementation of all other server parts.                                 |
%% | - Call                                                                    |
%% | - Info                                                                    |
%% | - Code Change                                                             |
%% | - Terminate                                                               |
%% -----------------------------------------------------------------------------
%% @doc Stops the server
handle_call(stop, _From, _State) ->
    {stop, normal, stopped, _State}.

%% @doc Throws an error if a normal message is send to the server.
handle_info(_, _) ->
    error(undef).

%% @doc Code change.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% @doc Terminates the server.
terminate(_Reason, _State) ->
    ok.
