extern void nap20(void);
extern void ch375_rblock(uint8_t *ptr);
extern void ch375_wblock(uint8_t *ptr);
extern int ch375_xfer(uint_fast8_t dev, bool is_read, uint32_t lba, uint8_t *dptr);
extern uint_fast8_t ch375_probe(void);

#define ch375_dport (*( unsigned char *) 0xC0D8)
#define ch375_sport (*( unsigned char *) 0xC0D9)

#define ch375_rdata()	ch375_dport
#define ch375_rstatus()	ch375_sport
#define ch375_wdata(x)	do {ch375_dport = (x); } while(0)
#define ch375_wcmd(x)	do {ch375_sport = (x); } while(0)


