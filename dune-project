(lang dune 3.17)

(name mdexp-actions)

(generate_opam_files)

(license "MIT")

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin <opensource@mbarbin.org>")

(source
 (github mbarbin/mdexp-actions))

(implicit_transitive_deps false)

(package
 (name mdexp-actions)
 (synopsis "Reusable GitHub Actions for the mdexp literate programming tool")
 (depends
  (ocaml
   (>= 5.2))
  (ocamlformat
   (= 0.28.1))
  (ppx_expect
   (and
    (>= v0.17)
    (< v0.18)))
  (ppxlib
   (>= 0.33))
  (print-table
   (>= 0.1.0))))
