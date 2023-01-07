#include <stdio.h>

int fib(int ains) {
    int n = ains;           //  compute nth Fibonacci number
    int f1 = 1, f2 = -1;    //  last two Fibonacci numbers

    while (n != 0) {        //  count down to n = 0
        f1 = f1 + f2;
        f2 = f1 - f2;
        n = n - 1;
    }
    return f1;
}

int main(void) {
    int n, res;
    printf("gimme num: ");
    scanf("%i", &n);
    res = fib(n);
    printf("Result of fib(%d): %d\n", n, res);
}