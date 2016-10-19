%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno;
int yydebug = 1;
char* lastFunction = "";
extern void yyerror( char* );
extern int yylex();
%}

/*********************************************************
 ********************************************************/
%union {
    char* id;
}

%token <id> ID
%token INTVAL FLTVAL DBLVAL STRVAL CHARVAL
%token VOID CHAR SHORT INT LONG FLOAT DOUBLE
%token EQ NE GE LE GT LT ADD SUB MUL DIV MOD OR AND BITOR BITAND BITXOR NOT COM LSH RSH SET SETADD SETSUB SETMUL SETDIV SETMOD SETOR SETAND SETXOR SETLSH SETRSH
%token RETURN DO WHILE FOR SWITCH CASE DEFAULT IF ELSE CONTINUE BREAK GOTO
%token UNSIGNED TYPEDEF STRUCT UNION CONST STATIC EXTERN AUTO REGISTER SIZEOF
%token PREPROC

%start top

%nonassoc IFX
%nonassoc ELSE

%%

top
	:
	| function top
	;

function
	: function_signature compound_statement {lastFunction = "";}
	;

function_signature
	: declaration_specifier ID function_parameters {printf("%s;\n", $2); lastFunction = $2;}
	;

function_parameters
	: '(' parameters ')'
	| '(' ')'
	| '(' identifiers ')'
	;

statement
	: compound_statement
	| expression_statement
	| selection_statement
	| interation_statement
	| jump_statement
	;

expression_statement
	: ';'
	| expression ';'
	;

selection_statement
	: IF '(' expression ')' statement ELSE statement
	| IF '(' expression ')' statement %prec IFX
	;

interation_statement
	: WHILE '(' expression ')' statement
	;

jump_statement
	: RETURN ';'
	| RETURN expression ';'
	;

compound_statement
	: '{' '}'
	| '{' block_items '}'
	;

expression
	: assignment_expression
	| expression ',' assignment_expression
	;

assignment_expression
	: conditional_expression
	| postfix_expression SET assignment_expression
	;

conditional_expression
	: or_expression
	;

or_expression
	: and_expression
	| or_expression OR and_expression
	;

and_expression
	: bitor_expression
	| and_expression AND bitor_expression
	;

bitor_expression
	: bitxor_expression
	| bitor_expression BITOR bitxor_expression
	;

bitxor_expression
	: bitand_expression
	| bitxor_expression BITXOR bitand_expression
	;

bitand_expression
	: eq_expression
	| bitand_expression BITAND eq_expression
	;

eq_expression
	: comparison_expression
	| eq_expression EQ comparison_expression
	| eq_expression NE comparison_expression
	;

comparison_expression
	: shift_expression
	| comparison_expression LT shift_expression
	| comparison_expression GT shift_expression
	| comparison_expression LE shift_expression
	| comparison_expression GE shift_expression
	;

shift_expression
	: addition_expression
	| shift_expression RSH addition_expression
	| shift_expression LSH addition_expression
	;

addition_expression
	: multiplication_expression
	| addition_expression ADD multiplication_expression
	| addition_expression SUB multiplication_expression
	;

multiplication_expression
	: postfix_expression
	| multiplication_expression MUL postfix_expression
	| multiplication_expression DIV postfix_expression
	| multiplication_expression MOD postfix_expression
	;

postfix_expression
	: primary_expression
	| ID '(' ')' {printf("%s -> %s;\n", lastFunction,$1);}
	| ID '(' expression ')' {printf("%s -> %s;\n", lastFunction, $1);}
	;

primary_expression
	: ID
	| INTVAL
	| STRVAL
	| FLTVAL
	| DBLVAL
	| CHARVAL
	| '(' expression ')'
	;

block_items
	: block_item
	| block_items block_item
	;

block_item
	: declaration
	| statement
	;

declaration
	: declaration_specifier ';'
	| declaration_specifier initialization_declarators ';'
	;

initialization_declarators
	: initialization_declarator
	| initialization_declarators ',' initialization_declarator
	;

initialization_declarator
	: declarator
	;

parameters
	: parameter_declaration
	| parameters ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifier declarator
	| declaration_specifier
	;

declaration_specifier
	: storage_specifier declaration_specifier
	| storage_specifier
	| type_specifier declaration_specifier
	| type_specifier
	| type_qualifier declaration_specifier
	| type_qualifier
	;

declarator
	: pointer direct_declarator
	| direct_declarator
	;

pointer
	: MUL
	| MUL pointer
	;

direct_declarator
	: ID
	| '(' declarator ')'
	| direct_declarator '[' ']'
	| direct_declarator '[' assignment_expression ']'
	| direct_declarator '(' parameters ')'
	| direct_declarator '(' ')'
	| direct_declarator '(' identifiers ')'
	;

identifiers
	: ID
	| identifiers ',' ID
	;

type_qualifier
	: CONST
	;

type_specifier
	: VOID
	| CHAR
	| INT
	| SHORT
	| LONG
	| FLOAT
	| DOUBLE
	| UNSIGNED
	;

storage_specifier
	: TYPEDEF
	| EXTERN
	| STATIC
	| AUTO
	| REGISTER
	;

%%

void yyerror( char *err ) {
    fprintf( stderr, "at line %d: %s\n", yylineno, err );
}

int main( int argc, const char *argv[] ) {
    printf( "digraph funcgraph {\n" );
    int res = yyparse();
    printf( "}\n" );

    return res;
}
