;(compile-file "init.lisp")
(load "init.lisp")
(let ((filename #+windows "linker.exe" 
		(or #+darwin "linker"
        #+unix "linker"
		#+linux "linker"))
        (main #'my-game:linker))
       #+clisp (saveinitmem filename :init-function main :executable t :norc t)
            #+sbcl (save-lisp-and-die filename :toplevel main :executable t)
                 #+clozure (save-application filename :toplevel-function main :prepend-kernel t))                                                      

;sbcl – (sb-ext:save-lisp-and-die filename :executable t)
;clisp – (ext:saveinitmem filename :save-executable t)
;OpenMCL – (require "COCOA-APPLICATION")
;ECL – (c:build-program ...)
;Allegro – (generate-executable ...)
;LispWorks – (deliver ...)
