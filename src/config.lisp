(in-package :de.halcony.cl-config)


(defclass config-manager ()
  ((config-table :initform (make-hash-table :test 'equalp)
                 :reader config-table)))


(defun trim-string (string)
  (string-trim '(#\SPACE #\TAB) string))


(defmethod enter-value ((cm config-manager) section key value)
  (let ((section (trim-string section))
        (key (trim-string key))
        (value (trim-string value)))
    (with-slots (config-table)
        cm
      (let ((section-table (gethash section config-table)))
        (if section-table
            (setf (gethash key section-table) value)
            (progn
              (setf (gethash section config-table)
                    (make-hash-table :test 'equalp))
              (enter-value cm section key value)))))))


(defmethod get-value ((cm config-manager) section key)
  (with-slots (config-table)
      cm
    (let ((section-table (gethash section config-table)))
      (if (not section-table)
          (error (format nil "configuration section ~a does not exist" section))
          (if (gethash key section-table)
              (values (gethash key section-table) T)
              (values nil nil))))))


(defun parse-config-file (config-file-path)
  (with-open-file (stream config-file-path)
    (do ((line (read-line stream nil nil)
               (read-line stream nil nil))
         (current-section "default")
         (config-manager (make-instance 'config-manager) config-manager))
        ((not line) config-manager)
      (let ((trimmed-line (trim-string line)))
        (when (not (string= trimmed-line ""))
          (let ((first (subseq trimmed-line 0 1))
                (last (subseq trimmed-line (- (length trimmed-line) 1))))
            (if (and (string= first "[")
                     (string= last "]"))
                (setf current-section (subseq trimmed-line 1 (- (length trimmed-line) 1)))
                (let ((split (cons (subseq trimmed-line 0 (position #\= trimmed-line :test #'char=))
                                   (subseq trimmed-line (+ (position #\= trimmed-line :test #'char=) 2)))))
                  (assert (and (not (string= (car split) ""))
                               (not (string= (cdr split) ""))))
                  (enter-value config-manager current-section (car split) (cdr split))))))))))
