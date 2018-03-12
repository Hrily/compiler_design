yacc -d parser/yac.y 
lex lexer/lex.l
cc y.tab.c lex.yy.c -g -w
