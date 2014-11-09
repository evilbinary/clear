(load "init.lisp")
(let ((filename #+windows "linker.exe" 
		(or #+darwin "linker"
        #+unix "linker")
		#+linux "linker")
        (main #'my-game:linker))
       #+clisp (saveinitmem filename :init-function main :executable t :norc t)
            #+sbcl (save-lisp-and-die filename :toplevel main :executable t)
                 #+clozure (save-application filename :toplevel-function main :prepend-kernel t))                                                      

