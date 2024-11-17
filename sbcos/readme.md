# Enhanced Basic & SBCOS

Here is Enhanced Basic together with SBCOS modified to run on the stock MECB 6850 ACIA, it is quite an easy port and I found it able to run in RAM or ROM. The basic is quite complete and has full source available. The monitor isn't half bad either having both assembler and disassembler built in.

```
65C02 Monitor v5.1 (5-30-05) Ready
with Enhanced Basic Interpreter (c) Lee Davison
(Press ? for help)
>?
Current commands are :
Syntax = {} required, [] optional, HHHH hex address, DD hex data

[HHHH][ HHHH]{Return} - Hex dump address(s)(up to 16 if no address entered)
[HHHH]{.HHHH}{Return} - Hex dump range of addresses (16 per line)
[HHHH]{:DD}[ DD]{Return} - Change data bytes
[HHHH]{G}{Return} - Execute a program (use RTS to return to monitor)
{HHHH.HHHH>HHHH{I}{Return} - move range at 2nd HHHH down to 1st to 3rd HHHH
[HHHH]{L}{Return} - List (disassemble) 20 lines of program
[HHHH]{.HHHH}{L}{Return} - Dissassemble a range
{HHHH.HHHH>HHHH{M}{Return} - Move range at 1st HHHH thru 2nd to 3rd HHHH
[HHHH][ HHHH]{Q}{Return} - Text dump address(s)
[HHHH]{.HHHH}{Q}{Return} - Text dump range of addresses (16 per line)
{R}{Return} - Print register contents from memory locations
{U}{Return} - Upload File (Xmodem/CRC or Intel Hex)
{V}{Return} - Monitor Version
{HHHH.HHHH>HHHH{W}{Return} - Write data in RAM to EEPROM
{!}{Return} - Enter Assembler
{@}{Return} - Cold-Start Enhanced Basic
{#}{Return} - Warm_Start Enhanced Basic
{?}{Return} - Print menu of commands

>@
Memory size ? 
31743 Bytes free
Enhanced BASIC 2.22
Ready
10 PRINT("Hello World!");
Ready
RUN
Hello World!
Ready
LIST
10 PRINT("Hello World!");
Ready
```

SBCOS with basic is from here: https://sbc.rictor.org/info2.html
Extended basic archive here: https://github.com/Klaus2m5/6502_EhBASIC_V2.22

To build for ram execution the various org statements in the code are commented out, the ```*=$9000``` is replace with a ram address, i.e. ```*=$2000```

To convert the binary image to s-records srec-cat is used:

```srec_cat SBC.BIN -binary -offset 0x1ffe -output SBC.HEX -Intel -address-length=2
```

* Note the offeset needed is two less than the code start address.
* Note the top of RAM address is hard coded in the basic source as constant "Ram_top" for 32k RAM I set this to $8000, for 2k ram I set this to $1f00 ($2000 possibly ok)

* Console I/O defaults to 6850 ACIA at $C008 9600 bps 
* File and device name changed, VIA2 removed from build.
* VIA1 (PS2KB) and ACIA1 (6551) initialised but nor used.
* LEDS show '6502'

