% include the knowledge base
:- ['load.pro'].

% 3.1 glanian_distance(Name1, Name2, Distance) 5 points
glanian_distance(Name1, Name2, Distance) :- 
	expects(Name1, _, Expected_list),
	glanian(Name2, _, Features),
	calculate_distance(Expected_list, Features, DistanceSquared),
	Distance is sqrt(DistanceSquared).

calculate_distance([-1], _, Distance) :- Distance is 0.

calculate_distance([H1], [H2], Distance) :-
	Distance is (H1-H2)*(H1-H2).

calculate_distance([H1|T1], [H2|T2], Distance) :-
	calculate_distance(T1, T2, TailDistance),
	calculate_distance([H1], [H2], HeadDistance),
	Distance is HeadDistance + TailDistance.



% 3.2 weighted_glanian_distance(Name1, Name2, Distance) 10 points
weighted_glanian_distance(Name1, Name2, Distance) :-
	expects(Name1, _, Expected_list),
	glanian(Name2, _, Features),
	weight(Name1, WeightList),
	calculate_weighted_distance(Expected_list, Features, WeightList, DistanceSquared),
	Distance is sqrt(DistanceSquared).

calculate_weighted_distance([-1], _, [-1], Distance) :- Distance is 0.

calculate_weighted_distance([H1], [H2], [H3], Distance) :-
	Distance is (H1-H2)*(H1-H2)*H3.

calculate_weighted_distance([H1|T1], [H2|T2], [H3|T3], Distance) :-
	calculate_weighted_distance(T1, T2, T3, TailDistance),
	calculate_weighted_distance([H1], [H2], [H3], HeadDistance),
	Distance is HeadDistance + TailDistance.

% 3.3 find_possible_cities(Name, CityList) 5 points
%find_possible_cities(Name, CityList) :- 

find_liked_cities(Name, CityList) :- findall(X,likes(Name, _, X), CityList).

find_current_city(Name, City) :- all_cities(CityList), member(City, CityList), is_living(Name, City).

is_living(Name, City) :- city(City, HabitantList, _), member(Name, HabitantList). 

all_cities(CityList) :- findall(X, city(X, _, _), CityList).

% 3.4 merge_possible_cities(Name1, Name2, MergedCities) 5 points

% 3.5 find_mutual_activities(Name1, Name2, MutualActivities) 5 points

% 3.6 find_possible_targets(Name, Distances, TargetList) 10 points

% 3.7 find_weighted_targets(Name, Distances, TargetList) 15 points

% 3.8 find_my_best_target(Name, Distances, Activities, Cities, Targets) 20 points

% 3.9 find_my_best_match(Name, Distances, Activities, Cities, Targets) 25 points
