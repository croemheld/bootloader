.code16

# Segment:Offset of bootstrap file

.set BOOTS_PHYS_ADDR,      0x00010000
.set BOOTS_SEGMENT,        0x1000
.set BOOTS_SEGMENT_OFFSET, 0x0000

.text

	.global _setup32

_setup32:
	cli

	# cs = 0x0000

	mov %cs, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs

	xor %ax, %ax
	mov %ax, %ss

	# Set stack pointer below setup stage

	mov $0x7ff0, %sp

	# Enable A20 line 

	mov $0x2401, %ax
	int $0x15
	jc .a20_error

	mov $0x10, %ebx
	mov $0x01, %ecx
	mov $BOOTS_SEGMENT, %eax
	mov %ax, %es
	xor %di, %di

	# PVD already loaded

	mov %es, %ax
	mov %ax, %ds
	mov %di, %si
	mov %cx, %bx
	shl $11, %bx

	mov $boot_dir, %ax
	call read_entry

	test %ax, %ax
	jz .die

	mov %ds:pvd_root_dir_rec_ext_sec(%si), %ebx
	mov %ds:pvd_root_dir_rec_dat_len(%si), %ecx
	shr $11, %ecx

	call read_sector

	mov %es, %ax
	mov %ax, %ds
	mov %di, %si
	mov %cx, %bx
	shl $11, %bx

	mov $next_stage_loader, %ax
	call read_entry

	test %ax, %ax
	jz .die

	mov %ds:pvd_root_dir_rec_ext_sec(%si), %ebx
	mov %ds:pvd_root_dir_rec_dat_len(%si), %ecx
	add $0x1FFF, %ecx
	shr $11, %ecx

	call read_sector

	xchg %bx, %bx

	# Jump to setup stage

	jmp $0x1000, $0

	# mov $0x800, %edi
	# mov $0x4f00, %ax
	# mov $0x4118, %cx
	# int $0x10
	# cmp $0x004f, %ax
	# jne .vesa_error

	# mov $0x900, %edi
	# mov $0x4f01, %ax
	# mov $0x0118, %cx
	# int $0x10
	# cmp $0x004f, %ax
	# jne .vesa_error

	# mov $0x4f02, %ax
	# mov $0x4118, %bx
	# int $0x10
	# cmp $0x004f, %ax
	# jne .vesa_error

	mov $0xA000, %di

	push %ds
	push %es

	mov $0x1130, %ax
	mov $0x0600, %bx
	int $0x10

	push %es
	pop %ds
	pop %es
	mov %bp, %si
	mov $1024, %cx
	rep movsl
	pop %ds

	mov $.die, %eax
	call *%eax

	jmp .die

.vesa_error:
	mov $vesa_error_msg, %si
	call print_string

.a20_error:
	lea a20_error_msg, %si
	call print_string

.die:
	jmp .die

boot_params:

	#
	# This struct contains boot relevant informations
	#

	boot_params_disk_drive: .byte                 0x0


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
next_stage_loader: .asciz "TEST.TXT"

a20_error_msg:    .asciz "Could not enable A20 line"
vesa_error_msg: .asciz "Error on VESA video mode setting"
