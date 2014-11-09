(in-package :my-game)
(defpackage #:my-game
  (:nickname #:my-game)
  (:use #:cl #:cffi #:lispbuilder-sdl #:lispbuilder-sdl-mixer #:lispbuilder-sdl-image #:lispbuilder-sdl-ttf)
  (:export main *default-name*))
