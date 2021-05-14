:- encoding(utf8).
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

calculate_weighted_distance([-1], _, [-1], Distance) :- 
	Distance is 0.

calculate_weighted_distance([H1], [H2], [H3], Distance) :-
	Distance is (H1-H2)*(H1-H2)*H3.

calculate_weighted_distance([H1|T1], [H2|T2], [H3|T3], Distance) :-
	calculate_weighted_distance(T1, T2, T3, TailDistance),
	calculate_weighted_distance([H1], [H2], [H3], HeadDistance),
	Distance is HeadDistance + TailDistance.

% 3.3 find_possible_cities(Name, CityList) 5 points
find_possible_cities(Name, CityList) :- 
	find_liked_cities(Name, LikedCities), 
	find_current_city(Name, CurrentCity), 
	append([CurrentCity], LikedCities, CityList2),
	remove_duplicates(CityList2, CityList).

find_liked_cities(Name, CityList) :- 
	findall(X, likes(Name, _, X), [CityList]).

find_current_city(Name, City) :- 
	all_cities(CityList), 
	member(City, CityList), 
	is_living(Name, City).

is_living(Name, City) :- 
	city(City, HabitantList, _), 
	member(Name, HabitantList). 

all_cities(CityList) :- 
	findall(X, city(X, _, _), CityList).

% 3.4 merge_possible_cities(Name1, Name2, MergedCities) 5 points
merge_possible_cities(Name1, Name2, MergedCities) :- 
	find_possible_cities(Name1, CityList1), 
	find_possible_cities(Name2, CityList2), 
	append(CityList1, CityList2, MergedCitiesDuplicates), 
	remove_duplicates(MergedCitiesDuplicates, MergedCities).

remove_duplicates([], []).

remove_duplicates([Head|Tail], NewTail) :- 
	member(Head, Tail), 
	remove_duplicates(Tail, NewTail).

remove_duplicates([Head|Tail], [Head|NewTail]) :- 
	not(member(Head, Tail)), 
	remove_duplicates(Tail, NewTail).
	

% 3.5 find_mutual_activities(Name1, Name2, MutualActivities) 5 points
find_mutual_activities(Name1, Name2, MutualActivities) :-
	likes(Name1, Activities1, _),
	likes(Name2, Activities2, _),
	find_mutuals(Activities1, Activities2, MutualActivities).

find_mutuals([], _, []).
find_mutuals([Head1|Tail1], List2, Intersection) :- 
	member(Head1, List2),
	find_mutuals(Tail1, List2, Intersection2),
	append([Head1], Intersection2, Intersection).

find_mutuals([Head1|Tail1], List2, Intersection) :- 
	not(member(Head1, List2)),
	find_mutuals(Tail1, List2, Intersection).
	

% 3.6 find_possible_targets(Name, Distances, TargetList) 10 points
find_possible_targets(Name, Distances, TargetList) :- 
	findall(TargetName, (glanian(TargetName, Gender, _), expects(Name, ExpectedGenderList, _), member(Gender, ExpectedGenderList)), TargetListUnsorted),
	find_possible_distances(Name, TargetListUnsorted, DistancesAndHeads),
	keysort(DistancesAndHeads, DistancesAndHeadsSorted),
	findall(X, member(X-_,DistancesAndHeadsSorted), Distances),
	findall(Y, member(_-Y,DistancesAndHeadsSorted), TargetList).

find_possible_distances(Name, [Head|Tail], Distances) :-
	glanian_distance(Name, Head, Distance),
	find_possible_distances(Name, Tail, TailDistance),
	append([Distance-Head], TailDistance, Distances).

find_possible_distances(_, [], []).


% 3.7 find_weighted_targets(Name, Distances, TargetList) 15 points
find_weighted_targets(Name, Distances, TargetList) :- 
	findall(TargetName, (glanian(TargetName, Gender, _), expects(Name, ExpectedGenderList, _), member(Gender, ExpectedGenderList)), TargetListUnsorted),
	find_possible_weighted_distances(Name, TargetListUnsorted, DistancesAndHeads),
	keysort(DistancesAndHeads, DistancesAndHeadsSorted),
	findall(X, member(X-_,DistancesAndHeadsSorted), Distances),
	findall(Y, member(_-Y,DistancesAndHeadsSorted), TargetList).

find_possible_weighted_distances(Name, [Head|Tail], Distances) :-
	weighted_glanian_distance(Name, Head, Distance),
	find_possible_weighted_distances(Name, Tail, TailDistance),
	append([Distance-Head], TailDistance, Distances).

find_possible_weighted_distances(_, [], []).

% 3.8 find_my_best_target(Name, Distances, Activities, Cities, Targets) 20 points
find_my_best_target(Name, Distances, Activities, Cities, Targets) :-
	find_targets(Name, TargetList),
	find_cities(Name, TargetList, CityList, TargetListDuplicated),
	find_activities(Name, CityList, TargetListDuplicated, Activities, Targets, Cities),
	find_distances(Name, Targets, Distances),
	print(Activities),
	print(Cities),
	print(Targets),
	print(Distances).

find_distances(Name, [Head|Tail], Distances) :-
	glanian_distance(Name, Head, Distance),
	find_distances(Name, Tail, TailDistance),
	append([Distance], TailDistance, Distances).

find_distances(_, [], []).	

find_activities(_, [], [], [], [], []).	

find_activities(Name, [CityHead|CityTail], [TargetHead|TargetTail], ActivityList, TargetList, CityList) :- 
	find_activities(Name, CityTail, TargetTail, Activity2, Target2, City2),
	find_activities_in_city(Name, CityHead, ActivityHead),
	length(ActivityHead, Times),
	write_x_times(CityHead, Times, CityListHead),
	write_x_times(TargetHead, Times, TargetListHead),
	append(TargetListHead, Target2, TargetList),
	append(CityListHead, City2, CityList),
	append(ActivityHead, Activity2, ActivityList).

decr(X,NX) :-
    NX is X-1.

write_x_times(Name, Times, List) :- 
	Times =\= 0,
	decr(Times, NewTimes),
	write_x_times(Name, NewTimes, List2),
	append([Name], List2, List).

write_x_times(_, 0, []).	

find_activities_in_city(Name, CityName, ActivityList) :- 
	dislikes(Name, DislikedActivities, _, _),
	city(CityName, _, ActivityHead2),
	findall(ActivityName, (member(ActivityName, ActivityHead2), not(member(ActivityName, DislikedActivities))), ActivityList).

find_cities(Name, [TargetHead|TargetTail], CityList, TargetsDuplicated) :-
	find_possible_cities(Name, CityList1),
	dislikes(Name, _, DislikedCities, _),
	activity_cities(Name, CityList3),
	findall(CityName, (city(CityName, _, _), (member(CityName, CityList1);member(CityName, CityList3)), not(member(CityName, DislikedCities)), merge_possible_cities(Name, TargetHead, CityList2), member(CityName, CityList2)), CityListHead2),
	remove_duplicates(CityListHead2, CityListHead),
	length(CityListHead, Times),
	write_x_times(TargetHead, Times, TargetsDuplicatedHead),
	find_cities(Name, TargetTail, CityListTail, TargetsDuplicatedTail),
	append(TargetsDuplicatedHead, TargetsDuplicatedTail, TargetsDuplicated),
	append(CityListHead, CityListTail, CityList).

find_cities(_, [], [], []).

activity_cities(Name, CityList) :-
	likes(Name, LikedActivities, _),
	findall(CityName, (city(CityName, _ , Activities), count_intersection(LikedActivities, Activities, Count), Count>0), CityList).

find_targets(Name, TargetList) :-
	findall(TargetName, (glanian(TargetName, Gender, _), expects(Name, ExpectedGenderList, _), member(Gender, ExpectedGenderList), not(find_old_relation(Name, TargetName)), in_tolerance_limits(Name, TargetName), activity_match(Name, TargetName, Conflict), Conflict < 3), TargetList2), 
	remove_duplicates(TargetList2, TargetList).

activity_match(Name, TargetName, Conflict) :-
	dislikes(Name, DislikedActivities, _, _),
	likes(TargetName, LikedActivities, _),
	count_intersection(DislikedActivities, LikedActivities, Conflict).

count_intersection([Head1|Tail1], List2, Count) :-
	member(Head1, List2), count_intersection(Tail1, List2, Count2), Count is 1+Count2.

count_intersection([Head1|Tail1], List2, Count) :-
	not(member(Head1, List2)), count_intersection(Tail1, List2, Count).

count_intersection([], _, 0).
count_intersection(_, [], 0).	

find_old_relation(Name, TargetName) :-
	old_relation([Name, TargetName]); old_relation([TargetName, Name]).

in_tolerance_limits(Name, TargetName) :-
	glanian(TargetName, _, FeaturesList),
	dislikes(Name, _, _, Limits),
	check_tolerance_limits(FeaturesList, Limits).

check_tolerance_limits([FeaturesHead|FeaturesTail], [LimitsHead|LimitsTail]) :-
	(is_empty(LimitsHead) ; (getMinMaxLimits(LimitsHead, MinLimit, [MaxLimit]), FeaturesHead >= MinLimit, FeaturesHead =< MaxLimit)),
	check_tolerance_limits(FeaturesTail, LimitsTail).

check_tolerance_limits([], []).

getMinMaxLimits([MinLimit|MaxLimit], MinLimit, MaxLimit).

is_empty(List):- not(member(_,List)).

% 3.9 find_my_best_match(Name, Distances, Activities, Cities, Targets) 25 points
