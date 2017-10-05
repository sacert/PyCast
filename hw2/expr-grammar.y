%token T_DOUBLE T_NUMBER T_NAME T_EXP T_SQRT T_LOG

%%
statement_list : statement '\n' statement_list
   |
   ;

statement: T_NAME '=' expression
   | expression
   ;

expression: expression '+' T_NUMBER
   | expression '-' T_NUMBER
   | expression '+' T_DOUBLE
   | expression '-' T_DOUBLE
   | expression '+' T_NAME 
   | expression '-' T_NAME 
   | T_NUMBER
   | T_DOUBLE
   | T_NAME 
   | T_EXP '(' expression ')'
   | T_SQRT '(' expression ')'
   | T_LOG '(' expression ')'
   ;

%%

