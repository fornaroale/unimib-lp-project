
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
         (print "errore, classe gia presente"))         
        (T (progn
             ;(print class-name)
             (add-class-spec class-name
                             (list class-name parents (gestione-attributi parents slot-value))
                             )	
             class-name))))

;gestione attributi
(defun gestione-attributi (par slot)
 ; (cond ((and ((null par) (null slot))) nil)
 ;(cond ((null par) (cond (null slot) nil) nil)
  (cond
   ((null par) (form nil slot))
   ((null slot)(form par nil))
   (T (form par slot))
   )
  )

;da sistemare 
(defun form (par slot)
	;aggiungere la verifica che sia un metodo
  (cond ((and (null par) (null slot)) nil)
	((null par) (verificaR slot (length slot)))
	((null slot) (risolvi-par par))
	(T (concatena (risolvi-par par) 
                      (verificaR slot (length slot))))
	)
  )

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
  (cond ((functionp method-spec) (setf (fdefinition method-name) method-spec)))
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
                             (T (list 'this)) ;altrimenti se non ci sono aggiungo solamente la this e ritorno
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
         (append (list (car temp)
                       '=>)
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
(defun new (class-name &rest slot) ;<-- slot: lista di attributi di classe
  (cond ((get-class-spec class-name)  ; verifico esistenza classe
    ; copio attributi classe (e parenti) in istanza e rimpiazzo valori
    ; default con valori istanza:
         (let ((class-specs (copy-tree (get-class-spec class-name))))
           (list 'oolinst (checkSlot class-specs slot 0))
           )
         )(T (print "Errore: classe inesistente!")))
  )


; Funzione checkSlot: verifica esistenza nomi slot istanza, e sostituisce
;                     valori default classe con valori istanza
; Devo modificare la instanceList (l'istanza) con i valori nuovi
; Per ogni slot-name in slot, scorro instanceList, e se lo trovo, sostituisco
; lo slot-value (posizione successiva ad esso) nella lista instanceList
(defun checkSlot (instanceList slot slotCount)
  (cond ((< slotCount (length slot))
    ; lista slot: in pos. slotCount ho il nome dello slot, in pos.
    ; slotCount+1 ho il relativo valore
         (setInstVal (nth 2 instanceList) 
                     (nth slotCount slot) 
                     (nth (+ 1 slotCount) slot)
                     0)
    ; proseguo con 'attributo' successivo
         (checkSlot instanceList slot (+ 2 slotCount))))
  instancelist
  )


; Funzione setInstVal: sostituisce il val. default con val. istanza
(defun setInstVal (instanceList slot-name slot-value contSlotInstance)
  (cond ((equal (nth contSlotInstance instanceList) slot-name)
    ; sostituisco slot-value con valore nuovo
         (setf (nth (+ 1 contSlotInstance) instanceList) slot-value)
    ; altrimenti proseguo nella ricerca (ammesso che cont < length)
         )(t (cond ((< contSlotInstance (length instanceList))
                    (setInstVal instanceList slot-name slot-value (+ 2 contSlotInstance))
                    )
                   )(t (error "~S --> attributo non esistente!" slot-name))
             )))
			 
			 
			 
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
   ((not (symbolp slot-name)) (print "Errore: slot-name non Ã¨ un simbolo"));check slot name=simbolo
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
	 
			 
			 
			 
			 
			 
