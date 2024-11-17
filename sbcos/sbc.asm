      *= $8002			; create exact 32k bin image

; prefill 32k block from $8002-$ffff with 'FF'

      .rept 2047
         .byte  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff ;
      .next 
      .byte  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  ;

;
; compile the sections of the OS
;
	*=$9000
;        *=$2000
;	.include ramstart.asm      ; $2000  Enhanced BASIC 
	.include basic.asm         ; $BC00  Enhanced BASIC 
	.include basldsv.asm	   ;        EH-BASIC load & save support

        *=$E000
 	.include VIA1.asm	         ;        VIA1 init
 	.include VIA2.asm	         ;        VIA2 init
;     	.include ACIA1.asm	   ;        ACIA init (19200,n,8,1)
     	.include ACIA0.asm	   ;        6850 ACIA init (9600,n,8,1)

 	.include sbcos.asm         ; $E800  OS
 
 	.include upload.asm        ; $FA00  Intel Hex & Xmodem-CRC uploader
	.include reset.asm         ; $FF00  Reset & IRQ handler

