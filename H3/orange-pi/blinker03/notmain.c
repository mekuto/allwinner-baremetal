#include "h3.h"
#include "h3_board.h"
#include "h3_timer.h"

#define LED1 H3_PORT_TO_GPIO(H3_GPIO_PORTA, 10)
#define POWER_LED_PIO	10	// PL10

#define PRCM_APB0_GATE_PIO (0x1 << 0)
#define PRCM_APB0_RESET_PIO (0x1 << 0)

// copied from https://github.com/vanvught/rpidmx512/blob/e56aae2a9abe151a17aa571022b0b982ecc018c1/lib-hal/src/h3/hardware.c#L135
void led2_init()
{
	H3_PRCM->APB0_GATE |= PRCM_APB0_GATE_PIO;
	H3_PRCM->APB0_RESET |= PRCM_APB0_RESET_PIO;
	uint32_t value = H3_PIO_PORTL->CFG1;
	value &= ~(GPIO_SELECT_MASK << PL10_SELECT_CFG1_SHIFT);
	value |= (GPIO_FSEL_OUTPUT << PL10_SELECT_CFG1_SHIFT);
	H3_PIO_PORTL->CFG1 = value;
}

void led2_set(unsigned int state)
{
	if (state) {
		H3_PIO_PORTL->DAT |= 1 << POWER_LED_PIO;
	} else {
		H3_PIO_PORTL->DAT &= ~(1 << POWER_LED_PIO);
	}
}

int notmain(unsigned int sp)
{
	h3_timer_init();

	h3_gpio_fsel(LED1, GPIO_FSEL_OUTPUT);
	led2_init();

	while (1) {
		h3_gpio_set(LED1);
		led2_set(0);
		__msdelay(1000);
		h3_gpio_clr(LED1);
		led2_set(1);
		__msdelay(1000);
	}
	return 0;
}
