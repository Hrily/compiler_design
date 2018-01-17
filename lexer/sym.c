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

int main(void)
{
    struct SymbolTable *symbolTable = initSymbolTable(0);
    addSymbol(symbolTable, "a");
    addSymbol(symbolTable, "b");
        startNewBlock(symbolTable);
        addSymbol(symbolTable, "c");
        stopCurrentBlock(symbolTable);
    addSymbol(symbolTable, "d");    
    printSymbols(symbolTable);
    struct Symbol* s = findSymbol(symbolTable, "a");
    printf("%s\n", s->name);
}