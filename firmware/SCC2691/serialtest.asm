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

; serial port addresses - for readability dupe the read/write locations

        
ACIA equ 6551 ;6850 ;6551 ;6850 ; 6850 or 6551


  if ACIA == 6551
  
; Base memory address of the 6551 ACIA
ACIA_ADDRESS 	EQU $c0e8

  else

; Base memory address of the 6551 ACIA
ACIA_ADDRESS   	equ $c008

  endif  

; 6851 registers
serialcr	equ ACIA_ADDRESS
serialrx	equ ACIA_ADDRESS+1
serialsr	equ ACIA_ADDRESS
serialtx	equ ACIA_ADDRESS+1
  

; 6551 Memory mapped registers
ACIA_REG_DATA     equ ACIA_ADDRESS+0
ACIA_REG_STATUS   equ ACIA_ADDRESS+1
ACIA_REG_COMMAND  equ ACIA_ADDRESS+2
ACIA_REG_CONTROL  equ ACIA_ADDRESS+3

; memory

ramstart	equ $1000
ramend		equ $1fff

; setup the reset vector, last location in rom
;		org $fffe	
;		fdb reset

; in ram, add our global variables

		org ramstart
		
		LBRA reset

inputbuffer	rmb 256
outputbuffer	rmb 256

; this is the start of rom

;		org $e000		
;		fill $ff, $1e00

greetingmsg	
                fcb cr
		fcb lf
		fcb cr
		fcb lf
		fcc "6809 serial test"
;		fcb cr
;		fcb lf
		fcb cr
		fcb lf
		fcb null
		
youtypedmsg	
    fcc "You typed: "
		fcb null
		
promptmsg	
    fcc "> "
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
CPMS	equ	10		; 1000 = 1 MHZ CLOCK
				; 2000 = 2 MHZ CLOCK
MFAC	equ	(CPMS/20)		; MULTIPLYING FACTOR FOR ALL
				; EXCEPT LAST MILLISECOND
MFACM	equ	(MFAC-4)		; MULTIPLYING FACTOR FOR LAST
				; MILLISECOND
;
; METHOD:
;
; THE ROUTINE IS DIVIDED INTO 2 PARTS.
; THE CALL TO THE "DLY" ROUTINE DELAYS EXACTLY 1 LESS THAN THE
; NUMBER OF REQUIRED MILLISECONDS.
; THE LAST ITERATION TAKES INTO ACCOUNT
; THE OVERHEAD TO CALL "DELAY" AND "DLY
; THIS OVERHEAD IS 78 CYCLES.
;
DELAY
	;
	; D0 ALL BUT THE LAST MILLISECOND
	;
	PSHS	D,X	 	; SAVE REGISTERS
	LDB	#MFAC		; GET MULTIPLYING FACTOR
	DECA			; REDUCE NUMBER OF MS BY 1 
	MUL			; MULTIPLY FACTOR TIMES MS
	TFR	D,Y		; TRANSFER LOOP COUNT TO X
	JSR	DLY
	;
	; ACCOUNT FOR 80 MS OVERHEAD DELAY BY REDUCING
	; LAST MILLISECOND'S COUNT
	;
	LDX	#MFACM			; GET REDUCED COUNT
	JSR	DLY			; DELAY LAST MILLISECOND
	PULS	D,X			; RESTORE REGISTERS
	RTS
	;
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
;
; SAMPLE EXECUTION:
;
SC8G
	;
	; DELAY 10 SECONDS
	; CALL DELAY 40 TIMES AT 250 MILLISECONDS EACH
	;
	LDB	#40		; 40 TIMES (28 HEX)
QTRSCD	LDA	#250		; 250 MILLISECONDS (FA HEX)
	JSR	DELAY
	DECB
	BNE	QTRSCD		; CONTINUE UNTIL DONE
	RTS
;	BRA	SC8G		; REPEAT OPERATION

;===============================================================================

;;; SERIAL PORT ;;;

; serial port setup

;===============================================================================
    if ACIA == 6551
    
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
    
; put the char in a, returning when its sent
serialputchar	
        PSHS    X,B,A    	; out                 
        LDX     #ACIA_ADDRESS
        STA     ,X                       
        LDX     #100
        JSR     DLY
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

    
    endif
;===============================================================================
    if ACIA == 65512
    
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
    
; put the char in a, returning when its sent
serialputchar	
        PSHS    X,B    	; out                 
        LDX     #ACIA_ADDRESS
ZF850   LDB     $01,X                    
        BITB    #$10                     
        BEQ     ZF850                    
        STA     ,X                       
        PULS    PC,X,B                   
    
; serialgetchar - gets a char, putting it in a
serialgetchar 	
        PSHS    X,B    	; in               
        LDX     #ACIA_ADDRESS
ZF841   LDB     $01,X                  
        BITB    #$08                    
        BEQ     ZF841                  
        LDA     ,X                    
        PULS    PC,X,B                  
    
    endif
;===============================================================================
    if ACIA == 6850
    
serialinit	
                lda #%00000011		; master reset
		sta serialcr
		; divider (=16), databits (=8n1), no rts and no interrupts
;		lda #%00010101
		lda #$51
		sta serialcr
		rts

; put the char in a, returning when its sent

serialputchar	
                ldb serialsr
		andb #%00000010		; transmit empty
		beq serialputchar	; wait for port to be idle
		sta serialtx		; output the char
		rts

; serialgetchar - gets a char, putting it in a

serialgetchar 	                
                lda serialsr		; get status
		anda #%00000001		; input empty?
		beq serialgetchar	; go back and look again
		lda serialrx		; get the char into a
		bsr serialputchar	; echo it
		rts

    endif		
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
