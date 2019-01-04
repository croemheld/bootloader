AS                                                := as
CC                                                := gcc
LD                                                := ld

ISODIR                                            := iso
BOOTDIR                                           := boot
BOOTPATH                                          := $(ISODIR)/$(BOOTDIR)

BOOT                                              := boot
BOOTBIN                                           := $(BOOT).bin

SETUP                                             := setup
SETUPBIN                                          := $(SETUP).bin

LOADERISO                                         := $(BOOT).iso

BOOTIMG                                           := $(BOOTDIR)/$(BOOTBIN)

BOCHSRC                                           := bochsrc

.PHONY: all
all: $(LOADERISO)

.PHONY: clean
clean:
	rm -f *.o
	rm -f *.bin
	rm -f *.ini
	rm -f *.iso
	rm -rf iso/

.PHONY: isotree
isotree:
	isoinfo -f -i os.iso

$(LOADERISO): $(BOOTBIN) $(SETUPBIN)
	mkdir -p $(BOOTPATH)
	cp $(BOOTBIN) $(BOOTPATH)
	cp $(SETUPBIN) $(BOOTPATH)
	cp test.txt $(BOOTPATH)

	genisoimage -R -b $(BOOTIMG) -no-emul-boot -V CR0S -v -o $(LOADERISO) $(ISODIR)

$(BOOTBIN): $(BOOT).o
	$(LD) -T boot.ld $(BOOT).o -o $@

$(SETUPBIN): $(SETUP).o
	$(LD) -T setup.ld $(SETUP).o -o $@

%.o: %.asm
	$(AS) $< -o $@