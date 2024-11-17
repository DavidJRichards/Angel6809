RamStart       SEI                     ; diable interupts
               CLD                     ; clear decimal mode                      
               LDX   #$FF              ;
               TXS                     ; init stack pointer
;               jsr   Via2_init
               jsr   Via1_init
               jsr   ACIA1_init
               jsr   ACIA2_init	       ; init the I/O devices
;               jsr   Pia1_init

               CLI                     ; Enable interrupt system
               JMP  MonitorBoot        ; Monitor for cold reset                       

