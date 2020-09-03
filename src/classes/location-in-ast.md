# Associando uma localização a uma árvore sintática

A **localaização** de uma frase no código fonte é necessária para **reportagem de erros**.

## Versão do compilador

Esta aula baseia-a na versão [v0.2](https://github.com/romildo/bcc328.2020.3/releases/tag/v0.2) do compilador.

## Anotando a localização

- Representação: **par** (produto de dois tipos)
  1. **localização** da construção no código fonte
  2. **árvore sintática** que representa a construção

- Usamos um **tipo parametrizado** que permite a anotação da localização de um valor de qualquer tipo
  ``` ocaml
  (* no módulo Location *)
  type `a loc = t * `a
  ```
  - `Location.loc` é um construtor de tipo que precisa de um parâmetro de tipo
  - A variável de tipo `` `a`` representa um tipo qualquer do OCaml
  - `Location.t` é o tipo de uma localização

- Exemplos:
  ``` ocaml
  Exp.exp Location.loc        (* tipo das expressões anotadas com uma localização *)
  Symbol.symbol Location.loc  (* tipo dos símbolos anotados com uma localização *)
  ```

- A maioria dos componentes internos de uma árvore sintática deverão ter sua localização anotada

- Alteraçções no módulo `Absyn`:
  - Até agora temos:
    ``` ocaml
    type exp =
        | BoolExp   of bool
        | IntExp    of int
        | WhileExp  of (exp * exp)
        | BreakExp
    ```
  - Vamos mudar para:
    ``` ocaml
    type exp =
        | BoolExp   of bool
        | IntExp    of int
        | WhileExp  of (lexp * lexp)  (* observe o uso de lexp ao invés de exp *)
        | BreakExp

    and lexp = exp Location.loc     (* observe a declaração do tipo lexp *)
    ```
  - `lexp` é o tipo das expressões anotadas com uma localização.
  - Observe que `exp` e `lexp` são tipos **mutuamente recursivos** e devem ser declarados simultaneamente no OCaml:
    - uma única declaração `type`
    - sepando os tipos com `and`

## Adaptando a gramática

- O valor semântico dos símbolos terminais pode conter as informações de localização das construções.

- Assim vamos usar `Absyn.lexp` ao invés de `Absyn.Exp` para o tipo associado aos símbolos não-terminais de expressões e programas.
  - Antes:
    ``` ocaml
    %start <Absyn.exp> program
    ```
  - Depois:
    ``` ocaml
    %start <Absyn.lexp> program
    ```

- Ao construir a árvore sintática, precisamos obter a localização da frase no programa fonte.

- O menhir oferece algumas [palavra-chaves](http://gallium.inria.fr/~fpottier/menhir/manual.html#sec%3Apositions) que dão acesso a informações de localização:
  - `%startpos` é a posição do início do primeiro símbolo no lado direito da regra de produção.
  - `%endpos` é a posição do final do último símbolo no lado direito da regra de produção.
  - `$loc` é o par `($startpos, $endpos)`

- Então podemos obter uma árvore sintática anotada com sua localização usando:
  ``` ocaml
  lhs: rhs { ($loc, ast) }
  ```
  sendo:
  - `lhs` o lado esquerda regra de produção
  - `rhs` o lado diretiro da regra de produção
  - `ast` a árvore sintática desejada

- **Tuplas** em OCaml podem ser escritas sem parênteses
  ``` ocaml
  let a = 2, 3, "Hello"
  let b = (2, 3, "Hello")
  ```
  Neste exemplo tanto `a` como `b` são triplas formadas pelos valores `2`, `3` e `"Hello"`.

- Assim não vamos escrever os parênteses para formar os pares nas ações semânticas, simplificando a notação:
  ``` ocaml
  lhs: rhs { $loc, ast }
  ```

- As regras de produção da gramática ficam então assim:
  ``` ocaml
  program:
  | e=exp EOF            {e}

  exp:
  | x=LITBOOL            {$loc, BoolExp x}
  | x=LITINT             {$loc, IntExp x}
  | x=LITREAL            {$loc, RealExp x}
  | WHILE t=exp DO b=exp {$loc, WhileExp (t, b)}
  | BREAK                {$loc, BreakExp}
  ```

## Adaptando o _driver_

- Como agora o parser retorna um valor do tipo `Absyn.exp`, é necessário usar o função correta para conversão para string:
  ``` ocaml
    let ast = Parser.program Lexer.token lexbuf in
    Format.printf "%s\n" (Absyn.show_lexp ast)
  ```
  Oserve que `show_exp` foi substituído por `show_lexp`.

## Testando o compilador

```
$ dune build src/driver/driver.exe
[...]

$ dune exec src/driver/driver.exe
while true do break
(:1.0-1.19,
 (Absyn.WhileExp
    ((:1.6-1.10, (Absyn.BoolExp true)), (:1.14-1.19, Absyn.BreakExp))))
```