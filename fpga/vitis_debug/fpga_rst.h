#include "xuartps.h"
#include "xscugic.h"

#define SLCR_UNLOCK_ADDR 0xF8000008
#define SLCR_LOCK_ADDR   0xF8000004
#define PL_RST_CTRL_ADDR 0xF8000240
#define UNLOCK_KEY	     0xDF0D
#define LOCK_KEY         0x767B
#define PL_RST_MASK      0x01
#define PL_CLR_MASK      0x00


#define UART_DEVICE_ID XPAR_PS7_UART_0_DEVICE_ID
#define UART_INT_IRQ_ID XPAR_XUARTPS_0_INTR
#define PL_RST_FLG 0x0A

void pl_soft_rst(void);
void uart_init(XUartPs * inst_uart_ps_ptr);
void uart_interrupt_handler(void *call_back_ref);
int uart_interrupt_init(XUartPs * inst_uart_ps_ptr , XScuGic *ptr_scugic);
void uart_ctrl_init();
