;; idaptiky - Guix Package Definition
;; Run: guix shell -D -f guix.scm

(use-modules (guix packages)
             (guix gexp)
             (guix git-download)
             (guix build-system node)
             ((guix licenses) #:prefix license:)
             (gnu packages base))

(define-public idaptiky
  (package
    (name "idaptiky")
    (version "0.1.0")
    (source (local-file "." "idaptiky-checkout"
                        #:recursive? #t
                        #:select? (git-predicate ".")))
    (build-system node-build-system)
    (synopsis "ReScript application")
    (description "ReScript application - part of the RSR ecosystem.")
    (home-page "https://github.com/hyperpolymath/idaptiky")
    (license license:agpl3+)))

;; Return package for guix shell
idaptiky
