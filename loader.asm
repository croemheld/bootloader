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

	# mov $0x41, %ah
	# mov $0x55aa, %bx
	# int $0x13
	# jc .ext_not_present
	# cmp $0xaa55, %bx
	# jne .ext_not_present

	mov $0x10, %ebx
	mov $0x01, %ecx
	mov $0x1000, %ax
	mov %ax, %es
	xor %di, %di

.find_pvd_loop:
	call read_sector

	cmpb $pvd_type, %es:pvd_type_off(%di)
	je .pvd_found
	inc %ebx

	jmp .find_pvd_loop

.pvd_found:
	mov %es:pvd_root_dir_rec + pvd_root_dir_rec_ext_sec(%di), %ebx
	mov %es:pvd_root_dir_rec + pvd_root_dir_rec_dat_len(%di), %ecx
	shr $11, %ecx

	call read_sector

	mov %es, %ax
	mov %ax, %ds
	mov %di, %si
	mov %cx, %bx
	shl $11, %bx

	mov $boot_dir, %ax
	call find_entry

	test %ax, %ax
	jz .path_not_found

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
	call find_entry

	test %ax, %ax
	jz .next_stage_not_found

	mov %ds:pvd_root_dir_rec_ext_sec(%si), %ebx
	mov %ds:pvd_root_dir_rec_dat_len(%si), %ecx
	add $0x1FFF, %ecx
	shr $11, %ecx

	call read_sector

	xchg %bx, %bx

	# Jump to 0x00010000

	jmp $0x1000, $0x0

	jmp .die

# .ext_not_present:
# 	xor %ax, %ax
# 	mov %ax, %ds
# 
# 	mov $ext_not_present_msg, %si
# 	call print_string
# 
# 	jmp .die

.path_not_found:
	xor %ax, %ax
	mov %ax, %ds

	mov $path_not_found_msg, %si
	call print_string

	jmp .die

.next_stage_not_found:
	xor %ax, %ax
	mov %ax, %ds

	mov $next_stage_not_found_msg, %si
	call print_string

	jmp .die

.die:
	jmp .die

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

ext_not_present_msg: .asciz "\r\nNo LBA"
path_not_found_msg: .asciz "\r\nNo path"
next_stage_not_found_msg: .asciz "\r\nNo stage"
initializing_msg: .asciz "Initializing bootloader v0.1..."

	. = _start + 510
	.byte 0x55
	.byte 0xaa
