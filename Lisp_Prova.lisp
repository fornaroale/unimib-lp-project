(defparameter *classes-specs* (make-hash-table))

(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))
(defun get-class-spec (name)
  (gethash name *classes-specs*))

(defun def-class (nomeClasse superClassi campi)
  (defparameter 'nomeClasse nomeClasse) 
  (defparameter 'superClassi superClassi)
  (defparameter 'campi campi))
  