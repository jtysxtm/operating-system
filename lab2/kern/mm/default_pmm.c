#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>

/* In the first fit algorithm, the allocator keeps a list of free blocks (known as the free list) and,
   on receiving a request for memory, scans along the list for the first block that is large enough to
   satisfy the request. If the chosen block is significantly larger than that requested, then it is 
   usually split, and the remainder added to the list as another free block.
   Please see Page 196~198, Section 8.2 of Yan Wei Min's chinese book "Data Structure -- C programming language"
*/
// you should rewrite functions: default_init,default_init_memmap,default_alloc_pages, default_free_pages.
/*
 * Details of FFMA
 * (1) Prepare: In order to implement the First-Fit Mem Alloc (FFMA), we should manage the free mem block use some list.
 *              The struct free_area_t is used for the management of free mem blocks. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list implementation.
 *              You should know howto USE: list_init, list_add(list_add_after), list_add_before, list_del, list_next, list_prev
 *              Another tricky method is to transform a general list struct to a special struct (such as struct page):
 *              you can find some MACRO: le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.)
 * (2) default_init: you can reuse the  demo default_init fun to init the free_list and set nr_free to 0.
 *              free_list is used to record the free mem blocks. nr_free is the total number for free mem blocks.
 * (3) default_init_memmap:  CALL GRAPH: kern_init --> pmm_init-->page_init-->init_memmap--> pmm_manager->init_memmap
 *              This fun is used to init a free block (with parameter: addr_base, page_number).
 *              First you should init each page (in memlayout.h) in this free block, include:
 *                  p->flags should be set bit PG_property (means this page is valid. In pmm_init fun (in pmm.c),
 *                  the bit PG_reserved is setted in p->flags)
 *                  if this page  is free and is not the first page of free block, p->property should be set to 0.
 *                  if this page  is free and is the first page of free block, p->property should be set to total num of block.
 *                  p->ref should be 0, because now p is free and no reference.
 *                  We can use p->page_link to link this page to free_list, (such as: list_add_before(&free_list, &(p->page_link)); )
 *              Finally, we should sum the number of free mem block: nr_free+=n
 * (4) default_alloc_pages: search find a first free block (block size >=n) in free list and reszie the free block, return the addr
 *              of malloced block.
 *              (4.1) So you should search freelist like this:
 *                       list_entry_t le = &free_list;
 *                       while((le=list_next(le)) != &free_list) {
 *                       ....
 *                 (4.1.1) In while loop, get the struct page and check the p->property (record the num of free block) >=n?
 *                       struct Page *p = le2page(le, page_link);
 *                       if(p->property >= n){ ...
 *                 (4.1.2) If we find this p, then it' means we find a free block(block size >=n), and the first n pages can be malloced.
 *                     Some flag bits of this page should be setted: PG_reserved =1, PG_property =0
 *                     unlink the pages from free_list
 *                     (4.1.2.1) If (p->property >n), we should re-caluclate number of the the rest of this free block,
 *                           (such as: le2page(le,page_link))->property = p->property - n;)
 *                 (4.1.3)  re-caluclate nr_free (number of the the rest of all free block)
 *                 (4.1.4)  return p
 *               (4.2) If we can not find a free block (block size >=n), then return NULL
 * (5) default_free_pages: relink the pages into  free list, maybe merge small free blocks into big free blocks.
 *               (5.1) according the base addr of withdrawed blocks, search free list, find the correct position
 *                     (from low to high addr), and insert the pages. (may use list_next, le2page, list_add_before)
 *               (5.2) reset the fields of pages, such as p->ref, p->flags (PageProperty)
 *               (5.3) try to merge low addr or high addr blocks. Notice: should change some pages's p->property correctly.
 */
free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

// 初始化物理内存管理器，初始化空闲内存块列表 free_list，并将空闲内存块数量 nr_free 设为0。
static void
default_init(void) {
    list_init(&free_list);//创建一个空的链表
    nr_free = 0;//将 nr_free 变量设为0，表示当前没有可用的内存块。
}

//初始化内存映射,对管理的空闲页的数据进行初始化
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);// 断言确保 n 大于 0，即需要初始化的页面数量大于0
    struct Page *p = base;
    //遍历一个内存块的每一页，初始化每一页的属性，将引用计数 ref 设为0，然后将这些页面添加到 free_list 列表中
    for (; p != base + n; p ++) {
        assert(PageReserved(p));// 确保页面已保留（PageReserved 宏用于检查页面是否已被保留，通常表示已分配给操作系统或内核）
        p->flags = p->property = 0;//页面空闲
        set_page_ref(p, 0);//页面空闲，无引用
    }
    base->property = n;//设置该内存块的第一页的 property 为 n，表示块包含n个页面
    SetPageProperty(base);//设置第一页状态，表示空闲块状态
    nr_free += n;//可用内存块数量+n
    if (list_empty(&free_list)) {//如果 free_list 列表为空，将该内存块添加到 free_list 列表
        list_add(&free_list, &(base->page_link));
    } else {//非空，按物理地址的顺序将该内存块插入到合适的位置
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {//base 小于 page，插入当前位置前
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {//如果base大于最后一个页面，添加到列表的最后
                list_add(le, &(base->page_link));
            }
        }
    }
}

//分配 n 个连续的物理页面
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {// 如果请求的页面数量大于可用的页面数量，无法满足分配请求
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        // 遍历 free_list ，寻找第一个满足需求（property >= n）的空闲块
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
        list_entry_t* prev = list_prev(&(page->page_link));
        list_del(&(page->page_link));//从 free_list 中移除该页面
        // 如果该页面的 property 大于请求的页面数量，将剩余的部分作为新的空闲块。
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);
            list_add(prev, &(p->page_link));
            //将新的页面插入到 free_list 列表中，确保按物理地址的顺序。
        }
        nr_free -= n;//更新可用页面数量
        ClearPageProperty(page);// 清除页面的属性，表示页面不再是空闲的。
    }
    return page;
}

//释放 n 个连续的物理页面
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    // 循环遍历要释放的页面范围
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p)); // 断言确保页面不是已保留（PageReserved）且不是空闲块（PageProperty）
        p->flags = 0; // 清除页面标志
        set_page_ref(p, 0);  // 引用计数 ref 设0
    }
    base->property = n; // 第一个页面的 property 设为 n，表内存块包含 n 个页面
    SetPageProperty(base); // 设为表示空闲块状态
    nr_free += n;  // 更新可用页面数量

    // 如果 free_list 为空，添加到列表。
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } 
    // 非空，按物理地址的顺序将内存块插入到合适位置
    else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            // base 小于 page，插入当前位置之前
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } 
            // 如果base大于最后一个页面，添加到列表的最后
            else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }

    // 尝试合并前一空闲块
    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
         // 如果前一个页面的末尾与当前页面相邻，合并这两个空闲块
        if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);// 清除当前页面的属性，因为它已经合并到前一个页面
            list_del(&(base->page_link));  // 从 free_list 中移除当前页面
            base = p;
        }
    }
    // 尝试合并后一空闲块
    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
         // 如果当前页面的末尾与后一个页面相邻，合并这两个空闲块
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p); // 清除后一页面的属性，因为它已经合并到当前页面
            list_del(&(p->page_link)); // 从 free_list 中移除后一页面
        }
    }
}

//返回可用内存页的数量
static size_t
default_nr_free_pages(void) {
    return nr_free;
}

//检查物理内存管理器的基本功能：分配和释放页面，检查分配、释放以及列表状态是否符合预期
static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    // 分配三个物理页面，将它们分别赋给 p0, p1, 和 p2。
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);
    
    assert(p0 != p1 && p0 != p2 && p1 != p2); // 确保分配的页面不同
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0); // 确保引用计数都为0。

    // 确保物理地址在合理范围内（小于 npage * PGSIZE）
    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    // 存储当前的 free_list ，然后初始化一个新的空的 free_list 列表
    list_entry_t free_list_store = free_list; 
    list_init(&free_list);
    assert(list_empty(&free_list));  // 确保 free_list 为空

    // 存储当前可用页面数量
    unsigned int nr_free_store = nr_free;  
    nr_free = 0;

    assert(alloc_page() == NULL);  // 确保无法分配页面，因为 nr_free 为0
 
    // 释放 p0, p1, 和 p2，然后检查 nr_free 是否为3。
    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    // 再次分配三个页面，确保它们都不为空
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    // 再次尝试分配页面，但此时应该返回NULL，因为没有足够的可用页面
    assert(alloc_page() == NULL);
    
    // 释放 p0，确保 free_list 列表不为空
    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0); // 尝试分配一个页面，应该返回 p0。
    assert(alloc_page() == NULL); // 再次尝试分配页面，但此时应该返回NULL，因为没有足够的可用页面

    assert(nr_free == 0);  // 确保 nr_free 现在为0，因为之前已经分配了所有的可用页面
    free_list = free_list_store; // 恢复原始的 free_list 
    nr_free = nr_free_store; // 恢复原始的 nr_free 

    // 释放 p0, p1, 和 p2
    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    // 遍历 free_list 列表，统计空闲块数量和总空闲页面数量
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    // 确保 total（总空闲页面数量）等于 nr_free_pages()
    assert(total == nr_free_pages());

    basic_check();// 调用 basic_check 函数，检查基本功能是否正常

    struct Page *p0 = alloc_pages(5), *p1, *p2;// 分配一个包含5个页面的连续内存块
    assert(p0 != NULL);//确保返回的指针不为NULL
    assert(!PageProperty(p0));// 确保返回的页面没有 PageProperty 标志

    //存储当前的 free_list 列表，然后初始化一个新的空 free_list 列表。
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));// 确保新 free_list 为空
    assert(alloc_page() == NULL);// 确保无法分配页面，因为 nr_free 为0

    //存储当前可用页面数量
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);// 释放 p0 中的第3、4、5个页面
    assert(alloc_pages(4) == NULL);// 确保无法分配包含4个页面的连续内存块
    assert(PageProperty(p0 + 2) && p0[2].property == 3);// 确保 p0 中的第3个页面有 PageProperty 标志，且 property 值为3
    assert((p1 = alloc_pages(3)) != NULL);// 分配一个包含3个页面的连续内存块
    assert(alloc_page() == NULL);// 确保无法分配单个页面
    assert(p0 + 2 == p1);// 确保 p1 是 p0 中的第3个页面

    p2 = p0 + 1;
    free_page(p0);
    free_pages(p1, 3);
    assert(PageProperty(p0) && p0->property == 1);// 确保 p0 有 PageProperty 标志，且 property 值为1
    assert(PageProperty(p1) && p1->property == 3);// 确保 p1 有 PageProperty 标志，且 property 值为3

    assert((p0 = alloc_page()) == p2 - 1);// 分配一个单独页面（p2 的前一个页面）
    free_page(p0);
    assert((p0 = alloc_pages(2)) == p2 + 1);// 再次分配一个包含2个页面的连续内存块，应该是 p2 的后一个页面

    free_pages(p0, 2);
    free_page(p2);

    assert((p0 = alloc_pages(5)) != NULL);// 分配一个包含5个页面的连续内存块
    assert(alloc_page() == NULL);//无法分配页面

    assert(nr_free == 0);//已分配所有可用页面
    nr_free = nr_free_store;//恢复

    free_list = free_list_store;//恢复
    free_pages(p0, 5);

    le = &free_list;
    // 遍历 free_list 列表，统计空闲块数量和总空闲页面数量
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}

//这个结构体在
const struct pmm_manager default_pmm_manager = {
    .name = "default_pmm_manager",// 物理内存管理器的名称
    .init = default_init,// 初始化物理内存管理器
    .init_memmap = default_init_memmap, // 初始化内存映射
    .alloc_pages = default_alloc_pages, // 分配页面
    .free_pages = default_free_pages, // 释放页面
    .nr_free_pages = default_nr_free_pages, // 获取可用页面数量
    .check = default_check, // 检查物理内存管理器的正确性
};

