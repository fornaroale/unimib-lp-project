%% -*- Mode: Prolog -*-
def_class(NomeClasse, [], SlotValues) :-
    verifica(NomeClasse, [], SlotValues),
    assegna(NomeClasse, [], SlotValues).

verifica(X, Y, Z) :-
    nonvar(X), nonvar(Y), nonvar(Z).

assegna(X, [], Z) :-
    assertz((X(Z))).

