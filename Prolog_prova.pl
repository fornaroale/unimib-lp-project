%% -*- Mode: Prolog -*-
def_class(NomeClasse, Parents, SlotValues) :-
    verifica(NomeClasse, Parents, SlotValues),
    assegna(NomeClasse, Parents, SlotValues).

verifica(X, Y, Z) :-
    nonvar(X), nonvar(Y), nonvar(Z).

assegna(X, Y, Z) :-
    assertz(X, (Y, Z)).
