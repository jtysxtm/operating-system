# lab 0.5

## 练习1 使用GDB验证启动流程

总的来说，qemu模拟rics-v的启动流程：

1. 上电、将必要文件加载到物理内存后，处理器的复位地址被初始化为0x1000，risc-v硬件加点后的几条指令即存储在该地址之后，该地址负责将PC跳转到0x80000000以加载Bootloader：
   该过程的汇编指令是

   ```
   0x1000:	auipc	t0,0x0 
   0x1004:	addi	a1,t0,32
   0x1008:	csrr	a0,mhartid
   0x100c:	ld	t0,24(t0)
   0x1010:	jr	t0
   0x1014:	unimp
   0x1016:	unimp
   0x1018:	unimp
   0x101a:	0x8000
   0x101c:	unimp
   ```

   在qemu的源代码文件virt.c中找到存储了对应十六进制代码的片段

   ```assembly
   /* reset vector */
       uint32_t reset_vec[8] = {
           0x00000297,                  /* 1:  auipc  t0, %pcrel_hi(dtb) */
           0x02028593,                  /*     addi   a1, t0, %pcrel_lo(1b) */
           0xf1402573,                  /*     csrr   a0, mhartid  */
   #if defined(TARGET_RISCV32)
           0x0182a283,                  /*     lw     t0, 24(t0) */
   #elif defined(TARGET_RISCV64)
           0x0182b283,                  /*     ld     t0, 24(t0) */
   #endif
           0x00028067,                  /*     jr     t0 */
           0x00000000,
           memmap[VIRT_DRAM].base,      /* start: .dword memmap[VIRT_DRAM].base */
           0x00000000,
                                        /* dtb: */
       };
   ```

   可以推测，`memmap[VIRT_DRAM].base`的值即为Bootloader的起始地址0x80000000。
2. 

# lab 1

## 练习1：理解内核启动中的程序入口操作

``la sp, bootstacktop``

`la`即'load address'，该指令对isp寄存器，即栈指针寄存器存入约定好的bootstacktop标签的地址0x80204000（kernel.sym)，（从标签名字中）可以确定bootstacktop为声明的栈顶的标签，因此该指令是初始化栈的部分操作。

``tail kern_init``

`tail`即'tail call'尾调用的缩写，作为RISC-V的一条伪指令，作用类似于函数调用。其扩展指令为 `auipc x6, offsetHi`和 `jalr x0, offsetLo(x6)`，对比call指令的扩展指令可以发现，tail不为 `x1`寄存器也即返回地址寄存器存入值。该条指令执行跳转kern_init标签，且不建立新的栈帧以优化结构提高效率。

## 练习2：完善中断处理
