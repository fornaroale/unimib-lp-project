
# Componenti:

829625 - Perego Daniele 
830065 - Fornaro Alessandro 
892681 - Leggio Giuseppe 

---------------------------------

# Descrizione predicati principali:

- def_class/3:
	Si occupa della definizione della classe, previa verifica che non esista una classe omonima nella base di conoscienza.
	Inserisce inoltre nella base di conoscienza eventuali attributi, metodi e superclassi della classe seguendo un modello
	simile a quello relazionale dei database:
		~ per definire la classe: class(nome_classe).
		~ per attributi/metodi: slot_value_in_class(nome_attributo, valore_attributo, nome_classe).
		~ per superclassi: superclass(nome_super_classe, nome_classe).

- new/3:
	Questo predicato si occupa di istanziare un "oggetto" della classe specificata per parametro con il nome richiesto.
	Come primo passo, verifica che la classe specificata esista e che non siano già presenti istanze con il nome richiesto.
	Aggiunge quindi l'istanza alla base di conoscienza, secondo un modello molto simile a quello relazionale dei database:
		instance_of(nome_istanza, nome_classe)
	Successivamente si ereditano attributi dalle superclassi della classe specificata e, unendoli a quelli della classe,
	si procede alla sostituzione di eventuali valori (di attributi) definiti dall'utente (predicato scorro_e_sostituisco).
		
- def_instance_slots/2:	
	Predicato ausiliario di new. Si occupa dell'aggiunta (alla base di conoscienza) di attributi e metodi:
		~ per gli attributi: slot_value_in_instance(nome_attributo, valore, nome_istanza)
		~ per i metodi: viene creata una regola nella seguente forma:
			nome_metodo(nome_istanza) :- corpo_metodo+.
				
- generate_instance_slots/2:
	Predicato ausiliario di new. È il predicato che si occupa di ereditare attributi e metodi dalle superclassi della
	classe specificata dall'utente.
	
- scorro_e_sostituisco/3:
	Predicato ausiliario di new. È il predicato che si occupa di sostituire i valori definiti dall'utente a quelli di
	default delle classi.
	
	
- getv/2:
	Data un'istanza, restituisce il valore associato all'attributo passato come parametro.
	Questo predicato verifica l'esistenza dell'istanza richiamando il predicato count_instance che ritorna un intero.
	Se il valore ritornato è > 0, allora l'istanza esiste e viene richiamato il predicato findall per trovare 
	il valore associato a quell'attributo. Per controllare l'esistenza dell'attributo alla fine viene richiamato
	il predicato length, se ritorna 1 allora l'attributo richiesto esiste altrimenti ritorna false.
	
	Nel caso di fallimento al primo controllo viene richiamato l'altro caso per la getv che riceve come 
	parametri solo l'istanza e 2 variabili anonime e stampa a video i messaggi di errore poichè l'istanza è inesistente.
	

- count_instance: predicato ausiliario della getv che verifica tramite il predicato findall/3 richiamato sul nome dell'istanza
	sul predicato instance_of(InstanceName, _), e il terzo parametro e' il valore intero che deve ritornare.

- getvx/3: 
 	Usata per cercare il valore di un attributo all'interno di oggetti annidati.
 	Con un solo elemento richiama la getv sull'unico elemento per ottenere il valore associato a quell'attributo, viene ritornato il suo valore associato.
	Con più elementi chiama la getv sul primo elemento.
 	Viene richiamato il predicato term_string sul valore ritornato dalla getv, poichè ritorna un risultato in una lista. 
 	Usando term_string viene convertita prima in stringa,
	vengono tolte le quadre con il predicato elimina_quadre, viene richiamato nuovamente 
 	term_string per convertirla in un termine e su di esso riapplica
 	ricorsivamente la getvx finchè non si arriva al caso base, ossia quando si ha un solo elemento.

