## 练习

对实验报告的要求：

- 基于markdown格式来完成，以文本方式为主
- 填写各个基本练习中要求完成的报告内容
- 完成实验后，请分析ucore_lab中提供的参考答案，并请在实验报告中说明你的实现与参考答案的区别
- 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
- 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

### 练习0：填写已有实验

本实验依赖实验1/2。请把你做的实验1/2的代码填入本实验中代码中有“LAB1”,“LAB2”的注释相应部分。

### 练习1：理解基于FIFO的页面替换算法（思考题）

<!--描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了 `kern/mm/swap_fifo.c`文件中，这点请同学们注意）

- 至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数-->

#### 换入换出过程

- 当发生`CAUSE_LOAD_ACCESS`或`CAUSE_STORE_ACCESS`的异常时，调用`pgfault_handler()`，当存在内存管理器`check_mm_struct`时，调用`do_pgfault()`，对异常情况进行判断，确定是缺页造成的访问异常还是非法的虚拟地址访问造成的。

- 调用`find_vma()`尝试找到包含了发生错误的虚拟地址的`vma`，将`pgfault_num`计数加一，更新`PTE`的权限标志位，使用`ROUNDDOWN()`取得虚拟地址对应的页首地址。尝试使用`get_pte`找到或创建这个地址对应的二级页表项。

- 若该页表项中每一位都是0，表明其原本确实不存在，则需要为其分配一个初始化后全新的物理页， 并建立虚实映射关系。
  - 调用`pgdir_alloc_page()`，首先调用宏定义的`alloc_page()`（即`alloc_pages(1)`），向页内存管理器尝试申请一个页的内存，失败则调用`swap_out()`进行页的换出，最终得到一个空闲的物理页用于建立映射，成功建立后调用`swap_map_swappable()`设置映射的这个物理页为可交换，并设置关联的虚拟地址，检查引用次数是否为1。

- 否则，说明该页只是暂时被交换到了磁盘上，需要将交换组中的数据读出并覆盖到所对应的物理页上。
  - 调用`swap_in()`换入页面，之后将跟这个页与虚拟地址的页表项建立映射关系，调用`swap_map_swappable()`设置映射的这个物理页为可交换，并设置关联的虚拟地址。

#### 用到的函数

* `find_vma(structmm_struct *mm,uintptr_t addr)`
  
  判断 `addr`是否在内存管理器管理的那段虚拟地址范围内，是的话将 `addr`对应的vma设置到mmap_cache，返回这个vma。

* `get_pte(pde_t* pgdir,uintptr_t la,bool create)`
  
  为 `la`查找对应的页表项，不存在时若 `create`为真则为其分配各级页表，并将各级页表空间内的值都设为0。

* `set_page_ref(struct Page *page,int val)`
  
  将页 `page`的引用次数设置为 `val`。

* `memset(void *s,char c,size_t n)`
  
  将从 `s`指向的地址开始大小为 `n`的范围内的值都设置为 `c`。

* `pte_create(uintptr_t ppn,int type)`
  
  从 `ppn`转为PTE，并设置其权限。

* `alloc_pages(size_t n)`
  
  声明一个大小为n的连续页。在本过程中主要用于声明一个大小为1的物理页用于映射。使用 `swap_out()`换出一个物理页，在下一次循环中获取到空出的物理页。

* `local_intr_save(x)`和 `local_intr_restore(x)`
  
  用于关闭和恢复中断控制。

* `page_remove_pte(pde_t *pgdir,uintptr_t la,pte_t *ptep)`
  
  释放一个和 `la`地址对应的内存页，并清空页表项，刷新TLB。

* `page_insert(pde_t *pgdir,struct Page *page,uintptr_t la,uint32_t perm)`
  
  用于建立 `page`对应物理地址与 `la`之间的映射关系，设置物理页 `page`的引用次数，若存在该虚拟地址与其他物理页的映射关系，调用 `page_remove_pte()`删除对应映射。调用 `pte_create()`构造页表项，刷新TLB。

* `swap_map_swappable(struct mm_struc *mm,uintptr_t addr,struct Page *page,int swap_in)`
  
  本过程中调用的是swap_fifo.c中的 `_fifo_map_swappable()`，将 `page`连接到内存管理器中存储的FIFO队列的head端

* `pgdir_alloc_page(pde_t* pgdir,uintptr_t la,uint32_t perm)`
  
  声明一个新的物理页用于虚拟地址的映射。调用 `alloc_page()`成功后，调用 `page_insert()`建立映射关系，在确定swap初始化后调用 `swap_map_swappable()`设置物理页为可交换，即加入FIFO队列头。
  
  * `assert(page_ref(page) ==1)`确保新声明的物理页的引用次数为本次的1。
* `swapfs_read(swap_entry_t entry,struct Page *page)`
  
  从磁盘中的某一扇区开始的N个连续扇区中读取数据，写入 `page`对应的地址中。

* `swap_in(struct mm_struct *mm,uintptr_t addr,struct Page **ptr_result)`
  
  调用 `swapfs_read()`从磁盘中读入 `addr`对应的物理页的数据，写入声明分配得到的一个新物理页中，将 `ptr_result`指向这个物理页。
  * `assert(result!=NULL)`：确保分配到了一个新的物理页。
  * `assert(r!=0)`：确保从磁盘中读取到了有效数据。
  
* `swapfs_write(swap_entry_t entry,struct Page *page)`
  
  向磁盘中的某一扇区开始的N个连续扇区写入 `page`对应的地址开始的数据。

* `swap_out_victim(struct mm_struct *mm,struct Page **ptr_page,int in_tick)`
  
  本过程中调用的是swap_fifo.c中的 `_fifo_swap_out_victim()`，把FIFO队列尾端的元素删除，并将删除的页的地址赋值给 `ptr_page`。

* `swap_out(struct mm_struct *mm,int n,int in_tick)`
  
  将内存管理器mm中某些内存页从内存中换出到磁盘。调用 `swap_out_victim()`得到要被换出的物理页，将该物理页写入磁盘，设置对应虚拟地址页表项，释放原物理页，刷新TLB。
  * `assert((*ptep&PTE_V) !=0)`：确保得到的页表项存在且是有效的。

### 练习2：深入理解不同分页模式的工作原理（思考题）

`get_pte()`函数（位于 `kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。

#### `get_pte()`函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。

- 这两段形式相似的代码的作用是为传入的虚拟地址 `la`查找及分配`PDX1`、`PDX0`两级页表；sv32、sv39、sv48页表机制指的是通过设置多级页表来完成更大虚拟空间的页面分配，虽然sv32是4个字节，sv39、sv48是8个字节，但它们的机制都是通过其中的某些位来表示某一级页表的偏移，结合起来通过总的地址分段依次定位到次级页表，最终定位到最小一级页内偏移。对于不同级的页表，区别只是在于对应在页表项值中的位置不同，页内部的标志位设置、空间赋值等操作是一样的，所以这两段代码只有在开头寻找对应级页表的位置时的代码有所差别。

#### 目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

- 这样的写法起到了正面作用。目前来说，查找页表项和（不存在时）分配页表项的操作是强关联的，当页表项不存在时就需要进行分配，因此在同一个函数中实现这两个功能，能够减少多个函数调用时的栈积压和参数传递、栈初始化时的时间消耗。此外，我们一般也只关心最小一级页表项的地址，函数能够掩盖其中的级级分配过程。

### 练习3：给未被映射的地址映射上物理页（需要编程）

<!--补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定的页表，而不是内核的页表。
请在实验报告中简要说明你的设计实现过程。请回答如下问题：
-->
#### 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。

在ucore实现页替换算法时，需要考虑如何记录虚拟地址与物理地址之间的映射关系以及如何判断某个物理页面是否被使用。

具体来说，页目录项和页表项中的PTE_P（存在位）可以用于表示某个页面是否已经分配并被占用，如果为0，则说明该页面没有被占用；如果为1，则说明该页面已经被占用。

此外，页目录项和页表项中的PTE_A（访问位）以及PTE_D（脏位）都可以用于判断页面是否被访问或修改。如果一个页面被访问或修改，则对应的PTE_A或PTE_D会被设置为1，否则为0。在页替换算法中，可以根据这些位来判断哪些页面可以被替换掉。

#### 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

1. 当出现页访问异常时，硬件首先会将错误的相关信息保存在相应寄存器中，并且将执行流程转交给中断处理程序。
scause寄存器会记录对应的错误原因， sepc寄存器记录触发中断的指令地址,stval寄存器记录中断处理所需的辅助信息，如指令获取，访存，缺页异常，记录发生问题的目标地址或出错的指令，以便中断处理程序处理。

2. 将控制权转交给操作系统内核，跳转到内核中的缺页异常处理函数（do_pgfault()）进行处理。

3. 在缺页异常处理函数中，根据缺页地址和进程的页表信息，从磁盘或交换分区中读取相应页面的内容，并建立虚拟地址和物理地址的映射关系，并设置访问权限。

4. 如果需要，将被替换的页面写回到磁盘或交换分区中。

5. 恢复之前保存的程序状态，返回到产生缺页异常的指令处重新执行。

#### 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

- 数据结构Page的每一项表示一个物理页，保存了该物理页的状态信息，包括是否被占用、是否可交换等。
- 页表反映了一个从虚拟地址到物理地址的映射关系，页表项（这里是狭义上最小的页的页表项）记录了物理页编号，对应这每一个pages中的物理页。page的vaddr属性存储了页面虚拟地址，通过虚拟地址可以获得页目录项和页表项。

### 练习4：补充完成Clock页替换算法（需要编程）

<!--通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。
请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 比较Clock页替换算法和FIFO算法的不同。-->

- Clock页替换算法实验过程：
  - 初始化
    
    在`_clock_init_mm`函数中，初始化一个双向链表`pra_list_head`作为页面队列，并将其地址赋给mm结构体的`sm_priv`字段。将页面按照访问情况链接起来。初始时，当前指针指向链表头。

  - 映射可置换页面
  
    在`_clock_map_swappable`函数中，将新的页面链接到页面队列的末尾，更新当前指针`curr_ptr`为新添加的页面，并设置其访问标志。

  - 选择置换页面
    
    在`_clock_swap_out_victim`函数中，从页面队列中选择一个置换页面。从当前指针开始，顺时针遍历页面队列，找到第一个未被访问过的页面进行置换。

- FIFO算法实验过程：
  - 初始化
    
    在`_fifo_init_mm`函数中，同样初始化一个双向链表`pra_list_head`作为页面队列，并将其地址赋给mm结构体的`sm_priv`字段。

  - 映射可置换页面
    
    在`_fifo_map_swappable`函数中，将新的页面链接到页面队列的末尾。

  - 选择置换页面
    
    在`_fifo_swap_out_victim`函数中，从页面队列中选择一个置换页面。直接选择页面队列的头部作为最早到达的页面进行置换。

#### Clock页替换算法和FIFO算法的不同之处：

- 页面选择方式
  
  Clock算法通过设置一个访问位（visited）来记录页面是否被访问过，根据访问位来选择置换页面。而FIFO算法则是按照页面进入队列的顺序，选择最早进入的页面进行置换。

- 置换策略
  
  Clock算法在选择置换页面时，会顺时针遍历页面队列，找到第一个未被访问过的页面进行置换。而FIFO算法则是直接选择队列头部的页面进行置换。

- 访问位更新
  
  Clock算法在每次置换页面后，会将当前页面的访问位重置为0，以便下一次判断页面是否被访问过。而FIFO算法不需要记录页面的访问情况，因此不需要更新访问位。

### 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）

如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？

* 优势
  * 减少了页表级数，能够显著提高查找页表的效率
  * TLB中一个项的覆盖范围增加，在容量不变的前提下TLB能存储的内存区域增加，这使得TLB的命中率得到大大提升。
  * 发生缺页异常时，能够减少处理次数；现代应用程序经常会存在超过4KB的连续内存请求，大页能够一次性地取出足够大的数据区域，以满足程序的需求。
* 缺点
  * 大页比较臃肿，在分配时不够灵活，动态调整能力较弱。
  * 分配精细度不够，大量分配时容易造成资源浪费。

<!--
【相关参考】
我们知道一个程序通常含有下面几段：

.text段：存放代码，需要是可读、可执行的，但不可写。
.rodata 段：存放只读数据，顾名思义，需要可读，但不可写亦不可执行。
.data 段：存放经过初始化的数据，需要可读、可写。
.bss段：存放经过零初始化的数据，需要可读、可写。与 .data 段的区别在于由于我们知道它被零初始化，因此在可执行文件中可以只存放该段的开头地址和大小而不用存全为 0的数据。在执行时由操作系统进行处理。
我们看到各个段需要的访问权限是不同的。但是现在使用一个大大页(Giga Page)进行映射时，它们都拥有相同的权限，那么在现在的映射下，我们甚至可以修改内核 .text 段的代码，因为我们通过一个标志位 W=1 的页表项就可以完成映射，但这显然会带来安全隐患。

因此，我们考虑对这些段分别进行重映射，使得他们的访问权限可以被正确设置。虽然还是每个段都还是映射以同样的偏移量映射到相同的地方，但实现过程需要更加精细。

这里还有一个小坑：对于我们最开始已经用特殊方式映射的一个大大页(Giga Page)，该怎么对那里面的地址重新进行映射？这个过程比较麻烦。但大家可以基本理解为放弃现有的页表，直接新建一个页表，在新页表里面完成重映射，然后把satp指向新的页表，这样就实现了重新映射
-->
### 扩展练习 Challenge：实现不考虑实现开销和效率的LRU页替换算法（需要编程）

challenge部分不是必做部分，不过在正确最后会酌情加分。需写出有详细的设计、分析和测试的实验报告。完成出色的可获得适当加分。
