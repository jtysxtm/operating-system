# 换入换出过程

当发生CAUSE_LOAD_ACCESS或CAUSE_STORE_ACCESS的异常时，调用pgfault_handler()，当存在内存管理器check_mm_struct时，调用do_pgfault()，对异常情况进行判断，确定是缺页造成的访问异常还是非法的虚拟地址访问造成的。

调用find_vma()尝试找到包含了发生错误的虚拟地址的vma，将pgfault_num计数加一，更新PTE的权限标志位，使用ROUNDDOWN()取得虚拟地址对应的页首地址。尝试使用get_pte找到或创建这个地址对应的二级页表项。

若该页表项中每一位都是0，表明其原本确实不存在，则需要为其分配一个初始化后全新的物理页， 并建立虚实映射关系。调用pgdir_alloc_page()，首先调用宏定义的alloc_page()（即alloc_pages(1)），向页内存管理器尝试申请一个页的内存，失败则调用swap_out()进行页的换出，最终得到一个空闲的物理页用于建立映射，成功建立后调用swap_map_swappable()设置映射的这个物理页为可交换，并设置关联的虚拟地址，检查引用次数是否为1。

否则，说明该页只是暂时被交换到了磁盘上，需要将交换组中的数据读出并覆盖到所对应的物理页上。调用swap_in()换入页面，之后将跟这个页与虚拟地址的页表项建立映射关系，调用swap_map_swappable()设置映射的这个物理页为可交换，并设置关联的虚拟地址。

# 用到的函数

* `find_vma(structmm_struct *mm,uintptr_t addr)`：判断 `addr`是否在内存管理器管理的那段虚拟地址范围内，是的话将 `addr`对应的vma设置到mmap_cache，返回这个vma。
* `get_pte(pde_t* pgdir,uintptr_t la,bool create)`：为 `la`查找对应的页表项，不存在时若 `create`为真则为其分配各级页表。
* `set_page_ref(struct Page *page,int val)`：将页 `page`的引用次数设置为 `val`。
* `memset(void *s,char c,size_t n)`：将从 `s`指向的地址开始大小为 `n`的范围内的值都设置为 `c`。
* `pte_create(uintptr_t ppn,int type)`：从 `ppn`转为PTE，并设置其权限。
* `alloc_pages(size_t n)`：声明一个大小为n的连续页。在本过程中主要用于声明一个大小为1的物理页用于映射。使用 `swap_out()`换出一个物理页，在下一次循环中获取到空出的物理页。
* `page_remove_pte(pde_t *pgdir,uintptr_t la,pte_t *ptep)`：释放一个和 `la`地址对应的内存页，并清空页表项，刷新TLB。
* `page_insert(pde_t *pgdir,struct Page *page,uintptr_t la,uint32_t perm)`：用于建立 `page`对应物理地址与 `la`之间的映射关系，设置物理页 `page`的引用次数，若存在该虚拟地址与其他物理页的映射关系，调用 `page_remove_pte()`删除对应映射。调用 `pte_create()`构造页表项，刷新TLB。
* `swap_map_swappable(struct mm_struc *mm,uintptr_t addr,struct Page *page,int swap_in)`：本过程中调用的是swap_fifo.c中的 `_fifo_map_swappable()`，将 `page`连接到内存管理器中存储的FIFO队列的head端
* `pgdir_alloc_page(pde_t* pgdir,uintptr_t la,uint32_t perm)`：声明一个新的物理页用于虚拟地址的映射。调用 `alloc_page()`成功后，调用 `page_insert()`建立映射关系，在确定swap初始化后调用 `swap_map_swappable()`设置物理页为可交换，即加入FIFO队列头。
* `swapfs_read(swap_entry_t entry,struct Page *page)`：从磁盘中的某一扇区开始的N个连续扇区中读取数据，写入 `page`对应的地址中。
* `swap_in(struct mm_struct *mm,uintptr_t addr,struct Page **ptr_result)`：调用 `swapfs_read()`从磁盘中读入 `addr `对应的物理页的数据，写入声明分配得到的一个新物理页中，将 `ptr_result`指向这个物理页。
* `swapfs_write(swap_entry_t entry,struct Page *page)`：向磁盘中的某一扇区开始的N个连续扇区写入 `page`对应的地址开始的数据。
* `swap_out_victim(struct mm_struct *mm,struct Page **ptr_page,int in_tick)`：本过程中调用的是swap_fifo.c中的 `_fifo_swap_out_victim()`，把FIFO队列尾端的元素删除，并将删除的页的地址赋值给 `ptr_page`。
* `swap_out(struct mm_struct *mm,int n,int in_tick)`：将内存管理器mm中某些内存页从内存中换出到磁盘。调用 `swap_out_victim()`得到要被换出的物理页，将该物理页写入磁盘，设置对应虚拟地址页表项，释放原物理页，刷新TLB。

## nr_free_pages()

返回空闲内存的大小nr*PAGESIZE。

## mm_create()

声明内存管理器结构体大小的空间，初始化一个内存管理器。其中会调用_fifo_init_mm()用于初始化FIFO队列。

## vma_create()

声明vma结构体大小的空间，初始化一个vma。声明的大小是从参数vm_start到vm_end的范围，参数vm_flags表示这部分虚拟空间的权限。

## insert_vma_struct()

把vma对应的虚拟空间连接到mm内存管理器中。在内存管理器存储vma的链表中找到该地址按照地址先后顺序对应的位置，检查地址范围是否有重叠。没有的话将其插入，将vma计数加一。

## get_pte()

为参数提供的地址查找对应的页表项，不存在时为其分配各级页表。

其中使用了set_page_ref()、page2pa()、memset()、pte_create()函数和PDX1()、alloc_page()、KADDR()、PDE_ADDR()、PDX0()等宏。

## free_pages()

default_pmm.c中定义的释放内存页的函数

## check_content_access()

调用_fifo_check_swap()，通过判断pgfault_num的值测试页面换入换出是否正常

## _fifo_init_mm

存在于swap_init_mm()中，该函数被位于vmm.c的mm_create()使用，

初始化一个FIFO队列，并把这个队列（实际上是双端链表）的头指针放到内存管理器中存储起来。
