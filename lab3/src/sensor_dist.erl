%%%-------------------------------------------------------------------
%%% @author defalt
%%% @copyright (C) 2025, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. mar 2025 18:09
%%%-------------------------------------------------------------------
-module(sensor_dist).
-author("defalt").

%% API
-export([get_rand_locations/1, dist/2, find_for_person/2, find_closest/2, find_for_person/3, find_closest_parallel/2]).

get_rand_locations(Number) ->
  [{rand:uniform(1000), rand:uniform(1000)} || _ <- lists:seq(1,Number)].

dist({X1, Y1}, {X2, Y2}) ->
  math:sqrt(math:pow(X1-X2, 2) + math:pow(Y1-Y2,2)).


find_for_person(PersonL, SensorsLocations) ->
  D = [{dist(PersonL, SensorsL), PersonL, SensorsL} || SensorsL <- SensorsLocations],
  lists:min(D).

find_closest(PeopleLocations, SensorsLocations) ->
  X= [find_for_person(P, SensorsLocations) || P <- PeopleLocations],
  lists:min(X).



find_for_person(PersonL, SensorsLocations, ParentPID) ->
  ParentPID ! find_for_person(PersonL, SensorsLocations).

find_closest_parallel(PeopleLocations, SensorsLocations) ->
  X= [spawn(?MODULE, find_for_person, [P, SensorsLocations, self()]) || P <- PeopleLocations],
  lists:min([receive Res->Res end||_<-X]).