
;creazione della association list
(defparameter *classes-specs* (make-hash-table))


;definizioni metodi getter and setter per l'association list
(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))
(defun get-class-spec (name)
  (gethash name *classes-specs*))


;;! Riscontrato errore usando defparameter, alla seconda creazione, 
;;! usando def-class diceva che era già presete un valore, quello creato in precedenza
;definizione del metodo defun-class
;come prima cosa deve creare un link sulla hashtable basandomi sul nomClasse
;controllo che non esista già una classe persona
(defun def-class (nomeClasse superClassi campi)
  ;(print nomeClasse)
  (cond ((not (get-class-spec nomeClasse)) (add-class-spec nomeClasse campi))
        (T (print "errore, classe gia presente"))))


; Funzione new: 
(defun new (nomeClasse &rest campi)
  ; verifico che non esista gia' il nome
  (cond ((not (symbol-plist nomeClasse))
	; qui devo verificare che ogni campo passato nel simbolo "campi" esista
	; --------- ... ---------
	; il primo campo della property list sara' nome della classe di appartenenza
	;(setf (get nomeClasse ('name)) (nomeClasse)
	; associo attributi all'oggetto il cui simbolo viene passato per argomento
	(let ((contCampi 0))
    (loop while (< contCampi (length campi)) do
      (setf (get nomeClasse (nth contCampi campi)) (nth (+ contCampi 1) campi))
      (incf contCampi 2)))
   (symbol-plist nomeClasse))
   (T (print "ERRORE, ISTANZA GIA' PRESENTE!"))))

