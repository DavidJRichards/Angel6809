;******************************************************************************
;	MECB_6522_VIA_IRQ.asm
;
;	A simple 6809 test for the MECB Prototype 6522 VIA Card and IRQ Interrupts.
;
;	This version is intended as RAM loadable code (eg. $0100 Entry).
;       uses old 4 digit 7 segment display on port B
;
;	VIA defaults to base address $C030
;
;	Author: david@djrm.net
;	Date:	Sep 2024
;
;******************************************************************************
Entry		EQU	$1000	; Code entry address (Zero page reserved for storage)
VDP 		EQU	$E080	; TMS9929A Video Display Processor address
VDP_VRAM	EQU	VDP+0	; VDP VRAM access address
VDP_REGISTER	EQU	VDP+1	; VDP Register access address
VCTRSWP		EQU	9	; ASSIST09 Vector Swap Service
IRQ_CODE	EQU	12	; IRQ Appendage Swap Function Code

VIA_BASE        EQU     $C030
VIA_ORB         EQU     0  
VIA_ORA         EQU     1
VIA_DDRB        EQU     2
VIA_DDRA        EQU     3
VIA_T1C         EQU     4 ; 4 & 5
VIA_TIL_L       EQU     4
VIA_T1C_L       EQU     4
VIA_T1C_H       EQU     5
VIA_T1L         EQU     6 ; 6 & 7
VIA_T1L_L       EQU     6
VIA_T1L_H       EQU     7
VIA_T2C         EQU     8 ; 8 & 9
VIA_T2L_L       EQU     8
VIA_T2C_L       EQU     8
VIA_T2C_H       EQU     9
VIA_SR          EQU     $A
VIA_ACR         EQU     $B
VIA_PCR         EQU     $C
VIA_IFR         EQU     $D
VIA_IER         EQU     $E
;VIA_ORA         EQU     $F



;
; Main Entry Point
		ORG	Entry
;		CLRA		; Initialise Direct Page Register for Zero page
;		TFR	A,DP	
; Tell asm6809 what page the DP register has been set to
;		SETDP	#$00
		
; Setup IRQ Handler
		LEAX	VIA_ISR,PCR
		LDA	#IRQ_CODE
		SWI
		FCB	VCTRSWP
; Clear CC IRQ Flag - Enable IRQ Interrupts
		ANDCC	#$EF	
		
; Setup VDP Initial Settings for Registers 0 - 7
		LDX	#VIA_BASE
		BSR	VIA_START
;                RTS
;
; Loop Forever
LoopForever	BRA	LoopForever
;
; *** End of Mainline. Subroutines follow ***
;
VIA_ISR
                LDA     #$10
                STA     VIA_BASE+VIA_T2C_L
                LDA     #$27
                STA     VIA_BASE+VIA_T2C_H
                INC     VIA_BASE+VIA_ORB
                RTI
                
VIA_START
                LDA     #$A0
                STA     VIA_BASE+VIA_IER
                LDA     #$FF
                STA     VIA_BASE+VIA_DDRB
                LDA     #$FF
                STA     VIA_BASE+VIA_ORB
                ANDCC	#$EF
                LDA     #$50
                STA     VIA_BASE+VIA_T2C_L
                LDA     #$C3
                STA     VIA_BASE+VIA_T2C_H
                RTS                
