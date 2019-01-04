OUTPUT_FORMAT(binary)
ENTRY(_setup32)

SECTIONS
{
	. = 0x8000;
	_SETUP_START = .;

	.test ALIGN(0x10) : {
		KEEP(*(.test*))
	}

	.text ALIGN(0x10) : {
		_TEXT_START = .;
		*(.text*)
		_TEXT_END = .;
	}

	.rodata ALIGN(0x10) : {
		_RODATA_START = .;
		*(.rodata*)
		_RODATA_END = .;
	}

	.data ALIGN(0x10) : {
		_DATA_START = .;
		*(.data*)
		_DATA_END = .;
	}

	.bss ALIGN(0x10) : {
		_BSS_START = .;
		*(.bss*)
		_BSS_END = .;
	}

	/DISCARD/ : {
		*(.comment*)
	}

	_SETUP_END = .;
}