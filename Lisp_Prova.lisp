
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
;controllo che non esista già una classe persona
(defun def-class (class-name parents &rest slot-value)
  ;controlli
  (cond ((get-class-spec class-name) 
         (print "errore, classe gia presente"))         
        (T (progn
             ;(print class-name)
             (add-class-spec class-name
                             (list class-name parents (gestione-attributi parents slot-value))
;(list class-name parents 
;(gestione-attributi parents slot-value)
;)
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
	((null par) (verifica slot))
	((null slot) (verifica par))
	(T (concatena (first (verifica
                              (rest(rest(get-class-spec (first par)))))) 
                      (verifica slot)))
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
      (apply (get-slot this method-name)
             (append (list this) args)
             )
      )
    )
  
  (eval (rewrite-method-code method-name method-spec))
 )
 
(defun rewrite-method-code (method-name method-spec)
  (cond ((not (symbolp method-name))    
         (error "ERRORE: method-name non valido"))

        ((functionp (car method-spec))
         (car method-spec))
    
        (T
         (append (list 'lambda
                       (cond ((not (null (car method-spec)))
                              (progn
                               (cond ((and (listp (car method-spec))
                                          (not (equalp 
                                             'this (car (car method-spec)))))

                                   (append '(this) (car method-spec)))
                                 (T (car method-spec))
                                 )
                               ))
                    
                         (T (list 'this))
                         
                         )
                       )
                 (cdr method-spec)
                 )
         )
        )
)
 
 
(defun verifica (temp)
  (cond ((and (listp (cdr temp))
              (equalp '=> (car(cdr temp))))
         (append (list (car temp)
                       '=>)
                 (list (process-method
                        (car temp)
                        (cdr (cdr temp)))
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
  instanceList
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
    );(t (print "Errore: uno degli attributi specificati e' inesistente!"))
)))