// license:BSD-3-Clause
// copyright-holders:Frank Palazzolo

// MAME driver for DigicoolThing's 6809 Computer

#include "emu.h"

#include "cpu/m6809/m6809.h"
#include "machine/mos6551.h"
#include "machine/6522via.h"
#include "machine/input_merger.h"
#include "machine/mc146818.h"
#include "machine/6840ptm.h"
#include "machine/clock.h"
#include "bus/rs232/rs232.h"
#include "emupal.h"
#include "screen.h"
#include "video/hd44780.h"

namespace {

class djrm6809_state : public driver_device
{
public:
	djrm6809_state(const machine_config &mconfig, device_type type, const char *tag)
		: driver_device(mconfig, type, tag)
		, m_maincpu(*this, "maincpu")
		, m_acia(*this, "acia")
    , m_ptm(*this, "ptm")
		, m_lcdc(*this, "hd44780")
		, m_rtc(*this, "rtc")
	{ }

	void djrm6809(machine_config &config);

private:
	void djrm6809_mem(address_map &map);
	void djrm6809_palette(palette_device &palette) const;

	required_device<cpu_device> m_maincpu;
	required_device<mos6551_device> m_acia;
	required_device<ptm6840_device> m_ptm;
	required_device<hd44780_device> m_lcdc;
	required_device<mc146818_device> m_rtc;
};

/******************************************************************************
 Address Maps
******************************************************************************/

void djrm6809_state::djrm6809_mem(address_map &map)
{
	map(0x2000, 0x3fff).ram();
	map(0x0000, 0x1FFF).rom();
	map(0xe000, 0xe7ff).ram();
	map(0x8000, 0x800f).m("via", FUNC(via6522_device::map));
	map(0xc000, 0xc007).rw("ptm", FUNC(ptm6840_device::read), FUNC(ptm6840_device::write));
	map(0xE800, 0xffff).rom();
	map(0xC400, 0xC403).rw("acia", FUNC(mos6551_device::read), FUNC(mos6551_device::write));	
	map(0xC800, 0xC801).rw(m_lcdc, FUNC(hd44780_device::read), FUNC(hd44780_device::write));
	map(0xD000, 0xD000).w(m_rtc, FUNC(mc146818_device::address_w));  //  RTC 146818 - has battery backup
	map(0xD001, 0xD001).rw(m_rtc, FUNC(mc146818_device::data_r), FUNC(mc146818_device::data_w));
}

/******************************************************************************
 Input Ports
******************************************************************************/

// This is here only to configure our terminal for interactive use
static DEVICE_INPUT_DEFAULTS_START( terminal )
	DEVICE_INPUT_DEFAULTS( "RS232_RXBAUD", 0xff, RS232_BAUD_115200 )
	DEVICE_INPUT_DEFAULTS( "RS232_TXBAUD", 0xff, RS232_BAUD_115200 )
	DEVICE_INPUT_DEFAULTS( "RS232_DATABITS", 0xff, RS232_DATABITS_8 )
	DEVICE_INPUT_DEFAULTS( "RS232_PARITY", 0xff, RS232_PARITY_NONE )
	DEVICE_INPUT_DEFAULTS( "RS232_STOPBITS", 0xff, RS232_STOPBITS_1 )
DEVICE_INPUT_DEFAULTS_END

void djrm6809_state::djrm6809_palette(palette_device &palette) const
{
	palette.set_pen_color(0, rgb_t(138, 146, 148));
	palette.set_pen_color(1, rgb_t(92, 83, 88));
}

static const gfx_layout charlayout =
{
	5, 8,   /* 5 x 8 characters */
	256,    /* 256 characters */
	1,  /* 1 bits per pixel */
	{ 0 },  /* no bitplanes */
	{ 3, 4, 5, 6, 7},
	{ 0, 8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8},
	8*8 /* 8 bytes */
};

static GFXDECODE_START( gfx_djrm6809 )
	GFXDECODE_ENTRY( "hd44780:cgrom", 0x0000, charlayout, 0, 1 )
GFXDECODE_END

/******************************************************************************
 Machine Drivers
******************************************************************************/

void djrm6809_state::djrm6809(machine_config &config)
{
	/* basic machine hardware */
	MC6809(config, m_maincpu, XTAL(4'000'000));
	m_maincpu->set_addrmap(AS_PROGRAM, &djrm6809_state::djrm6809_mem);
	
	via6522_device &via(MOS6522(config, "via", XTAL(4'000'000) / 4));
	via.irq_handler().set("mainirq", FUNC(input_merger_device::in_w<0>));

	mos6551_device &acia(MOS6551(config, "acia", 0));
	acia.set_xtal(1.8432_MHz_XTAL);
	acia.irq_handler().set("mainirq", FUNC(input_merger_device::in_w<1>));

	acia.txd_handler().set("rs232", FUNC(rs232_port_device::write_txd));
	acia.rts_handler().set("rs232", FUNC(rs232_port_device::write_rts));

	rs232_port_device &rs232(RS232_PORT(config, "rs232", default_rs232_devices, "terminal"));

	rs232.rxd_handler().set("acia", FUNC(mos6551_device::write_rxd));
	rs232.dcd_handler().set("acia", FUNC(mos6551_device::write_dcd));
	rs232.dsr_handler().set("acia", FUNC(mos6551_device::write_dsr));
	rs232.cts_handler().set("acia", FUNC(mos6551_device::write_cts));
	rs232.set_option_device_input_defaults("terminal", DEVICE_INPUT_DEFAULTS_NAME(terminal)); // must be below the DEVICE_INPUT_DEFAULTS_START block
	
	PTM6840(config, m_ptm, 16_MHz_XTAL / 4);
	m_ptm->set_external_clocks(4000000.0/14.0, 4000000.0/14.0, (4000000.0/14.0)/8.0);
	m_ptm->irq_callback().set_inputline("maincpu", M6809_IRQ_LINE);

/* LCD hardware */
	PALETTE(config, "palette", FUNC(djrm6809_state::djrm6809_palette), 2);
	GFXDECODE(config, "gfxdecode", "palette", gfx_djrm6809);
	
	HD44780(config, m_lcdc, 270'000); // TODO: clock not measured, datasheet typical clock used
	m_lcdc->set_lcd_size(2, 40);

/* rtc */
	MC146818(config, m_rtc, 32.768_kHz_XTAL);
	//m_rtc->irq().set(FUNC(micronic_state::mc146818_irq));   Connects to common irq line used by below PIAs and UART

	/* video hardware */
	screen_device &screen(SCREEN(config, "screen", SCREEN_TYPE_LCD));
	screen.set_refresh_hz(50);
	screen.set_vblank_time(ATTOSECONDS_IN_USEC(2500)); /* not accurate */
	screen.set_screen_update("hd44780", FUNC(hd44780_device::screen_update));
	screen.set_size(240, 18);
	screen.set_visarea(0, 240-1, 0, 18-1);
	screen.set_palette("palette");
	
	input_merger_device &merger(INPUT_MERGER_ANY_HIGH(config, "mainirq"));
	merger.output_handler().set_inputline(m_maincpu, M6809_IRQ_LINE);


}

ROM_START(djrm6809)
	ROM_REGION(0x10000, "maincpu",0)
	ROM_LOAD("djrm6809mon.bin",   0xF800, 0x800, CRC(b8183a64) SHA1(886250eecb6638eb7a8e34652eeff7741bda6e4c))
	ROM_LOAD("2716a.bin",   0x1800, 0x800, CRC(bf80f02a) SHA1(ab34ad0f0ebad941ee86e13a24564312648b1c08)) // original dumped rom
	ROM_LOAD("2716b.bin",   0x1000, 0x800, CRC(5fccd332) SHA1(574462eedae76698b940d6f18556cc6c1931fb8f)) // original dumped rom
	ROM_LOAD("2716c.bin",   0x800,  0x800, CRC(48434a58) SHA1(4a78301c0e3841bf634153595efc18d912c3c3b3)) // original dumped rom
	ROM_LOAD("2716d.bin",   0x000,  0x800, CRC(a14c7450) SHA1(1ab543e99901243f6a7e57dd68b8cf98caebd4d7)) // original dumped rom
ROM_END

} // anonymous namespace


//    YEAR  NAME         PARENT    COMPAT  MACHINE   INPUT    CLASS         INIT           COMPANY           FULLNAME                FLAGS
COMP( 2024, djrm6809,      0,        0,      djrm6809,   0,       djrm6809_state, empty_init,    "DigicoolThings",   "djrm 6809 Combo",  MACHINE_NO_SOUND_HW )
