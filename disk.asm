.code16

.text

read_sector:
	xchg %bx, %bx

	xor %ax, %ax
	mov %ax, %ds

	mov $dap_ptr, %edx

	mov %ebx, dap_llba_off(%edx)
	mov %ecx, dap_count_off(%edx)

	mov $dap_ptr, %si
	mov %es, %ax

	mov %ax, dap_segm_off(%edx)
	mov %di, dap_dest_off(%edx)

	mov $0x42, %ah
	int $0x13
	jc bios_error

	ret

bios_error:
	xor %ax, %ax
	mov %ax, %ds

	mov $bios_error_msg, %si
	call print_string

	call .die

dap_ptr:
	.byte  0x10                                   # DAP size
	.byte  0x00                                   # reserved
	.short 0x0001                                 # count
	.long  0x00000000                             # dest
	.long  0x00000000                             # LBA sector low
	.long  0x00000000                             # LBA sector high

.set dap_count_off, 2
.set dap_dest_off,  4
.set dap_segm_off,  6
.set dap_llba_off,  8
.set dap_hlba_off,  12

bios_error_msg: .asciz "\r\nError in BIOS"
