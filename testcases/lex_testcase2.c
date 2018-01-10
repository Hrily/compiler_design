/******************************
 * Authors
 * Manoj Kumar 15CO128
 * Hrishikesh Hiraskar 15CO121
 ******************************/
/* 

    This file includes scenarios that throw lexical errors such as

    * invalid identifiers
    * invalid literals (invalid constants)
    * unexpected tokens
    * illegal preprocessor directives
    * illegal escape sequences in a string

*/


#include<a.h> //invalid header file

int main()
{
    double 1a, a;       // invalid identifier    

    a = 1e*3;           //illegal floating constant

    a = 1.0.01          //illegal floating constant

    printf("abc\qadc"); //illegal escape seqences




    return 0;
}