(define-module (gnu packages guile-static)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages musl)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages make-bootstrap)
  #:use-module (gnu packages libunistring)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages base)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gawk)
  )

;; Derived from make-bootstrap.scm to provide 2.2 static/shared libs & interpreters

(define glibc-pie
  ;;  "enable flags in modified glibc for PIE without nscd, and with static NSS modules "
  (package
   (inherit glibc)
   (name "glibc-pie")
   (arguments
    (substitute-keyword-arguments (package-arguments glibc)
                                  ((#:configure-flags flags) `(cons* "--enable-static-pie" "--disable-nscd" "--disable-build-nscd" "--enable-static-nss" ,flags))
                                  ))))
(define glibc-instead-pie
  ;;  "replace all packages called glibc with glibc-pie"
  ;; rewrite based on string to match static outputs too
  (package-input-rewriting/spec `(("glibc" . ,(const glibc-pie) ))))

(define libunistring-pic
;;  "enable flags in libunistring for PIC"
  (package
   (inherit libunistring)
   (name "libunistring-pic")
   (arguments
    (substitute-keyword-arguments (package-arguments libunistring)
                                  ((#:make-flags flags '("CFLAGS=-fPIC")) ''("CFLAGS=-fPIC"))
                                  ((#:configure-flags flags '("CFLAGS=-fPIC")) ''("CFLAGS=-fPIC"))
     ))))

(define pic-instead
;;  "replace all packages called libunistring with libunistring-pic"
  ;; rewrite based on string to match static outputs too
  (package-input-rewriting/spec `(("libunistring" . ,(const libunistring-pic)))))


(define-public guile-stat
;;  "relocatable statically linked guile-2.2 with libs"
  (package
   (inherit guile-2.2)
   (name "guile-stat")

   (source (origin (inherit (package-source guile-2.2))
                   (patches (cons*
                             (search-patch "guile-relocatable.patch")
                             (search-patch "guile-2.2-default-utf8.patch")
                             (search-patch "guile-linux-syscalls.patch")
                             (origin-patches (package-source guile-2.2))))))

   (outputs (delete "debug" (package-outputs guile-2.2)))
   (inputs ;; build libs
    `(("libunistring:static" ,libunistring-pic "static") ;; regular libunistring will be rewrote
      ("glibc:static" ,glibc-pie "static")
      ("glibc" ,glibc-pie)
      ,@(package-inputs guile-2.2)))
   (native-inputs ;; build tools
    `(
      ("pkgconfig" ,pkg-config)
      ("coreutils" ,coreutils)
      ("tar" ,tar)
      ("xz" ,xz)
      ("gzip" ,gzip)
      ("bzip2" ,bzip2)
      ("patch" ,patch)
      ("sed" ,sed)
      ("grep" ,grep)
      ("gawk" ,gawk)
      ))
   (propagated-inputs ;; propagated need libs
    `(("libunistring:static" ,libunistring-pic "static")
      ("libunistring" ,libunistring-pic)
      ("glibc:static" ,glibc-pie "static")
      ("glibc" ,glibc-pie)
      ("libffi" ,libffi)
      ,@(package-propagated-inputs guile-2.2)))
   (arguments
    (substitute-keyword-arguments (package-arguments guile-2.2)
                                  ((#:strip-flags flags) ''()) ; remove strip flags
                                  ((#:configure-flags flags) ''("LDFLAGS=-ldl")) ; remove config flags
                                  ((#:phases '%standard-phases) ; remove static phase
                                   `(modify-phases ,phases
                                                   (delete 'pre-configure)
                                                   (add-before 'configure 'static-guile
                                                               (lambda _
                                                                 (substitute* "libguile/Makefile.in"
                                                                              ;; Create a statically-linked `guile'
                                                                              ;; executable.
                                                                              (("^guile_LDFLAGS =")
                                                                               "guile_LDFLAGS = -all-static")

                                                                              ;; Add `-ldl' *after* libguile-2.2.la.
                                                                              (("^guile_LDADD =(.*)$" _ ldadd)
                                                                               (string-append "guile_LDADD = " (string-trim-right ldadd) " -ldl\n")))))
                                                   ))


                                  ((#:tests? _ #f)
                                   ;; There are uses of `dynamic-link' in
                                   ;; {foreign,coverage}.test that don't fly here.
                                   #f)
                                  ;;((#:parallel-build? _ #f)
                                   ;; Work around the fact that the Guile build system is
                                   ;; not deterministic when parallel-build is enabled.
                                  ;;#f)
                                  ))))



;; rewrite the glibc/libunistring flags of any dependencies of guile
;; package definition for installing
(glibc-instead-pie (pic-instead guile-stat))
