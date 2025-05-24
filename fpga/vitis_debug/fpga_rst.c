
#include "xparameters.h"
#include "fpga_rst.h"
#include "xil_io.h"
#include "xuartps.h"
#include "xscugic.h"
#include "sleep.h"


void pl_soft_rst(void)
{
	int reg_value;
	Xil_Out32(SLCR_UNLOCK_ADDR, UNLOCK_KEY);
	Xil_Out32(PL_RST_CTRL_ADDR,PL_RST_MASK);
	usleep(100);
	Xil_Out32(PL_RST_CTRL_ADDR, PL_CLR_MASK);
	Xil_Out32(SLCR_LOCK_ADDR, LOCK_KEY);
	reg_value = Xil_In32(PL_RST_CTRL_ADDR);
	if(reg_value == 0x1)
	{
		xil_printf("not exit rst \r\n");
	}
	else
	{
		xil_printf(" exit rst \r\n");
	}

}

void uart_init(XUartPs * inst_uart_ps_ptr)
{
	XUartPs_Config *uart_cfg;
	uart_cfg = XUartPs_LookupConfig(UART_DEVICE_ID);
	if(NULL == uart_cfg)
	{
		xil_printf("the pointer of uart is null");
		return XST_FAILURE;
	}
	XUartPs_CfgInitialize(inst_uart_ps_ptr, uart_cfg, uart_cfg->BaseAddress);
	XUartPs_SetOperMode(inst_uart_ps_ptr, XUARTPS_OPER_MODE_NORMAL);
	XUartPs_SetFifoThreshold(inst_uart_ps_ptr, 1);
}

void uart_interrupt_handler(void *call_back_ref)
{
	XUartPs *inst_uart_ps_ptr = (XUartPs *)call_back_ref;
	u32 rec_data = 0;
	u32 uart_int_status;
	//�ú������ڶ�ȡ�ж�״̬����
	uart_int_status = XUartPs_ReadReg(inst_uart_ps_ptr->Config.BaseAddress,XUARTPS_IMR_OFFSET);
	//�ú������ڶ�ȡ�ж�״̬
	uart_int_status &= XUartPs_ReadReg(inst_uart_ps_ptr->Config.BaseAddress,XUARTPS_ISR_OFFSET);
	if(uart_int_status & (u32)XUARTPS_IXR_RXOVR)
		{
			rec_data = XUartPs_RecvByte(XPAR_PS7_UART_0_BASEADDR);
		}
	if( rec_data == PL_RST_FLG)
		{
			xil_printf("uart int , rst pl \r\n");
			pl_soft_rst();
		}
}


int uart_interrupt_init(XUartPs * inst_uart_ps_ptr , XScuGic *ptr_scugic)
{
	int status;
	//XScuGic_Connect
	status = XScuGic_Connect(ptr_scugic, UART_INT_IRQ_ID,(Xil_ExceptionHandler)uart_interrupt_handler,(void *) inst_uart_ps_ptr);
	XScuGic_SetPriorityTriggerType(ptr_scugic, UART_INT_IRQ_ID, (u8)0xA1, (u8)0x1);
	XUartPs_SetInterruptMask(inst_uart_ps_ptr, XUARTPS_IXR_RXOVR);
	XScuGic_Enable(ptr_scugic, UART_INT_IRQ_ID);
	return status;
}

void uart_ctrl_init(XUartPs * inst_uart_ps_ptr , XScuGic *ptr_scugic)
{

	uart_init(inst_uart_ps_ptr);
	uart_interrupt_init(inst_uart_ps_ptr,ptr_scugic);
	xil_printf("uart ctrl init done \r\n");
}
