
%%%% Progetto Linguaggi e Programmazione
%%%% oop.pl
%%%% Author: Perego Daniele 829625
%%%% Author: Fornaro Alessandro 830065
%%%% Author: Leggio Giuseppe 892681

%%% regole create per permettere ai metodi di modificare
%%% la knowledge base runtime
:- dynamic class/1.
:- dynamic slot_value_in_class/3.
:- dynamic slot_value_in_instance/3.
:- dynamic superclass/2.
:- dynamic instance_of/2.


%%% count_classes/2: conta il numero di classi aventi il nome passato 
%%% per parametro
count_classes(ClassName, Count) :-
    findall(ClassName, class(ClassName), Z),
    length(Z, Count).


%%% exist_class/1: controlla che la classe esista
exist_class(ClassName) :-
    count_classes(ClassName, Count),
    Count > 0.


%%% count_instances/2: conta il numero di istanze aventi il nome passato
%%% per parametro
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


%%% def_class_slot_T/2: che splitta i valori, rimuove gli = e istanzia 
%%% gli attributi
def_class_slot_T(ClassName, SlotValues) :-
    split_values(SlotValues, X),
    remove_equals(X, _, Out),
    def_class_slots(ClassName, Out).


%%% def_class_slots/2: definisce gli attributi di una classe
%%% Nota: se il numero di attributi e' dispari ritorna false
def_class_slots(_, []) :- !.
def_class_slots(ClassName, [X,Y]) :-
    assertz(slot_value_in_class(X, Y, ClassName)).
def_class_slots(ClassName, [X,Y|T]) :-
    assertz(slot_value_in_class(X, Y, ClassName)),
    def_class_slots(ClassName, T).


%%% def_super_classes/2: definisce le superclassi di una classe
def_super_classes(_, []) :- !.
def_super_classes(ClassName, [H|T]) :-
    exist_class(ClassName),
    def_super_classes(ClassName, T),
    assertz(superclass(H, ClassName)).


%%% exist_parents/1: controlla che i parents di una classe esistano
exist_parents([]) :- !.
exist_parents([H|T]) :-
    count_classes(H, Count),
    Count > 0, !,
    exist_parents(T).


%%% split_values/2: esegue lo split della lista iniziale
%%% Input: [nome = 'eva', anni = 20, saluta = method([], saluta(salve))])
%%% Output: X = [saluta, method([], saluta(salve)), anni, 20, nome, eva]
split_values([], X) :-
    append([], X, X).
split_values([H|T], Z):-
   H =.. Y,
   split_values(T, X),
   append(X, Y, Z).


%%% remove_equals/3: rimuove il carattere '=' dalla lista, prendendo
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
    %% rimuovo simbolo '='
    remove_equals(SplitValues, _, UserValues),
	flatten(ParentsSlots, ParentsSlotsFlatten),
    %% assegno ad attributi classe valori definiti da utente
    scorro_e_sostituisco(ParentsSlotsFlatten, UserValues, Out),
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
    %% mi assicuro che abbia dei parents
    has_parents(ClassName, Parents), !,
    %% estraggo gli attributi dalla classe
    get_class_slots(ClassName, ClassSlots),
    %% estraggo gli attributi dai parents
    get_parents_slots(Parents, ParentsSlots),
    %% append tra lista attributi classe e parents
    append(ClassSlots, ParentsSlots, AppendList),
    flatten(AppendList, FlatList),
    %% rimuovo duplicati
    find_duplicates(FlatList, ParentsValues).


%%% generate_instance_slots/2: utilizzata per classe che non ha parents
generate_instance_slots(ClassName, ParentsValues) :-
    %% mi limito a ritornare gli attributi della classe
    get_class_slots(ClassName, ParentsValues).


%%% get_parents_slots/2: ritorna gli attributi dei parent
get_parents_slots([], []).
get_parents_slots([SuperClass|OtherSC], ParentsSlots) :-
    generate_instance_slots(SuperClass, ParentsSlots1),
    get_parents_slots(OtherSC, ParentsSlots2),
    append(ParentsSlots1, ParentsSlots2, ParentsSlots).


%%% find_duplicates/2: cerca i duplicati per ogni coppia attributo-valore
%%% e li rimuove dalla lista, resituendo una List priva di duplicati
find_duplicates([], List) :-
    append([],[],List).
find_duplicates([X, Y],List) :-
    append([X], [Y], List).
find_duplicates([SlotName, SlotValue|T], List) :-
    %% Toglie un duplicato e lo mette in ListNew
    rimuovi(SlotName, T, TNew),
    find_duplicates(TNew, Out),
    append([SlotName, SlotValue], Out, List).


%%% rimuovi/3: rimuove elemento X dalla lista
rimuovi(_, [], []).
rimuovi(X, [X, _ |Rest], Out) :- rimuovi(X, Rest, Out).
rimuovi(X, [H, Y|Rest], [H, Y|Out]) :-
    X \= H,
    rimuovi(X, Rest, Out).


%%% scorro_e_sostituisco/3: presa una lista come primo parametro 
%%% e una come secondo, percorrendole a 2 a 2 come coppia [nome valore],
%%% sostituisce all'attributo con lo stesso nome nella prima lista il valore
%%% preso dalla seconda lista 
scorro_e_sostituisco(X, [], X).
scorro_e_sostituisco(Xds, [Xn, Yn], Out) :-
    sostituisci(Xds, Xn, Yn, Ex),
    append(Ex, [], Out).
scorro_e_sostituisco(Xds, [Xn, Yn | Xns], Out) :-
    sostituisci(Xds, Xn, Yn, Ex),
    scorro_e_sostituisco(Ex, Xns, Out).


%%% sostituisci/4: usato in scorro_e_sostituisco
sostituisci([Val1, _Y], Val1, Val2, [Val1, Val2]).
sostituisci([X, Y], _Val1, _Val2, [X, Y]).
sostituisci([Val1, _ | Xs], Val1, Val2,  [Val1, Val2 | Out]) :-
    sostituisci(Xs, Val1, Val2, Out).
sostituisci([X, Y | Xs], Val1, Val2, [X, Y | Out]) :-
    sostituisci(Xs, Val1, Val2, Out).


%%% getv/3: restituisce valore associato all'attributo
getv(InstanceName, SlotName, Result) :-
    %% verifico esistenza istanza
    count_instances(InstanceName, Count),
    Count is 1, !,
    %% verifico esistenza attributo (altrimenti ritorna false)
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


%%% has_parents/1: controlla se la classe ha superclassi (altrimenti false)
has_parents(ClassName, SuperClasses) :-
    findall(SuperClass, superclass(SuperClass, ClassName), SuperClassesInverse),
    reverse(SuperClassesInverse, SuperClasses, []),
    length(SuperClasses, Count),
    Count > 0, !.


%%% reverse/3: gira al contrario gli elementi di una lista
reverse([],Z,Z).
reverse([H|T],Z,Acc) :- reverse(T,Z,[H|Acc]).


%%% get_class_slots/2: ritorna in una lista gli attributi della classe
get_class_slots(ClassName, Slots) :-
    findall([SlotName, SlotValue],
            slot_value_in_class(SlotName, SlotValue, ClassName),
            Slots).


%%% def_instance_slots/2: assegna gli attributi all'istanza
def_instance_slots(_, []) :- !.
def_instance_slots(InstanceName, [X,Y|T]) :-
    %% se e' un metodo
    functor(Y, method, _), !,
    %% chiamo istanziazione metodo
    method_in_instance(X, Y, InstanceName),
    %% proseguo con la prossima coppia di valori
    def_instance_slots(InstanceName, T).


%%% def_instance_slots/2: se non e' un metodo:
def_instance_slots(InstanceName, [X,Y|T]) :-
    assertz(slot_value_in_instance(X, Y, InstanceName)),
    def_instance_slots(InstanceName, T).


%%% method_in_instance/3: processa ed inserisce nella knowledge base
%%% i metodi costruiti correttamente e con le this sostituite con
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
    %% unisco la testa al corpo aggiungendo :-
    fondi_testa_corpo(TestaInStringa, OutCorpo, OutMetodoInStringa),
    %% ritrasformo la stringa in termine
    term_string(MetodoF, OutMetodoInStringa),
    %% la inserisco nella BC
    assertz(MetodoF).


%%% fondi_testa_corpo/3: unisce la testa ad un corpo aggiungendo :- nel mezzo
fondi_testa_corpo(Testa, Corpo, Out) :-
    string_concat(" :- ", Corpo,Out1),
    string_concat(Testa, Out1, Out).


%%% costruisci_corpo/2: richiama costruisci_singolo_corpo
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


%%% elimina_quadre/2: predicato che elimina [], usato nella costruzione della
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


%%% estrai_secondo/2: ritorna il secondo elemento
estrai_secondo([_ ,X | _], X).


%%% estrai_resto/2: ritorna una lista privata dei primi due elementi
%%% (usato per ritornare eventuali parametri del metodo)
estrai_resto([_, _ | X], X).


%%% getvx/3: usato per cercare il valore di un attributo all'interno di
%%% oggetti annidati
getvx(InstanceName, [X], Result) :-
     getv(InstanceName, X, Result), !.
getvx(InstanceName, [X | Rest], Result) :-
    getv(InstanceName, X, Out),
    term_string(Out, Stringa),
    elimina_quadre(Stringa, Out2),
    term_string(Termine, Out2),
    getvx(Termine, Rest, Result), !.


%%% replace_this/3: rimpiazza le "this" presenti in un metodo con il
%%% nome della istanza che la sta definendo
replace_this(Stringa, Valore, Result) :-
    %% se fallisce ho finito, oppure non ho nulla da sostituire
    replace_singol_this(Stringa, Valore, Out), !,
    replace_this(Out, Valore, Result).
replace_this(Stringa, _Valore, Result) :-
    string_concat(Stringa, "", Result).


%%% replace_singol_this/3: rimpiazza la prima "this" che incontra e la
%%% sostituisce con l'istanza che la sta definendo
replace_singol_this(String, Var, Out) :-
    sub_string(String, Before, _, After, "this"), !,
    sub_string(String, 0, Before, _, Out1),
    Avanti is Before + 4,
    sub_string(String, Avanti, After, _, Out2),
    string_concat(Out1, Var, Temp),
    string_concat(Temp, Out2, Out).

