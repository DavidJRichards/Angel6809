* f9dasm: M6800/1/2/3/8/9 / H6309 Binary/OS9/FLEX9 Disassembler V1.78
* Loaded binary file 6809_Mon5.bin

*	SETLI 999
*****************************************************
** Used Labels                                      *
*****************************************************


Z0142   EQU     $0142	; Forth cold entry
Z0194   EQU     $0194	; Forth warm entry
M0400   EQU     $0400	; keyboard delay

M8000   EQU     $8000 ; VIA
M8002   EQU     $8002 ; VIA_

MC400   EQU     $C400 ; ACIA

MC800   EQU     $C800 ; LCD
MC801   EQU     $C801 ; LCD_

MD000   EQU     $D000 ; CLOCK
MD001   EQU     $D001 ; CLOCK_

MDIPG   EQU	    $E7   ; Monitor direct page
ME100   EQU     $E100 ; RX BUFFER
ME200   EQU     $E200 ; FILL INDEX
ME201   EQU     $E201 ; FULL FLAG
ME7B0   EQU     $E7B0 ; STACK
ME7D0   EQU     $E7D0 ; MONITOR STACK
ZE7E5   EQU     $E7E5 ; SW3 / USR VEC
ZE7E7   EQU     $E7E7 ; SW2 VEC
ZE7E9   EQU     $E7E9 ; FIQ VEC
ME7EC   EQU     $E7EC ; KB TMP
ME7ED   EQU     $E7ED ; CHSM
ZE7F2   EQU     $E7F2 ; NMI VEC
ZE7F4   EQU     $E7F4 ; IRQ VEC
ZE7F6   EQU     $E7F6 ; SWI VEC
M00F8   EQU       $F8 ; stack save 
ME7F8   EQU     $E7F8 ; STK SAV
ME7FA   EQU     $E7FA ; QT VEC
ZE7FC   EQU     $E7FC ; OUT VEC
ZE7FE   EQU     $E7FE ; IN VEC

*****************************************************
** Program Code / Data Areas                        *
*****************************************************

*****************************************************
** 	6551 ACIA                                   *
*****************************************************
        ORG     $F800 

ZF800   BRA     ZF808   ; init                 ;*F800: 20 06          ' .'
MF802   BRA     ZF83C   ; in ch                 ;*F802: 20 38          ' 8'
        BRA     ZF84B   ; out ch                ;*F804: 20 45          ' E'
        BRA     ZF85A   ; pqterm                 ;*F806: 20 52          ' R'

ZF808   PSHS    Y,X,D  	; init                  ;*F808: 34 36          '46'
        LDX     #MC400  ; acia                 ;*F80A: 8E C4 00       '...'
        LDA     #$9E    ; #control                 ;*F80D: 86 9E          '..'
        STA     $01,X   ; acia reset                 ;*F80F: A7 01          '..'
        STA     $03,X   ; set baud etc                 ;*F811: A7 03          '..'
        LDA     #$0B    ; #command                 ;*F813: 86 0B          '..'
        STA     $02,X   ; parity etc                ;*F815: A7 02          '..'
        LDA     $01,X   ; #status ?                 ;*F817: A6 01          '..'
        ANDA    #$20   	; dcd ?                  ;*F819: 84 20          '. '
;        LDA     ,X                       ;*F81B: A6 84          '..'
	      NOP            ;
	      NOP            ;
	      BNE	ZF82D    ;
;        BRA     ZF82D                    ;*F81D: 20 0E          ' .'
        LEAY    <ZF85A ; acia qterm             ;*F81F: 31 8C 38       '1.8'
        STY     ME7FA      ; qtvec              ;*F822: 10 BF E7 FA    '....'
        LEAY    <ZF83C ; acia in              ;*F826: 31 8C 13       '1..'
        STY     ZE7FE      ; invec                 ;*F829: 10 BF E7 FE    '....'
ZF82D   LDA     $01,X      ; # status ?              ;*F82D: A6 01          '..'
        ANDA    #$40    ; dsr ?                 ;*F82F: 84 40          '.@'
	bne	ZF83A          ;
;        BRA     ZF83A                    ;*F831: 20 07          ' .'
        LEAY    <ZF84B ; acia out              ;*F833: 31 8C 15       '1..'
        STY     ZE7FC      ; outvec              ;*F836: 10 BF E7 FC    '....'
	bra     YF940           ;
ZF83A   PULS    PC,Y,X,D                 ;*F83A: 35 B6          '5.'

ZF83C   PSHS    X,B    	; in                  ;*F83C: 34 14          '4.'
        LDX     #MC400                   ;*F83E: 8E C4 00       '...'
ZF841   LDB     $01,X                    ;*F841: E6 01          '..'
        BITB    #$08                     ;*F843: C5 08          '..'
        BEQ     ZF841                    ;*F845: 27 FA          ''.'
        LDA     ,X                       ;*F847: A6 84          '..'
        PULS    PC,X,B                   ;*F849: 35 94          '5.'

ZF84B   PSHS    X,B    	; out                  ;*F84B: 34 14          '4.'
        LDX     #MC400                   ;*F84D: 8E C4 00       '...'
ZF850   LDB     $01,X                    ;*F850: E6 01          '..'
        BITB    #$10                     ;*F852: C5 10          '..'
        BEQ     ZF850                    ;*F854: 27 FA          ''.'
        STA     ,X                       ;*F856: A7 84          '..'
        PULS    PC,X,B                   ;*F858: 35 94          '5.'

ZF85A   PSHS X                             ;*F85A: 34 10          '4.'
        LDX     #MC400                   ;*F85C: 8E C4 00       '...'
        LDA     $01,X                    ;*F85F: A6 01          '..'
        BITA    #$08                     ;*F861: 85 08          '..'
        BEQ     ZF877                    ;*F863: 27 12          ''.'
        LDA     ,X                       ;*F865: A6 84          '..'
        CMPA    #$1B                     ;*F867: 81 1B          '..'
        BNE     ZF878                    ;*F869: 26 0D          '&.'
ZF86B   LDA     $01,X                    ;*F86B: A6 01          '..'
        BITA    #$08                     ;*F86D: 85 08          '..'
        BEQ     ZF86B                    ;*F86F: 27 FA          ''.'
        LDA     ,X                       ;*F871: A6 84          '..'
        CMPA    #$1B                     ;*F873: 81 1B          '..'
        BNE     ZF878                    ;*F875: 26 01          '&.'
ZF877   CLRA                             ;*F877: 4F             'O'
ZF878   PULS    PC,X                     ;*F878: 35 90          '5.'

; get line of data into buffer
        LDA     MC400                    ;*F87A: B6 C4 00       '...'
        LEAX    ME100,PCR                ;*F87D: 30 8D E8 7F    '0...'
        LDB     ME200                    ;*F881: F6 E2 00       '...'
        STA     B,X                      ;*F884: A7 85          '..'
        INC     ME200                    ;*F886: 7C E2 00       '|..'
        CMPB    #$80                     ;*F889: C1 80          '..'
        BLT     ZF893                    ;*F88B: 2D 06          '-.'
        DEC     ME200                    ;*F88D: 7A E2 00       'z..'
        INC     ME201                    ;*F890: 7C E2 01       '|..'
ZF893   CMPA    #$0A                     ;*F893: 81 0A          '..'
        BNE     ZF897                    ;*F895: 26 00          '&.'
ZF897   RTS                              ;*F897: 39             '9'

;ZF93A   JMP     [ZE7FC]    ;outvec              ;*F93A: 6E 9F E7 FC    'n...'

YF93E   PSHS    X,Y,D    ; lcd init        
YF940   LEAX    LCT4,PCR                
        LDB     ,X+                      
YF946   LDA     ,X+                      
;        BSR     ZF93A ; outvec
	JSR	[ZE7FC] ; outvec
        DECB                             
        BNE     YF946    
	BSR	ZF906                 ; crlf
YF83A   PULS    PC,X,Y,D                 


*****************************************************
** 	LCD                                         *
*****************************************************
        ORG     $F900 

ZF900   BRA     ZF90E  ; pr xxxx                   ;*F900: 20 0C          ' .'
ZF902   BRA     ZF91A  ; pr aa                  ;*F902: 20 16          ' .'
ZF904   BRA     ZF938  ; op spc                   ;*F904: 20 32          ' 2'
ZF906   BRA     ZF930  ; op crlf                  ;*F906: 20 28          ' ('
ZF908   BRA     ZF93E  ; lcd init                  ;*F908: 20 34          ' 4'
ZF90A   BRA     ZF958  ; lcd setvec                  ;*F90A: 20 4C          ' L'
ZF90C   BRA     ZF962  ; lcd out                  ;*F90C: 20 54          ' T'

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
ZF9B0   TST     MC800                    ;*F9B0: 7D C8 00       '}..'
        BMI     ZF9B0                    ;*F9B3: 2B FB          '+.'
        STA     MC801                    ;*F9B5: B7 C8 01       '...'
ZF9B8   PULS    PC,X,D                   ;*F9B8: 35 96          '5.'

ZF9BA   TST     MC800    ; lcd ctrl                ;*F9BA: 7D C8 00       '}..'
        BMI     ZF9BA                    ;*F9BD: 2B FB          '+.'
        STB     MC800                    ;*F9BF: F7 C8 00       '...'
        RTS                              ;*F9C2: 39             '9'

LCT1	
	fcb	$6a, $5c, $6f, $ca, $3e ;

LCT2
	fcw	$2040, $2223, $6024 ;
	fcw	$2526, $2728, $293f 
	fcw	$2a2b, $2c2d, $3031 
	fcw	$3233, $3435, $3637 
	fcw	$3839, $3a3b, $2f3c 
	fcw	$2e3d, $21ff, $ffff 
	fcw	$1234, $5678 

;LCT3 MOVED TO END OF PAGE 0XFC
;	fcb	7 
;	fcb	$30, $30, $06 
;	fcb	$0e, $01, $07, $a8 
;	fcb	24 
;	fcc	" 6809 monitor v1.1 1989 " 
	
*****************************************************
** 	CLOCK                                       *
*****************************************************
        ORG     $FA00 

ZFA00   LBRA    ZFAB1                    ;*FA00: 16 00 AE       '...'
ZFA03   LBRA    ZFA06                    ;*FA03: 16 00 00       '...'
ZFA06   PSHS    X,D                      ;*FA06: 34 16          '4.'
        LBSR    ZFA8D                    ;*FA08: 17 00 82       '...'
        LDB     #$04                     ;*FA0B: C6 04          '..'
        LBSR    ZFAA3                    ;*FA0D: 17 00 93       '...'
        LBSR    ZF902                    ;*FA10: 17 FE EF       '...'
ZFA13   LDA     #$3A                     ;*FA13: 86 3A          '.:'
        JSR     [ZE7FC]  ; outvec                ;*FA15: AD 9F E7 FC    '....'
        LDB     #$02                     ;*FA19: C6 02          '..'
        LBSR    ZFAA3                    ;*FA1B: 17 00 85       '...'
        LBSR    ZF902                    ;*FA1E: 17 FE E1       '...'
        LDA     #$3A                     ;*FA21: 86 3A          '.:'
        JSR     [ZE7FC] ; outvec                 ;*FA23: AD 9F E7 FC    '....'
        LDB     #$00                     ;*FA27: C6 00          '..'
        BSR     ZFAA3                    ;*FA29: 8D 78          '.x'
        LBSR    ZF902                    ;*FA2B: 17 FE D4       '...'
        LBSR    ZF904                    ;*FA2E: 17 FE D3       '...'
        LBSR    ZF904                    ;*FA31: 17 FE D0       '...'
        LDB     #$06                     ;*FA34: C6 06          '..'
        BSR     ZFAA3                    ;*FA36: 8D 6B          '.k'
        SUBA    #$01                     ;*FA38: 80 01          '..'
        LDB     #$0A                     ;*FA3A: C6 0A          '..'
        MUL                              ;*FA3C: 3D             '='
        EXG     A,B                      ;*FA3D: 1E 89          '..'
        LEAX    MFD20,PCR                ;*FA3F: 30 8D 02 DD    '0...'
        LEAX    A,X                      ;*FA43: 30 86          '0.'
        LDB     ,X+                      ;*FA45: E6 80          '..'
ZFA47   LDA     ,X+                      ;*FA47: A6 80          '..'
        JSR     [ZE7FC] ;outvec                 ;*FA49: AD 9F E7 FC    '....'
        DECB                             ;*FA4D: 5A             'Z'
        BNE     ZFA47                    ;*FA4E: 26 F7          '&.'
        LBSR    ZF904                    ;*FA50: 17 FE B1       '...'
        LDB     #$07                     ;*FA53: C6 07          '..'
        BSR     ZFAA3                    ;*FA55: 8D 4C          '.L'
        LBSR    ZF902                    ;*FA57: 17 FE A8       '...'
        LBSR    ZF904                    ;*FA5A: 17 FE A7       '...'
        LDB     #$08                     ;*FA5D: C6 08          '..'
        BSR     ZFAA3                    ;*FA5F: 8D 42          '.B'
        SUBA    #$01                     ;*FA61: 80 01          '..'
        LDB     #$0A                     ;*FA63: C6 0A          '..'
        MUL                              ;*FA65: 3D             '='
        EXG     A,B                      ;*FA66: 1E 89          '..'
        LEAX    MFD66,PCR                ;*FA68: 30 8D 02 FA    '0...'
        LEAX    A,X                      ;*FA6C: 30 86          '0.'
        LDB     ,X+                      ;*FA6E: E6 80          '..'
ZFA70   LDA     ,X+                      ;*FA70: A6 80          '..'
        JSR     [ZE7FC]  ; outvec                ;*FA72: AD 9F E7 FC    '....'
        DECB                             ;*FA76: 5A             'Z'
        BNE     ZFA70                    ;*FA77: 26 F7          '&.'
        LBSR    ZF904                    ;*FA79: 17 FE 88       '...'
        LDA     #$19                     ;*FA7C: 86 19          '..'
        LBSR    ZF902                    ;*FA7E: 17 FE 81       '...'
        LDB     #$09                     ;*FA81: C6 09          '..'
        BSR     ZFAA3                    ;*FA83: 8D 1E          '..'
        LBSR    ZF902                    ;*FA85: 17 FE 7A       '..z'
        LBSR    ZF904                    ;*FA88: 17 FE 79       '..y'
        PULS    PC,X,D                   ;*FA8B: 35 96          '5.'
ZFA8D   PSHS D                             ;*FA8D: 34 06          '4.'
        LDB     #$0A                     ;*FA8F: C6 0A          '..'
ZFA91   STB     MD000                    ;*FA91: F7 D0 00       '...'
        LDA     MD001                    ;*FA94: B6 D0 01       '...'
        BPL     ZFA91                    ;*FA97: 2A F8          '*.'
ZFA99   STB     MD000                    ;*FA99: F7 D0 00       '...'
        LDA     MD001                    ;*FA9C: B6 D0 01       '...'
        BMI     ZFA99                    ;*FA9F: 2B F8          '+.'
        PULS    PC,D                     ;*FAA1: 35 86          '5.'
ZFAA3   STB     MD000                    ;*FAA3: F7 D0 00       '...'
        LDA     MD001                    ;*FAA6: B6 D0 01       '...'
        RTS                              ;*FAA9: 39             '9'
ZFAAA   STB     MD000                    ;*FAAA: F7 D0 00       '...'
        STA     MD001                    ;*FAAD: B7 D0 01       '...'
        RTS                              ;*FAB0: 39             '9'
ZFAB1   PSHS    X,D                      ;*FAB1: 34 16          '4.'
        LDA     #$06                     ;*FAB3: 86 06          '..'
        LDB     #$0A                     ;*FAB5: C6 0A          '..'
        BSR     ZFAAA                    ;*FAB7: 8D F1          '..'
        LDA     #$2B                     ;*FAB9: 86 2B          '.+'
        LDB     #$0B                     ;*FABB: C6 0B          '..'
        BSR     ZFAAA                    ;*FABD: 8D EB          '..'
        LDB     #$0C                     ;*FABF: C6 0C          '..'
        BSR     ZFAA3                    ;*FAC1: 8D E0          '..'
        LDB     #$0D                     ;*FAC3: C6 0D          '..'
        BSR     ZFAA3                    ;*FAC5: 8D DC          '..'
        BMI     ZFAC9                    ;*FAC7: 2B 00          '+.'
ZFAC9   LEAX    <MFAD3               ;*FAC9: 30 8C 07       '0..'
        STX     ZE7F4                    ;*FACC: BF E7 F4       '...'
        CLI                              ;*FACF: 1C EF          '..'
        PULS    PC,X,D                   ;*FAD1: 35 96          '5.'
MFAD3   LDB     #$0C                     ;*FAD3: C6 0C          '..'
        BSR     ZFAA3                    ;*FAD5: 8D CC          '..'
        RTI                              ;*FAD7: 3B             ';'

*****************************************************
** 	S-REC   LOADER                              *
*****************************************************
        ORG     $FB00 

ZFB00   BRA     ZFB04                    ;*FB00: 20 02          ' .'
ZFB02   BRA     ZFB7A                    ;*FB02: 20 76          ' v'
ZFB04   PSHS    Y,X                      ;*FB04: 34 30          '40'
        LDY     ZE7FE       ;invec             ;*FB06: 10 BE E7 FE    '....'
        LEAX    MF802,PCR                ;*FB0A: 30 8D FC F4    '0...'
        STX     ZE7FE                    ;*FB0E: BF E7 FE       '...'
        BSR     ZFB19                    ;*FB11: 8D 06          '..'
        STY     ZE7FE                    ;*FB13: 10 BF E7 FE    '....'
        PULS    PC,Y,X                   ;*FB17: 35 B0          '5.'
ZFB19   PSHS    Y,X,D                    ;*FB19: 34 36          '46'
ZFB1B   BSR     ZFB92                    ;*FB1B: 8D 75          '.u'
        CMPA    #$53                     ;*FB1D: 81 53          '.S'
        BNE     ZFB1B                    ;*FB1F: 26 FA          '&.'
        BSR     ZFB92                    ;*FB21: 8D 6F          '.o'
        CMPA    #$31                     ;*FB23: 81 31          '.1'
        BEQ     ZFB2D                    ;*FB25: 27 06          ''.'
        CMPA    #$39                     ;*FB27: 81 39          '.9'
        BNE     ZFB1B                    ;*FB29: 26 F0          '&.'
        BRA     ZFB5D                    ;*FB2B: 20 30          ' 0'
ZFB2D   LDA     #$01                     ;*FB2D: 86 01          '..'
        STA     ME7ED                    ;*FB2F: B7 E7 ED       '...'
        BSR     ZFB5F                    ;*FB32: 8D 2B          '.+'
        SUBA    #$03                     ;*FB34: 80 03          '..'
        PSHS A                             ;*FB36: 34 02          '4.'
        BSR     ZFB5F                    ;*FB38: 8D 25          '.%'
        TFR     A,B                      ;*FB3A: 1F 89          '..'
        BSR     ZFB5F                    ;*FB3C: 8D 21          '.!'
        EXG     A,B                      ;*FB3E: 1E 89          '..'
        TFR     D,X                      ;*FB40: 1F 01          '..'
        PULS A                             ;*FB42: 35 02          '5.'
        LEAY    A,X                      ;*FB44: 31 86          '1.'
ZFB46   BSR     ZFB5F                    ;*FB46: 8D 17          '..'
        STA     ,X+                      ;*FB48: A7 80          '..'
        PSHS Y                             ;*FB4A: 34 20          '4 '
        CMPX    ,S++                     ;*FB4C: AC E1          '..'
        BNE     ZFB46                    ;*FB4E: 26 F6          '&.'
        BSR     ZFB5F                    ;*FB50: 8D 0D          '..'
        LDA     ME7ED                    ;*FB52: B6 E7 ED       '...'
        BEQ     ZFB5B                    ;*FB55: 27 04          ''.'
        LBSR    ZFC00                    ;*FB57: 17 00 A6       '...'
        SWI                              ;*FB5A: 3F             '?'
ZFB5B   BRA     ZFB1B                    ;*FB5B: 20 BE          ' .'
ZFB5D   PULS    PC,Y,X,D                 ;*FB5D: 35 B6          '5.'
ZFB5F   BSR     ZFB92                    ;*FB5F: 8D 31          '.1'
        BSR     ZFB7A                    ;*FB61: 8D 17          '..'
        ASLA                             ;*FB63: 48             'H'
        ASLA                             ;*FB64: 48             'H'
        ASLA                             ;*FB65: 48             'H'
        ASLA                             ;*FB66: 48             'H'
        PSHS A                             ;*FB67: 34 02          '4.'
        BSR     ZFB92                    ;*FB69: 8D 27          '.''
        BSR     ZFB7A                    ;*FB6B: 8D 0D          '..'
        ADDA    ,S+                      ;*FB6D: AB E0          '..'
        PSHS A                             ;*FB6F: 34 02          '4.'
        ADDA    ME7ED                    ;*FB71: BB E7 ED       '...'
        STA     ME7ED                    ;*FB74: B7 E7 ED       '...'
        PULS A                             ;*FB77: 35 02          '5.'
        RTS                              ;*FB79: 39             '9'
ZFB7A   CMPA    #$30                     ;*FB7A: 81 30          '.0'
        BCS     ZFB8F                    ;*FB7C: 25 11          '%.'
        CMPA    #$3A                     ;*FB7E: 81 3A          '.:'
        BCS     ZFB8C                    ;*FB80: 25 0A          '%.'
        CMPA    #$41                     ;*FB82: 81 41          '.A'
        BCS     ZFB8F                    ;*FB84: 25 09          '%.'
        CMPA    #$47                     ;*FB86: 81 47          '.G'
        BCC     ZFB8F                    ;*FB88: 24 05          '$.'
        SUBA    #$07                     ;*FB8A: 80 07          '..'
ZFB8C   ANDA    #$0F                     ;*FB8C: 84 0F          '..'
        RTS                              ;*FB8E: 39             '9'
ZFB8F   LDA     #$80                     ;*FB8F: 86 80          '..'
        RTS                              ;*FB91: 39             '9'
ZFB92   JMP     [ZE7FE]                  ;*FB92: 6E 9F E7 FE    'n...'

*****************************************************
** 	6522 VIA KEYBOARD                           *
*****************************************************
        ORG     $FC00 

ZFC00   PSHS X                             ;*FC00: 34 10          '4.'
        LEAX    <ZFC30               ;*FC02: 30 8C 2B       '0.+'
        STX     ZE7FE                    ;*FC05: BF E7 FE       '...'
        LEAX    <MFC10               ;*FC08: 30 8C 05       '0..'
        STX     ME7FA                    ;*FC0B: BF E7 FA       '...'
        PULS    PC,X                     ;*FC0E: 35 90          '5.'
MFC10   LDB     #$0F                     ;*FC10: C6 0F          '..'
        BSR     ZFC27                    ;*FC12: 8D 13          '..'
        BNE     ZFC1C                    ;*FC14: 26 06          '&.'
        BSR     ZFC30                    ;*FC16: 8D 18          '..'
        CMPA    #$20                     ;*FC18: 81 20          '. '
        BNE     ZFC1D                    ;*FC1A: 26 01          '&.'
ZFC1C   CLRA                             ;*FC1C: 4F             'O'
ZFC1D   RTS                              ;*FC1D: 39             '9'
ZFC1E   STB     M8000                    ;*FC1E: F7 80 00       '...'
        LDA     M8000                    ;*FC21: B6 80 00       '...'
        ANDA    #$10                     ;*FC24: 84 10          '..'
        RTS                              ;*FC26: 39             '9'
ZFC27   STB     M8000                    ;*FC27: F7 80 00       '...'
        LDB     M8000                    ;*FC2A: F6 80 00       '...'
        ANDB    #$10                     ;*FC2D: C4 10          '..'
        RTS                              ;*FC2F: 39             '9'
ZFC30   PSHS    Y,X,D                    ;*FC30: 34 36          '46'
        LDA     #$EF                     ;*FC32: 86 EF          '..'
        STA     M8002                    ;*FC34: B7 80 02       '...'
        LDY     #M0400                   ;*FC37: 10 8E 04 00    '....'
        BRA     ZFC41                    ;*FC3B: 20 04          ' .'
ZFC3D   CLRA                             ;*FC3D: 4F             'O'
        STA     ME7EC                    ;*FC3E: B7 E7 EC       '...'
ZFC41   LDB     #$0D                     ;*FC41: C6 0D          '..'
ZFC43   DECB                             ;*FC43: 5A             'Z'
        BMI     ZFC3D                    ;*FC44: 2B F7          '+.'
        BSR     ZFC1E                    ;*FC46: 8D D6          '..'
        BEQ     ZFC43                    ;*FC48: 27 F9          ''.'
        STB     ,S                       ;*FC4A: E7 E4          '..'
ZFC4C   DECB                             ;*FC4C: 5A             'Z'
        BMI     ZFC3D                    ;*FC4D: 2B EE          '+.'
        BSR     ZFC1E                    ;*FC4F: 8D CD          '..'
        BEQ     ZFC4C                    ;*FC51: 27 F9          ''.'
        TFR     B,A                      ;*FC53: 1F 98          '..'
        ASLA                             ;*FC55: 48             'H'
        ASLA                             ;*FC56: 48             'H'
        ASLA                             ;*FC57: 48             'H'
        ASLA                             ;*FC58: 48             'H'
        ADDA    ,S                       ;*FC59: AB E4          '..'
        STA     ,S                       ;*FC5B: A7 E4          '..'
ZFC5D   DECB                             ;*FC5D: 5A             'Z'
        BMI     ZFC66                    ;*FC5E: 2B 06          '+.'
        BSR     ZFC1E                    ;*FC60: 8D BC          '..'
        BNE     ZFC3D                    ;*FC62: 26 D9          '&.'
        BEQ     ZFC5D                    ;*FC64: 27 F7          ''.'
ZFC66   LDA     ,S                       ;*FC66: A6 E4          '..'
        LEAX    <MFC9C               ;*FC68: 30 8C 31       '0.1'
        LDA     A,X                      ;*FC6B: A6 86          '..'
        STA     ,S                       ;*FC6D: A7 E4          '..'
        LDB     #$0D                     ;*FC6F: C6 0D          '..'
        BSR     ZFC27                    ;*FC71: 8D B4          '..'
        BNE     ZFC79                    ;*FC73: 26 04          '&.'
        EORA    #$10                     ;*FC75: 88 10          '..'
        STA     ,S                       ;*FC77: A7 E4          '..'
ZFC79   LDB     #$0E                     ;*FC79: C6 0E          '..'
        BSR     ZFC27                    ;*FC7B: 8D AA          '..'
        BNE     ZFC83                    ;*FC7D: 26 04          '&.'
        ANDA    #$1F                     ;*FC7F: 84 1F          '..'
        STA     ,S                       ;*FC81: A7 E4          '..'
ZFC83   TST     ME7EC                    ;*FC83: 7D E7 EC       '}..'
        BEQ     ZFC95                    ;*FC86: 27 0D          ''.'
        CMPA    ME7EC                    ;*FC88: B1 E7 EC       '...'
        BNE     ZFC8F                    ;*FC8B: 26 02          '&.'
        LEAY    -$07,Y                   ;*FC8D: 31 39          '19'
ZFC8F   DEY                              ;*FC8F: 31 3F          '1?'
        BNE     ZFC41                    ;*FC91: 26 AE          '&.'
        BRA     ZFC97                    ;*FC93: 20 02          ' .'
ZFC95   LDA     #$FF                     ;*FC95: 86 FF          '..'
ZFC97   STA     ME7EC                    ;*FC97: B7 E7 EC       '...'
        PULS    PC,Y,X,D                 ;*FC9A: 35 B6          '5.'

* 	Keyboard translation tables
MFC9C   FCB     $FF,$FF                  ;*FC9C: FF FF          '..'
        FCC     "SQFDHGKJL"              ;*FC9E: 53 51 46 44 48 47 4B 4A 4C 'SQFDHGKJL'
        FCB     $FF,$FF,$FF,$FF,$FF,$FF  ;*FCA7: FF FF FF FF FF FF '......'
        FCB     $FF                      ;*FCAD: FF             '.'
        FCC     "XWVCNB,M./"             ;*FCAE: 58 57 56 43 4E 42 2C 4D 2E 2F 'XWVCNB,M./'
        FCB     $FF,$FF,$FF,$FF,$FF,$FF  ;*FCB8: FF FF FF FF FF FF '......'
        FCB     $FF                      ;*FCBE: FF             '.'
        FCC     "ARE<"                   ;*FCBF: 41 52 45 3C    'ARE<'
        FCB     $0D,$FF                  ;*FCC3: 0D FF          '..'
        FCC     "\"                      ;*FCC5: 5C             '\'
        FCB     $FF,$1B,$FF,$FF,$FF,$FF  ;*FCC6: FF 1B FF FF FF FF '......'
        FCB     $FF,$FF,$FF,$FF          ;*FCCC: FF FF FF FF    '....'
        FCC     "YZUTOIP"                ;*FCD0: 59 5A 55 54 4F 49 50 'YZUTOIP'
        FCB     $0A,$FF,$FF,$FF,$FF,$FF  ;*FCD7: 0A FF FF FF FF FF '......'
        FCB     $FF,$FF,$FF,$FF          ;*FCDD: FF FF FF FF    '....'
        FCC     "421"                    ;*FCE1: 34 32 31       '421'
        FCB     $FF                      ;*FCE4: FF             '.'
        FCC     "3;"                     ;*FCE5: 33 3B          '3;'
        FCB     $FF,$FF,$FF,$FF,$FF,$FF  ;*FCE7: FF FF FF FF FF FF '......'
        FCB     $FF,$FF,$FF,$FF,$FF      ;*FCED: FF FF FF FF FF '.....'
        FCC     "658790"                 ;*FCF2: 36 35 38 37 39 30 '658790'
        FCB     $FF,$FF,$FF,$FF,$FF,$FF  ;*FCF8: FF FF FF FF FF FF '......'
        FCB     $FF,$FF,$FF,$FF,$FF,$FF  ;*FCFE: FF FF FF FF FF FF '......'
        FCC     "^ "                     ;*FD04: 5E 20          '^ '
        FCB     $FF                      ;*FD06: FF             '.'
        FCC     "@"                      ;*FD07: 40             '@'
        FCB     $FF,$FF,$FF,$FF,$FF,$FF  ;*FD08: FF FF FF FF FF FF '......'
        FCB     $FF,$FF,$FF,$FF,$FF,$FF  ;*FD0E: FF FF FF FF FF FF '......'
        FCB     $FF,$0E                  ;*FD14: FF 0E          '..'
        FCC     ":-"                     ;*FD16: 3A 2D          ':-'

*	Days
MFD20   FCB     $06                      ;*FD20: 06             '.'
        FCC     "Sunday   "              ;*FD21: 53 75 6E 64 61 79 20 20 20 'Sunday   '
        FCB     $06                      ;*FD2A: 06             '.'
        FCC     "Monday   "              ;*FD2B: 4D 6F 6E 64 61 79 20 20 20 'Monday   '
        FCB     $07                      ;*FD34: 07             '.'
        FCC     "Tuesday  "              ;*FD35: 54 75 65 73 64 61 79 20 20 'Tuesday  '
        FCB     $09                      ;*FD3E: 09             '.'
        FCC     "Wednesday"              ;*FD3F: 57 65 64 6E 65 73 64 61 79 'Wednesday'
        FCB     $08                      ;*FD48: 08             '.'
        FCC     "Thursday "              ;*FD49: 54 68 75 72 73 64 61 79 20 'Thursday '
        FCB     $06                      ;*FD52: 06             '.'
        FCC     "Friday   "              ;*FD53: 46 72 69 64 61 79 20 20 20 'Friday   '
        FCB     $08                      ;*FD5C: 08             '.'
        FCC     "Saturday "              ;*FD5D: 53 61 74 75 72 64 61 79 20 'Saturday '

*	Months
MFD66   FCB     $07                      ;*FD66: 07             '.'
        FCC     "January  "              ;*FD67: 4A 61 6E 75 61 72 79 20 20 'January  '
        FCB     $08                      ;*FD70: 08             '.'
        FCC     "February "              ;*FD71: 46 65 62 72 75 61 72 79 20 'February '
        FCB     $05                      ;*FD7A: 05             '.'
        FCC     "March    "              ;*FD7B: 4D 61 72 63 68 20 20 20 20 'March    '
        FCB     $05                      ;*FD84: 05             '.'
        FCC     "April    "              ;*FD85: 41 70 72 69 6C 20 20 20 20 'April    '
        FCB     $03                      ;*FD8E: 03             '.'
        FCC     "May      "              ;*FD8F: 4D 61 79 20 20 20 20 20 20 'May      '
        FCB     $04                      ;*FD98: 04             '.'
        FCC     "June     "              ;*FD99: 4A 75 6E 65 20 20 20 20 20 'June     '
        FCB     $04                      ;*FDA2: 04             '.'
        FCC     "July     "              ;*FDA3: 4A 75 6C 79 20 20 20 20 20 'July     '
        FCB     $06                      ;*FDAC: 06             '.'
        FCC     "August   "              ;*FDAD: 41 75 67 75 73 74 20 20 20 'August   '
        FCB     $09                      ;*FDB6: 09             '.'
        FCC     "September"              ;*FDB7: 53 65 70 74 65 6D 62 65 72 'September'
        FCB     $07                      ;*FDC0: 07             '.'
        FCC     "October  "              ;*FDC1: 4F 63 74 6F 62 65 72 20 20 'October  '
        FCB     $08                      ;*FDCA: 08             '.'
        FCC     "November "              ;*FDCB: 4E 6F 76 65 6D 62 65 72 20 'November '
        FCB     $08                      ;*FDD4: 08             '.'
        FCC     "December "              ;*FDD5: 44 65 63 65 6D 62 65 72 20 'December '

; extra lcd data
LCT3
	fcb	7 
	fcb	$30, $30, $06 
	fcb	$0e, $01, $07, $a8 

LCT4    FCB     24                      ;*FDE6: 18             '.'
	fcc	" 6809"  
	fcc	" Monitor"  
	FCC	" v1.2" 
	FCC	" 2024 " 


*****************************************************
* 	memory modify                               *
*****************************************************
	ORG	$FE00 

ZFE00   LBRA    ZFE09 ; modify                   ;*FE00: 16 00 06       '...'
ZFE03   LBRA    ZFE90 ; a to hex                  ;*FE03: 16 00 8A       '...'
        LBRA    ZFE7E ;                   ;*FE06: 16 00 75       '..u'

ZFE09   LDA     #$2E     ; .                ;*FE09: 86 2E          '..'
        PSHS A                             ;*FE0B: 34 02          '4.'
ZFE0D   LDA     #$0D    ; cr                 ;*FE0D: 86 0D          '..'
        JSR     [ZE7FC] ; outvec                 ;*FE0F: AD 9F E7 FC    '....'
        LDA     #$0A    ; lf                 ;*FE13: 86 0A          '..'
        JSR     [ZE7FC] ; outvec                 ;*FE15: AD 9F E7 FC    '....'
        LBSR    ZF904   ; op spc                ;*FE19: 17 FA E8       '...'
        LBSR    ZF900   ; op xxxx                 ;*FE1C: 17 FA E1       '...'
        LBSR    ZF904   ; op spc                 ;*FE1F: 17 FA E2       '...'
        LDA     ,X                       ;*FE22: A6 84          '..'
        LBSR    ZF902   ; op aa                 ;*FE24: 17 FA DB       '...'
        LBSR    ZF904   ; op spc                 ;*FE27: 17 FA DA       '...'
        LDA     ,X                       ;*FE2A: A6 84          '..'
        JSR     [ZE7FC] ; op chr                 ;*FE2C: AD 9F E7 FC    '....'
        JSR     [ZE7FE] ; getch                 ;*FE30: AD 9F E7 FE    '....'
        CMPA    #$58    ; X = exit                ;*FE34: 81 58          '.X'
        BEQ     ZFE5F   ; exit                 ;*FE36: 27 27          ''''
        CMPA    #$47    ; G = go                ;*FE38: 81 47          '.G'
        BEQ     ZFE7C   ; go                 ;*FE3A: 27 40          ''@'
        CMPA    #$2E    ; . = address                ;*FE3C: 81 2E          '..'
        BNE     ZFE42   ;                 ;*FE3E: 26 02          '&.'
        STA     ,S                       ;*FE40: A7 E4          '..'
ZFE42   CMPA    #$2F    ; / = data                ;*FE42: 81 2F          './'
        BNE     ZFE48                    ;*FE44: 26 02          '&.'
        STA     ,S                       ;*FE46: A7 E4          '..'
ZFE48   CMPA    #$0D    ; \n = inc addr                ;*FE48: 81 0D          '..'
        BEQ     ZFE62                    ;*FE4A: 27 16          ''.'
        CMPA    #$0A    ; \r = dec addr                ;*FE4C: 81 0A          '..'
        BEQ     ZFE66                    ;*FE4E: 27 16          ''.'
        LBSR    ZFB02   ; a to hex                 ;*FE50: 17 FC AF       '...'
        BMI     ZFE0D                    ;*FE53: 2B B8          '+.'
        LDB     ,S                       ;*FE55: E6 E4          '..'
        CMPB    #$2F    ; / = data                ;*FE57: C1 2F          './'
        BEQ     ZFE6A                    ;*FE59: 27 0F          ''.'
        CMPB    #$2E    ; . = address                ;*FE5B: C1 2E          '..'
        BEQ     ZFE78                    ;*FE5D: 27 19          ''.'
ZFE5F   PULS B                             ;*FE5F: 35 04          '5.'
        RTS                              ;*FE61: 39             '9'

ZFE62   INX                              ;*FE62: 30 01          '0.'
        BRA     ZFE0D                    ;*FE64: 20 A7          ' .'
ZFE66   DEX                              ;*FE66: 30 1F          '0.'
        BRA     ZFE0D                    ;*FE68: 20 A3          ' .'
ZFE6A   LDB     ,X       ; data                   ;*FE6A: E6 84          '..'
        ASLB                             ;*FE6C: 58             'X'
        ASLB                             ;*FE6D: 58             'X'
        ASLB                             ;*FE6E: 58             'X'
        ASLB                             ;*FE6F: 58             'X'
        ;ABA                              ;*FE70: 34 04 AB E0    '4...'
        PSHS B; 
        ADDA ,S +
        STA     ,X                       ;*FE74: A7 84          '..'
        BRA     ZFE0D                    ;*FE76: 20 95          ' .'
ZFE78   BSR     ZFE7E                    ;*FE78: 8D 04          '..'
        BRA     ZFE0D                    ;*FE7A: 20 91          ' .'
ZFE7C   JMP     ,X                       ;*FE7C: 6E 84          'n.'

ZFE7E   PSHS A           ; addr                           ;*FE7E: 34 02          '4.'
        TFR     X,D                      ;*FE80: 1F 10          '..'
        ASLA ;ASLD                             ;*FE82: 58 49          'XI'
        ROLA ;
        ASLA ;ASLD                             ;*FE84: 58 49          'XI'
        ROLA ;
        ASLA ;ASLD                             ;*FE86: 58 49          'XI'
        ROLA ;
        ASLA ;ASLD                             ;*FE88: 58 49          'XI'
        ROLA ;
        TFR     D,X                      ;*FE8A: 1F 01          '..'
        PULS B                             ;*FE8C: 35 04          '5.'
        ABX                              ;*FE8E: 3A             ':'
ZFE8F   RTS                              ;*FE8F: 39             '9'

ZFE90   LBSR    ZF906    ;                ;*FE90: 17 FA 73       '..s'
        LBSR    ZF904    ; op spc                ;*FE93: 17 FA 6E       '..n'
        LBSR    ZF900    ; op xxxx               ;*FE96: 17 FA 67       '..g'
ZFE99   JSR     [ZE7FE]  ; getch                ;*FE99: AD 9F E7 FE    '....'
        CMPA    #$58     ; X = exit                 ;*FE9D: 81 58          '.X'
        BEQ     ZFE8F                    ;*FE9F: 27 EE          ''.'
        CMPA    #$0D     ; \n                ;*FEA1: 81 0D          '..'
        BEQ     ZFEAE                    ;*FEA3: 27 09          ''.'
        LBSR    ZFB02                    ;*FEA5: 17 FC 5A       '..Z'
        BMI     ZFE99                    ;*FEA8: 2B EF          '+.'
        BSR     ZFE7E                    ;*FEAA: 8D D2          '..'
        BRA     ZFE90                    ;*FEAC: 20 E2          ' .'

ZFEAE   LDY     M00F8                    ;*FEAE: 10 9E F8       '...'
        STX     $0A,Y                    ;*FEB1: AF 2A          '.*'
        LDA     #$80                     ;*FEB3: 86 80          '..'
        ORA     ,Y                       ;*FEB5: AA A4          '..'
        STA     ,Y                       ;*FEB7: A7 A4          '..'
        LDS     M00F8                    ;*FEB9: 10 DE F8       '...'
        RTI                              ;*FEBC: 3B             ';'

*****************************************************
* 	Reset monitor                               *
*****************************************************
        ORG     $FF00 

rRST 	LDS     #ME7B0                   ;*FF00: 10 CE E7 B0    '....'
        STS     ME7F8      ; stack              ;*FF04: 10 FF E7 F8    '....'
        LEAX    <MFF20 ; nmi              ;*FF08: 30 8C 15       '0..'
        STX     ZE7F2                    ;*FF0B: BF E7 F2       '...'
        LEAX    <MFF81 ; swi              ;*FF0E: 30 8C 70       '0.p'
        STX     ZE7F6                    ;*FF11: BF E7 F6       '...'
        LBSR    ZF908      ; lc init              ;*FF14: 17 F9 F1       '...'
        LBSR    ZF90A      ; lc svec              ;*FF17: 17 F9 F0       '...'
        LBSR    ZFC00      ; kb svec              ;*FF1A: 17 FC E3       '...'
        LBSR    ZF800      ; acia init              ;*FF1D: 17 F8 E0       '...'
MFF20   STS     ME7F8 ; nmi                   ;*FF20: 10 FF E7 F8    '....'
        LDS     #ME7B0     ; monitor stack              ;*FF24: 10 CE E7 B0    '....'
        LDA     #MDIPG     ; monitor page                ;*FF28: 86 E7          '..'
        TFR     A,DP                     ;*FF2A: 1F 8B          '..'
ZFF2C   JSR     [ZE7FE] ; getch                 ;*FF2C: AD 9F E7 FE    '....'
        LDX     M00F8                    ;*FF30: 9E F8          '..'
        LEAX    $0A,X                    ;*FF32: 30 0A          '0.'
        CMPA    #$4D ; M   =  modify               ;*FF34: 81 4D          '.M'
        LBNE    ZFF3F                    ;*FF36: 10 26 00 05    '.&..'
        LBSR    ZFE00                    ;*FF3A: 17 FE C3       '...'
        BRA     ZFF2C                    ;*FF3D: 20 ED          ' .'
ZFF3F   CMPA    #$47  ; G  = go?                ;*FF3F: 81 47          '.G'
        BNE     ZFF48                    ;*FF41: 26 05          '&.'
        LBSR    ZFE03                    ;*FF43: 17 FE BD       '...'
        BRA     ZFF2C                    ;*FF46: 20 E4          ' .'
ZFF48   CMPA    #$52  ; R  = register                ;*FF48: 81 52          '.R'
        LBEQ    ZFF8C                    ;*FF4A: 10 27 00 3E    '.'.>'
        CMPA    #$4E  ; N  = continue               ;*FF4E: 81 4E          '.N'
        LBEQ    ZFF7D                    ;*FF50: 10 27 00 29    '.'.)'
        CMPA    #$4C  ; L  = load                ;*FF54: 81 4C          '.L'
        LBEQ    ZFB00                    ;*FF56: 10 27 FB A6    '.'..'
        CMPA    #$43  ; C  = cold                ;*FF5A: 81 43          '.C'
        LBEQ    Z0142                    ;*FF5C: 10 27 01 E2    '.'..'
        CMPA    #$57  ; W  = warm               ;*FF60: 81 57          '.W'
        LBEQ    Z0194                    ;*FF62: 10 27 02 2E    '.'..'
        CMPA    #$54  ; T  = time               ;*FF66: 81 54          '.T'
        BNE     ZFF70                    ;*FF68: 26 06          '&.'
        LBSR    ZFA00  ; clk init                  ;*FF6A: 17 FA 93       '...'
        LBSR    ZFA03  ; clk time                  ;*FF6D: 17 FA 93       '...'
ZFF70   CMPA    #$42  ; B  =                 ;*FF70: 81 42          '.B'
        NOP                              ;*FF72: 12             '.'
        CMPA    #$55  ; U  =                 ;*FF73: 81 55          '.U'
        BNE    ZFF2C  ; monitor loop                  ;*FF75: 10 26 FF B3    '.&..'
	      nop          ;
	      nop          ;y
        JMP     [ZE7E5] ; swi3                 ;*FF79: 6E 9F E7 E5    'n...'
ZFF7D   LDS     M00F8  ; continue                  ;*FF7D: 10 DE F8       '...'
        RTI                              ;*FF80: 3B             ';'
MFF81   LDA     #MDIPG  ; swi                  ;*FF81: 86 E7          '..'
        TFR     A,DP                     ;*FF83: 1F 8B          '..'
        STS     M00F8                    ;*FF85: 10 DF F8       '...'
        LDS     #ME7D0                   ;*FF88: 10 CE E7 D0    '....'
ZFF8C   LDX     M00F8  ; register                  ;*FF8C: 9E F8          '..'
        CLRB                             ;*FF8E: 5F             '_'
ZFF8F   LBSR    ZF904  ; op.spc                  ;*FF8F: 17 F9 72       '..r'
        CMPB    #$08                     ;*FF92: C1 08          '..'
        BNE     ZFF99                    ;*FF94: 26 03          '&.'
        LDX     #ME7F8 ; regs on stack                  ;*FF96: 8E E7 F8       '...'
ZFF99   CMPB    #$03                     ;*FF99: C1 03          '..'
        BLS     ZFFA2                    ;*FF9B: 23 05          '#.'
        LDA     ,X+                      ;*FF9D: A6 80          '..'
        LBSR    ZF902  ; op.aa                  ;*FF9F: 17 F9 60       '..`'
ZFFA2   LDA     ,X+                      ;*FFA2: A6 80          '..'
        LBSR    ZF902  ; op.aa                  ;*FFA4: 17 F9 5B       '..['
        INCB                             ;*FFA7: 5C             '\'
        CMPB    #$09                     ;*FFA8: C1 09          '..'
        BNE     ZFF8F                    ;*FFAA: 26 E3          '&.'
        LBRA    ZFF2C  ; monitor loop                  ;*FFAC: 16 FF 7D       '..}'

*	vectors redirected through ram
        ORG     $FFD0 
rSWI3 	JMP     [ZE7E5]                  ;*FFD0: 6E 9F E7 E5    'n...'
rSWI2 	JMP     [ZE7E7]                  ;*FFD4: 6E 9F E7 E7    'n...'
rFIRQ 	JMP     [ZE7E9]                  ;*FFD8: 6E 9F E7 E9    'n...'
rIRQ 	JMP     [ZE7F4]                  ;*FFDC: 6E 9F E7 F4    'n...'
rSWI 	JMP     [ZE7F6]                  ;*FFE0: 6E 9F E7 F6    'n...'
rNMI 	JMP     [ZE7F2]                  ;*FFE4: 6E 9F E7 F2    'n...'

*	reset and interrupt vectors
        ORG     $FFF2 
	FCW	rSWI3	$FFD0	;rswi3 
	FCW	rSWI2	$FFD4 	;rswi2
	FCW	rFIRQ	$FFD8 	;rfirq
	FCW	rIRQ	$FFDC 	;rirq
	FCW	rSWI	$FFE0 	;rswi
	FCW	rNMI	$FFE4 	;rnmi
	FCW	rRST	$FF00 	;reset


        END 
