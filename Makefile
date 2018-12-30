AS                                                := as
CC                                                := gcc
LD                                                := ld

ISODIR                                            := iso
BOOTDIR                                           := boot
BOOTPATH                                          := $(ISODIR)/$(BOOTDIR)

LOADER                                            := loader
LOADERBIN                                         := $(LOADER).bin
LOADERISO                                         := $(LOADER).iso

BOOTLOADER                                        := $(BOOTDIR)/$(LOADERBIN)

BOCHSRC                                           := bochsrc

AS_FILES := $(LOADER).asm

AS_OBJS  := $(patsubst %.asm, %.o, $(AS_FILES))

OBJS     := $(AS_OBJS)

.PHONY: all
all: $(LOADERISO)

.PHONY: clean
clean:
	rm -f *.o
	rm -f *.bin
	rm -f *.iso
	rm -rf iso/

isotree:
	isoinfo -f -i os.iso


$(LOADERISO): $(LOADERBIN)
	mkdir -p $(BOOTPATH)
	cp $(LOADERBIN) $(BOOTPATH)

	genisoimage -R -b $(BOOTLOADER)              \
		-no-emul-boot -V CR0S -v -o os.iso $(ISODIR)

$(LOADERBIN): $(OBJS)
	$(LD) -T linker.ld $(AS_OBJS) -o $@

%.o: %.asm
	$(AS) $< -o $@