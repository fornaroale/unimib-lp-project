
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


% Definisce classe
def_class(ClassName, Parents, SlotValues) :-
    countClasses(ClassName, Count),
    Count is 0, !,
    assertz(class(ClassName, Parents, SlotValues)).


% def_class in caso di cut: restituisce errore
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


% getInstanceSlot: ritorna il valore di un attributo
% MANCA: Controllo se l'elemento cercato non c'e'
getInstanceSlot(InstanceName, SlotName, SlotValue) :-
    getInstanceSlots(InstanceName, Slots),
    indexOf(Slots, SlotName, Index),
    ValueIndex is Index+1,
    nth0(ValueIndex, Slots, SlotValue).


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
    write("' non esiste.").


% indexOf/3: ritorna posizione di elemento nella lista
indexOf([Element|_], Element, 0):- !.
indexOf([_|Tail], Element, Index):-
  indexOf(Tail, Element, Index1),
  !,
  Index is Index1+1.

