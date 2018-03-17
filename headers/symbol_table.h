#ifndef _SYMBOL_TABLE_H_
#define _SYMBOL_TABLE_H_

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

char* copy (char* s) {
    char* r = (char*) malloc(strlen(s) + 1);
    strcpy(r, s);
    return r;
}

struct Symbol 
{
    char* name;
    char* type;
    int   scope;
    int   dimension;
    int   pdf;
    array(int) paramTypes;
};

void initParamTypes (struct Symbol* symbol)
{
    symbol->paramTypes = (typeof(symbol->paramTypes)) array_init();
}

void addParamType (struct Symbol* symbol, int type)
{
    array_push(symbol->paramTypes, type);
}

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

int hasSymbol (struct SymbolTable* symbolTable, char* name, int scope)
{
    if (scope < 0) 
    {
        for (int i=0; i<symbolTable->symbols.length; i++) 
        {
            if (strcmp(symbolTable->symbols.data[i]->name, name) == 0)
                return 1;
        }
        return 0;
    }
    for (int i=0; i<symbolTable->symbols.length; i++) 
    {
        if (strcmp(symbolTable->symbols.data[i]->name, name) == 0
              && symbolTable->symbols.data[i]->scope == scope)
            return 1;
    }
    return 0;
}

void addSymbol (struct SymbolTable* symbolTable, char* name, int scope)
{
    if (hasSymbol(symbolTable, name, scope))
        return;
    struct Symbol *symbol = (struct Symbol*)
        malloc(sizeof(struct Symbol));
    symbol->name = (char*) malloc(strlen(name)) + 1;
    symbol->scope = scope;
    symbol->type = NULL;
    symbol->dimension = 0;
    symbol->pdf = -1;
    strcpy(symbol->name, name);
    array_push(symbolTable->symbols, symbol);
}

struct Symbol* findSymbol (struct SymbolTable* symbolTable, 
        char* name, int scope) 
{
    if (scope < 0) 
    {
        for (int i=0; i<symbolTable->symbols.length; i++) 
        {
            if (strcmp(symbolTable->symbols.data[i]->name, name) == 0)
                return symbolTable->symbols.data[i];
        }
        return NULL;
    }
    for (int i=0; i<symbolTable->symbols.length; i++) 
    {
        if (strcmp(symbolTable->symbols.data[i]->name, name) == 0
              && symbolTable->symbols.data[i]->scope == scope)
            return symbolTable->symbols.data[i];
    }
    return NULL;
}

void addType (struct SymbolTable* symbolTable, char* name, char* type, int scope)
{
	struct Symbol* symbol = findSymbol(symbolTable, name, scope);
	if (symbol->type != NULL)
		yyerror("Redeclaration error");
	else
		symbol->type = copy(type);
}

void printSymbols (struct SymbolTable *symbolTable) {
    // Print current block
    if (symbolTable->symbols.length <= 0) 
        return;
    char* types[6] = {"", "int", "double", "char", "char*", "void"};
    printf("*** Symbol Table ***\n");
    printf("=================START=================\n");
    for (int i=0; i<symbolTable->symbols.length; i++) {
        struct Symbol* symbol = symbolTable->symbols.data[i];
        printf("%s\t%s\t%d\t", 
            symbol->type, 
            symbol->name, 
            symbol->scope);
        for (int i=0; i<symbol->paramTypes.length; i++)
            printf("%s, ", types[symbol->paramTypes.data[i]]);
        if (symbol->dimension > 0)
            printf("[%d]\t", symbol->dimension);
        if (symbol->pdf > -1)
            printf("%s\t", (symbol->pdf) ? "TRUE" : "FALSE");
        printf("\n");
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

void addConstant (struct ConstantTable* constantTable, char* text, char* type)
{
    if (hasConstant(constantTable, text))
        return;
    struct Constant *constant = (struct Constant*)
            malloc(sizeof(struct Constant));
    constant->text = (char*) malloc(strlen(text)) + 1;
    strcpy(constant->text, text);
    constant->type = (char*) malloc(strlen(type)) + 1;
    strcpy(constant->type, type);
    array_push(constantTable->constants, constant);
}

void printConstants (struct ConstantTable* constantTable) {
    // Print current block
    if (constantTable->constants.length <= 0) 
        return;
    printf("*** Constant Table ***\n");
    printf("=================START=================\n");
    for (int i=0; i<constantTable->constants.length; i++) {
        printf(" %s\t%s\n", constantTable->constants.data[i]->type, constantTable->constants.data[i]->text);
    }
    printf("==================END==================\n");
}

#endif
