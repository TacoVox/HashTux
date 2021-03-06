%% @author Jonas Kahler <jonas@derkahler.de> [www.derkahler.de]
%% @author Niklas le Comte niklas.lecomte@hotmail.com [www.hashtux.com/niklas]
%% @doc Initial database actions module
%% @version 0.4
%% -----------------------------------------------------------------------------
%% | Sprint 1 // v0.1                                                          |
%% | Created first as a normal module where the diffrent write operations was  |
%% | functions. Then made it into a gen_server which handled a lot of calls.   |
%% | It used every write operation defind in couch_operation.                  |
%% -----------------------------------------------------------------------------
%% | Sprint 2 // v0.2                                                          |
%% | Changed how many operations to include because of changes in how data is  |
%% | stored in the database. Only keept the operations which was needed for now|
%% | add_doc, and delete_hash.                                                 |
%% -----------------------------------------------------------------------------
%% | Sprint 4 // v0.3                                                          |
%% | Applied the new changes to this worker. It now fetches the credentials of |
%% | the database server from the config file and uses them to write to the db |
%% -----------------------------------------------------------------------------
%% | Sprint 5 // v0.4                                                          |
%% | Applied changes of db_addr_serv.                                          |
%% -----------------------------------------------------------------------------
-module(db_hash_writer).
-version(0.4).

-behavior(gen_server).

-export([start_link/0, stop/0, state/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).
-export([handle_info/2, terminate/2]).

%% -----------------------------------------------------------------------------
%% | Public API                                                                |
%% -----------------------------------------------------------------------------
%% @doc Starts the gen_server.
start_link() ->
    gen_server:start_link(?MODULE, [], []).

%% @doc Stops the gen_server
stop(Module) ->
    gen_server:call(Module, stop).
stop() ->
    stop(self()).

%% @doc Returns the current state of the module
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

%% @doc Call to stop the server.
handle_call(stop, _From, _State) ->
    {stop, normal, stopped, _State};
%% @doc Other calls to the server are not supported.
handle_call(_, _, _) ->
    error(undef).

%% @doc Add a document to the database
handle_cast({add_doc, Content, Rec}, State) ->
    add_docs(Content),
    Rec ! {self(), true},
    {stop, normal, State};
%% Deletes a hashtag from the database
handle_cast({delete_hash, Hash, Rec}, State) ->
    Results = couch_operations:doc_get({db_addr_serv:main_addr() ++
              "hashtux/_design/post/_view/by_hashtag?key=\"" ++ Hash ++ "\"",
              db_addr_serv:main_user(), db_addr_serv:main_pass()}),
    {_, Posts} = lists:keyfind(<<"rows">>, 1, Results),
    [couch_operations:doc_delete({db_addr_serv:main_addr() ++
         binary_to_list(ID), binary_to_list(Rev),
         db_addr_serv:main_user(), db_addr_serv:main_pass()}) ||
         [{<<"_id">>, ID}, {<<"_rev">>, Rev} | _] <- [Content ||
       {<<"value">>, Content} <- lists:flatten(Posts)]],
    Rec ! {self(), true},
    {stop, normal, State}.

%% @doc Normal messages to the server are not supported.
handle_info(_Info, _State) ->
    error(undef).

%% @doc Terminates the gen_server
terminate(_Reason, _State) ->
    ok.

%% -----------------------------------------------------------------------------
%% | Helperfunction implementation                                             |
%% -----------------------------------------------------------------------------
%% @doc Recursive unction to add several documents at a time to the database.
add_docs([]) -> ok;
add_docs([H|T]) ->
    UUID = couch_operations:get_uuid(),
    couch_operations:doc_add({db_addr_serv:main_addr() ++ "hashtux/" ++ UUID,
                     db_addr_serv:main_user(), db_addr_serv:main_pass()}, H),
    add_docs(T).
