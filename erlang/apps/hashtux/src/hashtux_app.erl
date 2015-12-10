%%%-------------------------------------------------------------------
%% @doc hashtux public API
%% @end
%%%-------------------------------------------------------------------

-module('hashtux_app').

-behaviour(application).

%% Application callbacks
-export([start/2
        ,stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	%%
	%% Bring up the Cowboy HTTP listener.
	%%
	http_cowboy:start(),
	
	%%
	%% Start the main supervisor
	%%
    'hashtux_sup':start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
