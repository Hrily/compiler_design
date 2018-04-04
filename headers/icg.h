#ifndef _ICG_H_
#define _ICG_H_

#include <stdio.h>
#include <stdlib.h>
#include "parse_tree.h"
#include "symbol_table.h"

#define SIZE 100

FILE* file;
int ln = 1;

int labels[SIZE];
int labell = 0;

int if_labels[SIZE];
int if_labell = 0;

int else_labels[SIZE];
int else_labell = 0;

int while_labels[SIZE];
int while_labell = 0;

int for_labels[SIZE];
int for_labell = 0;

int sink[SIZE];
int sinkl = 0;

int labelc = 0;

void icgInit ()
{
	file = fopen("b.out", "w");
}

void getLine ()
{
	return ln;
}

void convertTree (struct tree* t, int level)
{
	if (t == NULL)
		return;

	if (t->nodetype == number_node)
	{
		fprintf(file, "\tmov %d, e%d\n", t->body.a_number, level);
		ln++;
		return;
	}
	
	if (t->nodetype == double_node)
	{
		fprintf(file, "\tmov %llf, e%d\n", t->body.a_double, level);
		ln++;
		return;
	}

	if (t->nodetype == char_node)
	{
		fprintf(file, "\tmov %c, e%d\n", t->body.a_char, level);
		ln++;
		return;
	}

	if (t->nodetype == string_node)
	{
		fprintf(file, "\tmov %s, e%d\n", t->body.a_string, level);
		ln++;
		return;
	}

	if (t->nodetype == variable_node)
	{
		if (t->index > -1) {
			fprintf(file, "\tmov %d, ind\n", t->index);
			fprintf(file, "\tind = ind * 4\n");
			fprintf(file, "\tmov %s+ind, e%d\n", t->body.a_variable, level);
			ln+=2;
		}else if (t->s_index != NULL) {
			fprintf(file, "\tmov %s, ind\n", t->s_index);
			fprintf(file, "\tind = ind * 4\n");
			fprintf(file, "\tmov %s+ind, e%d\n", t->body.a_variable, level);
			ln+=2;
		}else
			fprintf(file, "\tmov %s, e%d\n", t->body.a_variable, level);
		ln++;
		return;
	}

	if (t->nodetype == operator_node) 
	{
		int left  = level*2,
		    right = level*2 + 1;
		// Assignment?
		if (equal(t->body.an_operator.operator, "="))
		{
			convertTree(t->body.an_operator.right, right);
			struct tree* c = t->body.an_operator.left;
			if (c->index > -1) {
				fprintf(file, "\tmov %d, ind\n", c->index);
				fprintf(file, "\tind = ind * 4\n");
				fprintf(file, "\tmov e%d, %s+ind\n", level, c->body.a_variable);
				ln+=2;
			}else if (c->s_index != NULL) {
				fprintf(file, "\tmov %s, ind\n", c->s_index);
				fprintf(file, "\tind = ind * 4\n");
				fprintf(file, "\tmov e%d, %s+ind\n", level, c->body.a_variable);
				ln+=2;
			}else
				fprintf(file, "\tmov e%d, %s\n", right, t->body.an_operator.left->body.a_variable);
			ln++;
			return;
		}

		convertTree(t->body.an_operator.left, left);
		convertTree(t->body.an_operator.right, right);
		// Unary?
		if (t->body.an_operator.left == NULL ||
			t->body.an_operator.right == NULL)
		{
			if (equal(t->body.an_operator.operator, "++"))
				fprintf(file, "\te%d = e%d + 1\n", level, level);
			if (equal(t->body.an_operator.operator, "--"))
				fprintf(file, "\te%d = e%d - 1\n", level, level);
			ln++;
			return;
		}
		// Binary?
		fprintf(file, "\te%d = e%d %s e%d\n", level, left, t->body.an_operator.operator, right);
		ln++;
	}
}

void addLabel (char* s)
{
	fprintf(file, "\n\n%s:\n", s);
	ln++;
}

void addIndex (struct tree* t, int index)
{
	t->index = index;
}

void addSIndex (struct tree* t, char* s)
{
	struct Symbol* symbol = getSymbolInScope(s);
	if (s == NULL) 
	{
		printf("Unknown Identifier: %s\n", s);
		yyerror("Unknown Identifier");
		return;
	}
	int type = getTypeConstant(symbol->type);
	if (type != TYPE_INT)
	{
		yyerror("Array index not of integer type");
		return;
	}
	t->s_index = copy(s);
	printf("tindex%s\n", t->s_index);
}

void preIf ()
{
	fprintf(file, "\tif e1 goto label%d\n", labelc++);
	ln++;
	fprintf(file, "\tgoto label%d\n", labelc++);
	ln++;
	if_labels[if_labell++] = labelc-1;
	fprintf(file, "label%d:\n", labelc-2);
	ln++;
}

void preIf1 ()
{
	sink[sinkl++] = -1;
}

void postIf ()
{
	fprintf(file, "label%d:\n", if_labels[--if_labell]);
	ln++;
}

void postIf2 () 
{	
	sinkl--;
}

void preElseIf ()
{
	fprintf(file, "label%d:\n", if_labels[--if_labell]);
	ln++;
}

void preElse () 
{
	printf("preElse l%d s%d\n", labelc-1, sink[sinkl-1]);
	if (sink[sinkl-1] == -1){
		// Create a lable
		fprintf(file, "\tgoto label%d\n", labelc++);
		printf("preElse %d\n", labelc-1);
		sink[sinkl-1] = labelc-1;
	}else
		fprintf(file, "\tgoto label%d\n", sink[sinkl-1]);

	ln++;
}

void postElse ()
{
	fprintf(file, "label%d:\n", sink[sinkl-1]);
	ln++;
}

void preWhile ()
{
	fprintf(file, "label%d:\n", labelc++);
	ln++;
	while_labels[while_labell++] = labelc-1;
}

void postWhile ()
{
	fprintf(file, "\tgoto label%d\n", while_labels[--while_labell]);
	postIf();
}

void preFor1 ()
{
	fprintf(file, "label%d\n", labelc++);
	ln++;
}

void preFor2 ()
{
	fprintf(file, "\tif e1 goto label%d\n", labelc+2); //TODO
	ln++;
	fprintf(file, "\tgoto label%d\n", labelc++);
	ln++;
	for_labels[for_labell++] = labelc-1;

	fprintf(file, "label%d\n", labelc++);
	ln++;
	for_labels[for_labell++] = labelc-1;
}

void preFor3 () 
{
	fprintf(file, "\tgoto label%d\n", labelc-3);
	ln++;
	fprintf(file, "label%d\n", labelc++);
	ln++;
}

void postFor ()
{
	fprintf(file, "\tgoto label%d\n", for_labels[--for_labell]);
	ln++;
	fprintf(file, "label%d\n", for_labels[--for_labell]);
	ln++;
}

#endif
