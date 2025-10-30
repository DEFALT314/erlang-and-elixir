%%%-------------------------------------------------------------------
%%% @author defalt
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. mar 2025 17:04
%%%-------------------------------------------------------------------
-module(ping).
-author("defalt").

%% API
-export([start/0, play/1, ping_f/1, pong_f/1, stop/0]).
start() ->
  P1 = spawn(?MODULE, ping_f, [0]),
  P2= spawn(?MODULE, pong_f, [0]),
  register(ping, P1),
  register(pong, P2).

play(N) when N>= 0 and is_integer(N)->
  ping ! {play, N}.
stop() ->
  ping !stop,
  pong ! stop.
ping_f(X) ->
  receive
    stop -> io:format("stopped");
    {play, 0} -> io:format("Ping done ~n"), ping_f(X+1);
    {play,Count} when is_integer(Count), Count>0 ->
      io:format("Ping ~p ~n", [Count]),
      pong ! {play,(Count -1)},
      ping_f(X+1)
  after 20000 ->
    io:format("died")
  end.

pong_f(X) ->
  receive
    stop -> io:format("stopped");
    {play, 0} -> io:format("Ping done ~n"), pong_f(X+1);
    {play,Count} when is_integer(Count), Count>0 ->
      io:format("Pong ~p ~n", [Count]),
      ping ! {play, (Count -1)},
      pong_f(X+1)
  after 20000 ->
    io:format("died")
  end.

