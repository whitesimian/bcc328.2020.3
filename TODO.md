# TODO

Here are most of the topics needed in the compiler impletantion for this project.

Check the topics as they are implemented, anotating who is the implementer, in the pull request implementing them.

Significant contributions to the implementation will be used to assign a grade to students at the end of the course.

- Lexical rules
   - [x] spaces (Romildo)
   - [x] line comments (Koda - PR#40)
   - [x] block comments (RodrigoJuliano - PR#18)
   - [x] boolean literals (Romildo)
   - [x] integer literals (Romildo)
   - [x] real literals (Fabricio - PR#16)
   - [x] string literals (Gabriel - PR #14)
   - [x] operators (Koda - PR #26)
   - [x] punctuation symbols (Arilton - PR#34, Artur-PR#15)
   - [x] keyworkds (Felipe - PR#36)
   - [x] identifiers (Felipe - PR#36)

- Lexer tests
   - [x] spaces
   - [x] line comments
   - [x] block comments
   - [x] boolean literals
   - [x] integer literals
   - [x] real literals (Fabricio - PR#16)
   - [ ] string literals
   - [x] operators (Koda - PR #26)
   - [x] punctuation symbols
   - [x] keyworkds
   - [x] identifiers (Felipe)

- Abstract syntax trees (representation)
   - Expressions
     - [x] boolean constant
     - [x] integer constant
     - [x] real constant (Romildo)
     - [x] string constant (Gabriel - PR #14)
     - [ ] variable
     - [x] unary operation  (Fabricio - PR #53)
     - [x] binary operation  (Fabricio - PR #53)
     - [ ] assignment
     - [x] function call   (Artur - PR #57)
     - [x] if (Koda - PR #61)
     - [x] while
     - [x] break (Romildo)
     - [x] let (Felipe)
     - [x] sequence (RodrigoJuliano #PR60)
   - Variables
     - [x] simple (Felipe - PR #55)
   - Declarations
     - [x] variable (Felipe - PR #55)

- Conversion from abstract syntax tree to generic tree
   - Expressions
     - [x] boolean constant
     - [x] integer constant
     - [x] real constant (Romildo)
     - [x] string constant (Gabriel - PR #14)
     - [ ] variable
     - [x] unary operation  (Fabricio - PR #53)
     - [x] binary operation  (Fabricio - PR #53)
     - [ ] assignment
     - [x] function call  (Artur - PR #57)
     - [x] if (Koda - PR #61)
     - [x] while
     - [x] break (Romildo)
     - [x] let (Felipe - PR #55)
     - [x] sequence (RodrigoJuliano #PR60)
   - Variables
     - [x] simple variable (Felipe - PR #55)
   - Declarations
     - [x] variable (Felipe - PR #55)

- Parser (production rules)
   - Expressions
     - [x] boolean constant
     - [x] integer constant
     - [x] real constant (Romildo)
     - [x] string constant (Gabriel - PR #14)
     - [ ] variable
     - [x] unary operation  (Fabricio - PR #53)
     - [x] binary operation  (Fabricio - PR #53)
     - [ ] assignment
     - [x] function call   (Artur - PR #57)
     - [x] if (Koda - PR #61)
     - [x] while
     - [x] break (Romildo)
     - [x] let (Felipe - PR #55)
     - [x] sequence (RodrigoJuliano #PR60)
   - Variables
     - [x] simple variable (Felipe - PR #55)
   - Declarations
     - [x] variable (Felipe - PR #55)

- Parser tests (expects tests for the parser)
   - Expressions
     - [ ] boolean constant
     - [ ] integer constant
     - [ ] real constant
     - [ ] string constant
     - [ ] variable
     - [ ] unary operation
     - [ ] binary operation
     - [ ] assignment
     - [ ] function call
     - [ ] if
     - [ ] while
     - [ ] break
     - [ ] let
     - [ ] sequence
   - Variables
     - [ ] simple variable
   - Declarations
     - [ ] variable

- Type representation
  - [x] void
  - [x] boolean
  - [x] integer
  - [ ] real
  - [ ] string

- Semantic Analysis
  - Internal representation of types
    - [x] void
    - [x] bool
    - [ ] int
    - [ ] real
    - [ ] string

  - Semantic rules
    - Expressions
       - [x] boolean constant
       - [ ] integer constant
       - [ ] real constant
       - [ ] string constant
       - [ ] variable (**wait**)
       - [ ] unary operation
       - [ ] binary operation
       - [ ] assignment (**wait**)
       - [ ] function call (**wait**)
       - [ ] if
       - [ ] while
       - [ ] break (**wait**)
       - [ ] let (**wait**)
       - [ ] sequence
     - Variables
       - [ ] simple variable (**wait**)
     - Declarations
       - [ ] variable (**wait**)
