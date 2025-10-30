%%%-------------------------------------------------------------------
%%% @author defalt
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. mar 2025 17:25
%%%-------------------------------------------------------------------
-module(quick).
-author("defalt").

%% API
-export([qs/1, compare_speeds/3, random_elems/3]).

qs([Pivot | Tail]) ->
  qs(less_than(Tail, Pivot)) ++ [Pivot] ++ qs(grt_eq_than(Tail, Pivot));
qs([]) -> [].

less_than(List, Arg) ->
  [X || X <- List, X < Arg].

grt_eq_than(List, Arg) ->
  [X || X <- List, X >= Arg].

random_elems(N, Min, Max) ->
  [rand:uniform(Max - Min + 1) + Min - 1 || _ <- lists:seq(1, N)].

compare_speeds(List, Fun1, Fun2) ->
  {Time1, _} = timer:tc(Fun1, [List]),
  {Time2, _} = timer:tc(Fun2, [List]),
  io:format("Czas sortowania Fun1: ~p mikrosekund~nCzas sortowania Fun2: ~p mikrosekund~n", [Time1, Time2]).