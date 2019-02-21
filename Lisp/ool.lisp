
; creazione della association list
(defparameter *classes-specs* (make-hash-table))


; definizioni metodi getter and setter per l'association list
(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))
(defun get-class-spec (name)
  (gethash name *classes-specs*))


; definizione del metodo defun-class
; come prima cosa deve creare un link sulla hashtable 
; basandomi sul nomClasse
;controllo che non sista gia' una classe persona
(defun def-class (class-name parents &rest slot-value)
  ;controlli
  (cond ((get-class-spec class-name) 
         (format *error-output* "errore, classe gia presente"))
        ((listp class-name) (format *error-output* "il nome classe non puï¿½ essere una lista"))
        ((and (not (null parents)) (atom parents)) (format *error-output* "errore, la classe parent deve essere una lista"))
        (T (progn
             (add-class-spec class-name
                             (list class-name parents (gestione-attributi parents slot-value))
                             )	
             class-name))))

;gestione attributi
(defun gestione-attributi (par slot)
  (cond
   ((not(null par)) 
     (cond
      ((not (esistePar par)) (error "una o piu classi padre non esiste"))
      ((not (null slot))(verificaR slot (length slot)))
      ;(t nil)
      )
     )
   ((not (null slot))(verificaR slot (length slot)))))

;controlla esistenza parents
(defun esistePar (listaP)
  (cond ((atom listaP) 
         (cond ((get-class-spec listaP) T)
               (t nil))
         )
        ((eql (length listaP) 1) 
         (cond ((get-class-spec (car listaP)) T)
               (t nil))
         )
        (t (and (esistePar (first listaP)) 
                (esistePar (rest listaP))))
  ))

; da cancellare INUTILIZZTA
(defun form (par slot)
	;aggiungere la verifica che sia un metodo
  (cond ((and (null par) (null slot)) nil)
	((null par) (verificaR slot (length slot)))
	((null slot) (risolvi-par par))
	(T (concatena (risolvi-par par) 
                      (verificaR slot (length slot))))
	)
  )
; da cancellare INUTILIZZATA
(defun risolvi-par (par)
  (cond ((equal (length par) 0) nil)
        ((append (first(rest(rest(get-class-spec (first par))))) 
                 (risolvi-par (rest par))))
        )
  )

(defun concatena (x y)
  (append x y)
  ;(flatten (append x y))
  )

;--------
(defun process-method (method-name method-spec)
  (setf (fdefinition method-name)
    (lambda (this &rest args)
      (apply (getv this method-name)
             (append '(this) args)
             ))
    )
  (eval (rewrite-method-code method-name method-spec))
  )

(defun rewrite-method-code (method-name method-spec)
  (cond ((not (symbolp method-name))    
         (error "Errore, il metodo non e' costruito correttamente"))
        ((functionp method-spec) ;se il primo elemento del metodo e' gia una funzione
         method-spec) ;ritorno la funzione
        (T
         (append (list 'lambda ;creo la funzione lambda
                       (cond ((not (null (car method-spec))) ;prima verificando se ci sono altri parametri
                              (progn
                                (cond ((and (listp (car method-spec)) ;se i parametri del metodo sono una lista
                                            (not (equalp 
                                                  'this (car (car method-spec))))) ; e non ho gia la this
                                       (append '(this) (car method-spec))) ;allora aggiungo la this
                                      (T (car method-spec)) ;e ritorno tutti i parametri
                                      )
                                ))
                             (T  '(this)) ;altrimenti se non ci sono aggiungo solamente la this e ritorno
                             )
                      )
                 (cdr method-spec) ;aggiungo in coda a lambda e ai parametri, la funzione
                 )
         )
        )
  )

(defun verificaR (temp n) ;scorro 2 a 2 perche' una lista, e verifico chiamando verifica
  (cond ((equal n 0) nil)
        (T (append (verifica (subseq temp 0 2))
                   (verificaR (subseq temp 2 n) (- n 2))))
        )
  )
(defun verifica (temp)
  (cond ((and (listp (car(cdr temp))); se il corpo e' una lista
              (equalp '=> (car(car(cdr temp))))); se trovo il simbolo di metodo, e' un metodo
         (append (list (car temp))
                 (list (process-method
                        (car temp)
                        (cdr (car (cdr temp))))
                       )
                 )
         )
        (T temp) 
        )
  )
;--------
;forse inutile
(defun appendi (l1 l2)
  (cond ((null l1) l2)
        (T (list (first l1) (appendi (rest l1) l2))))
  )

;forse inutile
(defun flatten (x)
  (cond ((null x) x)
        ((atom x) (list x))
        (T (append (flatten (first x))
                   (flatten (rest x)))))
  )

;(defun verifica (x)
	;implementare riconoscimento dei metodi
;  (progn x)
;)






; Funzione new: ritorna lista contenente valori di istanza
(defun new (class-name &rest slot) ;<-- slot = lista di attributi di classe
  (cond
   ((get-class-spec class-name)  ; verifico esistenza classe
    (let ((class-specs (copy-tree (get-class-spec class-name))))
      (list 'oolinst
            class-name
            (second (get-class-spec class-name))
            (checkSlot (searchParents class-name
                                      (first (last class-specs)))
                       slot
                       0)))
    )(T (error "~S --> classe inesistente!" class-name))))



; Funzione searchParents: controlla che la classe abbia parents e, in tal
; caso, copia gli attributi delle classi genitore nell'istanza
(defun searchParents (class-name instanceList)
  (cond 
   ; se la classe non e' ulla
   ((not (null class-name))
    ;mi salvo i parents della classe in parents
    (let ((parents (second (get-class-spec class-name))))
      (cond 
       ;se parents e' un atomo
       ((atom parents)
        (append
         (cond
          ; ed e' null
          ((null parents)
           ; e la class name e' un atomo
           (cond ((atom class-name)
                  ;allora copio istanceList e gli attributi
                  ;della classe su cui sono
                  (copySlotsInIstance instanceList
                                      (car (last (get-class-spec class-name)))
                                      0))
                 ; se la class-name non e' un atomo copio comunque i valori
                 ; degli attributi della classe su cui sono
                 (t (copySlotsInIstance (searchParents parents instanceList)
                                        (car
                                         (last 
                                          (get-class-spec (car class-name))))
                                        0))))
          ; se la classe name non e' un atomo
          ; copio gli attributi dei parents
          (T (copySlotsInIstance instanceList
                                 (car (last (get-class-spec parents)))
                                 0)))))
       ; se parents è una lista ma ha un solo elemento
       ; copio gli attributi dei parents
       ((eql (length parents) 1)
        (append 
         (copySlotsInIstance (searchParents (car parents) instanceList)
                             (car (last (get-class-spec (car parents))))
                             0)))
       ; altrimenti, se parents non è un atomo 
       ; richiamo ricorsivamente sul primo elemento
       ; e sul resto dei parents
       (t (append (searchParents (first parents) instanceList) 
                  (searchParents (rest parents) instanceList))
          ))))))



; Funzione copySlotsInIstance: copia attributi e metodi della classe
; genitore in quelli della classe figlio
(defun copySlotsInIstance (instanceList slot slotCount)
    (cond ((< slotCount (length slot))
    ; lista slot: in pos. slotCount ho il nome dello slot, in pos.
    ; slotCount+1 ho il relativo valore
    ; proseguo con 'attributo'/metodo successivo
         (copySlotsInIstance 
          (setParValue instanceList 
                       (nth slotCount slot) 
                       (nth (+ 1 slotCount) slot)
                       0)
          slot 
          (+ 2 slotCount)))
    ; ritorno la lista
        (T instanceList)))



; Funzione setParValue: inserisce attributi parent in istanza
(defun setParValue (instanceList slot-name slot-value contSlotParents)
  (cond 
   ((equal (nth contSlotParents instanceList) slot-name)
    ; sostituisco val. default con val. istanza deciso da utente:
    (listReplace instanceList (+ 1 contSlotParents) slot-value)
    ; altrimenti proseguo nella ricerca (ammesso che cont < length)
    )(T (cond ((< (+ 2 contSlotParents) (length instanceList))
               (setParValue instanceList 
                            slot-name 
                            slot-value 
                            (+ 2 contSlotParents)))
              ; se arrivo qui, significa che lo slot non c'era in eventuali
              ; padri: faccio la append e inserisco l'attributo/metodo
              (T (append instanceList (list slot-name slot-value)))
        ))))



; Funzione checkSlot: verifica esistenza nomi slot istanza, e sostituisce
;                     valori default classe con valori istanza
; Devo modificare la instanceList (l'istanza) con i valori nuovi
; Per ogni slot-name in slot, scorro instanceList, e se lo trovo, sostituisco
; lo slot-value (posizione successiva ad esso) nella lista instanceList
(defun checkSlot (instanceList slot slotCount)
  (cond ((< slotCount (length slot))
    ; lista slot: in pos. slotCount ho il nome dello slot, in pos.
    ; slotCount+1 ho il relativo valore,
    ; e proseguo con 'attributo' successivo
         (checkSlot (setInstVal instanceList 
                                (nth slotCount slot) 
                                (nth (+ 1 slotCount) slot)
                                0)
                    slot (+ 2 slotCount)))
  ; ritorno la lista
        (T instanceList)))



; Funzione setInstVal: sostituisce il val. default con val. istanza
(defun setInstVal (instanceList slot-name slot-value contSlotInstance)
  (cond 
   ((and (equal (nth contSlotInstance instanceList) slot-name)
         (not (functionp (nth (+ 1 contSlotInstance) instanceList))))
    ; sostituisco val. default con val. istanza deciso da utente:
    (listReplace instanceList (+ 1 contSlotInstance) slot-value)
    ; altrimenti proseguo nella ricerca (ammesso che cont < length)
    )(T (cond ((< (+ 2 contSlotInstance) (length instanceList))
               (setInstVal instanceList
                           slot-name
                           slot-value 
                           (+ 2 contSlotInstance)))
              (T (error "~S --> attributo inesistente!" slot-name))
        ))))



; Funzione per sostituzione n-esimo valore di una lista con 'elem'
(defun listReplace (list n elem)
  (cond
   ((null list) ())
   ((= n 0) (cons elem (cdr list)))
   (t (cons (car list) (listReplace (cdr list) (1- n) elem)))))
			 
			 
			 
;Verifico che l'istanza inizi per "oolinst", altrimenti stampo un errore
;Se esiste, verifico che slot-name sia un simbolo
;Se e' tutto okay, calcolo il valore dell'attributo richiesto richiamando la funzione get-slot-value

(defun getv (instance slot-name) ;instance -> lista slot-name(campo) -> simbolo
  (cond 
   (T (check-getv instance slot-name) ;verifico se i dati in input alla funzione siano corretti
    (get-slot-value instance slot-name)) ;se lo sono ritorno l'elemento
   )
  )

(defun check-getv (instance slot-name) 
  (cond 
   ((not (equal (car instance) 'OOLINST)) (error "Non inizia con oolinst"));check instance
   ((not (symbolp slot-name)) (print "Errore: slot-name non e' un simbolo"));check slot name=simbolo
   )
  )

(defun get-slot-value (instance slot-name);recupera attributo richiesto
  ;prende l'elemento alla posizione successiva rispetto al nome dell'attributo, dalla 
  ;sottolista contenuta nel'instanza in cui sono contenuti tutti gli attributi
 
 (getElAtPos (+ 1 (getPos slot-name (extract-attributes-list instance))) 
              (extract-attributes-list instance))
)

(defun extract-attributes-list (instance)  ;ritorna la sotto-lista degli attributi
  (nth 2 (car (rest instance)))
  )

(defun getElAtPos (pos l) ;ritorna l'elemento di una lista data la posizione
  ;(print l)
  (cond 
   ((<= pos 0) (car l))
   (T (getElAtPos (- pos 1) (cdr l)))
   )
  )
(defun getPos (el l) ;ritorna la posizione di un dato elemento in una lista
  ;(print l)
  (cond 
   ((null l)(error "Attributo non presente"))
   ((eql (car l) el) 0)
   (T (+ 1 (cond
            ((not (null (cdr l))) (getPos el (rest l)))
            (t (getPos el '()))
            )
         )
      )
   )
  )
			 

;getvx deve ritornare una lista contenente l'elenco di valori richiesti dall'utente
;prendo il primo elemento

(defun getvx (instance &rest slot-name)
  (cond 
   ((not (null (car slot-name))) 
    (append (list (getv instance (car slot-name))) 
             (getvx instance (car (rest slot-name)))))
   )
  )			 
;probabilmente inutile
(defun length-list (l)
  (cond 
   ((null l) 0)
   ((null (car l)) 1)
   ((not (null (car (rest l)))) (+ 1 (length (rest l))))
   )
  )
	 
;; test input


(def-class 'protoni nil 'attrProtoni "prova protoni")
(def-class 'neutroni nil 'attrNeutroni "prova neutroni")
(def-class 'elettroni nil 'attrElettroni "prova importante")
(def-class 'neutrini nil)
(def-class 'molecole '(protoni neutroni elettroni) 'stato :quantico)
(def-class 'muschio '(molecole neutrini) 'piangi '(=> () (write "weee")) 'stato "vita")
(def-class 'ecosistema '(muschio) :stato :vita)
(def-class 'uomo '(molecole) 'nome "unbound" :cognome :unbound)
(def-class 'citta '(uomo) 'nomeCitta :unbound)
(def-class 'pianeta '(citta ecosistema) 'nomeSistema 'terra)

(def-class 'a nil 'nome "lettera")
(def-class 'b nil 'valore "unbound")
(def-class 'c nil 'metodi "zzzzzz")
(def-class 'd nil 'spina "non inclusa")
(def-class 'lettereab '(a b) 'spazio "universo")
(def-class 'alfabeto '(lettereab c) 'asdrubale "leggio") 	 
(def-class 'alfabetoDue '(lettereab c d) 'metodi "sono il nuovo alphab")			 
			 
			 
(def-class 'uno nil 'attuno :unoAtt)
(def-class 'due nil 'attdue :dueAtt)	
(def-class 'tre nil 'atttre :treAtt)	
(def-class 'quattro nil 'attquattro :quattroAtt)
(def-class 'primi4 '(uno due tre quattro) 'valore :siamoIPrimi4)	