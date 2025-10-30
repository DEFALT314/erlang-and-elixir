%%%-------------------------------------------------------------------
%%% @author defalt
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. kwi 2025 11:22
%%%-------------------------------------------------------------------
-module(pollution_value_collector_gen_statem).
-author("defalt").
-behavior(gen_statem).
-record(state, {id=null, data=[]}).
%% API
-export([callback_mode/0, collecting/3, idle/3, store_data/0, add_value/3, set_station/1, init/1, start_link/0]).
-export([stop/0]).
start_link() ->
  gen_statem:start_link({local, ?MODULE},?MODULE, [], []).

init([]) -> {ok, idle, #state{}}.

stop() -> gen_statem:stop(?MODULE).

set_station(Id) ->
  gen_statem:cast(?MODULE, {set_station, Id}).

add_value(Date, Type, Value) ->
  gen_statem:cast(?MODULE, {add_value, Date, Type, Value}).

store_data() ->
  gen_statem:cast(?MODULE, store_data).

idle(_Event, {set_station, Id}, State)->
  {next_state, collecting, State#state{id = Id}}.

collecting(_Event, {add_value, Date, Type, Value}, State = #state{data = Data}) ->
  {next_state, collecting, State#state{data=[{Date, Type, Value}|Data] }};

collecting(_Event, store_data, #state{id=Id, data =Data})->
  lists:foreach(fun({D,T, V})-> pollution_gen_server:add_value(Id,D,T,V) end,Data),
  {next_state, idle, #state{}}.

callback_mode() -> state_functions.