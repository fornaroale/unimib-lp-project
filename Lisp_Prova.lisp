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
 ; (print nomeClasse)
  (cond ((not (get-class-spec nomeClasse)) (add-class-spec nomeClasse campi))
        (T (print "errore, classe gia presente"))))

