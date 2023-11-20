#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        //read_csr(sstatus)读取控制寄存器sstatus位与操作检查其中的SIE位
        //如果SIE位为1，表示中断允许
        intr_disable();//关闭中断
        return 1;//保存中断状态
    }
    return 0;//中断禁止，中断状态未被保存
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();//开启中断
    }
}

#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \ //保存当前的中断状态，并将其赋值给变量x
    } while (0)
#define local_intr_restore(x) __intr_restore(x); //恢复之前保存的中断状态

#endif /* !__KERN_SYNC_SYNC_H__ */
