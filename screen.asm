.code16

.section .text

clear_screen:
	push %bp
	mov %sp, %bp

	pusha

	mov $0x07, %ah
	mov $0x00, %al
	mov $0x07, %bh
	mov $0x00, %cx
	mov $0x18, %dh
	mov $0x4f, %dl

	int $0x10

	popa

	mov %bp, %sp
	pop %bp

	ret

reset_cursor:
	push %bp
	mov %sp, %bp

	pusha

	mov $0x00, %dh
	mov $0x00, %dl
	mov $0x02, %ah
	mov $0x00, %bh

	int $0x10

	popa

	mov %bp, %sp
	pop %bp

	ret
