#include <stdio.h>

int main () {
    
    // Declaration 
    int a = 0, b;
    int c;

    // Arithmetic expression
    a = b*(c+3)%a;

    // Logical expression
    a = (b == 3) && c > 1;

    // Assignment
    a += 3;

    // Iteration
    for (int i=0; i<10; i++) {
        // Postfix
        a++;
        // Prefix;
        --b;
    }

    // Condition
    if (a > b) {
        a = 4;
    } else {
        b = 4;
    }
}