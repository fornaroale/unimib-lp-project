
# Componenti:

829625 - Perego Daniele 
830065 - Fornaro Alessandro 
892681 - Leggio Giuseppe 

---------------------------------

# Descrizione funzioni principali:

- new:
	Questa funzione si occupa di istanziare un "oggetto" della classe specificata per parametro. In primis, verifica che
	la classe specificata esista (nella hashtable): in tal caso cerca, tramite metodi ausiliari, attributi e metodi della
	classe e delle superclassi della classe specificata, e costruisce la stringa come da specifiche richieste (ovvero
	nella forma: (oolinst ...)) sostituendo eventuali valori definiti dall'utente da assegnare agli attributi (qualora
	essi siano definiti nella classe).

- searchParents/2:
	È una delle funzioni ausiliarie della new. Si occupa di recuperare gli attributi e i metodi della classe specificata nel
	parametro formale class-name, e di far lo stesso per le sue superclassi.
	
- checkSlot/2:
	È una delle funzioni ausiliarie della new. Si occupa di sostituire, anche grazie alla funzione setInstVal, i valori
	default degli attributi con eventuali nuovi valori decisi dall'utente. Grazie alla setInstVal, si crea un "doppio
	scorrimento", realizzato tramite ricorsione: si scorre la lista dei valori decisi dall'utente e, per ognuno di questi,
	se presente nella lista degli attributi della classe, si esegue la sostituzione nell'istanza.

- searchForMethods/2:
	È una delle funzioni ausiliarie della new. Viene chiamata appena prima di restituire l'istanza all'utente, nella new.
	Permette di scorrere la lista di attributi e metodi contenuti nell'istanza e, per ogni metodo, di chiamare la funzione
	process-method.

- def-class:
	È una funzione che permette di inserire la definizione di una classe nella tebella hash, chiamta association list.
	Inizia controllando che che tutti gli attributi passati siano validi, superati i controlli esegue una remash sulla 
	tabella hash per cancellare eventuali istanze precedenti della classe, in modo da permetterne la ridefinizione, 
	in seguito procede a salvare la classe sull'association list richiamando il metodo gestione-attributi  su slot-value
	 e se ce ne sono chiama verificaR che controlla i vari attributi e/o metodi.

- esistePar/1:
	È una funzione usata dalla def-class per controllare che esistano i parents che si stanno definendo mentre si crea una nuova classe.
	Passata una lista che dovrebbe contenere eventuali parents la processa ricorsivamente, dove ogni parents viene cercato
	tramite get-class-spec e se ritornato ritorna T, NIL in caso contrario.

- process-method/2:
	È una funzione che crea la funzione trampolino che costruisco mediante lambda, questa funzione avro' come parametri la this e 
	in piu eventuali altri valori, usati dalla funzione che viene richiamata da questa funzione trampolino appena creata, 
	uso la funzione apply per applicare la funzione trovata mediante una getv con this (che verra' sostituito con l'istanza stessa 
 	quando richiamato) e il nome del metodo.
	E alla fine come parametro di eval richiamo rewrite-method-code.

- rewrite-method-code/2:
	È una funzione che riscrive un metodo aggiungendo la this come primo argomento delle variabili se non gia presente e la ricostruisce
	aggiungendo lambda in testa, in modo  da essere trasformata in una funzione anonima quando verra' valutata da eval nella process_method.

- verificaR/2:
	È una funzione ricorsiva usata per cercare un metodo, scorre 2 a 2 una lista e verifica se ogni coppia è o meno un 
	metodo richiamando verifica.
	Chiamata con 2 elementi, la lista e il numero di elementi nela lista per poterla scorrere ricorsivamente 2 a 2.

- verifica/1: 
	È una funzione a cui passo una lista di soli 2 elementi, se analizzando il secondo trova il simbolo di metodo => allora
	richiama la process-method che mediante una chiamata a rewrite-method-code la ricostruisce e ritorna come funzione anonima.
	Questa viene poi ritornata in questa forma. Se non trova il simbolo di metodo sarà un semplice attributo e ritornato inalterato.
	

- getv/2:
	Prende in input l'istanza passata, ovvero una lista nella forma (oolinst classe [slot-values]) e il nome dell'attributo.
	Verifica che sia una lista formata in quel modo, 
	verifica che slot-name sia un simbolo, richiama il metodo get-slot-value, il quale prende in input l'istanza e l'attributo
	e ritorna il valore associato se l'attribut oesiste, oppure stampa l'errore.

- get-slot-value/2: 
	Funzione ausiliaria per getv.
	Estratta la sottolista contenente gli slot-values, sfruttando first e last, tramite la funzione position preleva la posizione 
	dell'attributo richiesto, la ritorna e poi sfruttando la funzione nth
	viene ritornato il valore corrispondente all'attributo cercato, richiamata sul valore ritornato da position +1.

- getvx/2:
	Usata per cercare il valore di un attributo all'interno di oggetti annidati.
	Prende come input l'istanza e un numero variabile di attributi dell'istanza.
	Dato che &Rest ritorna una lista di elementi, la funzione verifica i seguenti casi:
		Se l'attributo passato è nil ritorna nil
		Se l'attributo passato è un atomo richiama su di esso la getv che ritorna il valore associato all'attributo
		Nei rimanenti casi, processo la lista ritornata da &rest, su ogni elemento applico la getv e richiamo la getvx con ricorsione doppia sul risultato della getv e sul resto della lista 
		degli attributi.
