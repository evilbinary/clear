;;; -*- lisp -*-
(defpackage :my-game (:user #:cl #:asdf))
(in-package :my-game)
(defsystem my-game
    :name "linker"
    :version "0.1"
    :author "evilbinary"
    :depends-on (cffi lispbuilder-sdl lispbuilder-sdl lispbuilder-sdl-mixer lispbuilder-sdl-image lispbuilder-sdl-ttf)
    :components ((:file "package")
		 (:file "game" :depends-on ("package"))
		 (:file "init" :depends-on ("game"))))
