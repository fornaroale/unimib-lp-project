# Documentazione privata

## LISP

### Predicati
* Consentiti: (quasi) tutto quello che è nello standard ANSI, LET, LET*, defparameter SOLO top-level (non nelle funzioni)
* Vietati: SET, la SETQ e la SETF (a meno che non strettamente necessarie) (nota: l'uso di setf è consentito per modificare gli elementi di una lista); LOOP, DO, DO*, DOTIMES, DOLIST
* NOTA: Uso pessimo operatori di assegnamento LISP: (Perchè? Perchè setf modifica l'ambiente globale! Usa let!)
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

## PROLOG

### Predicati
* Consentiti: tutto quello che è nella libreria di SWIPL 7.6.4
* Vietati: IF (-> e *->), OR (;), possibilmente NOT

### Link utili
SWIPL 7.6.4 Reference  -> http://www.swi-prolog.org/download/stable/doc/SWI-Prolog-7.6.4.pdf <br />
