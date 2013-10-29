open Ocamlbuild_plugin;;

ocaml_lib ~extern:true "llvm";;
ocaml_lib ~extern:true "llvm_analysis";;

Options.ocaml_cflags := ["-I";"+llvm-3.3"];;
Options.ocaml_lflags := ["-I";"+llvm-3.3"];;

flag ["link"; "ocaml"; "g++"] (S[A"-cc"; A"g++"]);;
