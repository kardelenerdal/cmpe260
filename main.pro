% include the knowledge base
:- ['load.pro'].

% 3.1 glanian_distance(Name1, Name2, Distance) 5 points
glanian_distance(Name1, Name2, Distance) :- 
	expects(Name1, _, Expected_list),
	glanian(Name2, _, Features),
	calculate_distance(Expected_list, Features, DistanceSquared),
	Distance is sqrt(DistanceSquared).

calculate_distance([-1], _, Distance) :- print(c), Distance is 0.

calculate_distance([H1], [H2], Distance) :-
	print(a),
	Distance is (H1-H2)*(H1-H2).

calculate_distance([H1|T1], [H2|T2], Distance) :-
	print(b),
	calculate_distance(T1, T2, TailDistance),
	calculate_distance([H1], [H2], HeadDistance),
	print(H1),
	print(' '),
	print(H2),
	Distance is HeadDistance + TailDistance.



% 3.2 weighted_glanian_distance(Name1, Name2, Distance) 10 points

% 3.3 find_possible_cities(Name, CityList) 5 points

% 3.4 merge_possible_cities(Name1, Name2, MergedCities) 5 points

% 3.5 find_mutual_activities(Name1, Name2, MutualActivities) 5 points

% 3.6 find_possible_targets(Name, Distances, TargetList) 10 points

% 3.7 find_weighted_targets(Name, Distances, TargetList) 15 points

% 3.8 find_my_best_target(Name, Distances, Activities, Cities, Targets) 20 points

% 3.9 find_my_best_match(Name, Distances, Activities, Cities, Targets) 25 points
