
% valori di default per evitare errori sulle count
class(default, default, default).
instance(default, default, default).


% conta il numero di classi aventi il nome passato per parametro
countClasses(ClassName, Count) :-
    findall(ClassName, class(ClassName,_,_), Z),
    length(Z, Count).

% conta il numero di istanze aventi il nome passato per parametro
countInstances(InstanceName, Count) :-
    findall(InstanceName, instance(InstanceName,_,_), Z),
    length(Z, Count).


% def_class/3: definisce classe aggiungendola alla knowledge base
def_class(ClassName, Parents, SlotValues) :-
    countClasses(ClassName, Count),
    Count is 0, !,
    assertz(class(ClassName, Parents, SlotValues)).


% def_class/3 in caso di cut: restituisce errore
def_class(ClassName, _, _) :-
    write("Errore: "),
    write(ClassName),
    write(" e' una classe gia' definita."),
    fail.


% new/2: richiama new/3
new(InstanceName, ClassName) :-
    new(InstanceName, ClassName, []), !.


% new/3: aggiunge alla knowledge base l'istanza
% MANCA: copia attributi classe e parents
new(InstanceName, ClassName, SlotValues) :-
    % controllo esistenza classe
    countClasses(ClassName, CountClasses),
    CountClasses is 1, !,
    % controllo che non siano presenti istanze omonime
    countInstances(InstanceName, CountInstances),
    CountInstances is 0, !,
    % creo l'istanza e scrivo messaggio di conferma
    assertz(instance(InstanceName, ClassName, SlotValues)),
    write("Istanza '"),
    write(InstanceName),
    write("' di classe '"),
    write(ClassName),
    write("' creata con successo").


% new/3 in caso di cut: restituisce errore
new(_, ClassName, _) :-
    write("Errore: classe "),
    write(ClassName),
    write(" inesistente."),
    fail.


% getv/3: restituisce valore associato all'attributo
getv(InstanceName, SlotName, Result) :-
    getInstanceSlot(InstanceName, SlotName, Result).


% getInstanceSlot/3: ritorna il valore di un attributo
% (controllando che sia un nome e non un valore)
getInstanceSlot(InstanceName, SlotName, SlotValue) :-
    getInstanceSlots(InstanceName, Slots),
    indexOf(Slots, SlotName, Index), !,
    Index mod 2 =:= 0, !,
    ValueIndex is Index + 1,
    getElementAt(Slots, ValueIndex, SlotValue).


% getInstanceSlot/3 in caso di cut
getInstanceSlot(_,_,_) :-
    write("Nome di attributo ricercato non presente."),
    fail.


% getInstanceSlots/2: ritorna la lista contenente gli
% attributi contenuti nell'istanza
getInstanceSlots(InstanceName, Slots) :-
    countInstances(InstanceName, Count),
    Count is 1, !,
    instance(InstanceName,_,Slots),
    length(Slots, SlotsLength),
    SlotsLength > 0.


% getInstanceSlots/2 in caso di cut
getInstanceSlots(InstanceName, _) :-
    write("L'istanza di nome '"),
    write(InstanceName),
    write("' non esiste."),
    fail.


% indexOf/3: ritorna posizione di elemento nella lista
% Se non lo trova, ritorna false!
indexOf([Element|_], Element, 0):- !.
indexOf([_|Tail], Element, Index):-
  indexOf(Tail, Element, Index1),
  !,
  Index is Index1 + 1.


% getElementAt/3: ritorna l'elemento che si trova nella
% posizione specificata nella lista
getElementAt(Lista, Index, X) :-
    getElementAt(Lista, 0, Index, X).
getElementAt([X|_], N, N, X) :-
    !.
getElementAt([_|Xs], T, N, X) :-
    T1 is T+1,
    getElementAt(Xs, T1, N, X).
