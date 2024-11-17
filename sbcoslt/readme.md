# SBC Lite

Cut-down SBC monitor

downloaded from here:http://forum.6502.org/viewtopic.php?p=26996

[readme.txt](./README.TXT)

Added ACIA2.asm for 6850 ACIA at $c008

Added PS2 Keyboard init into VIA1.asm at $c030

Write '6502' to DLR2416 LEDs at $c0f0-cof3

Built under DOSBox-X with build.bat

```
tass /c /lsbc.lbl sbc.asm sbc25.rom sbc25.lst
```

Binary image converted to s-records with commad:
```
srec_cat SBC25.ROM -binary -offset 0x1ffe -output SBC25.HEX -Intel -address-length=2
```