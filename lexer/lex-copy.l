%{

#include <stdio.h>

#include <string.h>
#include <stdlib.h>

#define typeof __typeof__

#define PUTTAB(n) {for(int _i_=0;_i_<n;_i_++) {printf("\t");}}

#define array(type)  \
  struct {           \
      type* data;    \
      size_t length; \
  }

#define array_init() \
  {                  \
      .data = NULL,  \
      .length = 0    \
  }

#define array_free(array) \
  do {                    \
      free(array.data);   \
      array.data = NULL;  \
      array.length = 0;   \
  } while (0)

#define array_push(array, element)                \
  do {                                            \
      array.data = realloc(array.data,            \
                           sizeof(*array.data) *  \
                             (array.length + 1)); \
      array.data[array.length] = element;         \
      array.length++;                             \
  } while (0)

#define array_pop(array)    \
{                           \
    array.length--;         \
}

#define last_element(array) array.data[array.length-1]


struct Symbol 
{
    char* name;
    char* type;
};

struct SymbolTable 
{
    array(struct Symbol*) symbols;
};

struct SymbolTable* initSymbolTable ()
{
    struct SymbolTable* symbolTable = (struct SymbolTable*)
            malloc(sizeof(struct SymbolTable));
    symbolTable->symbols = (typeof(symbolTable->symbols)) array_init();
    return symbolTable;
}

int hasSymbol (struct SymbolTable* symbolTable, char* name)
{
    for (int i=0; i<symbolTable->symbols.length; i++) {
        if (strcmp(symbolTable->symbols.data[i]->name, name) == 0)
            return 1;
    }
    return 0;
}

void addSymbol (struct SymbolTable* symbolTable, char* name)
{
    if (hasSymbol(symbolTable, name))
        return;
    struct Symbol *symbol = (struct Symbol*)
            malloc(sizeof(struct Symbol));
    symbol->name = (char*) malloc(strlen(name)) + 1;
    strcpy(symbol->name, name);
    array_push(symbolTable->symbols, symbol);
}

void printSymbols (struct SymbolTable *symbolTable) {
    // Print current block
    if (symbolTable->symbols.length <= 0) 
        return;
    printf("*** Symbol Table ***\n");
    printf("=================START=================\n");
    for (int i=0; i<symbolTable->symbols.length; i++) {
        printf(" %s\n", symbolTable->symbols.data[i]->name);
    }
    printf("==================END==================\n");
}

struct Constant 
{
    char* text;
    char* type;
};

struct ConstantTable 
{
    array(struct Constant*) constants;
};

struct ConstantTable* initConstantTable ()
{
    struct ConstantTable* constantTable = (struct ConstantTable*)
            malloc(sizeof(struct ConstantTable));
    constantTable->constants = (typeof(constantTable->constants)) array_init();
    return constantTable;
}

int hasConstant (struct ConstantTable* constantTable, char* text)
{
    for (int i=0; i<constantTable->constants.length; i++) {
        if (strcmp(constantTable->constants.data[i]->text, text) == 0)
            return 1;
    }
    return 0;
}

void addConstant (struct ConstantTable* constantTable, char* text)
{
    if (hasConstant(constantTable, text))
        return;
    struct Constant *constant = (struct Constant*)
            malloc(sizeof(struct Constant));
    constant->text = (char*) malloc(strlen(text)) + 1;
    strcpy(constant->text, text);
    array_push(constantTable->constants, constant);
}

void printConstants (struct ConstantTable* constantTable) {
    // Print current block
    if (constantTable->constants.length <= 0) 
        return;
    printf("*** Constant Table ***\n");
    printf("=================START=================\n");
    for (int i=0; i<constantTable->constants.length; i++) {
        printf(" %s\n", constantTable->constants.data[i]->text);
    }
    printf("==================END==================\n");
}

struct SymbolTable* symbolTable = NULL;
struct ConstantTable* constantTable = NULL;

%}
blank_char			[ \t\n]
letter 				[a-z|A-Z]
digit 				[0-9]
delimeter			;
space 				[ \t]
comma				,

start_block			\{
end_block			\}

keyword				auto|double|int|struct|break|else|long|switch|case|enum|register|typedef|char|extern|return|union|const|float|short|unsigned|continue|for|signed|void|default|goto|sizeof|volatile|do|if|static|while

header 				#include(\<{letter}+\.h\>)|#include\"{letter}+(\.)?{letter}*\"

identifier 			({letter}|_)({letter}|{digit}|_)*
data_type 			(void)|(int)|(char)|(float)|(double)|(struct({space}{identifier}))|(union({space}{identifier}))
nonidentifier		[^a-zA-Z_,.; \t\n]([^0-9,.; \t\n])+([^, \t\n.;])*

parameter_list 		({identifier},)*({identifier})

integer 			({digit})+
unsigned_integer	{integer}
signed_integer		(\+|\-)?{integer}
positive_integer	(\+)?{integer}

double				({integer}\.{integer}([eE]{integer})?)|({integer}[eE]{integer})
unsigned_double		{double}
signed_double		(\+|\-)?{double}
nondouble			{digit}+(\.{integer})(\.{integer})+

string_constant		\".*\"

constant            {integer}|{unsigned_integer}|{signed_integer}|{positive_integer}|{double}|{unsigned_double}|{signed_double}|{string_constant}

assignment_operator	=
operator			(\+|\-|\*|\/|\+\+|\-\-|\%)
relational_operator	(\<|\<=|\>|\>=|==|!=)
logical_operator 	(&&|\|\||!)
bitwise_operator	(&|\||\^|~|\<\<|\>\>)

single_comment		\/\/.*
multi_comment		\/\*(.|\n)+\*\/

if_construct        if({space}*)?\((.)+\)
else                else

for                 for({space}*)\(.*;.*;.*\)

while               while({space}*)\(\)

%%
{blank_char} 		;


{header} 			printf("header : %s\n", yytext);


{if_construct}      printf("if_construct : %s\n", yytext);
{else}              printf("else_construct : %s\n", yytext);

{for}               printf("for loop : %s\n", yytext);
{while}             printf("while loop : %s\n", yytext);

{start_block}		;
{end_block}			;

{data_type}    		{printf("data_type : %s\n", yytext);}
{keyword}      		{printf("keyword : %s\n", yytext);}
{identifier}		{
    addSymbol(symbolTable, yytext);
	printf("identifier : %s\n", yytext);
    return ID;
};

{parameter_list}	printf("parameter_list : %s\n", yytext);

{nondouble}			printf("Illegal double constant : %s\n", yytext);
{double}			{printf("double : %s\n", yytext); addConstant(constantTable, yytext); return DOUBLE}
{signed_double}		{printf("signed_double : %s\n", yytext); addConstant(constantTable, yytext); return SIGNED_DOUBLE}

{integer}			{printf("integer : %s\n", yytext); addConstant(constantTable, yytext); return INT}
{signed_integer}	{printf("signed_integer : %s\n", yytext); addConstant(constantTable, yytext); return SIGNED_INT}

{string_constant}	{printf("string_constant : %s\n", yytext); addConstant(constantTable, yytext); return STRING}

{single_comment}	printf("single_comment : %s\n", yytext);
{multi_comment}		printf("multi_comment : %s\n", yytext);

{assignment_operator} printf("assignment_operator : %s\n", yytext);
{operator}			printf("operator : %s\n", yytext);
{relational_operator} printf("relational_operator : %s\n", yytext);
{logical_operator}	printf("logical_operator : %s\n", yytext);
{bitwise_operator}	printf("bitwise_operator : %s\n", yytext);

{delimeter}			;
{comma}				;
[(){}]|\[|\]        ;

[^ \t\n]			printf("Invalid character : %s\n", yytext);

%%

int main () {
	symbolTable = initSymbolTable();
	constantTable = initConstantTable();
	yyin = fopen("test.c", "r");
	yylex();
	fclose(yyin);
}

int yywrap () {
	printSymbols(symbolTable);
	printConstants(constantTable);
	return 1;
}
