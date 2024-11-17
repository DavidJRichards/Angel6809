; ----------------- assembly instructions ---------------------------- 
;
; this is a subroutine library only
; it must be included in an executable source file
;
;
;*** I/O Locations *******************************
; define the i/o address of the 6850 ACIA2 chip

ACAI2Base       = $C008
ACIA2sta        = ACAI2Base+0
ACIA2dat        = ACAI2Base+1

;***********************************************************************
; 6850 I/O Support Routines
;
ACIA2_init     LDX   #<ACIA2_Input      ; set up RAM vectors for
               LDA   #>ACIA2_Input      ; Input, Output, and Scan
               TAY                     	; Routines
               EOR   #$A5              	;
               sta   ChrInVect+2       	;
               sty   ChrInVect+1       	;
               stx   ChrInVect         	;
               LDX   #<ACIA2_Scan  	;
               LDA   #>ACIA2_Scan       ;
               TAY                     	;
               EOR   #$A5              	;
               sta   ScanInVect+2      	;
               sty   ScanInVect+1      	;
               stx   ScanInVect        	;
               LDX   #<ACIA2_Output     ;
               LDA   #>ACIA2_Output     ;
               TAY                     	;
               EOR   #$A5              	;
               sta   ChrOutVect+2      	;
               sty   ChrOutVect+1      	;
               stx   ChrOutVect        	;
;               lda   #<ACIA2_scan      	; setup BASIC vectors
;               sta   VEC_IN
;	       lda   #>ACIA2_scan	; BASIC's chr input
;               sta   VEC_IN+1
;               lda   #<ACIA2_Output	
;               sta   VEC_OUT
;	       lda   #>ACIA2_Output	; BASIC's chr output 
;               sta   VEC_OUT+1
;	       lda   #<Psave
;               sta   VEC_SV
;	       lda   #>Psave		; SAVE cmd
;               sta   VEC_SV+1
;	       lda   #<pload
;               sta   VEC_LD
;	       lda   #>pload		; LOAD cmd
;               sta   VEC_LD+1

; LEDs on prototype board
               lda      #$32
               sta      $c0f0
               lda      #$30
               sta      $c0f1
               lda      #$35
               sta      $c0f2
               lda      #$36
               sta      $c0f3

;===============================================================================
ACIA2portset    lda     #$03            ; reset UART
                sta     ACIA2sta
                lda     #$15            ; set 8N1 serial parameter
                sta     ACIA2sta
                rts

;===============================================================================
;
; non-waiting get character routine 
;
ACIA2_Scan      LDA     ACIA2sta        ; check UART status
                AND     #$01            ; can read?
                BEQ     UAGRET          ; if not, return with Z flag set
                LDA     ACIA2dat        ; read UART data
                sec
                rts
UAGRET          clc
                RTS
        
;===============================================================================
;
; input chr from ACIA2 (waiting)
;
ACIA2_Input     JSR     ACIA2_Scan
                BCC     ACIA2_Input
                RTS

;===============================================================================
;
; output to OutPut Port
;
ACIA2_Output    PHA                     ; save character
UAPUTL          LDA     ACIA2sta        ; check UART status
                AND     #$02            ; can write?
                BEQ     UAPUTL          ; wait if not
                PLA                     ; restore character
                STA     ACIA2dat        ; write character
                RTS
                
;===============================================================================
;
;end of file
