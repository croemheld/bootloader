OUTPUT_FORMAT(binary)
ENTRY(_start)

SECTIONS
{
	. = 0x7C00;

	.text : {
		*(.text*)
	}

	.rodata : {
		*(.rodata*)
	}

	.data : {
		*(.data*)
	}

	.bss : {
		*(.bss*)
	}

	/DISCARD/ : {
		*(.comment*)
	}
}