%token CLASS ID LCB RCB ASSIGN INTCONSTANT SEMICOLON LPAREN RPAREN VOID INT BOOL
%%
program: CLASS ID LCB field_decl_list method_decl_list RCB
field_decl_list: field_decl field_decl_list
     |
     ;
method_decl_list: method_decl method_decl_list
     |
     ;
field_decl: type ID ASSIGN INTCONSTANT SEMICOLON
method_decl: return_type ID LPAREN RPAREN
return_type: type
return_type: VOID
type: INT
type: BOOL
%%
