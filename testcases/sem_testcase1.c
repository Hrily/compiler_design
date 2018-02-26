#include<stdio.h>
#include<stdlib.h>

int add (int a, int b)
{
    return a + b;
}
int main()
{
    int a;
    float b;
    scanf("%d%f", &a, &b);
    printf("%d\n", add(a, b));
    return 0;
}