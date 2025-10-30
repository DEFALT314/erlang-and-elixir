%%%-------------------------------------------------------------------
%%% @author defalt
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. kwi 2025 16:24
%%%-------------------------------------------------------------------
-module(pollution_gen_server).
-author("defalt").
-behavior(gen_server).
%% API
-export([init/1, handle_call/3, handle_cast/2, start_link/0, add_station/2, add_value/4, remove_value/3, get_one_value/3, get_station_min/2, get_daily_mean/2, get_hourly_mean/3, crash/0]).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [],[]).

init([])-> {ok, pollution:create_monitor()}.
add_station(Name, Location) ->
  gen_server:cast(?MODULE, {add_station, Name, Location}).

add_value(Id, Date, Type, Value) ->
  gen_server:cast(?MODULE, {add_value, Id, Date, Type, Value}).

remove_value(Id, Date, Type) ->
  gen_server:cast(?MODULE, {remove_value, Id, Date, Type}).

get_one_value(Id,  Date, Type) ->
  gen_server:call(?MODULE, {get_one_value, Id,  Date, Type}).

get_station_min(Id, Type) ->
  gen_server:call(?MODULE, {get_station_min, Id, Type }).

get_daily_mean(Type, Day) ->
  gen_server:call(?MODULE, {get_daily_mean, Type, Day}).

get_hourly_mean(Id, Type,Hour) ->
  gen_server:call(?MODULE, {get_hourly_mean, Id, Type, Hour}).

handle_cast({add_station, Name, Location}, State) ->
  case pollution:add_station(Name, Location, State) of
    {error, _} ->
      {noreply, State};
    X ->
      {noreply, X}
  end;

handle_cast({add_value, Id, Date, Type, Value}, State) ->
  case pollution:add_value(Id, Date, Type, Value, State) of
    {error, _} ->
      {noreply, State};
    X ->
      {noreply, X}
  end;
handle_cast({remove_value, Id, Date, Type}, State) ->
  case pollution:remove_value(Id, Date, Type, State) of
    {error, _} ->
      {noreply, State};
    X ->
      {noreply, X}
  end.

handle_call({get_one_value, Id,  Date, Type},_From, State) ->
  {reply, pollution:get_one_value(Id,  Date, Type, State), State};
handle_call({get_station_min, Id, Type },_From, State) ->
  {reply, pollution:get_station_min(Id, Type, State), State};
handle_call({get_daily_mean, Type, Day},_From, State) ->
  {reply, pollution:get_daily_mean(Type, Day, State), State};
handle_call({get_hourly_mean, Id, Type, Hour},_From, State) ->
  {reply, pollution:get_hourly_mean(Id, Type,Hour, State), State}.
crash() ->
  gen_server:call(?MODULE, {crash}).

%%pollution_gen_server:start_link().
%%pollution_gen_server:add_station(test,{1,1}).
%%pollution_gen_server:add_value(test, {{2023,3,27},{11,16,10}}, "PM10", 2).
%%pollution_gen_server:get_one_value(test,  {{2023,3,27},{11,16,10}}, "PM10").
%%pollution_gen_server:add_value(test, {{2024,3,27},{11,16,10}}, "PM10", 3).
%%pollution_gen_server:get_hourly_mean(test, "PM10", 11).
%%pollution_gen_server:add_value(test, {{2024,3,27},{12,16,10}}, "PM10", 100).