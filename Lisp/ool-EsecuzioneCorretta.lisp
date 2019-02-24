;;;; -*- Mode: Lisp -*-
;;;;
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
         (error "~S --> classe gia presente" class-name))
        ((listp class-name) (error "il nome classe non puo' essere una lista"))
        ((and (not (null parents)) (atom parents)) 
         (error "errore, la classe parent deve essere una lista"))
        (T 
         (add-class-spec class-name
                         (list class-name parents 
                               (gestione-attributi parents slot-value))
                         )	
         class-name)))



;gestione attributi
(defun gestione-attributi (par slot)
  (cond
   ((not(null par)) 
    (cond
     ((not (esistePar par)) (error "una o piu classi padre non esiste"))
     ((not (null slot))(verificaR slot (length slot)))))
   ((not (null slot))(verificaR slot (length slot)))))



;controlla esistenza parents
(defun esistePar (listaP)
  (cond ((atom listaP) 
         (cond ((get-class-spec listaP) T)
               (t nil)))
        ((eql (length listaP) 1) 
         (cond ((get-class-spec (car listaP)) T)
               (t nil)))
        (t (and (esistePar (first listaP)) 
                (esistePar (rest listaP))))))

(defun process-method (method-name method-spec)
  (setf (fdefinition method-name)
        (lambda (this &rest args)
          (apply (getv this method-name)
                 (append (list this) args))))
  (eval (rewrite-method-code method-name method-spec)))

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
                                       (append (list 'this) (car method-spec))) ;allora aggiungo la this
                                      (T (car method-spec)))));e ritorno tutti i parametri
                             (T  (list 'this))));altrimenti se non ci sono aggiungo solamente la this e ritorno
                 (cdr method-spec)))));aggiungo in coda a lambda e ai parametri, la funzione


(defun verificaR (temp n) ;scorro 2 a 2 perche' una lista, e verifico chiamando verifica
  (cond ((equal n 0) nil)
        (T (append (verifica (subseq temp 0 2))
                   (verificaR (subseq temp 2 n) (- n 2))))))


(defun verifica (temp)
  (cond ((and (listp (car(cdr temp))); se il corpo e' una lista
              (equalp '=> (car(car(cdr temp))))); se trovo il simbolo di metodo, e' un metodo
         (append (list (car temp))
                 (list (process-method
                        (car temp)
                        (cdr (car (cdr temp)))))))
        (T temp)))


; Funzione new: ritorna lista contenente valori di istanza
(defun new (class-name &rest slot) ;<-- slot = lista di attributi di classe
  (cond
   ((get-class-spec class-name)  ; verifico esistenza classe
    (list 'oolinst
          class-name
          (second (get-class-spec class-name))
          (searchForMethods 
           (checkSlot 
            (searchParents class-name nil)
            slot 0)
           0))
    )(T (error "~S --> classe inesistente!" class-name))))



(defun searchParents (class-name instanceList)
  (cond
   ; se classe != null, cerco i parents
   ((not (null class-name))
    (cond
     ; se class-name non ï¿½ una lista:
     ((not (listp class-name))
      ; parents (locale) conterra' le classi genitore
      (let ((parents (second (get-class-spec class-name))))
        (cond
         ((null parents)
          ; se ha zero parents, ho raggiunto la cima:
          ; copio gli attributi
          (copySlotsInIstance instanceList
                              (car (last (get-class-spec class-name)))
                              0))
         ((eql 1 (length parents))
          ; se ha un solo parent allora entro nel parent con 
          ; questo metodo e poi copio gli attributi della classe
          ; in cui sono
          (copySlotsInIstance (searchParents (first parents) instanceList)
                              (car (last (get-class-spec class-name)))
                              0))
         (T 
          ; altrimenti ha piu' parent, quindi richiamo
          ; questa funzione sul primo e sul resto dei
          ; parent, in caso di doppione tengo i valori
          ; trovati per ultimi (grazie a copySlotInInstance)
          (copySlotsInIstance (copySlotsInIstance
                               (searchParents (first parents) instanceList)
                               (searchParents (rest parents) instanceList)
                               0)
                              (car (last (get-class-spec class-name)))
                              0)))))
      ; class-name ï¿½ una lista: allora
      ; richiamo questa funzione sul primo e sul resto dei
      ; parent, sostituendo a mano a mano i risultati
     (T	(copySlotsInIstance (copySlotsInIstance
                               (searchParents (first class-name) instanceList)
                               (searchParents (rest class-name) instanceList)
                               0)
                              (car (last (get-class-spec class-name)))
                              0))))))



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



; Funzione setParValue: inserisce attributi parent (slot) in istanza
(defun setParValueOLD (instanceList slot-name slot-value contSlotParents)
  (cond 
   ((equal (nth contSlotParents instanceList) slot-name) (
    ; sostituisco val. default con val. istanza deciso da utente:
    ;(listReplace instanceList (+ 1 contSlotParents) slot-value)
    ; altrimenti proseguo nella ricerca (ammesso che cont < length)
    ))(T 
      (cond ((< (+ 2 contSlotParents) (length instanceList))
               (setParValue instanceList 
                            slot-name 
                            slot-value 
                            (+ 2 contSlotParents)))
              ; se arrivo qui, significa che lo slot non c'era in eventuali
              ; padri: faccio la append e inserisco l'attributo/metodo
              (T (append instanceList (list slot-name slot-value)))))))

(defun setParValue (instanceList slot-name slot-value contSlotParents)
  (cond 
   ((not(equal (nth contSlotParents instanceList) slot-name)) 
    (cond ((< (+ 2 contSlotParents) (length instanceList))
           (setParValue instanceList 
                        slot-name 
                        slot-value 
                        (+ 2 contSlotParents)))
              ; se arrivo qui, significa che lo slot non c'era in eventuali
              ; padri: faccio la append e inserisco l'attributo/metodo
          (T (append instanceList (list slot-name slot-value)))))
   (t instanceList)
   )
  )




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
    )(T (cond 
         ((< (+ 2 contSlotInstance) (length instanceList))
          (setInstVal instanceList
                      slot-name
                      slot-value 
                      (+ 2 contSlotInstance)))
         (T (error "~S --> attributo inesistente!" slot-name))))))



; Funzione searchForMethods: richiama process-method su eventuali metodi
; slotList: e' la lista dell'istanza
; slotCount: contatore usato per muoversi nell'istanza
(defun searchForMethods (slotList slotCount)
  (cond ((< slotCount (length slotList))
         ; se e' una funzione richiamo la process method
         (cond
          ((functionp (nth (+ 1 slotCount) slotList))
           (process-method (nth slotCount slotList)
                           (nth (+ 1 slotCount) slotList))))
         (searchForMethods slotList (+ 2 slotCount))
         slotList)))



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
   ;check instance
   ((not (equal (car instance) 'OOLINST)) (error "Non inizia con oolinst"))
   ((not (symbolp slot-name)) (error "Slot-name non e' un simbolo!"))
   ; verifico se i dati in input alla funzione siano corretti
   (T (get-slot-value instance slot-name)))) 



; Funzione get-slot-value: recupera attributo richiesto
(defun get-slot-value (instance slot-name)
  ;prende l'elemento alla posizione successiva rispetto al nome dell'attributo, dalla 
  ;sottolista contenuta nel'instanza in cui sono contenuti tutti gli attributi
  (cond 
   ((not (null (position slot-name (first (last instance)))))
    (nth (+ 1 (position slot-name (first (last instance))))
         (first (last instance))))
   (T (error "~S --> Attributo non presente!" slot-name))))
		 


;getvx deve ritornare una lista contenente l'elenco di valori richiesti dall'utente
;prendo il primo elemento
(defun getvxOLD (instance &rest slot-name)
  (cond 
   ((not (null (car slot-name))) 
    (append (list (getv instance (car slot-name))) 
            (getvx instance (rest slot-name))))))

(defun getvx (instance &rest slot-name)
  (cond 
   ((null (car slot-name)) nil)
   ;((atom slot-name)(getv instance slot-name))
   ((and (equal (length slot-name) 1) (atom (car slot-name))) (getv instance (car slot-name)))
   ((and (equal (length slot-name) 1) (listp (car slot-name))) (append (list (getv instance (car (car slot-name)))) 
                                                                       (getvx instance (rest (car slot-name)))))
   (t (append (list (getv instance (car slot-name))) (getvx instance (rest slot-name))))
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
(def-class 'citta '(uomo) 'nomeCitta :unbound 'Dati '(=> () (list (getv this 'nomeCitta) (getv this 'nome) (getvx this :cognome 'attrProtoni))))
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

;(def-class 'person () 'age 42 :name "Lilith")
	
;(def-class ï¿½student ï¿½(person)
;           ï¿½name "Eva Lu Ator"
;           ï¿½university "Berkeley"
;           ï¿½talk ï¿½(=> ()
;                      (list
;                              (list (getv this ï¿½name))
;                              (getv this ï¿½age))))
;(def-class 'p-complex nil
;           :phi 0.0
;           :rho 1.0
;           'sum '(=> (pcn)
;                     (list (getv this :rho)
;                           (getv this :phi)
;                           (getv pcn :rho)
;                           (getv pcn :phi)
;                           )))

;(def-class ï¿½studente-bicocca ï¿½(student)
;           ï¿½talk ï¿½(=> ()
;                      (princ "Mi chiamo ")
;                      (princ (getv this ï¿½name))
;                      (terpri)
;                      (princ "e studio alla Bicocca.")
;                      (terpri))
;           ï¿½university "UNIMIB")

;(def-class 'person () :age 42 :name "Lilith")
;(def-class 'superhero ï¿½(person) :age 4092)
;(def-class 'doctor ï¿½(person))
;(def-class 'fictional-character ï¿½(person) :age 60)
;(def-class 'time-lord ï¿½(doctor superhero fictional-character))

(def-class 'person () :age 42 :name "Lilith")
(def-class 'superhero ’(person) :age 4092)
(def-class 'doctor ’(person))
(def-class 'fictional-character ’(person) :age 60)
(def-class 'time-lord ’(doctor superhero fictional-character))

(def-class 'base () :lunghezza 0 :a 0 :b 0)
(def-class 'quadrato '(base) :lunghezza 10 :a 0 :b 1 :c 2 :d 3)
(def-class 'triangolo '(base) :lunghezza 20  :a 6 :b 6 :c 6 )
(def-class 'figure '(quadrato triangolo))