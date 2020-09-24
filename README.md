# BCC328: Construção de Compiladores I

[![Build Status](https://travis-ci.org/romildo/bcc328.2020.3.svg?branch=master)](https://travis-ci.org/romildo/bcc328.2020.3)

Writing a compiler for a toy language.


## Preparing the environment for the project (Ubuntu >= 18.04)

Installing some development languages, libraries and tools

- Processador de macro de uso geral que é usado por vários componentes do OCaml
  ```
  $ sudo apt install m4
  ```

- Utilitário que usa a biblioteca readline para permitir a edição da entrada do teclado para qualquer comando
  ```
  $ sudo apt install rlwrap
  ```

- Opam (OCaml package manager)
  Install directly from the internet. Alternatively can install using the operating system package manager.
  ```
  $ sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)
  ```

  Inicializa o estado interno do opam no diretório ~/.opam
  ```
  $ opam init --bare
  ```

- Instala compilador de OCaml
  ```
  $ opam switch create 4.11.1
  ```

  Aplica as alterações para o shell atual
  ```
  $ eval $(opam env)
  ```

- Sistema de construção para OCaml
  ```
  $ opam install dune
  ```

- Serviço de editor que fornece recursos IDE modernos para o OCaml
  ```
  $ opam install merlin
  ```

- Extensão de sintaxe que permite extrair tipos ou assinaturas de outros arquivos de interface compilados
  ```
  $ opam install ppx_import
  ```

- Extensão de sintaxe que facilita geração de código baseada em tipos em OCaml
  ```
  $ opam install ppx_deriving
  ```

- Extensão de sintaxe para escrita de testes em OCaml
  ```
  $ opam install ppx_expect
  ```

- Biblioteca unicode para OCaml
  ```
  $ opam install camomile
  ```

- Gerador de analisador sintático para OCaml
  ```
  $ opam install menhir
  ```

- Obtém a textual interface file (.mli) from the compiled interface (.cmi)
  ```
  $ opam install ocaml-print-intf
  ```

- Implementação do servidor de protocolo de linguagem para OCaml
  ```
  $ opam pin add ocaml-lsp-server https://github.com/ocaml/ocaml-lsp.git
  ```

- Ambiente interativo alternativo para OCaml
  ```
  $ opam install utop
  ```

- Install LLVM and CLang
  - CLang (C/C++ compiler)
    ```
    $ sudo apt install clang
    ```
  - Dependencies for building OCaml LLVM bindings
    ```
    $ sudo apt install cmake m4 python2
    ```
  - LLVM bindings for OCaml
    ```
    $ opam install llvm
    ```

## How to clean uneeded files

```
$ dune clean
```

## How to compile

```
$ dune build src/bin/driver.exe
```

## How to run the driver

```
$ dune exec src/bin/driver.exe
```

## How to run expect tests

```
$ dune runtest
```

## How to promote outputs of the expect tests

```
$ dune promote
```

## References

[Recipes for OCamlLex](https://medium.com/@huund/recipes-for-ocamllex-bb4efa0afe53)

