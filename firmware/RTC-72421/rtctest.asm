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
rtc_base	equ	$c040
rtc_reg_s1	equ	rtc_base+$0	; 1-second digit
rtc_reg_s10	equ	rtc_base+$1	; 10-seconds digit
rtc_reg_mi1	equ	rtc_base+$2	; 1-minute digit
rtc_reg_mi10	equ	rtc_base+$3	; 10-minutes digit
rtc_reg_h1	equ	rtc_base+$4	; 1-hour digit
rtc_reg_h10	equ	rtc_base+$5	; 10-hours digit
rtc_reg_d1	equ	rtc_base+$6	; 1-day digit
rtc_reg_d10	equ	rtc_base+$7	; 10-days digit
rtc_reg_mo1	equ	rtc_base+$8	; 1-month digit
rtc_reg_mo10	equ	rtc_base+$9	; 10-months digit
rtc_reg_y1	equ	rtc_base+$a	; 1-year digit
rtc_reg_y10	equ	rtc_base+$b	; 10-years digit
rtc_reg_w	equ	rtc_base+$c	; Day of week
rtc_reg_cd	equ	rtc_base+$d	; Control reg D
rtc_reg_ce	equ	rtc_base+$e	; Control reg E
rtc_reg_cf	equ	rtc_base+$f	; Control reg F


INCHNP  EQU     0               ; INPUT CHAR IN A REG - NO PARITY
OUTCH   EQU     1               ; OUTPUT CHAR FROM A REG
PDATA1  EQU     2               ; OUTPUT STRING
PDATA   EQU     3               ; OUTPUT CR/LF THEN STRING
OUT2HS  EQU     4               ; OUTPUT TWO HEX AND SPACE
OUT4HS  EQU     5               ; OUTPUT FOUR HEX AND SPACE
PCRLF   EQU     6               ; OUTPUT CR/LF
SPACE   EQU     7               ; OUTPUT A SPACE
MONITR  EQU     8               ; ENTER ASSIST09 MONITOR

        org     $1000
        
        bra     rtc_show_time
        bra     rtc_get_time
        lbra    rtc_set_time
                
        fcb      0
ram_time
rt_c    fcb     $20     0 century
rt_y    fcb     $24     1 year
rt_o    fcb     $10     2 month
rt_d    fcb     $03     3 date
rt_h    fcb     $17     4 hour
rt_m    fcb     $55     5 minute
rt_s    fcb     0       6 second
rt_cs   fcb     0       7

rtc_show_time        
        leax    ram_time,pcr
        bsr     rtc_get_time
        
        lda     #'<'
        bsr     outch
        ldd     0,x     ; year
        bsr     out4h
        lda     #'-'
        bsr     outch
        lda     3,x     ; date
        bsr     out2h
        lda     #'-'
        bsr     outch
        lda     2,x     ; month
        bsr     out2h

        lda     #$20
        bsr     outch

        lda     4,x     ; hours
        bsr     out2h
        lda     #':'        
        bsr     outch
        lda     5,x     ; minutes
        bsr     out2h
        lda     #':'
        bsr     outch
        lda     6,x     ; seconds
        bsr     out2h
        lda     #'>'
        bsr     outch
        rts
        
        leax    ram_time,pcr
        lbra    rtc_set_time

out4h                   ; output as hex digits contents of D register
ZF90E   PSHS D         ; pr xxxx      
        BSR     ZF91A                   
        EXG     B,A                     
        BSR     ZF91A                   
        PULS    PC,D                    

out2h
ZF91A   PSHS A         ; pr aa                   
        ASRA                           
        ASRA                           
        ASRA                           
        ASRA                            
        BSR     ZF924                  
        PULS A                         

ZF924   ANDA    #$0F   ; pr x             
        CMPA    #$0A                 
        BCS     ZF92C                
        ADDA    #$07                  
ZF92C   ADDA    #$30                 

outch
        pshs  cc                ; preserve irq mask which is set by assis09
        SWI                     ; Call ASSIST09 monitor function
        FCB     OUTCH           ; Service code byte
        puls  cc
        RTS



;;;
;;; Get ISO 8601 time stamp from RTC and store at X
;;;
rtc_get_time
        pshs a,b
rtc_get_time_loop
;;; Loop until two identical time stamps have been read
	jsr	rtc_get_time_sample
	tstb
	bne	rtc_get_time_loop
        puls    a,b,pc

rtc_get_time_sample
	clrb            ; Cant single step clrb
;        ldb     #0
;;; Read SECONDS
	pshs    x
	ldx	#rtc_reg_s1
	jsr	rtc_read_8bit
	puls    x
	cmpa	6,x
	beq	*+3
	incb
	sta	6,x
;;; Read MINUTES
	pshs    x
	ldx	#rtc_reg_mi1
	jsr	rtc_read_8bit
	puls    x
	anda	#$7f
	cmpa	5,x
	beq	*+3
	incb
	sta	5,x
;;; Read HOURS
	pshs    x
	ldx	#rtc_reg_h1
	jsr	rtc_read_8bit
	puls    x
	anda	#$3f
	cmpa	4,x
	beq	*+3
	incb
	sta	4,x
;;; Read DAY
	pshs    x
	ldx	#rtc_reg_d1
	jsr	rtc_read_8bit
	puls    x
	anda	#$3f
	cmpa	3,x
	beq	*+3
	incb
	sta	3,x
;;; Read MONTH
	pshs    x
	ldx	#rtc_reg_mo1
	jsr	rtc_read_8bit
	puls    x
	anda	#$1f
	cmpa	2,x
	beq	*+3
	incb
	sta	2,x
;;; Read YEAR
	pshs    x
	ldx	#rtc_reg_y1
	jsr	rtc_read_8bit
	puls    x
	cmpa	1,x
	beq	*+3
	incb
	sta	1,x
;;; Read CENTURY
	lda	ram_time+0
	sta	0,x
	rts
	
;;; Helper funtion to assemble two RTC nibs to one byte
rtc_read_8bit
	pshs    b
	lda	1,x
	asla
	asla
	asla
	asla
	ldb	0,x
	andb	#$0f
        pshs    b       ; ABA
        adda    ,S+     ; ABA
	puls    b,pc

;;;
;;; Set RTC to ISO 8601 time stamp stored at X
;;;
rtc_set_time
;;; Stop RTC
	lda	#$07
	sta	rtc_reg_cf
	lda	#$04            ; OUTPUT 1 SECOND PULSE ON STD.P
	sta	rtc_reg_ce
	clra                    ; CANT SINGLE STEP CLRA
;        lda     #0
	sta	rtc_reg_cd
;;; Set CENTURY
	lda	0,x
	sta	ram_time+0
;;; Set YEAR
	lda	1,x
	pshs    x
	ldx	#rtc_reg_y1
	jsr	rtc_write_8bit
	puls    x
;;; Set MONTH
	lda	2,x
	pshs    x
	ldx	#rtc_reg_mo1
	jsr	rtc_write_8bit
	puls    x
;;; Set DAY
	lda	3,x
	pshs    x
	ldx	#rtc_reg_d1
	jsr	rtc_write_8bit
	puls    x
;;; Set HOURS
	lda	4,x
	pshs    x
	ldx	#rtc_reg_h1
	jsr	rtc_write_8bit
	puls    x
;;; Set MINUTES
	lda	5,x
	pshs    x
	ldx	#rtc_reg_mi1
	jsr	rtc_write_8bit
	puls    x
;;; Set SECONDS
	lda	6,x
	pshs    x
	ldx	#rtc_reg_s1
	jsr	rtc_write_8bit
	puls    x
;;; Start RTC
	lda	#$04
	sta	rtc_reg_cf
	rts
	
;;; Helper funtion to assemble two RTC nibs to one byte
rtc_write_8bit
	pshs    b
        tfr     a,b
	lsra
	lsra
	lsra
	lsra
	sta	1,x
	andb	#$0f
	stb	0,x
	puls    b,pc

        END
