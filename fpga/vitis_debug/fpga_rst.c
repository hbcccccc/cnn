
#include "xparameters.h"
#include "fpga_rst.h"
#include "xil_io.h"
#include "xuartps.h"
#include "xscugic.h"
#include "sleep.h"
#define CNN_AXI_BASE_ADDR 0x40000000
#define OVA_INT_IRQ_ID XPAR_FABRIC_CNN_TOP_WRAPPER_0_O_INTERRUPT_INTR

typedef struct {
	XUartPs *uart_ptr;
	XScuGic *scugic_ptr;
} Uart_scugic_stru;

void pl_soft_rst(void)
{

	//XScuGic_Disable(ptr_scugic, OVA_INT_IRQ_ID);
	int reg_value;
	Xil_Out32(SLCR_UNLOCK_ADDR, UNLOCK_KEY);
	Xil_Out32(PL_RST_CTRL_ADDR,PL_RST_MASK);
	usleep(1);
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

	//XScuGic_Enable(ptr_scugic, OVA_INT_IRQ_ID);
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
	//XUartPs *inst_uart_ps_ptr = (XUartPs *)call_back_ref;
	Uart_scugic_stru *inst_uart_scugic_struct_ptr = (Uart_scugic_stru *)call_back_ref;
	XUartPs *inst_uart_ps_ptr = inst_uart_scugic_struct_ptr->uart_ptr;
	XScuGic *inst_xscugic_ptr = inst_uart_scugic_struct_ptr->scugic_ptr;

	XScuGic_Disable(inst_xscugic_ptr, OVA_INT_IRQ_ID);
	XScuGic_Disable(inst_xscugic_ptr, UART_INT_IRQ_ID);
	u32 rec_data = 0;
	u32 uart_int_status;
	//该函数用于读取中断状态掩码
	uart_int_status = XUartPs_ReadReg(inst_uart_ps_ptr->Config.BaseAddress,XUARTPS_IMR_OFFSET);
	//该函数用于读取中断状态
	uart_int_status &= XUartPs_ReadReg(inst_uart_ps_ptr->Config.BaseAddress,XUARTPS_ISR_OFFSET);
	if(uart_int_status & (u32)XUARTPS_IXR_RXOVR)
		{
			rec_data = XUartPs_RecvByte(XPAR_PS7_UART_0_BASEADDR);
		}
	if( rec_data == PL_RST_FLG)
		{
			xil_printf("uart int , rst pl \r\n");
			XUartPs_WriteReg(inst_uart_ps_ptr->Config.BaseAddress,XUARTPS_ISR_OFFSET,XUARTPS_IXR_RXOVR);
			pl_soft_rst();
			 volatile uint32_t *addr = (uint32_t *)CNN_AXI_BASE_ADDR;
			 *addr = 0xFFFFFFFF;
			XScuGic_Enable(inst_xscugic_ptr, OVA_INT_IRQ_ID);
			XScuGic_Enable(inst_xscugic_ptr, UART_INT_IRQ_ID);
		}

}


int uart_interrupt_init(XUartPs * inst_uart_ps_ptr , XScuGic *ptr_scugic)
{
	int status;
	//XScuGic_Connect
	Uart_scugic_stru *inst_uart_scugic_struct_ptr;
	inst_uart_scugic_struct_ptr->scugic_ptr = ptr_scugic;
	inst_uart_scugic_struct_ptr->uart_ptr = inst_uart_ps_ptr;

	status = XScuGic_Connect(ptr_scugic, UART_INT_IRQ_ID,(Xil_ExceptionHandler)uart_interrupt_handler,(void *) inst_uart_scugic_struct_ptr);
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
