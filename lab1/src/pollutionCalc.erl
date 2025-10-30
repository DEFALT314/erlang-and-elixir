%%%-------------------------------------------------------------------
%%% @author defalt
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. mar 2025 14:45
%%%-------------------------------------------------------------------
-module(pollutionCalc).
-author("defalt").

%% API
-export([number_of_readings/2, sample_data/0, calculate_max/2, calculate_sum/2, calculate_mean/2, calculate_count/2]).


sample_data() ->
  [
    {"stacja_centralna", {{2024, 5, 15}, {10, 30, 0}}, [{pm10, 25}, {pm25, 12}]},
    {"stacja_centralna", {{2024, 5, 15}, {12, 0, 0}}, [{pm10, 30}, {pm25, 15}]},
    {"stacja_wschodnia", {{2024, 5, 16}, {9, 30, 0}}, [{pm10, 20}, {pm25, 10}]},
    {"stacja_wschodnia", {{2024, 5, 16}, {11, 30, 0}}, [{pm10, 28}, {pm25, 14}]},
    {"stacja_poludniowa", {{2024, 5, 17}, {14, 30, 0}}, [{pm10, 35},{pm25, 18}]}
  ].

number_of_readings([{_, {{Year,Month, Date}, _}, _}|T], {Year,Month, Date}) -> 1 + number_of_readings(T, {Year,Month, Date});
number_of_readings([_|T], {Year,Month, Date}) -> number_of_readings(T, {Year,Month, Date});
number_of_readings([], _) -> 0.

calculate_max([{_, {{_,_, _}, {_,_, _}}, Measurements}], Type) ->
  find_type(Measurements,Type);
calculate_max([{_, {{_,_, _}, {_,_, _}}, Measurements}|T], Type) ->
  X= find_type(Measurements, Type),
  Y =calculate_max(T,Type),
  case {X,Y} of
    {null, null} -> null;
    {null, Y} -> Y;
    {X, null} -> X;
    _ -> max(X,Y)
  end.

calculate_mean(Readings, Type) ->
  Sum = calculate_sum(Readings,Type),
  Count = calculate_count(Readings, Type),
  case Count of
    0-> 0.0;
    _ -> Sum/Count
  end.

calculate_sum([], _) ->0.0;
calculate_sum([{_, {{_,_, _}, {_,_, _}}, Measurements}|T], Type) ->
  X= find_type(Measurements, Type),
  case X of
    null -> calculate_sum(T,Type);
    _ -> X+calculate_sum(T,Type)
  end.

calculate_count([], _) ->0;
calculate_count([{_, {{_,_, _}, {_,_, _}}, Measurements}|T], Type) ->
  X= find_type(Measurements, Type),
  case X of
    null -> calculate_count(T,Type);
    _ -> 1+calculate_count(T,Type)
  end.

find_type([{Type, Value}|_], Type) ->
  Value;
find_type([_|T], Type) -> find_type(T, Type);
find_type([], _) -> null.

