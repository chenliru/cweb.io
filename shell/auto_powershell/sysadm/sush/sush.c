#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
   setuid( 0 );
   system( "$PWD/sush.ksh > $PWD/sush.out 2>&1" );

   return 0;
}

