%token ID DOUBLE SIGNED_DOUBLE INT SIGNED_INT STRING CHAR
%left '+' '-'
%left '*' '/'

%{
#include <stdio.h>
%}
%%

ED : E
	{
		printf("Valid expression...\n");
	}
	;

E : E '+' E
  | E '-' E
  | E '*' E
  | E '/' E
  | '('E')'
  | ID
  | DOUBLE
  | SIGNED_DOUBLE
  | INT
  | SIGNED_INT
  | CHAR
 
%%

void yyerror (char *s) {
	printf("Invalid expression: %s!\n", s);
}

int main () {
	printf("Enter expression :\n");
	yyparse();
}