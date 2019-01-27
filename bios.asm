.code16

.section .text

	.global bios_interrupt
	.type bios_interrupt, @function

bios_call:
	push %ebp
	mov %esp, %ebp

	push %edi

	mov 0x00(%ebp), %eax
	mov 0x04(%ebp), %ebx
	mov 0x08(%ebp), %ecx
	mov 0x10(%ebp), %edx

	mov 0x14(%ebp), %edi

	int %edi

	pop %edi

	mov %ebp, %esp
	pop %ebp

	ret