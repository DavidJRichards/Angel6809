# Angel6809

Historical 6809 development board, resurrected in MAME.

Derived from Digicoolthings mecb MAIM configuration with changes gleaned from other sources

[mecb6809](https://github.com/epaell/MECB)

## Features

* 2k monitor rom
* 8k figForth rom
* 8k battery backed ram
* 2k scratch ram
* 6551 acia
* 6522 via
* 6818 rtc
* polled keyboard
* 2x40 LCD display
* RS232 interface

[MAME files](./mame)

![Boad top view](./photos/20140502_180034.jpg)

![Boad bottom view](./photos/20140502_180118.jpg)

![Keyboard](./photos/IMG_20210312_213837.png)

![2x40 LCD](./photos/LCD_2x40.png)

## Memory Map

```
Z0142   EQU     $0142	; Forth cold entry
Z0194   EQU     $0194	; Forth warm entry
M0400   EQU     $0400	; keyboard delay

M8000   EQU     $8000 ; VIA
M8002   EQU     $8002 ; VIA_

MC400   EQU     $C400 ; ACIA

MC800   EQU     $C800 ; LCD
MC801   EQU     $C801 ; LCD_

MD000   EQU     $D000 ; CLOCK
MD001   EQU     $D001 ; CLOCK_

MDIPG   EQU	$D7   ; Monitor direct page
ME100   EQU     $D100 ; RX BUFFER
ME200   EQU     $D200 ; FILL INDEX
ME201   EQU     $D201 ; FULL FLAG
ME7B0   EQU     $D7B0 ; STACK
ME7D0   EQU     $D7D0 ; MONITOR STACK
ZE7E5   EQU     $D7E5 ; SW3 / USR VEC
ZE7E7   EQU     $D7E7 ; SW2 VEC
ZE7E9   EQU     $D7E9 ; FIQ VEC
ME7EC   EQU     $D7EC ; KB TMP
ME7ED   EQU     $D7ED ; CHSM
ZE7F2   EQU     $D7F2 ; NMI VEC
ZE7F4   EQU     $D7F4 ; IRQ VEC
ZE7F6   EQU     $D7F6 ; SWI VEC
M00F8   EQU     $F8   ; stack save 
ME7F8   EQU     $D7F8 ; STK SAV
ME7FA   EQU     $D7FA ; QT VEC
ZE7FC   EQU     $D7FC ; OUT VEC
ZE7FE   EQU     $D7FE ; IN VEC
```

Original source code development was limited by the assembler used to a maximum of 256 byte output, hence the software is broken into sections starting at 256 byte boundaries and concatenated together to form the monitor eprom. Each 256 byte section starts with a jump table to the functions needed by other blocks.

Various functions are redirected through ram jump tables to enable changes at run time without re-compiling. The original version can switch between lcd/keyboard and serial terminal by examining the DSR and DCD values at boot time (this is disabled at preset  - all I/O is done through serial by default. this can change when the keyboard emulation is made to work.


## ram redirection vectors

|address|name      |default|
|-------|----------|-------|
|e7e5   |SWI3      |none   |
|e7e7   |SWI2      |none   |
|e7e9   |FIRQ      |none   |
|e7f4   |IRQ       |none   |
|e7f6   |SWI       |ff83   |
|e7f2   |NMI       |ff22   |
|fixed  |Reset     |ff00   |
|       |          |       |
|e7fa   |Qterm keyb|fc10   |
|       |Qtern acia|f85a   |
|e7fc   |Out lcd   |f90c   |
|       |Out acia  |f84b   |
|e7fe   |In keyb   |fc32   |
|       |In acia   |f83c   |

* Break button tied to NMI to enter monitor
* SWI used to enter monit fhrough code breakpoint


## Sections

|address|purpose   |
|-------|----------|
|f800   |acia      |
|f900   |lcd       |
|fa00   |rtc       |
|fb00   |S rec load|
|fc00   |keyboard  |
|fd00   |text etc  |
|fe00   |modify    |
|ff00   |monitor   |

## Jump tables

|acia |function|jump|
|-----|--------|----|
|f800 |init    |f808|
|f802 |in ch   |f83c|
|f804 |out ch  |f84b|

|clock|function|location(approx)|
|-----|--------|----|
|fa00 |init    |fab1|
|fa03 |time    |fa06|

|lcd  |function  |jump|
|-----|----------|----|
|f900 |pr xxxx   |f90e|
|f902 |pr aa     |f91a|
|f904 |op spc    |f938|
|f906 |op crlf   |f930|
|f908 |lcd init  |f93e|
|f90a |lcd setvev|f958|
|f90c |lcd out   |f962|

|s-records|function|jump |
|---------|--------|-----|
|fb00     |        |fb04 |
|fb02     |        |fb7a |

|keyboard|function|jump |
|--------|--------|-----|
|fc00    |get ch  |fc00 |

|modify|function|jump |
|------|--------|-----|
|fe00  |modify  |fe09 |
|fe03  |a to hex|fe90 |


## Monitor

Monitor commands are a single character followed by optional numbers and ended by return.

<br>

|Letter  |Command|
|--------|-------|
|M       |Modify              |
|R       |Register display    |
|N       |Continue after break|
|S       |save S records      |
|L       |load S records      |
|I       |Forth warm start    |
|O       |Forth cold start    |
|G       |Go                  |
|.       |Modify address      |
|/       |Modify data         |
|Return  |next address        |
|Linefeed|this address ?      |
|T       |Show Date & Time    |


Monitor register display has no labels enabling it to fit on a single line of the 40 character display and still leave room to see a command being typed. The display has the following format:

```
Cc A  B  D  X  Y  U  Pc S
```

|Code |Meaning|
|-----|-------|
|Cc|Condition codes|
|A |register|
|B |register|
|D |register (A and B)|
|X |register|
|Y |register|
|U ||
|Pc|program counter|
|S |stack pointer|


## Notes

* mame invocation (includes LCD simulation)

```
./mame djrm6809 -debug -window -resolution 640x480 -rs232 null_modem -bitb socket.localhost:1234
```

* terminal invocation

```
putty -load mame-rs232
```

(raw protocol on localhost, port 1234)

* The only working keyboard is by using rs232 nullmodem driver to a TCP port. The 6522 keyboard driver is unimplemented. The Console keyboard and screen is broken somehow. Possible cause is due to having two consoles in the configuration (LCD and rs232)

* All clocks used need to be reviewed and corrected, known to be wrong.


## Screenshot

Shows serial console overlaid on mame 2x40 character LCD mimic

![Screenshot](./photos/Screenshot1.png)


## Building from source

Before attempting to build the project maim.lst needs the target definitions added, see patch below for details

[mame.lst patch](./mame/src/mame.lst.patch)

I use a simlink to the source code to the project source to simplify project management, link the source file djrm6809.cpp to the same file in mame/src/homebrew

The from the maim directory a make command will build everything including the djrm6809 project

```
make -j5
```
The -j5 option to make enables the use of 4 cpu cores for the build and considerably quickens the process.

Alternativley a subset with only the djrm6809 project can be built with the following invocation:

```
make SUBTARGET=djrm6809 SOURCES=src/mame/homebrew/djrm6809.cpp TOOLS=1 REGENIE=1 -j5

```
Before the project can be run the roms need to be placed in the correct locations, the path in the repository mimics the required path in mame, they can be linked or copied to mame/roms as required. each file represents a 2kB 2716 eprom in the original system.

* note: the subset build does not accept the -rs232 command, I dont know why, I'm using the full mame version for my testing.

The whole project is my first attempt at a MAME simulation, this is very much a work in progress as I learn how to do it.

D
