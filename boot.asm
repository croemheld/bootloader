.code16

.set BOOT_IMAGE_ADDR,                             0x7C00
.set BOOT_STACK_ADDR,                             0x1800

# Segment:Offset of setup stage

.set SETUP_PHYS_ADDR,                             0x8000
.set SETUP_SEGMENT,                               0x0800
.set SETUP_SEGMENT_OFFSET,                        0x0000

.section .text

	.global _start

#
# Bootloader entry point
#

_start:
	ljmp $0, $_setup16

#
# The actual code after clearing %cs
#

_setup16:
	cli

	xorw    %ax, %ax
	movw    %ax, %ss
	movw    %ax, %ds
	movw    %ax, %es

	movw    $BOOT_STACK_ADDR, %sp

	# Save disk drive

	movb    %dl, boot_params_disk_drive

	# Clear screen and reset text mode cursor

	call    clear_screen
	call    reset_cursor

	lea     initializing_msg, %si
	call    print_string

	# Load the Primary Volume Descriptor into memory

	call    read_pvd

 	# Load BOOT directory

	lea     setup_id, %ax
	movw    $SETUP_SEGMENT, %di
	call    read_entry

	ljmp    $0, $SETUP_PHYS_ADDR

	# Something went terribly wrong

	jmp     .die

.die:
	jmp     .die

boot_params:

#
# This struct contains boot relevant informations
#

boot_params_disk_drive: 
	.byte   0x0

a20_error_msg:
	.asciz  "Could not enable A20 line"

initializing_msg:
	.asciz  "Initializing bootloader v0.1..."

.include "disk.asm"
.include "print.asm"
.include "screen.asm"

setup_id: .asciz "/BOOT/SETUP.BIN;1"

	. = _start + 510
	.byte 0x55
	.byte 0xaa

################################################################################

# _start:
# 	cli
# 
# 	xor %ax, %ax
# 	mov %ax, %ss
# 	mov %ax, %ds
# 	mov %ax, %es
# 	mov $BOOT_STACK_ADDR, %sp
# 
# 	call clear_screen
# 	call reset_cursor
# 
# 	mov $initializing_msg, %si
# 	call print_string
# 
# 	mov $0x10, %ebx
# 	mov $0x01, %ecx
# 	mov $SETUP_SEGMENT, %ax
# 	mov %ax, %es
# 	xor %di, %di
# 
# .find_pvd_loop:
# 	call read_sector
# 
# 	cmpb $pvd_type, %es:pvd_type_off(%di)
# 	je .pvd_found
# 	inc %ebx
# 
# 	jmp .find_pvd_loop
# 
# .pvd_found:
# 	mov %es:pvd_root_dir_rec + pvd_root_dir_rec_ext_sec(%di), %ebx
# 	mov %es:pvd_root_dir_rec + pvd_root_dir_rec_dat_len(%di), %ecx
# 	shr $11, %ecx
# 
# 	call read_sector
# 
# 	mov %es, %ax
# 	mov %ax, %ds
# 	mov %di, %si
# 	mov %cx, %bx
# 	shl $11, %bx
# 
# 	mov $setup_id, %ax
# 	call find_entry
# 
# 	test %ax, %ax
# 	jz .die
# 
# 	mov %ds:pvd_root_dir_rec_ext_sec(%si), %ebx
# 	mov %ds:pvd_root_dir_rec_dat_len(%si), %ecx
# 	shr $11, %ecx
# 
# 	call read_sector
# 
# 	mov %es, %ax
# 	mov %ax, %ds
# 	mov %di, %si
# 	mov %cx, %bx
# 	shl $11, %bx
# 
# 	mov $next_stage_loader, %ax
# 	call find_entry
# 
# 	test %ax, %ax
# 	jz .die
# 
# 	mov %ds:pvd_root_dir_rec_ext_sec(%si), %ebx
# 	mov %ds:pvd_root_dir_rec_dat_len(%si), %ecx
# 	add $0x1FFF, %ecx
# 	shr $11, %ecx
# 
# 	call read_sector
# 
# 	xchg %bx, %bx
# 
# 	# Jump to setup stage
# 
# 	jmp $0, $SETUP_PHYS_ADDR
# 
# .die:
# 	jmp .die
# 
# .include "disk.asm"
# .include "print.asm"
# .include "screen.asm"
# 

# next_stage_loader: .asciz "SETUP.BIN"
# initializing_msg: .asciz "Initializing bootloader v0.1..."
# 
# 	. = _start + 510
# 	.byte 0x55
# 	.byte 0xaa
