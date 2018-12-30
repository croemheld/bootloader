.code16

.text

print_string:
	push %bp
	mov %sp, %bp

	pusha

	mov $0x00, %bh
	mov $0x00, %bl
	mov $0x0e, %ah

.print_char:
	lodsb

	cmp $0, %al
	je .done

	int $0x10
	jmp .print_char

.done:
	popa

	mov %bp, %sp
	pop %bp

	ret
