%define parse.error verbose
%left '+' '-'
%left '*' '/'

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

%{
#include <stdio.h>
#include <string.h>

extern FILE*   yyin;
extern struct SymbolTable* symbolTable;
extern struct ConstantTable* constantTable;
extern struct SymbolTable* initSymbolTable();
extern struct ConstantTable* initConstantTable();
extern void printConstants(struct ConstantTable*);
extern void printSymbols(struct SymbolTable*);
extern struct Symbol* findSymbol(struct SymbolTable*, char*);
extern char* copy(char*);
extern void addType(struct SymbolTable*, char*, char*);


char* current_datatype;
%}
%%
start: statement
     | start statement


statement : E
		  | declaration
		  ;

E_F : ID
  	| INT
  	| DOUBLE
  	| STRING
  	| CHAR
  	;


E_T : E_T '*' E_F
  | E_T '/' E_F
  | E_F
  ;


E : E '+' E_T
  | E '-' E_T
  | '(' E ')'
  ;
  

decl : ID {addType(symbolTable, $1, current_datatype);}
	 | ID '=' INT {addType(symbolTable, $1, current_datatype);}
	 | ID '=' DOUBLE {addType(symbolTable, $1, current_datatype);}
	 | ID '=' STRING {addType(symbolTable, $1, current_datatype);}
	 | ID '=' CHAR {addType(symbolTable, $1, current_datatype);}
	 ;

decl_list : decl ',' decl_list
		  | decl
		  ;

datatype : DATATYPE {
	current_datatype = copy($1);
	printf("current_datatype : %s\n", current_datatype);
}

declaration : datatype decl_list ';' 

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