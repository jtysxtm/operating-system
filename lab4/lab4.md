# 练习

 对实验报告的要求：

- 基于markdown格式来完成，以文本方式为主
- 填写各个基本练习中要求完成的报告内容
- 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
- 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

## 练习0：填写已有实验

本实验依赖实验2/3。请把你做的实验2/3的代码填入本实验中代码中有“LAB2”,“LAB3”的注释相应部分。

## 练习1：分配并初始化一个进程控制块（需要编码）

alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

- 【提示】在alloc_proc函数的实现中，需要初始化的proc_struct结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明proc_struct中struct context context和struct trapframe *tf成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

```cpp
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
        proc->state = PROC_UNINIT;                      //状态为未初始化
        proc->pid = -1;                                 //pid为未赋值
        proc->runs = 0;                                 //运行时间为0
        proc->kstack = 0;                               //除了idleproc其他线程的内核栈都要后续分配
        proc->need_resched = 0;                         //不需要调度切换线程
        proc->parent = NULL;                            //没有父线程
        proc->mm = NULL;                                //未分配内存
        memset(&(proc->context), 0, sizeof(struct context));//将上下文变量全部赋值为0，清空
        proc->tf = NULL;                                //初始化没有中断帧
        proc->cr3 = boot_cr3;                           //内核线程的cr3为boot_cr3，即页目录为内核页目录表
        proc->flags = 0;                                //标志位为0
        memset(proc->name, 0, PROC_NAME_LEN+1);         //将线程名变量全部赋值为0，清空
    }
    return proc;
}
```

`alloc_proc()`负责分配创建一个 `proc_struct`并对其进行基本初始化，仅起到了创建进程块实例的作用，没有创建内核线程本身。

```cpp
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    tf.gpr.s0 = (uintptr_t)fn;      //函数入口
    tf.gpr.s1 = (uintptr_t)arg;     //函数参数
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
    tf.epc = (uintptr_t)kernel_thread_entry;    //epc指向kernel_thread_entry，即执行s0指向的函数
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    //内核栈上分配一块空间保存tf
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
    *(proc->tf) = *tf;
    proc->tf->gpr.a0 = 0;               //a0设置为0表示为子进程
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;//esp非空则设置tf栈指针为esp,否则指向自己
    proc->context.ra = (uintptr_t)forkret;//上下文的ra设置为forkret入口
    proc->context.sp = (uintptr_t)(proc->tf);//上下文的栈顶放置tf
}
```

在 `kernel_thread()`和 `copy_thread()`中我们可以观察到函数对tf和context的操作。作为proc_struct结构体的组成，context保存了前一个进程的上下文信息，即被调用者保存寄存器的值，这使得uCore能够在内核态中也实现上下文切换与进程调度；tf是指向中断帧的指针，当进程从用户空间跳转到内核空间以及在内核态创建新线程时都需要通过记录了中断前状态的中断帧来恢复各寄存器的值，从而使进程能够继续执行。

## 练习2：为新创建的内核线程分配资源（需要编码）

创建一个内核线程需要分配和设置好很多资源。

kernel_thread函数通过调用**do_fork**函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们**实际需要"fork"的东西就是stack和trapframe**。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：

- 调用alloc_proc，首先获得一块用户信息块。
- 为进程分配一个内核栈。
- 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
- 复制原进程上下文到新进程
- 将新进程添加到进程列表
- 唤醒新进程
- 返回新进程号

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

### do_fork函数实现过程

```c
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;

    // 检查当前进程数量是否超过最大进程数量限制
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;//跳转到fork_out
    }

    ret = -E_NO_MEM;//在发生内存分配失败时可以返回适当的错误码

    // 分配一个进程控制块
    proc = alloc_proc();
    if(proc==NULL)//分配失败
        goto fork_out;  

    // 设置当前进程为新进程的父进程
    proc->parent = current;

    // 为新进程分配内核栈
    if(setup_kstack(proc))
        goto bad_fork_cleanup_kstack;//跳转进行清理

    //复 制进程的内存布局信息，以确保新进程拥有与原进程相同的内存环境
    if(copy_mm(clone_flags,proc))
        goto bad_fork_cleanup_proc;//失败则进行清理
  
    // 复制原进程的上下文到新进程
    copy_thread(proc, stack, tf);

    // 为新进程分配一个唯一的进程号
    proc->pid = get_pid();

    // 将新进程添加到进程列表
    hash_proc(proc);
    list_add(&proc_list,&(proc->list_link));
    nr_process ++;//更新进程数量计数器

    // 唤醒新进程，进入可调度状态
    wakeup_proc(proc);
  
    // 返回新进程号pid
    ret = proc->pid;

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```

do_fork函数的实现流程如下：

1. 检查当前进程数量是否已经达到最大限制（MAX_PROCESS），如果超过则直接跳转到fork_out标签处，返回-E_NO_FREE_PROC。
2. 设置返回值为-E_NO_MEM，以便在发生内存分配失败时可以返回适当的错误码。
3. 调用alloc_proc函数来分配一个进程控制块（proc_struct），并将返回的指针保存在proc变量中。如果分配失败，则直接跳转到fork_out标签处，返回-E_NO_MEM。
4. 将新进程的父进程指针指向当前进程。
5. 调用setup_kstack函数为新进程分配内核栈空间，如果失败则跳转到bad_fork_cleanup_kstack标签处进行清理工作。
6. 调用copy_mm函数复制原进程的内存管理信息到新进程，这一步骤是复制进程的内存布局信息，以确保新进程拥有与原进程相同的内存环境。如果失败，则跳转到bad_fork_cleanup_proc标签处进行清理工作。
7. 调用copy_thread函数复制原进程的上下文到新进程，包括栈和 trapframe。
8. 为新进程分配一个唯一的进程号（pid），调用get_pid函数实现此目的。
9. 将新进程添加到进程列表，并更新进程数量计数器。
10. 唤醒新进程，使其进入可调度状态。
11. 返回新进程的pid作为函数的返回值。
12. 通过调用get_pid()函数为新进程分配一个唯一的pid。该函数实现了一个简单的计数器，并通过自增操作返回一个唯一的值作为pid。

基于上述代码可知，ucore在每次创建新的内核线程时候，都会通过调用get_pid函数为新进程分配了一个唯一的pid，并将其赋值给新进程的proc->pid字段，以保证每个新fork的线程具有唯一的pid。

## 练习3：编写proc_run 函数（需要编码）

proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：

- 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
- 禁用中断。你可以使用 `/kern/sync/sync.h`中定义好的宏 `local_intr_save(x)`和 `local_intr_restore(x)`来实现关、开中断。
- 切换当前进程为要运行的进程。
- 切换页表，以便使用新进程的地址空间。`/libs/riscv.h`中提供了 `lcr3(unsigned int cr3)`函数，可实现修改CR3寄存器值的功能。
- 实现上下文切换。`/kern/process`中已经预先编写好了 `switch.S`，其中定义了 `switch_to()`函数。可实现两个进程的context切换。
- 允许中断。

请回答如下问题：

- 在本实验的执行过程中，创建且运行了几个内核线程？

完成代码编写后，编译并运行代码：make qemu

如果可以得到如 附录A所示的显示内容（仅供参考，不是标准答案输出），则基本正确。

## 扩展练习 Challenge：

- 说明语句 `local_intr_save(intr_flag);....local_intr_restore(intr_flag);`是如何实现开关中断的？
