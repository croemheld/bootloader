.code16

.text

read_sector:
	xor %ax, %ax
	mov %ax, %ds

	mov %ebx, dap_ptr_llba(,1)
	mov %ecx, dap_ptr_cnum(,1)

	lea dap_ptr(,1), %si
	mov %es, %ax

	mov %ax, dap_ptr_segm(,1)
	mov %di, dap_ptr_dest(,1)

	mov $0x42, %ah
	int $0x13
	jc .bios_error

	ret

.bios_error:
	xor %ax, %ax
	mov %ax, %ds

	mov $bios_error_msg, %si
	call print_string

	jmp .die

find_entry:
	push %di
	push %es
	push %bx

	mov %ax, %di
	xor %ax, %ax
	mov %ax, %es
	add %si, %bx

.find_entry_loop:
	cmp %bx, %si
	jae .entry_not_found
	cmpb $0, %ds:pvd_root_dir_rec_len(%si)
	je .entry_not_found

	xor %cx, %cx
	mov %ds:pvd_root_dir_rec_idt_len(%si), %cl
	cmp $boot_dir_name_len, %cl
	jb .next_entry

	xor %bp, %bp

.strcmp_loop:
	mov %es:(%bp,%di), %cl
	mov %ds:pvd_root_dir_rec_idt(%bp,%si), %ch
	test %cl, %cl

	jz .strcmp_check

	cmp %ch, %cl
	jne .next_entry
	inc %bp

	jmp .strcmp_loop

.strcmp_check:
	cmp $';', %ch
	je .entry_found

	test %ch, %ch
	je .entry_found

	cmp $pvd_root_dir_rec_idt_len, %bp
	je .entry_found

.next_entry:
	xor %cx, %cx
	mov %ds:pvd_root_dir_rec_len(%si), %cl
	add %cx, %si

	jmp .find_entry_loop

.entry_not_found:
	xor %ax, %ax
	jmp .entry_return

.entry_found:
	mov $1, %ax

.entry_return:
	pop %bx
	pop %es
	pop %di

	ret

# Disk Address Packet (DAP)

dap_ptr:
dap_ptr_size: .byte  0x10
dap_ptr_resv: .byte  0x00
dap_ptr_cnum: .short 0x0001
dap_ptr_dest: .short 0x00000000
dap_ptr_segm: .short 0x00000000
dap_ptr_llba: .long  0x00000000
dap_ptr_hlba: .long  0x00000000

bios_error_msg: .asciz "\r\nAn error in the BIOS function occurred."
