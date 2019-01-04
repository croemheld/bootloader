.code16

.section .test

.short 0x1234

.section .text

	.global _setup32

_setup32:
	cli

	mov %cs, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs

	xor %ax, %ax
	mov %ax, %ss

	# Set stack pointer below setup stage

	mov $0x7ff0, %sp

	# Enter unreal mode



.die:
	jmp .die


.include "a20.asm"
.include "disk.asm"
.include "print.asm"
.include "screen.asm"

.set pvd_type_off,               0

.set pvd_type,                   1
.set pvd_root_dir_rec,         156
.set pvd_root_dir_rec_len,       0
.set pvd_root_dir_rec_dat_len,  10
.set pvd_root_dir_rec_ext_sec,   2
.set pvd_root_dir_rec_idt,      33
.set pvd_root_dir_rec_idt_len,  32

.set boot_dir_name_len, 4
boot_dir: .asciz "BOOT"
