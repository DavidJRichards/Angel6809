
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

 org $1000
 jmp setup

init pshs a
 lda #arst
 sta $9000
 lda #aset
 sta $9000
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

setup pshs d 
 ldd #serin
 std userin
 ldd #serout
 std userout
 ldd setup
 std f1key
 bsr init
 puls d
 jmp restart

 end


