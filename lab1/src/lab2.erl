%%%-------------------------------------------------------------------
%%% @author defalt
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. mar 2025 17:15
%%%-------------------------------------------------------------------
-module(lab2).
-author("defalt").

%% API
-export([qs/1]).

qs([Pivot|Tail]) -> qs( less_than(Tail,Pivot) ) ++ [Pivot] ++ qs( grt_eq_than(Tail,Pivot) )


less_than(List, Arg) ->
  lists:filter(fun (X) when X<Arg-> true; (_) -> false end, List).

grt_eq_than(List, Arg) ->
  lists:filter(fun (X) when X>=Arg-> true; (_) -> false end, List).

