# 练习

 对实验报告的要求：

- 基于markdown格式来完成，以文本方式为主
- 填写各个基本练习中要求完成的报告内容
- 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
- 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

## 练习0：填写已有实验

本实验依赖实验2/3/4。请把你做的实验2/3/4的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”的注释相应部分。注意：为了能够正确执行lab5的测试应用程序，可能需对已完成的实验2/3/4的代码进行进一步改进。

## 练习1: 加载应用程序并执行（需要编码）

do_execv函数调用load_icode（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序。你需要补充load_icode的第6步，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好proc_struct结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。

请在实验报告中简要说明你的设计实现过程。

- 请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

### 设计实现

这一部分的代码实际上是构造一个中断返回环境，以便中断处理完成后能够切换到需要执行的程序入口。

```
tf->gpr.sp = USTACKTOP;// 设置用户进程的栈指针为用户栈的顶部.当进程从内核态切换到用户态时，栈指针需要指向用户栈的有效地址
    tf->epc = elf->e_entry; //修改epc，指向程序内存入口
    // 进程从内核态切换到用户态，需要将中断帧的状态调整为用户态，清除了 SPP 表示的特权级信息，以及 SPIE 表示的中断使能信息。
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);// 将 sstatus 寄存器中的 SPP和 SPIE位清零
```

### 执行经过

* 用户态进程被ucore选择占用CPU执行后，用户态进程调用exec系统调用，进入正常中断处理流程，控制权最终转移到syscall.c中的syscall，根据IDT传递给sys_exec函数，调用proc.c中的do_execve函数完成进程的加载。
* do_execve负责回收进程自身所占用的空间，换用kernel的PDT，之后调用load_icode函数，用新的程序覆盖内存空间，形成一个执行新程序的新进程，同时设置好当前系统调用的中断帧，使得中断返回后能够以用户态权限跳转到新的进程的入口处执行。
* 中断返回处理，epc指向程序内存入口，同时SPP清0，因此trapentry.S中的处理部分就会将堆栈切换回用户进程的栈同时完成特权级的切换，跳转到程序入口，开始执行第一条指令。


## 练习2: 父进程复制自己的内存空间给子进程（需要编码）

创建子进程的函数do_fork在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过copy_range函数（位于kern/mm/pmm.c中）实现的，请补充copy_range的实现，确保能够正确执行。

请在实验报告中简要说明你的设计实现过程。

```c
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end,
               bool share) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);// 页对齐
    assert(USER_ACCESS(start, end));// 用户地址合法，在用户空间
    // copy content by page unit.
    do {// 遍历起始地址到结束
        // call get_pte to find process A's pte according to the addr start
        // 调用 get_pte 函数获取源进程 from 中地址 start 对应的页表项指针 ptep
        // 如果页表项不存在，则将 start 向上取整到下一个页的起始地址。
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        // call get_pte to find process B's pte according to the addr start. If
        // pte is NULL, just alloc a PT
        if (*ptep & PTE_V) {//页表项是否有效（存在）
            if ((nptep = get_pte(to, start, 1)) == NULL) {
                return -E_NO_MEM;
            }
            // 获取源进程 A 中页表项的权限信息
            uint32_t perm = (*ptep & PTE_USER);
            // get page from ptep
            // 将源进程 A 中的页表项转换成页结构体 page
            struct Page *page = pte2page(*ptep);
            // alloc a page for process B
            // 在目标进程 B 中分配一个新的页结构体 npage
            struct Page *npage = alloc_page();

            assert(page != NULL);
            assert(npage != NULL);
            int ret = 0;
            /* LAB5:EXERCISE2 YOUR CODE
             * replicate content of page to npage, build the map of phy addr of
             * nage with the linear addr start
             *
             * Some Useful MACROs and DEFINEs, you can use them in below
             * implementation.
             * MACROs or Functions:
             *    page2kva(struct Page *page): return the kernel vritual addr of
             * memory which page managed (SEE pmm.h)
             *    page_insert: build the map of phy addr of an Page with the
             * linear addr la
             *    memcpy: typical memory copy function
             *
             * (1) find src_kvaddr: the kernel virtual address of page
             * (2) find dst_kvaddr: the kernel virtual address of npage
             * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
             * (4) build the map of phy addr of  nage with the linear addr start
             */
            // 复制页面内容，并建立目标进程 B 的物理地址与线性地址的映射关系
            void* src_kvaddr = page2kva(page); // 源页的内核虚拟地址
            void* dst_kvaddr = page2kva(npage); // 目标页的内核虚拟地址
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE); // 复制页面内容
            // 将目标进程 B 中的页表项和页结构体建立映射关系
            ret = page_insert(to, npage, start, perm);
            // 断言映射建立成功
            assert(ret == 0);
        }
        start += PGSIZE;// 移动到下一页继续复制下一页内容
    } while (start != 0 && start < end);
    return 0;//完成所有页面复制
}
```

`copy_range` 函数实现了将一个进程 A 的地址空间的内存内容从地址 start 到 end 复制到另一个进程 B 的地址空间的功能。

* 确保页对其和用户地址合法的情况下，遍历源进程A 的地址范围
* 获取源进程 A 中地址 start 对应的页表项指针 ptep和目标进程 B 中地址 start 对应的页表项指针 nptep

* 获取页表项权限，分配页结构体，获取内核虚拟地址，复制页面内容

* 将目标进程B 中的页表项和页结构体建立映射关系
* 继续复制后续页面内容直到完成所有页面复制

### 如何设计实现Copy on Write机制？给出概要设计，鼓励给出详细设计。

  Copy-on-write（简称COW）的基本概念是指如果有多个使用者对一个资源A（比如内存块）进行读操作，则每个使用者只需获得一个指向同一个资源A的指针，就可以该资源了。若某使用者需要对这个资源A进行写操作，系统会对该资源进行拷贝操作，从而使得该“写操作”使用者获得一个该资源A的“私有”拷贝—资源B，可对资源B进行写操作。该“写操作”使用者对资源B的改变对于其他的使用者而言是不可见的，因为其他使用者看到的还是资源A。

因此对应的修改主要集中在

* do_fork时不对内存进行复制操作
* 在内存页出现访问异常的之后再对共享的内存页进行复制，再在新的内存页上进行修改操作。
* 具体实现：
  * 在do_fork部分的内存复制时，不对内存进行复制，而是将两个进程的内存页映射到同一个物理页，在各自的虚拟页上标记该页为不可写，同时设置一个额外的标记位为共享位，表示该页和某些虚拟页共享了一个物理页，当发生修改异常时，进行对应的处理；
  * 在page_fault部分对是否是由于写共享页引起的异常增加一个判断，是的话再申请一个物理页来将共享页复制一份，交给出错的进程进行处理，将其原本映射关系改成新的物理页，设置该虚拟页为非共享、可写。对原物理页关联的所有虚拟页，如果其不再被其他进程共享，修改其标志位为非共享、可写。

## 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）

请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：

- 请分析fork/exec/wait/exit的执行流程。重点关注哪些操作是在用户态完成，哪些是在内核态完成？内核态与用户态程序是如何交错执行的？内核态执行结果是如何返回给用户程序的？
- 请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）

执行：make grade。如果所显示的应用程序检测都输出ok，则基本正确。（使用的是qemu-1.0.1）

### 分析执行流程

* fork函数主要负责使用系统调用在当前进程下创建一个子进程，在两个不同进程中根据函数的返回值进行不同的处理。
  在user/libs/ulib.h中，fork函数被定义成对系统调用用户态接口sys_fork（user/libs/syscall.c）的封装，当用户态调用fork函数时，可以认为是执行正常的中断处理流程，最终会将控制权转交给syscall（user/libs/syscall.c），函数内部通过内联汇编，将参数传递后执行ecall，产生trap, 进入内核态进行异常处理，经过trap.c中的exception_handler处理句柄唤起对应的系统调用函数sys_fork(kern/syscall/syscall.c)，之后转发给proc.c的do_fork函数，随之完成对新进程的进程控制块的初始化、内容的设置以及进程列表的更新。
* 当前实验阶段设计中没有出现名为exec()的函数，只在内核中存在名为sys_exec的系统调用，我们猜测如果存在用户态调用的exec()，那么它的执行流程也会和上述fork函数一样，最终在kern/syscall/syscall.c中被分配到sys_exec函数中，并在参数传递完成后调用do_execve函数。
  do_execve函数负责回收进程自身所占用的空间，之后调用load_icode函数，用新的程序覆盖内存空间，形成一个执行新程序的新进程，同时设置好中断帧，使得中断返回后能够跳转到新的进程的入口处执行。
* wait函数主要负责在子进程退出时让父进程完成对进程所占剩余资源的彻底回收。
  在user/libs/ulib.h中，wait函数被定义成对系统调用用户态接口sys_wait（user/libs/syscall.c）的封装，当用户态调用wait函数时，可以认为是执行正常的中断处理流程，最终会将控制权转交给syscall（user/libs/syscall.c），函数内部通过内联汇编，将参数传递后执行ecall，产生trap, 进入内核态进行异常处理，经过trap.c中的exception_handler处理句柄唤起对应的系统调用函数sys_wait(kern/syscall/syscall.c)，之后转发给proc.c中的do_wait函数，开始搜索指定进程是否存在指定的ZOMBIE态子进程（或任意的ZOMBIE态子进程），根据查找结果，找到则直接将其占用的所有剩余资源，如内核栈、进程控制块等全部释放；未找到则将进程状态设置为SLEEPING并设置等待状态为等待子进程、调用调度器切换到别的可执行进程，直至对应的子进程陷入ZOMBIE态唤醒这个父进程。
* exit函数负责在进程自身退出时释放所占用的大部分内存空间，包括内存管理信息如页表等所占空间，同时唤醒父进程完成对自身不能回收的剩余空间的回收，并切换到其他进程。
  在user/libs/ulib.h中，exit函数被定义成对系统调用用户态接口sys_exit（user/libs/syscall.c）的封装，当用户态调用exit函数时，可以认为是执行正常的中断处理流程，最终会将控制权转交给syscall（user/libs/syscall.c），函数内部通过内联汇编，将参数传递后执行ecall，产生trap, 进入内核态进行异常处理，经过trap.c中的exception_handler处理句柄唤起对应的系统调用函数sys_exit(kern/syscall/syscall.c)，之后转发给proc.c中的do_exit函数，释放当前进程的大部分资源，更改该进程状态为ZOMBIE，并在父进程进入wait等待状态时唤醒，调用调度器换出其他进程，等待父进程进一步完成对剩余资源的回收。
* 我们假设exec的执行流程和其他三个函数一致，那么这些函数的调用操作都是在用户态发起的，用户态负责发出中断，传递对应的参数后执行ecall陷入到内核态，之后由内核态负责进行相应的系统调用处理，执行完成后，从do_xxxx函数开始反向将结果传递，trap.c中断处理完成后进入到epc下一条指令执行，同时返回值通过用户态syscall函数中内联汇编定义的返回值保存地址ret最终传递回用户程序。

### 执行状态生命周期图

```
  alloc_proc   
      |   				       + --------- yield/时间片用完 ---------- +
      |  				       |				       |
      V   				       ↓				       |
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- scheduled()调度器调度 --> RUNNING -- exit/kill系统调用 --> PROC_ZOMBIE 
                                               |   				       ↑
                                               |wait				       |
					       |系统调用			       |
					       ↓				       |
					 PROC_SLEEPING --子进程唤醒/exit系统调用 -------+   
```

## 扩展练习 Challenges

### 实现 Copy on Write （COW）机制

给出实现源码,测试用例和设计报告（包括在cow情况下的各种状态转换（类似有限状态自动机）的说明）。

这个扩展练习涉及到本实验和上一个实验“虚拟内存管理”。在ucore操作系统中，当一个用户父进程创建自己的子进程时，父进程会把其申请的用户空间设置为只读，子进程可共享父进程占用的用户内存空间中的页面（这就是一个共享的资源）。当其中任何一个进程修改此用户内存空间中的某页面时，ucore会通过page fault异常获知该操作，并完成拷贝内存页面，使得两个进程都有各自的内存页面。这样一个进程所做的修改不会被另外一个进程可见了。请在ucore中实现这样的COW机制。

由于COW实现比较复杂，容易引入bug，请参考 https://dirtycow.ninja/ 看看能否在ucore的COW实现中模拟这个错误和解决方案。需要有解释。

这是一个big challenge.

### 说明该用户程序是何时被预先加载到内存中的？与我们常用操作系统的加载有何区别，原因是什么？
