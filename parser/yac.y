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
extern void printConstants(struct ConstantTable*);
extern void printSymbols(struct SymbolTable*);
%}
%%
start: statement
     | start statement


_E_ : E {
	printf("Valid expression\n");
} 

statement : _E_

E : E '+' E
  | E '-' E
  | '(' E ')'
  | ID
  | INT
  | DOUBLE
  | STRING
  | CHAR
  ;

%%

void yyerror (char *s) {
	printf("Invalid expression: %s!\n", s);
}

int main () {
	yyin = fopen("parser/test.c", "r");
	symbolTable = initSymbolTable();
	constantTable = initConstantTable();
	yyparse();
	

	printSymbols(symbolTable);
	printConstants(constantTable);
}