(asdf:defsystem :cl-config
  :author "Simon Koch <projects@halcony.de>"
  :components ((:file "package")
               (:file "config"
                      :depends-on ("package"))))
