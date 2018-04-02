#ifndef _ICG_H_
#define _ICG_H_

#include <stdio.h>
#include <stdlib.h>
#include "parse_tree.h"
#include "symbol_table.h"

FILE* file;
int ln = 1;

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
			fprintf(file, "\tmov e%d, %s\n", level, t->body.an_operator.left->body.a_variable);
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
				fprintf(file, "\te%d = e%e + 1\n", level, level);
			if (equal(t->body.an_operator.operator, "--"))
				fprintf(file, "\te%d = e%e - 1\n", level, level);
			ln++;
			return;
		}
		// Binary?
		fprintf(file, "\te%d = e%d %s e%d\n", level, left, t->body.an_operator.operator, right);
		ln++;
	}
}


#endif
