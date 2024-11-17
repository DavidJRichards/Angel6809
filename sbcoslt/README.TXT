Here are my SBC-2 Operating System Source Files.

They include:

sbc.asm   - The build file that includes all the other files in the proper order
            (you would assemble this file with TASS)

acia.asm - 65c51 init and IO support for monitor
sbcos.asm - monitor & minassembler
reset.asm - reset and IRQ initialization

Compiled using TASS using the following command line:
TASS /lsbc.lbl sbc.asm sbc.bin sbcos.lst

Code will be assembled starting at $FC00

The compiler list output file from TASS is called:
sbc25.lst

The label file contains all the labels and their addresses and is called:
sbc.lbl

There is 1 compiled file included:
sbc25.rom  -  the raw binary object file


Current object code occupies $FC00-$FFFF

To modify for another target platform, just update the ACIA1.ASM file to 
support these functions:

ACIA1_init - called from reset.asm - initialize the serial terminal device

ACIA1_Input - called from sbc2os.asm - wait for character from terminal, return in Acc

ACIA1_Scan - called from  sbc2os.asm - test for character from terminal - 
             no wait - return with Carry clear for no character, set for character
             last character will be in Acc if carry set - no need to call ACIA1_Input

ACIA1_Output - called from sbc2os.asm - send char in Acc to terminal

In sbc2os.asm, line 40-42, are the calls used from the OS to the terminal.

The SBC-2OS command syntax is as follows:

Syntax = {} required, [] optional, HHHH hex address, DD hex data

[HHHH][ HHHH]{Return} - Hex dump address(s)(up to 16 if no address entered)
[HHHH]{.HHHH}{Return} - Hex dump range of addresses (16 per line)
[HHHH]{:DD}[ DD]{Return} - Change data bytes (modify memory)
[HHHH]{G}{Return} - Execute a program (use RTS to return to monitor)
{HHHH.HHHH>HHHH{I}{Return} - move range at 2nd HHHH down to 1st to 3rd HHHH
{HHHH.HHHH>HHHH{M}{Return} - Move range at 1st HHHH thru 2nd to 3rd HHHH
{HHHH}{Q}{Return} - Text dump address
{HHHH.HHHH}{Q}{Return} - Text dump range of addresses (16 per line)
{R}{Return} - Print register contents from memory locations - used after BRK if needed
{V}{Return} - Monitor Version

To add a new command, just increment the value stored at CmdCount, on line 458 of sbc2os.asm.

Then, add the ASCII code of the new key (must not be a Hex digit, A-F) at the end of table
CmdAscii.

At the end of table Cmdjmptbl, add the start address label, minus 1

At the end of table Cmdseccode, add $00.  

Finally, in sbc.asm, include the new code file.  There are about 65 bytes open.  If your code 
is larger, then drop the *= $FC00 down as needed.

Good luck!

Daryl

