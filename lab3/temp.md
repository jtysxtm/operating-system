# 用到的函数

## _fifo_init_mm

存在于swap_init_mm()中，该函数被位于vmm.c的mm_create()使用，

初始化一个FIFO队列，并把这个队列（实际上是双端链表）的头指针放到内存管理器中存储起来。

## _fifo_map_swappable

存在于swap_map_swappable()，在do_pgfault()中被pgdir_alloc_page()调用，将传递的参数page页连接到内存管理器中存储的FIFO队列head端。

## \_fifo_swap_out_victim

存在于swap.c的swap_out()中，把FIFO队列尾端的元素删除，并将删除的页的地址赋值给ptr_page。

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

其中使用了set_page_ref()、page2pa()、memset()、pte_create()
