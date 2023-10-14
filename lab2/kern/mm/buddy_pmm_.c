#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm_.h>
#include <stdio.h>

free_buddy_t free_buddy;
#define free_array (free_buddy.buddy_array)
#define order (free_buddy.order)
#define nr_free (free_buddy.nr_free)
extern ppn_t fppn;

#define IS_POWER_OF_2(x) (!((x)&((x)-1)))

static uint32_t GET_POWER_OF_2(size_t n)
{
    uint32_t power = 0;
    while(n>>1)
    {
        n>>=1;
        power++;
    }
    return power;
}

static struct Page* GET_BUDDY(struct Page *page)
{
    uint32_t power=page->property;
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
    return page+(ppn-page2ppn(page));
}

static void show_buddy_array(void) {
    cprintf("[!]BS: Printing buddy array:\n");
    for (int i = 0;i < 16;i ++) {
        cprintf("%d layer: ", i);
        list_entry_t *le = &(free_array[i]);
        while ((le = list_next(le)) != &(free_array[i])) {
            struct Page *p = le2page(le, page_link);
            cprintf("%d ", 1 << (p->property));
        }
        cprintf("\n");
    }
    cprintf("---------------------------\n");
    return;
}

static void buddy_init(void)
{
    for(int i=0;i<16;i++)
    {
        list_init(free_array+i);
    }
    order=0;
    nr_free=0;
    return;
}

static void buddy_init_memmap(struct Page *base,size_t real_n)
{
    
    assert(real_n>0);
    struct Page *p=base;
    order=GET_POWER_OF_2(real_n);
    size_t n=1<<order;
    nr_free=n;
    for (; p != base + n; p+=1) 
    {
        assert(PageReserved(p));// 确保页面已保留
        p->flags =  0;//页面空闲
        p->property =0;
        set_page_ref(p, 0);//页面空闲，无引用                
    }
    list_add(&(free_array[order]), &(base->page_link));
    base->property=order;
    //cprintf("base order is %d\n",order);
    return;
}

static struct Page * buddy_alloc_pages(size_t real_n)
{
    assert (real_n>0);
    //cprintf("real_n is %d\n",real_n);
    if(real_n>nr_free)
    return NULL;
    struct Page *page=NULL;
    order=IS_POWER_OF_2(real_n)?GET_POWER_OF_2(real_n):GET_POWER_OF_2(real_n)+1;
    //cprintf("is order of 2?%d\n",IS_POWER_OF_2(real_n));
    //cprintf("order is %d\n",order);
    size_t n=1<<order;
    while(1)
    {
        if(!list_empty(&(free_array[order])))
        {
            //show_buddy_array();
            page=le2page(list_next(&(free_array[order])),page_link);
            list_del(list_next(&(free_array[order])));
            SetPageProperty(page);
            nr_free-=n;
            //show_buddy_array();
            //cprintf("nr_free is %d",nr_free);
            //show_buddy_array();
            //cprintf("page->property is %d\n",page->property);
            break;
        }
        for(int i=order;i<16;i++)
        {
            if(!list_empty(&(free_array[i])))
            {
                struct Page *page1=le2page(list_next(&(free_array[i])),page_link);
                struct Page *page2=page1+(1<<(i-1));
                page1->property=i-1;
                page2->property=i-1;
                list_del(list_next(&(free_array[i])));
                list_add(&(free_array[i-1]),&(page2->page_link));
                list_add(&(free_array[i-1]),&(page1->page_link));
                //cprintf("devide into 2^%d block\n",i-1);
                break;
            }
        }
    }
    return page;
}

static void buddy_free_pages(struct Page *base, size_t n)
{
    assert(n>0);
    nr_free+=1<<base->property;  
    //cprintf("base property is %d",base->property);
    struct Page *free_page=base;
    struct Page *free_page_buddy=GET_BUDDY(free_page);
    list_add(&(free_array[free_page->property]),&(free_page->page_link));
    while(!PageProperty(free_page_buddy)&&free_page->property<14)
    {
        //cprintf("in while\n");
        if(free_page_buddy<free_page)
        {
            struct Page* temp;
            free_page->property=0;
            ClearPageProperty(free_page);
            temp=free_page;
            free_page=free_page_buddy;
            free_page_buddy=temp;
        }
        list_del(&(free_page->page_link));
        list_del(&(free_page_buddy->page_link));
        free_page->property+=1;
        list_add(&(free_array[free_page->property]),&(free_page->page_link));
        free_page_buddy=GET_BUDDY(free_page);
        //cprintf("buddy's property is %d\n",free_page_buddy->property);
        //show_buddy_array();
    }
    //ClearPageProperty(free_page);
    return;
}
static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

 static void basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2); // 确保分配的页面不同
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0); // 确保引用计数都为0。

    // 确保物理地址在合理范围内（小于 npage * PGSIZE）
    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);
    show_buddy_array();
    // 释放 p0, p1, 和 p2，然后检查 nr_free 是否为3。
    free_page(p0);
    //cprintf("p0 free\n");
    free_page(p1);
    //cprintf("p1 free\n");
    free_page(p2);
    //show_buddy_array();
    //cprintf("nr_free is %d",nr_free);
    show_buddy_array();
    assert(nr_free == 16384);


    assert((p0 = alloc_pages(4)) != NULL);
    assert((p1 = alloc_pages(2)) != NULL);
    assert((p2 = alloc_pages(1)) != NULL);
    cprintf("%p,%p,%p\n",page2pa(p0),page2pa(p1),page2pa(p2));show_buddy_array();
    free_pages(p0, 4);
    cprintf("p0 free\n");show_buddy_array();
    free_pages(p1, 2);
    show_buddy_array();
    cprintf("p1 free\n");show_buddy_array();
    free_pages(p2, 1);
    cprintf("p2 free\n");show_buddy_array();
    show_buddy_array();

    assert((p0 = alloc_pages(3)) != NULL);
    assert((p1 = alloc_pages(3)) != NULL);
    show_buddy_array();
    free_pages(p0, 3);
    free_pages(p1, 3);
    show_buddy_array();
}   

static void buddy_check(void) {
    show_buddy_array();

    basic_check();// 调用 basic_check 函数，检查基本功能是否正常



}

const struct pmm_manager buddy_pmm_manager_ = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};