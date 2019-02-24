
% valori di default per evitare errori sulle count
class(defaultCatchCountError).
superclass(defaultCatchCountError,
           defaultCatchCountError2).
slot_value_in_class(defaultCatchCountError,
                    defaultCatchCountError2,
                    defaultCatchCountError3).
slot_value_in_instance(defaultCatchCountError,
                       defaultCatchCountError2,
                       defaultCatchCountError3).
instance_of(defaultCatchCountError,
            defaultCatchCountError2).


% conta il numero di classi aventi il nome passato per parametro
countClasses(ClassName, Count) :-
    findall(ClassName, class(ClassName), Z),
    length(Z, Count).


% conta il numero di istanze aventi il nome passato per parametro
countInstances(InstanceName, Count) :-
    findall(InstanceName, instance_of(InstanceName,_), Z),
    length(Z, Count).


% def_class/3: definisce classe aggiungendola alla knowledge base
def_class(ClassName, Parents, SlotValues) :-
    countClasses(ClassName, Count),
    Count is 0, !,
    assertz(class(ClassName)),
    defSuperClasses(ClassName, Parents),
    defClassSlots(ClassName, SlotValues).


% def_class/3 in caso di cut: restituisce errore
def_class(ClassName, _, _) :-
    write("Errore: "),
    write(ClassName),
    write(" e' una classe gia' definita."),
    fail.


% defSuperClasses/2: definisce le superclassi di una classe
defSuperClasses(_, []) :- !.
defSuperClasses(ClassName, [H]) :-
    assertz(superclass(H, ClassName)).
defSuperClasses(ClassName, [H|T]) :-
    assertz(superclass(H, ClassName)),
    defSuperClasses(ClassName, T).


% defClassSlots/2: definisce gli attributi di una classe
% Nota: se il numero di attributi e' dispari ritorna false
defClassSlots(_, []) :- !.
defClassSlots(ClassName, [X,Y]) :-
    assertz(slot_value_in_class(X, Y, ClassName)).
defClassSlots(ClassName, [X,Y|T]) :-
    assertz(slot_value_in_class(X, Y, ClassName)),
    defClassSlots(ClassName, T).


% new/2: richiama new/3
new(InstanceName, ClassName) :-
    new(InstanceName, ClassName, []), !.


% new/3: aggiunge alla knowledge base l'istanza
% MANCA: copia attributi classe e parents
new(InstanceName, ClassName, SlotValues) :- %slotValues DA FARE!
    % controllo esistenza classe
    countClasses(ClassName, CountClasses),
    CountClasses is 1, !,
    % controllo che non siano presenti istanze omonime
    countInstances(InstanceName, CountInstances),
    CountInstances is 0, !,
    % creo l'istanza
    assertz(instance_of(InstanceName, ClassName)),
    % assegno attributi ad istanza
    defInstanceSlots(InstanceName, SlotValues),
    % scrivo messaggio di conferma istanziazione
    write("Istanza '"),
    write(InstanceName),
    write("' di classe '"),
    write(ClassName),
    write("' creata con successo").


% new/3 in caso di cut: restituisce errore
new(InstanceName, ClassName, _) :-
    write("Errore durante creazione istanza '"),
    write(InstanceName),
    write("' di classe '"),
    write(ClassName),
    write("'."),
    fail.


% defInstanceSlots/2: funzione momentanea per assegnamento
% attributi istanza (mancano attributi di classe e parents)
defInstanceSlots(_, []) :- !.
defInstanceSlots(InstanceName, [X,Y]) :-
    assertz(slot_value_in_instance(X, Y, InstanceName)).
defInstanceSlots(InstanceName, [X,Y|T]) :-
    assertz(slot_value_in_instance(X, Y, InstanceName)),
    defInstanceSlots(InstanceName, T).


% getv/3: restituisce valore associato all'attributo
getv(InstanceName, SlotName, Result) :-
    % verifico esistenza istanza
    countInstances(InstanceName, Count),
    Count is 1, !,
    % verifico esistenza attributo (altr. ritorna false)
    % e, nel caso, lo ritorna
    findall(SlotValues,
            slot_value_in_instance(SlotName,SlotValues,InstanceName),
            Result),
    length(Result, CountSlot),
    CountSlot > 0.


% getv/3: in caso di cut
getv(InstanceName, _, _) :-
    write("Errore: istanza "),
    write(InstanceName),
    write(" inesistente."),
    fail.




% --------------------------------------------------------
%  FUNZIONI AL MOMENTO INUTILIZZATE:

% indexOf/3: ritorna posizione di elemento nella lista
% Se non lo trova, ritorna false!
indexOf([Element|_], Element, 0):- !.
indexOf([_|Tail], Element, Index):-
  indexOf(Tail, Element, Index1), !,
  Index is Index1+1.


% getElementAt/3: ritorna l'elemento che si trova nella
% posizione specificata nella lista
getElementAt(Lista, Index, X) :-
    getElementAt(Lista, 0, Index, X).
getElementAt([X|_], N, N, X) :- !.
getElementAt([_|Xs], T, N, X) :-
    T1 is T+1,
    getElementAt(Xs, T1, N, X).

% --------------------------------------------------------
