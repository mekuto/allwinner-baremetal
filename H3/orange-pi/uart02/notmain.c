#include "h3_uart0_debug.h"

int notmain(unsigned int sp)
{
	uart0_init();
	uart0_puts("\nHello, world.\n\nlib-h3 here!\n");

	return 0;
}
