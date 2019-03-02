# Progetto E2P 2019
Corso di Linguaggi di Programmazione, AA 2018-2019 - UniMiB

## Obiettivo
Costruzione di un'estensione "object oriented" di Common Lisp e di Prolog.

## Autori
- Alessandro Fornaro > @fornaroale <br />
- Daniele Perego > @Perego98 <br />
- Giuseppe Leggio > @LeggioBeppe98

## Progetto OOΛ - LISP

### Funzioni
* Consentite: (quasi) tutte quelle che sono nello standard ANSI; LET; LET*; defparameter SOLO top-level (non nelle funzioni)
* Vietate: SET, SETQ e SETF (a meno che non strettamente necessarie) (nota: l'uso di setf è consentito per modificare gli elementi di una lista); LOOP, DO, DO*, DOTIMES, DOLIST

### Caso d'uso
```
(def-class 'perifericaOutput nil 'marca "sconosciutaMarcaOUt" 'valore 0 'talk '(=> () (write "sono una periferica di output")))
(def-class 'perifericaInput nil 'marca "sconosciutaMarcaINp" 'valore 0 'talk '(=> () (write "sono una periferica di input")))
(def-class 'mouse '(perifericaInput) 'marca "microsoft" 'valore 30 'talk '(=> () (write "sono un mouse")))
(def-class 'tastiera '(perifericaInput) 'marca "trust" 'valore 100 'talk '(=> () (write "sono una tastiera costosa")))
(def-class 'monitor '(perifericaInput perifericaOutput) 'marca "BenQ" 'talk '(=> () (write "sono un monitor molto costoso")))
(def-class 'xsinistri '(mouse) 'marca "logitech" 'valore 200 'talk '(=> () (write "sono un mouse per grandi")))
(def-class 'xdestri '(mouse) 'marca "logiDX" 'valore 50 'talk '(=> () (write "sono un mouse fantastico")))
(def-class 'setup '(xdestri tastiera monitor) 'valore 9)
(defparameter testPersonale (new 'setup 'valore 300))

(getv testPersonale 'valore)
(getv testPersonale 'marca)
(talk testPersonale)
```
Output atteso: 300 - logiDX - sono un mouse fantastico

### Note
Esempio di uso pessimo operatori di assegnamento LISP:
```(progn
   (setf a 1)
   (setf b 2)
   (setf c (* a b))
   
   ;; Chiamo FOO
   (foo a b c))
```
Questo perchè setf modifica l'ambiente globale! Usare piuttosto let.
   
### Link utili
CL HyperSpec -> http://clhs.lisp.se/Front/index.htm <br /><br />

## Progetto OOΠ - PROLOG

### Predicati
* Consentiti: tutto quello che è nella libreria di SWIPL 7.6.4
* Vietati: IF (-> e *->), OR (;), possibilmente NOT

### Link utili
SWIPL 7.6.4 Reference  -> http://www.swi-prolog.org/download/stable/doc/SWI-Prolog-7.6.4.pdf <br />

### Caso d'uso
```
def_class(perifericaOutput, [], [marca = 'sconosciutaMarcaOUt', valore = 0, talk = method([], (write("Sono una periferica di output")))]).
def_class(perifericaInput, [], [marca = 'sconosciutaMarcaINp', valore = 0, talk = method([], (write("Sono una per. di input")))]).
def_class(mouse, [perifericaInput], [marca = 'microsoft', valore = 30, talk = method([], (write("Sono un mouse")))]).
def_class(tastiera, [perifericaInput], [marca = 'trust', valore = 100, talk = method([], (write("Sono una tastiera")))]).
def_class(monitor, [perifericaInput, perifericaOutput], [marca = 'BenQ', talk = method([], (write("Sono un monitor BenQ")))]).
def_class(xsinistri, [mouse], [marca = 'logitech', valore = 200, talk = method([], (write("Sono un mouse per sinistri")))]).
def_class(xdestri, [mouse], [marca = 'logiDX', valore = 50, talk = method([], (write("Sono un mouse per destri")))]).
def_class(setup, [xdestri, tastiera, monitor], [valore = 9]).

new(testPersonale, setup).
getv(testPersonale, valore, Out).
getv(testPersonale, marca, Out).
talk(testPersonale).
```
Output atteso: 9 - logiDX - sono un mouse per destri
```
new(testPersonale2, setup, [valore = 300]).
getv(testPersonale2, valore, Out).
getv(testPersonale2, marca, Out).
talk(testPersonale2).
```
Output atteso: 300 - logiDX - sono un mouse per destri
