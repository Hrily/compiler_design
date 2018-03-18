%{

#include "y.tab.h"

extern struct SymbolTable* symbolTable;
extern struct ConstantTable* constantTable;
extern struct Symbol* addSymbol(struct SymbolTable*, char*);
extern void addConstant(struct ConstantTable*, char*, char*);
extern char* copy(char*);

int line = 1;

%}
blank_char			[ \t\n]
letter 				[a-z|A-Z]
digit 				[0-9]
delimeter			;
space 				[ \t]
comma				,

start_block			\{
end_block			\}

keyword				auto|double|int|struct|break|else|long|switch|case|enum|register|typedef|char|extern|return|union|const|float|short|unsigned|continue|for|signed|void|default|goto|sizeof|volatile|do|if|static|while

header 				#include({space}*)(\<{letter}+\.h\>)|#include({space}*)\"{letter}+(\.)?{letter}*\"

identifier 			({letter}|_)({letter}|{digit}|_)*
data_type 			(void)|(int)|(char)|(float)|(double)|(struct({space}{identifier}))|(union({space}{identifier}))
nonidentifier		[^a-zA-Z_,.; \t\n]([^0-9,.; \t\n])+([^, \t\n.;])*

parameter_list 		({identifier},)*({identifier})

integer 			({digit})+
unsigned_integer	{integer}
signed_integer		(\+|\-)?{integer}
positive_integer	(\+)?{integer}

double				({integer}\.{integer}([eE]{integer})?)|({integer}[eE]{integer})
unsigned_double		{double}
signed_double		(\+|\-)?{double}
nondouble			{digit}+(\.{integer})(\.{integer})+

char_constant       '(.|(\\a)|(\\b)|(\\f)|(\\n)|(\\r)|(\\t)|(\\v)|(\\')|(\\\")|(\\\\)|(\\\?))'
string_constant		\".*\"

constant            {integer}|{unsigned_integer}|{signed_integer}|{positive_integer}|{double}|{unsigned_double}|{signed_double}|{char_constant}|{string_constant}

operator			(\+|\-|\*|\/|\%)
relational_operator	(\<|\<=|\>|\>=|==|!=)
logical_operator 	(&&|\|\||!)
bitwise_operator	(&|\||\^|~|\<\<|\>\>)

single_comment		\/\/.*
multi_comment		\/\*(.|\n)+\*\/

case                "case"
default             "default"
if                  "if"
else                "else"
switch              "switch"
while               "while"
do                  "do"
for                 "for"

goto                "goto"
continue            "continue"
break               "break"
return              "return"

assignment_operator	"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"|="|"^="
shift_op_l          "<<"
shift_op_r          ">>"
lt_comp             "<"
gt_comp             ">"
lte_comp            "<="
gte_comp            ">="
equality_op         "=="
not_equality_op     "!="
and_op              "&&"
or_op               "||"
inc_op              "++"
dec_op              "--"

%%
[\n]                line++;
{blank_char} 		;


{header} 			printf("header : %s\n", yytext);

{case}              return CASE;
{default}           return DEFAULT;
{if}                return IF;
{else}              return ELSE;
{switch}            return SWITCH;
{while}             return WHILE;
{do}                return DO;
{for}               return FOR;

{goto}              return GOTO;
{continue}          return CONTINUE;
{break}             return BREAK;
{return}            return RETURN;

{assignment_operator} {
    yylval.sval = copy(yytext);
    return ASSIGNMENT;
}
{shift_op_l}        return SHIFT_OP_L;
{shift_op_l}        return SHIFT_OP_R;
{lt_comp}           return LT_COMP;
{gt_comp}           return GT_COMP;
{lte_comp}          return LTE_COMP;
{gte_comp}          return GTE_COMP;
{equality_op}       return EQUALITY_OP;
{not_equality_op}   return NOT_EQUALITY_OP;
{and_op}            return AND_OP;
{or_op}             return OR_OP;
{inc_op}            return INC_OP;
{dec_op}            return DEC_OP;

{start_block}		return yytext[0];
{end_block}			return yytext[0];

{data_type}    		{
    printf("data_type : %s\n", yytext);
    yylval.dt = copy(yytext);
    return DATATYPE;
}
{keyword}      		{printf("keyword : %s\n", yytext);}
{identifier}		{
    printf("identifier : %s\n", yytext);
    yylval.sval = copy(yytext);
    return ID;
};

{parameter_list}	printf("parameter_list : %s\n", yytext);

{nondouble}			printf("Illegal double constant : %s\n", yytext);
{double}			{
    printf("double : %s\n", yytext); 
    addConstant(constantTable, yytext, "double"); 
    yylval.dval = atoi(yytext);
    return DOUBLE;
}
{integer}			{
    printf("integer : %s\n", yytext); 
    addConstant(constantTable, yytext, "int"); 
    yylval.ival = atoi(yytext);
    return INT;
}

{string_constant}	{
    printf("string_constant : %s\n", yytext); 
    addConstant(constantTable, yytext, "string"); 
    yylval.sval = copy(yytext);
    return STRING;
}
{char_constant}	    {
    printf("char_constant : %s\n", yytext); 
    addConstant(constantTable, yytext, "char"); 
    yylval.sval = copy(yytext);
    return CHAR;
}


{single_comment}	printf("single_comment : %s\n", yytext);
{multi_comment}		printf("multi_comment : %s\n", yytext);

{operator}			{printf("operator : %s\n", yytext); return yytext[0];}
{relational_operator} {printf("reltional_operator : %s\n", yytext); return yytext[0];}
{logical_operator}	{printf("logical_operator : %s\n", yytext); return yytext[0];}
{bitwise_operator}	{printf("bitwise_operator : %s\n", yytext); return yytext[0];}

{delimeter}			return yytext[0];
{comma}				return yytext[0];
[(){}]|\[|\]        return yytext[0];
<<EOF>>             return -1;

[^ \t\n]			printf("Invalid character : %s\n", yytext);

%%

// int main () {
// 	symbolTable = initSymbolTable();
// 	constantTable = initConstantTable();
// 	yyin = fopen("test.c", "r");
// 	yylex();
// 	fclose(yyin);
// }

int yywrap () {
	return -1;
}
