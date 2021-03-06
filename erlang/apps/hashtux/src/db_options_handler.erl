%% @author Jonas Kahler <jonas@derkahler.de> [www.derkahler.de]
%% @author Niklas le Comte niklas.lecomte@hotmail.com [www.hashtux.com/niklas]
%% @doc Handles operations on options for the db_readers
%% @version 0.2
%% -----------------------------------------------------------------------------
%% | Sprint 4 // v0.1                                                          |
%% | This module is created for the purpose of handling options for the        |
%% | advanced search and as well for the user statistics. It orders_options,   |
%% | search_opt, pre_search_opt.                                               |
%% -----------------------------------------------------------------------------
%% | Sprint 5 // v0.2                                                          |
%% | Added the insert_timestamp to the possible options                        |
%% -----------------------------------------------------------------------------
-module(db_options_handler).
-version(0.2).

-export([handle_options/2, pre_search_opt/1, pre_search_opt/2]).

%% @doc Function to apply all passed options to a list of results.
handle_options(L, Options) ->
    FL1 = db_filter:content_type(L, lists:keyfind(content_type, 1, Options)),
    FL2 = db_filter:service(FL1, lists:keyfind(service, 1, Options)),
    FL3 = db_filter:language(FL2, lists:keyfind(language, 1, Options)),
    FL4 = db_filter:timeframe(FL3, lists:keyfind(timeframe, 1, Options)),
    FL5 = db_filter:insert_timeframe(FL4,
                    lists:keyfind(insert_timeframe, 1, Options)),
    db_filter:limit_result(FL5, lists:keyfind(limit, 1, Options)).

%% @doc This returns an url string for the quering of the db.
pre_search_opt(L) ->
    pre_search_opt(L, []).
pre_search_opt([], L) ->
    L;
pre_search_opt([{time}| T], L) ->
    R = L ++ "startkey=[0" ++ ",\"a\"]&endkey=[99999999999999999999999999" ++ ",\"z\"]",
    pre_search_opt(T, R);
pre_search_opt([{time, Start, End}| T], L) ->
    R = L ++ "startkey=[" ++ integer_to_list(Start) ++ ",\"a\"]&endkey=[" ++ integer_to_list(End) ++ ",\"z\"]",
    pre_search_opt(T, R);
pre_search_opt([_| T], L) ->
    pre_search_opt(T, L).
