#ifndef _PARSE_TREE_H_
#define _PARSE_TREE_H_

#define step 4

// parse tree
enum treetype {operator_node, number_node, double_node, char_node, string_node, variable_node};
typedef struct tree {
   enum treetype nodetype;
   union {
     struct {struct tree *left, *right; char* operator;} an_operator;
     int a_number;
     char* a_variable;
     char* a_char;
     char* a_string;
     double a_double;
   } body;
} tree;

static tree *make_operator (tree *l, char* o, tree *r) {
   tree *result= (tree*) malloc (sizeof(tree));
   result->nodetype= operator_node;
   result->body.an_operator.left= l;
   result->body.an_operator.operator= copy(o);
   result->body.an_operator.right= r;
   return result;
}

static tree *make_number (int n) {
   tree *result= (tree*) malloc (sizeof(tree));
   result->nodetype= number_node;
   result->body.a_number= n;
   return result;
}

static tree *make_variable (char* v) {
   tree *result= (tree*) malloc (sizeof(tree));
   result->nodetype= variable_node;
   result->body.a_variable= copy(v);
   return result;
}

static tree *make_char (char* v) {
   tree *result= (tree*) malloc (sizeof(tree));
   result->nodetype= char_node;
   result->body.a_char = copy(v);
   return result;
}

static tree *make_string (char* v) {
   tree *result= (tree*) malloc (sizeof(tree));
   result->nodetype= string_node;
   result->body.a_string = copy(v);
   return result;
}

static tree *make_double (double v) {
   tree *result= (tree*) malloc (sizeof(tree));
   result->nodetype= double_node;
   result->body.a_double= v;
   return result;
}

static void printtree (tree *t, int level) {
   if (t)
     switch (t->nodetype)
     {
       case operator_node:
        printtree (t->body.an_operator.right, level+step);
        printf ("%*c%s\n", level, ' ', t->body.an_operator.operator);
        printtree (t->body.an_operator.left, level+step);
        break;
       case number_node:
        printf ("%*c%d\n", level, ' ', t->body.a_number);
        break;
       case string_node:
        printf ("%*c%s\n", level, ' ', t->body.a_string);
        break;
       case char_node:
        printf ("%*c%s\n", level, ' ', t->body.a_char);
        break;
       case variable_node:
        printf ("%*c%s\n", level, ' ', t->body.a_variable);
        break;
       case double_node:
        printf ("%*c%lf\n", level, ' ', t->body.a_double);
        break;
     }
}

#endif
