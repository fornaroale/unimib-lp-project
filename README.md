# Documentazione privata

## LISP

### Documentazione codice
* __(defun def-class ( nome parents &rest campi))__
Verifica se la classe è presente nella classes-list -> richiama get-class-spec. Se è presente, non l'aggiunge e restituisce il messaggio di errore, se non è presente aggiunge la classe nella classes-list -> richiama add-class-spec. Se la lista dei parents non è vuota, bisogna leggere gli attributi delle classi e far si che la nuova classe erediti gli stessi attributi, ovvero leggere gli attributi dalle classi che eredita e copiarli nella nuova classe.

* __(defun new (class-name &rest campi) )__ Verifica che la classe esista, verificando che l'hash del classe sia presente nell'hashtable; copia gli attributi dalla hashtable nella lista dell'istanza; controlla che i campi (attributi) da instanziare esistano e prende i valori di input.

* __(defun getv (instance campo))__ istance -> lista campo -> simbolo. Verifico che l'istanza esista, se è nil non esiste: (codice: (boundp 's)). Se esiste, verifico che esista il campo scorrendo la lista dell'istanza: se esiste il campo prendo il campo e ritorno il valore, altrimenti ritorno errore; se non esiste ritorno errore.

* __(defun getvx (instance campo))__ Scorro instance e ritorno per ogni elemento di instance e applico getv.
	
* __(defun rewrite-method-code__ .......................

### Predicati Prolog
* Consentiti: tutto quello che è nella libreria di SWIPL 7.6.4
* Vietati: IF (-> e *->), OR (;), possibilmente NOT

### Predicati Lisp
* Consentiti: (quasi) tutto quello che è nello standard ANSI, LET, LET*, defparameter SOLO top-level (non nelle funzioni)
* Vietati: SET, la SETQ e la SETF (a meno che non strettamente necessarie) (nota: l'uso di setf è consentito per modificare gli elementi di una lista)
* NOTA: Uso pessimo operatori di assegnamento LISP:
```(progn
   (setf a 1)
   (setf b 2)
   (setf c (* a b))
   
   ;; Chiamo FOO
   (foo a b c))
```
   
### Link utili
make-hash-table -> http://clhs.lisp.se/Body/f_mk_has.htm <br />
symbol-name -> http://clhs.lisp.se/Body/f_symb_2.htm <br />
