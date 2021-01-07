#include <stdio.h>
#include <stdbool.h>
#include <unistd.h>


int main(int argc, char *argv[])
{
    printf("Victim running with PID %d\n", getpid());

    while (true)
    {
        sleep(1);
    }
}
