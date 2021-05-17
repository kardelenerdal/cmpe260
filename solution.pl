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
	(H1 =\= -1 , H3 =\= -1),
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
	remove_duplicates(MergedCitiesDuplicates, MergedCities), !.

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
	findall(Y, member(_-Y,DistancesAndHeadsSorted), TargetList),!.

find_possible_weighted_distances(Name, [TargetHead|TargetTail], Distances) :-
	weighted_glanian_distance(Name, TargetHead, Distance),
	find_possible_weighted_distances(Name, TargetTail, TailDistance),
	append([Distance-TargetHead], TailDistance, Distances).

find_possible_weighted_distances(_, [], []).

mycombine([],[],[],[],[]).

mycombine([Dh|Dt], [Th|Tt], [Ch|Ct], [Ah|At], AllLists) :-
	mycombine(Dt, Tt, Ct, At, AllListsTail),
	append([Dh-[Th, Ch, Ah]], AllListsTail, AllLists).

mydivide([], [], [], [], []).

mydivide([Distance-[Target, City, Activity]|At], Targets, Distances, Activities, Cities) :-
	mydivide(At, TargetsTail, DistancesTail, ActivitiesTail, CitiesTail),
	append([Target], TargetsTail, Targets),
	append([City], CitiesTail, Cities),
	append([Activity], ActivitiesTail, Activities),
	append([Distance], DistancesTail, Distances).

% 3.8 find_my_best_target(Name, Distances, Activities, Cities, Targets) 20 points
find_my_best_target(Name, Distances, Activities, Cities, Targets) :-
	find_weighted_targets(Name, _, PossibleTargetList),
	find_targets(Name, PossibleTargetList, TargetList),
	find_cities_and_activities(Name, TargetList, Cities2, Activities2, Targets2),
	find_distances(Name, Targets2, Distances2),
	mycombine(Distances2, Targets2, Cities2, Activities2, AllListsUnsorted),
	keysort(AllListsUnsorted, AllLists),
	mydivide(AllLists, Targets, Distances, Activities, Cities),
	length(Activities, Al), print(Al),
	length(Cities, Cl), print(Cl),
	length(Targets, Tl), print(Tl),
	length(Distances, Dl), print(Dl),
	%print(Activities),
	%print(Cities),
	%print(Targets),
	%print(Distances),
	!.

find_distances(Name, [Head|Tail], Distances) :-
	weighted_glanian_distance(Name, Head, Distance),
	find_distances(Name, Tail, TailDistance),
	append([Distance], TailDistance, Distances).

find_distances(_, [], []).	

decr(X,NX) :-
    NX is X-1.

write_x_times(Name, Times, List) :- 
	Times =\= 0,
	decr(Times, NewTimes),
	write_x_times(Name, NewTimes, List2),
	append([Name], List2, List).

write_x_times(_, 0, []).	

divide_city_activity([], [], []).	
divide_city_activity([City-Activity|CaTail], CityList, ActivityList) :-	
	divide_city_activity(CaTail, CityListTail, ActivityListTail),
	append([City], CityListTail, CityList),
	append([Activity], ActivityListTail, ActivityList).

find_cities_and_activities(Name, [TargetHead|TargetTail], CityList, ActivityList, TargetsDuplicated) :-
	merge_possible_cities(Name, TargetHead, MergedCities),
	findall(City-Activity, (is_compatible(Name, Activity, City), member(City, MergedCities)), CityAndActivityHead2),
	remove_duplicates(CityAndActivityHead2, CityAndActivityHead),
	length(CityAndActivityHead, Times),
	write_x_times(TargetHead, Times, TargetsDuplicatedHead),
	divide_city_activity(CityAndActivityHead, CityListHead, ActivityListHead),
	find_cities_and_activities(Name, TargetTail, CityTail, ActivityTail, TargetsTail),
	append(TargetsDuplicatedHead, TargetsTail, TargetsDuplicated),
	append(CityListHead, CityTail, CityList),
	append(ActivityListHead, ActivityTail, ActivityList).

find_cities_and_activities(_, [], [], [], []).

find_targets(Name, PossibleTargetList, TargetList) :-
	expects(Name, ExpectedGenderList, _),
	findall(TargetName, (glanian(TargetName, Gender, _), member(TargetName, PossibleTargetList), member(Gender, ExpectedGenderList), not(find_old_relation(Name, TargetName)), in_tolerance_limits(Name, TargetName), activity_match(Name, TargetName, Conflict), Conflict < 3), TargetList2),
	remove_duplicates(TargetList2, TargetList).

activity_match(Name, TargetName, Conflict) :-
	dislikes(Name, DislikedActivities, _, _),
	likes(TargetName, LikedActivities, _),
	count_intersection(DislikedActivities, LikedActivities, Conflict),!.

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
find_my_best_match(Name, Distances, Activities, Cities, Targets) :-
	find_weighted_targets(Name, _, PossibleTargetList),
	find_matches(Name, PossibleTargetList, TargetList),
	%print(TargetList),
	find_cities_and_activities_matches(Name, TargetList, Cities2, Activities2, Targets2),
	find_distances_matches(Name, Targets2, Distances2),
	mycombine(Distances2, Targets2, Cities2, Activities2, AllListsUnsorted),
	keysort(AllListsUnsorted, AllLists),
	mydivide(AllLists, Targets, Distances, Activities, Cities),
	length(Activities, Al), print(Al),
	length(Cities, Cl), print(Cl),
	length(Targets, Tl), print(Tl),
	length(Distances, Dl), print(Dl),
	%print(Activities),
	%print(Cities),
	%print(Targets),
	%print(Distances),
	!.


find_matches(Name, PossibleTargetList, TargetList) :-
	glanian(Name, MyGender, _),
	expects(Name, ExpectedGenderList, _),
	findall(TargetName, (member(TargetName, PossibleTargetList), glanian(TargetName, Gender, _), member(Gender, ExpectedGenderList), expects(TargetName, ExpextedGenderList2, _), member(MyGender, ExpextedGenderList2), not(find_old_relation(Name, TargetName)), in_tolerance_limits(Name, TargetName), in_tolerance_limits(TargetName, Name), activity_match(TargetName, Name, Conflict2), Conflict2 < 3, activity_match(Name, TargetName, Conflict), Conflict < 3), TargetList2), 
	remove_duplicates(TargetList2, TargetList).


is_compatible(Name, Activity, City):-
	(city(City, Habitants, ActivitiesInCity),
		likes(Name, _, LikedCities),
		dislikes(Name, DislikedActivities, _, _),
		(member(Name, Habitants) ; (member(City, LikedCities))), member(Activity, ActivitiesInCity), not(member(Activity, DislikedActivities)));
	(dislikes(Name, _, DislikedCities2, _),
		likes(Name, LikedActivities2, _),
		city(City, _, ActivitiesInCity), not(member(City, DislikedCities2)), member(Activity, ActivitiesInCity), member(Activity, LikedActivities2)).	


find_cities_and_activities_matches(Name, [TargetHead|TargetTail], CityList, ActivityList, TargetsDuplicated) :-
	merge_possible_cities(Name, TargetHead, MergedCities),
	findall(City-Activity, (is_compatible(Name, Activity, City), is_compatible(TargetHead, Activity, City), member(City, MergedCities)), CityAndActivityHead2),
	remove_duplicates(CityAndActivityHead2, CityAndActivityHead),
	length(CityAndActivityHead, Times),
	write_x_times(TargetHead, Times, TargetsDuplicatedHead),
	divide_city_activity(CityAndActivityHead, CityListHead, ActivityListHead),
	find_cities_and_activities_matches(Name, TargetTail, CityTail, ActivityTail, TargetsTail),
	append(TargetsDuplicatedHead, TargetsTail, TargetsDuplicated),
	append(CityListHead, CityTail, CityList),
	append(ActivityListHead, ActivityTail, ActivityList).

find_cities_and_activities_matches(_, [], [], [], []).	

find_distances_matches(Name, [Head|Tail], Distances) :-
	weighted_glanian_distance(Name, Head, Distance1),
	weighted_glanian_distance(Head, Name, Distance2),
	find_distances_matches(Name, Tail, TailDistance),
	Distance is (Distance1 + Distance2)/2,
	append([Distance], TailDistance, Distances).

find_distances_matches(_, [], []).	
