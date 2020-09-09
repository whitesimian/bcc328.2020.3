# Análise semântica: contexto

- Ao analisar uma frase dentro de um programa fonte pode ser necessário obter informações sobre o **contexto** em que a frase aparece:
  - Quais **nomes** são conhecidos e podem ser usados?
    - tipos
    - variáveis
    - funções
  - O que sabemos sobre estes nomes?
  - Existem outras informações relevantes?

- Como representar o contexto no compilador?

## Tabelas de símbolos

- **Tabelas de símbolos** são **mapeamentos** (ou **dicionários**) indexados por símbolos (nomes dados a entidades, como tipos, variáveis e funções).

- Associado a cada símbolo há informações adicionais, como por exemplo:
  - estrutura do tipo
  - tipo da variável
  - assinatura da função

- Suporta as operações:
  - inserir um novo símbolo
  - consultar um símbolo
  - remover símbolos

- Podem ser implementadas de várias maneiras:
  - **tabela funcional**: estrutura de dados imutável
    - as operações de inserção ou remoção criam uma nova tabela, preservando a tabela original
    - adequada para um estilo de programão declarativo, como aquele praticado com linguagens funcionais puras (Haskell, por exemplo)
    - em OCaml podemos usar o módulo `Map`
  - **tabela imperativa**: estrura de dados mutável
    - as operações de inserção ou remoção alteram a tabela original
    - adequada para programação imperativa, onde são permitidos efeitos (como atribuição, por exemplo)
    - em OCaml podemos usar o módulo `Hashtbl`

- Leituras:
  - Modern Compiler Implementation in ML, do Andrew Appel: seção 5.1 (Symbol tables)
  - [Compiler design and implementation in OCaml with LLVM framework](https://www.theseus.fi/handle/10024/166119): seção 4.2 (Symbol table)

### Módulo `Symbol`

- Tipo `symbol` para representar nomes de uma forma eficiente no compilador.
  
- Tipo `'a table` para representar tabelas de símbolos com valores do tipo `'a` associados aos símbolos.
  - Internamente usa-se o módulo `Map` do OCaml para mapeamentos (estrutura declarativa)
  
- A variavel `empty`, associada à tabela de símbolos vazia.
  
- A função `enter`, que recebe um símbolo, um valor, e uma tabela de símbolos, e retorna uma nova tabela obtida pela inserção do símbolo associado ao valor na tabela dada.
  
- A função `look`, que recebe um símbolo e uma tabela de símbolos, e pesquisa o símbolo na tabela retornando um valor opcional contendo a informação associada ao símbolo quando o símbolo for encontrado.

- A estrutura de dados que implementa a tabela de símbolos é funcional (declarativa):
  - `enter` não altera a tabela, mas cria uma nova
  - não há necessidade de uma função para remover itens da tabela

- Quando o compilador estiver analisando:
  - uma **declaração**: o nome declarado deve ser inserido em uma tabela de símbolos, junto com informações relevantes coletadas na declaração
  - o **uso** de um nome: o nome usado deve ser pesquisado na tabela de símbolos para obter informações sobre o nome

## O ambiente

- O ambiente (ou contexto) contém as informações conhecidas e que podem ser relevantes no contexto em que uma frase é analisada.

- Em nossa implementação, no módulo `Env` temos:
  - tabela de símbolos de tipos
  - tabela de símbolos de variáveis e funções
  - flag indicativa de expressão de repetição

- Observe que na linguagem fonte do nosso projeto temos dois espaços de nomes:
  - para tipos
  - para variáveis e funções

- Para distinguir entre variáveis e funções, usaremos o tipo `entry` na tabela de símbolos:
  ``` ocaml
  type entry =
    | VarEntry of Type.ty
    | FunEntry of Type.ty list * Type.ty
  [@@deriving show]
  ```
  - `VarEntry` corresponde a uma variavel e tem um campo para o tipo da variável
  - `FunEntry` corresondente a uma função, e tem dois campos que permitem representar a assinatura da função:
    - lista dos tipos dos parâmetros formais
    - tipo do resultado

- O ambiente inicial (variável `initial`) contém:
  - os tipos pré-definidos
  - as variáveis e funções pré-definidas
  - a flag de que não está dentro de uma expressão de repetição

- Na versão atual do projeto,
  - apenas os tipos pré-definidos `void` e `bool`, e 
  - as funções `printbool` e `not`

  constam do ambiente.

-  Os demais nomes pré-definidos devem ser acrescentados como atividades.

## Usando o ambiente na análise semântica

- As funções do analisador semântico devem ser modificadas, acrescentando o ambiente no qual uma frase é analisada.
  ``` ocaml
  module A = Absyn
  module T = Type
  
  type entry = [%import: Env.entry]
  type env = [%import: Env.env]
  
  let rec check_exp {venv; tenv; inloop} (pos, (exp, ty)) =
    match exp with
    | A.BoolExp _ -> ty := Some T.BOOL
    | A.IntExp  _ -> ty := Some T.INT
  
    | _ -> Error.fatal "unimplemented"
  
  let semantic program =
    check_exp Env.initial program
  ```

- Nas próximas aulas vamos estudar a análise semântica de algumas construções que dependem do ambiente.