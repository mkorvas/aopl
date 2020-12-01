% Run like this:
% swipl -G2g -T2g -L2g sim.pl in

:- initialization main.
main :-
  opt_arguments([[opt(infile)]], _, Args),
  ([Infile] = Args, !; Infile = 'in-ex'),
  writeln(Infile),
  solve(Infile, X),
  % solve2(Infile, X),
  writeln(X),
  halt,  % Comment this out for use in an interactive session.
  [].

solve(File, FinalTurn) :-
  problem_spec(File, Spec),
  solve_as_list(Spec, FinalTurn), !.
  % solve_as_set(Spec, FinalTurn), !.

solve2(File, FinalTurn) :-
  problem_spec(File, [cg(1, 1), cg(1, 1)], Spec),
  solve_as_list(Spec, FinalTurn), !.
  % solve_as_set(Spec, FinalTurn), !.

solve_as_list(Conf, FinalTurn) :-
  solve_as_list([], [Conf], 0, FinalTurn).

solve_as_list(_, [], _, _) :- !, fail.
solve_as_list(_, LastConfs, FinalTurn, FinalTurn) :-
  member(Conf, LastConfs),
  final_configuration(Conf),
  !.
solve_as_list(PrevConfs, LastConfs, Turn, FinalTurn) :-
  NextTurn is Turn + 1,
  setof(ReachableConf,
        Conf ^ (member(Conf, LastConfs), reachable(Conf, ReachableConf)),
        ReachableConfs),
  subtract(ReachableConfs, PrevConfs, NewNoPrev),
  subtract(NewNoPrev, LastConfs, NewConfs),
  length(LastConfs, L),
  writeln([NextTurn, L]),
  solve_as_list(LastConfs, NewConfs, NextTurn, FinalTurn).

solve_as_set(Conf, FinalTurn) :-
  empty_nb_set(NoConfs),
  empty_nb_set(LastConfs),
  add_nb_set(Conf, LastConfs, true),
  solve(NoConfs, LastConfs, 0, FinalTurn).

solve(_, LastConfs, _, _) :- empty_nb_set(LastConfs), !, fail.
solve(_, LastConfs, FinalTurn, FinalTurn) :-
  gen_nb_set(LastConfs, Conf),
  final_configuration(Conf),
  !.
solve(PrevConfs, LastConfs, Turn, FinalTurn) :-
  NextTurn is Turn + 1,
  setof(ReachableConf,
        Conf ^ (gen_nb_set(LastConfs, Conf), reachable(Conf, ReachableConf)),
        ReachableConfs),
  list_set_diff(ReachableConfs, PrevConfs, NewNoPrev),
  set_subtract(NewNoPrev, LastConfs, NewConfs),
  size_nb_set(LastConfs, L),
  writeln([NextTurn, L]),
  solve(LastConfs, NewConfs, NextTurn, FinalTurn).

set_subtract(As, Bs, Cs) :-
  nb_set_to_list(As, Al),
  list_set_diff(Al, Bs, Cs).

list_set_diff([], _, Cs) :- empty_nb_set(Cs).
list_set_diff([A|Al], Bs, Cs) :-
  list_set_diff(Al, Bs, Cs),
  (add_nb_set(A, Bs, false) ; add_nb_set(A, Cs, true)).

final_configuration([]).
final_configuration([floor(4)|Items]) :- final_configuration(Items).
final_configuration([cg(4, 4)|Items]) :- final_configuration(Items).

reachable(Conf1, Conf2) :-
  member(floor(F), Conf1),
  next_floor(F, Fnew),
  move_items(Conf1, Conf2, F, Fnew),
  safe_floor(Conf2, F),
  safe_floor(Conf2, Fnew).

elevable([chip]).
elevable([generator]).
elevable([chip_and_generator]).
elevable([chip, chip]).
elevable([chip, generator]).
elevable([generator, generator]).

move_items(Conf1, Conf2, F, Fnew) :-
  elevable(Items),
  move_items(F, Fnew, Items, Conf1, Conf2F),
  selectchk(floor(F), Conf2F, floor(Fnew), Conf2Unsorted),
  msort(Conf2Unsorted, Conf2).

move_items(_, _, [], Conf, Conf).
move_items(F, Fnew, [T|Tl], Conf1, [Moved|MovedRest]) :-
  move_item(F, Fnew, T, Conf1, Remains, Moved),
  move_items(F, Fnew, Tl, Remains, MovedRest).

move_item(F, Fnew, chip, Conf, Remains, cg(Fnew, FG)) :-
  select(cg(F, FG), Conf, Remains).
move_item(F, Fnew, generator, Conf, Remains, cg(FC, Fnew)) :-
  select(cg(FC, F), Conf, Remains).
move_item(F, Fnew, chip_and_generator, Conf, Remains, cg(Fnew, Fnew)) :-
  select(cg(F, F), Conf, Remains).

next_floor(F, F2) :-
  (F2 is F + 1; F2 is F - 1), F2 >= 1, F2 =< 4.

safe_floor(Conf, F) :-
  \+ unsafe_floor(Conf, F).
unsafe_floor(Conf, F) :-
  member(cg(F, FG), Conf),
  F \= FG,
  member(cg(_, F), Conf).

% Input processing
problem_spec(File, Spec) :-
  phrase_from_file(lines(Items), File),
  to_cg_pairs(Items, Pairs),
  msort([floor(1)| Pairs], Spec), !.
problem_spec(File, ExtraPairs, Spec) :-
  phrase_from_file(lines(Items), File),
  to_cg_pairs(Items, Pairs),
  append(Pairs, ExtraPairs, AllPairs),
  msort([floor(1)| AllPairs], Spec), !.

to_cg_pairs([], []).
to_cg_pairs(Items, [cg(FC, FG)|Pl]) :-
  selectchk(item(chip, E, FC), Items, ItemsNoChip),
  selectchk(item(generator, E, FG), ItemsNoChip, ItemsNoE),
  to_cg_pairs(ItemsNoE, Pl), !.

% Input parsing
eos([], []).

lines([]) --> eos, !.
lines(AllItems) -->
  line(Items), lines(MoreItems),
  { append(Items, MoreItems, AllItems) }.

line([]) --> ( "\n"; eos ), !.
line(AllItems) -->
  simple_line(Items), lines(MoreItems),
  { append(Items, MoreItems, AllItems) }.

simple_line([], A, Z) :-
  nothing_relevant(A, Z), !.
simple_line(Items, A, Z) :-
  floor_items(Items, A, Z), !.

nothing_relevant --> "The ", word(_), " floor contains nothing relevant.".
floor_items(FloorItems) -->
  "The ", floor_name(F), " floor contains", items(Is), ".",
  { items_with_floor(Is, F, FloorItems) }.

floor_name(1) --> "first".
floor_name(2) --> "second".
floor_name(3) --> "third".
floor_name(4) --> "fourth".

items([]) --> "".
items(Is) --> list_joiner(_), items(Is).
items([item(chip, E)|Is]) -->
  " a ", word(E), "-compatible microchip", items(Is).
items([item(generator, E)|Is]) -->
  " a ", word(E), " generator", items(Is).

list_joiner(_) --> ","; " and"; ", and".

items_with_floor([], _F, []).
items_with_floor([item(T, E)|Is], F, [item(T, E, F)|Ifs]) :-
  items_with_floor(Is, F, Ifs).

word(W) --> alpha(L), alpha_star(Ls), { atom_codes(W, [L|Ls]) }.
alpha(X) --> [X], { code_type(X, alpha) }.
alpha_star([]) --> [].
alpha_star([L|Ls]) --> alpha(L), !, alpha_star(Ls).

% first problem, avoiding all configurations seen so far:
%   4629.32user 9.66system 1:19:13elapsed 97%CPU (0avgtext+0avgdata 217328maxresident)k
%   0inputs+0outputs (0major+135144minor)pagefaults 0swaps
% first problem, avoiding only configurations from the preceding step:
%   438.28user 1.57system 7:38.91elapsed 95%CPU (0avgtext+0avgdata 116044maxresident)k
%   0inputs+0outputs (0major+111250minor)pagefaults 0swaps
% ... optimizations...
% second problem, solve_as_set:
%   4.30user 0.06system 0:04.38elapsed 99%CPU (0avgtext+0avgdata 43444maxresident)k
%   0inputs+0outputs (0major+9127minor)pagefaults 0swaps
% second problem, solve_as_list:
%   4.10user 0.06system 0:04.18elapsed 99%CPU (0avgtext+0avgdata 11648maxresident)k
%   0inputs+0outputs (0major+5570minor)pagefaults 0swaps
