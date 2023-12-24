#### 练习0：填写已有实验

本实验依赖实验2/3/4/5/6/7。请把你做的实验2/3/4/5/6/7的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”/“LAB5”/“LAB6” /“LAB7”的注释相应部分。并确保编译通过。注意：为了能够正确执行lab8的测试应用程序，可能需对已完成的实验2/3/4/5/6/7的代码进行进一步改进。

#### 练习1: 完成读文件操作的实现（需要编码）

首先了解打开文件的处理流程，然后参考本实验后续的文件读写操作的过程分析，填写在 kern/fs/sfs/sfs_inode.c中 的sfs_io_nolock()函数，实现读文件中数据的代码。

发起read系统调用后，进入sys_read函数，进入内核态后调用了sysfile_read函数，传入文件句柄、base和len，此时就进入到了文件系统抽象层。sysfile_read首先检查文件长度是否不为0、文件是否可读（file_testfd），之后声明buffer空间，即调用kmalloc函数分配4096字节的buffer空间。之后进入循环，只要文件仍有剩余部分，就重复循环：循环中调用file_read函数将文件内容读取到buffer中，alen为实际大小。调用copy_to_user函数将读到的内容拷贝到用户的内存空间中，调整各变量以进行下一次循环读取，直至指定长度读取完成。最后函数调用层层返回至用户程序，用户程序收到了读到的文件内容。

`sfs_io_nolock`的调用是通过 `file_read`->`vop_read`(`sfs_read`)->`sfs_io`->`sfs_io_nolock`的途径实现的。

该函数首先检查以确保inode不是目录类型的，而后检查参数中范围的合法性，最后根据读写操作选择对应的缓冲区操作函数，之后计算出需要读或写的总块数，之后分别对没有对齐到快的起始部分、中间的满块部分和末尾剩余的部分进行处理。最后在写时检查写的字节数并更新inode大小，如果超出设置dirty标志。

```
 // 读取非对齐的第一块
if ((blkoff = offset % SFS_BLKSIZE) != 0|| endpos / SFS_BLKSIZE == offset / SFS_BLKSIZE)  {
    // 要找到第一块中要读的大小。如果开始块与结束块，块号相同，则只读 endpos - offset长度
    // 否则，读第一个块到结尾
    size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);
    // 载入这个文件逻辑上第blkno个数据块，得到其所对应的索引ino
    if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) 
    {
        goto out;
    }

    // 将第ino块（磁盘块号就是inode的序列号）从blkoff读取buf (或被写入)
    if ((ret = sfs_buf_op(sfs, buf, size, ino, blkoff)) != 0) 
    {
        goto out;
    }
    alen += size;
    if (nblks == 0)
    {
        goto out;
    }
    buf += size;
    blkno++;
    nblks--;
}

// 对齐的中间块，循环读取
size = SFS_BLKSIZE;
while (nblks != 0) { 
    // 载入这个文件逻辑上第blkno个数据块，ino为所对应的索引
    if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
        goto out;
    }

    // 读取或写入完整的一块
    if ((ret = sfs_block_op(sfs, buf, ino, 1)) != 0) { 
        goto out;
    }
    alen += size, buf += size, blkno++, nblks--;
}
// 末尾最后一块没对齐的情况
// 和读取第一个块类似，先找到对应的索引号，再向buffer读取应读的大小
if ((size = endpos % SFS_BLKSIZE) != 0) {  
    // 更新size
    if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
        goto out;
    }
    if ((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0) {   
        goto out;
    }
    alen += size;
}

```

#### 练习2: 完成基于文件系统的执行程序机制的实现（需要编码）

改写proc.c中的load_icode函数和其他相关函数，实现基于文件系统的执行程序机制。执行：make qemu。如果能看看到sh用户程序的执行界面，则基本成功了。如果在sh用户界面上可以执行”ls”,”hello”等其他放置在sfs文件系统中的其他执行程序，则可以认为本实验基本成功。

1. 在 `alloc_proc`中增加对文件系统指针的初始化。
2. 修改从lab5继承的 `load_icode`，使其从磁盘中加载程序。

相比于lab5的实现，其主要修改的部分就是读取ELF的方式以及附带的栈指针修改、参数传递。

```C++
assert(argc >= 0 && argc <= EXEC_MAX_ARG_NUM);

if (current->mm != NULL) {
    panic("load_icode: current->mm must be empty.\n");
}

int ret = -E_NO_MEM;
struct mm_struct *mm;
//(1) create a new mm for current process
//为进程创建一个新的mm
if ((mm = mm_create()) == NULL) {
    goto bad_mm;
}
//(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
//进行页表项的初始化设置
if (setup_pgdir(mm) != 0) {
    goto bad_pgdir_cleanup_mm;
}
//(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
//复制ELF文件的TEXT/DATA段到内存空间
struct Page *page;
//ELF头指针
struct elfhdr elf_content;
struct elfhdr *elf = &elf_content;  
//程度段头指针
struct proghdr ph_content;
struct proghdr *ph = &ph_content;
//（3.1）从磁盘上读取出ELF文件的文件头并判断是否合法
if ((ret = load_icode_read(fd, elf, sizeof(struct elfhdr), 0)) != 0) {
    goto bad_elf_cleanup_pgdir;
}
if (elf->e_magic != ELF_MAGIC) {
    ret = -E_INVAL_ELF;
    goto bad_elf_cleanup_pgdir;
}
//（3.2）根据ELF文件头的信息找到每一个程序段头
uint32_t vm_flags, perm;
for (int i = 0; i < elf->e_phnum; i ++) {
    //读出程序头
    if ((ret = load_icode_read(fd, ph, sizeof(struct proghdr), elf->e_phoff + sizeof(struct proghdr) * phnum)) != 0) {
        goto bad_cleanup_mmap;
    }
    //(3.4) find every program section headers
    //不是可加载的程序段
    if (ph->p_type != ELF_PT_LOAD) {
        continue ;
    }
    //文件过大
    if (ph->p_filesz > ph->p_memsz) {
        ret = -E_INVAL_ELF;
        goto bad_cleanup_mmap;
    }
    //文件大小为0，可能时BSS段
    if (ph->p_filesz == 0) {
         continue ;
    }
    //(3.3) call mm_map fun to setup the new vma
    //调用mm_map函数设置新的虚拟内存区域VMA，包括地址、大小和权限
    vm_flags = 0, perm = PTE_U | PTE_V;
    if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
    if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
    if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
    // modify the perm bits here for RISC-V
    //修改权限位
    if (vm_flags & VM_READ) perm |= PTE_R;
    if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
    if (vm_flags & VM_EXEC) perm |= PTE_X;
    //完成虚拟内存映射
    if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    off_t offset = ph->p_offset;
    size_t off, size;
    uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

    ret = -E_NO_MEM;

    end = ph->p_va + ph->p_filesz;
    //(3.4) callpgdir_alloc_page to allocate page for TEXT/DATA, read contents in file
    //      and copy them into the new allocated pages
    while (start < end) {
        // 为TEXT/DATA段逐页分配物理内存空间
        if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
            ret = -E_NO_MEM;
            goto bad_cleanup_mmap;
        }
        off = start - la, size = PGSIZE - off, la += PGSIZE;
        if (end < la) {
            size -= la - end;
        }
        // 将磁盘上的TEXT/DATA段读入到分配好的内存空间中去
        if ((ret = load_icode_read(fd, page2kva(page) + off, size, offset)) != 0) {
            goto bad_cleanup_mmap;
        }
        start += size, offset += size;
    }

    //(3.5) allocate pages for BSS
    end = ph->p_va + ph->p_memsz;
    if (start < la) {
        // 如果存在BSS段
        /* ph->p_memsz == ph->p_filesz */
        if (start == end) {
            continue ;
        }
        //并且先前的TEXT/DATA段分配的最后一页没有被完全占用
        //则剩余的部分被BSS段占用，进行清零
        off = start + PGSIZE - la, size = PGSIZE - off;
        if (end < la) {
            size -= la - end;
        }
        memset(page2kva(page) + off, 0, size);
        start += size;
        assert((end < la && start == end) || (end >= la && start == la));
    }
    //如果BSS段仍需要空间
    while (start < end) {
        if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
            ret = -E_NO_MEM;
            goto bad_cleanup_mmap;
        }
        off = start - la, size = PGSIZE - off, la += PGSIZE;
        if (end < la) {
            size -= la - end;
        }
        memset(page2kva(page) + off, 0, size);
        start += size;
    }
}
//关闭传入的文件
sysfile_close(fd);

//(4) setup user stack memory
// 为用户栈分配内存
// 使用 pgdir_alloc_page 分配几个物理页作为用户栈的底部
vm_flags = VM_READ | VM_WRITE | VM_STACK;
if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
    goto bad_cleanup_mmap;
}
assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);

//(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
// 增加 mm 的引用计数,设置当前进程的 mm 和 cr3
// 使用 lcr3 设置 CR3 寄存器，切换页表
mm_count_inc(mm);
current->mm = mm;
current->cr3 = PADDR(mm->pgdir);
lcr3(PADDR(mm->pgdir));

//(6) setup uargc and uargv in user stacks
uint32_t argv_size = 0;
int i;
for (i = 0; i < argc; i++) {
    // 确定传入给应用程序的参数具体应当占用多少空间
    argv_size += strnlen(kargv[i], EXEC_MAX_ARG_LEN + 1) + 1;
}
//根据参数占用的空间推算出传参之后栈顶的位置，存在对齐
uintptr_t stacktop =
    USTACKTOP - (argv_size / sizeof(long) + 1) * sizeof(long);
//设置uargv参数数组的位置
char **uargv = (char **)(stacktop - argc * sizeof(char *));
argv_size = 0;
//将argv指向的数据拷贝到用户栈中
for (i = 0; i < argc; i++) {
    uargv[i] = strcpy((char *)(stacktop + argv_size), kargv[i]);
    argv_size += strnlen(kargv[i], EXEC_MAX_ARG_LEN + 1) + 1;
}
stacktop = (uintptr_t)uargv - sizeof(int);
*(int *)stacktop = argc;

//(7) setup trapframe for user environment
struct trapframe *tf = current->tf;
// Keep sstatus
uintptr_t sstatus = tf->status;
memset(tf, 0, sizeof(struct trapframe));
/* LAB5:EXERCISE1 YOUR CODE
 * should set tf->gpr.sp, tf->epc, tf->status
 * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
 *          tf->gpr.sp should be user stack top (the value of sp)
 *          tf->epc should be entry point of user program (the value of sepc)
 *          tf->status should be appropriate for user program (the value of sstatus)
 *          hint: check meaning of SPP, SPIE in SSTATUS, use them by SSTATUS_SPP, SSTATUS_SPIE(defined in risv.h)
 */
tf->gpr.sp = USTACKTOP;
tf->epc = elf->e_entry;
// Set SPP to 0 so that we return to user mode
// Set SPIE to 1 so that we can handle interrupts
tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;

ret = 0;

out:
return ret;
bad_cleanup_mmap: // 进行加载失败的一系列清理操作
exit_mmap(mm);
bad_elf_cleanup_pgdir:
put_pgdir(mm);
bad_pgdir_cleanup_mm:
mm_destroy(mm);
bad_mm:
goto out;

```

#### 扩展练习 Challenge1：完成基于“UNIX的PIPE机制”的设计方案

如果要在ucore里加入UNIX的管道（Pipe)机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个(或多个）具体的C语言struct定义。在网络上查找相关的Linux资料和实现，请在实验报告中给出设计实现”UNIX的PIPE机制“的概要设方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）

```
struct pipe_buffer {
	//缓冲区结构体
	struct page *page;
	unsigned int offset, len;
	unsigned int flags;
};
```

```
struct pipe_inode_info {
	//管道结构体
	wait_queue wait;
	unsigned int nrbufs, curbuf, buffers;
	unsigned int readers;
	unsigned int writers;
	unsigned int files;
	unsigned int waiting_writers;
	struct pipe_buffer *bufs;
	struct inode * io;
};
```

* 在磁盘上保留一部分空间或者是一个特定的文件来作为pipe机制的缓冲区：
  * 当某两个进程之间要求建立管道，假定将进程A的标准输出作为进程B的标准输入，那么可以在这两个进程的进程控制块上新增变量来记录进程的这种属性；在进程A, B中打开同一个缓冲区;
  * 当进程A使用标准输出进行write系统调用、进程B使用标准输入的时候进行read系统调用的时候，通过变量选择接口时能够将这些标准输入输出的数据输入输出到缓冲区中。

#### 扩展练习 Challenge2：完成基于“UNIX的软连接和硬连接机制”的设计方案

如果要在ucore里加入UNIX的软连接和硬连接机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个(或多个）具体的C语言struct定义。在网络上查找相关的Linux资料和实现，请在实验报告中给出设计实现”UNIX的软连接和硬连接机制“的概要设方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）
