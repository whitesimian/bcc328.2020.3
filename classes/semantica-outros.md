# Análise semântica: operadores binários

- Uma **operação binária** é formada por:
  - operador
  - operando da esquerda (expessão)
  - operando da direita (expessão)
  
- Exemplos:
  ```
  20 + 33
  5*(a-1) > b^(1/2)
  resposta = "sim"
  44/0.5
  ```

- Os operadores são **sobrecarregados**: funcionam com vários tipos diferentes.

- **Regras semânticas**:
  - analisa-se cada um dos operandos, obtendo-se o tipo de cada um deles
  - os operandos devem ser de tipos compatíveis (mesmo tipo)
    - exceção:
      - operandos dos tipos inteiro e real podem ser usados na mesma operação
      - o operando do tipo inteiro é convertido implicitamente para o tipo real
  - regras específicas para cada operador:
    - operadores aritméticos:
      - operandos inteiros: resultado inteiro
      - operandos reais: resultado real
      - operando inteiro e real: resultado real
      - qualquer outro caso: erro de tipo
    - operadores igual e diferente:
      - operandos podem ser de qualquer tipo
      - resultado: booleano
    - operadores relacionais:
      - operandos devem ser inteiros, reais ou strings
      - resultado: booleano
    - operadores lógicos:
      - operandos devem ser booleanos
      - resultado: booleano

# Análise semântica: operador de negação (simétrico)

- A expressão de negação (simétrico aditivo) é formada por:
  - uma subexpressão
  
- Exemplos:
  ```
  - alfa
  -44
  - (x - a)
  ```

- **Regras semânticas**:
  - analisa-se a subexpressão, obtendo-se o seu tipo
  - o tipo da subexpressão deve ser inteiro ou real
  - o resultado é o do mesmo tipo da subexpressão
  
# Análise semântica: expressão sequência

- Uma expressão sequência é formada por uma lista de subexpressões.

- Exemplos:
  ```
  (x := 2*x-1; printint(x^2); x/3)
  (a; b; c)
  ()
  ```

- **Regras semânticas**:
  - Faz-se a análise semântica de cada subexpressão.
  - O tipo do resultado é o tipo da última subexpressão, se houver.
  - Caso contrário o tipo do resultado é void.
  
# Análise semântica: expressão condicional

- Uma expressão condicional é formada por três subexpressões
  - teste
  - alternativa _then_
  - alternativa _else_ (opcional)

- Exemplos:
  ```
  if x > 0 then "abc" else "xyz"
  if nao_encontrado then primeiro := -1
  ```

- **Regras semânticas**:
  - Faz-se a análise semântica do teste, que deve ser booleano.
  - Faz-se a análise semântica da alternativa _then_
  - Se houver a alternativa _else_
    - faz-se a sua análise semântica
    - os tipos das duas alternativas devem ser compatíveis
    - o tipo do resultado é o tipo das alternativas
  - Caso contrário:
    - o tipo do resultado é void
  
# Análise semântica: expressão de repetição

- Uma expressão de repetição é formada por duas subexpressões
  - teste
  - corpo

- Exemplos:
  ```
  while continuar do readint()
  while x < 20 do (printint(x); x := x - 1)
  ```

- **Regras semânticas**:
  - Faz-se a análise semântica do teste, que deve ser booleano.
  - Faz-se a análise semântica do corpo, em um ambiente estendido para sinalizar a compilação de expressão condicional.
  - O tipo do resultado é void.
  
# Análise semântica: expressão break

- A expressão break não tem componentes.

- Exemplos:
  ```
  while true do (
    x := readint();
    if x >= 0 then
      break
  )
  ```

- **Regras semânticas**:
  - Deve ocorrer no corpo de uma expressão de repetição.
  - Se aparecer no corpo de uma função não pode se referir a uma expressão de repetição externa à função.
  - O tipo do resultado é void.


# Atividades

- Implementar as regras de análise semântica explanadas nesta aula.

- **Todos** os alunos **devem** realizar estas atividades **individualmente**.

- Cada aluno deve submeter um _pull request_ (no **repositório** da disciplina) com as implementações solicitadas **até o dia 18/09** (sexta-feira).
