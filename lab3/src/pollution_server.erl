%%%-------------------------------------------------------------------
%%% @author defalt
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. kwi 2025 14:39
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("defalt").

%% API
-export([start/0, add_station/2, add_value/4, remove_value/3, get_one_value/3, get_station_min/2, get_daily_mean/2, get_hourly_mean/3, stop/0, init/0, get_state/0]).

start() ->
  register(pollution_server, spawn(?MODULE, init, [])).

init()->
  InitState = pollution:create_monitor(),
  loop(InitState).

stop() ->
  pollution_server ! stop.

loop(State) ->
  receive
    stop -> unregister(pollution_server),ok;
    {request,Pid,{ add_station, Name, Location }} ->
      case pollution:add_station(Name, Location, State) of
        {error, Reason} ->
          Pid ! {error, Reason},
          loop(State);
        X ->
          Pid ! ok,
          loop(X)
      end;
    {request,Pid,{ add_value, Id, Date, Type, Value }} ->
      case pollution:add_value(Id, Date, Type, Value, State) of
        {error, Reason} ->
          Pid ! {error, Reason},
          loop(State);
        X ->
          Pid ! ok,
          loop(X)
      end;
    {request,Pid,{ remove_value, Id, Date, Type }} ->
    case pollution:remove_value(Id, Date, Type, State) of
      {error, Reason} ->
        Pid ! {error, Reason},
        loop(State);
      X ->
        Pid ! ok,
        loop(X)
    end;
    {request,Pid,{ get_one_value, Id,  Date, Type }} ->
      case pollution:get_one_value(Id,  Date, Type, State) of
        {error, Reason} ->
          Pid ! {error, Reason},
          loop(State);
        X ->
          Pid ! X,
          loop(State)
      end;
    {request,Pid,{ get_station_min, Id, Type }} ->
    case pollution:get_station_min(Id, Type, State) of
      {error, Reason} ->
        Pid ! {error, Reason},
        loop(State);
      X ->
        Pid ! X,
        loop(State)
    end;
    {request,Pid,{ get_daily_mean, Type, Day }} ->
    case pollution:get_daily_mean(Type, Day, State) of
      {error, Reason} ->
        Pid ! {error, Reason},
        loop(State);
      X ->
        Pid ! X,
        loop(State)
    end;
    {request,Pid,{ get_hourly_mean, Id, Type,Hour }} ->
      case pollution:get_hourly_mean(Id, Type,Hour, State) of
        {error, Reason} ->
          Pid ! {error, Reason},
          loop(State);
        X ->
          Pid ! X,
          loop(State)
      end;
    {request,Pid,{getstate}} ->
      Pid ! State,
      loop(State)
  end.

call(Msg) ->
  pollution_server ! {request, self(), Msg},
  receive
    X->X
  end.

get_state() ->
  pollution_server ! {request, self(), {getstate}},
  receive
    X->X
  end.

add_station(Name, Location) ->
  call({add_station, Name, Location}).

add_value(Id, Date, Type, Value) ->
  call({add_value, Id, Date, Type, Value}).

remove_value(Id, Date, Type) ->
  call({remove_value, Id, Date, Type}).

get_one_value(Id,  Date, Type) ->
  call({get_one_value, Id,  Date, Type}).

get_station_min(Id, Type) ->
  call({get_station_min, Id, Type }).

get_daily_mean(Type, Day) ->
  call({get_daily_mean, Type, Day}).

get_hourly_mean(Id, Type,Hour) ->
  call({get_hourly_mean, Id, Type, Hour}).
