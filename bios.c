#include "bios.h"

#define BIOS_GP_REGISTER(c)                      \
    union {                                      \
        uint32_t e##c##x;                        \
        uint16_t    c##x;                        \
        struct {                                 \
            uint8_t c##h;                        \
            uint8_t c##l;                        \
        };                                       \
    }

#define BIOS_NV_REGISTER(c)                      \
    union {                                      \
        uint32_t e##c;                           \
        uint16_t    c;                           \
        uint8_t  c##l;                           \
    }

struct bios_regs {
	uint16_t ds, es;
	uint32_t rflags;

	/*
	 * General Purpose Registers
	 */

	BIOS_GP_REGISTER(a);
	BIOS_GP_REGISTER(b);
	BIOS_GP_REGISTER(c);
	BIOS_GP_REGISTER(d);

	/*
	 * Subset: Non-volatile General Purpose Registers
	 */

	BIOS_NV_REGISTER(si);
	BIOS_NV_REGISTER(di);
	BIOS_NV_REGISTER(bp);
	BIOS_NV_REGISTER(sp);
} __attribute__((packed));

struct bios_desc {
	uint16_t limit;
	uint32_t base;
} __attribute__((packed));

struct bios_cpu_mode {
	struct bios_regs regs;
	struct biod_desc desc;
} __attribute__((packed));

struct bios_trampoline {
	struct bios_cpu_mode rmode;
	struct bios_cpu_mode pmode;
} __attribute__((packed));

struct bios_trampoline bios_trampoline;

/*
 * Get BIOS CPU modes
 */

static struct bios_trampoline *get_bios_trampoline(void)
{
	return &bios_trampoline;
}

static struct bios_cpu_mode *get_bios_cpu_rmode(void)
{
	return &get_bios_trampoline()->rmode;
}

static struct bios_cpu_mode *get_bios_cpu_pmode(void)
{
	return &get_bios_trampoline()->pmode;
}

static struct bios_regs *get_bios_rmode_regs(void)
{
	return &get_bios_cpu_rmode()->regs;
}

static struct bios_regs *get_bios_pmode_regs(void)
{
	return &get_bios_cpu_pmode()->regs;
}

static struct bios_desc *get_bios_rmode_desc(void)
{
	return &get_bios_cpu_rmode()->desc;
}

static struct bios_desc *get_bios_pmode_desc(void)
{
	return &get_bios_cpu_pmode()->desc;
}

/*
 * Store BIOS CPU modes
 */

void bios_store_rmode_state(struct bios_cpu_mode *rmode)
{
	struct bios_cpu_mode *bios_rmode = get_bios_cpu_rmode();

	bmemcpy(bios_rmode, rmode, sizeof(*rmode));
}

void bios_store_pmode_state(struct bios_cpu_mode *pmode)
{
	struct bios_cpu_mode *bios_pmode = get_bios_cpu_pmode();

	bmemcpy(bios_pmode, pmode, sizeof(*pmode));
}