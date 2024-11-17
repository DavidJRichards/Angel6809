; ----------------- assembly instructions ---------------------------- 
;
; this is a subroutine library only
; it must be included in an executable source file
;
;
;*** I/O Locations *******************************
; define the i/o address of the 6821 Pia1 chip
Pia1Base       =     $c010
Pia1PRB        =     Pia1Base+$0
Pia1PRA        =     Pia1Base+$1
Pia1DDRB       =     Pia1Base+$2
Pia1DDRA       =     Pia1Base+$3
Pia1T1CL       =     Pia1Base+$4
Pia1T1CH       =     Pia1Base+$5
Pia1T1LL       =     Pia1Base+$6
Pia1TALH       =     Pia1Base+$7
Pia1T2CL       =     Pia1Base+$8
Pia1T2CH       =     Pia1Base+$9
Pia1SR         =     Pia1Base+$a
Pia1ACR        =     Pia1Base+$b
Pia1PCR        =     Pia1Base+$c
Pia1IFR        =     Pia1Base+$d
Pia1IER        =     Pia1Base+$e
Pia1PRA1       =     Pia1Base+$f
;
;***********************************************************************
; 6522 VIA I/O Support Routines
;
Pia1_init      
               ldx   #$00              ; get data from table
Pia1init1      lda   Pia1idata,x       ; init all 16 regs from 00 to 0F
               sta   Pia1Base,x        ; 
               inx                     ; 
               cpx   #$07              ; 
               bne   Pia1init1         ;       
               rts                     ; done
;
Pia1idata      .byte $00               ; prb  '00000000'
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
