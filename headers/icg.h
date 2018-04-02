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

void postIf ()
{
	fprintf(file, "label%d:\n", if_labels[--if_labell]);
	ln++;
}

void preElse () 
{
	fprintf(file, "\tgoto label%d\n", labelc++);
	ln++;
	else_labels[else_labell++] = labelc-1;
}

void postElse ()
{
	fprintf(file, "label%d:\n", else_labels[--else_labell]);
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

#endif
