%% @author Jonas Kahler <jonas.kahler@icloud.com> [www.derkahler.de]
%% @author Niklas le Comte niklas.lecomte@hotmail.com [www.hashtux.com/niklas]
%% @doc A worker that handles the reading from the db for the userstats
%% @version 0.2
%% -----------------------------------------------------------------------------
%% | Sprint 4                                                                  |
%% | Version 0.1                                                               |
%% | This gen_server will work as a worker and handle the different messages   |
%% | from the sup for collecting  user statistics. Basic functionality is done,|
%% | it can read from the db and use mapreduce functions for getting the corre-|
%% | ct data.                                                                  |
%% -----------------------------------------------------------------------------
%% | Sprint 5                                                                  |
%% | Applied changes of db_addr_serv. Changed the DB address.                  |
%% -----------------------------------------------------------------------------
-module(db_userstats_reader).
-version(0.2).

-behavior(gen_server).

-export([start_link/0, stop/0, state/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).
-export([code_change/3, terminate/2]).

%% -----------------------------------------------------------------------------
%% | Public API                                                                |
%% -----------------------------------------------------------------------------
%% @doc Starts the gen_server and links it to the calling process.
start_link() ->
    gen_server:start_link(?MODULE, [], []).

%% @doc Stops the gen_server.
stop(Module) ->
    gen_server:call(Module, stop).
stop() ->
    stop(self()).

%% @doc Returns the state of the gen_sever
state(Module) ->
    gen_server:call(Module, state).
state() ->
    state(self()).

%% -----------------------------------------------------------------------------
%% | Server implementation                                                     |
%% -----------------------------------------------------------------------------
%% @doc Init function which starts the server with an empty state.
init([]) ->
    {ok, []}.

%% @doc Stop call to the server.
handle_call(stop, _From, _State) ->
    {stop, normal, stopped, _State};
%% @doc Other calls are not supported.
handle_call(_, _, _) ->
    error(undef).

%% @doc Get statistics based on the search term from the server.
handle_cast({get_stats, Term, Options, Rec}, State) ->
    R = couch_operations:doc_get({db_addr_serv:main_addr() ++
             "hashtux_userstats_cached_data/" ++ Term,
             db_addr_serv:main_user(), db_addr_serv:main_pass()}),
    [_,_ | List] = R,
    SR = [[{<<"key">>, String}, {<<"value">>, Value}] || {String, Value} <- List],
    LR = db_options_handler:handle_options(SR, Options),
    Rec ! {self(), LR},
    {stop, normal, State}.


%% @doc Normal messages to the server are not supported.
handle_info(_Info, _State) ->
    error(undef).

%% doc Code update
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% @doc Terminates the server
terminate(_Reason, _State) ->
    ok.

