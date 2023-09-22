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

- ``la sp, bootstacktop``

`la`即'load address'，该指令对isp寄存器，即栈指针寄存器存入约定好的bootstacktop标签的地址0x80204000（kernel.sym)，（从标签名字中）可以确定bootstacktop为声明的栈顶的标签，因此该指令的目的是将栈指针初始化为内核栈顶的地址，以便为操作系统内核提供一个可用的栈空间。

- ``tail kern_init``

`tail`即'tail call'尾调用的缩写，作为RISC-V的一条伪指令，作用类似于函数调用。其扩展指令为 `auipc x6, offsetHi`和 `jalr x0, offsetLo(x6)`，对比call指令的扩展指令可以发现，tail不为 `x1`寄存器也即返回地址寄存器存入值。该条指令执行跳转kern_init标签，且不建立新的栈帧以优化结构提高效率，启动操作系统内核的初始化过程，进行必要的设置和准备工作，如初始化各种数据结构、创建进程、加载设备驱动程序等。

## 练习2：完善中断处理

- 时钟中断处理的实现

[这里插图]


- 实现过程 
```c
volatile size_t num=0;

static void print_ticks() {
    cprintf("%d ticks\n", TICK_NUM);
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
        ......
        case IRQ_S_TIMER:
            clock_set_next_event();
            ticks++;
            if(ticks==100)
            {
                print_ticks();
                ticks=0;
                num++;
            }
            if(num==10)
            {
                sbi_shutdown();
            }
            break;
        ......
    }
}
```
定义`num`辅助记录打印次数，调用`clock_set_next_event()`设置下次始终中断，计数器`ticks`累加记录中断次数。当操作系统每遇到100次时钟中断后，调用`print_ticks()`，于控制台打印`100 ticks`，同时打印次数`num`累加，当打印完10行后，调用sbi.h中的`shut_down()`函数关机。

- 定时器中断处理流程

OpenSBI提供的`sbi_set_timer()`接口，仅可以传入一个时刻，让它在那个时刻触发一次时钟中断。因此无法一次设置多个中断事件发生。于是选择初始只设置一个时钟中断，之后每次发生时钟中断时，设置下一次时钟中断的发生。

```c
// Hardcode timebase
static uint64_t timebase = 100000;

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    // timebase = sbi_timebase() / 500;
    clock_set_next_event();

    // initialize time counter 'ticks' to zero
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
```

`SIE`（Supervisor Interrupt Enable，监管者中断使能）用于控制和管理处理器的中断使能状态。因此在初始化clock时，需要先开启时钟中断的使能。接着调用`clock_set_next_event(void)`设置时钟中断事件，使用`sbi_set_timer()`接口，将timer的数值变为`当前时间 + timebase`，即设置下次时钟中断的发生时间。

回看时钟中断处理流程：每秒发生100次时钟中断，触发每次时钟中断后设置10ms后触发下一次时钟中断，每触发100次时钟中断（1秒钟）输出`100 ticks`到控制台。
