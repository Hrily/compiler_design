%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define TRUE		1
#define FALSE		0
#define typeof 		__typeof__
#define PUTTAB(n) 	{for(int _i_=0;_i_<n;_i_++) {printf("\t");}}

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

void addSymbol (struct SymbolTable *symbolTable, 
        char* type, char* name) {
    struct Symbol *symbol = (struct Symbol*)
            malloc(sizeof(struct Symbol));
    symbol->name = (char*) malloc(strlen(name)) + 1;
    strcpy(symbol->name, name);
    symbol->type = (char*) malloc(strlen(type)) + 1;
    strcpy(symbol->type, type);
    array_push(last_element(symbolTable->stack)->symbols, symbol);
}

void printSymbols (struct SymbolTable *symbolTable) {
    // Print current block
    if (symbolTable->symbols.length <= 0) goto print_child;
    PUTTAB(symbolTable->depth);
    printf("=======START=======\n");
    PUTTAB(symbolTable->depth);
    printf(" TYPE\tNAME\n");
    for (int i=0; i<symbolTable->symbols.length; i++) {
        PUTTAB(symbolTable->depth);
        printf(" %s\t%s\n", 
            symbolTable->symbols.data[i]->type, 
            symbolTable->symbols.data[i]->name);
    }
    PUTTAB(symbolTable->depth);
    printf("========END========\n");
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
int addToST = FALSE;
char* type;

%}
blank_char			[ \t\n]
letter 				[a-z|A-Z]
digit 				[0-9]
delimeter			;
space 				[ ]
comma				,

start_block			\{
end_block			\}

header 				#include(\<{letter}+\.h\>)|#include\"{letter}+(\.)?{letter}*\"

identifier 			({letter}|_)({letter}|{digit}|_)*(\[{positive_integer}\])?
data_type 			(void)|(int)|(char)|(float)|(double)|(struct({space}{identifier}))|(union({space}{identifier}))

parameter_list 		({identifier},)*({identifier})
function_call 		{identifier}\({parameter_list}\)|{identifier}\(\)

integer 			({digit})*
unsigned_integer	{integer}
signed_integer		(\+|\-)?{integer}
positive_integer	(\+)?{integer}

double				{integer}\.{integer}
unsigned_double		{double}
signed_double		(\+|\-)?{double}

assignment_operator	=
operator			(\+|\-|\*|\/|\+\+|\-\-|\%)
relational_operator	(\<|\<=|\>|\>=|==|!=)
logical_operator 	(&&|\|\||!)
bitwise_operator	(&|\||\^|~|\<\<|\>\>)

single_comment		\/\/.*
multi_comment		\/\*(.|\n)+\*\/

%%
{blank_char} 		;

{header} 			printf("header : %s\n", yytext);

{start_block}		{startNewBlock (symbolTable);};
{end_block}			{stopCurrentBlock (symbolTable);};


{data_type}			{
	type = (char*) malloc(yyleng);
	strcpy(type, yytext);
	addToST = TRUE;
	printf("data_type : %s\n", yytext);
};
{identifier}		{
	// Remove array braces if needed
	for (int i=0; i<yyleng; i++) {
		if (yytext[i] == '[') {
			yytext[i] = '\0';
			break;
		}
	}
	if (addToST) {
		if (hasSymbol(symbolTable, type, yytext))
			printf("Redeclaration error for %s\n", yytext);
		else
			addSymbol(symbolTable, type, yytext);
		
	}
	printf("identifier : %s\n", yytext);
};

{parameter_list}	printf("parameter_list : %s\n", yytext);
{function_call}		printf("function_call : %s\n", yytext);

{unsigned_integer}	printf("unsigned_integer : %s\n", yytext);
{signed_integer}	printf("signed_integer : %s\n", yytext);

{single_comment}	printf("single_comment : %s\n", yytext);
{multi_comment}		printf("multi_comment : %s\n", yytext);

{assignment_operator} printf("assignment_operator : %s\n", yytext);
{operator}			printf("operator : %s\n", yytext);
{relational_operator} printf("relational_operator : %s\n", yytext);
{logical_operator}	printf("logical_operator : %s\n", yytext);
{bitwise_operator}	printf("bitwise_operator : %s\n", yytext);

{delimeter}			{ if (addToST) addToST = FALSE; }
{comma}				;
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