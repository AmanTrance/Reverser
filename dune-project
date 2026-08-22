(lang dune 3.21)

(name reverse_tcp)

(generate_opam_files true)

(source
 (github AmanTrance/Reverser))

(authors "Aman Kansal aman.hobo@gmail.com")

(license LICENSE)

(package
 (name reverse_tcp)
 (synopsis "Reverse SSH Based on Source IP")
 (description "Reverse SSH Based on Source IP")
 (depends 
   base
   lwt
   toml)
 (tags
  ("add topics" "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
