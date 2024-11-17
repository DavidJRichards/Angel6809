; ----------------- assembly instructions ---------------------------- 
;
; this is a subroutine library only
; it must be included in an executable source file
;
;
;*** I/O Locations *******************************
; define the i/o address of the 6850 ACIA0 chip
UART            = $c008
UARTS           = UART+0
ACIA0sta        = UART+0
UARTD           = UART+1
ACIA0dat        = UART+1

;***********************************************************************
; 6850 I/O Support Routines
;
ACIA0_init     LDX   #<ACIA0_Input      ; set up RAM vectors for
               LDA   #>ACIA0_Input      ; Input, Output, and Scan
               TAY                     	; Routines
               EOR   #$A5              	;
               sta   ChrInVect+2       	;
               sty   ChrInVect+1       	;
               stx   ChrInVect         	;
               LDX   #<ACIA0_Scan  	;
               LDA   #>ACIA0_Scan       ;
               TAY                     	;
               EOR   #$A5              	;
               sta   ScanInVect+2      	;
               sty   ScanInVect+1      	;
               stx   ScanInVect        	;
               LDX   #<ACIA0_Output     ;
               LDA   #>ACIA0_Output     ;
               TAY                     	;
               EOR   #$A5              	;
               sta   ChrOutVect+2      	;
               sty   ChrOutVect+1      	;
               stx   ChrOutVect        	;
               lda   #<ACIA0_scan      	; setup BASIC vectors
               sta   VEC_IN
	       lda   #>ACIA0_scan	; BASIC's chr input
               sta   VEC_IN+1
               lda   #<ACIA0_Output	
               sta   VEC_OUT
	       lda   #>ACIA0_Output	; BASIC's chr output 
               sta   VEC_OUT+1
	       lda   #<Psave
               sta   VEC_SV
	       lda   #>Psave		; SAVE cmd
               sta   VEC_SV+1
	       lda   #<pload
               sta   VEC_LD
	       lda   #>pload		; LOAD cmd
               sta   VEC_LD+1
;===============================================================================
ACIA0portset    lda     #$03                ; reset UART
                sta     UARTS
                lda     #$15                ; set 8N1 serial parameter
                sta     UARTS
                rts

;===============================================================================
;
; non-waiting get character routine 
;
ACIA0_Scan      LDA     UARTS           ; check UART status
                AND     #$01            ; can read?
                BEQ     UAGRET          ; if not, return with Z flag set
                LDA     UARTD           ; read UART data
                sec
                rts
UAGRET          clc
                RTS
        
;===============================================================================
;
; input chr from ACIA0 (waiting)
;
ACIA0_Input     JSR     ACIA0_Scan
                BCC     ACIA0_Input
                RTS

;===============================================================================
;
; output to OutPut Port
;
ACIA0_Output    PHA                     ; save character
UAPUTL          LDA     UARTS           ; check UART status
                AND     #$02            ; can write?
                BEQ     UAPUTL          ; wait if not
                PLA                     ; restore character
                STA     UARTD           ; write character
                RTS
                
;===============================================================================
;
;end of file
