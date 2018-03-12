%define parse.error verbose
%left '*' '/'
%left '+' '-'

%{
#include <stdio.h>
#include <string.h>
#include "headers/symbol_table.h"
#include "headers/parse_tree.h"
#include "headers/semantic.h"

extern FILE* yyin;
extern int   line;

struct SymbolTable* symbolTable = NULL;
struct ConstantTable* constantTable = NULL;

char* current_datatype;
char* current_function_datatype;
struct Symbol* current_symbol;
int flag = 0;
int dontCreateNewScope = 0;

%}

%union {
	int    ival;
	double dval;
	char   cval;
	char*  sval;
	char*  dt;
	struct tree* a_tree;
}

%token <sval> ID
%token <ival> INT
%token <dval> DOUBLE
%token <sval> CHAR
%token <sval> STRING
%token <dt>   DATATYPE
%token <sval> ASSIGNMENT
%token INC_OP DEC_OP SHIFT_OP_L SHIFT_OP_R LT_COMP GT_COMP LTE_COMP GTE_COMP EQUALITY_OP NOT_EQUALITY_OP AND_OP OR_OP
%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%type <a_tree> conditional_expression additive_expression multiplicative_expression logical_or_expression shift_expression relational_expression logical_and_expression equality_expression and_expression exclusive_or_expression inclusive_or_expression cast_expression unary_expression primary_expression expression postfix_expression assignment_expression init declarator
%type <sval> assignment_operator
%type <dt>   datatype

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
        $$ = $1;
	current_datatype = copy($1);
    }
    ;

function_declarator_bracket
   : ID '(' {
      startNewScope();
      dontCreateNewScope = 1;
   }
   ;

function_declarator
   : function_declarator_bracket parameter_list ')' {
      current_function_datatype = copy(current_datatype);
   }
   ;

function_definition
    : datatype function_declarator compound_statement
    ;

declarator
    : ID {
	addSymbol(symbolTable, $1, getCurrentScope());
	addType(symbolTable, $1, current_datatype, getCurrentScope());
	$$ = make_variable($1);
    }
    | declarator '[' constant_expression ']' {$$ = $1;}
    | declarator '[' ']' {$$ = $1;}
    | declarator '(' parameter_list ')' {$$ = $1;}
    | declarator '(' id_list ')' {$$ = $1;}
    | declarator '(' ')' {$$ = $1;}
    ;

declaration 
    : datatype init_list ';'
    | error {}
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
    : declarator {$$ = $1;}
    | declarator ASSIGNMENT assignment_expression {
		$$ = make_operator($1, $2, $3);
		printf("*** Parse Tree ***\n");
		printtree($$, 1);
		printf("***\n");
		printf("\n");
		if (!checkType($$, getCurrentScope())) 
			yyerror("Operation performed on inconsistent datatypes\n");
    }
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
    :
    | datatype declarator {
	 addParamType(current_symbol, getTypeConstant($1));
    }
    | DATATYPE {
	 addParamType(current_symbol, getTypeConstant($1));
    }
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


block_start
   : '{' {
      if (!dontCreateNewScope)
	 startNewScope();
      else
	 dontCreateNewScope = 0;
   }
   ;

block_end
   : '}' {
      if (!dontCreateNewScope)
	 endCurrentScope();
   }
   ;

compound_statement
    : block_start statement_list block_end
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

bracket_begin_scope
   : ')' {
      startNewScope();
   }
   ;

selection_statement
    : IF '(' expression bracket_begin_scope statement                %prec "then"
      {
	 endCurrentScope();
      }
    | IF '(' expression bracket_begin_scope statement ELSE statement
      {
	 endCurrentScope();
      }
    | SWITCH '(' expression bracket_begin_scope statement
      {
	 endCurrentScope();
      }
    ;

do 
   : DO {
      startNewScope();
   }
   ;

iteration_statement
	: WHILE '(' expression bracket_begin_scope statement
	  {
	    endCurrentScope();
	  }
	| do statement WHILE '(' expression ')' ';'
	  {
	    endCurrentScope();
	  }
	| FOR '(' expression_statement expression_statement bracket_begin_scope statement
	  {
	    endCurrentScope();
	  }
	| FOR '(' expression_statement expression_statement expression bracket_begin_scope statement
	  {
	    endCurrentScope();
	  }
	;

return_expression 
   : expression {
      int expression_type = checkAndGetTypes($1, getCurrentScope());
      int return_type = getTypeConstant(current_function_datatype);
      if (expression_type != -1 && (
	    (expression_type == TYPE_STRING && return_type != TYPE_STRING) ||
	    (expression_type != TYPE_STRING && return_type == TYPE_STRING) ) )

	 yyerror("Return type not matching function definition\n");
   }
   ;

jump_statement
	: GOTO ID ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN return_expression ';'
	;

primary_expression
	: ID {$$ = make_variable($1);}
	| INT {$$ = make_number($1);}
    | DOUBLE {$$ = make_double($1);}
	| STRING {$$ = make_string($1);}
	| CHAR {$$ = make_char($1);}
	| '(' expression ')' {$$ = $2;}
	;

expression
    : assignment_expression {
		$$ = $1;
		printf("*** Parse Tree ***\n");
		printtree($1, 1);
		printf("***\n");
		printf("\n");
		if (!checkType($$, getCurrentScope())) 
			yyerror("Operation performed on inconsistent datatypes\n");	
    }
    | expression ',' assignment_expression {$$ = $3;}
    ;

assignment_expression
	: conditional_expression {$$ = $1;}
	| unary_expression assignment_operator assignment_expression {
	    $$ = make_operator($1, $2, $3);
        }
	;

assignment_operator
    : ASSIGNMENT
    ;

conditional_expression
	: logical_or_expression {
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
	| postfix_expression INC_OP {$$ = make_operator($1, "++", NULL);}
	| postfix_expression DEC_OP {$$ = make_operator($1, "--", NULL);}
    ;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' assignment_expression
    ;

unary_expression
	: postfix_expression {$$ = $1;}
	| INC_OP unary_expression {$$ = make_operator(NULL, "++", $2);}
	| DEC_OP unary_expression {$$ = make_operator(NULL, "--", $2);}
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
	| relational_expression LT_COMP shift_expression {$$ = make_operator($1, "<", $3);}
	| relational_expression GT_COMP shift_expression {$$ = make_operator($1, ">", $3);}
	| relational_expression LTE_COMP shift_expression {$$ = make_operator($1, "<=", $3);}
	| relational_expression GTE_COMP shift_expression {$$ = make_operator($1, ">=", $3);}
	;

equality_expression
	: relational_expression {$$ = $1;}
	| equality_expression EQUALITY_OP relational_expression {$$ = make_operator($1, "==", $3);}
	| equality_expression NOT_EQUALITY_OP relational_expression {$$ = make_operator($1, "!=", $3);}
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
    flag = 1;
    printf("Error at line %d: %s\n", line, s);
}

int main (int argc, char* argv[]) {

    if (argc != 2){
        printf("No input file!\n");
        return 1;
    }

    yyin = fopen(argv[1], "r");

    if (!yyin) {
	printf("File doesn't exist\n");
	return 1;
    }

    symbolTable = initSymbolTable();
    constantTable = initConstantTable();
    scopes[0] = 0; // Global
    yyparse();
    
    if (!flag){
		printSymbols(symbolTable);
		printConstants(constantTable);
		printf("Program is syntactically correct.\n");
    } else {
		printf("Compilation Failed!\n");
    }
	
}
