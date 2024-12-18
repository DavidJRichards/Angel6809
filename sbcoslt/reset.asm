; ----------------- assembly instructions ---------------------------- 
;
;****************************************************************************
; Reset, Interrupt, & Break Handlers
;****************************************************************************
;               *= $FF00             ; put this in last page of ROM

;--------------Reset handler----------------------------------------------
Reset          SEI                     ; diable interupts
               CLD                     ; clear decimal mode                      
               LDX   #$FF              ;
               TXS                     ; init stack pointer
               jsr   ACIA1_init	       ; init the I/O devices

               CLI                     ; Enable interrupt system
               JMP  MonitorBoot        ; Monitor for cold reset                       
;
Interrupt      PHA                     ; a
               TXA  	               ; 
               PHA                     ; X
               TSX                     ; get stack pointer
               LDA   $0103,X           ; load INT-P Reg off stack
               AND   #$10              ; mask BRK
               BNE   BrkCmd            ; BRK CMD
               PLA                     ; x
               tax                     ; 		
               pla                     ; a
NMIjump        RTI                     ; Null Interrupt return
BrkCmd         pla                     ; X
               tax                     ;
               pla                     ; A
               jmp   BRKroutine        ; patch in user BRK routine

;
;  NMIjmp      =     $FFFA             
;  RESjmp      =     $FFFC             
;  INTjmp      =     $FFFE             

               *=    $FFFA
               .word  NMIjump
               .word  Reset 
               .word  Interrupt
;end of file
