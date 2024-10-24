; memory map
; 0xxx - ram
; 10xx - io
; 10xx xxxx xxxx xxxx - serial
; 11xx - rom

; ascii constants

cr		  equ $0d
lf		  equ $0a
bs		  equ $10
null		equ $00

VCTRSWP		EQU	9	; ASSIST09 Vector Swap Service
IRQ_CODE	EQU	12	; IRQ Appendage Swap Function Code
CION        EQU 20
CIDTA       EQU 22
CIOFF       EQU 24
COON        EQU 26
CODTA       EQU 28
COOFF       EQU 30


; serial port addresses - for readability dupe the read/write locations
  
; Base memory address of the 6551 ACIA
ACIA_ADDRESS 	EQU $c0e8

USEDELAY   EQU 1  

; 6551 Memory mapped registers
ACIA_REG_DATA     equ ACIA_ADDRESS+0
ACIA_REG_STATUS   equ ACIA_ADDRESS+1
ACIA_REG_COMMAND  equ ACIA_ADDRESS+2
ACIA_REG_CONTROL  equ ACIA_ADDRESS+3

; memory

ramstart	equ $1000
ramend		equ $1fff

; in ram, add our global variables

		org ramstart
		
		LBRA reset

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

; setup stack to the end of ram so it can go grown backwards

reset		
;                lds #ramend+1		; setup hardware stack

    if 0
		ldx #ramstart		; clear from start of ram		
zeroram		
    clr ,x+
		cmpx #ramend+1		; to end
		bne zeroram
    endif
    
; setup the serial port

		lbsr serialinit		; setup the serial port
		ldx #greetingmsg	; greetings!
		lbsr serialputstr	; output the greeting

;===========================

; Setup I/O Handlers
		LEAX    serialputchar,pcr
		LDA	    #CODTA
		SWI
		FCB	    VCTRSWP

		LEAX    serial_cidta,pcr
		LDA	    #CIDTA
		SWI
		FCB	    VCTRSWP

        rts
;===========================



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
