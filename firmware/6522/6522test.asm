VIA_T1CL = $A804 ; timer 1 counter low
VIA_T1CH = $A805 ; timer 1 counter high
VIA_ACL  = $A80B ; Auxiliary Control register
VIA_IER  = $A80E ; Interrupt Enable Register
VIA_IFR  = $A80D ; Interrupt Flag Register

TIMER_COUNT = $0510  ; A two-byte memory location to store a counter
TIMER_INTVL = $270E  ; The number the timer is going to count down from

LESS_THAN = 0
EQUAL = 1
MORE_THAN = 2
 
FUNC_RESULT = $0512    ; or a RAM location of your choice

    lda #%11000000 ; setting bit 7 sets interrupts and bit 6 enables Timer 1
    sta VIA_IER

    lda #%01000000
    sta VIA_ACL

; We set up TIMER_INTVL earlier,,,
    lda #<TIMER_INTVL      ; Load low byte of our 16-bit value
    sta VIA_T1CL
    lda #>TIMER_INTVL      ; Load high byte of our 16-bit value
    sta VIA_T1CH           ; This starts the timer running

;===============================================================================

ISR_handler
      pha : 
      phx : 
      phy
      ; other ISR stuff perhaps
      bit VIA_IFR          ; Bit 6 copied to overflow flag
      bvc isr_timer_end    ; Overflow clear, so not this...
isr_timer
      lda VIA_T1CL         ; Clears the interrupt
      inc TIMER_COUNT      ; Increment low byte
      bne isr_timer_end    ; Low byte didn't roll over, so we're all done
      inc TIMER_COUNT + 1  ; previous byte rolled over, so increment high byte
isr_timer_end
      jmp exit_isr
; other isr stuff
exit_isr
      ply : 
      plx : 
      pla
      rti
      
;===============================================================================      
      
via_chk_timer
      sei                         ; Don't want interrupts changing the value of TIMER_COUNT
      pha
      lda TIMER_COUNT + 1         ; Compare the high bytes first as if they aren't
      cmp #<TIMER_INTVL + 1       ; equal, we don't need to compare the low bytes
      bcc via_chk_timer_less_than ; Count is less than interval
      bne via_chk_timer_more_than ; Count is more than interval
      lda TIMER_COUNT             ; High bytes equal - what about low bytes?
      cmp TIMER_INTVL
      bcc via_chk_timer_less_than
      bne via_chk_timer_more_than
      lda #EQUAL                  ; COUNT = INTVL - this what we're looking for.
      jmp via_chk_timer_reset
via_chk_timer_less_than
      lda #LESS_THAN ; COUNT < INTVL - counter isn't big enough yet
      jmp via_chk_timer_end ; so let's bug out.
via_chk_timer_more_than
      lda #MORE_THAN ; COUNT > INTVL - shouldn't happen, but still...
via_chk_timer_reset
      stz VIAC_TIMER_COUNT ; reset counter
      stz VIAC_TIMER_COUNT + 1
via_chk_timer_end
      sta FUNC_RESULT
      pla
      cli
      rts      
      
;===============================================================================


0 ORB            
1 ORA
2 DDRB
3 DDRA
4/5 T1C
4 TIL-L / T1C-L
5 T1C-H
6/7 T1L
6 T1L-L
7 T1L-H
8/9 T2C
8 T2L-L / T2C-L
9 T2C-H
A SR
B ACR
C PCR
D IFR
E IER
F ORA


ONESHOT2  LDA   #$00
          STA   ACR      ;Select Mode
          STA   T2LL     ;Low-Latch=0
          LDA   #$01     ;Delay Duration
          STA   T2CH     ;High Part=01hex.  Start
          LDA   #$20     ;Mask
LOOP      BIT   IFR      ;Time out?
          BEQ   LOOP
          LDA   T2CL     ;Clear Timer 2 Interrupt
          
          
ONESHOT1  LDA   #$00
          STA   ACR      ;1-Shot Mode: No PB7 Pulses
          STA   T1LL     ;Low-Latch
          LDA   #$01     ;Delay
          STA   T1CH     ;Loads also T1CL and Starts
          LDA   #$20
LOOP      BIT   IFR      ;Time Out?
          BEQ   LOOP
          LDA   T1LL     ;Clear Interrupt Flag
          


      
