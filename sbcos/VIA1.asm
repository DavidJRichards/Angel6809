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
Via1_init      ldx   #$00              ; get data from table
Via1init1      lda   Via1idata,x       ; init all 16 regs from 00 to 0F
               sta   Via1Base,x        ; 
               inx                     ; 
               cpx   #$0f              ; 
               bne   Via1init1         ;       
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
;
;
;end of file
