%%%-------------------------------------------------------------------
%%% @author defalt
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. mar 2025 18:08
%%%-------------------------------------------------------------------
-module(lab1).
-author("defalt").

%% API
-export([power/2]).
power(Base,Expression) when Expression > 0 -> power(Base, Expression-1) * Base;
power(_, 0) -> 1.