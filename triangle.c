#include <stdio.h>

// Declare the manager function
extern double manager();

int main() {
    printf("Welcome to Huron’s Triangle Area Calculator!\n");

    // Call the manager function
    double area = manager();

    // Print the computed area
    printf("Computed Triangle Area: %f\n", area);
    printf("Thank you for using this program!\n");

    return 0;
}