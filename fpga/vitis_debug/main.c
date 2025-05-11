#include "xparameters.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "xplatform_info.h"
#include <xil_printf.h>
#include "sleep.h"

#define SLCR_UNLOCK_ADDR 0xF8000008
#define SLCR_LOCK_ADDR   0xF8000004
#define PL_RST_CTRL_ADDR 0xF8000240
#define UNLOCK_KEY	     0xDF0D
#define LOCK_KEY         0x767B
#define PL_RST_MASK      0x01
#define PL_CLR_MASK      0x00


#define INTC_DEVICE_ID XPAR_SCUGIC_SINGLE_DEVICE_ID
//自己的PL中断号，导进去可以发现中断号确实是61
#define OVA_INT_IRQ_ID XPAR_FABRIC_CNN_TOP_WRAPPER_0_O_INTERRUPT_INTR
#define CNN_AXI_BASE_ADDR 0x40000000
#define INTC_TYPE_RISING_EDGE 0x03
#define INTC_TYPE_HIGH_LEVEL XSCU

XScuGic inst_scugic;

void pl_soft_rst(void)
{
	Xil_Out32(SLCR_UNLOCK_ADDR, UNLOCK_KEY);
	Xil_Out32(PL_RST_CTRL_ADDR,PL_RST_MASK);
	Xil_Out32(PL_RST_CTRL_ADDR, PL_CLR_MASK);
	Xil_Out32(SLCR_LOCK_ADDR, LOCK_KEY);
}


void ova_int_handler(void *call_back_ref){
	 volatile uint32_t *addr = (uint32_t *)CNN_AXI_BASE_ADDR;
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
	xil_printf("interrupt priority is %d,trigger is %d",int_priority,int_trigger);
	xil_printf("interrupt init done");
	XScuGic_Enable(ptr_scugic, OVA_INT_IRQ_ID);
	XScuGic_SelfTest(ptr_scugic);
	return status;
}

int main(void)
{
	 xil_printf("My cnn test \r\n");
	 //pl_soft_rst();
	 int status;
	 status = int_init(&inst_scugic);
		if(status != XST_SUCCESS)
		{
			xil_printf("interrupt init error");
		}
 	 volatile uint32_t *addr = (uint32_t *)CNN_AXI_BASE_ADDR;
 	 uint32_t data = 0x09;
	 // 在 main() 中打印中断状态
while(1)
	 {

	 }
}

