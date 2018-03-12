#ifndef _SEMANTIC_H_
#define _SEMANTIC_H_

#include <string.h>
#include "parse_tree.h"
#include "symbol_table.h"

extern struct SymbolTable* symbolTable;
extern void yyerror (char *s);

#define TYPE_INT    1
#define TYPE_DOUBLE 2
#define TYPE_CHAR   3
#define TYPE_STRING 4
#define TYPE_VOID   5

// Scope
int scopes[1000];
int scopesLength = 1;
int scopeCounter = 1;

int getCurrentScope () 
{
    return scopes[scopesLength - 1];
}

void startNewScope () 
{
   scopes[scopesLength++] = scopeCounter++;
}

void endCurrentScope () 
{
    scopesLength--;
}

int isScopeValid (int scope)
{
   for (int i = scopesLength-1; i>=0; i--)
        if (scopes[i] == scope)
            return 1;
   return 0;
}

char* getType (char* name, int scope)
{
    for (int i = scopesLength - 1; i >= 0; i--)
    {
        struct Symbol* symbol = findSymbol(symbolTable, name, scopes[i]);
        if (symbol == NULL) continue;
        return symbol->type;
    }
    printf("Unknown identifier %s\n", name);
    yyerror("Unknown identifier\n");
    return NULL;
}

int equal (char* s, char* t)
{
    return strcmp(s, t) == 0;
}

int getTypeConstant (char* type) 
{
   if (equal(type, "int"))
       return TYPE_INT;
   if (equal(type, "double"))
       return TYPE_DOUBLE;
   if (equal(type, "char"))
       return TYPE_CHAR;
   if (equal(type, "string"))
       return TYPE_STRING;
       return TYPE_CHAR;
   if (equal(type, "void"))
       return TYPE_VOID;
}


int checkAndGetTypes (struct tree* parseTree, int scope)
{
    if (parseTree == NULL)
        return 0;
    switch (parseTree->nodetype)
    {
        case operator_node: {
            int leftType  = checkAndGetTypes(
                parseTree->body.an_operator.left,  scope);
            int rightType = checkAndGetTypes(
                parseTree->body.an_operator.right, scope);
            // printf("operator %s left %d right %d\n", parseTree->body.an_operator.operator, leftType, rightType);
            if (leftType == -1 || rightType == -1)
                return -1;
            if (leftType == 0)
                return rightType;
            if (rightType == 0)
                return leftType;
            if (leftType == TYPE_STRING && rightType == TYPE_STRING)
                return TYPE_STRING;
            if (leftType != TYPE_STRING && rightType != TYPE_STRING)
                return leftType;
            return -1;
        }
        case number_node:
            return TYPE_INT;
        case char_node:
            return TYPE_CHAR;
        case string_node:
            return TYPE_STRING;
        case double_node:
            return TYPE_DOUBLE;
        case variable_node: {
            char* type = getType(parseTree->body.a_variable, scope);
            return getTypeConstant(type);
        }
    }
}

int checkType (struct tree* parseTree, int scope)
{
    return checkAndGetTypes(parseTree, scope) != -1;
}

#endif
