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

char* current_function_call;
int current_function_call_scope;
struct Symbol* current_function_call_symbol;
array(int) current_function_param_types;

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

struct Symbol* getSymbolInScope (char* name)
{
    for (int i = scopesLength - 1; i >= 0; i--)
    {
        struct Symbol* symbol = findSymbol(symbolTable, name, scopes[i]);
        if (symbol == NULL) continue;
        return symbol;
    }
    return NULL;
}

char* getType (char* name, int scope)
{
    struct Symbol* symbol = getSymbolInScope(name);
    if (symbol)
        return symbol->type;
    printf("Unknown identifier %s\n", name);
    yyerror("Unknown identifier\n");
    return NULL;
}

int getTypeConstant (char* type) 
{
    if (type == NULL)
        return 0;
    if (equal(type, "int"))
        return TYPE_INT;
    if (equal(type, "double"))
        return TYPE_DOUBLE;
    if (equal(type, "char"))
        return TYPE_CHAR;
    if (equal(type, "char*"))
        return TYPE_STRING;
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

void setDimension (struct tree* idNode, int dimension)
{
   if (dimension < 1){
      yyerror("Invalid array size");
      return ;
      }
    char* name = idNode->body.a_variable;
    struct Symbol* symbol = getSymbolInScope(name);
    if (symbol && symbol->dimension == 0)
        symbol->dimension = dimension;
}

void setCurrentFunctionCall (char* name, int scope)
{
    current_function_call = copy(name);
    current_function_call_scope = scope;
    current_function_param_types = 
        (typeof(current_function_param_types)) array_init();
}

void addCurrentFunctionParamType (int type)
{
    array_push(current_function_param_types, type);
}

struct Symbol* getFunctionCallDefinition (char* name)
{
    for (int i = scopesLength - 1; i >= 0; i--)
    {
        struct Symbol* symbol = findSymbol(symbolTable, name, scopes[i]);
        if (symbol == NULL) continue;
        if (symbol->pdf == -1)
            return symbol;
    }
    return NULL;
}

void checkCurrentFunctionCallTypes ()
{

    // Add to symbol table
    current_function_call_symbol = addSymbol(symbolTable, 
            current_function_call, current_function_call_scope);
    current_function_call_symbol->pdf = 0;

    struct Symbol* symbol = getFunctionCallDefinition(current_function_call);

    if (symbol == NULL)
    {
        current_function_call_symbol->pdf = 0;
        return;
    } 
    current_function_call_symbol->pdf =  1;

    int original_length = symbol->paramTypes.length;
    int new_lenght = current_function_param_types.length;

    if (original_length != new_lenght)
    {
        printCurrentFunctionError(symbol);
        return;
    }
    
    for (int i = 0; i < original_length; i++)
        if (current_function_param_types.data[i] != symbol->paramTypes.data[i])
            printCurrentFunctionError(symbol);

    current_function_call_symbol->type = 
            copy(symbol->type);
}

void printCurrentFunctionError (struct Symbol* symbol)
{
    printf("No definition matches function call %s\n", symbol->name);
    yyerror("Invalid function call");
    // TODO: print more verbose error
}

#endif
