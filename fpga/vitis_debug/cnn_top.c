#include "xparameters.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "xplatform_info.h"
#include <xil_printf.h>
#include "sleep.h"
#include "fpga_rst.h"



#define INTC_DEVICE_ID XPAR_SCUGIC_SINGLE_DEVICE_ID
//自己的PL中断号，导进去可以发现中断号确实是61
#define OVA_INT_IRQ_ID XPAR_FABRIC_CNN_TOP_WRAPPER_0_O_INTERRUPT_INTR
#define CNN_AXI_BASE_ADDR 0x40000000
#define INTC_TYPE_RISING_EDGE 0x03
#define INTC_TYPE_HIGH_LEVEL XSCU

XScuGic inst_scugic;
XUartPs inst_uart;

int i = 0;

void ova_int_handler(void *call_back_ref){
	 volatile uint32_t *addr = (uint32_t *)CNN_AXI_BASE_ADDR;
	 i++;
	 xil_printf("%d \r\n",i);
	 //int int_status;
	 //xil_printf("interrupt status is %h",1);
	 //int_status = *addr ;
	 //xil_printf("interrupt status is %h",int_status);
	 *addr = 0xFFFFFFFF;

}

int int_init(XScuGic *ptr_scugic){
	int status;
	u8 int_priority;
	u8 int_trigger;
	XScuGic_Config *ptr_scugic_cfg_inst;
	Xil_ExceptionEnable();
	ptr_scugic_cfg_inst = XScuGic_LookupConfig(INTC_DEVICE_ID);
	status = XScuGic_CfgInitialize(ptr_scugic, ptr_scugic_cfg_inst, ptr_scugic_cfg_inst->CpuBaseAddress);
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler,ptr_scugic);
	status = XScuGic_Connect(ptr_scugic, OVA_INT_IRQ_ID, (Xil_ExceptionHandler)ova_int_handler, 1);
	XScuGic_SetPriorityTriggerType(ptr_scugic, OVA_INT_IRQ_ID, (u8)0xA0, (u8)0x1);
	XScuGic_GetPriorityTriggerType(ptr_scugic, OVA_INT_IRQ_ID,&int_priority ,&int_trigger);

	uart_ctrl_init(&inst_uart, ptr_scugic);
	XScuGic_Enable(ptr_scugic, OVA_INT_IRQ_ID);
	return XST_SUCCESS;
}

int main(void)
{
	 xil_printf("My cnn test \r\n");
	 int status = int_init(&inst_scugic);
while(1)
	 {

	 }
}

