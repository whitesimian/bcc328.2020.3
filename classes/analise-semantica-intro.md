# Análise Semântica: Introdução

- Objetivos:
  - completar a análise do programa fonte, checando as regras restantes, como por exemplo:
    - checagem de tipo
    - checagem do escopo dos identificadores
    - outros detalhes
  
- Entrada:
  - árvore sintática

- Saída:
  - árvore sintática com anotações adicionais calculadas pelo analisador
    - tipos de expressões, variáveis e funções

- Será necessário definir:
  - **representação interna para os tipos** da linguagem fonte
  - **tabelas de símbolos** para associar informações relevantes aos identificadores
    - **tipo**: a definição da estrutura do tipo
    - **variável**: o tipo da variável
    - **função**:
      - tipos dos parâmetros formais
      - tipo do resultado
  - **ambiente** (ou contexto) contendo os identificadores conhecidos e outras informações relevantes
    - ambiente de tipos
    - ambiente de variáveis e funções
    - *flag* indicando se está sendo analisada uma expressão de repetição
      - importante para analisar a expressão `break`
      
- Será necessário adaptar os tipos usados para representação das árvores sintáticas
  - adicionar o tipo inferido para:
    - expessões
    - variáveis
    - funções

## Representação interna de tipos ##

- O compilador precisa verificar a compatibilidade de tipos nas consttruções usadas no programa fonte.

- Para tanto é necessária uma representação interna dos tipos da linguagem fonte.

- Isto é feito no módulo `Type`.

- Vamos começar com uma implementação parcial, que os participantes devem completar.

### Os tipos básicos da linguagem fonte ###

- `bool`
- `int`
- `real`
- `string`
- `void`

### O tipo `void` ###

- Usado para expressões que são executadas apenas pelos efeitos que produz (como atribuição, e saída de dados).
- Não tem um valor _interessante_.
- É o tipo da expressão sequência vazia `()`.

### Definição do tipo `Type.ty` ###

- Descreve como representar as diferentes formas para os tipos da lingugem fonte.

``` ocaml
type ty =
  | VOID
  | BOOL
[@@deriving show]
```

### Árvore genérica a partir do tipo ###

- Para facilitar a visualização da representação interna dos tipos, pode-se convertê-los para uma árvore generica, que depois pode ser convertida para string.

``` ocaml
(* general tree from internal type representation *)
let tree_of = function
  | VOID -> Tree.mkt "VOID" []
  | BOOL -> Tree.mkt "BOOL" []
```

### Compatibilidade de tipo ###

- Para determinar se um determinado tipo é compatível com outro tipo:

``` ocaml
let coerceable a b =
  match a, b with
  | VOID , VOID -> true
  | BOOL , BOOL -> true
  | _           -> false
```

- Dois tipos básicos são compatíveis se eles forem idênticos.

## Adaptando os tipos das árvores sintáticas

- O analisador semântico poderia reconstruir as árvores sintáticas para anexar as informações de tipo.

- Isto pode tornar-se trabalhoso.

- Alternativa: adaptar as representações de árvore sintática já existentes para incluir o tipo inferido.

### Alterações no módulo `Absyn`

- `'a typed`: um tipo polimórfico para **anotar uma árvore sintática com um tipo interno**:
  ``` ocaml
  type 'a typed = 'a * Type.ty option ref
  [@@deriving show]
  ```
  - Observe que é usado um **par** contendo:
    - a árvore sintática básica 
    - uma **referência** para um **tipo opcional**
  - O conteúdo da referência é opcional porque quando a árvore sintática é construída (pelo analisador sintático), o tipo ainda não é conhecido.
    - usa-se a constante `None` neste caso
  - A referência poderá ser atualizada durante a análise semântica:
    - quando o tipo for determinado, basta atribuir `Some t` à referência, onde `t` é o tipo encontrado
    
- A nova função auxiliar `dummyt` anota uma árvore sintática com `None`, útil quando o tipo ainda não é conhecido.
  ``` ocaml
  let dummyt ast = (ast, ref None)
  ```

- `exp`: é agora o tipo das expressões com anotação de tipo.
  ``` ocaml
  type exp = exp_basic typed
  [@@deriving show]
  ```

- `exp_basic`: antes chamado apenas de `exp`, é o tipo básico das expressões sem anotação de tipo.
  ``` ocaml
  and exp_basic =
    | BoolExp       of bool
    | IntExp        of int
    | StringExp     of string
    | RealExp       of float
    | NegativeExp   of lexp
    | BinaryExp     of (lexp * binary_op * lexp)
    | IfExp         of (lexp * lexp * lexp option)
    | WhileExp      of (lexp * lexp)
    | BreakExp
    | ExpSeq        of lexp list
    | CallExp       of symbol * lexp list
    | VarExp        of lvar
    | LetExp        of ldec list * lexp
    [@@deriving show]
  ```
  
- `dec` foi adaptado para anotar o tipo interno da variável declarada:
  ``` ocaml
  and dec =
    | VarDec of vardec typed
    [@@deriving show]

  and vardec = Symbol.symbol * Symbol.symbol option * lexp
    [@@deriving show]
  ```

### Adaptando o módulo `Absyntree`

- A nova função auxiliar `tree_of_typed`:
  - converte uma árvore sintática anotada com um tipo para uma árvore generalizada
  - parâmetros:
    - a função que é usada para converta a árvore sintatica básicaa
    - a árvore sintática anotada com o tipo
  - será anexada uma nova linha no nó da árvore para inserir a informação do tipo, se ela estiver presente

- As definições das funções foram adaptadas às modificações dos tipos em `Absyn`.
  
- Exemplo:
  ``` ocaml
  let rec tree_of_exp exp =
    tree_of_typed tree_of_exp_basic exp

  and tree_of_exp_basic exp =
    match exp with
    | BoolExp x                 -> mktr (sprintf "BoolExp %b" x) []
  (* ... *)
  ```

### Adaptando o módulo `Parser`

- As regras de produção na gramática do analisador sintático devem ser adaptadas para refletir as mudanças nos tips das árvores sintáticas.

- Para facilitar a escrita das ações semânticas, foi definida uma função auxiliar `(%)` no cabeçalho da gramática:
  - notação de operador binário
  - parâmetros:
    - localização
    - árvore sintática básica
  ``` ocaml
  %{
      let (%) loc ast = (loc, dummyt ast)
  %}
  ```
  - exemplo:
  ``` ocaml
  exp:
  | x=LITBOOL                               {$loc % BoolExp x}
  ```

## O módulo de análise semântica ##

- No módulo `Semantic` é definia a função de análise semântica.

- A função `Semantic.semantic`:
  - recebe a árvore sintática de um programa
  - tem o **efeito** de alterar as referências atualizando os tipos inferidos durante a análise semântica

- A função auxiliar `Semantic.check_exp` será usada para analisar expessões.

- Outras funções auxiliares serão definidas para completar o analisador semântico.

``` ocaml
module A = Absyn
module T = Type

let rec check_exp (pos, (exp, ty)) =
  match exp with
  | A.BoolExp _ -> ty := Some T.BOOL

  | _ -> Error.fatal "unimplemented"

let semantic program =
  check_exp program
```

## Chamando o analisador semântico no driver

- Acrescentamos no drive a chamada da função `Semantic.semantic` para realizar a análise semântica.
- Exibimos o tipo encontrado.

``` ocaml
let main () =
  (* ... *)
    let ast = Parser.program Lexer.token lexbuf in
    (* ... *)
    Semantic.semantic ast;
    match ast with
    | (_, (_, { contents = Some ty })) ->    (* este padrão permite selecionar o tipo dentro da estrutura de dados *)
       print_endline (Type.show_ty ty)
    | _ ->
       Error.fatal "cannot determine type of program"
  (* ... *)
```

## Testando o compilador

```
$ dune exec src/driver/driver.exe
false
Abstract syntax tree:
============================================================
╭─────────────╮
│BoolExp false│
╰─────────────╯
Semantic analysis:
============================================================
Type.BOOL

```

## Próximas aulas

- Estudar alguns detalhes sobre como fazer análise semântica:
  - Tabela de símbolos
  - Ambiente (contexto)
  - Discussão da análise de algumas construções

## Atividades ##

- Completar o módulo `Type` com os demais tipos básicos.
- Implementar a **análise semântica de algumas construções simples** que não involvam variáveis, funções ou declarações.
- Anotar no arquivo `TODO.ml`
