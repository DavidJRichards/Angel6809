## MACH-9 investigation

Use f9dasm to re-create assmbler source files from binary rom images

`./f9dasm  -info mach9.inf >mach9.asm`

###  Commands

* Print,  Print line
* Shift Print, Advance paper
* ESC, Abort operation
* 1 Toggle tape1 motor ON/OFF
* 2 Toggle Tape2 motor ON/OFF
* \> Prompt `INPUT,OUTPUT,SOURCE,DESTIN` 
* When given I,O,S,D command prompts with (T,K,U,M,X)
* devices are: T=Tape, K=Console, U=User, M=Memory, X=Dummy 
* Option tape 1 or 2, input/output filenamme
* Option memory (A265), length (81) (change these before using assembler)
* < Prompt `EDIT,PASTE,SYMBOL`
* When given E,P,S command promps for edit, paste, and symbol location and length (or something)
* . Toggle something ON/OFF
* P Toggle something ON/OFF
* V Toggle something ON/OFF
* Z Toggle something ON/OFF
* F1 '[' User defined function (A386)
* F2 ']' User defined function (A388)
* F3 '^' User defined function (A38A)
* P printer on
* \* Address input
* M examine memory
* / Modify memory
* G execute instructions
* R Display cpu registers
`CC AABB DP XXXX YYYY SSSS *PC* UUUU`
`00 0000 00 0000 0000 AC00 F000 AB80`
* C Condition codes (a3e7)
* A Accumulator A (a3e80
* B Accumulator B (a3e9)
* D Direct page register (a3ea)
* X Register X (a3eb)
* Y Register Y (a3ed)
* S Stack pointer (a3ef)
* \* Program counter (????)
* U User stack pointer (a3f3)
* Q Set Breakpoint 0 to 4 (A38C, A38E, A390, A392, A394)
* W List breakpoints 0 to 4 `/----/----/----/----/----/`
* F Set function address F1, F2 or F3
* H causes abort
* L List to selected destination device
* O Output memory dump from address and size set in > Source command uses ; hh hh hh ascii hex format
* N Two pass assembler, expects source code at 'Source' device, output to 'Destination' device
* E Initialise editor [EOB=$0000]
* T Re-enter editor
* I Interactive assembler, no prompt, input <sp> or label <sp> nmemonic operand or command, finish with <sp>END
* K Disassembler, prompts for start address, number of lines, option 0=instructions only, 1=address+instructions, 2=address+pcodes+instructions
* H causes restart
* J,?: unrecognised

### Editor commands:

* T goto top
* B goto bottom , shows buffer extent i.e. t[EOB=$013D]
* U, D, then <enter> performs line Up or Down function 
* I insert text before current line
* K delete current line
* \# number of lines to list
* L list 
* Q quit
* C f= Change text, enter text to find, delimiter, then new replacement text, delimiter, y to confirm
* F f> Find text, enter text string, end with delimiter, y to confirm 
* E esc = Choose text delimiter character, e.g. '/' or ' '
* O Unknown purpose, promps 'No select' (can cut/delete/paste text when used with other keys)


### Assembler
Assembler accetps nemonics and some commands including: 

* ORG, END, FORM, LIST, NAME, PAGE (syntax unknown)

To assemble some code the source and destinations have to be set, to assemble the code in the text editor the default source is the memory device at adderss 0. The output can be the memory device at address 1000 to match the code origin.

To avoid overwriting the assembler binary output reset the Destination address after successfull assembly.

### 6850 ACIA source code example 
example assembler program to use 6850 ACIA as user Input and output [userio.asm](./userio.asm)

The source code to be imported into editor using TTY serial port. Enter editor with 'E' command, then insert lines with 'I' command. At this point the contenrs oof userio.asm should be copiied to the serial port, afterwards type <ctrl> Z to termiante.

To assemble into memory the Source should be set to memory address 0  and the destination should be set to address 1000 Using the > command followed by S and M and source address 0 then > followed by D and M then typing the load address 1000 and length 100

The two pass assembleer is used since forward references have been used in the source file, Use the N command, if successful the output will now be at address 1000

Change the destination address before proceeding because some other commands use it (dissasemble, K, for instance) use > D M K to make the console the output destination.

The program initialses the ACIA to operate at 9600 bps and sets the User input and output vectors to send and receive serial data. it also sets the F1 function key to repeat the initialisation sequence.

Run the program initilaisation by setting the program counter to 1000 and issuing a go command. (* 1000 G)

Successfull execution is indicated by the message 'Init 6850 ACIA' being output to the console before a warm start is executed.

It is then possible to have a fast serial console by setting the 
