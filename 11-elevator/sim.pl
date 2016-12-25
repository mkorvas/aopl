:- initialization main.
main :-
  opt_arguments([[opt(infile)]], _, Args),
  ([Infile] = Args, !; Infile = 'in-ex'),
  writeln(Infile),
  solve(Infile, X),
  writeln(X),
  halt.

solve(File, FinalTurn) :-
  problem_spec(File, Spec),
  solve([], [Spec], 0, FinalTurn).

solve(_, [], _, _) :- !, fail.
solve(_, LastConfs, FinalTurn, FinalTurn) :-
  member(FinalConf, LastConfs),
  final_configuration(FinalConf),
  !.
solve(PrevConfs, LastConfs, Turn, FinalTurn) :-
  NextTurn is Turn + 1,
  setof(ReachableConf,
        Conf ^ (member(Conf, LastConfs), reachable(Conf, ReachableConf)),
        ReachableConfs),
  subtract(ReachableConfs, PrevConfs, NewNoPrev),
  subtract(NewNoPrev, LastConfs, NewConfs),
  length(LastConfs, L),
  writeln([NextTurn, L]),
  solve(LastConfs, NewConfs, NextTurn, FinalTurn).

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

% Input parsing
problem_spec(File, Spec) :-
  phrase_from_file(lines(Items), File),
  sort([floor(1)| Items], Spec).

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
