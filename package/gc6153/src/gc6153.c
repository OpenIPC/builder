/*
 * gc6153: userspace i2c bitbang + GC6153F register tool
 * for Vstarcam C8622 (Ingenic T23), motor driver chip on GPIO53(SCL)/GPIO52(SDA)
 *
 * The GC6153 is a dual-channel 256-microstep stepper driver plus one DC
 * channel (the ircut coil), with a dual SPI/I2C interface; this board wires
 * it in i2c mode at 7-bit 0x10. Datasheet summary:
 * https://damodev.csdn.net/6823f4b5a5baf817cf4b3f9c.html
 * (Not to be confused with the Toll Micro TMI8150/B, an SPI-only chip in the
 * same QFN-20 footprint.)
 *
 * GPIO model: Ingenic T23 (port regs at 0x10010000 + port*0x1000,
 * shadow func regs at +0x7000, data via PXPAT0 S/C).
 *
 * i2c open-drain: "1" = pin as input (external/internal pull-up),
 * "0" = pin as output driving low.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <time.h>
#include <sys/time.h>

/* i2c-dev uapi (avoid header dependency) */
#define I2C_SLAVE      0x0703
#define I2C_SMBUS      0x0720
#define I2C_SMBUS_QUICK 0
#define I2C_SMBUS_BYTE  1
#define I2C_SMBUS_WRITE 0
struct i2c_smbus_ioctl_data {
    uint8_t read_write, command;
    uint32_t size;
    void *data;
};
union i2c_smbus_data { uint8_t byte; };

#define GPIO_IOBASE   0x10010000
#define GPIO_MAP_SIZE 0x8000
#define PORT_OFF(p)   ((p) * 0x1000)
#define SHADOW_OFF    0x7000

/* port registers */
#define PXPIN   0x00
#define PXINT   0x10
#define PXMSK   0x20
#define PXPAT1  0x30
#define PXPAT0  0x40
#define PXPUENS 0x114
#define PXPDENC 0x128
/* shadow registers */
#define PZINTC   0x18
#define PZMSKS   0x24
#define PZPAT1S  0x34
#define PZPAT1C  0x38
#define PZPAT0S  0x44
#define PZPAT0C  0x48
#define PZGID2LD 0xF0

#define PORT 1          /* GPIO52/53 are on port B */
static unsigned PIN_SCL = 53;   /* GPIO53 = PB21 */
static unsigned PIN_SDA = 52;   /* GPIO52 = PB20 */
#define GRP  PORT       /* shadow load group = port index */

static volatile uint32_t *gpio;   /* mapped 0x10010000 */

static inline void wr(uint32_t off, uint32_t v) { gpio[off / 4] = v; }
static inline uint32_t rd(uint32_t off) { return gpio[off / 4]; }

static void delay_us(unsigned us)
{
    struct timeval a, b;
    gettimeofday(&a, 0);
    do { gettimeofday(&b, 0); }
    while ((b.tv_sec - a.tv_sec) * 1000000 + (b.tv_usec - a.tv_usec) < (long)us);
}

static unsigned busdelay = 3;   /* us per half-bit => ~150kHz */

static int hw_probe(int fd, int addr)
{
    uint8_t b = 0;
    if (ioctl(fd, I2C_SLAVE, addr) < 0) return -1;
    return write(fd, &b, 1) == 1 ? 0 : -1;
}

/* pin as input (released, pulled up) */
static void pin_release(unsigned pin)
{
    unsigned port = pin / 32, b = pin % 32;
    wr(SHADOW_OFF + PZINTC, 1u << b);
    wr(SHADOW_OFF + PZMSKS, 1u << b);
    wr(SHADOW_OFF + PZPAT1S, 1u << b);
    wr(SHADOW_OFF + PZGID2LD, port);
}
/* pin as output driving low */
static void pin_low(unsigned pin)
{
    unsigned port = pin / 32, b = pin % 32;
    wr(SHADOW_OFF + PZINTC, 1u << b);
    wr(SHADOW_OFF + PZMSKS, 1u << b);
    wr(SHADOW_OFF + PZPAT1C, 1u << b);
    wr(SHADOW_OFF + PZPAT0C, 1u << b);
    wr(SHADOW_OFF + PZGID2LD, port);
}
/* pin as output driving given value (push-pull) */
static void pin_drive(unsigned pin, int v)
{
    unsigned port = pin / 32, b = pin % 32;
    wr(SHADOW_OFF + PZINTC, 1u << b);
    wr(SHADOW_OFF + PZMSKS, 1u << b);
    wr(SHADOW_OFF + PZPAT1C, 1u << b);
    wr(SHADOW_OFF + (v ? PZPAT0S : PZPAT0C), 1u << b);
    wr(SHADOW_OFF + PZGID2LD, port);
}
static int pin_read(unsigned pin)
{
    return !!(rd(PORT_OFF(pin / 32) + PXPIN) & (1u << (pin % 32)));
}

static void sda(int v) { v ? pin_release(PIN_SDA) : pin_low(PIN_SDA); }
/* push-pull SCL: sole master, guarantees clock edges without a pull-up */
static void scl(int v) { pin_drive(PIN_SCL, v); }

static void pin_input(unsigned g)
{
    unsigned port = g / 32, pin = g % 32;
    wr(SHADOW_OFF + PZINTC, 1u << pin);
    wr(SHADOW_OFF + PZMSKS, 1u << pin);
    wr(SHADOW_OFF + PZPAT1S, 1u << pin);
    wr(SHADOW_OFF + PZGID2LD, port);
}
static void pin_out(unsigned g, int v)
{
    unsigned port = g / 32, pin = g % 32;
    wr(SHADOW_OFF + PZINTC, 1u << pin);
    wr(SHADOW_OFF + PZMSKS, 1u << pin);
    wr(SHADOW_OFF + PZPAT1C, 1u << pin);
    wr(SHADOW_OFF + (v ? PZPAT0S : PZPAT0C), 1u << pin);
    wr(SHADOW_OFF + PZGID2LD, port);
}
static int gread(unsigned g)
{
    return !!(rd(PORT_OFF(g / 32) + PXPIN) & (1u << (g % 32)));
}
/* one-shot address probe on arbitrary pin pair, open-drain both */
static int pair_probe(unsigned sclk, unsigned sdat, uint8_t addr)
{
    int i, ack;
    PIN_SCL = sclk; PIN_SDA = sdat;
    /* both released (input + weak pull-up) */
    pin_input(sclk); pin_input(sdat);
    wr(PORT_OFF(sclk / 32) + PXPDENC, 1u << (sclk % 32));
    wr(PORT_OFF(sdat / 32) + PXPDENC, 1u << (sdat % 32));
    wr(PORT_OFF(sclk / 32) + PXPUENS, 1u << (sclk % 32));
    wr(PORT_OFF(sdat / 32) + PXPUENS, 1u << (sdat % 32));
    delay_us(busdelay * 4);
    if (!gread(sdat)) { pin_input(sclk); pin_input(sdat); return -2; } /* bus busy/stuck */
    /* start */
    pin_out(sdat, 0); delay_us(busdelay);
    pin_out(sclk, 0); delay_us(busdelay);
    /* address byte, open-drain data */
    for (i = 6; i >= 0; i--) {
        if ((addr >> i) & 1) pin_input(sdat); else pin_out(sdat, 0);
        delay_us(busdelay);
        pin_input(sclk); delay_us(busdelay);
        pin_out(sclk, 0); delay_us(busdelay);
    }
    /* write bit = 0 */
    pin_out(sdat, 0); delay_us(busdelay);
    pin_input(sclk); delay_us(busdelay);
    pin_out(sclk, 0); delay_us(busdelay);
    /* ACK bit */
    pin_input(sdat); delay_us(busdelay * 2);
    pin_input(sclk); delay_us(busdelay);
    ack = gread(sdat) ? 1 : 0;
    pin_out(sclk, 0); delay_us(busdelay);
    /* stop */
    pin_out(sdat, 0); delay_us(busdelay);
    pin_input(sclk); delay_us(busdelay);
    pin_input(sdat); delay_us(busdelay);
    return ack;
}

static void i2c_start(void)
{
    sda(1); scl(1); delay_us(busdelay);
    sda(0); delay_us(busdelay);
    scl(0); delay_us(busdelay);
}
static void i2c_stop(void)
{
    sda(0); delay_us(busdelay);
    scl(1); delay_us(busdelay);
    sda(1); delay_us(busdelay * 2);
}
/* returns 0 on ACK */
static int i2c_write_byte(uint8_t b)
{
    int i, ack;
    for (i = 7; i >= 0; i--) {
        sda((b >> i) & 1); delay_us(busdelay);
        scl(1); delay_us(busdelay);
        scl(0); delay_us(busdelay);
    }
    sda(1); delay_us(busdelay);       /* release for ACK */
    scl(1); delay_us(busdelay);
    ack = pin_read(PIN_SDA) ? 1 : 0;
    scl(0); delay_us(busdelay);
    return ack;
}
static uint8_t i2c_read_byte(int ack)
{
    uint8_t b = 0;
    int i;
    sda(1);
    for (i = 7; i >= 0; i--) {
        scl(1); delay_us(busdelay);
        if (pin_read(PIN_SDA)) b |= 1 << i;
        scl(0); delay_us(busdelay);
    }
    sda(ack ? 0 : 1); delay_us(busdelay);
    scl(1); delay_us(busdelay);
    scl(0); delay_us(busdelay);
    sda(1);
    return b;
}

#define CHIP_ADDR 0x10

static int chip_write(uint8_t reg, uint8_t val)
{
    int ack = 0;
    i2c_start();
    ack |= i2c_write_byte((CHIP_ADDR << 1) | 0);
    ack |= i2c_write_byte(reg);
    ack |= i2c_write_byte(val);
    i2c_stop();
    return ack;
}
static int chip_read(uint8_t reg, uint8_t *val)
{
    int ack = 0;
    i2c_start();
    ack |= i2c_write_byte((CHIP_ADDR << 1) | 0);
    ack |= i2c_write_byte(reg);
    i2c_start();                       /* repeated start */
    ack |= i2c_write_byte((CHIP_ADDR << 1) | 1);
    *val = i2c_read_byte(0);           /* NACK last byte */
    i2c_stop();
    return ack;
}

/* GC6153 power-on table from vendor motor_iic.ko init_gc6153 */
static const uint8_t init_table[][2] = {
    {0x17, 0x00}, {0x17, 0x13}, {0x12, 0xc0}, {0x13, 0x03}, {0x14, 0x1f},
    {0x00, 0x10}, {0x01, 0x00}, {0x09, 0x10}, {0x0a, 0x00},
    {0x03, 0x00}, {0x0c, 0x00}, {0x02, 0x04}, {0x0b, 0x04},
    {0x05, 0x11}, {0x0e, 0x11}, {0x06, 0x22}, {0x0f, 0x22},
    {0x18, 0x00}, {0x19, 0x00}, {0x1a, 0x00}, {0x1b, 0x00},
};
static int chip_init(void)
{
    unsigned i;
    int ack = 0;
    for (i = 0; i < sizeof(init_table) / sizeof(init_table[0]); i++) {
        ack |= chip_write(init_table[i][0], init_table[i][1]);
        delay_us(50);
    }
    delay_us(10);
    ack |= chip_write(0x17, 0x03);
    delay_us(50);
    return ack;
}

/* ---- vendor-verbatim movement, from motor_iic.ko VP_*_motor_manual_start/disable ----
 * per-axis register blocks:
 *   y (tilt, block1): mode 0x06, current 0x01, phase pair 0x07/0x08, pos 0x18/0x19
 *   x (pan,  block2): mode 0x0f, current 0x0a, phase pair 0x10/0x11, pos 0x1a/0x1b
 * phase word = [start:bit11][dir:bit10][data:10bit], split hi/lo across the pair,
 * 10us between words. chip self-steps; poll pos regs until stable, then disable. */
struct axis_regs { uint8_t mode, cur, phi, plo, posl, posh; };
static const struct axis_regs AX[2] = {
    {0x06, 0x01, 0x07, 0x08, 0x18, 0x19},   /* y = tilt */
    {0x0f, 0x0a, 0x10, 0x11, 0x1a, 0x1b},   /* x = pan  */
};

static int phase_wr(const struct axis_regs *a, int dirflag, int start, unsigned data10)
{
    int ack = 0;
    ack |= chip_write(a->phi, ((data10 >> 8) & 3) | ((dirflag & 1) << 2) | (start ? 8 : 0));
    ack |= chip_write(a->plo, data10 & 0xff);
    return ack;
}

/* vendor move burst: VP_Xaxis_motor_manual_start */
static int vendor_move(int x, int dir, int speed, unsigned steps)
{
    const struct axis_regs *a = &AX[x];
    int dirflag = (dir - 1) & 1;
    int idx = 10 - speed, ack = 0;
    unsigned s1, ramp[4], i;
    if (idx <= 0) idx = 1;
    if (idx > 10) idx = 10;
    s1 = 215 + 30 * idx;                /* 245..515 */
    ramp[0] = s1 * 9 / 10;
    ramp[1] = s1 * 8 / 10;
    ramp[2] = s1 * 6 / 10;
    ramp[3] = s1 * 5 / 10;
    ack |= chip_write(0x17, 0x13);      /* stop pin low = motor active */
    delay_us(50);
    ack |= chip_write(a->mode, 0x02);   /* run mode */
    ack |= chip_write(a->cur, 0x7f);    /* current (vendor default torque: 127) */
    ack |= phase_wr(a, dirflag, 1, s1);
    delay_us(10);
    for (i = 0; i < 4; i++) {
        ack |= phase_wr(a, dirflag, 0, ramp[i]);
        delay_us(10);
    }
    ack |= phase_wr(a, dirflag, 0, steps > 256 ? 32 : 0);
    delay_us(10);
    ack |= phase_wr(a, 0, 0, steps & 0x3ff);   /* NB: vendor clears dir bit here */
    delay_us(10);
    ack |= phase_wr(a, dirflag, 0, (steps >> 10) & 0x3ff);
    delay_us(10);
    return ack;
}

/* vendor stop: VP_*_motor_disable + vp_stop_pin_to_h */
static int vendor_stop(int x, int dir)
{
    const struct axis_regs *a = &AX[x];
    int dirflag = (dir - 1) & 1, ack = 0;
    static const unsigned decay[8] = {324, 216, 144, 96, 64, 0, 0, 0};
    unsigned i;
    ack |= chip_write(a->mode, 0x07);   /* brake/disable mode */
    ack |= chip_write(a->cur, 0x00);
    for (i = 0; i < 8; i++)
        ack |= phase_wr(a, dirflag, i == 0, decay[i]);
    ack |= chip_write(0x17, 0x03);      /* stop pin high = idle */
    return ack;
}

static unsigned vendor_pos(int x)
{
    uint8_t lo = 0, hi = 0;
    chip_read(AX[x].posl, &lo);
    delay_us(10);
    chip_read(AX[x].posh, &hi);
    return ((unsigned)hi << 8) | lo;
}

/* continuous jog: re-issue the vendor burst as soon as the position counter
 * stalls; stop on timeout or when the axis stalls at a limit */
static int vendor_cont(int x, int dir, int speed, unsigned ms)
{
    unsigned t = 0, last, now, bursts = 1, stable = 0, moved = 0;
    int ack = vendor_move(x, dir, speed, 1023);
    last = vendor_pos(x);
    while (t < ms) {
        delay_us(5000);
        t += 5;
        now = vendor_pos(x);
        if (now != last) {
            last = now;
            moved = 1;
            stable = 0;
            continue;
        }
        stable++;
        if (moved && stable >= 1) {
            /* burst finished -> re-issue immediately */
            ack |= vendor_move(x, dir, speed, 1023);
            bursts++;
            moved = 0;
            stable = 0;
        } else if (!moved && stable >= 30) {
            printf("limit after %u bursts\n", bursts);
            break;
        }
    }
    ack |= vendor_stop(x, dir);
    printf("%s: %u bursts, pos %u, %s\n", x ? "pan" : "tilt", bursts, last,
           t >= ms ? "timeout" : "limit");
    return ack;
}

/* direct-drive streamer for GC6153F: chip steps on each phase-pair write.
 * mode 0: constant 10-bit value (dir bit toggles)
 * mode 1: 32-entry sine on the 10-bit value (offset binary around 0x200),
 *         direction = table order */
static int drive_stream(int x, int mode, int dir, unsigned val, unsigned count, unsigned us)
{
    const struct axis_regs *a = &AX[x];
    /* full sine, 32 entries, offset binary 1..1023 around 512 */
    static const uint16_t sine[32] = {
        512, 612, 708, 796, 873, 937, 984, 1013,
        1023, 1013, 984, 937, 873, 796, 708, 612,
        512, 412, 316, 228, 151, 87, 40, 11,
        1, 11, 40, 87, 151, 228, 316, 412
    };
    unsigned i, k = 0;
    int ack = 0;
    chip_write(0x17, 0x13);
    delay_us(50);
    chip_write(a->mode, 0x02);
    chip_write(a->cur, 0x40);
    for (i = 0; i < count; i++) {
        unsigned v;
        if (mode == 1) {
            unsigned idx = dir > 0 ? (k & 31) : ((32 - (k & 31)) & 31);
            v = sine[idx];
            k++;
        } else {
            v = val & 0x3ff;
        }
        /* NB: never set bit3 ("start") - GC6153F direct-drive hangs on it */
        ack |= chip_write(a->phi, ((dir < 0 && mode == 0) ? 4 : 0) | ((v >> 8) & 3));
        ack |= chip_write(a->plo, v & 0xff);
        delay_us(us);
    }
    ack |= chip_write(a->phi, 0);
    ack |= chip_write(a->plo, 0);
    ack |= chip_write(0x17, 0x03);
    return ack;
}

/* jog: move, poll position until stable (limit) or ms elapsed, then stop */
static int vendor_run(int x, int dir, int speed, unsigned ms)
{
    unsigned last, now, stable = 0, t = 0;
    int ack = vendor_move(x, dir, speed, 1023);
    if (ack) { printf("move burst NACK!\n"); return ack; }
    last = now = vendor_pos(x);
    while (t < ms) {
        delay_us(20000);
        t += 20;
        now = vendor_pos(x);
        if (now == last) {
            if (++stable >= 3) break;
        } else {
            stable = 0;
            last = now;
        }
    }
    ack |= vendor_stop(x, dir);
    printf("%s pos %u->%u, %s\n", x ? "pan" : "tilt", last, now,
           stable >= 3 ? "limit/stable" : "timeout");
    return ack;
}

int main(int argc, char **argv)
{
    int fd, i;
    if (argc < 2) {
        fprintf(stderr, "usage: %s scan|init|dump|wr <reg> <val>|rd <reg>|probe\n", argv[0]);
        return 1;
    }
    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) { perror("/dev/mem"); return 1; }
    gpio = mmap(NULL, GPIO_MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, GPIO_IOBASE);
    if (gpio == MAP_FAILED) { perror("mmap"); return 1; }
    { char *e = getenv("BD"); if (e) busdelay = atoi(e); }
    if (getenv("SWAP")) { PIN_SCL = 30; PIN_SDA = 29; }
    { char *e = getenv("SCL"); if (e) PIN_SCL = atoi(e); }
    { char *e = getenv("SDA"); if (e) PIN_SDA = atoi(e); }

    /* SDA: no pull-down, weak pull-up on; bus idle */
    wr(PORT_OFF(PIN_SCL / 32) + PXPDENC, 1u << (PIN_SCL % 32));
    wr(PORT_OFF(PIN_SDA / 32) + PXPDENC, 1u << (PIN_SDA % 32));
    wr(PORT_OFF(PIN_SCL / 32) + PXPUENS, 1u << (PIN_SCL % 32));
    wr(PORT_OFF(PIN_SDA / 32) + PXPUENS, 1u << (PIN_SDA % 32));
    sda(1); scl(1);
    delay_us(10);

    if (!strcmp(argv[1], "recover")) {
        /* i2c bus recovery: clock SCL until SDA releases, then STOP */
        int n;
        sda(1);
        for (n = 0; n < 32; n++) {
            scl(0); delay_us(10);
            scl(1); delay_us(10);
            if (pin_read(PIN_SDA)) { printf("SDA released after %d clocks\n", n + 1); break; }
        }
        /* STOP: SDA low while SCL high, then release */
        sda(0); delay_us(10);
        scl(1); delay_us(10);
        sda(1); delay_us(10);
        printf("SDA=%d SCL=%d\n", pin_read(PIN_SDA), pin_read(PIN_SCL));
        return 0;
    } else if (!strcmp(argv[1], "discover")) {
        /* discover [addr] [lo] [hi] - probe addr on every free SCL/SDA pair,
         * verified: addr must ACK twice, addr+1 must NACK */
        uint8_t addr = argc > 2 ? strtol(argv[2], 0, 0) : CHIP_ADDR;
        unsigned lo = argc > 3 ? atoi(argv[3]) : 32;
        unsigned hi = argc > 4 ? atoi(argv[4]) : 96;
        unsigned s, d; int found = 0;
        for (s = lo; s < hi; s++) {
            if (!(rd(PORT_OFF(s / 32) + PXMSK) & (1u << (s % 32)))) continue;
            for (d = lo; d < hi; d++) {
                if (s == d) continue;
                if (!(rd(PORT_OFF(d / 32) + PXMSK) & (1u << (d % 32)))) continue;
                if (pair_probe(s, d, addr)) continue;
                if (pair_probe(s, d, addr)) continue;
                if (pair_probe(s, d, addr + 1) == 0) continue;
                printf("VERIFIED 0x%02x: SCL=GPIO%u SDA=GPIO%u\n", addr, s, d);
                found++;
            }
        }
        printf("discover done, %d verified\n", found);
    } else if (!strcmp(argv[1], "hwscan")) {
        /* hwscan <bus> - scan a kernel i2c adapter via /dev/i2c-N */
        char path[32];
        snprintf(path, sizeof(path), "/dev/i2c-%d", argc > 2 ? atoi(argv[2]) : 0);
        int f = open(path, O_RDWR), found = 0;
        if (f < 0) { perror(path); return 1; }
        for (i = 0x03; i < 0x78; i++)
            if (hw_probe(f, i) == 0) { printf("ACK at 0x%02x\n", i); found++; }
        printf("bus %s: %d device(s)\n", path, found);
        return 0;
    } else if (!strcmp(argv[1], "ports")) {
        /* decode every pin: MSK=1&PAT1=1 in, MSK=1&PAT1=0 out(PAT0), MSK=0 func */
        int port, pin;
        for (port = 0; port < 4; port++) {
            uint32_t p = PORT_OFF(port);
            uint32_t pin_r = rd(p + PXPIN), msk = rd(p + PXMSK),
                     pat1 = rd(p + PXPAT1), pat0 = rd(p + PXPAT0);
            printf("port %c: PIN=%08x MSK=%08x PAT1=%08x PAT0=%08x\n",
                   'A' + port, pin_r, msk, pat1, pat0);
            for (pin = 0; pin < 32; pin++) {
                uint32_t b = 1u << pin;
                if (!(msk & b)) continue;          /* peripheral function */
                if (pat1 & b) continue;            /* input */
                printf("  GPIO%c%-2d OUT = %d\n", 'A' + port, pin, !!(pat0 & b));
            }
        }
    } else if (!strcmp(argv[1], "toggle") && argc >= 4) {
        /* toggle <gpio> <count> [ms] - square-wave a pin, end low */
        int g = atoi(argv[2]), cnt = atoi(argv[3]);
        int ms = argc > 4 ? atoi(argv[4]) : 100;
        unsigned port = g / 32, pin = g % 32, k;
        for (k = 0; k < (unsigned)cnt; k++) {
            wr(SHADOW_OFF + PZINTC, 1u << pin);
            wr(SHADOW_OFF + PZMSKS, 1u << pin);
            wr(SHADOW_OFF + PZPAT1C, 1u << pin);
            wr(SHADOW_OFF + PZPAT0S, 1u << pin);
            wr(SHADOW_OFF + PZGID2LD, port);
            usleep(ms * 1000);
            wr(SHADOW_OFF + PZPAT0C, 1u << pin);
            wr(SHADOW_OFF + PZGID2LD, port);
            usleep(ms * 1000);
        }
        printf("toggled GPIO%d %d times\n", g, cnt);
    } else if (!strcmp(argv[1], "set") && argc == 4) {
        /* set <gpio> <0|1> - one-shot output drive */
        int g = atoi(argv[2]), v = atoi(argv[3]);
        unsigned port = g / 32, pin = g % 32;
        wr(SHADOW_OFF + PZINTC, 1u << pin);
        wr(SHADOW_OFF + PZMSKS, 1u << pin);
        wr(SHADOW_OFF + PZPAT1C, 1u << pin);
        wr(SHADOW_OFF + (v ? PZPAT0S : PZPAT0C), 1u << pin);
        wr(SHADOW_OFF + PZGID2LD, port);
        printf("GPIO%d (P%c%d) <- %d\n", g, 'A' + g / 32, g % 32, v);
    } else if (!strcmp(argv[1], "watch") && argc == 3) {
        /* watch <gpio> - poll a pin for 3s, print transitions (find step pins) */
        int g = atoi(argv[2]);
        unsigned port = g / 32, pin = g % 32;
        int last = -1, n;
        for (n = 0; n < 30000; n++) {
            int v = !!(rd(PORT_OFF(port) + PXPIN) & (1u << pin));
            if (v != last) { printf("GPIO%d -> %d\n", g, v); last = v; }
        }
    } else if (!strcmp(argv[1], "gpio")) {
        uint32_t p = PORT_OFF(PORT);
        printf("PXPIN(boot)      = 0x%08x\n", rd(p + PXPIN));
        /* drive both high */
        wr(SHADOW_OFF + PZINTC, (1u << PIN_SCL) | (1u << PIN_SDA));
        wr(SHADOW_OFF + PZMSKS, (1u << PIN_SCL) | (1u << PIN_SDA));
        wr(SHADOW_OFF + PZPAT1C, (1u << PIN_SCL) | (1u << PIN_SDA));
        wr(SHADOW_OFF + PZPAT0S, (1u << PIN_SCL) | (1u << PIN_SDA));
        wr(SHADOW_OFF + PZGID2LD, GRP);
        delay_us(50);
        printf("PXPIN(out high)  = 0x%08x\n", rd(p + PXPIN));
        /* drive both low */
        wr(SHADOW_OFF + PZPAT0C, (1u << PIN_SCL) | (1u << PIN_SDA));
        wr(SHADOW_OFF + PZGID2LD, GRP);
        delay_us(50);
        printf("PXPIN(out low)   = 0x%08x\n", rd(p + PXPIN));
        /* release */
        sda(1); scl(1);
        delay_us(50);
        printf("PXPIN(released)  = 0x%08x\n", rd(p + PXPIN));
    } else if (!strcmp(argv[1], "scan")) {
        int found = 0;
        for (i = 0x03; i < 0x78; i++) {
            int ack;
            i2c_start();
            ack = i2c_write_byte(i << 1);
            i2c_stop();
            if (!ack) { printf("ACK at 0x%02x\n", i); found++; }
        }
        printf(found ? "done, %d device(s)\n" : "no devices found\n", found);
    } else if (!strcmp(argv[1], "probe")) {
        i2c_start();
        i = i2c_write_byte((CHIP_ADDR << 1) | 0);
        i2c_stop();
        printf("chip 0x%02x: %s\n", CHIP_ADDR, i ? "NO ack" : "ACK");
        return i;
    } else if (!strcmp(argv[1], "init")) {
        i = chip_init();
        printf("init %s\n", i ? "NACK!" : "ok");
        return i;
    } else if (!strcmp(argv[1], "drive") && argc >= 7) {
        /* drive <x|y> <mode 0=const|1=sine> <dir +1|-1> <val10> <count> [us] */
        int x = (argv[2][0] == 'x');
        int mode = atoi(argv[3]);
        int dir = atoi(argv[4]);
        unsigned val = strtoul(argv[5], 0, 0);
        unsigned count = strtoul(argv[6], 0, 0);
        unsigned us = argc >= 8 ? strtoul(argv[7], 0, 0) : 2000;
        return drive_stream(x, mode, dir, val, count, us);
    } else if (!strcmp(argv[1], "vmove") && argc >= 6) {
        /* vmove <x|y> <dir 1|2> <speed 0-10> <steps> - vendor burst, non-blocking */
        int x = (argv[2][0] == 'x');
        int dir = atoi(argv[3]), speed = atoi(argv[4]);
        unsigned steps = strtoul(argv[5], 0, 0);
        i = vendor_move(x, dir, speed, steps);
        printf("vmove %c dir=%d speed=%d steps=%u %s\n", x ? 'x' : 'y', dir,
               speed, steps, i ? "NACK!" : "ok");
        return i;
    } else if (!strcmp(argv[1], "vstop") && argc >= 3) {
        /* vstop <x|y> [dir] - vendor decay ramp + stop pin high */
        int x = (argv[2][0] == 'x');
        int dir = argc >= 4 ? atoi(argv[3]) : 1;
        i = vendor_stop(x, dir);
        printf("vstop %c %s\n", x ? 'x' : 'y', i ? "NACK!" : "ok");
        return i;
    } else if (!strcmp(argv[1], "vcont") && argc >= 6) {
        /* vcont <x|y> <dir 1|2> <speed 0-10> <ms> - continuous jog via burst chaining */
        int x = (argv[2][0] == 'x');
        return vendor_cont(x, atoi(argv[3]), atoi(argv[4]),
                           strtoul(argv[5], 0, 0));
    } else if (!strcmp(argv[1], "vrun") && argc >= 6) {
        /* vrun <x|y> <dir 1|2> <speed 0-10> <ms> - jog with limit detect + stop */
        int x = (argv[2][0] == 'x');
        return vendor_run(x, atoi(argv[3]), atoi(argv[4]),
                          strtoul(argv[5], 0, 0));
    } else if (!strcmp(argv[1], "dump")) {
        uint8_t v;
        for (i = 0x00; i <= 0x1b; i++) {
            if (chip_read(i, &v)) { printf("reg 0x%02x: NACK\n", i); continue; }
            printf("reg 0x%02x = 0x%02x\n", i, v);
        }
    } else if (!strcmp(argv[1], "phase") && argc == 5) {
        /* phase <x|y> <dir> <val10> - direct phase-current drive */
        int x = (argv[2][0] == 'x');
        unsigned dir = atoi(argv[3]) & 1;
        unsigned val = strtol(argv[4], 0, 0) & 0x3ff;
        uint8_t rhi = x ? 0x10 : 0x07, rlo = x ? 0x11 : 0x08;
        int a = 0;
        a |= chip_write(rhi, (dir << 2) | ((val >> 8) & 3));
        a |= chip_write(rlo, val & 0xff);
        printf("phase %c dir=%u val=0x%03x %s\n", x ? 'x' : 'y', dir, val,
               a ? "NACK!" : "ok");
        return a;
    } else if (!strcmp(argv[1], "q2") && argc >= 4) {
        /* q2 <x|y> <dir> [steps] [ms] - signed quadrature:
         * reg A = [dir:bit2][mag 0-3], reg B = [sign:bit7][mag 0-127] */
        int x = (argv[2][0] == 'x');
        int up = atoi(argv[3]);
        int count = argc > 4 ? atoi(argv[4]) : 400;
        int ms = argc > 5 ? atoi(argv[5]) : 5;
        uint8_t rmode = x ? 0x0f : 0x06, rspd = x ? 0x0a : 0x01;
        uint8_t ra = x ? 0x10 : 0x07, rb = x ? 0x11 : 0x08;
        static const uint8_t qa[8] = {0x00, 0x02, 0x03, 0x02, 0x00, 0x06, 0x07, 0x06};
        static const uint8_t qb[8] = {0x7f, 0x5a, 0x00, 0xda, 0xff, 0xda, 0x00, 0x5a};
        int i, ph = 0;
        chip_write(0x17, 0x13); delay_us(50);
        chip_write(rmode, 2);
        chip_write(rspd, 0x40);
        for (i = 0; i < count; i++) {
            ph = up ? (ph + 1) & 7 : (ph + 7) & 7;
            chip_write(ra, qa[ph]);
            chip_write(rb, qb[ph]);
            usleep(ms * 1000);
        }
        chip_write(ra, 0); chip_write(rb, 0);
        chip_write(0x17, 0x03);
        printf("q2 done\n");
    } else if (!strcmp(argv[1], "quad") && argc >= 5) {
        /* quad <x|y> <table_dir> <bit2> [steps] [ms] - two-phase quadrature:
         * 0x10/0x07 = dir-bit2 + phase A level (2 bit), 0x11/0x08 = phase B */
        int x = (argv[2][0] == 'x');
        int up = atoi(argv[3]);
        unsigned b2 = atoi(argv[4]) & 1;
        int count = argc > 5 ? atoi(argv[5]) : 400;
        int ms = argc > 6 ? atoi(argv[6]) : 5;
        uint8_t rmode = x ? 0x0f : 0x06, rspd = x ? 0x0a : 0x01;
        uint8_t ra = x ? 0x10 : 0x07, rb = x ? 0x11 : 0x08;
        static const uint8_t qa[8] = {2, 3, 3, 3, 2, 0, 0, 0};
        static const uint8_t qb[8] = {255, 218, 128, 38, 1, 38, 128, 218};
        int i, ph = 0;
        chip_write(0x17, 0x13); delay_us(50);
        chip_write(rmode, 2);
        chip_write(rspd, 0x40);
        for (i = 0; i < count; i++) {
            ph = up ? (ph + 1) & 7 : (ph + 7) & 7;
            chip_write(ra, (b2 << 2) | qa[ph]);
            chip_write(rb, qb[ph]);
            usleep(ms * 1000);
        }
        chip_write(ra, 0); chip_write(rb, 0);
        chip_write(0x17, 0x03);
        printf("quad done\n");
    } else if (!strcmp(argv[1], "ustep") && argc >= 4) {
        /* ustep <x|y> <dir> [steps] [ms] - unipolar half-step sequence on
         * reg 0x10/0x07 as 4-bit phase mask, 0x11/0x08 as current */
        int x = (argv[2][0] == 'x');
        int up = atoi(argv[3]);
        int count = argc > 4 ? atoi(argv[4]) : 400;
        int ms = argc > 5 ? atoi(argv[5]) : 5;
        uint8_t rmode = x ? 0x0f : 0x06, rspd = x ? 0x0a : 0x01;
        uint8_t rhi = x ? 0x10 : 0x07, rlo = x ? 0x11 : 0x08;
        static const uint8_t half[8] = {1, 3, 2, 6, 4, 12, 8, 9};
        int i, ph = 0;
        chip_write(0x17, 0x13); delay_us(50);
        chip_write(rmode, 2);
        chip_write(rspd, 0x40);
        chip_write(rlo, 0xff);
        for (i = 0; i < count; i++) {
            ph = up ? (ph + 1) & 7 : (ph + 7) & 7;
            chip_write(rhi, half[ph]);
            usleep(ms * 1000);
        }
        chip_write(rhi, 0); chip_write(rlo, 0);
        chip_write(0x17, 0x03);
        printf("ustep done\n");
    } else if (!strcmp(argv[1], "steps") && argc >= 4) {
        /* steps <x|y> <dir 0=dec,1=inc> [count] [ms] - cycle 2-bit phase state */
        int x = (argv[2][0] == 'x');
        int up = atoi(argv[3]);
        int count = argc > 4 ? atoi(argv[4]) : 100;
        int ms = argc > 5 ? atoi(argv[5]) : 5;
        uint8_t rmode = x ? 0x0f : 0x06, rspd = x ? 0x0a : 0x01;
        uint8_t rhi = x ? 0x10 : 0x07, rlo = x ? 0x11 : 0x08;
        int i, ph = 0;
        chip_write(0x17, 0x13); delay_us(50);
        chip_write(rmode, 2);
        chip_write(rspd, 0x40);
        chip_write(rlo, 0xff);              /* full current */
        for (i = 0; i < count; i++) {
            ph = up ? (ph + 1) & 3 : (ph + 3) & 3;
            chip_write(rhi, ph);
            usleep(ms * 1000);
        }
        chip_write(rhi, 0); chip_write(rlo, 0);
        chip_write(0x17, 0x03);
        printf("steps done\n");
    } else if (!strcmp(argv[1], "pos")) {
        /* pos - read X (0x1a/0x1b) and Y (0x18/0x19) position counters */
        uint8_t xh, xl, yh, yl;
        chip_read(0x1a, &xh); chip_read(0x1b, &xl);
        chip_read(0x18, &yh); chip_read(0x19, &yl);
        printf("xpos=%u ypos=%u\n", (xh << 8) | xl, (yh << 8) | yl);
    } else if (!strcmp(argv[1], "sweep") && argc >= 4) {
        /* sweep <x|y> <dir 0=down,1=up> [cycles] [ms] [steps/cycle]
         * stream the 10-bit phase value across one electrical period */
        int x = (argv[2][0] == 'x');
        int up = atoi(argv[3]);
        int cycles = argc > 4 ? atoi(argv[4]) : 100;
        int ms = argc > 5 ? atoi(argv[5]) : 5;
        int sps = argc > 6 ? atoi(argv[6]) : 8;
        uint8_t rmode = x ? 0x0f : 0x06, rspd = x ? 0x0a : 0x01;
        uint8_t rhi = x ? 0x10 : 0x07, rlo = x ? 0x11 : 0x08;
        int c, k;
        chip_write(0x17, 0x13); delay_us(50);
        chip_write(rmode, 2);
        chip_write(rspd, 0x40);
        for (c = 0; c < cycles; c++) {
            for (k = 0; k < sps; k++) {
                int idx = up ? k : (sps - 1 - k);
                unsigned v = (unsigned)idx * 1024 / sps;
                chip_write(rhi, (v >> 8) & 3);
                chip_write(rlo, v & 0xff);
                usleep(ms * 1000);
            }
        }
        chip_write(rhi, 0);
        chip_write(rlo, 0);
        chip_write(0x17, 0x03);
        printf("sweep done\n");
    } else if (!strcmp(argv[1], "run") && argc >= 4) {
        /* run <x|y> <dir> [steps] [ms] - cycle phase amplitude, watch axis */
        int x = (argv[2][0] == 'x');
        unsigned dir = atoi(argv[3]) & 1;
        int steps = argc > 4 ? atoi(argv[4]) : 200;
        int ms = argc > 5 ? atoi(argv[5]) : 5;
        uint8_t rmode = x ? 0x0f : 0x06, rspd = x ? 0x0a : 0x01;
        uint8_t rhi = x ? 0x10 : 0x07, rlo = x ? 0x11 : 0x08;
        static const uint16_t ramp[] = {0x3ff, 0x380, 0x300, 0x280, 0x200, 0x180, 0x100, 0x80};
        int i, k;
        chip_write(0x17, 0x13); delay_us(50);
        chip_write(rmode, 2);
        chip_write(rspd, 0x40);
        for (i = 0; i < steps; i++) {
            for (k = 0; k < 8; k++) {
                unsigned v = ramp[k];
                chip_write(rhi, (dir << 2) | ((v >> 8) & 3));
                chip_write(rlo, v & 0xff);
                usleep(ms * 1000);
            }
        }
        chip_write(rhi, dir << 2);
        chip_write(rlo, 0);
        chip_write(0x17, 0x03);
        printf("run done\n");
    } else if (!strcmp(argv[1], "ircut") && argc == 3) {
        /* tmi_ircut_control from vendor module; the coil needs ~200ms
         * energized or the filter does not actually swap (1=night/out,
         * 2=day/in) */
        uint8_t v = strtol(argv[2], 0, 0);
        int a = 0;
        a |= chip_write(0x17, 0x13); delay_us(50);
        a |= chip_write(0x15, 0x7f); delay_us(50);
        a |= chip_write(0x16, v);    usleep(200000);
        a |= chip_write(0x17, 0x03); delay_us(50);
        printf("ircut %s\n", a ? "NACK!" : "ok");
        return a;
    } else if (!strcmp(argv[1], "phases") && argc == 4) {
        /* direct phase-drive poke, from VP_Xaxis_motor_manual_start */
        uint8_t p0 = strtol(argv[2], 0, 0), p1 = strtol(argv[3], 0, 0);
        int a = 0;
        a |= chip_write(0x17, 0x13); delay_us(50);
        a |= chip_write(0x0f, 0x02);
        a |= chip_write(0x0a, 0x30);
        a |= chip_write(0x10, p0);   delay_us(10);
        a |= chip_write(0x11, p1);   delay_us(10);
        printf("phases %s\n", a ? "NACK!" : "ok");
        return a;
    } else if (!strcmp(argv[1], "wr") && argc == 4) {
        i = chip_write(strtol(argv[2], 0, 0), strtol(argv[3], 0, 0));
        printf("wr %s\n", i ? "NACK!" : "ok");
        return i;
    } else if (!strcmp(argv[1], "rd") && argc == 3) {
        uint8_t v;
        i = chip_read(strtol(argv[2], 0, 0), &v);
        if (i) { printf("rd NACK\n"); return i; }
        printf("0x%02x\n", v);
    } else {
        fprintf(stderr, "unknown command\n");
        return 1;
    }
    return 0;
}
