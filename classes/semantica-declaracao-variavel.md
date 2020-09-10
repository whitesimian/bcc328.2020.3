# Análise semântica: declaração de variáveis

- Nossa linguagem fonte permite **declarações locais** de variáveis como parte de uma **expressão let**.

- No exemplo:
  ```
  let
     var peso = 68.3
     var altura : real = 181.0 + 2.3
  in
    printint(peso * altura / 2)
  ```
  são declaradas duas novas variáveis `peso` e `altura`

- A indicação do tipo da variável é opcional.

- A inicialização da variável é obrigatória

## Regras semânticas

- A **expressão de inicialização** deve ser analisada semanticamente, determinando o seu tipo.

- Se o nome do **tipo da variável** tiver sido indicado:
  - ele deve ser pesquisado na **tabela de símbolos**
    - se não for encontrado, deve ser reportado um **erro**
    - se for encontrado,
      - a sua representação interna estará disponível
      - o tipo da **expressão de inicialização** deve ser compatível com o tipo da variável
        - incompatível: reportar **erro**
        - compatível: o tipo da variável é aquele obtido da tabela de símbolos

- Se o **tipo da variável** não tiver sido indicado:
  - o tipo da variável é o mesmo tipo da expressão de inicialização

- A variável e seu tipo deve ser adicionada à **tabela de variáveis e funções**.

## Checagem de declaração de variavel

- A função `check_var_dec` faz a análise semântica da declaração de variável.

- Recebe:
  - o ambiente
  - a posição no código fonte
  - os dados da declaração de variável
    - árvore sintática da declaração de variável:
      ``` ocaml
      and dec =
        | VarDec of vardec typed
        (* ... *)

      and vardec = Symbol.symbol * Symbol.symbol option * lexp
      ```

- Aplica as regras semânticas explicadas no início da aula.

- Retorna um ambiente estendido com a inclusão do nome da variável e do seu tipo.

  ``` ocaml
  and check_dec_var env pos ((name, type_opt, init), tref) =
    let tinit = check_exp env init in
    let tvar =
      match type_opt with
      | Some tname ->
         let t = tylook env.tenv tname pos in
         compatible tinit t (loc init);
         t
      | None -> tinit
    in
    ignore (set tref tvar);
    let venv' = S.enter name (VarEntry tvar) env.venv in
    {env with venv = venv'}
  ```

- A função `check_var_dec_` é usada em `check_dec`:

  ``` ocaml
  and check_dec env (pos, dec) =
    match dec with
    (* ... *)
    | A.VarDec x -> check_dec_var env pos x
    (* ... *)
  ```

## Funções auxiliares

### Obter a localização de uma árvore sintática no código fonte

``` ocaml
let loc = Location.loc
```

### Reportar erros


``` ocaml
let undefined loc category id =
  Error.error loc "undefined %s %s" category (S.name id)

let misdefined loc category id =
  Error.error loc "%s is not a %s" (S.name id) category

let type_mismatch loc expected found =
  Error.error loc "type mismatch: expected %s, found %s" (T.show_ty expected) (T.show_ty found)
```

### Pesquisar nomes em tabelas de símbolos

``` ocaml
let look env category id pos =
  match S.look id env with
  | Some x -> x
  | None -> undefined pos category id

let tylook tenv id pos =
  look tenv "type" id pos

let varlook venv id pos =
  match look venv "variable" id pos with
  | VarEntry t -> t
  | FunEntry _ -> misdefined pos "variable" id

let funlook venv id pos =
  match look venv "function" id pos with
  | VarEntry _ -> misdefined pos "function" id
  | FunEntry (params, result) -> (params, result)
```

### Checar compatibilidade de tipos

``` ocaml
let compatible ty1 ty2 pos =
  if not (T.coerceable ty1 ty2) then
    type_mismatch pos ty2 ty1
```

## Testando

- Já podemos testar expressões let contendo declarações de variáveis, porém não podemos testar o uso dessas variáveis.
  ```
  let
     var nome = "laura"
     var idade: int = 21
  in
     false
  ```
  que produz a seguinte árvore sintática com os tipos anotados:

  ```
                              ╭─────────╮
                              │ LetExp  │
                              │Type.BOOL│
                              ╰─────┬───╯
                            ╭───────┴─────────────────────────╮
                         ╭──┴─╮                        ╭──────┴──────╮
                         │Decs│                        │BoolExp false│
                         ╰──┬─╯                        │  Type.BOOL  │
               ╭────────────┴────────────╮             ╰─────────────╯
        ╭──────┴────╮               ╭────┴───╮
        │  VarDec   │               │ VarDec │
        │Type.STRING│               │Type.INT│
        ╰──────┬────╯               ╰────┬───╯
     ╭───┬─────┴───╮            ╭──────┬─┴──────╮
  ╭──┴─╮ ┴ ╭───────┴───────╮ ╭──┴──╮ ╭─┴─╮ ╭────┴────╮
  │nome│   │StringExp laura│ │idade│ │int│ │IntExp 21│
  ╰────╯   │  Type.STRING  │ ╰─────╯ ╰───╯ │Type.INT │
           ╰───────────────╯               ╰─────────╯
  ```

- Ilustrando erro de tipo:
  ```
  let
     var peso: real = true
  in
     88
  ```
  que produz a seguinte árvore sintática com os tipos anotados:

  ```
  :2.20-2.24 error: type mismatch: expected Type.REAL, found Type.BOOL
  ```

## Próximas aulas

- Estudaremos como fazer a análise semântica de:
  - variável simples, que permitirá usar uma variável simples no programa.

- Poderemos então  testar o nosso compilador com o uso de variáveis locais.
