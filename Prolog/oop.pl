
%%%% Progetto Linguaggi e Programmazione
%%%% oop.pl
%%%% Author: Perego Daniele 829625
%%%% Author: Fornaro Alessando 830065
%%%% Author: Leggio Giuseppe 892681

%%% regole create per permettere ai metodi di modificare
%%% la knowledge base runtime
:- dynamic class/1.
:- dynamic slot_value_in_class/3.
:- dynamic slot_value_in_instance/3.
:- dynamic superclass/2.
:- dynamic instance_of/2.


%%% conta il numero di classi aventi il nome passato per parametro
count_classes(ClassName, Count) :-
    findall(ClassName, class(ClassName), Z),
    length(Z, Count).


%%% conta il numero di istanze aventi il nome passato per parametro
count_instances(InstanceName, Count) :-
    findall(InstanceName, instance_of(InstanceName,_), Z),
    length(Z, Count).


%%% def_class/3: definisce classe aggiungendola alla knowledge base
def_class(ClassName, Parents, SlotValues) :-
    count_classes(ClassName, Count),
    Count is 0, !,
    exist_parents(Parents),
    assertz(class(ClassName)),
    def_super_classes(ClassName, Parents),
    def_class_slot_T(ClassName, SlotValues), !.


%%% def_class/3 in caso di cut: restituisce errore
def_class(ClassName, _, _) :-
    write("Errore: "),
    write(ClassName),
    write(" e' una classe gia' definita."),
    fail.


%%% def_class_slot_T/2
%%% metodo per creare istanze di slot_value_in_class
%%% che splitta i valori, rimuove gli = e istanzia gli attributi
def_class_slot_T(ClassName, SlotValues) :-
    split_values(SlotValues, X),
    remove_equals(X, _, Out),
    def_class_slots(ClassName, Out).


%%% def_super_classes/2: definisce le superclassi di una classe
def_super_classes(_, []) :- !.
def_super_classes(ClassName, [H|T]) :-
    exist_class(ClassName),
    def_super_classes(ClassName, T),
    assertz(superclass(H, ClassName)).


%%% def_class_slots/2: definisce gli attributi di una classe
%%% Nota: se il numero di attributi e' dispari ritorna false
def_class_slots(_, []) :- !.
def_class_slots(ClassName, [X,Y]) :-
    assertz(slot_value_in_class(X, Y, ClassName)).
def_class_slots(ClassName, [X,Y|T]) :-
    assertz(slot_value_in_class(X, Y, ClassName)),
    def_class_slots(ClassName, T).


%%% exist_parents/1: controlla che i parents esistano
exist_parents([]) :- !.
exist_parents([H|T]) :-
    count_classes(H, Count),
    Count > 0, !,
    exist_parents(T).


%%% exist_class/1: controlla che la classe esista
exist_class(ClassName) :-
    count_classes(ClassName, Count),
    Count > 0.


%%% split_values/2: esegue lo split della lista iniziale
%%% Input:[nome = 'eva', anni = 20, saluta = method([], saluta(salve))])
%%% Output: X = [saluta, method([], saluta(salve)), anni, 20, nome, eva]
split_values([], X) :-
    append([], X, X).
split_values([H|T], Z):-
   H =.. Y,
   split_values(T, X),
   append(X, Y, Z).


%%% remove_equals/3: rimuove il carattere uguale dalla lista, prendendo
%%% in input la lista restituita da split_values.
%%% Input: [=, saluta, method([], saluta(salve)), =, anni, 20, =, nome, eva]
%%% Output: X = [saluta, method([], saluta(salve)), anni, 20, nome, eva]
remove_equals([], X, X).
remove_equals([X, Y, Z|T], L, W):-
    X = '=',
    remove_equals(T, [Y, Z], X1),
    append(L, X1, W).


%%% New/2: Richiama new/3
new(InstanceName, ClassName) :-
    new(InstanceName, ClassName, []), !.


%%% new/3: aggiunge alla knowledge base l'istanza
new(InstanceName, ClassName, SlotValues) :-
    %% controllo esistenza classe
    count_classes(ClassName, CountClasses),
    CountClasses is 1, !,
    %% controllo che non siano presenti istanze omonime
    count_instances(InstanceName, CountInstances),
    CountInstances is 0, !,
    %% creo l'istanza
    assertz(instance_of(InstanceName, ClassName)),
    %% eredito attributi da parents
    generate_instance_slots(ClassName, ParentsSlots),
    %% processo attributi utente
    split_values(SlotValues, SplitValues),
    %% rimuovo simbolo '=' da SplitValues
    remove_equals(SplitValues, _, UserValues),
    %% aggiungo/sostituisco attributi definiti da utente
    scorro_e_sostituisco(ParentsSlots, UserValues, Out),
    %% assegno attributi ad istanza
    def_instance_slots(InstanceName, Out),
    %% scrivo messaggio di conferma istanziazione
    write("Istanza '"),
    write(InstanceName),
    write("' di classe '"),
    write(ClassName),
    write("' creata con successo"), !.


%%% new/3 in caso di cut: restituisce errore
new(InstanceName, ClassName, _) :-
    write("Errore durante creazione istanza '"),
    write(InstanceName),
    write("' di classe '"),
    write(ClassName),
    write("'."),
    fail.


%%% generate_instance_slots/2: genera la lista di slot contenente gli
%%% attributi della classe e dei parent
generate_instance_slots(ClassName, ParentsValues) :-
    %% estraggo gli attributi dalla classe
    get_class_slots(ClassName, ClassSlots),
    %% mi assicuro che abbia dei parents
    has_parents(ClassName, Parents), !,
    %% estraggo gli attributi dai parents
    get_parents_slots(Parents, ParentsSlots),
    %% append tra lista attributi classe e parents
    append(ParentsSlots, ClassSlots, AppendList),
    %% trasformo ParentsValues in FlatSlots, nella forma:
    %%    [nomeAtt1, valAtt1, nomeAtt2, valAtt2]
    flatten(AppendList, FlatList),
    %% rimuovo duplicati
    find_duplicates(FlatList, ParentsValues).


%%% generate_instance_slots/2: utilizzata per classe che non ha parents
generate_instance_slots(ClassName, ParentsValues) :-
    %% mi limito a ritornare gli attributi della classe
    get_class_slots(ClassName, ClassSlots),
    %% trasformo ParentsValues in FlatSlots, nella forma:
    %%    [nomeAtt1, valAtt1, nomeAtt2, valAtt2]
    flatten(ClassSlots, ParentsValues).


%%% find_duplicates/3: cerca i duplicati per ogni coppia attributo-valore
%%% e li rimuove dalla lista, resituendo una List priva di duplicati
find_duplicates([], List) :-
    append([],[],List).

find_duplicates([X, Y],List) :-
    append([X], [Y], List).

find_duplicates([SlotName, SlotValue|T], List) :-
    %% Toglie un duplicato e lo mette in ListNew
    remv(SlotName, T, TNew),
    find_duplicates(TNew, Out),
    append([SlotName, SlotValue], Out, List).


%%% remv/3: rimuove elemento X dalla lista
remv(_, [], []).

remv(X, [X, _ |T], T1) :- remv(X, T, T1).

remv(X, [H, Y|T], [H, Y|T1]) :-
    X \= H,
    remv(X, T, T1).


%%% scorro_e_sostituisco/3: Metodo che presa una lista come primo parametro ne
%%% sostituisce i valori
%%% INPUT TYPE: scorro_e_sostituisco([nome_attibuto_a, valore_a],
%%% [nome_attributo_a,nuovo_valore_a], Out).
%%% Out: [nome_attributo_a, nuovo_valore_a]
scorro_e_sostituisco(X, [], X).

scorro_e_sostituisco(Xds, [Xn, Yn], Out) :-
    sostituisci(Xds, Xn, Yn, Ex),
    append(Ex, [], Out).

scorro_e_sostituisco(Xds, [Xn, Yn | Xns], Out) :-
    sostituisci(Xds, Xn, Yn, Ex),
    scorro_e_sostituisco(Ex, Xns, Out).


%%% sostituisci/4: usato in scorro_e_sostituisco
%%% INPUT: sosituisci([nome_attibuto_a, valore_a], nome_attibuto_a,
%%% nuovo_valore, Out).
%%% Out :[nome_attibuto_a, nuovo_valore]
sostituisci([Val1, _ | Xs], Val1, Val2,  [Val1, Val2 | Out]) :-
    sostituisci(Xs, Val1, Val2, Out).

sostituisci([X, Y | Xs], Val1, Val2, [X, Y | Out]) :-
    sostituisci(Xs, Val1, Val2, Out).

sostituisci([Val1, _Y], Val1, Val2, [Val1, Val2]).

sostituisci([X, Y], _Val1, _Val2, [X, Y]).


%%% getv/3: restituisce valore associato all'attributo
getv(InstanceName, SlotName, Result) :-
    %% verifico esistenza istanza
    count_instances(InstanceName, Count),
    Count is 1, !,
    %% verifico esistenza attributo (altr. ritorna false)
    %% e, nel caso, lo ritorna
    findall(SlotValues,
            slot_value_in_instance(SlotName,SlotValues,InstanceName),
            Result),
    length(Result, CountSlot),
    %% verifico che sia stato trovato il valore
    CountSlot > 0.


%%% getv/3: in caso di cut
getv(InstanceName, _, _) :-
    write("Errore: istanza "),
    write(InstanceName),
    write(" inesistente."),
    fail.


%%% has_parents/1: controlla se la classe ha parents (altr. false)
has_parents(ClassName, SuperClasses) :-
    findall(SuperClass, superclass(SuperClass, ClassName), SuperClasses),
    length(SuperClasses, Count),
    Count > 0, !.


%%% get_parents_slots/2: ritorna gli attributi dei parent
get_parents_slots([SuperClass|OtherSC], ParentsSlots) :-
    generate_instance_slots(SuperClass, ParentsSlots),
    get_parents_slots(OtherSC, ParentsSlots).
get_parents_slots([], _).


%%% get_class_slots/2: ritorna in una lista gli attributi della classe
get_class_slots(ClassName, Slots) :-
    findall([SlotName, SlotValue],
            slot_value_in_class(SlotName, SlotValue, ClassName),
            Slots).


%%% def_instance_slots/2: funzione per l'assegnamento
%%% degli attributi della istanza
def_instance_slots(_, []) :- !.

def_instance_slots(InstanceName, [X,Y|T]) :-
    %% se e' un metodo
    functor(Y, method, _), !,
    %% chiamo istanziazione metodo
    method_in_instance(X, Y, InstanceName),
    %% proseguo con la prossima coppia di valori
    def_instance_slots(InstanceName, T).

%%% Se non e' un metodo:
def_instance_slots(InstanceName, [X,Y|T]) :-
    assertz(slot_value_in_instance(X, Y, InstanceName)),
    def_instance_slots(InstanceName, T).


%%% method_in_instance/3: metodo utilizzaato per processare ed inserire nella
%%% BC i metodi costruiti correttamente e con le this sostituite con
%%% il nome della istanza che la richiama
method_in_instance(NomeMetodo, CorpoMetodo, InstanceName) :-
    %% trasformo in stringa per richiamare la funzione che processa la this
    term_string(CorpoMetodo, StrConThis),
    term_string(InstanceName, ValDaSostituire),
    replace_this(StrConThis, ValDaSostituire, Result),
    term_string(Y, Result),
    Y =.. X,
    %% lavoro sulle stringhe per aggiungere un numero indefinito di variabili
    estrai_secondo(X, Parametri),
    %% aggiunge tutte le eventuali variabili
    aggiungi_variabili(InstanceName, Parametri, OutVariabili),
    Testa =.. [NomeMetodo, OutVariabili],
    term_string(Testa, Stringa),
    elimina_quadre(Stringa, TestaInStringa),
    %% ora devo creare il corpo
    estrai_resto(X, CorpoInStringa),% corpo ritornato come una stringa
    costruisci_corpo(CorpoInStringa, OutCorpo),
    %%unisco la testa al corpo aggiungemdo :-
    fondi_testa_corpo(TestaInStringa, OutCorpo, OutMetodoInStringa),
    %% ritrasformo la stringa in termine
    term_string(MetodoF, OutMetodoInStringa),
    %% la inserisco nella BC
    assertz(MetodoF).


%%% fondi_testa_corpo/3: unisce la testa ad un corpo aggiungendo :-nel mezzo
fondi_testa_corpo(Testa, Corpo, Out) :-
    string_concat(" :- ", Corpo,Out1),
    string_concat(Testa, Out1, Out).


%%% costruisci_corpo/2: gli viene passata una lista e richiama
%%% costruisci_singolo_corpo
costruisci_corpo([X], Out) :-
    costruisci_singolo_corpo(X, Out).


%%% costruisci_singolo_corpo/2 aggiunge il punto in coda
costruisci_singolo_corpo(Metodo, Out) :-
    term_string(Metodo, Out1),
    string_concat(Out1, ".", Out).


%%% aggiungi_variabili/3 aggiunge eventuali variabili
%%% usata per costruire la testa della regola
aggiungi_variabili(InstanceName, X, OutVariabili) :-
   append([InstanceName], X, OutVariabili).


%%% elimina_quadre/2: metodo che elimina [], usato nella costruzione della
%%% testa, per poter ceare correttamente il termine
elimina_quadre(Stringa, Out) :-
    elimina_quadra_aperta(Stringa, Tp),
    elimina_quadra_chiusa(Tp, Out).


%%% elimina_quadra_aperta/3: usato da elimina_quadra
elimina_quadra_aperta(String, Out) :-
    sub_string(String, Before, _, After, "["), !,
    sub_string(String, 0, Before, _, Out1),
    Avanti is Before + 1,
    sub_string(String, Avanti, After, _, Out2),
    string_concat(Out1, Out2, Out).


%%% elimina_quadra_chiusa/3: usato da elimina_quadra
elimina_quadra_chiusa(String, Out) :-
    sub_string(String, Before, _, After, "]"), !,
    sub_string(String, 0, Before, _, Out1),
    Avanti is Before + 1,
    sub_string(String, Avanti, After, _, Out2),
    string_concat(Out1, Out2, Out).

%%% estrai_secondo/2: ritorna il secondo elemento, usato per ritornare
%%% eventuali parametri del metodo
estrai_secondo([_ ,X | _], X).


%%% estrai_resto/2: tutta una lista privata dei primi due elementi,
%%% usato per ritornare eventuali parametri del metodo
estrai_resto([_, _ | X], X).


%%% Struttua istanza/3:
%%% (instance_of(InstanceName, ClassName))
%%% slot_value_in_instance(X, Y, InstanceName)). -> X,Y coppia attr-valore
%%% Non ripeto i controlli di esistenza dell'istanza e degli attributi
%%% perche' vengono effettuati nella getv.
get_list_values(_, [], X):-
    append([], X, X), !.

get_list_values(InstanceName, [H|T], Result):-
    getv(InstanceName, H, R),
    get_list_values(InstanceName, T, X),
    append(X, R, Result), !.


%%% getvx/3
getvx(InstanceName, [H|T], Result):-
    get_list_values(InstanceName, [H|T], R),
    reverse(R, Result), !.


%%% replace_this/3: usato per rimpiazzare le this in un metodo con il
%%% nome della istanza che la sta definendo, chiama ricorsivamente
%%% replace_singol_this
replace_this(Stringa, Valore, Result) :-
    %%se fallisce vuol dire che o ho finito o non ho nulla da sostituire
    replace_singol_this(Stringa, Valore, Out), !,
    replace_this(Out, Valore, Result).
    %string_concat(Out, Out2, Result).

replace_this(Stringa, _Valore, Result) :-
    string_concat(Stringa, "", Result).


%%% replace_singol_this/3: usato per rimpiazzare le this in un metodo con il
%%% nome della istanza che la sta definendo, sostituisce solo il
%%% primo che incontra
replace_singol_this(String, Var, Out) :-
    sub_string(String, Before, _, After, "this"), !,
    sub_string(String, 0, Before, _, Out1),
    Avanti is Before + 4,
    sub_string(String, Avanti, After, _, Out2),
    string_concat(Out1, Var, Temp),
    string_concat(Temp, Out2, Out).

