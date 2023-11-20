#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { 
    //将SSTATUS寄存器的SIE位设置为1，以允许中断触发和响应。
    set_csr(sstatus, SSTATUS_SIE); 
}

/* intr_disable - disable irq interrupt */
void intr_disable(void) { 
    //将SSTATUS寄存器的SIE位清除为0，以禁止中断触发和响应。
    clear_csr(sstatus, SSTATUS_SIE); 
}
