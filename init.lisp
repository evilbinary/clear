(ql:quickload :cffi)
;(pushnew #P"/opt/local/Library/Frameworks/" cffi:*foreign-library-directories* 
;	 :test #'equal)
;install for mac port sdl-framwork version :)
(pushnew #P"/opt/local/Library/Frameworks/" cffi:*darwin-framework-directories*
	 :test #'equal)
(ql:quickload "lispbuilder-sdl")
(ql:quickload "lispbuilder-sdl-mixer")
(ql:quickload "lispbuilder-sdl-image")
(load "./game.lisp")
(my-game:linker)
