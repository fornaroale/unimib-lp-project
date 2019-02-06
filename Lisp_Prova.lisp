
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
		
  ))
; funzione che mi risolve i parents e attributi
(defun fondi-attributi (l1 l2)



)





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

;funzione ricorsiva che 
(defun scorri-attributi (def-class n lungRagg nomeAttrbuto newValore)
  
)