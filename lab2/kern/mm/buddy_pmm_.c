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
        n=n>>1;
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

static void buddy_init(void)
{
    for(int i=0;i<15;i++)
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
    order=IS_POWER_OF_2(real_n)?GET_POWER_OF_2(real_n):GET_POWER_OF_2(real_n)-1;
    size_t n=1<<order;
    nr_free=n;
    for (; p != base + n; p+=1) 
    {
        assert(PageReserved(p));// 确保页面已保留（PageReserved 宏用于检查页面是否已被保留，通常表示已分配给操作系统或内核）
        p->flags =  0;//页面空闲
        p->property =-1;
        set_page_ref(p, 0);//页面空闲，无引用
                    
    }
    list_add(&(free_array[order]), &(base->page_link));

    base->property=order;
    return;
}

static struct Page * buddy_alloc_pages(size_t real_n)
{
    assert (real_n>0);
    if(real_n>nr_free)
    return NULL;
    struct Page *page=NULL;
    order=GET_POWER_OF_2(real_n);
    size_t n=1<<order;
    while(1)
    {
        if(!list_empty(&(free_array[order])))
        {
            page=le2page(list_next(&(free_array[order])),page_link);
            list_del(list_next(&(free_array[order])));
            SetPageProperty(page);
            nr_free-=n;
            break;
        }
        for(int i=order+1;i<15;i++)
        {
            if(!list_empty(&(free_array[i])))
            {
                struct Page *page1=le2page(list_next(&(free_array[i])),page_link);
                struct Page *page2=page1+(1<<(i-1));
                page1->property=i-1;
                page2->property=i-1;
                list_del(list_next(&(free_array[i])));
                list_add(&(free_array[i-1]),&(page1->page_link));
                list_add(&(free_array[i-1]),&(page2->page_link));
                break;
            }
        }
    }
    return page;
}

static void buddy_free_pages(struct Page *base, size_t n)
{
    assert(n>0);
    struct Page *free_page=base;
    struct Page *free_page_buddy=GET_BUDDY(free_page);
    list_add(&(free_array[free_page->property]),&(free_page->page_link));
    while(!PageProperty(free_page_buddy)&&free_page->property<15)
    {
        if(free_page_buddy<free_page)
        {
            free_page->property=-1;
            ClearPageProperty(free_page);
            list_del(&(free_page->page_link));
            list_del(&(free_page_buddy->page_link));
            list_add(&(free_array[free_page->property]),&(free_page->page_link));
            SetPageProperty(free_page_buddy);
            free_page=free_page_buddy;
            free_page_buddy=GET_BUDDY(free_page_buddy);
        }
        else{
            list_del(&(free_page->page_link));
            list_del(&(free_page_buddy->page_link));
            free_page->property+=1;
            list_add(&(free_array[free_page->property]),&(free_page->page_link));
            free_page_buddy=GET_BUDDY(free_page);
        }
        ClearPageProperty(free_page);
        nr_free+=1<<base->property;
        return;
    }
}
static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

static void
buddy_check(void) {
    //basic_check();
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