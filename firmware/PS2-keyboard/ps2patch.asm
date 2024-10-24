Entry		    EQU	$1000	; Code entry address (Zero page reserved for storage)

VDP 		    EQU	$E080	; TMS9929A Video Display Processor address
VDP_VRAM	    EQU	VDP+0	; VDP VRAM access address
VDP_REGISTER	EQU	VDP+1	; VDP Register access address

VCTRSWP		    EQU	9	; ASSIST09 Vector Swap Service
IRQ_CODE	    EQU	12	; IRQ Appendage Swap Function Code
CION            EQU 20
CIDTA           EQU 22
CIOFF           EQU 24
COON            EQU 26
CODTA           EQU 28
COOFF           EQU 30

VIA_BASE        EQU     $C030
VIA_ORB         EQU     0  
VIA_ORA         EQU     1
VIA_DDRB        EQU     2
VIA_DDRA        EQU     3
VIA_T1C         EQU     4 ; 4 & 5
VIA_TIL_L       EQU     4
VIA_T1C_L       EQU     4
VIA_T1C_H       EQU     5
VIA_T1L         EQU     6 ; 6 & 7
VIA_T1L_L       EQU     6
VIA_T1L_H       EQU     7
VIA_T2C         EQU     8 ; 8 & 9
VIA_T2L_L       EQU     8
VIA_T2C_L       EQU     8
VIA_T2C_H       EQU     9
VIA_SR          EQU     $A
VIA_ACR         EQU     $B
VIA_PCR         EQU     $C
VIA_IFR         EQU     $D
VIA_IER         EQU     $E
;VIA_ORA         EQU     $F

*******************************************
* ASSIST09 MONITOR SWI FUNCTIONS
* THE FOLLOWING EQUATES DEFINE FUNCTIONS PROVIDED
* BY THE ASSIST09 MONITOR VIA THE SWI INSTRUCTION.
******************************************
INCHNP  EQU     0               ; INPUT CHAR IN A REG - NO PARITY
OUTCH   EQU     1               ; OUTPUT CHAR FROM A REG
PDATA1  EQU     2               ; OUTPUT STRING
PDATA   EQU     3               ; OUTPUT CR/LF THEN STRING
OUT2HS  EQU     4               ; OUTPUT TWO HEX AND SPACE
OUT4HS  EQU     5               ; OUTPUT FOUR HEX AND SPACE
PCRLF   EQU     6               ; OUTPUT CR/LF
SPACE   EQU     7               ; OUTPUT A SPACE
MONITR  EQU     8               ; ENTER ASSIST09 MONITOR
VCTRSW  EQU     9               ; VECTOR EXAMINE/SWITCH
BRKPT   EQU     10              ; USER PROGRAM BREAKPOINT
PAUSE   EQU     11              ; TASK PAUSE FUNCTION
NUMFUN  EQU     11              ; NUMBER OF AVAILABLE FUNCTIONS

; ascii constants
cr		        equ $0d
lf		        equ $0a
bs		        equ $10
null		    equ $00


; serial port addresses 
; Base memory address of the 6551 ACIA
ACIA_ADDRESS 	EQU $c0e8
USEDELAY        EQU 1  

; 6551 Memory mapped registers
ACIA_REG_DATA     equ ACIA_ADDRESS+0
ACIA_REG_STATUS   equ ACIA_ADDRESS+1
ACIA_REG_COMMAND  equ ACIA_ADDRESS+2
ACIA_REG_CONTROL  equ ACIA_ADDRESS+3

; 6522 VIA



; memory

;ramstart	equ $1000
;ramend		equ $1fff


;
; Main Entry Point
		ORG	Entry
;		CLRA		; Initialise Direct Page Register for Zero page
;		TFR	A,DP	
; Tell asm6809 what page the DP register has been set to
;		SETDP	#$00
    
; setup the serial port

;		lbsr serialinit		; setup the serial port
;		ldx #greetingmsg	; greetings!
;		lbsr serialputstr	; output the greeting

; setup via for keyboard

        lda     #$08
        sta     $C03C
        lda	    $C031
        	
kloop	
;    	lda	    $C03D
;		bita	#2
;		beq	    kloop
;		lda	    $C031
;		jsr	    outch
;		bra	    kloop
		
		
;===========================

; Setup I/O Handlers
;		LEAX    serialputchar,pcr
;		LDA	    #CODTA
;		SWI
;		FCB	    VCTRSWP

		LEAX    keyboard_cidta,pcr
		LDA	    #CIDTA
		SWI
		FCB	    VCTRSWP

        rts
;===========================

keyboard_cidta
 * CIDTA - RETURN CONSOLE INPUT CHARACTER
* OUTPUT: C=0 IF NO DATA READY, C=1 A=CHARACTER
* U VOLATILE

        LDU     #VIA_BASE
        LDA     $D,U             ; LOAD STATUS REGISTER
        lsra
        lsra
        BCC     kcirtn           ; RETURN IF NOTHING
        LDA     1,U              ; LOAD DATA BYTE
kcirtn   RTS                     ; RETURN TO CALLER
        


mainloop	
        ldx #promptmsg		; ">"
		lbsr serialputstr	; output that
		
		ldx #inputbuffer	; now we need some text
		lbsr serialgetstr	; get the text (waiting as needed)

		ldx #outputbuffer

		ldy #newlinemsg		; tidy up the console with a newline
		lbsr concatstr		; ...
		ldy #youtypedmsg	; tell the user ...
		lbsr concatstr		; ...
		ldy #inputbuffer	; ...
		lbsr concatstr		; ...
		ldy #newlinemsg		; ...
		lbsr concatstr		; ...
		clr ,x+			; (add a null)

		ldx #outputbuffer
		lbsr serialputstr	; ... what they typed

		RTS
		bra mainloop

;===============================================================================

;;; SERIAL PORT ;;;

; serial port setup

;===============================================================================
    
serialinit   
        PSHS    Y,X,D  	; init 
        LDX     #ACIA_ADDRESS
        LDA     #$00    ; # dummy value
        STA     $01,X   ; acia reset 
        LDA     #$1E    ; #control 
        STA     $03,X   ; set baud etc  
        LDA     #$0B    ; #command   
        STA     $02,X   ; parity etc 
        PULS    PC,Y,X,D             
    
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
	RTS

; put the char in a, returning when its sent
serialputchar	
        PSHS    X,B,A    	; out                 
        LDX     #ACIA_ADDRESS
        IF USEDELAY == 0
ZF850   LDB     $01,X                    
        BITB    #$10                     
        BEQ     ZF850                    
        STA     ,X                       
        ELSE
        STA     ,X                       
        LDX     #100
        JSR     DLY
        ENDIF
        PULS    PC,X,B,A                   
    
; serialgetchar - gets a char, putting it in a
serialgetchar 	
        PSHS    X,B    	; in               
        LDX     #ACIA_ADDRESS
ZF841   LDB     $01,X                  
        BITB    #$08                    
        BEQ     ZF841                  
        LDA     ,X                    
        PULS    PC,X,B                  

serial_cidta
 * CIDTA - RETURN CONSOLE INPUT CHARACTER
* OUTPUT: C=0 IF NO DATA READY, C=1 A=CHARACTER
* U VOLATILE

        LDU     #ACIA_ADDRESS   ; LOAD ACIA ADDRESS
        LDA     1,U             ; LOAD STATUS REGISTER
        LSRA                    ; TEST RECEIVER REGISTER FLAG
        lsra
        lsra
        lsra
        BCC     cirtn           ; RETURN IF NOTHING
        LDA     0,U             ; LOAD DATA BYTE
cirtn   RTS                     ; RETURN TO CALLER

 

; serial query terminal - if character waiting check if it is ESC
pqterm
ZF85A   PSHS X
        LDX     #ACIA_ADDRESS
        LDA     $01,X 
        BITA    #$08
        BEQ     ZF877
        LDA     ,X
        CMPA    #$1B
        BNE     ZF878
ZF86B   LDA     $01,X
        BITA    #$08 
        BEQ     ZF86B
        LDA     ,X  
        CMPA    #$1B 
        BNE     ZF878 
ZF877   CLRA 
ZF878   PULS    PC,X 

    
;===============================================================================
; puts the null terminated string pointed to by x

serialputstr	
                lda ,x+			; get the next char
		beq serialputstrout	; null found, bomb out
		bsr serialputchar	; output the character
		bra serialputstr	; more chars
serialputstrout	
    		rts

; serialgetstr - gets a line, upto a cr, filling x as we go

serialgetstr
                bsr pqterm
                bne serialgetstrout
	
    		bsr serialgetchar	; get a char in a
		cmpa #cr		; cr?
		beq serialgetstrout	; i f it is, then out
		cmpa #lf		; lf?
		beq serialgetstrout	; i f it is, then out
		sta ,x+			; add it to string
		bra serialgetstr	; get more
serialgetstrout	
    		clr ,x+			; add a null
		rts

; concatstr - add string y to string x, not copying the null

concatstr	
    		lda ,y+
		beq concatstrout
		sta ,x+
		bra concatstr
concatstrout	
    		rts
;===============================================================================
    		
out4h                   ; output as hex digits contents of D register
ZF90E   PSHS D         ; pr xxxx      
        BSR     ZF91A                   
        EXG     B,A                     
        BSR     ZF91A                   
        PULS    PC,D                    

ZF91A   PSHS A         ; pr aa                   
        ASRA                           
        ASRA                           
        ASRA                           
        ASRA                            
        BSR     ZF924                  
        PULS A                         

ZF924   ANDA    #$0F   ; pr x             
        CMPA    #$0A                 
        BCS     ZF92C                
        ADDA    #$07                  
ZF92C   ADDA    #$30                 

outch
        pshs  cc                ; preserve irq mask which is set by assis09
        SWI                     ; Call ASSIST09 monitor function
        FCB     OUTCH           ; Service code byte
        puls  cc
        RTS

    		
    		
inputbuffer	rmb 256
outputbuffer	rmb 256

greetingmsg	
                fcb cr
		fcb lf
		fcb cr
		fcb lf
		fcc "6809 serial test"
		fcb cr
		fcb lf
		fcb null
		
youtypedmsg	
    fcc "You typed: "
		fcb null
		
promptmsg	
    fcc ": "
		fcb null
		
newlinemsg	
    fcb cr
		fcb lf
		fcb null

    		
