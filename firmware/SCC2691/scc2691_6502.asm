;******************************************************************************
IOPAGE		.EQU	$FE00	;I/O Page Base Start Address
;******************************************************************************
SCC2691_BASE	.EQU	IOPAGE+$80	;Beginning of Console UART address
;
UART_MODEREG	.EQU	SCC2691_BASE+$00 	;MR1/MR2 same address, sequential read/write
UART_STATUS	.EQU	SCC2691_BASE+$01	;UART Status Register (READ)
UART_CLKSEL	.EQU	SCC2691_BASE+$01	;UART Clock Select Register (WRITE)
UART_BRGTST	.EQU	SCC2691_BASE+$02	;UART BRG Test register (READ)
UART_COMMAND	.EQU	SCC2691_BASE+$02	;UART Command Register (WRITE)
UART_RECEIVE	.EQU	SCC2691_BASE+$03	;UART Receive Register (READ)
UART_TRANSMIT	.EQU	SCC2691_BASE+$03	;UART Transmit Register (WRITE)
UART_CLKTEST	.EQU	SCC2691_BASE+$04	;X1/X16 Test Register (READ)
UART_AUXCR	.EQU	SCC2691_BASE+$04	;Aux Command Register (WRITE)
UART_ISR	.EQU	SCC2691_BASE+$05	;Interrupt Status Register (READ)
UART_IMR	.EQU	SCC2691_BASE+$05	;Interrupt Mask Register (WRITE)
UART_CNTU	.EQU	SCC2691_BASE+$06	;Counter/Timer Upper Register (READ)
UART_CNTUP	.EQU	SCC2691_BASE+$06	;Counter/Timer Upper Preset Register (WRITE)
UART_CNTL	.EQU	SCC2691_BASE+$07	;Counte/Timerr Lower Register (READ)
UART_CNTLP	.EQU	SCC2691_BASE+$07	;Counter/Timer Lower Preset Register (WRITE)
;
;******************************************************************************

;
;Initializing the SCC2691 UART as the Console
;An undocumented bug in the W65C02 processor requires a different approach for programming the
; SCC2691 for proper setup/operation. The SCC2691 uses two Mode Registers which are accessed at
; the same register in sequence. There is a command that Resets the Mode Register pointer (to MR1)
; that is issued first. Then MR1 is loaded followed by MR2. The problem with the W65C02 is a false
; read of the register when using indexed addressing (i.e., STA UART_REGISTER,X). This results in
; the mode register pointer being moved to the second register, so the write to MR1 never happens.
; While the indexed list works fine for all other register functions/commands, the loading of the
; Mode Registers needs to be handled separately.
;
;NOTE: The W65C02 will function properly "if" a page boundary is crossed as part of the STA
; (i.e., STA $FDFF,X) where the value of the X register is high enough to cross the page boundary.
; Programming in this manner would be confusing and require modification if the base I/O address
; is changed for a different hardware I/O map. Not worth the aggravation in my view.
;
;The same bug in the W65C02 also creates a false read when sending any command to the Command
; Register (assumed indexed addressing), as the read function of that hardware register is the
; BRG Test register. This can result in a different baud rate being selected, depending on the
; baud rate tables listed in the Datasheet. When using either 19.2K or 38.4K baud rate, the tables
; are the same for both normal and BRG Test mode, so the UART will operate normally. Changing to a
; different baud rate via the BRG Test register requires additional coding to use any of the
; extended baud rates.
;
;NOTE: As a result of the bug mentioned above, the X1/X16 Test Mode register will be toggled twice
; when the INIT_2691 routine is executed. The end result is the 2691 UART is correctly configured
; after the routine completes. Also note that the NMI PANIC routine above also toggles the X1/X16
; Test Mode register in case it was inadvertantly invoked (toggled).
;
;There are two basic routines to setup the 2691 UART
;
;The first routine is a basic RESET of the UART.
; It issues the following sequence of commands:
; 1- Send a Power On command to the ACR
; 2- Reset Break Change Interrupt
; 3- Reset Receiver
; 4- Reset Transmitter
; 5- Reset All errors
;
;The second routine initializes tha 2691 UART for operation. It uses two tables of data; one for the
; register offset and the other for the register data. The table for register offsets is maintained in
; ROM. The table for register data is copied to page $03, making it soft data. If needed, operating
; parameters can be altered and the UART re-initialized.
;
; Updated BIOS version to Ver. 2.01 on 2nd April 2018. Shorten INIT_IO routine by moving up the
; INIT_2691 to remove the "JMP INIT_2691", saves a few bytes and some clock cycles.
;
INIT_IO		JSR	RESET_2691	;Power-Up Reset of SCC2691 UART
;		LDA	#DF_TICKS	;Get divider for jiffy clock for 1-second
;		STA	TICKS		;Preload TICK count
;
INIT_2691	;This routine sets the initial operating mode of the UART
		SEI			;Disable interrupts
		LDX	#INIT_DATAE-INIT_DATA	;Get the Init byte count
2691_INT	LDA	LOAD_2691-1,X	;Get Data for 2691 register
		LDY	INIT_OFFSET-1,X	;Get Offset for 2691 register
		STA	SCC2691_BASE,Y	;Store to selected register
		DEX			;Decrement count
		BNE	2691_INT	;Loop back until all registers are loaded
;
		LDA	MR1_DAT		;Get Mode Register 1 Data
		STA	UART_MODEREG	;Send to 2691
		LDA	MR2_DAT		;Get Mode Register 2 Data
		STA	UART_MODEREG	;Send to 2691
		CLI			;Enable interrupts
		RTS			;Return to caller
;
RESET_2691	;This routine does a basic Reset of the SCC2691
		LDA	#%00001000	;Get Power On mask
		STA	UART_AUXCR	;Send to 2691 (ensure it's on)
;
		LDX	#UART_RDATAE-UART_RDATA1	;Get the Init byte count
UART_RES1	LDA	UART_RDATA1-1,X	;Get Reset commands
		STA	UART_COMMAND	;Send to UART CR
		DEX			;Decrement the command list
		BNE	UART_RES1	;Loop back until all are sent
		RTS			;Return to caller
;
;END OF BIOS CODE for Pages $F8 through $FD
;******************************************************************************

;
;Configuration Data - The following tables contains the default data used for:
;	- Reset of the SCC2691 (RESET_2691 routine)
;	- Init of the SCC2691 (INIT_2691 routine)
;	- Basic details for register definitions are below, consult SCC2691 DataSheet
; and Application Note AN405 for details and specific operating conditions.
;
; Mode Register 1 definition ($93)
;	Bit7		;RxRTS Control - 1 = Yes
;	Bit6		;RX-Int Select - 0 = RxRDY
;	Bit5		;Error Mode - 0 = Character
;	Bit4/3	;Parity Mode - 10 = No Parity
;	Bit2		;Parity Type - 0 = Even (doesn't matter)
;	Bit1/0	;Bits Per Character - 11 = 8
;
;	Mode Register 2 Definition ($17)
;	Bit7/6	;Channel Mode	- 00 = Normal
;	Bit5		;TxRTS Control - 0 = Yes
;	Bit4		;CTS Enable - 1 = Yes
;	Bit3-0	;Stop Bits - 0111 = 1 Stop Bit
;
;	Baud Rate Clock Definition ($CC)
;	Upper 4 bits = Receive Baud Rate
;	Lower 4 bits = Transmit Baud Rate
;	for 38.4K setting is %11001100
;	Also set ACR Bit7 = 0 for standard rates
;
;	Command Register Definition
;	Bit7-4	;Special commands
;	Bit3		;Disable Transmit
;	Bit2		;Enable Transmit
;	Bit1		;Disable Receive
;	Bit0		;Enable Receive
;
;	Aux Control Register Definition ($68)
;	Bit7		;BRG Set Select - 0 = Default
;	Bit654	;Counter/Timer operating mode 110 = Counter mode from XTAL
;	Bit3		;Power Down mode 1 = Off (normal)
;	Bit210	;MPO Pin Function 000 = RTSN (active low state)
;
;	Interrupt Mask Register Definition ($1D)
;	Bit7	;MPI Pin Change Interrupt 1 = On
;	Bit6	;MPI Level Interrupt 1 = On
;	Bit5	;Not used (shows as active on read)
;	Bit4	;Counter Ready Interrupt 1 = On
;	Bit3	;Delta Break Interrupt 1 = On
;	Bit2	;RxRDY Interrupt 1 = On
;	Bit1	;TxEMT Interrupt 1 = On
;	Bit0	;TxRDY Interrupt 1 = On
;
CFG_TABLE	;Configuration table for hardware devices
;Data commands are sent in reverse order from list. This list is the default initialization for
; the UART as configured for use as a Console connected to ExtraPutty. The data here is copied
; to page $03 and is used to configure the UART during boot up. The soft data can be changed
; and the the core INIT_2691 can be called to reconfigure the UART. NOTE: the Register offset
; data is not kept in soft config memory as the initialization sequence should not be changed!
INIT_DATA	;Start of UART Initialization Data
		.DB	%00010000	;Reset Mode Register pointer
		.DB	%10100000	;Enable RTS (Receiver)
		.DB	%00001001	;Enable Receiver/Disable Transmitter
		.DB	%00011101	;Interrupt Mask Register setup
		.DB	%01101000	;Aux Register setup for Counter/Timer
		.DB	%01001000	;Counter/Timer Upper Preset
		.DB	%00000000	;Counter/Timer Lower Preset
		.DB	%11001100	;Baud Rate clock for Rcv/Xmt
		.DB	%10010000	;Disable Counter/Timer
		.DB	%00001010	;Disable Receiver/Transmitter
		.DB	%10110000	;Disable RTS (Receiver)
		.DB	%00000000	;Interrupt Mask Register setup
		.DB	%00001000	;Aux Register setup for Power On
INIT_DATAE				;End of UART Initialization Data
;
;Mode Register Data is defined separately. Using a loop routine to send this data to the
; UART does not work properly. See the description of the problem using Indexed addressing
; to load the UART registers above. This data is also kept in soft config memory in page $03.
MR1_DAT		.DB	%10010011	;Mode Register 1 Data
MR2_DAT		.DB	%00010111	;Mode Register 2 data
;
;Reserved for additional I/O devices
		.DB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
;
;Reset UART Data is listed here. The sequence and commands do not require changes for any reason.
; These are maintained in ROM only. A total of 32 bytes is available for hard configuration data.
;These are the register offsets and Reset data for the UART
UART_RDATA	;UART Reset Data for Received Break (ExtraPutty/Terminal Send Break)
		.DB	%00000001	;Enable Receiver
UART_RDATA1				;Smaller list for entry level Reset (RESET_2691)
		.DB	%01000000	;Reset All Errors
		.DB	%00110000	;Reset Transmitter
		.DB	%00100000	;Reset Receiver
		.DB	%01010000	;Reset Break Change Interrupt
UART_RDATAE				;End of UART Reset Data 
;
INIT_OFFSET	;Start of UART Initialization Register Offsets
		.DB	$02		;Command Register
		.DB	$02		;Command Register
		.DB	$02		;Command Register
		.DB	$05		;Interrupt Mask Register
		.DB	$04		;Aux Command Register
		.DB	$06		;Counter Preset Upper
		.DB	$07		;Counter Preset Lower
		.DB	$01		;Baud Clock Register
		.DB	$02		;Command Register
		.DB	$02		;Command Register
		.DB	$02		;Command Register
		.DB	$05		;Interrupt Mask Register
		.DB	$04		;Aux Command Register
INIT_OFFSETE				;End of UART Initialization Register Offsets
;
;Reserved for additional I/O devices
		.DB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
;
;END OF BIOS VECTOR DATA AND HARDWARE DEFAULT CONFIGURATION DATA
;******************************************************************************


