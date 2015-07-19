;;game by evilbinary
;;rootntsd@gmail.com
;;create date:2014-05-01


(defpackage #:my-game
  (:use #:cl :cl-user)
  (:nicknames #:clear)
  (:export #:linker))
(in-package my-game)


(defvar *path* *default-pathname-defaults*)
(defvar *image-path* (merge-pathnames "image/" *path*))
;(print *image-path*)
(defvar *music-path* (merge-pathnames "sound/" *path*))
(defvar *audio-path* (merge-pathnames "sound/" *path*))
(defvar *bomb-image* nil)

;(defvar *image-path* (sdl:load-directory))
(defvar *begin-x* 20)
(defvar *begin-y* 80)
(defvar *number-col* 6)
(defvar *number-row* 6)

(defvar *frequency* 44100)
(defvar *output-chunksize* 2048)
(defvar *output-channels* 2)
(defvar *sample-format* SDL-CFFI::AUDIO-S16LSB)

(defun main() (linker))

;;检查重复个数y
(defun compress (x)
  (if (consp x)
      (compr (car x) 1 (cdr x))
      x))

(defun compr (elt n lst)
  (if (null lst)
      (list (n-elts elt n))
      (let ((next (car lst)))
        (if (eql next elt)
            (compr elt (+ n 1) (cdr lst))
            (cons (n-elts elt n)
                  (compr next 1 (cdr lst)))))))

(defun n-elts (elt n)
  (if (> n 1)
      (list n elt)
      elt))

;;解压重复
(defun uncompress (lst)
  (if (null lst)
      nil
      (let ((elt (car lst))
            (rest (uncompress (cdr lst))))
        (if (consp elt)
            (append (apply #'list-of elt)
                    rest)
            (cons elt rest)))))

(defun uncompress1 (lst)
  (if (null lst)
      nil
      (let ((elt (car lst))
            (rest (uncompress (cdr lst))))
        (if (consp elt)
            (append (apply #'list-of elt)
                    rest)
            (cons elt rest)))))

(defun list-of (n elt)
  (if (zerop n)
      nil
      (cons elt (list-of (- n 1) elt))))

(defun check-swapable (ax ay bx by)
  (and (<= bx (+ ax 1)) (>= bx (- ax 1)) ;;交换只能隔壁
       (<= by (+ ay 1)) (>= by (- ay 1))))

(defun check-bound (ax ay bx by)
  (and (<= ax *number-col*)
       (<= bx *number-col*)
       (<= ay *number-row*)
       (<= by *number-row*) 
       (>= ax 0) 
       (>= ay 0)
       (>= bx 0)
       (>= by 0) ;;>0 控制
))

;;todo clear 1 metho
(defun clear1 (list)
  (dolist (l list)
    (compress l)))
(defmacro ll (&rest l)
	   `(list ,@l))
;;清除一行
(defun clear-line(list)
  (let ((e0 (car list))
	(count 0)
	(i 0)
	(tmp '(0))
	(result '()))
    (do ((i 1 (incf i)))
	((> i (length list)) result)
      (progn
	;;(format t "cmp n[~a]:~a,~a~%" i (nth i list) e0)
	(if (eq (nth i list) e0)
	    (progn
	      (setf tmp (append tmp (list i)))
	      ;;(format t "tmp:~a i:~a~%" tmp i)
	      (incf count)
	      (if (>= count 2)
		;;(format t "count:~a e:~a~%" count e0)
		nil))
	    (progn 
	      ;;(setf tmp (append tmp (list i)))
	      ;;(format t "tmp1:~a~%" tmp)
	      (when (> count 1)
		(setf result (append result tmp )))
	      (setf tmp (list i))
	      (setf e0 (nth i list))
	      (setf count 0)))
	;;(format t "i:~a e0:~a n[~a]:~a~%" i e0 i (nth i list))
	))
    (return-from clear-line result)))

(defun nth-col(list n)
  "获第n列"
  (let ((tmp nil))
    (dolist (x list)
      ;(print x)
      ;(format t "~a~%" (nth n x))
      (setf tmp (append tmp (list (nth n x))))
      )
    (return-from nth-col tmp)))


(defun draw-image (image x y)
  (let ((pos (sdl:point :x (+ *begin-x* (* x 48))
				    :y (+ *begin-y* (* y 48)))))
    (sdl:draw-surface-at  image pos)))

(defun copy-mat (mat)
  (copy-list mat))
             
(defun draw-diff (a b)
  (format t "diff ~a #####~% ~a~%" a b)
  (loop for x in a
    for y in b
    for i from 0
    do 
    (loop for xa in x
      for xb in y
      for j from 0
      ;(format t "####~a ~a~%" xa xb)
      if (not (= xa xb))
       do
	 (format t "~a ~a~%" xa xb)
	 (draw-image *bomb-image* i j)
	 (sleep 1)
         )
))

(defun draw-imags(images mat)
  (loop for m in mat
     for i from 0
     do (loop for e in m
          for j from 0
          for (y x) = (multiple-value-list (values i j))
          for position = (sdl:point :x (+ *begin-x* (* x 48))
				    :y (+ *begin-y* (* y 48)))
          do (let ((val nil))
               (setf val (mat-elt mat i j))
               ;(format  t "val:~a (~a,~a) i:~a j:~a~%"  val x y i j)
               (if (not (eq val nil))
                   (sdl:draw-surface-at (nth val (remove nil images)) position))
               
	    
	      ))))

(defun clear(mat)
  ;;(format t "l:~a~%" list)
  (let ((row nil)
	(col nil)
	(i 0))
  (dolist (l1 (car mat))
    (setf col (append col (list (clear-line (nth-col mat i)))))
    (incf i))
  (dolist (l mat)
    (setf row (append row (list (clear-line l))))
    ;(format t " clear-line:~a~%" (clear-line l))
    )
  ;(format t " row:~a col:~a~%" row col)
  (setf i 0)
  ;;set row zero
  (dolist (r row)
    (set-zero r (nth i mat))
    (incf i))
  ;;set col zero
  (setf i 0)
  (dolist (c col)
    (dolist (ce c)
      (mat-set mat ce i 0)
      ;(setf (mat-elt list i ce) 0)
      ;(format t "i:~a ce:~a v:~a~%" i ce (mat-elt list i ce))
      )
    (incf i))
   (return-from clear (list row col))))
(defun set-zero(pos list)
  (dolist (x pos)
    (setf (nth x list) 0)))

(defmacro mat-elt (mat row col)
  `(nth ,col (nth ,row ,mat)))
(defmacro mat-set (mat row col val)
  `(setf (mat-elt ,mat ,row ,col) ,val))
#+darwin (defun mat-set (mat row col val)
  (setf (mat-elt mat row col) val))

(defun mat-get (mat row col)
  (values (mat-elt mat row col))
)
(defun column@ (mat at)
  (mapcar #'(lambda (r) (nth at r)) mat))
(defun mat-rotate (mat)
  (apply #'mapcar (lambda (&rest r) r) mat))
(defmacro != (&rest l)
  `(not (= ,@l)))
(defun mat-print(mat)
  (dolist (l mat)
    (format t "~a~%" l)))

(defun test-clear()
  (let ((a nil))
    (setf a (list (list 1 2 2 2 5 5) '(1 2 5 5 5 2) '(1 1 1 4 5 1) '(1 3 4 5 6 6)))
    (setf a (list (list 1 2 3 4 4 4 1) (list 2 3 4 2 2 1 2) (list 3 4 5 3 4 5 2) (list 4 5 6 5 6 2 3) (list 5 4 3 6 1 1 4) (list 6 5 4 2 2 3 1)  (list 3 4 5 3 4 5 3)  (list 3 4 5 3 4 5 1)  (list 3 4 5 3 4 5 1)))
    ;(format t "nth0:~a" (nth 0 a))
    (format t "befor:~%")
    (mat-print a)
    (clear a)
    (format t "after:~%")
    (mat-print a)
    (format t "down:~%")
    (mat-print a)
    (format t "down-af:~%")
    (mat-print (down a))))

(defun down-line (list)
  (let ((zero ())
	(vals ()))
    (dolist (l list)
      (if (eq l 0)
	  ;;(format t "~a~%" (adjoin l zero))
	  (setf zero (append  zero (list l)))
	  ;(format t "~a~%" (append vals l));
	  (setf vals (append  vals (list l)))
	  ))
    ;(format t "zero:~a vals:~a append:~a~%" zero vals (append zero vals))
    ;(setf vals (append zero vals))
    (return-from down-line (append zero vals))))
    
(defun down (mat)
 ; (mat-print mat)
  ;(mat-rotate mat)
  (setf mat (mat-rotate mat))
  ;(mat-print mat)
  (let ((mt nil))
    (dolist (m mat)
      (setf mt (append mt (list (down-line m))))
      ;(format t "down:~a~%" (down-line m))
      )
    (return-from down (mat-rotate mt))))

(defun sample-finished-action ()
  (sdl-mixer:register-sample-finished
   (lambda (channel)
     (declare (ignore channel))
     nil)))

(defun music-finished-action ()
  (sdl-mixer:register-music-finished
   (lambda ())))

; play music
(defun play-music(music music-status)
  (if (sdl-mixer:music-playing-p)
      (progn
	(sdl-mixer:pause-Music)
	(setf music-status (format nil "Music \"~A\": Paused..." 1)))
      (if (sdl-mixer:music-paused-p)
        (progn
          (sdl-mixer:resume-Music)
          (setf music-status (format nil "Music \"~A\": Resumed..." 1)))
        (progn
          (sdl-mixer:play-music music)
          (setf music-status (format nil "Music \"~A\": Playing..." 1))))))


;(defparameter array-status nil)
(defun linker ()  
  (let ((sample nil)
        ;(status "")
	(array-status nil)
	(images nil)
	(image-bg nil)
	(down-x nil)
	(down-y nil)
	(music-bg nil)
	(status nil)
	(music-status nil)
	(mixer-opened nil)
	)
    ;; Init value
    (setf array-status (list '(1 2 3 4 4 4 1) '(2 3 4 2 2 1 2) '(3 4 5 3 4 5 2) '(4 5 6 5 6 2 3) '(5 4 3 6 1 1 4) '(6 5 4 2 2 3 1)  '(3 4 5 3 4 5 3)  '(3 4 5 3 4 5 1)  '(3 4 5 3 4 5 1)))
    (setf array-status (list (list 1 2 3 2 4 4 1) (list 2 3 4 2 2 1 2) (list 3 4 5 3 4 5 2) (list 4 5 6 5 6 2 3) (list 5 4 3 6 1 1 4) (list 6 5 4 2 2 3 1) (list 6 5 4 2 2 3 1)  ))
    (mat-print array-status)
    ;(clear array-status)
    (print "init sdl")
    ;; Initialize SDL
    (sdl:with-init ()
      (print "init window")
      (sdl:window 460 480 :title-caption "clear")
      ;(sdl:window 600 600 )
      (print "init frame")
      (setf (sdl:frame-rate) 30)
      (setf status "100")
      (print "init font")
      (sdl:initialise-default-font)
      (print "init image")
      (sdl-image:init-image :jpg :png :tif)
     
      (let ((images-name (list "chess0.png" "chess1.png" "chess2.png" "chess3.png" "chess4.png" "chess5.png" "chess6.png" ))
	    (images-1 nil))
	(print "load images")
	;(sdl-image:load-image (merge-pathnames "chess0.png" *image-path*) :color-key-at #(90 90 ))
	(dolist (name images-name)
	  (format t "path:~a~%" (merge-pathnames name *image-path*))
	  (setf images (append images (list (sdl-image:load-image (merge-pathnames name *image-path*) :color-key-at #(90 90))))))
      
      (print "load background image")
      ;load backgroud image
      (setf image-bg (sdl-image:load-image (merge-pathnames "bg.png" *image-path*) :color-key-at #(0 0) )))
      (setf *bomb-image* (sdl-image:load-image (merge-pathnames "bomb.png" *image-path*) :color-key-at #(0 0) ))

      (print "mixer init")
      (sdl-mixer:init-mixer  :wav :ogg :mp3)
      (print "load bg music")
      ;;load bg music 
      ;;(setf mixer-opened (sdl-mixer:OPEN-AUDIO  :enable-callbacks nil))
      (setf mixer-opened (sdl-mixer:open-audio :frequency *frequency*
                     :chunksize *output-chunksize*
                     ;; :enable-callbacks t
                     :format *sample-format*
                     :channels *output-channels*))
      (print "open success")
    (when mixer-opened
      (setf status "Opened Audio Mixer.")
      (setf music-bg (sdl-mixer:load-music (sdl:create-path "music.mp3" *audio-path*)))
      (setf sample (sdl-mixer:load-sample (sdl:create-path "phaser.wav" *audio-path*)))
      ;; Seems in win32, that these callbacks are only really supported by Lispworks.
      (music-finished-action)
      (sample-finished-action)
      (sdl-mixer:allocate-channels 16)
      (play-music music-bg music-status)
      (sdl-mixer:play-sample sample)
      (format t "music-status:~a~%" music-status)
      ;(setf music-bg (sdl-mixer:load-music (sdl:create-path "bgm_game.ogg" *audio-path*)))
      ;(format t "music:~a~%" music-bg)
      ;(sdl-mixer:play-music music-bg)
      )
      
      (sdl:update-display)

      (sdl:with-events ()
        (:quit-event () t)
        (:video-expose-event ()
			     (sdl:update-display))
        (:key-down-event ()
			 (when (sdl:key-down-p :SDL-KEY-ESCAPE)
			   (sdl:push-quit-event))
			 (when (sdl:key-down-p :SDL-KEY-R)
			   (format t "reset~%")
			   (mat-set array-status 0 0 (+ 1 (random 5)))
			   (setf array-status (list '(1 2 3 4 2 4 1) '(2 3 4 2 2 1 2) '(3 4 5 3 4 5 2) '(4 5 6 5 6 2 3) '(5 4 3 6 1 1 4) '(6 5 4 2 2 3 1)  '(3 4 5 3 4 5 3)  '(3 4 5 3 4 5 2) ))
			   (mat-print array-status))
			 (when (sdl:key-down-p :SDL-KEY-SPACE)
			   (when (sdl:audio-opened-p)
			     (sdl:play-audio  sample)
			     (print (list sample))
			     (list sample)
			     (sdl:draw-string-solid "test" (sdl:point) :color sdl:*red*)))
			 ;;press m key for test
			 (when (sdl:key-down-p :SDL-KEY-M)
			  
			     (play-music music-bg music-status)
					;(sdl-mixer:play-sample sample)
			     ;(sdl-mixer:play-music music-bg)
			     )
			 ;;press p key
			 (when (sdl:key-down-p :SDL-KEY-P)
			   (format t "clear befor~%")
			   (mat-print (clear array-status))

			   (format t "p press~%")
			   (setf array-status (down array-status))
			   (mat-print (down array-status))
			   (format t " after down~%")
			   (mat-print array-status)))
	;(:mouse-motion-event (:state state :x x :y y :x-rel x-rel :y-rel y-rel)
	;		     (format t "state:~a x:~a y:~a x-rel:~a y-rel:~a~%" state x y x-rel y-rel))
	(:mouse-button-down-event (:button button :state state :x x :y y)
				  (when (= button 1)
				    (format t "down button:~a state:~a x:~a y:~a~%" button state x y)
				    (setf down-x x)
				    (setf down-y y))
				  )
	(:mouse-button-up-event (:button button :state state :x x :y y)
				(if (= button 1)
				    (progn 
                                      (format t "up button:~a state:~a x:~a y:~a~%" button state x y)
                                      (format t "down-x:~a down-y:~a~%" down-x down-y)
                                      (let ((swap-a-x nil)
                                            (swap-a-y nil)
                                            (swap-b-x nil)
                                            (swap-b-y nil)
                                            (swap-a-value nil)
                                            (swap-b-value nil))
                                        (setf swap-a-x (floor (/ (- down-x *begin-x*) 48)))
                                        (setf swap-a-y (floor (/ (- down-y *begin-y*) 48)))
                                        (setf swap-b-x (floor (/ (- x *begin-x*) 48)))
                                        (setf swap-b-y (floor (/ (- y *begin-y*) 48)))
                                        (format t "swapa:(~a,~a) (~a,~a)~%"  swap-a-x swap-a-y swap-b-x swap-b-y)
                                        (format t "check-bound:~a~%" (check-bound swap-a-x swap-a-y swap-b-x swap-b-y))
                                        (when (and  (check-swapable swap-a-x swap-a-y swap-b-x swap-b-y) 
					       (check-bound swap-a-x swap-a-y swap-b-x swap-b-y))
                                          (setf swap-a-value  (mat-get array-status swap-a-y swap-a-x))
                                          (setf swap-b-value (mat-get array-status swap-b-y swap-b-x))
                                          (format t "va:~a vb:~a~%" swap-a-value swap-b-value)
                                          (if (or swap-a-value swap-b-value (!= swap-a-x swap-b-x) (!= swap-a-y swap-b-y))
                                              (progn 
                                                (mat-set array-status swap-a-y swap-a-x swap-b-value)
                                                (mat-set array-status swap-b-y swap-b-x swap-a-value)
                                                (format t "set:(~a,~a)=~a set:(~a,~a)=~a~%" swap-a-x swap-a-y swap-a-value swap-b-x swap-b-y swap-b-value)))))
                                      (let ((old-array-status (copy-mat array-status)))
                                        (format t "copy-mat ~a" old-array-status)
                                        (mat-print (clear array-status))
                                        (draw-diff old-array-status array-status)
                                        (format t "p press~%")
                                        (setf array-status (down array-status)))
                                      
                                      ))
				)
				
				    
        (:idle ()
               (sdl:clear-display sdl:*black*)
               (sdl:draw-surface-at image-bg  (sdl:point :x 0 :y 0))
               ( draw-imags images array-status)
               ;(format t "~%")
               (when (sdl:audio-opened-p)
                 (if (sdl:audio-playing-p)
                     (setf status (format nil "Number of audio samples playing: ~d"
                                          (sdl:audio-playing-p)))
                     (setf status "Audio complete. Press SPACE to restart.")))
               (sdl:draw-filled-circle (sdl:point :x (random 200) :y (random 10))
                                       (random 40)
                                       :color (sdl:any-color-but-this sdl:*black*)
                                       :surface sdl:*default-display*)
               (sdl:draw-string-solid status (sdl:point) :color sdl:*white*)

               ;(sdl:draw-string-solid-* status 1 1 :surface sdl:*default-display* :color sdl:*white*)
               ;(sdl:draw-string-solid-* music-status 1 11 :surface sdl:*default-display* :color sdl:*white*)
               ;(sdl:draw-string-solid-* (format nil "Samples playing: ~A..." (sdl-mixer:sample-playing-p nil))
               ;                   1 21 :surface sdl:*default-display* :color sdl:*white*)
               ; (sdl:dyraw-string-solid-* "<M> Toggle Music. <S> Play Samples." 1 40 :surface sdl:*default-display* :color sdl:*white*)
               (sdl:update-display)
               )))))
