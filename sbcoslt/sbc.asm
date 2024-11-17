;      *= $8002			; create exact 32k bin image

;
; prefill 32k block from $8002-$ffff with 'FF'
;
;      .rept 2047
;         .byte  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff ;
;      .next 
;      .byte  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff  ;

;
; compile the sections of the OS
;

;	*=$FC00
;	*=$F400
	*=$2000
        .include ramstart.asm

 	.include VIA1.asm	         ;        VIA1 init
; 	.include VIA2.asm	         ;        VIA2 init
; 	.include PIA1.asm	         ;        PIA1 init
        .include ACIA1.asm	   ; 6551 ACIA init (9600,n,8,1)
        .include ACIA2.asm	   ; 6850 ACIA init (9600,n,8,1)

 	.include sbcos.asm         ; OS
 
;	.include reset.asm         ; Reset & IRQ handler

