%{

%}
letter 				[a-z|A-Z]
digit 				[0-9]
header 				#include(\<{letter}+\.h\>)|#include\"{letter}+(\.)?{letter}*\"
identifier 			({letter}|_)({letter}|{digit}|_)*
space 				[ ]
data_type 			(void)|(int)|(char)|(float)|(double)|(struct({space}{identifier}))|(union({space}{identifier}))
parameter_list 		({identifier},)*({identifier})
function_call 		{identifier}\({parameter_list}\)|{identifier}\(\)
%%
{header} 			printf("header : %s\n", yytext);
{data_type}			printf("data_type : %s\n", yytext);
{identifier}		printf("identifier : %s\n", yytext);
{parameter_list}	printf("parameter_list : %s\n", yytext);
{function_call}		printf("function_call : %s\n", yytext);
%%

int main () {
	yyin = fopen("test.c", "r");
	yylex();
	fclose(yyin);
}

int yywrap () {
	return 1;
}
