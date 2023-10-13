#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm_.h>

free_buddy_t free_buddy;
#define free_array (free_buddy.buddy_array)
#define order (free_buddy.order)
#define nr_free (free_buddy.nr_free)

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



static void buddy_init(void)
{
    for(int i=0;i<15;i++)
    {
        list_init(free_array+i);v 
    }
    order=0;
    nr_free=0;
    return;
}

static void buddy_init_memmap(struct Page *base,size_t real_n)
{
    assert(n>0);
    struct Page *p=base;
    order=IS_POWER_OF_2(real_n)?GET_POWER_OF_2(real_n):GET_POWER_OF_2(real_n)-1;
    size_t n=pow(2,order);
    nr_free=n;
    for (; p != base + n; p ++) 
    {
        assert(PageReserved(p));// 确保页面已保留（PageReserved 宏用于检查页面是否已被保留，通常表示已分配给操作系统或内核）
        p->flags = p->property = 0;//页面空闲
        set_page_ref(p, 0);//页面空闲，无引用
    }
    list_add(&(free_array[order]), &(base->page_link));
    base->property=order;
    return;
}

static struct Page * buddy_alloc_pages(size_t real_n)
{
    assert(n>0);
    if(n>nr_free)
    return NULL;
    struct Page *page=NULL;
    order=GET_POWER_OF_2(real_n);
    size_t n=pow(2,order);
    while(1)
    {
        if(!list_empty(&(free_array[order])))
        {
            page=le2page(list_next(&(free_array[order])),page_link);
            list_del(list_next(&(free_array[order])),page_link);
            SetPageProperty(page);
            nr_free-=n;
            break;
        }
        for(int i=order+1;i<15;i++)
        {
            if(!list_empty(&(free_array[i])))
            {
                struct Page *page1=le2page(list_next(&(free_array[i])),page_link);
                struct Page *page2=page1+pow(2,i-1);
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
    
}