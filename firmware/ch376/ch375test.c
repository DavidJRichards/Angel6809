// djrm ch376 test program
// build for ram loading
// cmoc -i --org=1000  --srec ch375.c ch375test.c 

#include <cmoc.h>
#include <stdarg.h>
#include "types.h"
#include "ch375.h"

uint_fast8_t dev = 0;   // first device (IGNORED)
bool is_read = 1;       // read
uint32_t lba = 0;       // block 0
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


void dump(unsigned char * data)
{
  int i,j,k,t;
  unsigned char c;
  char buffer_[12];
  printf("\n   \t");
  for(i=0; i< 32; i++)
  {
    sprintf(buffer_,"%02x",i);
    printf("%s ",buffer_);
  }
  printf("\n\n");

  k=0;
  for(j=0; j<16; j++)
  {
    t=k;
    sprintf(buffer_,"%03x",k);
    printf("%s\t",buffer_);

    for(i=0; i< 32; i++)
    {
        c=data[k++];
        sprintf(buffer_,"%02x",c);
        printf("%s,",buffer_);
    }
    k=t;
    printf("\t");
    for(i=0; i< 32; i++)
    {
        c=data[k++];
        if(c>=0x20 && c<=0x7f)
          printf("%c",c);
        else
          printf(".");
    }
    printf("\n");
  }
}


int main(void)
{
  int i;
  for(i=0; i<512; i++)
    dptr[i]=0x24;

  oldCHROUT = setConsoleOutHook(newOutputRoutine);
  printf("ch375 test\n");

  if(ch375_probe())
  {
    ch375_xfer(dev, is_read, lba, dptr); 
    dump(dptr);
    printf("\n");
  }

  return 0;
}

void nap20(void)
{
  asm{
  pshs  x
  ldx #1
	; ***************************
	; ROUTINE:		DLY
	; PURPOSE:		DELAY ROUT1NE
	; ENTRY:		REGISTER X = COUNT
	; EXIT:			REGISTER X = 0
	; REGISTERS USED:	X
	; ****************************

DLY	  BRA	DLY1
DLY1	BRA	DLY2
DLY2	BRA	DLY3
DLY3	BRA	DLY4
DLY4	LEAX	-1,X
	    BNE	DLY
      puls  x,pc
  }
}


