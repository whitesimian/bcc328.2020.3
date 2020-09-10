# Análise semântica de expressões let

- Nossa linguagem fonte apresenta a **expressão let**:
  - permite **declarações** de
    - **tipos**,
    - **variáveis** e
    - **funções**
  - com **escopo** restrito a uma **expressão**

- No exemplo:
  ``` tiger
  let
     var peso = 68.3
     var altura : real = 181.0 + 2.3
  in
    printint(peso * altura / 2)
  ```
  - são declaradas duas novas variáveis `peso` e `altura`
  - o escopo destas variáveis se restringe às declarações seguintes e ao corpo da expressão let

## Regras semânticas

- Analisar a lista de declarações em sequência, estendendo o ambiente (contexto) com os novos nomes.
- Analisar o corpo no ambiente estendido com os novos nomes
- Tipo resultante: o tipo do corpo.

## Alteração em `check_exp` para retornar o tipo inferido da expressão

- A função para analisar expressões foi alterada para:
  - além de **atualizar** o **tipo calculado** na referência contida na árvore sintática da expressão,
  - também **retornar** este tipo como resultado.

- Vai facilitar porque o tipo calculado poderá ser usado imediatamente, como resultado da função.

``` ocaml
let rec check_exp env (pos, (exp, tref)) =
  match exp with
  | A.BoolExp _   -> set tref T.BOOL
  | A.IntExp  _   -> set tref T.INT
  | A.RealExp _   -> set tref T.REAL
  | A.StringExp _ -> set tref T.STRING
  | _ -> Error.fatal "unimplemented"
```

- A função auxiliar `set`:
  - **atribui** um valor a uma referência cujo conteúdo é opcional
  - **retorna o valor atribuído**

``` ocaml
let set reference value =
   reference := Some value;
   value
```

## Implementação da análise semântica da expressão let

- Acrescentando uma alternativa em `check_exp` para o caso da expressão let.

``` ocaml
  let rec check_exp env (pos, (exp, tref)) =
    match exp with
    (* ... *)
    | A.LetExp (decs, body) -> check_exp_let env pos tref decs body
    (* ... *)
  ```

- Usando uma função auxiliar para implementar as regras semânticas da expressão let:
  ``` ocaml
  and check_exp_let env pos tref decs body =
    let env' = List.fold_left check_dec env decs in
    let tbody = check_exp env' body in
    set tref tbody
    ```
  - Melhor organização do código.
  - Evitar que o código da função `check_exp` fique muito grande.

- Foi usada a função `List.fold_left` da biblioteca do OCaml.
  - permite combinar os valores de uma lista
  - da esquerda para a direita
  - usando uma operação binária
  - exemplo:
    ``` ocaml
    let conta = List.fold_left (-) 500 [10; 80; 6; 48]
    ```
    cálculo que será feito:
    ``` ocaml
    (((500 - 10) - 80) - 6) - 48
    ```
    resultando em
    ```
    val conta : int = 356
    ```
  - exemplo aplicado no analisador semântico, supondo que `d1`, `d2` e `d3` são declarações:
    ``` ocaml
    List.fold_left check_dec env [ d1; d2; d3 ]
    ```
    cálculo que será feito:
    ``` ocaml
    check_deck (check_dec (check_dec env d1) d2) d3
                          ------------------
                          env'
               ---------------------------------
               env''
    -----------------------------------------------
    env'''
    ```
    resultando
    ```
    env'''
    ```

## Implementação da análise semântica de declarações

- A função `check_dec` faz a análise semântica de declarações
  - recebe como argumento
    - o ambiente (contexto)
    - a declaração (anotada com uma posição)
  - retorna o ambiente estendido
    - inclui o nome declarado na tabela de símbolos

- Como uma declaração pode ser de várias formas possíveis, selecionamos uma alternativa baseando-se na forma da declaração.
  ``` ocaml
  and check_dec env (pos, dec) =
    match dec with
    | _ -> Error.fatal "unimplemented"
  ```
  
- Nas próximas aulas entraremos em mais detalhes sobre regras semânticas para declarações.

## Testando

- Como ainda não implementamos nenhuma forma de declaração, ainda é possível testar o uso de declarações locais.

- Podemos contudo fazer uma expressão let sem nenhuma declaração:

```
let in 56.7

```
que produz a seguinte árvore sintática com os tipos anotados:

```
       ╭─────────╮
       │ LetExp  │
       │Type.REAL│
       ╰─────┬───╯
   ╭─────────┴──╮
╭──┴─╮ ╭────────┴────────╮
│Decs│ │RealExp 56.700000│
╰────╯ │    Type.REAL    │
       ╰─────────────────╯
```
