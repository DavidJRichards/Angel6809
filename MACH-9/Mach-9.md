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

* ORG
* END 
* FORM 
* LIST 
* NAME 
* PAGE

To assemble some code the source and destinations have to be set, to assemble the code in the text editor the default source is the memory device at adderss 0. The output can be the memoory device at, say, address 1000 to match the code origin.

To avoid overwriting the assembler binary output reset the Destination address after successfull assembly.

example assembler program to use 6850 ACIA as user Input and output [userio.asm](./userio.asm)

