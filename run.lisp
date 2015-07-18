(ql:quickload '(:asdf :cffi))
(pushnew #P"/opt/local/lib/" cffi:*foreign-library-directories* 
	 :test #'equal)
;install for mac port sdl-framwork version :)
#+darwin (pushnew #P"/opt/local/Library/Frameworks/" cffi:*darwin-framework-directories*
	 :test #'equal)
(ql:quickload 
  '( :lispbuilder-sdl :lispbuilder-sdl-mixer :lispbuilder-sdl-ttf 
     :lispbuilder-sdl-image ))
;(ql:quickload "lispbuilder-sdl")
;(ql:quickload "lispbuilder-sdl-mixer")
;(ql:quickload "lispbuilder-sdl-image")
(load "./game.lisp")
#+sbcl (sb-int:with-float-traps-masked (:invalid) (my-game:linker))
#+ecl (my-game:linker)
#+clisp (my-game:linker)
#+ccl  (my-game:linker)
