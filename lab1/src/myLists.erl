%%%-------------------------------------------------------------------
%%% @author defalt
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. mar 2025 14:16
%%%-------------------------------------------------------------------
-module(myLists).
-author("defalt").

%% API
-export([contains/2, duplicateElements/1, sumFloats/1, sumFloats/2]).

contains([Val|_], Val) -> true;
contains([_|T], Val) -> contains(T, Val);
contains([], _) -> false.

duplicateElements([H|T]) -> [H, H| duplicateElements(T)];
duplicateElements([]) -> [].

sumFloats([H|T]) when is_float(H) -> sumFloats(T) + H;
sumFloats([_|T])-> sumFloats(T);
sumFloats([]) -> 0.0.

sumFloats([H|T], Sum) when is_float(H) -> sumFloats(T, Sum + H);
sumFloats([_|T], Sum)-> sumFloats(T, Sum);
sumFloats([], Sum) -> Sum.