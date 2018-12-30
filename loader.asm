.code16

.text

	.global _start

_start:
	xor %ax, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %ss
	mov $0x7c00, %sp

	call clear_screen
	call reset_cursor

	mov $initializing_msg, %si
	call print_string

	# int $0x13 extensions

	mov $0x41, %ah
	mov $0x55aa, %bx
	int $0x13
	jc ext_not_present
	cmp $0xaa55, %bx
	jne ext_not_present

	mov $0x10, %ebx
	mov $0x01, %ecx
	mov $0x1000, %ax
	mov %ax, %es
	xor %di, %di

.find_pvd_loop:
	call read_sector

	cmpb $pdv_type, %es:vd_type_off(%di)
	je .pvd_found
	inc %ebx

	jmp .find_pvd_loop

.pvd_found:

	mov $pvd_found_msg, %si
	call print_string

	call .die

ext_not_present:
	xor %ax, %ax
	mov %ax, %ds

	mov $ext_not_present_msg, %si
	call print_string

	call .die

.die:
	jmp .die

.include "disk.asm"
.include "print.asm"
.include "screen.asm"

.set vd_type_off, 0

.set pdv_type,    1

pvd_found_msg: .asciz "\r\nPVD found"
not_found_suffix_msg: .asciz " not found"
ext_not_present_msg: .asciz "\r\nLBA ext not present"
initializing_msg: .asciz "Initializing cr0S bootloader..."

	. = _start + 510
	.byte 0x55
	.byte 0xaa
