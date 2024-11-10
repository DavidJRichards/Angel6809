// djrm ch376 test program
// build for ram loading
// cmoc -i --org=1000  --srec ch375.c ch375test.c 

#include <cmoc.h>
#include <stdarg.h>
#include "types.h"
#include "ch375.h"

uint_fast8_t dev = 0;   // first device
bool is_read = 1;       // read
uint32_t lba = 10;      // block 10
uint8_t dptr[512];      // data buffer

#define ASSIST09_OUTCH 1
#define ASSIST09_PDATA 3
ConsoleOutHook oldCHROUT;

void newOutputRoutine(void)
{
    const char msg = '\x04'; // empty message string - just send crlf
    asm
    {
        pshs    U,x,b // preserve registers used by this routine, except A
        cmpa    #13 // cr
        bne     @outch
        leax    msg
        swi
        fcb     ASSIST09_PDATA
        bra     @done
@outch: swi
        fcb     ASSIST09_OUTCH
@done:  puls    U,x,b
    }
}

int main(void)
{
  oldCHROUT = setConsoleOutHook(newOutputRoutine);
  printf("ch375 test!\n\r");

  if(ch375_probe())
  {
    ch375_xfer(dev, is_read, lba, dptr); 
  }
  return 0;
}

void nap20(void)
{
asm{
  pshs  x
  ldx #20
	; ***************************
	; ROUTINE:		DLY
	; PURPOSE:		DELAY ROUT1NE
	; ENTRY:		REGISTER X = COUNT
	; EXIT:			REGISTER X = 0
	; REGISTERS USED:	X
	; ****************************

DLY	BRA	DLY1
DLY1	BRA	DLY2
DLY2	BRA	DLY3
DLY3	BRA	DLY4
DLY4	LEAX	-1,X
	BNE	DLY
  puls  x,pc
;	RTS
}
}

void ch375_rblock(uint8_t *ptr)
{
  ;// __z88dk_fastcall;
}
void ch375_wblock(uint8_t *ptr)
{
  ;// __z88dk_fastcall;
}


