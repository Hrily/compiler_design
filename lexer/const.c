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

void printconstants (struct ConstantTable* constantTable) {
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

int main () {
    struct ConstantTable* constantTable = initConstantTable();
    addConstant(constantTable, "1");
    addConstant(constantTable, "2");
    addConstant(constantTable, "2.0");
    addConstant(constantTable, "1");
    printconstants(constantTable);
}