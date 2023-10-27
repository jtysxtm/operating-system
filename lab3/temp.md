# 用到的函数

## _fifo_init_mm

存在于swap_init_mm()中，该函数被位于vmm.c的mm_create()使用，

初始化一个FIFO队列，并把这个队列（实际上是双端链表）的头指针放到内存管理器中存储起来。

## _fifo_map_swappable

存在于swap_map_swappable()，在do_pgfault()中被pgdir_alloc_page()调用，将传递的参数page页连接到内存管理器中存储的FIFO队列head端。

## \_fifo_swap_out_victim

存在于swap.c的swap_out()中，把FIFO队列尾端的元素删除，并将删除的页的地址赋值给ptr_page。

## nr_free_pages()
