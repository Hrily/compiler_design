%define parse.error verbose
%left '*' '/'
%left '+' '-'

%{
#include <stdio.h>
#include <string.h>
#include "headers/symbol_table.h"
#include "headers/parse_tree.h"

extern FILE*   yyin;
extern int line;

struct SymbolTable* symbolTable = NULL;
struct ConstantTable* constantTable = NULL;

char* current_datatype;

%}

%union {
	int ival;
	double dval;
	char cval;
	char *sval;
	char* dt;
	struct tree* a_tree;
}

%token <sval> ID
%token <ival> INT
%token <dval> DOUBLE
%token <cval> CHAR
%token <sval> STRING
%token <dt>   DATATYPE
%token INC_DEC_OP ASSIGNMENT SHIFT_OP_L SHIFT_OP_R COMP_OP EQUALITY_OP AND_OP OR_OP
%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%type <a_tree> conditional_expression additive_expression multiplicative_expression logical_or_expression shift_expression relational_expression logical_and_expression equality_expression and_expression exclusive_or_expression inclusive_or_expression cast_expression unary_expression primary_expression expression postfix_expression assignment_expression

%start translation_unit

%nonassoc "then"
%nonassoc ELSE

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
	: ID {$$ = make_variable($1);}
	| INT {$$ = make_number($1);}
    | DOUBLE {$$ = make_number($1);}
	| STRING {$$ = make_variable($1);}
	| CHAR {$$ = make_number($1);}
	| '(' expression ')' {$$ = $2;}
	;

expression
    : assignment_expression {$$ = $1;}
    | expression ',' assignment_expression {$$ = $3;}
    ;

assignment_expression
	: conditional_expression {$$ = $1;}
	| unary_expression assignment_operator assignment_expression {$$ = $3;}
	;

assignment_operator
    : '='
    | ASSIGNMENT
    ;

conditional_expression
	: logical_or_expression {
	    printf("*** Parse Tree ***\n");
	    printtree($1, 1);
	    printf("***\n");
	    printf("\n");
	 }
	| logical_or_expression '?' expression ':' conditional_expression
	;

constant_expression
	: conditional_expression
	;

postfix_expression
	: primary_expression {$$ = $1;}
	| postfix_expression '[' expression ']' {$$ = $1;}
	| postfix_expression '(' ')' {$$ = $1;}
	| postfix_expression '(' argument_expression_list ')' {$$ = $1;}
	| postfix_expression '.' ID {$$ = $1;}
	| postfix_expression INC_DEC_OP {$$ = $1;}
    ;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' assignment_expression
    ;

unary_expression
	: postfix_expression {$$ = $1;}
	| INC_DEC_OP unary_expression {$$ = $2;}
	| unary_operator cast_expression {$$ = $2;}
	| "sizeof" unary_expression {$$ = $2;}
	| "sizeof" '(' DATATYPE ')' {$$ = make_variable($3);}
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
	: unary_expression {$$ = $1;}
	| '(' DATATYPE ')' cast_expression {$$ = $4;};
	;

multiplicative_expression
	: cast_expression {$$ = $1;}
	| multiplicative_expression '*' cast_expression {$$ = make_operator($1, "*", $3);}
	| multiplicative_expression '/' cast_expression {$$ = make_operator($1, "/", $3);}
	| multiplicative_expression '%' cast_expression {$$ = make_operator($1, "%", $3);}
	;

additive_expression
	: multiplicative_expression {$$ = $1;}
	| additive_expression '+' multiplicative_expression {$$ = make_operator($1, "+", $3);}
	| additive_expression '-' multiplicative_expression {$$ = make_operator($1, "-", $3);}
	;

shift_expression
	: additive_expression {$$ = $1;}
	| shift_expression SHIFT_OP_L additive_expression {$$ = make_operator($1, "<<", $3);}
	| shift_expression SHIFT_OP_R additive_expression {$$ = make_operator($1, ">>", $3);}

	;

relational_expression
	: shift_expression {$$ = $1;}
	| relational_expression COMP_OP shift_expression {$$ = make_operator($1, "comp", $3);}
	;

equality_expression
	: relational_expression {$$ = $1;}
	| equality_expression EQUALITY_OP relational_expression {$$ = make_operator($1, "==/!=", $3);}
	;

and_expression
	: equality_expression {$$ = $1;}
	| and_expression '&' equality_expression {$$ = make_operator($1, "&", $3);}
	;

exclusive_or_expression
	: and_expression {$$ = $1;}
	| exclusive_or_expression '^' and_expression {$$ = make_operator($1, "^", $3);}
	;

inclusive_or_expression
	: exclusive_or_expression {$$ = $1;}
	| inclusive_or_expression '|' exclusive_or_expression {$$ = make_operator($1, "|", $3);}
	;

logical_and_expression
	: inclusive_or_expression {$$ = $1;}
	| logical_and_expression AND_OP inclusive_or_expression {$$ = make_operator($1, "&&", $3);}
	;

logical_or_expression
	: logical_and_expression {$$ = $1;}
	| logical_or_expression OR_OP logical_and_expression {$$ = make_operator($1, "||", $3);}
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
