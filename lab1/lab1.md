# lab 0.5

## 练习1 使用GDB验证启动流程

总的来说，qemu模拟rics-v的启动流程：

1. 上电、将必要文件加载到物理内存后，处理器的复位地址被初始化为0x1000，risc-v硬件加电后的几条指令即存储在该地址之后，也即0x1000~0x101a附近，这部分负责将PC跳转到0x80000000以加载Bootloader。
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

   可以推测，`memmap[VIRT_DRAM].base`的值即为Bootloader的起始地址 `0x80000000`。

   分析上述指令：

   1. `auipc	t0,0x0`将立即数 `0x0`左移12位后与PC的高20位相加，得到的32位立即数存放在 `t0`中，实际上 `t0`存放的值在执行完后变为 `0x1000`；
   2. `addi	a1,t0,32`将 `a1`存放的值更改为 `0x1020`；
   3. `csrr	a0,mhartid`将 `mhartid`寄存器的值存放到 `a0`中，mhartid为线程的ID，此处为0；
   4. `ld	t0,24(t0)`从 `t0`存放的地址+24后得到的位置加载一个双字的数据到 `t0`中， `0x1018`和 `0x101a`位置组成的双字为 `0x80000000`；
   5. `jr	t0`无条件跳转到 `0x80000000`。
2. 在 `0x80000000`处设置断点，运行到此处，发现接下来的指令为

   ```
   (gdb) x/10i $pc
   => 0x80000000:	csrr	a6,mhartid
      0x80000004:	bgtz	a6,0x80000108
      0x80000008:	auipc	t0,0x0
      0x8000000c:	addi	t0,t0,1032
      0x80000010:	auipc	t1,0x0
      0x80000014:	addi	t1,t1,-16
      0x80000018:	sd	t1,0(t0)
      0x8000001c:	auipc	t0,0x0
      0x80000020:	addi	t0,t0,1020
      0x80000024:	ld	t0,0(t0)
   ```

   我们已经知道此处交由SBI内核控制，所以在SBI源代码处搜索，找到了 `csrr a6,mhartid`对应的位置 `fw_base.S`中的 `_start:`代码块。

   通过阅读代码，在这一过程中主要进行：

   1. 检查mhartid的值判断是否热启动，选择是否跳转；
   2. 保存load address；
   3. 当加载地址load address和链接地址link address不一致时进行重定向和优化；
   4. 对寄存器进行一系列的存值初始化，重置中断，设置trap条件，初始化栈；
   5. 跳转sbi_init()。

   `sbi_init.c`中的 `sbi_init()`选择启动方式为热启动或冷启动，以冷启动为例，进行一系列的处理器、控制台、中断控制器、时钟等组件，之后通过 `sbi_boot_prints()`打印SBI版本等信息，调用 `sbi_hart_pmp_dump()`打印PMP信息，接着执行 `__asm__ __volatile__("mret" : : "r"(a0), "r"(a1));`切换控制流到S-Mode。
3. 接着在gdb中设置断点为kern_entry，输出 `Breakpoint 1 at 0x80200000: file kern/init/entry.S, line 7`，通过查找发现 `0x80200000`即 `kernel.ld`中定义的 `BASE_ADDRESS`。

# lab 1

## 练习1：理解内核启动中的程序入口操作

- ``la sp, bootstacktop``

`la`即'load address'，该指令对isp寄存器，即栈指针寄存器存入约定好的bootstacktop标签的地址0x80204000（kernel.sym)，（从标签名字中）可以确定bootstacktop为声明的栈顶的标签，因此该指令的目的是将栈指针初始化为内核栈顶的地址，以便为操作系统内核提供一个可用的栈空间。

- ``tail kern_init``

`tail`即'tail call'尾调用的缩写，作为RISC-V的一条伪指令，作用类似于函数调用。其扩展指令为 `auipc x6, offsetHi`和 `jalr x0, offsetLo(x6)`，对比call指令的扩展指令可以发现，tail不为 `x1`寄存器也即返回地址寄存器存入值。该条指令执行跳转kern_init标签，且不建立新的栈帧以优化结构提高效率，启动操作系统内核的初始化过程，进行必要的设置和准备工作，如初始化各种数据结构、创建进程、加载设备驱动程序等。

## 练习2：完善中断处理

- 时钟中断处理的实现

  ![结果1](https://github.com/jtysxtm/operating-system/blob/main/lab1/image/lab1/1695360539860.png)

  ![结果2](https://github.com/jtysxtm/operating-system/blob/main/lab1/image/lab1/1695360932714.png)
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
            if(ticks==TICK_NUM)
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

定义 `num`辅助记录打印次数，调用 `clock_set_next_event()`设置下次始终中断，计数器 `ticks`累加记录中断次数。当操作系统每遇到100次时钟中断后，调用 `print_ticks()`，于控制台打印 `100 ticks`，同时打印次数 `num`累加，当打印完10行后，调用sbi.h中的 `shut_down()`函数关机。

- 定时器中断处理流程

OpenSBI提供的 `sbi_set_timer()`接口，仅可以传入一个时刻，让它在那个时刻触发一次时钟中断。因此无法一次设置多个中断事件发生。于是选择初始只设置一个时钟中断，之后每次发生时钟中断时，设置下一次时钟中断的发生。

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

`SIE`（Supervisor Interrupt Enable，监管者中断使能）用于控制和管理处理器的中断使能状态。因此在初始化clock时，需要先开启时钟中断的使能。接着调用 `clock_set_next_event(void)`设置时钟中断事件，使用 `sbi_set_timer()`接口，将timer的数值变为 `当前时间 + timebase`，即设置下次时钟中断的发生时间。

回看时钟中断处理流程：每秒发生100次时钟中断，触发每次时钟中断后设置10ms后触发下一次时钟中断，每触发100次时钟中断（1秒钟）输出 `100 ticks`到控制台。

## 扩展练习 Challenge1：描述与理解中断流程

### 描述ucore中处理中断异常的流程

处理中断异常的流程大致可概括如下：

- 中断异常产生

  - 当 CPU 执行指令时，如果发生错误或者遇到需要处理的事件，将引发异常或中断。
  - 中断分为异常（Exception，包括：访问无效内存地址、执行非法指令(除零)、发生缺页等），陷入（Trap，常见的形式有通过ecall进行系统调用(syscall)，或通过ebreak进入断点(breakpoint)），外部中断（Interrupt，典型的有定时器倒计时结束、串口收到数据等）。
- 寻找中断入口，保存上下文

  - 默认情况下,不论处在什么权限模式，控制权都会被移交到 M 模式的异常处理程序。M 模式的异常处理程序可以将异常重新导向 S 模式，也支持通过异常委托机制（Machine Interrupt Delegation,机器中断委托）选择性地将中断和同步异常直接交给 S 模式处理,而完全绕过 M 模式。当触发中断进入 S 态进行处理时，`sepc`、`scause`、`stval`等寄存器会被硬件自动设置，将一些信息提供给中断处理程序
  - 产生中断后，操作系统会根据 `stvex`（中断向量表基址）把不同种类的中断映射到对应的中断处理程序。如果只有一个中断处理程序，那么可以让 `stvec`直接指向那个中断处理程序的地址。
  - 找到中断入口点后，`SAVE_ALL`保存上下文信息（包括程序计数器 PC、各种寄存器等）到内核栈上，并将上下文包装成结构体送入对应的中断处理程序。
- 中断处理

  - 对中断进行初始化，通过 `sscratch`判断是内核态产生的中断还是用户态产生的中断。
  - 根据 `scause`把中断处理、异常处理的工作分发给interrupt_handler()，exception_handler(), 这些函数再根据中断或异常的不同类型来处理。
- 恢复上下文

  - 当中断处理程序执行完后，ucore 会将保存在内核栈上的上下文信息恢复回来，并使用 `sret`等特权指令返回到原始的程序执行点继续执行。
- 继续执行

  - CPU 从恢复现场之后的指令开始继续执行。如果异常处理程序成功地修复了问题，那么程序可以继续向下执行；否则，如果问题无法解决或者需要等待后续事件，则 CPU 可能会再次引起异常或中断，并重新执行上述流程。

### mov a0，sp的目的

```
    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL

    move  a0, sp
    jal trap
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    # return from supervisor call
    sret
```

`mov a0, sp` 的目的是将栈指针（stack pointer，sp 寄存器）的值保存到寄存器 a0 中，然后将寄存器 a0 的值作为参数传递给接下来调用的函数 trap,以此使中断处理程序获得当前的上下文信息，实现对异常或中断的处理，并在处理完成后通过 `restore_all` 恢复上下文信息，并执行 `sret` 指令返回到之前的执行状态。

### SAVE_ALL中寄存器保存在栈中的位置

### 对于任何中断，__alltraps 中都需要保存所有寄存器吗？请说明理由。

## 扩展练习Challenge3：完善异常中断

直接在 `kern_init()`函数内部添加汇编代码，分别调用ebreak和mert指令尝试产生中断。在 `trap.c`的 `exception_handler()`内部分别添加完打印语句后，尝试编译链接，打开kernel.asm的对应片段

```
    asm volatile("mret"); //  插入无效指令
    80200050:	30200073          	mret
    asm volatile("ebreak"); // 插入断点指令
    80200054:	9002                	ebreak
```

可以看到，mret指令对应4个字节，而ebreak只有2个字节，查阅参考资料发现，实际上此时ebreak设置环境断点调用的是16位的指令c.ebreak，而不是32位的break。因此在对应的打印语句后，应该分别更新epc为 `+4`和 `+2`：

```c
        case CAUSE_ILLEGAL_INSTRUCTION:
            cprintf("Exception type:Illegal instruction\n");
            cprintf("Illegal instruction caught at 0x%p\n",tf->epc);
            tf->epc+=4;
            break;
        case CAUSE_BREAKPOINT:
            cprintf("Exception type:breakpoint\n");
            cprintf("breakpoint caught at 0x%p\n",tf->epc);
            tf->epc+=2;
            break;
```

`make qemu`后打印语句

```c
sbi_emulate_csr_read: hartid0: invalid csr_num=0x302
Exception type:Illegal instruction
Illegal instruction caught at 0x0x80200050
Exception type:breakpoint
breakpoint caught at 0x0x80200054
```

之后能够正常打印十次 `100ticks`并退出。
