
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
			(add-class-spec class-name
				;(list class-name parents slot-value)
				(list class-name parents 
					(fondi-attributi parents slot-value)
				)
		)
		
		class-name;
		)
		
  )))
; funzione che mi risolve i parents e attributi
(defun fondi-attributi (lp ls)
; controllo se lp e/o ls ovvero i parent e gli slot sono vuoti
(cond ((and (null lp) (null ls)) nil); se entrambe vuote non faccio nulla
	  ((null lp) (create-metod xxx) (set-slot xxx xxx));!!da fare
	  ((null ls) (create-metod xxx) (set-slot xxx xxx));!!da fare
))


; Funzione new: ritorna lista contenente valori di istanza
(defun new (class-name &rest slot) ;<-- slot: lista di attributi di classe
  (cond ((get-class-spec class-name)  ; verifico esistenza classe
    ; copio attributi classe (e parenti) in istanza e rimpiazzo valori
    ; default con valori istanza:
    (list 'oolinst (checkSlot (get-class-spec class-name) slot 0))
    ;(list 'oolinst class-name (get-class-spec class-name))
    )  ; ritorno istanza
    (T (print "Errore: classe inesistente!")))
;	(let ((contArgomenti 0))
)


; Funzione checkSlot: verifica esistenza nomi slot istanza, e sostituisce
;                     valori default classe con valori istanza
; Devo modificare la instanceList (l'istanza) con i valori nuovi
; Per ogni slot-name in slot, scorro instanceList, e se lo trovo, sostituisco
; lo slot-value (posizione successiva ad esso) nella lista instanceList
(defun checkSlot (instanceList slot slotCount)
  (cond ((< slotCount (length slot)
    ; lista slot: in pos. slotCount ho il nome dello slot, in pos.
    ; slotCount+1 ho il relativo valore
    (setInstVal (nth 2 instanceList) 
                (nth slotCount slot) 
                (nth (+ 1 slotCount) slot)
                2) ; devo partire dalla pos. 2
    ; proseguo con 'attributo' successivo
    (checkSlot instanceList slot (+ 2 slotCount))))))


; Funzione setInstVal: sostituisce il val. default con val. istanza
(defun setInstVal (instanceList slot-name slot-value contSlotInstance)
  (cond ((equal (nth contSlotInstance instanceList) slot-name)
    ; sostituisco slot-value con valore nuovo
    (setf (nth (+ 1 contSlotInstance) instanceList) slot-value)
    ; altrimenti proseguo nella ricerca (ammesso che cont < length)
    (T (cond ((< contSlotInstance (length instanceList))
      (setInstVal instanceList slot-name slot-value (+ 2 contSlotInstance))
       )
)))))
