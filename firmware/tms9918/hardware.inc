; vim:noet:sw=8:ts=8:ai:syn=as6809
;	ifndef	_HARDWARE_INC_
;	define _HARDWARE_INC_

;************ Memory ************
RAMSTART	equ    	0x0000
RAMEND		equ    	0x7FFF
XRAMSTART	equ    	0x8000
XRAMEND		equ    	0xBFFF
STKSTART	equ    	RAMEND
ROMSTART	equ    	0xE000
USERPROG_ORG	equ    	0x0100		;entry point for user programs
ROMDP		equ    	0x00		;ROM requires direct page to be 0
ROMSTKSTART	equ    	(ROMDP<<8)+64	;ROM stack
SYSRAM		equ    	0x02		;start of system-used RAM
					;(bytes 0x0000 and 0x0001 unused)

VDP		equ    	0xC080		;TMS9918A Video Display Processor
VDP_VRAM	equ    	VDP+0		;used for VRAM reads/writes
VDP_REG		equ    	VDP+1		;control registers/address latch
VBANK_LOWER	equ    	VDP+0x4		;read to select lower 16K of VRAM
VBANK_UPPER	equ    	VDP+0xC		;read to select upper 16K of VRAM
VRAM		equ    	0x4000		;high bits of VRAM address


;************ Console escape codes ************
ESC_CLRSCR	equ    	0xFF
ESC_CLRLINE	equ    	0xFE


;************* Common characters ************
NLCHAR		equ    	0x0A
CRCHAR		equ    	0x0D
BACKSPACECHAR	equ    	0x08
DELETECHAR	equ    	0x7F

;	endif
