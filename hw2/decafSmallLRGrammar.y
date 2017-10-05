%token CLASS ID LCB RCB ASSIGN INTCONSTANT SEMICOLON LPAREN RPAREN VOID INT BOOL
%%
program: CLASS class_name LCB field_decl_list method_decl_list RCB
     | CLASS class_name LCB field_decl_list RCB
     ;
class_name: ID
field_decl_list: field_decl_list field_decl
     |
     ;
method_decl_list: method_decl_list method_decl
     | method_decl
     ;
field_decl: type ID ASSIGN INTCONSTANT SEMICOLON
method_decl: VOID ID LPAREN RPAREN
     | type ID LPAREN RPAREN
     ;
type: INT
     | BOOL
     ;
%%
