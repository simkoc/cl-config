(defpackage :de.halcony.cl-config
  (:use :cl-user
        :cl)
  (:nicknames :cl-config)
  (:export parse-config-file
           get-value
           enter-value))
