// build for ram loading
// cmoc -i --org=1000 --srec hello.c 
// When using GTKTerm
// at assit09 prompt use 'L' command
// then shift-control-R to transfer s-record file
// afterwards start program with C 1000
// Hello Workd! should be displayed

#include <cmoc.h>
#include <stdarg.h>

#define ASSIST09_OUTCH 1
#define ASSIST09_PDATA 3
ConsoleOutHook oldCHROUT;

#define LEDREG  0xC0F0

#define LED2  (*( unsigned char *) 0xC0F1)

unsigned char dummy=0;
unsigned char data=0;
unsigned int addr;


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
        oldCHROUT = setConsoleOutHook(newOutputRoutine);
//        oldCHROUT = setConsoleOutHook(0X101E);
        printf("Hello World!\n\r");

//        printf("LED1 Addr  %d\n\r", &LED1);
        data = LED2;
        printf("LED1 Data  %d\n\r", data);
//        printf("LED1 Value %d\n\r", *LED1);

        *( unsigned char *)LEDREG = 0x24;
        LED2 = 0X25;
        return 0;
}
