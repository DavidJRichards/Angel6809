# MECB djrm 6809

## Card devices addresses

### 6309 CPU @ 2MHz

|Device|Address range|
|------|-------------|
|Ram   |0000 to BFFF |
|I/O   |C000 to C0FF |
|Rom   |C100 to FFFF |

### 6809 CPU @ 1MHz

|Device|Address range|
|------|-------------|
|Ram   |0000 to BFFF |
|I/O   |C000 to C0FF |
|Rom   |C100 to FFFF |

### 6502 CPU @ 1MHz

|Device|Address range|
|------|-------------|
|Ram   |0000 to BFFF |
|I/O   |C000 to C0FF |
|Rom   |C100 to FFFF |

### MECB 1MB ROM Expansion

|Device|Banks    |Address         |
|------|---------|----------------|
|U2    |0 to 7   |0xC100 to 0xFFFF|
|U3    |8 to 15  |0xC100 to 0xFFFF|

### MECB TMS9918 Video

|Device |Address range|
|-------|-------------|
|TMS9918|0X80 TO 0X87 |

### MECB Motorola I/O Card

|Device|Address range|
|------|-------------|
|PTM   |0x00 to 0x07 |
|ACIA  |0X08 TO 0X0f |
|PIA   |0X10 TO 0X17 |

### Compact Flash Card

|Device|Address range|
|------|-------------|
|CF-IDE|0xC0 to 0xC7 |


### SYSTEM_IO

|Device|Address range|
|------|-------------|
|UART  |0x28 to 0x2F |
|VIA   |0x30 to 0x3F |
|RTC   |0x40 to 0x4F |

### MECB Prototype PLD #1

|Device      |Address range|
|------------|-------------|
|LCD HD44780 |0xE0 to ExE7 |
|ACIA 6551   |0xE8 to 0xEF |
|DLR2416 LEDS|0xF0 to 0xF7 |

### T6963 LCD & CH376 USB

|Device   |Address range|
|---------|-------------|
|T6939 LCD|0xD0 to 0xD7 |
|CH376 USB|0xD8 to 0xDF |
|Combo    |0xD0 to 0xDF |


### 1MB ROM Expansion

#### Loaded segments

|Slot| Name            | Start| Finish|Load image|
|----|-----------------|------|-------|----------|
| 0  | Assis09 + Disasm| 00000| 0ffff | 0E000    |
| 1  | Extended Basic  | 10000| 1ffff | 18000    |
| 2  | Z79 Forth/AI    | 20000| 2fFFF | 20000    |
| 3  | BBC Basic       | 30000| 3fFFF | 3c000    |

##### Notes

Default I/O @ 0xC000

 * 0 djrm combined Assis09 & Dissasembler & some BIOS tests
 * 1 Jeff Tranter Assist09 etc & Extended Basic @ 0xC100
 * 2 Z79 Forth, needs FIRQ for 6850 UART & Compact Flash
 * 3 BBC Basic needs I/O @ 0xA000



