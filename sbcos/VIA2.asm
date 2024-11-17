; ----------------- assembly instructions ---------------------------- 
;
; this is a subroutine library only
; it must be included in an executable source file
;
;
;*** I/O Locations *******************************
; define the i/o address of the Via2 chip
;*** 6522 CIA ************************
Via2Base       =     $c010
Via2PRB        =     Via2Base+$0
Via2PRA        =     Via2Base+$1
Via2DDRB       =     Via2Base+$2
Via2DDRA       =     Via2Base+$3
Via2T1CL       =     Via2Base+$4
Via2T1CH       =     Via2Base+$5
Via2T1LL       =     Via2Base+$6
Via2TALH       =     Via2Base+$7
Via2T2CL       =     Via2Base+$8
Via2T2CH       =     Via2Base+$9
Via2SR         =     Via2Base+$a
Via2ACR        =     Via2Base+$b
Via2PCR        =     Via2Base+$c
Via2IFR        =     Via2Base+$d
Via2IER        =     Via2Base+$e
Via2PRA1       =     Via2Base+$f
;
;***********************************************************************
; 6522 VIA I/O Support Routines
;
Via2_init      
               lda      #$30
               sta      $c0f0
               lda      #$31
               sta      $c0f1
               lda      #$32
               sta      $c0f2
               lda      #$33
               sta      $c0f3
               ldx   #$00              ; get data from table
Via2init1      lda   Via2idata,x       ; init all 16 regs from 00 to 0F
               sta   Via2Base,x        ; 
               inx                     ; 
               cpx   #$07              ; 
               bne   Via2init1         ;       
               rts                     ; done
;
Via2idata      .byte $00               ; prb  '00000000'
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
