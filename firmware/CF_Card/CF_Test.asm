********************************
* MONITOR LABLES
********************************
INCHP	EQU	$00		; INPUT CHAR FROM CONSOLE AND ECHO
OUTCH	EQU	$01		; OUTPUT CHAR ON CONSOLE
PDATA	EQU	$03		; PRINT TEXT STRING @ X ENDED BY $04
OUT2HS	EQU	$04		; PRINT 2 HEX CHARS @ X
OUT4HS	EQU	$05		; PRINT 4 HEX CHARS @ X
HSDTA	EQU	$E436

********************************
* PROGRAM VARIABLES
********************************
HEXCHAR		FCB		$00

********************************
* CF REGS
********************************
CFADDRESS	EQU 	$F300
CFDATA		EQU		$00		; DATA PORT
CFERROR		EQU		$01		; ERROR CODE (READ)
CFFEATURE	EQU		$01		; FEATURE SET (WRITE)
CFSECCNT	EQU		$02		; NUMBER OF SECTORS TO TRANSFER
CFLBA0		EQU		$03		; SECTOR ADDRESS LBA 0 [0:7]
CFLBA1		EQU		$04		; SECTOR ADDRESS LBA 1 [8:15]
CFLBA2		EQU		$05		; SECTOR ADDRESS LBA 2 [16:23]
CFLBA3		EQU		$06		; SECTOR ADDRESS LBA 3 [24:27 (LSB)]
CFSTATUS	EQU		$07		; STATUS (READ)
CFCOMMAND	EQU		$07		; COMMAND SET (WRITE)

CFSTATUSL	EQU		CFADDRESS+CFSTATUS
********************************
* START OF PROGRAM
********************************
	ORG	$2000
		JMP		START
********************************
* CF CARD COMMANDS
********************************
DRIVEID		EQU		$EC
LBA0		FCB		$00
LBA1		FCB		$00
LBA2		FCB		$00
LBA3		FCB		$E0
DATABLK		EQU		$1000
********************************

********************************
* MENU HELP TEXT
********************************
HHELP	FCC		"? - List the commands available."
		FCB		$0D,$0A
		FCC		"D - Display the RAM buffer contents."
		FCB		$0D,$0A
		FCC		"F - Fill CF Card buffer with a constant."
		FCB		$0D,$0A
		FCC		"I - Initialise the CF Card."
		FCB		$0D,$0A
		FCC		"L - Set the LBA address."
		FCB		$0D,$0A
		FCC		"R - Read a data block from theCF Card."
		FCB		$0D,$0A
		FCC		"W - Write a data block to the CF Card."
		FCB		$0D,$0A
		FCC		"V - Verify the data block written to the CF Card."		
		FCB		$0D,$0A
		FCC		"P - Print the properties of the CF Card."		
		FCB		$0D,$0A
		FCC		"Q - Exit this application & return to the monitor."		
		FCB		$0D,$0A,$04
		
********************************
* MENU OPTION TEXT
********************************
NEWLINE	FCB		$0D,$0A,$04
PROMPT	FCB		">",$04
INIT	FCC		"Initialise CF Card."
		FCB		$0D,$04
READ	FCC		"Read From CF Card."
		FCB		$0D,$04
WRITE	FCC		"Write to CF Card."
		FCB		$0D,$04
INFO	FCC		"Read CF Card Info."
		FCB		$0D,$04

********************************
* SUBROUTINE TEXT STRINGS
********************************
ERROR	FCC		"Error initialising the CF Card"
		FCB		$0D,$04
WAIT	FCC		"Waiting for CF Card"
		FCB		$0D,$04
MARKER	FCC		"*"
		FCB		$0D,$04
INHEX	FCC		"Enter hex code: "
		FCB		$04
********************************

START	LDX		#NEWLINE		; Get a new line and print the input prompt
        SWI 
        FCB     PDATA 
		LDX		#PROMPT 
        SWI 
        FCB     PDATA
        SWI 
		FCB		INCHP			; Wait for a key to be pressed on the keyboard
		CMPA	#'?				; Print the list of available commands
		BNE		NEXT
		JSR		HELP
NEXT	ANDA	#$DF			; Make sure the character is upper-case
		CMPA	#'D				; Display the RAM buffer contents.
		BNE		NEXT1
		JSR		DISPCF
NEXT1	CMPA	#'F				; Fill CF Card buffer with a constant
		BNE		NEXT2
		JSR		CFFILL
NEXT2	CMPA	#'I				; Initialise the CF Card
		BNE		NEXT3
		JSR		INITCF
NEXT3	CMPA	#'L				; Set the LBA addresses for the card
		BNE		NEXT4
		JSR		LBACF
NEXT4	CMPA	#'R				; Read a block of data from the CF Card to memory
		BNE		NEXT5
		JSR		READCF
NEXT5	CMPA	#'W				; Write a block of data from the memory toCF Card
		BNE		NEXT6
		JSR		WRITECF
NEXT6	CMPA	#'V				; Print the properties of the CF Card
		BNE		NEXT7
		JSR		CFVERIF
NEXT7	CMPA	#'P				; Print the properties of the CF Card
		BNE		NEXT8
		JSR		CFINFO
NEXT8	CMPA	#'Q				; Exit the program
		BNE		START
		JMP		QUIT
		BRA		START

****************************************************
* Display the contents of the RAM buffer
****************************************************
DISPCF	PSHS	Y,X,B,A
		LDX		#DATABLK
		PSHS	X
		LDX		#DATABLK+$0200
		PSHS	X
		JSR		HSDTA
		PULS	Y,X,B,A
		PULS	X
		PULS	X
		RTS

****************************************************
* Set the LBA values used for reading a block of data from the CF Card
****************************************************
LBATXT0	FCB		"LBA 0 value (hex): ",$04
LBATXT1	FCB		"LBA 1 value (hex): ",$04
LBATXT2	FCB		"LBA 2 value (hex): ",$04
LBACF	PSHS	A
		LDY		#LBATXT0
		JSR		GETHEX			; Get the hex address value
		STA		LBA0
		JSR		CMDWAIT
		
		LDY		#LBATXT1
		JSR		GETHEX
		STA		LBA1
		JSR		CMDWAIT
		
		LDY		#LBATXT2
		JSR		GETHEX
		STA		LBA2
		JSR		CMDWAIT

		LDB		#LBA3
		STB		CFLBA3, X
		JSR		CMDWAIT
		LDB		#$01
		STB		CFSECCNT, X
		JSR		CMDWAIT
		LDB		#$EF			; Enable features 
		STB		CFCOMMAND, X
		
		PULS	A
		RTS

****************************************************
* Initialise the CF Card
****************************************************
INITCF	LDX		#CFADDRESS
		JSR		CMDWAIT
		LDB		#$04			; Reset the CF Card
		STB		CFCOMMAND, X
		JSR		CMDWAIT
		LDB		#$E0			; Clear LBA3, set Master & LBA mode
		STB		CFLBA3, X
		JSR		CMDWAIT
		LDB		#$01			; Set 8-bit bus-width
		STB		CFFEATURE, X
		JSR		CMDWAIT
		LDB		#$01			; Read only one sector at a time.
		STB		CFSECCNT, X
		JSR		CMDWAIT
		LDB		#$EF			; Enable features 
		STB		CFCOMMAND, X
		JSR		CMDWAIT
		LDB		LBA0
		STB		CFLBA0, X
		JSR		CMDWAIT
		LDB		LBA1
		STB		CFLBA1, X
		JSR		CMDWAIT
		LDB		LBA2
		STB		CFLBA2, X
		JSR		CMDWAIT
		LDB		#LBA3
		STB		CFLBA3, X
		JSR		CMDWAIT
		LDB		#$01
		STB		CFSECCNT, X
		JSR		CMDWAIT
		LDB		#$EF			; Enable features 
		STB		CFCOMMAND, X
		JSR		CFERR
		RTS

****************************************************
* Print CF Card information
****************************************************
SERNO	FCC		"   Serial No.: "		
		FCB		$04
FIRMREV	FCC		"Firmware Rev.: "		
		FCB		$04
MODELNO	FCC		"    Model No.: "		
		FCB		$04
LBAHEAD	FCC		"                1  2  3  4"		
		FCB		$04
LBASIZE	FCC		"    LBA Size : "		
		FCB		$04

CFINFO	PSHS	Y,X,B,A
		JSR		CMDWAIT
		LDX		#CFADDRESS
		LDB		#DRIVEID			; Issue Drive ID command
		STB		CFCOMMAND, X
		
		LDY		#DATABLK			; Point to the start of the memory block
INFOCF	JSR		DATWAIT
		LDB		CFSTATUS, X			; Check the Drq bit for available data
		BITB	#$08
		BEQ		INFNEXT
		LDB		CFDATA, X			; Read the data byte
		STB		,Y+					; Write it te the buffer
		BRA		INFOCF
		
INFNEXT	LDX		#MODELNO			; Print the card model number
		SWI
		FCB		PDATA
		LDY 	#DATABLK+54
		LDB		#20
MODNO	LDA		1,Y
		SWI
		FCB		OUTCH
		LDA		,Y++
		SWI
		FCB		OUTCH
		DECB	
		BNE MODNO

		LDX		#FIRMREV			; Print the card firmware revision
		SWI
		FCB		PDATA
		LDY 	#DATABLK+46
		LDB		#4
FIRM	LDA		1,Y
		SWI
		FCB		OUTCH
		LDA		,Y++
		SWI
		FCB		OUTCH
		DECB	
		BNE FIRM

		LDX		#SERNO				; Print the card serial number
		SWI
		FCB		PDATA
		LDY 	#DATABLK+20
		LDB		#10
SERIAL	LDA		1,Y
		SWI
		FCB		OUTCH
		LDA		,Y++
		SWI
		FCB		OUTCH
		DECB	
		BNE 	SERIAL

		LDX		#LBASIZE			; Print the card LBA details
		SWI
		FCB		PDATA
		LDY 	#DATABLK+120
		LDB		#02
LBACNT	LEAX	1,Y
		SWI
		FCB		OUT2HS
		LEAX	,Y++
		SWI
		FCB		OUT2HS
		DECB	
		BNE 	LBACNT

		PULS	Y,X,B,A
		RTS		

****************************************************
* Read a block of data from the CF Card to memory
* Loop until the Drq bit = 0 (bit 3)
****************************************************
READCF	PSHS	Y,X,B,A
		LDX		#CFADDRESS		
		JSR		CMDWAIT
		LDB		LBA0				; Load the LBA addresses with the current
		STB		CFLBA0, X			; settings before issuing the read command.
		JSR		CMDWAIT
		LDB		LBA1
		STB		CFLBA1, X
		JSR		CMDWAIT
		LDB		LBA2
		STB		CFLBA2, X
		JSR		CMDWAIT
		LDB		LBA3
		STB		CFLBA3, X
		JSR		CMDWAIT
		LDB		#$01
		STB		CFSECCNT, X
		JSR		CMDWAIT

		JSR		CMDWAIT
		LDB		#$20				; Send read command to the CF Card
		STB		CFCOMMAND, X
		JSR		DATWAIT

		LDY		#DATABLK			; Point to the start of the memory block
RDLOOP	JSR		DATWAIT
		LDA		CFDATA, X			; Read the data byte
		STA		,Y+					; Write it to the buffer
		JSR		DATWAIT
		LDA		CFSTATUS, X		
		BITA	#$08
		BNE		RDLOOP

RDEXIT	PULS	Y,X,B,A
		RTS



****************************************************
* Write a block of data from the memory to CF Card
****************************************************
WRITECF	PSHS	Y,X,B,A	
		JSR		CMDWAIT
		LDX		#CFADDRESS		
		LDB		LBA0				; Load the LBA addresses with the current
		STB		CFLBA0, X			; settings before issuing the write command.
		JSR		CMDWAIT
		LDB		LBA1
		STB		CFLBA1, X
		JSR		CMDWAIT
		LDB		LBA2
		STB		CFLBA2, X
		JSR		CMDWAIT
		LDB		LBA3
		STB		CFLBA3, X
		JSR		CMDWAIT
		LDB		#$01
		STB		CFSECCNT, X

		JSR		CMDWAIT
		LDB		#$30				; Send write command to the CF Card
		STB		CFCOMMAND, X
*		JSR		CMDWAIT
		JSR		DATWAIT

		LDY		#DATABLK			; Point to the start of the memory block
WRLOOP	LDA		,Y+					; Read the byte from the buffer
		STA		CFDATA, X			; Write the data byte to the CF Card.
		JSR		DATWAIT
		LDA		CFSTATUS, X		
		BITA	#$08
		BNE		WRLOOP
		PULS	Y,X,B,A
		RTS

****************************************************
* Fill the CF Card buffer memory with a constant
****************************************************
CFFILL	PSHS	A
		LDY		#INHEX				; Get the fill character in A
		JSR		GETHEX				; Load the value to be written to the memory block
		LDX		#$0200				; Initialise the counter to 512
		LDY		#DATABLK			; Point to the start of the memory block
LFILL	STA		,Y+					; Write the data
		LEAX	-1,X				; Decrement the loop counter
		BNE		LFILL				; Repeat until counter = 0
		PULS	A
		RTS

****************************************************
* Verify the data written to the CF Card
****************************************************
VERTXT	FCC		"Verify error at "		
		FCB		$04
VDATC	FCC		"  Card data value : "		
		FCB		$04
VDATM	FCC		"Buffer data value : "		
		FCB		$04
VADD	FCB		$00, $00
CFVERIF	PSHS	Y,X,B,A
		LDX		#CFADDRESS		
		JSR		CMDWAIT
		LDB		LBA0				; Load the LBA addresses with the current
		STB		CFLBA0, X			; settings before issuing the read command.
		JSR		CMDWAIT
		LDB		LBA1
		STB		CFLBA1, X
		JSR		CMDWAIT
		LDB		LBA2
		STB		CFLBA2, X
		JSR		CMDWAIT
		LDB		LBA3
		STB		CFLBA3, X
		JSR		CMDWAIT
		LDB		#$01
		STB		CFSECCNT, X
		JSR		CMDWAIT

		JSR		CMDWAIT
		LDB		#$20				; Send read command to the CF Card
		STB		CFCOMMAND, X
		JSR		DATWAIT

		LDY		#DATABLK			; Point to the start of the memory block
VFLOOP	JSR		DATWAIT
		LDA		CFDATA, X			; Read the data byte
		CMPA	,Y					; Compare data with the buffer contents
		BEQ		VCONT
		CMPA	,Y+					; Increment the Y-register, so the pointer value is
									; correct for the error reporting.
		
		PSHS	Y,X,B,A				; The stack contains some of the information we 
		LDX		#VERTXT				; want to report. First print the text
        SWI 
        FCB     PDATA 
        LDD		4,S					; Read the address of the error from the stack
        SUBD	#$1001				; Remove the address offset
        STD		VADD				; Store the result so that the OUT4HS routine can
        LDX		#VADD				; print it.
        SWI
        FCB		OUT4HS
        LDX		#VDATC				; Print the data value read from the CF Card.
        SWI
        FCB		PDATA
        LDA		,S	
        STA		VADD
        LDX		#VADD
        SWI
        FCB		OUT2HS
        
        LDX		#VDATM				; Print the data value read from memory.
        SWI
        FCB		PDATA
        LDD		4,S					; Read the address of the error from the stack
        SUBD	#$01				; Remove the address offset
        STD		VADD				; Store the result so that the OUT4HS routine can
        LDX		VADD				; print it.
        SWI
        FCB		OUT2HS
        
        PULS	Y,X,B,A
		
VCONT	JSR		DATWAIT
		LDA		CFSTATUS, X		
		BITA	#$08
		BNE		VFLOOP


VFEXIT	PULS	Y,X,B,A
		RTS


****************************************************
* Print the list of available commands
****************************************************
HELP	LDX		#HHELP
        SWI 
        FCB     PDATA 
		RTS 

****************************************************
* Quit the application
****************************************************
QUIT	LDX		#NEWLINE
        SWI 
        FCB     PDATA 
		RTS        
        
****************************************************
* Wait for CF Card ready when reading/writing to CF Card
* Check for Busy = 0 (bit 7)
****************************************************
DATWAIT	LDB		CFSTATUSL	 	; Read the status register
		BITB	#$80			; Isolate the ready bit
		BNE		DATWAIT			; Wait for the bit to clear
		RTS        

****************************************************
* Wait for CF Card ready when reading/writing to CF Card
* Check for RDY = 0 (bit 6)
****************************************************
CMDWAIT	LDB		CFSTATUSL	 	; Read the status register
		BITB	#$C0			; Isolate the ready bit
		BEQ		CMDWAIT			; Wait for the bit to clear
		RTS        

****************************************************
* Error Initialising the CF Card
****************************************************
CFERR	LDB		CFSTATUSL
		BITB	#$01			; Isolate the error bit
		BEQ		EREXIT			
		SWI 
		FCB     PDATA 
EREXIT	RTS

****************************************************
* Read a 2-digit hex number from the console
****************************************************	
GETHEX	LDX		#NEWLINE		; Get a new line and print the input prompt
        SWI 
        FCB     PDATA 
		LEAX	,Y
        SWI 
        FCB     PDATA
        JSR		HEXDIG			; Get first digit
        BITB	#$F0
        BNE		GETHEX			; An incorrect key was pressed, try again
        LSLB
        LSLB
        LSLB
        LSLB
        LDX		#HEXCHAR
        STB		,X
        JSR		HEXDIG			; Get second digit
        ADDB	,X
        STB		,X
        LDA		,X
		RTS

****************************************************
* Read a single-digit hex number from the console
****************************************************	
HEXDIG	SWI 
		FCB		INCHP			; Wait for a key to be pressed on the keyboard
		CMPA	#'0				; Brute force search for hex characters
		BNE		DIGIT
		LDB		#$00
		RTS
DIGIT	CMPA	#'1				; Brute force search for hex characters
		BNE		DIGIT1
		LDB		#$01
		RTS
DIGIT1	CMPA	#'2
		BNE		DIGIT2
		LDB		#$02
		RTS
DIGIT2	CMPA	#'3	
		BNE		DIGIT3
		LDB		#$03
		RTS
DIGIT3	CMPA	#'4	
		BNE		DIGIT4
		LDB		#$04
		RTS
DIGIT4	CMPA	#'5	
		BNE		DIGIT5
		LDB		#$05
		RTS
DIGIT5	CMPA	#'6	
		BNE		DIGIT6
		LDB		#$06
		RTS
DIGIT6	CMPA	#'7
		BNE		DIGIT7
		LDB		#$07
		RTS
DIGIT7	CMPA	#'8
		BNE		DIGIT8
		LDB		#$08
		RTS
DIGIT8	CMPA	#'9
		BNE		DIGIT9
		LDB		#$09
		RTS
DIGIT9	ANDA	#$DF
		CMPA	#'A	
		BNE		DIGIT10
		LDB		#$0A
		RTS
DIGIT10	CMPA	#'B	
		BNE		DIGIT11
		LDB		#$0B
		RTS
DIGIT11	CMPA	#'C	
		BNE		DIGIT12
		LDB		#$0C
		RTS
DIGIT12	CMPA	#'D	
		BNE		DIGIT13
		LDB		#$0D
		RTS
DIGIT13	CMPA	#'E
		BNE		DIGIT14
		LDB		#$0E
		RTS
DIGIT14	CMPA	#'F
		BNE		DIGIT15
		LDB		#$0F
		RTS
DIGIT15	LDB		#$F0			; If we get here, a wrong key has been pressed
		RTS
		
END
       
