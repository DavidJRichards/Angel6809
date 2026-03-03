
  name userio 

acia equ $9008
aciac equ acia
aciad equ acia+1

rdrf equ 1
tdre equ 2
arst equ 3
aset equ $15

userin equ $a410
userout equ $a412
f1key equ $a386

restart equ $f000
msgprint equ $f018

 org $1000
setup pshs x
 ldx #serin
 stx userin
 ldx #serout
 stx userout
 ldx #setup
 stx f1key
 bsr init
 ldx #msg
 lbsr msgprint
 puls x
 jmp restart

init pshs a
 lda #arst
 sta aciac
 lda #aset
 sta aciac
 puls a,pc

serout pshs b
seroul ldb aciac
 bitb #tdre
 beq seroul
 sta aciad
 puls b,pc

serin lda aciac
 bita #rdrf
 beq serin
 lda aciad
 rts

msg fcc "Init 6850 ACIA"
 fcb 0

 end


