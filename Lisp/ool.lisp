;;;; -*- Mode: Lisp -*-
;;;; Progetto Linguaggi e Programmazione
;;;; ool.lisp
;;;; Author: Perego Daniele 829625
;;;; Author: Fornaro Alessandro 830065
;;;; Author: Leggio Giuseppe 892681



;;; creazione della association list
(defparameter *classes-specs* (make-hash-table))



;;; aggiunge alla hash-table il contenuto di class-spec
(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))

  

;;; ritorna il valore dentro la hash-table con chiave name
(defun get-class-spec (name)
  (gethash name *classes-specs*))

  

;;; definizione del metodo def-class
;;; inizia controllando che tutti gli attributi passati siano validi
;;; superati i controlli procede a salvare la classe sull'association list
;;; richiamando il metodo gestione-attributi che controlla i vari attributi
(defun def-class (class-name parents &rest slot-value)
  (cond ((listp class-name) 
         (error "il nome classe non puo' essere una lista"))
        ((and (not (null parents)) (atom parents)) 
         (error "~S --> la classe parent deve essere una lista" parents))
        ((and (not (null parents))(not (esistePar parents))) 
         (error "~S --> una o piu classi padre non esiste" parents))
        (T 
         ;; in questo modo se la classe e' gia definita viene riscritta
         (remhash class-name *classes-specs*) 
         (add-class-spec class-name
                         (list class-name parents 
                               (gestione-attributi slot-value)))	
         class-name)))



;;; definizione del metodo gestione attributi
;;; metodo utilizzato per fare un controllo sulla presenza di attributi
;;; se sono presenti richiama VerificaR passandogli i vari attributi 
;;; e la lunghezza della lista di slot
(defun gestione-attributi (slot)
  (cond
   ((not (null slot))(verificaR slot (length slot)))))

   
  
;;; definisco una verifica ricorsiva per cercare un metodo che
;;; scorre 2 a 2 una lista, e verifico ogni coppia chiamando verifica
(defun verificaR (temp n) 
  (cond ((equal n 0) nil)
        (T (append (verifica (subseq temp 0 2))
                   (verificaR (subseq temp 2 n) (- n 2))))))


				   
;;; funzione che, se trova un metodo,
;;; mediante chiamata a process-method ritorna una funzione anonima
;;; costruita sulla base sel metodo passato
(defun verifica (temp)
  ;; se il corpo e' una lista e trovo il simbolo del metodo
  ;; allora e' un metodo e lo tratto come tale
  ;; in caso contrario sara' un semplice attributo e lo ritorno inalterato
  (cond ((and (listp (car(cdr temp)))
              (equalp '=> (car(car(cdr temp)))))
         (append (list (car temp))
                 (list (process-method
                        (car temp)
                        (cdr (car (cdr temp)))))))
        (T temp)))



;;; definizione del metodo che controlla l'esistenza delle superclassi
(defun esistePar (listaP)
  (cond 
   ;; questo primo caso serve quando avviene la chiamata ricorsiva
   ;; sul first della lista di parents
   ((atom listaP) 
    (cond ((get-class-spec listaP) T)
          (t nil)))
   ;; questo e' il caso usato quando ho una lista di un solo elemento
   ((eql (length listaP) 1) 
    (cond ((get-class-spec (car listaP)) T)
          (t nil)))
   ;; questo e' il caso eseguito quando una lista ha piu di un parents
   (t (and (esistePar (first listaP)) 
           (esistePar (rest listaP))))))


		   
;;; definizione del metodo che crea la funzione trampolino
;;; che costruisco mediante lambda, questa funzione avro' come parametri
;;; la this e in piu eventuali altri valori, usati dalla funzione 
;;; che viene richiamata da questa funzione trampolino appena creata  
;;; uso la funzione apply per applicare la funzione trovata mediante
;;; una getv con this (che verra' sostituito con l'istanza stessa 
;;; quando richiamato) e il nome del metodo. 
(defun process-method (method-name method-spec)
  (setf (fdefinition method-name)
        (lambda (this &rest valori)
          (apply (getv this method-name)
                 (append (list this) valori))))
  (eval (rewrite-method-code method-name method-spec)))


  
;;; definizione del metodo che riscrive un metodo passato 
;;; aggiungendo la this come primo argomento se non e' gia presente
(defun rewrite-method-code (method-name method-spec)
  (cond ((not (symbolp method-name))    
         (error "~S --> metodo costruito non correttamente" method-name))
        ;; se il primo elemento delle specifiche e' gia una funzione
        ;; la ritorno senza fare altro
        ((functionp method-spec) method-spec)
        ;; altrimenti creo la funzione aggiungendo le this
        (t (append (list 'lambda
                         ;; prima verifico se ci sono altri parametri
                         (cond ((not (null (car method-spec)))
                                ;; se i parametri del metodo sono una lista
                                ;; e la this non e' gia presente la aggiungo
                                ;; e in coda ritorno tutti gli altri parametri
                                (cond ((and (listp (car method-spec)) 
                                            (not 
                                             (equalp 'this 
                                                     (car (car method-spec)))))
                                       (append (list 'this) (car method-spec)))
                                      (t (car method-spec))))
                               ;; altrimenti aggiungo solo this
                               (t  (list 'this))))
                 ;aggiungo in coda a lambda e ai parametri, la funzione
                   (cdr method-spec)))))

				   
				   
;;; funzione new richiamata per istanziare un oggetto;
;;; permette di modificare i valori degli attributi di default
(defun new (class-name &rest slot)
  (cond
   ;; controllo che la classe esista
   ((get-class-spec class-name) 
    ;; se esiste costruisco l'oggetto 
    (list 'oolinst
          class-name
          (second (get-class-spec class-name))
          ;; cerco negli attributi dei metodi mediante searchForMethods
          ;; dopo aver copiato tutti gli attributi e metodi associati
          ;; alle relative superclassi (parents) usando searchParents
          (searchForMethods 
           (checkSlot 
            (searchParents class-name nil)
            slot 0)
           0)))
   (T (error "~S --> classe inesistente!" class-name))))



;;; funzione che copia tutti gli attributi e metodi propri
;;; e delle superclassi da cui eredita
(defun searchParents (class-name instanceList)
  (cond
   ;; verifico che il nome classe non sia nil
   ;; e se verificato verifico che non sia una lista
   ((not (null class-name))
    (cond
     ((not (listp class-name))
      ;; parents conterra' i parents della classe su cui sto lavorando
      (let ((parents (second (get-class-spec class-name))))
        (cond
         ;; se ha zero parents
         ((null parents)
          (copySlotsInInstance instanceList
                              (car (last (get-class-spec class-name)))
                              0))
         ;; se ha un solo parent ci entro chiamando searchParents
         ;; (questo metodo) copiando gli attributi della classe in cui sono
         ((eql 1 (length parents))
          (copySlotsInInstance (searchParents 
                               (first parents) 
                               (copySlotsInInstance 
                                instanceList 
                                (car 
                                 (last (get-class-spec class-name))) 
                                0))
                              (car (last (get-class-spec class-name)))
                              0))
         ;; se ho piu' parent richiamo searchParents sul primo e sul 
         ;; resto dei parent, in caso di doppione tengo i valori
         ;; trovati per primi (grazie a copySlotInInstance)
         (T (copySlotsInInstance (copySlotsInInstance
                                 (searchParents 
                                  (first parents) 
                                  (copySlotsInInstance 
                                   instanceList 
                                   (car (last (get-class-spec class-name))) 
                                   0))
                                 (searchParents (rest parents) instanceList)
                                 0)
                                (car (last (get-class-spec class-name)))
                                0)))))
     ;; se class-name e' una lista richiamo searchParents 
     ;; sul primo e sul resto dei parent
     (T	(copySlotsInInstance (copySlotsInInstance
                             (searchParents 
                              (first class-name) 
                              (copySlotsInInstance 
                               instanceList 
                               (car (last (get-class-spec (first class-name)))) 
                               0))
                             (searchParents (rest class-name) instanceList)
                             0)
                            (car (last (get-class-spec class-name)))
                            0))))))



;;; funzione che copia attributi e metodi della lista slot
;;; in instanceList qualora non siano gia' presenti
(defun copySlotsInInstance (instanceList slot slotCount)
  ;; se non ho finito di scorrere la lista di attributi continuo
  (cond ((< slotCount (length slot))
         (copySlotsInInstance 
          (setParValue instanceList 
                       (nth slotCount slot) ; attributo
                       (nth (+ 1 slotCount) slot) ; valore attributo
                       0)
          slot 
          (+ 2 slotCount)))
        ;; se non ho nulla da scorere ritorno instanceList
        (T instanceList)))


		
;;; funzione che verifica se sono gia' presenti delle coppie
;;; attributo-valore definite in instanceList, se gia presenti le lascia
;;; invariate, altrimenti provvede ad inserirle
(defun setParValue (instanceList slot-name slot-value contSlotParents)
  (cond 
   ;; se non trova il nome dell'attributo
   ((not(equal (nth contSlotParents instanceList) slot-name)) 
    ;; lo cerca ricorsivamente sul resto della lista aumentando di 2
    ;; fino a quando non ho analizzato tutta la lista
    (cond ((< (+ 2 contSlotParents) (length instanceList))
           (setParValue instanceList 
                        slot-name 
                        slot-value 
                        (+ 2 contSlotParents)))
          ;; se arrivo qui, significa che lo slot non c'era in eventuali
          ;; padri, faccio quindi la append e inserisco l'attributo/metodo
          (T (append instanceList (list slot-name slot-value)))))
   ;; se trovo l'attributo vuol dire che e' stato gia inserito 
   ;; e ritorno la lista inalterata, perche' si vuole tenere
   ;; la prima coppia attributo valore che si incontra
   (t instanceList)))



;;; funzione che scorre la lista di attributi della classe 2 a 2;
;;; per ogni coppia chiama setInstVal che scorrera' invece la instanceList
(defun checkSlot (instanceList slot slotCount)
  (cond ((< slotCount (length slot))
         (checkSlot (setInstVal instanceList 
                                (nth slotCount slot) ; attributo
                                (nth (+ 1 slotCount) slot) ;valore
                                0)
                    slot (+ 2 slotCount)))
        ;; se non ho nulla in slot ritorno la lista
        (T instanceList)))



;;; funzione che sostituisce il valore di default dell'attributo con il 
;;; valore definito dall'utente, scorrendo la instanceList 
(defun setInstVal (instanceList slot-name slot-value contSlotInstance)
  (cond 
   ;; se trovo lo slot con il nome dell'attributo che cerco
   ;; e verifico che non sia una funzione (perche' da specifiche si possono 
   ;; modificare solo i valori degli attributi)
   ((and (equal (nth contSlotInstance instanceList) slot-name)
         (not (functionp (nth (+ 1 contSlotInstance) instanceList))))
    ;; sostituisco il valore default con il valore dell'istanza 
    ;; deciso dall'utente
    (listReplace instanceList (+ 1 contSlotInstance) slot-value))
   ;; altrimenti proseguo nella ricerca (ammesso che cont < length)
   (T (cond 
       ((< (+ 2 contSlotInstance) (length instanceList))
        (setInstVal instanceList
                    slot-name
                    slot-value 
                    (+ 2 contSlotInstance)))
       (T (error "~S --> attributo inesistente!" slot-name))))))



;;; funzione che richiama process-method su eventuali metodi
;;; dove slotList e' la lista dell'istanza
;;; e slotCount un contatore usato per muoversi nell'istanza
(defun searchForMethods (slotList slotCount)
  ;; scorro la lista 2 a 2
  (cond ((< slotCount (length slotList))
         ;; se e' una funzione richiamo la process method
         (cond
          ((functionp (nth (+ 1 slotCount) slotList))
           (process-method (nth slotCount slotList)
                           (nth (+ 1 slotCount) slotList))))
         (searchForMethods slotList (+ 2 slotCount))
         slotList)))



;;; funzione per sostituzione n-esimo valore di una lista con 'elem'
(defun listReplace (list n elem)
  (cond
   ((null list) ())
   ((= n 0) (cons elem (cdr list)))
   (t (cons (car list) (listReplace (cdr list) (1- n) elem)))))
			 
			 
;;; funzione che serve per stampare il valore di un dato attributo	 
;;; Verifico che l'istanza inizi per "oolinst", altrimenti stampo un errore
;;; Se esiste, verifico che slot-name sia un simbolo
;;; Se non riscontro errori, calcolo il valore dell'attributo richiesto 
;;; richiamando la funzione get-slot-value
(defun getv (instance slot-name)
  (cond
   ((not (equal (car instance) 'OOLINST)) (error "Non inizia con oolinst"))
   ((not (symbolp slot-name)) (error "Slot-name non e' un simbolo!"))
   (T (get-slot-value instance slot-name)))) 



;;; definisco una funzione che recupera l'attributo richiesto
;;; prende l'elemento alla posizione successiva rispetto al nome 
;;; dell'attributo, dalla sottolista contenuta nel'instanza in cui sono 
;;; contenuti tutti gli attributi se non lo trova restituisce un errore
(defun get-slot-value (instance slot-name)
  (cond 
   ((not (null (position slot-name (first (last instance)))))
    (nth (+ 1 (position slot-name (first (last instance))))
         (first (last instance))))
   (T (error "~S --> Attributo non presente!" slot-name))))



;;; funzione per trovare il valore di un attributo 
;;; all'interno di oggetti annidati
(defun getvx (instance &rest slot-name)
  (cond 
   ((null (car slot-name)) nil)  
   ;; se passo un solo elemento eseguo queste istruzioni
   ((and (eql (length slot-name) 1) 
         (atom (car slot-name))) 
    (getv instance (car slot-name))) 
   ;; in tutti gli altri casi eseguo il resto
   ((eql (length slot-name) 1) 
    (cond ((eql (length (car slot-name)) 1) 
           (getv instance (car(car slot-name))))
          (T (getvx (getv instance (car (car slot-name))) 
                    (rest(car slot-name))))))
   ;; se ce ne sono ancora
   (t (getvx (getv instance (car slot-name)) 
             (rest slot-name)))))


 ;;;; End Of File
