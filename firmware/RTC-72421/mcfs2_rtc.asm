;;;
;;; MCFS2 real time clock driver
;;; By: Daniel Tufvesson 2017
;;;
;;; Provides two external functions:
;;; rtc_get_time - read time from RTC hardware
;;; rtc_set_time - set time of RTC hardware
;;;

;;;
;;; RTC-72421 registers
;;; 
rtc_base:	equ	$9fc0
rtc_reg_s1:	equ	rtc_base+$0	; 1-second digit
rtc_reg_s10:	equ	rtc_base+$1	; 10-seconds digit
rtc_reg_mi1:	equ	rtc_base+$2	; 1-minute digit
rtc_reg_mi10:	equ	rtc_base+$3	; 10-minutes digit
rtc_reg_h1:	equ	rtc_base+$4	; 1-hour digit
rtc_reg_h10:	equ	rtc_base+$5	; 10-hours digit
rtc_reg_d1:	equ	rtc_base+$6	; 1-day digit
rtc_reg_d10:	equ	rtc_base+$7	; 10-days digit
rtc_reg_mo1:	equ	rtc_base+$8	; 1-month digit
rtc_reg_mo10:	equ	rtc_base+$9	; 10-months digit
rtc_reg_y1:	equ	rtc_base+$a	; 1-year digit
rtc_reg_y10:	equ	rtc_base+$b	; 10-years digit
rtc_reg_w:	equ	rtc_base+$c	; Day of week
rtc_reg_cd:	equ	rtc_base+$d	; Control reg D
rtc_reg_ce:	equ	rtc_base+$e	; Control reg E
rtc_reg_cf:	equ	rtc_base+$f	; Control reg F

;;;
;;; Get ISO 8601 time stamp from RTC and store at X
;;;
rtc_get_time:
	psha
	pshb
rtc_get_time_loop:
;;; Loop until two identical time stamps have been read
	jsr	rtc_get_time_sample
	tstb
	bne	rtc_get_time_loop
	pulb
	pula
	rts
rtc_get_time_sample:
	clrb
;;; Read SECONDS
	pshx
	ldx	#rtc_reg_s1
	jsr	rtc_read_8bit
	pulx
	cmpa	6,x
	beq	*+3
	incb
	staa	6,x
;;; Read MINUTES
	pshx
	ldx	#rtc_reg_mi1
	jsr	rtc_read_8bit
	pulx
	anda	#$7f
	cmpa	5,x
	beq	*+3
	incb
	staa	5,x
;;; Read HOURS
	pshx
	ldx	#rtc_reg_h1
	jsr	rtc_read_8bit
	pulx
	anda	#$3f
	cmpa	4,x
	beq	*+3
	incb
	staa	4,x
;;; Read DAY
	pshx
	ldx	#rtc_reg_d1
	jsr	rtc_read_8bit
	pulx
	anda	#$3f
	cmpa	3,x
	beq	*+3
	incb
	staa	3,x
;;; Read MONTH
	pshx
	ldx	#rtc_reg_mo1
	jsr	rtc_read_8bit
	pulx
	anda	#$1f
	cmpa	2,x
	beq	*+3
	incb
	staa	2,x
;;; Read YEAR
	pshx
	ldx	#rtc_reg_y1
	jsr	rtc_read_8bit
	pulx
	cmpa	1,x
	beq	*+3
	incb
	staa	1,x
;;; Read CENTURY
	ldaa	ram_time+0
	staa	0,x
	rts
;;; Helper funtion to assemble two RTC nibs to one byte
rtc_read_8bit:
	pshb
	ldaa	1,x
	asla
	asla
	asla
	asla
	ldab	0,x
	andb	#$0f
	aba
	pulb
	rts

;;;
;;; Set RTC to ISO 8601 time stamp stored at X
;;;
rtc_set_time:
;;; Stop RTC
	ldaa	#$07
	staa	rtc_reg_cf
	clra
	staa	rtc_reg_cd
;;; Set CENTURY
	ldaa	0,x
	staa	ram_time+0
;;; Set YEAR
	ldaa	1,x
	pshx
	ldx	#rtc_reg_y1
	jsr	rtc_write_8bit
	pulx
;;; Set MONTH
	ldaa	2,x
	pshx
	ldx	#rtc_reg_mo1
	jsr	rtc_write_8bit
	pulx
;;; Set DAY
	ldaa	3,x
	pshx
	ldx	#rtc_reg_d1
	jsr	rtc_write_8bit
	pulx
;;; Set HOURS
	ldaa	4,x
	pshx
	ldx	#rtc_reg_h1
	jsr	rtc_write_8bit
	pulx
;;; Set MINUTES
	ldaa	5,x
	pshx
	ldx	#rtc_reg_mi1
	jsr	rtc_write_8bit
	pulx
;;; Set SECONDS
	ldaa	6,x
	pshx
	ldx	#rtc_reg_s1
	jsr	rtc_write_8bit
	pulx
;;; Start RTC
	ldaa	#$04
	staa	rtc_reg_cf
	rts
;;; Helper funtion to assemble two RTC nibs to one byte
rtc_write_8bit:
	pshb
	tab
	lsra
	lsra
	lsra
	lsra
	staa	1,x
	andb	#$0f
	stab	0,x
	pulb
	rts
