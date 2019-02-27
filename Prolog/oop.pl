
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
    def_class_slot_T(ClassName, SlotValues).


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
%%% Input:[nome = 'lele', anni = 20, saluta = method([],
%%% saluta(salve))]) Output: X = [saluta, method([], saluta(salve)),
%%% anni, 20, nome, lele]
split_values([], X) :-
    append([], X, X).
split_values([H|T], Z):-
   H =.. Y,
   split_values(T, X),
   append(X, Y, Z).


%%% remove_equals/3: rimuove il carattere uguale dalla lista, prendendo
%%% in input la lista restituita da split_values.
%%% Input: [=, saluta, method([], saluta(salve)), =, anni, 20,
%%%         =, nome, lele]
%%% Output: X = [saluta, method([], saluta(salve)), anni, 20,
%%%              nome, lele]
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


%%% list_methods/2: estrae tutti i metodi dalla lista splittata
%%% Input: [saluta, method([], saluta(salve)), anni, 20, nome, lele]
%%% Result: X = [method([], saluta(salve))]
extract_methods(W, []):-
    %% verifica se non e' un predicato
    (functor(W, method, _)), !.
extract_methods(W, [W]):-
    %%verifica se e' un predicato "method(..)"
    (functor(W, method, _)).


%%% verifica se e' un metodo, se si mi ritorna il metodo come lista,
%%% altrimenti mi ritorna una lista vuota, infine fa un append per
%%% riunire tutte le liste.
list_methods([], []).
list_methods([H|T], X):-
    extract_methods(H, Z),
    list_methods(T, Y),
    append(Y, Z, X).


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
    write("' creata con successo").


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
    flatten_list(AppendList, FlatList),
    %% rimuovo duplicati
    find_duplicates(FlatList, ParentsValues).


%%% generate_instance_slots/2 per classe che non ha parents:
generate_instance_slots(ClassName, ParentsValues) :-
    %% mi limito a ritornare gli attributi della classe
    get_class_slots(ClassName, ClassSlots),
    %% trasformo ParentsValues in FlatSlots, nella forma:
    %%    [nomeAtt1, valAtt1, nomeAtt2, valAtt2]
    flatten_list(ClassSlots, ParentsValues).

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


%%% delete/3
delFromList(0, [_|T], T).
delFromList(X, [H|T], [H|T2]) :-
    NuovaX is X-1,
    delFromList(NuovaX, T, T2).


%%% flatten/2: porta i componenti di una lista al 'primo livello'
flatten_list([], []) :- !.
flatten_list([L|Ls], FlatL) :-
    !,
    flatten_list(L, NewL),
    flatten_list(Ls, NewLs),
    append(NewL, NewLs, FlatL).
flatten_list(L, [L]).


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


%%% def_instance_slots/2: funzione momentanea per assegnamento
%%% attributi istanza (mancano attributi di classe e parents)
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

method_in_instance(X, Y, InstanceName) :-
    write("Nome "),
    write(X),
    write(" - Codice: "),
    write(Y),
    write(" - il codice appartiene all'istanza: "),
    write(InstanceName).


%%% scorro_e_sostituisco/3
%%% Metodo che presa una lista come primo parametro ne
%%% sostituisce i valori, lista nella forma
%%% scorro_e_sostituisco([nome_attibuto_a, valore_a],
%%% [nome_attributo_a,nuovo_valore_a], Out).
%%% Out varra' [nome_attributo_a, nuovo_valore_a]
scorro_e_sostituisco(X, [], X).
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
    CountSlot > 0.


%%% getv/3: in caso di cut
getv(InstanceName, _, _) :-
    write("Errore: istanza "),
    write(InstanceName),
    write(" inesistente."),
    fail.


%%% Struttua istanza/3:
%%% (instance_of(InstanceName, ClassName))
%%%slot_value_in_instance(X, Y, InstanceName)). -> X,Y coppia attr-valore
%%% Non ripeto i controlli di esistenza dell'istanza e degli attributi
%%% perche' vengono effettuati nella getv.
get_list_values(_, [], X):-
    append([], X, X), !.
get_list_values(InstanceName, [H|T], Result):-
    getv(InstanceName, H, R),
    get_list_values(InstanceName, T, X),
    append(X, R, Result), !.
getvx(InstanceName, [H|T], Result):-
    get_list_values(InstanceName, [H|T], R),
    reverse(R, Result), !.

%%%FUNZIONANTE DA COMMENTARE E PULIRE

replace_this(Stringa, Valore, Result) :-
    %%se fallisce vuol dire che o ho finito o non ho nulla da sostituire
     replace_singol_this(Stringa, Valore, Out), !,
     replace_this(Out, Valore, Result).
     %string_concat(Out, Out2, Result).

replace_this(Stringa, _Valore, Result) :-
    string_concat(Stringa, "", Result).

replace_singol_this(String, Var, Out) :-
    sub_string(String, Before, _, After, "this"), !,
    sub_string(String, 0, Before, _, Out1),
    Avanti is Before + 4,
    sub_string(String, Avanti, After, _, Out2),
    string_concat(Out1, Var, Temp),
    string_concat(Temp, Out2, Out),
    write(Out).

%%% Input: method_in_instance("talk", "getv(this, nome, N)", beppe, X)
%%% Output: X =  (talk(beppe):-call(getv(beppe, nome, _8632))).
%%% Aggiorna inoltre la KB, quindi se assert non e' commentato
%%% ricordarsi di usare:
%%% listing(talk(X)).
%%% retractall(talk(X))
method_in_instance(_NomeIstanza, _NomeMetodo, _CorpoMetodo) :-
   ! .

method_in_instance1(NomeMetodo, Metodo, NomeIstanza, Rules) :-
    %%estrae this e inserisce il nome dell'istance -> ritorna una stringa
    replace_this(Metodo, NomeIstanza, CorpoStr),
    %%creo sub-stringa: "nomeMetodo(NomeIstanza)"
    add_argument(NomeMetodo, NomeIstanza, TestaArg),
    %%creo sub-string: "call(CorpoFunzione)"
    add_call(CorpoStr, CorpoCall),
    %%unifico le sub-string per creare la regola (ritorna una stringa)
    string_comp(TestaArg, " :- ", CorpoCall, Z),
    %%converto in termine usando, term_string, ma genera il problema dell    %%a variabile anonima
    term_string(Rules, Z),
    %%aggiorno la KB.
    assertz(Rules).

method2_in_instance2(NomeMetodo, Metodo, NomeIstanza, Rules) :- %test errato%
    replace_this(Metodo, NomeIstanza, CorpoStr),
    add_call(CorpoStr, CorpoCall),
    term_string(Nome, NomeMetodo),
    term_string(Corpo2, CorpoCall),
    Testa =.. [Nome, NomeIstanza],
    string_comp(Testa, ":-", Corpo2, Rules).
%% e' sbagliato
    %assertz(Rules).

/*add_write(Regola, Result) :-
    string_comp("write(", Regola, ")", Result).*/


add_call(Corpo, Result) :-
    string_comp("call(", Corpo, ")", Result).

add_argument(NomeMetodo, NomeIstanza, Result) :-
    string_comp(NomeMetodo, "(", NomeIstanza, X),
    string_concat(X, ") ", Result).

string_comp(A, B, C, X):-
   string_concat(A, B, Z),
   string_concat(Z, C, X).

 %assertz(NomeMetodo(NomeIstanza) :- call(Z)) .
/*set_rules(NomeMetodo, CorpoMetodo, X) :-
    X =.. [NomeMetodo, CorpoMetodo].

*/







% --------------------------------------------------------
%  FUNZIONI AL MOMENTO INUTILIZZATE:

%%% index_of/3: ritorna posizione di elemento nella lista
%%% Se non lo trova, ritorna false!
index_of([Element|_], Element, 0):- !.
index_of([_|Tail], Element, Index):-
  index_of(Tail, Element, Index1), !,
  Index is Index1+1.


%%% get_element_at/3: ritorna l'elemento che si trova nella
%%% posizione specificata nella lista
get_element_at(Lista, Index, X) :-
    get_element_at(Lista, 0, Index, X).
get_element_at([X|_], N, N, X) :- !.
get_element_at([_|Xs], T, N, X) :-
    T1 is T+1,
    get_element_at(Xs, T1, N, X).


% --------------------------------------------------------


%%% ------------------------------------------------------
% METODO CHE, DATA IN INPUT UNA LISTA DI METODI, CREA IL
% CORPO DELLA CALL
% Input:  ["write(...)", "getv(...)", etc.]
% Output: "call(write(...)), call(getv(...)), etc."
% Parametri attesi: ListaMetodi, ListaRisultato

% NOTA: bisogna togliere l'ultima virgola dell'ultima call (con
% una substring) e aggiungere un punto (con una concat).
createCalls([H|T], StringRisultato) :-
    string_comp("call(", H, "),", Ris1),
    createCalls(T, StringTemp),
    string_concat(Ris1, StringTemp, StringRisultato).
createCalls([], "").


%%% Tu hai lista iniziale generata da extract_meth
%%% Input di extract: [saluta, method([], saluta(salve)), anni, 20,
%%% nome, lele]
%%% Output di extract: X = [method([], saluta(salve), saluto(ciao))]
%%% voglio ottenere solo saluta(salve): mi basta prendere il primo el.
%%% della lista (nota che sono separati da virgola; poi vado sulle due
%%% posizioni successive
%%% Output di remove_method_tag: X = [saluta(salve), saluto(ciao)]

remove_method_tag([H|T], Risultato, IsFunction) :-
    %% se sono su method, lo salto
    IsFunction > 0, !,
    term_string(H, HTerm),
    remove_method_tag(T, List, IsFunction),
    append(List, HTerm, Risultato).
remove_method_tag(Lista, Risultato, _) :-
    remove_method_tag(Lista, Risultato, 1).
remove_method_tag([],[],_).


%%% In:[method([], (write('My name is'), getv(this, nome, N),write(N)))]
%%% Crea una lista del tipo [method, [], (write('My name is'),
%%% getv(this, nome, N), write(N))] In modo tale da separare gli
%%% argomenti del metodo da method
format_list_method([], X) :-
    append([], X, X).
format_list_method([H|T], ResultList) :-
    H =.. L,
    format_list_method(T, List),
    append(List, L, ResultList).

%%% Una volta usata la format_list_method, estraiamo gli argomenti del
%%% method, e' sfruttabile sia per ottenere la lista senza gli argomenti
%%% che per ottenere gli argomenti
%%% In:[method, [comesichiama], (write('My name is'), getv(this, nome,
%%% N), write(N))]
get_arguments_method([_, Y|T], Y, T):-
    is_list(Y).

%%% Rimuovo method perchè non è piu' necessario
%%% [method,  (write('My name is'), getv(this, nome, N), write(N))]
remove_method_tag([X|T], T):-
    X = method.


%%% Ora con list_to_string posso ottenere la rimozione dellle parentesi
%%% che contengono il corpo del metodo
%%% Input: (write('My name is'), getv(this, nome, N), write(N))
%%% Out:   "write('My name is'), getv(this, nome, N), write(N)"
%%% Le rimuove in automatico le parentesi

list_to_string([], X) :-
    append([], X, X).
list_to_string([H|T], ResultList) :-
    term_string(H, Str),
    list_to_string(T, L),
    append(L, Str, ResultList).


/*create_method_list_string([], X) :-
    append([], X, X).
create_method_list_string([H|T], Result) :-
    split_string(H, ",", "", L),
    create_method_list_string(T, NewL),
    append(NewL, L, Result).*/
	
	
%%%Input: generate_list_with_new_format([nome = 'lele', anni = 20, talk = method([],(write("My name is "), getv(this, name, N), write(N), nl, write("My age is "), getv(this, age, A), write(A), nl))], X).
generate_list_with_new_format(ListSlotValueInput, ResultList):-
    split_values(ListSlotValueInput, R1),
    remove_equals(R1, _, R2 ),
    list_methods(R2, R3),
    format_list_method(R3, R4),
    get_arguments_method(R4, _, R5),
    list_to_string(R5, ResultList).


