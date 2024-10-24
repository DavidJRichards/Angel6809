*****************************************************
** 	LCD                                         *
*****************************************************

MC800   EQU     $C0E0 ; LCD
MC801   EQU     $C0E1 ; LCD_

        ORG     $1000 
        BSR     ZF958
        BRA     ZF93E

; Initialise Direct Page Register for Zero page
		CLRA
		TFR	A,DP	
; Tell asm6809 what page the DP register has been set to
		SETDP	#$00

ZF900   BRA     ZF90E  ; pr xxxx                   ;*F900: 20 0C          ' .'
ZF902   BRA     ZF91A  ; pr aa                  ;*F902: 20 16          ' .'
ZF904   BRA     ZF938  ; op spc                   ;*F904: 20 32          ' 2'
ZF906   BRA     ZF930  ; op crlf                  ;*F906: 20 28          ' ('
ZF908   BRA     ZF93E  ; lcd init                  ;*F908: 20 34          ' 4'
ZF90A   BRA     ZF958  ; lcd setvec                  ;*F90A: 20 4C          ' L'
ZF90C   BRA     ZF962  ; lcd out                  ;*F90C: 20 54          ' T'

ZE7FC   FDB     0

ZF90E   PSHS D         ; pr xxxx                    ;*F90E: 34 06          '4.'
        TFR     X,D                      ;*F910: 1F 10          '..'
        BSR     ZF91A                    ;*F912: 8D 06          '..'
        EXG     B,A                      ;*F914: 1E 98          '..'
        BSR     ZF91A                    ;*F916: 8D 02          '..'
        PULS    PC,D                     ;*F918: 35 86          '5.'

ZF91A   PSHS A         ; pr aa                    ;*F91A: 34 02          '4.'
        ASRA                             ;*F91C: 47             'G'
        ASRA                             ;*F91D: 47             'G'
        ASRA                             ;*F91E: 47             'G'
        ASRA                             ;*F91F: 47             'G'
        BSR     ZF924                    ;*F920: 8D 02          '..'
        PULS A                             ;*F922: 35 02          '5.'

ZF924   ANDA    #$0F   ; pr crlf                  ;*F924: 84 0F          '..'
        CMPA    #$0A                     ;*F926: 81 0A          '..'
        BCS     ZF92C                    ;*F928: 25 02          '%.'
        ADDA    #$07                     ;*F92A: 8B 07          '..'
ZF92C   ADDA    #$30                     ;*F92C: 8B 30          '.0'
        BRA     ZF93A                    ;*F92E: 20 0A          ' .'

ZF930   LDA     #$0D                     ;*F930: 86 0D          '..'
        BSR     ZF93A                    ;*F932: 8D 06          '..'
        LDA     #$0A                     ;*F934: 86 0A          '..'
        BRA     ZF93A                    ;*F936: 20 02          ' .'

ZF938   LDA     #$20   ; pr spc                  ;*F938: 86 20          '. '
ZF93A   JMP     [ZE7FC]  ;outvec               ;*F93A: 6E 9F E7 FC    'n...'

ZF93E   PSHS    X,D    ; lcd init                  ;*F93E: 34 16          '4.'
;        LEAX    MFDDE,PCR                ;*F940: 30 8D 04 9A    '0...'
        LEAX    LCT3,PCR                ;*F940: 30 8D 04 9A    '0...'
        LDA     ,X+                      ;*F944: A6 80          '..'
ZF946   LDB     ,X+                      ;*F946: E6 80          '..'
        BSR     ZF9BA  ; lc ctrl                  ;*F948: 8D 70          '.p'
        DECA                             ;*F94A: 4A             'J'
        BNE     ZF946                    ;*F94B: 26 F9          '&.'

        LDB     ,X+                      ;*F94D: E6 80          '..'
ZF94F   LDA     ,X+                      ;*F94F: A6 80          '..'
        BSR     ZF90C  ; lc out                  ;*F951: 8D B9          '..'
        DECB                             ;*F953: 5A             'Z'
        BNE     ZF94F                    ;*F954: 26 F9          '&.'
        PULS    PC,X,D                   ;*F956: 35 96          '5.'

ZF958   PSHS    X,D    ; lcd setvec                  ;*F958: 34 16          '4.'
        LEAX    ZF90C,PCR                ;*F95A: 30 8C AF       '0..'
        STX     ZE7FC   ; outvec                 ;*F95D: BF E7 FC       '...'
        PULS    PC,X,D                   ;*F960: 35 96          '5.'

ZF962   PSHS    X,D    ; lcd out                  ;*F962: 34 16          '4.'
        ANDA    #$7F                     ;*F964: 84 7F          '..'
        CMPA    #$18                     ;*F966: 81 18          '..'
        BNE     ZF974                    ;*F968: 26 0A          '&.'
        LDB     #$01                     ;*F96A: C6 01          '..'
        BSR     ZF9BA                    ;*F96C: 8D 4C          '.L'
        LDB     #$A8                     ;*F96E: C6 A8          '..'
        BSR     ZF9BA                    ;*F970: 8D 48          '.H'
        BRA     ZF9B8                    ;*F972: 20 44          ' D'
ZF974   CMPA    #$0E                     ;*F974: 81 0E          '..'
        BNE     ZF988                    ;*F976: 26 10          '&.'
        LDB     #$05                     ;*F978: C6 05          '..'
        BSR     ZF9BA                    ;*F97A: 8D 3E          '.>'
        LDA     #$20                     ;*F97C: 86 20          '. '
        BSR     ZF90C                    ;*F97E: 8D 8C          '..'
        LDB     #$07                     ;*F980: C6 07          '..'
        LDA     #$0E                     ;*F982: 86 0E          '..'
        BSR     ZF9BA                    ;*F984: 8D 34          '.4'
        BRA     ZF9B8                    ;*F986: 20 30          ' 0'
ZF988   CMPA    #$0D                     ;*F988: 81 0D          '..'
        BEQ     ZF9B8                    ;*F98A: 27 2C          '','
        CMPA    #$0A                     ;*F98C: 81 0A          '..'
        BEQ     ZF9B8                    ;*F98E: 27 28          ''('
        CMPA    #$61                     ;*F990: 81 61          '.a'
        BCS     ZF996                    ;*F992: 25 02          '%.'
        ANDA    #$5F                     ;*F994: 84 5F          '._'
ZF996   CMPA    #$5C                     ;*F996: 81 5C          '.\'
        BCS     ZF9A3                    ;*F998: 25 09          '%.'
        CMPA    #$60                     ;*F99A: 81 60          '.`'
        BHI     ZF9A3                    ;*F99C: 22 05          '".'
;        LEAX    MF967,PCR                ;*F99E: 30 8C C6       '0..'
        LEAX    LCT1-$5C,PCR                ;*F99E: 30 8C C6       '0..'
        BRA     ZF9AE                    ;*F9A1: 20 0B          ' .'
ZF9A3   CMPA    #$20                     ;*F9A3: 81 20          '. '
        BCS     ZF9B0                    ;*F9A5: 25 09          '%.'
        CMPA    #$40                     ;*F9A7: 81 40          '.@'
        BHI     ZF9B0                    ;*F9A9: 22 05          '".'
;        LEAX    MF9A8,PCR                ;*F9AB: 30 8C FA       '0..'
        LEAX    LCT2-$20,PCR                ;*F9AB: 30 8C FA       '0..'
ZF9AE   LDA     A,X      ; lcd data                ;*F9AE: A6 86          '..'
ZF9B0   
        TST     MC800                    ;*F9B0: 7D C8 00       '}..'
        BMI     ZF9B0                    ;*F9B3: 2B FB          '+.'
        STA     MC801                    ;*F9B5: B7 C8 01       '...'
        NOP
        NOP
        NOP
        NOP
ZF9B8   PULS    PC,X,D                   ;*F9B8: 35 96          '5.'

ZF9BA   
        TST     MC800    ; lcd ctrl                ;*F9BA: 7D C8 00       '}..'
        BMI     ZF9BA                    ;*F9BD: 2B FB          '+.'
        STB     MC800                    ;*F9BF: F7 C8 00       '...'
        NOP
        NOP
        NOP
        NOP
        RTS                              ;*F9C2: 39             '9'

LCT1	
	fcb	$6a, $5c, $6f, $ca, $3e ;

LCT2
	fdb	$2040, $2223, $6024 ;
	fdb	$2526, $2728, $293f 
	fdb	$2a2b, $2c2d, $3031 
	fdb	$3233, $3435, $3637 
	fdb	$3839, $3a3b, $2f3c 
	fdb	$2e3d, $21ff, $ffff 
	fdb	$1234, $5678 

LCT3
	fcb	7 
	fcb	$30, $30, $06 
	fcb	$0e, $01, $07, $a8 
	fcb	24 
	fcc	" 6809 monitor v1.1 1989 " 
	

