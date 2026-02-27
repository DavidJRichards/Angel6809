* MACH-9 investigation


Use f9dasm to re-create assmbler source files from binary rom images

`./f9dasm  -info mach9.inf >mach9.asm`

##  Commands

* Print,  Print line
* Shift Print, Advance paper
* ESC, Abort operation
* 1 Toggle tape1 motor ON/OFF
* 2 Toggle Tape2 motor ON/OFF
* . Toggle something ON/OFF
* P Toggle something ON/OFF
* V Toggle something ON/OFF
* Z Toggle something ON/OFF
* F1 '[' User defined function (A386)
* F2 ']' User defined function (A388)
* F3 '^' User defined function (A38A)
* * Address input
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
* * Program counter (????)
* U User stack pointer (a3f3)
* Q Set Breakpoint 0 to 4 (A38C, A38E, A390, A392, A394)
* W List breakpoints 0 to 4 `/----/----/----/----/----/`
* F Set function address F1, F2 or F3
* H causes abort
* L input for something until ^Z, ESC terminates 
* O expects input for something, ^Z or nESC terminates
* N Two pass assembler, expects source code
* E Initialise editor [EOB=$0000]
* T Re-enter editor
* I Editor Insert, prompt changes to `.`, ESC to finish
* I Interactive assembler, no prompt, input <sp> or label <sp> nmemonic operand or command, finish with <sp>END

Assembler accetts nemonics and some commands including: ORG, END, FORM, LIST, NAME, PAGE


Editor accepts commands: 
T goto top
B goto bottom , shows buffer extent i.e. t[EOB=$013D]
U, D, enter (performs U or D) 
I insert before current line




