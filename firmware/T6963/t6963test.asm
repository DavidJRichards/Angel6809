;	     	T6963C SAMPLE PROGRAM V0.01 
; 
; 
VCTRSWP		    EQU	9	; ASSIST09 Vector Swap Service
IRQ_CODE	    EQU	12	; IRQ Appendage Swap Function Code
CION            EQU 20
CIDTA           EQU 22
CIOFF           EQU 24
COON            EQU 26
CODTA           EQU 28
COOFF           EQU 30

TXHOME 		EQU $40 		; SET TXT HM ADD 
TXAREA 		EQU $41 		; SET TXT AREA 
GRHOME 		EQU $42 		; SET GR HM ADD 
GRAREA 		EQU $43 		; SET GR AREA 
CURSOR      EQU $21         ; cursor pointer
OFFSET 		EQU $22 		; SET OFFSET ADD 
ADPSET 		EQU $24 		; SET ADD PTR 
AWRON 		EQU $B0 		; SET AUTO WRITE MODE 
ARDON		EQU $B1		    ; set auto read mode
AWROFF 		EQU $B2 		; RESET AUTO WRITE MODE  
DATAWR      EQU $C0         ; data write
BITRES 		EQU $F0 		; Bit RESET
BITSET 		EQU $F8 		; Bit SET
T6963_BASE  EQU $C0D0
CMDP 		EQU $01 		; CMD PORT 
DTAP	    EQU $00 		; DATA PORT 

TL1         EQU $4C
TL2         EQU $8C
TL3         EQU $CC

; TALL DISPLAY
; 16 x 40 @ 8x8

; WIDE DISPLAY
; 8 X 40 @ 8X8

LCD_XWIDTH      EQU 240
LCD_YHEIGHT     EQU 64  ;128
LCD_KBYTES      EQU 8

LCD_WIDTH       EQU 48
LCD_HEIGHT      EQU 8 ;16 


_TH             EQU $0
_TA             EQU $40    ; 40 rounded to next multiple of 16, 64
_GH             EQU $400
_GA             EQU $400

VIA_BASE        EQU     $C030
VIA_ORB         EQU     0  
VIA_ORA         EQU     1
VIA_IRA         EQU     1
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

VIA_PCR_HANDSHAKE_OUTPUT EQU $8	; bits 3,2,1


                ORG $1000 
                
START 
; 
;   SET GRAPHIC HOME ADDRESS 
; 
        ldd     #_GH
        lbsr     DT2
        lda     #GRHOME
        lbsr     CMD

; 
;   SET GRAPHIC AREA 
; 
        ldd     #_GA
        lbsr     DT2
        lda     #GRAREA
        lbsr     CMD        
; 
;   SET TEXT HOME ADDRESS 
; 
        ldd     #_TH
        lbsr     DT2
        lda     #TXHOME
        lbsr     CMD
; 
;   SET TEXT AREA 
;
        ldd     #_TA
        lbsr     DT2
        lda     #TXAREA
        lbsr     CMD 

;
;   DISPLAY MODE
;
        lda     #$9F    ; (TEXT ON, GRAPHICS ON, CURSOR ON, BLINK ON) 
        lbsr     CMD 

;
;   CURSOR SHAPE
;
        lda     #$A1    ; 2 LINE CURSOR
        lbsr     CMD 
               
;
;   MODE SET
;
        lda     #$80    ; MODE SET (OR MODE, Internal Character Generator MODE) 
        lbsr     CMD 

;
; CLEAR SCREEN
;
        lbsr    T6963_FILL
        lbsr    T6963_CLEAR
        
 ; SET OFFSET REGISTER         
        LDD     #2
        LBSR    DT2
        lda     #OFFSET
        lbsr    CMD

; 
;   WRITE EXTERNAL CHARACTER GENERATOR DATA 
; 
        LDD     #$1400
        lbsr    DT2
        lda     #ADPSET
        lbsr    CMD        
        lda     #AWRON
        lbsr    CMD
        ldb     #$E8
        LEAY    EXTCG,PCR
excg    lda     ,y+
        lbsr    ADT
        decb
        bne     excg
        lda     #AWROFF
        lbsr    CMD
        
;
;   ADDRESS POINTER
;
        CLRA
        CLRB
        lbsr     DT2
        lda     #ADPSET
        lbsr     CMD

;   SET CURSOR
        ldd     #$71D   ; Y - X AT END OF SCREEN
        lbsr     DT2
        lda     #CURSOR
        lbsr     CMD 
        
    IF 0

;   write message
        leay    TXBUF2,pcr   ; address of null terminated string
        lbsr    WRITESTR       

; 
;   WRITE TEXT DISPLAY DATA (external CG) 
;
        ldd     #_TH+TL1
        lbsr    DT2
        lda     #ADPSET
        lbsr    CMD
        lda     #AWRON
        lbsr    CMD
        ldb     #6
        leay    EXPRT1,pcr
wxlp1   lda     ,y+
        lbsr    ADT
        decb
        bne     wxlp1
        lda     #AWROFF
        lbsr    CMD   
; 
;   WRITE TEXT DISPLAY DATA (INTERNAL CG) 
;
        ldd     #_TH+TL2
        lbsr    DT2
        lda     #ADPSET
        lbsr    CMD
        lda     #AWRON
        lbsr    CMD
        ldb     #6
        leay    EXPRT2,pcr '?djrm?'
wxlp    lda     ,y+
        lbsr    ADT
        decb
        bne     wxlp 
        lda     #AWROFF
        lbsr    CMD        
           
; 
;   WRITE TEXT DISPLAY DATA (external CG) 
;
        ldd     #_TH+TL3
        lbsr    DT2
        lda     #ADPSET
        lbsr    CMD
        lda     #AWRON
        lbsr    CMD
        ldb     #6
        leay    EXPRT3,pcr
wxlp3   lda     ,y+
        lbsr    ADT
        decb
        bne     wxlp3
        lda     #AWROFF
        lbsr    CMD        
        
        lbsr     WRITEBUFFER
        lbsr     READBUFFER
;        lbsr     WRITEBUFFER
;        rts
    ENDIF
;================================================
; Initialise VIA for keyboard handshake
		ldx	#VIA_BASE
        lda     #VIA_PCR_HANDSHAKE_OUTPUT
        sta     VIA_PCR,X
        lda	VIA_IRA,X

        clra
        clrb
        std     T6963_ADR
        lbsr    T6963_POS

;================================================
; Setup I/O Handlers
		LEAX    TEXT_OUTCH,pcr
		LDA	    #CODTA
		SWI
		FCB	    VCTRSWP

		LEAX    keyboard_cidta,pcr
		LDA	    #CIDTA
		SWI
		FCB	    VCTRSWP

        rts

;================================================

TEXT_OUTCH
        PSHS    d,x,y,u        
        lbsr    T6963_PUTC
        puls    d,x,y,u,pc        


mainlp
        bsr     keyboard_cidta
        bcc     mainlp
        CMPA    #3
        BEQ     MLX
        lbsr    T6963_PUTC
        bra     mainlp  
MLX     RTS        

;================================================
 * CIDTA - RETURN CONSOLE INPUT CHARACTER
* OUTPUT: C=0 IF NO DATA READY, C=1 A=CHARACTER
* U VOLATILE
keyboard_cidta
	    PSHS	U
        LDU     #VIA_BASE
        LDA     VIA_IFR,U        ; GET STATUS
        lsra
        lsra
        BCC     kcirtn           ; RETURN IF NOTHING
        LDA     VIA_IRA,U        ; LOAD DATA BYTE
kcirtn  PULS	U,PC             ; RETURN TO CALLER

;-----------------------------------------------------------------------------

;
;   COMMAND WRITE ROUTINE 
; 
CMD     
        ldx     #T6963_BASE
cmd1    ldb     CMDP,x
        andb    #3
        cmpb    #3
        bne     cmd1
        sta     CMDP,X
        rts

; 
;   DATA WRITE (1 byte) ROUTINE 
; 
DT1
        ldx     #T6963_BASE
dt11    ldb     CMDP,X
        andb    #3
        cmpb    #3
        bne     dt11        
        sta     DTAP,X
        rts

; 
; DATA WRITE (2 byte) ROUTINE 
; 
DT2     PSHS    Y
        ldx     #T6963_BASE
        tfr     d,y
dt21    ldb     CMDP,X
        andb    #3
        cmpb    #3
        bne     dt21        
        tfr     y,d
        stb     DTAP,X
dt22    ldb     CMDP,X
        andb    #3
        cmpb    #3
        bne     dt22
        tfr     y,d        
        sta     DTAP,X        
        PULS    Y
        rts
        
; 
;   AUTO WRITE MODE ROUTINE 
;  
ADT
        PSHS    B,X
        ldx     #T6963_BASE
adt1    ldb     CMDP,X
        andb    #8
        beq     adt1 
        sta     ,X
        PULS    B,X
        rts     
; 
;   AUTO READMODE ROUTINE 
;  
ARD 
        PSHS    B,X
        ldx     #T6963_BASE
ard1    ldb     CMDP,X
        andb    #4
        beq     ard1
        lda     DTAP,X
        PULS    B,X
        rts
        
; 
;   READ TEXT buffer, LCD addr in HL
;
READBUFFER
;
;        ldd     #_TH+TL1    ; Address Pointer
;        ldd     #_TH+$80
        PSHS    X
        bsr     DT2
        lda     #ADPSET
        bsr     CMD
        
        lda     #ARDON       ; SET DATA AUTO READ
        bsr     CMD
        
        ldb     #64
        leax    TXBUF,pcr        
rxlp1                
        bsr     ARD         ; transfer data
        adda    #$20
        sta     ,x+ 
        decb
        bne     rxlp1
        
        lda     #AWROFF               
        bsr     CMD
        PULS    X
        rts


; 
;   WRITE TEXT buffer
;
WRITEBUFFER
;		
;        ldd     #_TH+TL1    ; Address Pointer
;        ldd     #_TH+$100
        PSHS    X
        lbsr    DT2
        lda     #ADPSET
        lbsr    CMD
        
        lda     #AWRON      ; SET DATA AUTO READ
        lbsr    CMD
        
        ldb     #64
        leax    TXBUF,pcr        
txlp1  
        lda     ,x+
        suba    #$20
        bsr     ADT
        decb
        bne     txlp1
        
        lda     #AWROFF               
        lbsr     CMD
        PULS    X
        rts

;
SCROLL_UP
;
        ldy     #7
        ldu     #0
        
scr1    tfr     u,x          
        ldb     #$40
        abx
        tfr     x,d
        lbsr    READBUFFER
        tfr     u,d     
        lbsr    WRITEBUFFER
        tfr     x,u
        leay    -1,y        
        bne     scr1
        
        tfr     U,d          ;
        leay    BLANKS,pcr   ; address of null terminated string
        lbsr    WRITESTR       
        tfr     U,d
        std     T6963_ADR
        lbsr    T6963_POS
        rts

WRITESTR
        PSHS    X
        lda     #AWRON      ; SET DATA AUTO READ
        lbsr    CMD
wsr1  
        lda     ,y+
        beq     wsr2
        suba    #$20
        lbsr    ADT
        bra     wsr1
wsr2        
        lda     #AWROFF               
        lbsr     CMD
        PULS    X
        rts
        
T6963_FILL
; 
;   WRITE TEXT BLANK CODE 
; 
        ldd         #_TH
        lbsr        DT2
        lda         #ADPSET
        lbsr        CMD
        lda         #AWRON
        lbsr        CMD
        ldy         #$400
        clra
txcr    lbsr        ADT
        leay        -1,y
        bne         txcr
        lda         #AWROFF
        lbsr        CMD
        rts

T6963_CLEAR
;   WRITE Graphics BLANK CODE 
; 
        ldd         #_GH
        lbsr        DT2
        lda         #ADPSET
        lbsr        CMD
        lda         #AWRON
        lbsr        CMD
        ldy         #$100
        clra
gxcr    lbsr        ADT
        leay        -1,y
        bne         gxcr
        lda         #AWROFF
        lbsr         CMD
        rts
        
T6963_POS	
        tfr     d,u
        lbsr    DT2
        lda     #ADPSET
        lbsr    CMD

;        PSHS    U
;        PULS    B
;        PULS    A
;        TFR     D,U

        tfr     u,d     ; mask to 6 bits (column)
        exg     a,b
        anda    #$3f
        lbsr    DT1
        
        tfr     u,d
        asrb            ; shift right 6 bits
        rora
        asrb            ; 2
        rora
        asrb            ; 3
        rora
        asrb            ; 4
        rora
        asrb            ; 5
        rora
        asrb            ; 6
        rora
        lbsr    DT1

        lda     #CURSOR
        lbsr    CMD  
		rts

;
; write data
;
T6963_PUTC
        cmpa    #$D         ; RETURN (^M)
        bne     tpc0
        lbsr    T6963_CR
        LDA     #$a
;        lbra    T6963_LF    ; ADD LF
tpc0    cmpa    #$0A        ; LINE FEED (^J)
        BNE     tpc1
        bsr     T6963_LF
        ldx     T6963_ADR
        cmpx    #$01E8      ; END OF SCREEN
        BLO     tpc01        
        LBSR    SCROLL_UP
tpc01   rts
        
tpc1    cmpa    #$0C        ; CLEAR SCREEN
        bne     tpc2    
        lbsr    T6963_FILL
        clra
        clrb
        std     T6963_ADR
        lbsr    T6963_POS
        rts        

tpc2    pshs    a
        lda     T6963_ADR+1
        anda    #$3f
        cmpa    #40         ; END OF LINE
        blo     tpc3
        lbsr    T6963_CR
        lbsr    T6963_LF
        ldd     T6963_ADR
        lbsr    T6963_POS        
tpc3    puls    a

        PSHS    A
        ldx     T6963_ADR
        cmpx    #$01E8      ; END OF SCREEN
        BLO     tpc4        
        LBSR    SCROLL_UP
tpc4    puls    a    
        


T6963_PUTC_RAW
        suba    #$20
        lbsr    DT1
        lda     #DATAWR
        lbsr    CMD
        
        ldx     T6963_ADR
        ldb     #1
        abx
        stx     T6963_ADR
        TFR     X,D
        lbsr    T6963_POS
        rts
               
T6963_LF
        ldx     T6963_ADR
        ldb     #$40
        abx
        stx     T6963_ADR
        TFR     X,D
        lbsr    T6963_POS
        rts

		
T6963_CR
        ldd     T6963_ADR
        andb    #$c0
        std     T6963_ADR
        lbsr    T6963_POS
        rts
        
;
; Subroutine end
;

;
; working data
;
T6963_ROW       fcb     $24
T6963_ADR       fdb     _TH
T6963_COL       fcb     $24

;	TEXT DISPLAY CHARACTER CODE
;

EXPRT1  fcb 	$84, $80, $80, $80, $80, $87		; EXTERNAL CG CODE (semi graphic)
EXPRT2  fcb     $81, $44, $4A, $52, $4D, $81
EXPRT3	fcb 	$8A, $80, $80, $80, $80, $8D
;
;	EXTERNAL CG FONT DATA
;
EXTCG

;
; 29 box drawing characters
;
        fcb    $00,$00,$00,$ff,$ff,$00,$00,$00
        fcb    $18,$18,$18,$18,$18,$18,$18,$18
        fcb    $00,$00,$00,$0f,$0f,$08,$08,$08
        fcb    $00,$00,$00,$00,$1f,$18,$18,$18
        fcb    $00,$00,$00,$1f,$1f,$18,$18,$18
        fcb    $00,$00,$00,$f0,$f0,$10,$10,$10
        fcb    $00,$00,$00,$00,$f8,$18,$18,$18
        fcb    $00,$00,$00,$f8,$f8,$18,$18,$18
        fcb    $08,$08,$08,$0f,$0f,$00,$00,$00
        fcb    $18,$18,$18,$18,$1f,$00,$00,$00
        fcb    $18,$18,$18,$1f,$1f,$00,$00,$00
        fcb    $10,$10,$10,$f0,$f0,$00,$00,$00
        fcb    $18,$18,$18,$18,$f8,$00,$00,$00
        fcb    $18,$18,$18,$f8,$f8,$00,$00,$00
        fcb    $08,$08,$08,$0f,$0f,$08,$08,$08
        fcb    $18,$18,$18,$18,$1f,$18,$18,$18
        fcb    $18,$18,$18,$1f,$1f,$18,$18,$18
        fcb    $10,$10,$10,$f0,$f0,$10,$10,$10
        fcb    $18,$18,$18,$18,$f8,$18,$18,$18
        fcb    $18,$18,$18,$f8,$f8,$18,$18,$18
        fcb    $00,$00,$00,$ff,$ff,$10,$10,$10
        fcb    $00,$00,$00,$00,$ff,$18,$18,$18
        fcb    $00,$00,$00,$ff,$ff,$18,$18,$18
        fcb    $10,$10,$10,$ff,$ff,$00,$00,$00
        fcb    $18,$18,$18,$18,$ff,$00,$00,$00
        fcb    $18,$18,$18,$ff,$ff,$00,$00,$00
        fcb    $10,$10,$10,$ff,$ff,$10,$10,$10
        fcb    $18,$18,$18,$18,$ff,$18,$18,$18
        fcb    $18,$18,$18,$ff,$ff,$18,$18,$18

;
;
; line buffer
;
TXBUF
		fcb 	"The quick brown fox jumps over the lazy dog."
TXBUF2		
		fcb 	"Now is the time for all good me to come to the aid of the party.", 0
BLANKS  fcb     "                                        ",0
		END

