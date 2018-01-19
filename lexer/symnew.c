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

int main () {
    struct SymbolTable* symbolTable = initSymbolTable();
    addSymbol(symbolTable, "a");
    addSymbol(symbolTable, "b");
    addSymbol(symbolTable, "c");
    addSymbol(symbolTable, "a");
    printSymbols(symbolTable);
}