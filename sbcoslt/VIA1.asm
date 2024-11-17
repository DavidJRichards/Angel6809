; ----------------- assembly instructions ---------------------------- 
;
; this is a subroutine library only
; it must be included in an executable source file
;
;
;*** I/O Locations *******************************
; define the i/o address of the Via1 chip
;*** 6522 CIA ************************
Via1Base       =     $c030
Via1PRB        =     Via1Base+0
Via1PRA        =     Via1Base+1
Via1DDRB       =     Via1Base+2
Via1DDRA       =     Via1Base+3
Via1T1CL       =     Via1Base+4
Via1T1CH       =     Via1Base+5
Via1T1LL       =     Via1Base+6
Via1TALH       =     Via1Base+7
Via1T2CL       =     Via1Base+8
Via1T2CH       =     Via1Base+9
Via1SR         =     Via1Base+$A
Via1ACR        =     Via1Base+$B
Via1PCR        =     Via1Base+$C
Via1IFR        =     Via1Base+$D
Via1IER        =     Via1Base+$E
Via1PRA1       =     Via1Base+$F
;
;***********************************************************************
; 6522 VIA I/O Support Routines
;
Via1_init      
               LDX   #<PS2KB_Input      ; set up RAM vectors for
               LDA   #>PS2KB_Input      ; Input, Output, and Scan
               TAY                     	; Routines
               EOR   #$A5              	;
               sta   ChrInVect+2       	;
               sty   ChrInVect+1       	;
               stx   ChrInVect         	;
               LDX   #<PS2KB_Scan  	;
               LDA   #>PS2KB_Scan       ;
               TAY                     	;
               EOR   #$A5              	;
               sta   ScanInVect+2      	;
               sty   ScanInVect+1      	;
               stx   ScanInVect        	;

               ldx   #$00              ; get data from table
Via1init1      lda   Via1idata,x       ; init all 16 regs from 00 to 0F
               sta   Via1Base,x        ; 
               inx                     ; 
               cpx   #$0f              ; 
               bne   Via1init1         ;       
               
; setup via for keyboard
               lda      #$08
               sta      Via1PCR
               lda	Via1PRA
                              
               rts                     ; done
;
Via1idata      .byte $00               ; prb  '00000000'
               .byte $00               ; pra  "00000000'
               .byte $00               ; ddrb 'iiiiiiii'
               .byte $00               ; ddra 'iiiiiiii'
               .byte $00               ; tacl  
               .byte $00               ; tach  
               .byte $00               ; tall  
               .byte $00               ; talh  
               .byte $00               ; t2cl
               .byte $00               ; t2ch
               .byte $00               ; sr
               .byte $00               ; acr
               .byte $00               ; pcr
               .byte $7f               ; ifr
               .byte $7f               ; ier
; 
keyboard_cidta
; CIDTA - RETURN CONSOLE INPUT CHARACTER
; OUTPUT: C=0 IF NO DATA READY, C=1 A=CHARACTER
; U VOLATILE

PS2KB_Scan
                lda    Via1IFR         ; LOAD STATUS REGISTER
                lsr
                lsr
                BCC     kcirtn          ; RETURN IF NOTHING
                LDA     Via1PRA         ; LOAD DATA BYTE
kcirtn          RTS                     ; RETURN TO CALLER

PS2KB_Input
                JSR     PS2KB_Scan
                BCC     PS2KB_Input
                RTS


        

;
;
;end of file
