# Análise semântica: variável e atribuição

## Expressão variável

- Uma **variável** representa uma célula na memória do computador.

- Pode ser de várias formas:
  - **simples**: identificador
  - parte de uma estrutura de dados, como por exemplo
    - **campo de registro**
    - **componente de um _array_**

- A regra semântica específica depende da forma da variável.

- O tipo da expressão variável é o tipo da variável.

- Nesta aula: análise de variável simples.

## Variável simples

- A variável simples é um identificador (nome da variável)

- Exemplo:
  ``` ocaml
  altura
  ```

- Regra semântica:
  - pesquisar o nome da variável na tabela de símbolos de variáveis e funções do ambiente
    - não encontrada: reportar erro de variável indefinida
    - encontrada:
      - verificar se o nome está associado com:
        - função: reportar erro
        - variável: o tipo da variável é o tipo encontrado na tabela

## Expressão de atribuição

- A **expressão de atribuição** tem:
  - uma variável e
  - uma subexpressão.

- Exemplo:
  ``` ocaml
  area := 56.8
  ```
- Regra semântica:
  - fazer a análise semântica da variável, obtendo o seu tipo
  - fazer a análise semântica da expressão, obtendo o seu tipo
  - verificar se o tipo da expressão é compatível com o tipo da variável:
    - não: reportar erro de tipo
  - o tipo da expressão de atribuição é `void`

## Atividades

### Análise semântica de expressão variável

- Acrescentar a análise semântica da expressão variável em `check_exp`:
  - incluir a alternativa para o construtor `VarExp` no `match`
  - determinar o tipo da expressão variável:
    - chamar uma função auxiliar `check_var`, para analisar a variável, obtendo o seu tipo
  ``` ocaml
  let rec check_exp env (pos, (exp, tref)) =
    match exp with
    (* ... *)
    | A.VarExp v -> (* ... check_var env x ... *)
    (* ... *)
  ```

- Definir uma nova função `check_var` para fazer análise semântica da variável:
  - recebe o ambiente e a variável a ser analisada
  - faz a análise semântica da variável
    - usar uma expressão `match` para selecionar o caso de acordo com a forma da variável
  - retorna o tipo da variável
  - seguir o mesmo esquema de `check_exp` e `check_dec`.

### Análise semântica de variável simples

- Acrescentar a análise semânttica de variável simples em `check_var`, de acordo com a regra semântica correspondente.

### Análise semântica de expressão de atribuição

- Acrescentar a análise semânttica de atribuição em `check_exp`, de acordo com a regra semântica correspondente.

### Realização das atividades desta aula

- **Todos** os alunos **devem** realizar estas atividades **individualmente**.

- Cada aluno deverá preparar um **vídeo** mostrando e **explicando** o seu código
  > incluindo a **demonstração** com **exemplos**.

- Os vídeos devem ser submetidos no **moodle**, até as 23:59 horas do dia 14/09 (segunda-feira).

- Cada aluno deve submeter um _pull request_ (no **repositório** da disciplina) com as implementações solicitadas **no dia 15/09** (terça-feira).
  > nem antes e nem depois deste dia
