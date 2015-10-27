-module(main_flow).
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3]).

start_link() ->
    gen_server:start_link({local, main_flow}, main_flow, [], []).

init(_Args) ->
	io:format("Started the main flow controller.~n~n"),
    {ok, []}.

handle_call({search, Term}, From, State) -> 
	io:format("Term: ~p~n", [Term]),
	Ref = gen_server:call(db_serv, {get_cont, Term}),
	receive {Ref, Res} -> {reply, Res, State} end.
	%if (Term == "help") ->
	%	   {reply, "There is no help for a lost soul like yours.", State};
	%	true ->
	%		{reply, lists:reverse(Term), State}
	%end.
				