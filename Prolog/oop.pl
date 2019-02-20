%% -*- Mode: Prolog -*-
% Metodo di base, verifica se parents e' una lista di simboli come
% richiesto, se la condizione e' verificata aggiunge alla base di
% conoscenza i predicati:
% class(NomeClasse) - superclass(Nomeclasse, [parents]),
% slot_value_in_class(NomeClasse, Valori).
%
% In questo modosarà più semplice recuperare le informazioni avendo dei
% predicati separati e usando il nome della classe come "chiave
% principale"
%
% Verifica inoltre che la classe non sia già stata definita, assumendo
% che non ci possonon essere due classi con lo stesso nome, di
% conzeguenza posso avere un unico predicato del tipo class(NomeClasse)
% riferito a una singola classe.
def_class(NomeClasse, Parents, Values):-
  is_listOf_atom(Parents),
  not(class(NomeClasse)), %funziona solo se all'inizio dichiari un predicato class a caso e poi puoi anche rimuoverlo.
  assert(class(NomeClasse)),
  assert(superclass(NomeClasse, Parents)),
  assert(slot_value_in_class(NomeClasse, Values)). %da modificare


%Verifica se la lista passata come parametro contiene solo atomi
is_listOf_atom(X) :-
        var(X), !,
        fail.
is_listOf_atom([]).
is_listOf_atom([H|T]) :-
        atom(H), is_listOf_atom(T).

%Funziona ma devo ancora capire come sfruttarlo
extract_method([],[]).
extract_method([H|_], [H]):-
    (functor(H, method, _)).
extract_method([H|T], [T1]):-
    not((functor(H, method, _))),
    extract_method(T, [T1]).


%non l'ho usato ma può tornare utile
is_alist(X) :-
        var(X), !,
        fail.
is_alist([]).
is_alist([_|T]) :-
    is_alist(T).




