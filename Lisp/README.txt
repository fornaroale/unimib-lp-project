(defun def-class ( nome parents &rest campi))
;Verifica se la classe è presente nella classes-list -> richiama get-class-spec
;se è presente, non l'aggiunge e restituisce il messaggio di errore 
;se non è presente, aggiunge la classe nella classes-list -> richiama add-class-spec
;se la lista dei parents non è vuota, bisogna leggere gli attributi delle classi e far si che 
;la nuova classe erediti gli stessi attributi, ovvero leggere gli attributi dalle classi che 
;eredita e copiarli nella nuova classe


(defun new (class-name &rest campi) )
;Verifica che la classe esista, verificando che l'hash del classe sia presente nell'hashtable
;Copia gli attributi dalla hashtable nella lista dell'istanza
;Controlla che i campi (attributi) da instanzare esistano e prende i valori di input

(defun getv (instance campo)) ;instance -> lista campo -> simbolo
;Verifico che l'istanza esista, se è nil non esiste: (boundp 's)
	;Se esiste, verifico che esista il campo scorrendo la lista dell'istanza
		;Se esiste il campo prendo il campo e ritorno il valore
		;Se non esiste ritorno errore
	;Se non esiste non ritorno errore

(defun getvx (instance campo))
;scorro instance e ritorno per ogni elemento di instance e applico getv
	
(defun rewrite-method-code



