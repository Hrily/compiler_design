#include<stdio.h>
#include<stdlib.h>

int a=10, b=5;
void printGlobal()
{
    printf("%d %d\n", a, b);
}
int main()
{
    int a=7, b=4;
    if(1)
    {
        int a=6, b=3;
        printf("%d %d\n", a, b);
    }
    printf("%d %d\n", a, b);
    printGlobal();
    return 0;
}