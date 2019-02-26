
%%% regole create per permettere ai metodi di modificare la BC runtime
%:- dynamic def_class/3.
%:- dynamic class/1.
%:- dynamic slot_value_in_class/3.

%%% valori di default per evitare errori sulle count
class([]). %% aggiunto per il caso in cui parents sia vuoto
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
    existSuperClasses(Parents),
    assertz(class(ClassName)),
    defSuperClasses(ClassName, Parents),
    defClassSlotT(ClassName, SlotValues).


% def_class/3 in caso di cut: restituisce errore
def_class(ClassName, _, _) :-
    write("Errore: "),
    write(ClassName),
    write(" e' una classe gia' defiNita."),
    fail.


%%% defClassSlotT/2
%%% metodo per creare istanze di slot_value_in_class
%%% che splitta i valori, rimuove gli = e istanzia gli attributi
defClassSlotT(ClassName, SlotValues) :-
    split_values(SlotValues, X),
    remove_equals(X, _, Out),
    defClassSlots(ClassName, Out).


% defSuperClasses/2: definisce le superclassi di una classe
defSuperClasses(_, []) :- !.
defSuperClasses(ClassName, [H|T]) :-
    existClass(ClassName),
    defSuperClasses(ClassName, T),
    assertz(superclass(H, ClassName)).


% defClassSlots/2: definisce gli attributi di una classe
% Nota: se il numero di attributi e' dispari ritorna false
defClassSlots(_, []) :- !.
defClassSlots(ClassName, [X,Y]) :-
    assertz(slot_value_in_class(X, Y, ClassName)).
defClassSlots(ClassName, [X,Y|T]) :-
    assertz(slot_value_in_class(X, Y, ClassName)),
    defClassSlots(ClassName, T).


% existSuperClasses/1: controlla che i parents esistano
existSuperClasses([]) :- !.
existSuperClasses([H|T]) :-
    countClasses(H, Count),
    Count > 0, !,
    existSuperClasses(T).


% existClass/1: controlla che la classe esista
existClass(ClassName) :-
    countClasses(ClassName, Count),
    Count > 0.

% split_values/2: esegue lo split della lista iniziale
% Input:[nome = 'lele', anni = 20, saluta = method([], saluta(salve))])
% Output: X = [saluta, method([], saluta(salve)), anni, 20, nome, lele]
split_values([], X) :-
    append([], X, X).
split_values([H|T], Z):-
   H =.. Y,
   split_values(T, X),
   append(X, Y, Z).

%remove_equals/3: rimuove il carattere uguale dalla lista, prendendo in
% input la lista restituita da split_values.
% Input: [=, saluta, method([], saluta(salve)), =, anni, 20, =, nome, lele]
% Output: X = [saluta, method([], saluta(salve)), anni, 20, nome, lele]
remove_equals([], X, X).
remove_equals([X, Y, Z|T], L, W):-
    X = '=',
    remove_equals(T, [Y, Z], X1),
    append(L, X1, W).



%%% gestione_methods/1
%%% presa la lista di attributi ne estrae metodo e
%%% relativo nome e lo istanzia
gestione_methods([X, Y|T]):-
    extract_methods(Y, Z),
    gestione_methods(T),
    functor(Y, method, _),
    process_method(X, Z).

gestione_methods([]).

%%% process_methods/2
%%% preso il nome del metodo e il metodo
%%% lo inserisce come fatto nella base di conoscenza
process_method(X, Y) :-
    Term =.. [X, Y],
    assert(Term).


%list_methods/2: estrae tutti i metodi dalla lista splittata
%Input: [saluta, method([], saluta(salve)), anni, 20, nome, lele]
%Result: X = [method([], saluta(salve))]
extract_methods(W, []):-
   %verifica se non e' un predicato
   not((functor(W, method, _))).
extract_methods(W, [W]):-
    %verifica se e' un predicato "method(..)"
    (functor(W, method, _)).

% verifica se e' un metodo, se si mi ritorna il metodo come lista,
% altrimenti mi ritorna una lista vuota, infine fa un append per riunire
% tutte le liste.
list_methods([], []).
list_methods([H|T], X):-
    extract_methods(H, Z),
    list_methods(T, Y),
    append(Y, Z, X).


% New/2: Richiama new/3
new(InstanceName, ClassName) :-
    new(InstanceName, ClassName, []), !.


%%% new/3: aggiunge alla knowledge base l'istanza
%%% MANCA: copia attributi classe e parents
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


%%% new/3 in caso di cut: restituisce errore
new(InstanceName, ClassName, _) :-
    write("Errore durante creazione istanza '"),
    write(InstanceName),
    write("' di classe '"),
    write(ClassName),
    write("'."),
    fail.


%%% generateInstanceSlots/2: genera la lista di slot contenente gli
%%% attributi della classe e dei parent
generateInstanceSlots(ClassName, ParentsValues) :-
    %% estraggo gli attributi dalla classe
    getClassSlots(ClassName, ClassSlots),
    %% mi assicuro che abbia dei parents
    hasParents(ClassName, Parents), !,
    %% estraggo gli attributi dai parents
    getParentsSlots(Parents, ParentsSlots),
    %% append tra lista attributi classe e parents
    append(ParentsSlots, ClassSlots, AppendList),
    %% trasformo ParentsValues in FlatSlots, nella forma:
    %%    [nomeAtt1, valAtt1, nomeAtt2, valAtt2]
    flatten(AppendList, FlatList),
    %% rimuovo duplicati
    findDuplicates(FlatList, ParentsValues).
    % DA FARE: aggiungere attributi utente
    %............


%%% generateInstanceSlots/2 per classe che non ha parents:
generateInstanceSlots(ClassName, ParentsValues) :-
    % mi limito a ritornare gli attributi della classe
    getClassSlots(ClassName, ParentsValues).


%%% ----------------------------------------------------------------------
%%% CODICE MIO PER ELIMINARE DUPLICATI ATTRIBUTI:

%%% findDuplicates/3: cerca i duplicati per ogni coppia attributo-valore
%%% e li rimuove dalla lista, resituendo una List priva di duplicati
findDuplicates([SlotName,SlotValue|T], List) :-
    %% Toglie un duplicato e lo mette in ListNew
    delDuplicate(T, SlotName, TNew), !,
    findDuplicates([SlotName,SlotValue|TNew], List).
%%% Quando non trova piu' duplicati:
findDuplicates([SlotName,SlotValue|T], List) :-
    findDuplicates(T, [SlotName, SlotValue | List]).
findDuplicates([],List) :-
    write(List).


%%% delDuplicates/3: rimuove dalla lista un attributo di nome SlotName
%%% Se non lo trova, ritorna false
delDuplicate(ListOld, SlotName, ListNew) :-
    %% se trovo un duplicato:
    indexOf(ListOld, SlotName, Index), !,
    %% cancello name dell'attributo dalla lista
    delFromList(Index, ListOld, CleanList),
    %% dopo aver cancellato il name, il value avra' stessa index
    delFromList(Index, CleanList, ListNew).

%%% ----------------------------------------------------------------------

%%% CODICE LELE PER ELIMINARE DUPLICATI ATTRIBUTI:

provaFFF([SlotName,_SlotValue|T], Lista) :-
    indexOf(Lista, SlotName, _Index), !,
    provaFFF(T, Lista).

provaFFF([SlotName,SlotValue|T], Lista) :-
    append([SlotName], SlotValue, Lista),
    provaFFF(T, Lista).

%%% ----------------------------------------------------------------------


%%% delete/3
delFromList(0, [_|T], T).
delFromList(X, [H|T], [H|T2]) :-
    NuovaX is X-1,
    delFromList(NuovaX, T, T2).


%%% flatten/2: porta i componenti di una lista al 'primo livello'
flattenList([], []) :- !.
flattenList([L|Ls], FlatL) :-
    !,
    flattenList(L, NewL),
    flattenList(Ls, NewLs),
    append(NewL, NewLs, FlatL).
flattenList(L, [L]).


% hasParents/1: controlla se la classe ha parents (altr. false)
hasParents(ClassName, SuperClasses) :-
    findall(SuperClass, superclass(SuperClass, ClassName), SuperClasses),
    length(SuperClasses, Count),
    Count > 0, !.


% getParentsSlots/2: ritorna gli attributi dei parent
getParentsSlots([SuperClass|OtherSC], ParentsSlots) :-
    generateInstanceSlots(SuperClass, ParentsSlots),
    getParentsSlots(OtherSC, ParentsSlots).
getParentsSlots([], _).


% getClassSlots/2: ritorna in una lista gli attributi della classe
getClassSlots(ClassName, Slots) :-
    findall([SlotName, SlotValue],
            slot_value_in_class(SlotName, SlotValue, ClassName),
            Slots).


% defInstanceSlots/2: funzione momentanea per assegnamento
% attributi istanza (mancano attributi di classe e parents)
defInstanceSlots(_, []) :- !.
defInstanceSlots(InstanceName, [X,Y]) :-
    assertz(slot_value_in_instance(X, Y, InstanceName)).
defInstanceSlots(InstanceName, [X,Y|T]) :-
    assertz(slot_value_in_instance(X, Y, InstanceName)),
    defInstanceSlots(InstanceName, T).


%%% scorro_e_sostituisco/3
%%% Metodo che presa una lista come primo parametro ne
%%% sostituisce i valori, lista nella forma
%%% scorro_e_sostituisco([nome_attibuto_a, valore_a],
%%% [nome_attributo_a,nuovo_valore_a], Out).
%%% Out varra' [nome_attributo_a, nuovo_valore_a]
scorro_e_sostituisco(Xds, [Xn, Yn], Out) :-
    sostituisci(Xds, Xn, Yn, Ex),
    append(Ex, [], Out).

scorro_e_sostituisco(Xds, [Xn, Yn | Xns], Out) :-
    sostituisci(Xds, Xn, Yn, Ex),
    scorro_e_sostituisco(Ex, Xns, Out).



%%% sostituisci/4
%%% usato in scorri e sostituisci
%%% sosituisci([nome_attibuto_a, valore_a], nome_attibuto_a,
%%% nuovo_valore, Out).
%%% Out varra' [nome_attibuto_a, nuovo_valore]
sostituisci([Val1, _ | Xs], Val1, Val2,  [Val1, Val2 | Out]) :-
    sostituisci(Xs, Val1, Val2, Out).

sostituisci([X, Y | Xs], Val1, Val2, [X, Y | Out]) :-
    sostituisci(Xs, Val1, Val2, Out).


sostituisci([Val1, _Y], Val1, Val2, [Val1, Val2]).

sostituisci([X, Y], _Val1, _Val2, [X, Y]).


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


% indexOf/3: ritorna posizione di elemento nella lista
% Se non lo trova, ritorna false!
indexOf([Element|_], Element, 0):- !.
indexOf([_|Tail], Element, Index):-
  indexOf(Tail, Element, Index1), !,
  Index is Index1+1.




% --------------------------------------------------------
%  FUNZIONI AL MOMENTO INUTILIZZATE:


% getElementAt/3: ritorna l'elemento che si trova nella
% posizione specificata nella lista
getElementAt(Lista, Index, X) :-
    getElementAt(Lista, 0, Index, X).
getElementAt([X|_], N, N, X) :- !.
getElementAt([_|Xs], T, N, X) :-
    T1 is T+1,
    getElementAt(Xs, T1, N, X).


% --------------------------------------------------------
