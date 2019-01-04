.code16

.text

	.global enable_a20

enable_a20:
	call a20_check
	jnc .a20_enabled

	call enable_a20_bios
	call a20_check
	jnc .a20_enabled

	call enable_a20_fast
	jnc .a20_enabled

	call enable_a20_8042
	call a20_check

.a20_enabled:

	ret

enable_a20_bios:
	mov $0x2401, %ax
	int $0x15

	ret

enable_a20_fast:
	in $0x92, %al
	test $2, %al
	jnz .a20_fast_enabled

	or $2, %al
	and $0xfe, %al
	out %al, $0x92

.a20_fast_enabled:

	ret

enable_a20_8042:
	call .a20_wait
	mov $0xd1, %al
	out %al, $0x64

	call .a20_wait
	mov $0xdf, %al
	out %al, $0x60

	call .a20_wait
	mov $0xff, %al
	out %al, $0x64

	call .a20_wait

	ret

.a20_wait:
	out %al, $0x80
	in $0x64, %al
	test $1, %al
	jne .a20_no_output

	out %al, $0x80
	in $0x60, %al
	jmp .a20_wait

.a20_no_output:
	test $2, %al
	jne .a20_wait

	ret

a20_check:
	push %ds
	push %es
	xor %ax, %ax

	mov %ax, %ds
	mov $0xffff, %ax
	mov %ax, %es
	mov 0x1000(,1), %ax
	mov $5, %cx

.a20_check_loop:
	out %al, $0x80
	mov 0x1000(,1), %bx
	cmp %es:0x1010, %bx
	jne .a20_8042_enabled

	inc %bx

	mov %bx, 0x1000(,1)
	cmp %es:0x1010, %bx
	jne .a20_8042_enabled

	dec %cx
	jnz .a20_check_loop
	stc
	jmp .a20_8042_return

.a20_8042_enabled:
	clc

.a20_8042_return:
	mov %ax, 0x1000(,1)
	pop %es
	pop %ds

	ret
