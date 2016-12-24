solveIn(NumMoves) :-
  setof(Position, initialPosition(Position), Positions),
  solveIn(Positions, 0, NumMoves).
solveIn(Positions, NumMoves, NumMoves) :-
  finalPosition(FinalPos),
  member(FinalPos, Positions),
  !,
  % writeln(Positions), writeln(NumMoves)
  .
solveIn(Positions, I, NumMoves) :-
  I2 is I + 1,
  addReachable(Positions, OutPositions),
  % (I2 > 13; writeln(OutPositions), writeln(I2)),
  solveIn(OutPositions, I2, NumMoves).

addReachable(Positions, OutPositions) :-
  setof(NewPos,
        Pos ^ (member(Pos, Positions), reachable(Pos, NewPos)),
        NewPositions),
  union(Positions, NewPositions, OutPositions).

initialPosition(Conf) :-
  sort([floor(1),
        item(chip, hydrogen, 1), item(generator, hydrogen, 2),
        item(chip, lithium, 1), item(generator, lithium, 3)], Conf).
finalPosition(Conf) :-
  sort([floor(4),
        item(chip, hydrogen, 4), item(generator, hydrogen, 4),
        item(chip, lithium, 4), item(generator, lithium, 4)], Conf).

reachable(Conf1, Conf2) :-
  member(floor(F), Conf1),
  nextFloor(F, Fnew),
  moveItems(Conf1, Conf2, F, Fnew),
  safeFloor(Conf2, F),
  safeFloor(Conf2, Fnew).

% Move one item.
moveItems(Conf1, Conf2, F, Fnew) :-
  member(item(T, E, F), Conf1),
  subtract(Conf1, [floor(F), item(T, E, F)], ConfBase),
  sort([floor(Fnew), item(T, E, Fnew)|ConfBase], Conf2).
% Move two items.
moveItems(Conf1, Conf2, F, Fnew) :-
  member(item(T, E, F), Conf1),
  member(item(T2, E2, F), Conf1),
  (T \= T2; E \= E2),
  subtract(Conf1, [floor(F), item(T, E, F), item(T2, E2, F)], ConfBase),
  sort([floor(Fnew), item(T, E, Fnew), item(T2, E2, Fnew)|ConfBase], Conf2).

nextFloor(F, F2) :-
  (F2 is F + 1; F2 is F - 1), F2 >= 1, F2 =< 4.

safeFloor(Conf, F) :-
  \+ unsafeFloor(Conf, F).
unsafeFloor(Conf, F) :-
  member(item(chip, E, F), Conf),
  member(item(generator, E2, F), Conf),
  E \= E2,
  \+ member(item(generator, E, F), Conf).

% reachable(X, Y) :- Y is X + 1.
% reachable(X, Y) :- Y is X - 1.
% reachable(X, Y) :- Y is X * 2.
% initialPosition(0).
% finalPosition(62).
