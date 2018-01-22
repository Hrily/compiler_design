%define parse.error verbose
%left '+' '-'
%left '*' '/'

%union {
	int ival;
	double dval;
	char cval;
	char *sval;
}

%token <sval> ID
%token <ival> INT
%token <dval> DOUBLE
%token <cval> CHAR
%token <sval> STRING

%{
#include <stdio.h>
extern FILE*   yyin;
extern struct SymbolTable* symbolTable;
extern struct ConstantTable* constantTable;
extern struct SymbolTable* initSymbolTable();
extern struct ConstantTable* initConstantTable();
%}
%%

_E_ : E {
	printf("Valid expression\n");
} 

E : E '+' E
  | E '-' E
  | E '*' E
  | E '/' E
  | E '%' E
  | '(' E ')'
  | ID
  | INT
  | DOUBLE
  | STRING
  | CHAR

%%

void yyerror (char *s) {
	printf("Invalid expression: %s!\n", s);
}

int main () {
	yyin = fopen("parser/test.c", "r");
	symbolTable = initSymbolTable();
	constantTable = initConstantTable();
	printf("Enter expression :\n");
	// do {
	// 	printf("feof %d\n", feof(yyin));
	// 	yyparse();
	// 	printf("feof %d\n", feof(yyin));
	// } while (!feof(yyin));
	while (!feof(yyin))
		yyparse();
	printf("feof %d\n", feof(yyin));
	
}