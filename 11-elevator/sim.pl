% Run like this:
% swipl -G2g -T2g -L2g sim.pl in

:- initialization main.
main :-
  % use_module(library(nbSet)),
  opt_arguments([[opt(infile)]], _, Args),
  ([Infile] = Args, !; Infile = 'in-ex'),
  writeln(Infile),
  solve(Infile, X),
  % solve2(Infile, X),
  writeln(X),
  halt,
  [].

solve(File, FinalTurn) :-
  problem_spec(File, Spec),
  solve_as_set(Spec, FinalTurn).
  % solve([], [Spec], 0, FinalTurn).

solve2(File, FinalTurn) :-
  problem_spec(File,
               [item(chip, dilithium, 1),
                item(generator, dilithium, 1),
                item(chip, elerium, 1),
                item(generator, elerium, 1)],
               Spec),
  writeln(Spec), !, fail,
  solve([], [Spec], 0, FinalTurn).

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
  % writeln(NewConfs),
  solve(LastConfs, NewConfs, NextTurn, FinalTurn).

set_subtract(As, Bs, Cs) :-
  nb_set_to_list(As, Al),
  list_set_diff(Al, Bs, Cs).

list_set_diff([], _, Cs) :- empty_nb_set(Cs).
list_set_diff([A|Al], Bs, Cs) :-
  list_set_diff(Al, Bs, Cs),
  (add_nb_set(A, Bs, false) ; add_nb_set(A, Cs, true)).

% solve(_, [], _, _) :- !, fail.
% solve(_, LastConfs, FinalTurn, FinalTurn) :-
%   member(FinalConf, LastConfs),
%   final_configuration(FinalConf),
%   !.
% solve(PrevConfs, LastConfs, Turn, FinalTurn) :-
%   NextTurn is Turn + 1,
%   setof(ReachableConf,
%         Conf ^ (member(Conf, LastConfs), reachable(Conf, ReachableConf)),
%         ReachableConfs),
%   subtract(ReachableConfs, PrevConfs, NewNoPrev),
%   subtract(NewNoPrev, LastConfs, NewConfs),
%   length(LastConfs, L),
%   writeln([NextTurn, L]),
%   writeln(NewConfs),
%   solve(LastConfs, NewConfs, NextTurn, FinalTurn).

final_configuration([]).
final_configuration([floor(4)|Items]) :- final_configuration(Items).
final_configuration([item(_, _, 4)|Items]) :- final_configuration(Items).

reachable(Conf1, Conf2) :-
  member(floor(F), Conf1),
  next_floor(F, Fnew),
  move_items(Conf1, Conf2, F, Fnew),
  safe_floor(Conf2, F),
  safe_floor(Conf2, Fnew).

% Move one item.
move_items(Conf1, Conf2, F, Fnew) :-
  member(item(T, E, F), Conf1),
  subtract(Conf1, [floor(F), item(T, E, F)], ConfBase),
  sort([floor(Fnew), item(T, E, Fnew)|ConfBase], Conf2).
% Move two items.
move_items(Conf1, Conf2, F, Fnew) :-
  member(item(T, E, F), Conf1),
  member(item(T2, E2, F), Conf1),
  (T \= T2; E \= E2),
  subtract(Conf1, [floor(F), item(T, E, F), item(T2, E2, F)], ConfBase),
  sort([floor(Fnew), item(T, E, Fnew), item(T2, E2, Fnew)|ConfBase], Conf2).

next_floor(F, F2) :-
  (F2 is F + 1; F2 is F - 1), F2 >= 1, F2 =< 4.

safe_floor(Conf, F) :-
  \+ unsafe_floor(Conf, F).
unsafe_floor(Conf, F) :-
  member(item(chip, E, F), Conf),
  member(item(generator, E2, F), Conf),
  E \= E2,
  \+ member(item(generator, E, F), Conf).

% Input processing
problem_spec(File, Spec) :-
  phrase_from_file(lines(Items), File),
  % abstract_mats(Items, VarmatItems),
  sort([floor(1)| Items], Spec).
problem_spec(File, ExtraItems, Spec) :-
  phrase_from_file(lines(Items), File),
  union(Items, ExtraItems, AllItems),
  % abstract_mats(AllItems, VarmatItems),
  sort([floor(1)| AllItems], Spec).

abstract_mats(Il, Ev) :-
  mat_list(Il, Ml),
  list_to_set(Ml, Ms),
  length(Ms, NumMats),
  length(Vars, NumMats),
  all_different(Vars),
  match_mats(Il, Ms, Vars, Ev),
  !.

mat_list([], []).
mat_list([item(_, M, _)|Il], [M|Ml]) :- mat_list(Il, Ml).

match_mats([], _, _, []).
match_mats([I|Il], Ms, Vs, [Im|Ims]) :-
  match_mat(I, Ms, Vs, Im),
  match_mats(Il, Ms, Vs, Ims).

match_mat(item(T, M, F), [M|_], [V|_], item(T, V, F)).
match_mat(I, [_|Ms], [_|Vs], Im) :- match_mat(I, Ms, Vs, Im).

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
