#include <cmoc.h>
#include <stdarg.h>

#define ASSIST09_OUTCH 1
#define ASSIST09_PDATA 3
ConsoleOutHook oldCHROUT;

void newOutputRoutine(void)
{
    const char msg = '\x04'; // empty message string - just send crlf
    asm
    {
        pshs    x,b // preserve registers used by this routine, except A
        cmpa    #13 // cr
        bne     @outch
        leax    msg
        swi
        fcb     ASSIST09_PDATA
        bra     @done
@outch: swi
        fcb     ASSIST09_OUTCH
@done:  puls    x,b
    }
}

int main(void)
{
//        oldCHROUT = setConsoleOutHook(newOutputRoutine);
        oldCHROUT = setConsoleOutHook(0X101E);
        printf("Hello World!\n\r");
//        setConsoleOutHook(oldCHROUT);
        return 0;
}
