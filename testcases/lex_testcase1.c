// ******************************
// Authors
// Manoj Kumar 15CO128
// Hrishikesh Hiraskar 15CO121
// ******************************

#include<stdio.h>

int main()
{
	printf("Test case for scanning\n");
    
    // Line to validate the tokenization of single line comments
    
    /* This comment tests 
     * multi line comments
     */

    // Identifiers
	double aBA=1e5;
	char _12='x';
	double A_1=12.0;

    // Array
    int arr[5] = {1, 2, 3, 4, 5};

    // Operators Tests
    int a = 2;
	int b = 1;
	int c = a + b;
	c = a % b;
	c = a++;

    int flag = 1;
    // If condition
	if (flag == 1)
		printf("Hello World!\n");
    
    // If else condition
	if (flag == 1)
		printf("Hello World!\n");
	else 
		printf("Bye World!\n");

    // Else if ladder
	if (flag == 1)
		printf("Hello World!\n");
	else if (flag == 0)
		printf("Hi World!\n");
	else 
		printf("Bye World!\n");

    // For loop
    for (int i = 0; i < 5; i++) {
		printf("*");
	}
	printf("\n");

    // Nested For loop
	for (int i = 5; i >= 0; i--) {
		for (int j = 0; j < i; j++) {
			printf("*");
		}
		printf("\n");
	}

    // While loop
    int i = 5;
    while (i >= 0) {
        printf("*");
        i--;
    }
    printf("\n");

    // Nested while loop
    i = 5;
    while (i >= 0) {
		int j = i;
		while (j >= 0) {
			printf("*");
			j--;
		}
		printf("\n");
		i--;
	}

	return 0;
}