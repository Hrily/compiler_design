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


struct Symbol {
    char* name;
    char* type;
};

struct SymbolTable {
    int depth;
    array(struct Symbol*) symbols;
    array(struct SymbolTable*) children;
    array(struct SymbolTable*) stack;
};

struct SymbolTable* initSymbolTable (int depth) {
    struct SymbolTable* symbolTable = (struct SymbolTable*)
            malloc(sizeof(struct SymbolTable));
    symbolTable->depth = depth;
    symbolTable->symbols = (typeof(symbolTable->symbols)) array_init();
    symbolTable->children = (typeof(symbolTable->children)) array_init();
    symbolTable->stack = (typeof(symbolTable->stack)) array_init();
    array_push(symbolTable->stack, symbolTable);
    return symbolTable;
}

void addSymbolWithType (struct SymbolTable *symbolTable, 
        char* type, char* name) {
    struct Symbol *symbol = (struct Symbol*)
            malloc(sizeof(struct Symbol));
    symbol->name = (char*) malloc(strlen(name)) + 1;
    strcpy(symbol->name, name);
    symbol->type = (char*) malloc(strlen(type)) + 1;
    strcpy(symbol->type, type);
    array_push(last_element(symbolTable->stack)->symbols, symbol);
}

void addSymbol (struct SymbolTable *symbolTable, 
        char* name) {
    struct Symbol *symbol = (struct Symbol*)
            malloc(sizeof(struct Symbol));
    symbol->name = (char*) malloc(strlen(name)) + 1;
    strcpy(symbol->name, name);
    array_push(last_element(symbolTable->stack)->symbols, symbol);
}

void printSymbols (struct SymbolTable *symbolTable) {
    // Print current block
    if (symbolTable->symbols.length <= 0) goto print_child;
    PUTTAB(symbolTable->depth);
    printf("=================START=================\n");
    PUTTAB(symbolTable->depth);
    printf(" TYPE\tNAME\n");
    for (int i=0; i<symbolTable->symbols.length; i++) {
        PUTTAB(symbolTable->depth);
        printf(" %s\t%s\n", 
            symbolTable->symbols.data[i]->type, 
            symbolTable->symbols.data[i]->name);
    }
    PUTTAB(symbolTable->depth);
    printf("==================END==================\n");
    print_child:
    // Print Children
    for(int i=0; i<symbolTable->children.length; i++) 
        printSymbols(symbolTable->children.data[i]);

}

int hasSymbol (struct SymbolTable* symbolTable, 
        char* type, char* name) {
    struct SymbolTable* currentST = last_element(symbolTable->stack);
    for (int i=0; i<currentST->symbols.length; i++) {
        if (strcmp(currentST->symbols.data[i]->type, type) == 0 &&
                strcmp(currentST->symbols.data[i]->name, name) == 0)
            return 1;
    }
    return 0;
}

struct Symbol* findSymbol (struct SymbolTable* symbolTable, 
        char* name) {
    struct SymbolTable* currentST = last_element(symbolTable->stack);
    for (int i=0; i<currentST->symbols.length; i++) {
        if (strcmp(currentST->symbols.data[i]->name, name) == 0)
            return currentST->symbols.data[i];
    }
    return NULL;
}

void startNewBlock (struct SymbolTable* symbolTable) {
    struct SymbolTable *currentST = last_element(symbolTable->stack);
    struct SymbolTable *newST = initSymbolTable(symbolTable->depth + 1);
    array_push(currentST->stack, newST);
    array_push(currentST->children, newST);
}

int stopCurrentBlock (struct SymbolTable* symbolTable) {
    if (symbolTable->stack.length == 1) 0;
    array_pop(symbolTable->stack);
    return 1;
}

struct SymbolTable* symbolTable = NULL;

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

integer 			({digit})*
unsigned_integer	{integer}
signed_integer		(\+|\-)?{integer}
positive_integer	(\+)?{integer}

double				({integer}\.{integer}([eE]{integer})?)|({integer}[eE]{integer})
unsigned_double		{double}
signed_double		(\+|\-)?{double}
nondouble			{digit}+(\.{integer})(\.{integer})+

string_constant		\".*\"

assignment_operator	=
operator			(\+|\-|\*|\/|\+\+|\-\-|\%)
relational_operator	(\<|\<=|\>|\>=|==|!=)
logical_operator 	(&&|\|\||!)
bitwise_operator	(&|\||\^|~|\<\<|\>\>)

single_comment		\/\/.*
multi_comment		\/\*(.|\n)+\*\/

if_construct        if({space}*)?\((.)+\)
else                else


%%
{blank_char} 		;


{header} 			printf("header : %s\n", yytext);


{if_construct}      printf("if_construct : %s\n", yytext);
{else}           printf("else_construct : %s\n", yytext);

{start_block}		{startNewBlock (symbolTable);};
{end_block}			{stopCurrentBlock (symbolTable);};

{data_type}    		{printf("data_type : %s\n", yytext);}
{keyword}      		{printf("keyword : %s\n", yytext);}
{identifier}		{
    if (findSymbol(symbolTable, yytext) != NULL)
        printf("Redeclaration error for %s\n", yytext);
    else
        addSymbol(symbolTable, yytext);
	printf("identifier : %s\n", yytext);
};

{parameter_list}	printf("parameter_list : %s\n", yytext);

{nondouble}			printf("Illegal double constant : %s\n", yytext);
{double}			printf("double : %s\n", yytext);
{signed_double}		printf("signed_double : %s\n", yytext);

{integer}			printf("integer : %s\n", yytext);
{signed_integer}	printf("signed_integer : %s\n", yytext);

{string_constant}	printf("string_constant : %s\n", yytext);

{single_comment}	printf("single_comment : %s\n", yytext);
{multi_comment}		printf("multi_comment : %s\n", yytext);

{assignment_operator} printf("assignment_operator : %s\n", yytext);
{operator}			printf("operator : %s\n", yytext);
{relational_operator} printf("relational_operator : %s\n", yytext);
{logical_operator}	printf("logical_operator : %s\n", yytext);
{bitwise_operator}	printf("bitwise_operator : %s\n", yytext);

{delimeter}			;
{comma}				;

{nonidentifier}		printf("Invalid identifier : %s\n", yytext);
[^ \t\n]			printf("Invalid character : %s\n", yytext);

%%

int main () {
	symbolTable = initSymbolTable(0);
	yyin = fopen("test.c", "r");
	yylex();
	fclose(yyin);
}

int yywrap () {
	printf("\n*** SYMBOL TABLE ***\n");
	printSymbols(symbolTable);
	return 1;
}