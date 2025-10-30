%%%-------------------------------------------------------------------
%%% @author defalt
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. mar 2025 11:53
%%%-------------------------------------------------------------------
-module(pollution).
-author("defalt").

%% API
-export([add_value/5, create_monitor/0, add_station/3, remove_value/4, get_one_value/4, get_station_min/3, get_daily_mean/3, get_hourly_mean/4]).

create_monitor() -> #{}.

add_station(Name, Location, P) ->
  Key = {Name, Location},
  KeyList = maps:keys(P),
  IsUniqName = not lists:any(fun ({X,_}) -> X =:= Name end, KeyList),
  IsUniqLocation = not lists:any(fun ({_,X}) -> X =:= Location end, KeyList),
  case {IsUniqName, IsUniqLocation} of
    {true, true} ->
      P1=  P#{Key => []  },
      P1;
    {false, _} ->
      {error, duplicate_name};
    {_, false} ->
      {error, duplicate_coordinates}
  end.

add_value(Id, Date, Type, Value, P) ->
  Find = fun(K,_) ->
    case K of
      {Id, _} -> true;
      {_, Id} -> true;
      _ -> false
    end
         end,
  FilteredMap = maps:filter(Find, P),
  case maps:size(FilteredMap) of
    1->
      [{KeyF, ValueF}] = maps:to_list(FilteredMap),
      Duplicate = lists:any(fun({D, T, _}) -> D== Date andalso T== Type end, ValueF),
      case Duplicate of
        false ->
          NewMeasurements = [{Date, Type, Value} | ValueF],
          P#{KeyF => NewMeasurements};
        true -> {error, duplicate_measurement}
      end;
    0 -> {error, station_not_found};
    _ -> {error, multiple_stations_found}
  end.

remove_value(Id, Date, Type, P) ->
  Find = fun(K,_) ->
    case K of
      {Id, _} -> true;
      {_, Id} -> true;
      _ -> false
    end
         end,
  FilteredMap = maps:filter(Find, P),
  case maps:size(FilteredMap) of
    1->
      [{KeyF, ValueF}] = maps:to_list(FilteredMap),
      Element = lists:any(fun({D, T, _}) -> D== Date andalso T== Type end, ValueF),
      case Element of
        true ->
          NewMeasurements = lists:filter(fun({D, T, _}) -> D=/= Date orelse T=/= Type end, ValueF),
          P#{KeyF => NewMeasurements};
        false -> {error, element_not_found}
      end;
    0 -> {error, station_not_found};
    _ -> {error, multiple_stations_found}
  end.

get_one_value(Id,  Date, Type, P) ->
  Find = fun(K,_) ->
    case K of
      {Id, _} -> true;
      {_, Id} -> true;
      _ -> false
    end
         end,
  FilteredMap = maps:filter(Find, P),
  case maps:size(FilteredMap) of
    1->
      [{_, ValueF}] = maps:to_list(FilteredMap),
      Element = lists:search(fun({D, T, _}) -> D== Date andalso T== Type end, ValueF),
      case Element of
        false -> {error, element_not_found};
        {_, {_,_, X}} ->X
      end;
    0 -> {error, station_not_found};
    _ -> {error, multiple_stations_found}
  end.

get_station_min(Id, Type, P) ->
  Find = fun(K,_) ->
    case K of
      {Id, _} -> true;
      {_, Id} -> true;
      _ -> false
    end
         end,
  FilteredMap = maps:filter(Find, P),
  case maps:size(FilteredMap) of
    1->
      [{_, ValueF}] = maps:to_list(FilteredMap),
      Element = lists:any(fun({_, T, _}) -> T== Type end, ValueF),
      case Element of
        true ->
          E = lists:map(fun({_, _, V}) -> V end ,lists:filter(fun({_, T, _}) -> T== Type end, ValueF)),
          lists:min(E);
        false -> {error, element_not_found}
      end;
    0 -> {error, station_not_found};
    _ -> {error, multiple_stations_found}
  end.


get_daily_mean(Type, Day, P) ->
  FilteredMeasurements = lists:filter(
    fun({{D,_}, T, _}) -> D == Day andalso T == Type end,
    lists:flatten(maps:values(P))
  ),
  Values = lists:map(fun({_, _, V}) -> V end, FilteredMeasurements),
  case Values of
    [] -> {error, no_elements};
    _ -> lists:sum(Values) / length(Values)
  end.
% dodaj do modułu pollution funkcje get_horuly_mean, która zwraca średnią wartość parametru zadanego typu o określonej godzinie każdego dnia dla określonej stascji
get_hourly_mean(Id, Type,Hour, P) ->
  Find = fun(K,_) ->
    case K of
      {Id, _} -> true;
      {_, Id} -> true;
      _ -> false
    end
         end,
  FilteredMap = maps:filter(Find, P),
  case maps:size(FilteredMap) of
    1->
      [{_, ValueF}] = maps:to_list(FilteredMap),
      FilteredMeasurements = lists:filter(
        fun({ {_, {H, _, _} }, T, _}) ->
          T == Type andalso H == Hour
        end,
        ValueF
      ),
      Values = lists:map(fun ({_,_, V}) -> V end, FilteredMeasurements),
      case Values of
        [] ->  {error, no_measurements};
        _ -> lists:sum(Values)/ length(Values)
      end;
    0 -> {error, station_not_found};
    _ -> {error, multiple_stations_found}
  end.