%define parse.error verbose
%left '*' '/'
%left '+' '-'

%union {
	int ival;
	double dval;
	char cval;
	char *sval;
	char* dt;
}

%token <sval> ID
%token <ival> INT
%token <dval> DOUBLE
%token <cval> CHAR
%token <sval> STRING
%token <dt>   DATATYPE
%token INC_DEC_OP ASSIGNMENT SHIFT_OP_L SHIFT_OP_R COMP_OP EQUALITY_OP AND_OP OR_OP
%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%start translation_unit

%nonassoc "then"
%nonassoc ELSE

%{
#include <stdio.h>
#include <string.h>
#include "headers/symbol_table.h"

extern FILE*   yyin;
extern int line;

struct SymbolTable* symbolTable = NULL;
struct ConstantTable* constantTable = NULL;

char* current_datatype;

%}
%%

translation_unit
    : global_declaration
    | translation_unit global_declaration
    ;

global_declaration
    : function_definition
    | declaration
    ;

datatype
    : DATATYPE {
		current_datatype = copy($1);
    }
    ;

function_definition
    : datatype declarator compound_statement
    ;

declarator
    : ID {
		addType(symbolTable, $1, current_datatype);
    }
    | declarator '[' constant_expression ']'
    | declarator '[' ']'
    | declarator '(' parameter_list ')'
    | declarator '(' id_list ')'
    | declarator '(' ')'
    ;

declaration 
    : datatype init_list ';'
    ;

declaration_list
    : declaration
    | declaration declaration_list
    ;

init_list
    : init
    | init ',' init_list
    ;

init 
    : declarator
    | declarator '=' initializer
    ;

initializer
    : assignment_expression
    | '{' initializer_list '}'
    ;

initializer_list
    : initializer initializer_list_tail
    ;

initializer_list_tail
    : 
    | ',' 
    | ',' initializer_list
    ;

parameter_list
    : parameter_declaration parameter_list_tail
    ;

parameter_list_tail
    : 
    | ',' parameter_list
    | ',' '.' '.' '.'
    ;

parameter_declaration
    : DATATYPE declarator
    | DATATYPE
    ;

id_list
    : ID
    | ID ',' id_list
    ;

statement
    : declaration_list
    | compound_statement
    | labeled_statement
    | expression_statement
    | selection_statement
    | iteration_statement
    | jump_statement
    ;

compound_statement
    : '{' statement_list '}'
    ;

statement_list
    : statement
    | statement statement_list
    ;

labeled_statement
    : ID ':' statement
    | CASE constant_expression ':' statement
    | DEFAULT ':' statement
    ;

expression_statement
    : ';'
    | expression ';'
    ;

selection_statement
    : IF '(' expression ')' statement                %prec "then"
    | IF '(' expression ')' statement ELSE statement
    | SWITCH '(' expression ')' statement
    ;

iteration_statement
	: WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	| FOR '(' expression_statement expression_statement ')' statement
	| FOR '(' expression_statement expression_statement expression ')' statement
	;

jump_statement
	: GOTO ID ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;

primary_expression
	: ID
	| INT
    | DOUBLE
	| STRING
	| CHAR
	| '(' expression ')'
	;

expression
    : assignment_expression
    | expression ',' assignment_expression
    ;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
	;

assignment_operator
    : '='
    | ASSIGNMENT
    ;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
	;

constant_expression
	: conditional_expression
	;

postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']'
	| postfix_expression '(' ')'
	| postfix_expression '(' argument_expression_list ')'
	| postfix_expression '.' ID
	| postfix_expression INC_DEC_OP
    ;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' assignment_expression
    ;

unary_expression
	: postfix_expression
	| INC_DEC_OP unary_expression
	| unary_operator cast_expression
	| "sizeof" unary_expression
	| "sizeof" '(' DATATYPE ')'
	;

unary_operator
	: '&'
	| '*'
	| '+'
	| '-'
	| '~'
	| '!'
	;

cast_expression
	: unary_expression
	| '(' DATATYPE ')' cast_expression
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' cast_expression
	| multiplicative_expression '/' cast_expression
	| multiplicative_expression '%' cast_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression
	;

shift_expression
	: additive_expression
	| shift_expression SHIFT_OP_L additive_expression
	| shift_expression SHIFT_OP_R additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression COMP_OP shift_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQUALITY_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;

%%

void yyerror (char *s) {
	printf("Error at line %d: %s!\n", line, s);
}

int main (int argc, char* argv[]) {

    if (argc != 2){
        printf("No input file!\n");
        return 1;
    }

	yyin = fopen(argv[1], "r");
	symbolTable = initSymbolTable();
	constantTable = initConstantTable();
	yyparse();
	

	printSymbols(symbolTable);
	printConstants(constantTable);
}