// ******************************
// Authors
// Manoj Kumar 15CO128
// Hrishikesh Hiraskar 15CO121
// ******************************
/* 

    This file includes scenarios that throw lexical errors such as

    * invalid literals (invalid constants)
    

*/


#include<stdio.h> 

int main()
{
    double 1a, a;           

    a = 192.168.0.1;           //illegal floating constant

    a = 1.0.01                 //illegal floating constant

    return 0;
}