#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

//计算当前节点的左孩子节点在数组中的下标；
#define LEFT_LEAF(index) ((index)*2)
//计算当前节点的右孩子节点在数组中的下标；
#define RIGHT_LEAF(index) ((index)*2+1)
//计算当前节点的父节点在数组中的下标；
#define PARENT(index) ((index)/2)
//判断 x 是否为 2 的幂；
#define IS_POWER_OF_2(x) (!((x)&((x)-1)))
//计算 a 和 b 中的最大值。
#define MAX(a, b) ((a) > (b) ? (a) : (b))

unsigned* buddy_manager;
struct Page* page_base;
int free_page_num, manager_size;

//size如果不是2的幂，向上取上后的幂次方
int UP_LOG(int size)
{
    int n=0;//幂次
    int temp=size;
    while(temp>>=1)
    {
        n++;
    }
    temp= (size>>n)<<n;
    if(size-temp!=0)//如果不为0说明size的二进制表示中还有1的位
    {
        n++;//向上取
    }
    return n;//size的最小2的幂次方的指数
}

static void buddy_init(void) {
    free_page_num = 0;
}

static void buddy_init_memmap(struct Page *base, size_t n){
    // 首先对页进行初始化
    struct Page* p;
    for(p = base; p != base + n; p++){
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
        SetPageProperty(p);
    }
    // 获取 buddy_manager 数组的长度
    // manager_size = 1<<UP_LOG(n) 只能容纳到满二叉树中的节点数
    //不能同时存储一棵满二叉树和它的对应堆中的信息（即各个节点的大小）
    manager_size = 2 * (1<<UP_LOG(n));
    // 获取 buddy_manager 的起始地址 预留base最开始的部分给 buddy_manager
    //buddy_manager = (unsigned*) page2kva(base);
    buddy_manager = (unsigned*) page2pa(base);
    // 调整 base，向后移动 4 * manager_size / 4096 个页
    // 4 * manager_size为buddy_manager占用大小（字节单位），处以4096转换为页数
    base += 4 * manager_size / 4096;
    // page_base 为可用内存空间的起始地址，在后续申请和释放内存的时使用
    page_base = base;
    // 剩余可用页数
    free_page_num = n - 4 * manager_size / 4096;
    // buddy数组的下标[1 … manager_size]有效
    unsigned i = 1;
    unsigned node_size = manager_size / 2;
    // 遍历 buddy_manager 数组，初始化每个索引对应的 buddy 大小
    for(; i < manager_size; i++){
        buddy_manager[i] = node_size;
        if(IS_POWER_OF_2(i+1)){
            node_size /= 2;//如果 i+1 是2的幂次方，则调整节点大小为原来的一半
        }
    }
    base->property = free_page_num;//// 将 base 的属性设置为剩余可用页数
    SetPageProperty(base);

    //打印初始化信息
    cprintf("===================buddy init end===================\n");
    cprintf("free_size = %d\n", free_page_num);
    cprintf("buddy_size = %d\n", manager_size);
    cprintf("buddy_addr = 0x%08x\n", buddy_manager);
    cprintf("manager_page_base = 0x%08x\n", page_base);
    cprintf("====================================================\n");
}

int buddy_alloc(int size){
    unsigned index = 1;//根节点开始遍历
    unsigned offset = 0;//分配块的便宜量
    unsigned node_size;

    if(buddy_manager[index] < size)//如果根节点大小小于需要的快，无内存可用
        return -1;

    //向上取
    if(size <= 0)
        size = 1;
    else if(!IS_POWER_OF_2(size))
        size = 1 << UP_LOG(size);
    
    // 从根节点往下深度遍历，找到恰好等于size的块
    for(node_size = manager_size / 2; node_size != size; node_size /= 2){
        if(buddy_manager[LEFT_LEAF(index)] >= size)// 如果左子节点的大小大于等于需要的块大小，则向左子节点移动
            index = LEFT_LEAF(index);//优先分左
        else
            index = RIGHT_LEAF(index);
    }

    // 将找到的块取出分配
    buddy_manager[index] = 0;

    // 计算块在所有块内存中的索引
    // (index) * node_size：从内存管理器起始位置开始的偏移量（字节）
    // offset：相对于整个内存区域的偏移量
    offset = (index) * node_size - manager_size / 2;
    cprintf(" index:%u offset:%u ", index, offset);

    // 向上回溯至根节点，修改沿途节点的大小
    while(index > 1){
        index = PARENT(index);
        buddy_manager[index] = MAX(buddy_manager[LEFT_LEAF(index)],buddy_manager[RIGHT_LEAF(index)]);
        //保留左右子节点中大的块的大小
    }

    return offset;//返回分配块的偏移量即索引
}

static struct Page* buddy_alloc_pages(size_t n) {
    cprintf("alloc %u pages", n);
    assert(n>0);
    if(n > free_page_num)
        return NULL;

    // 获取分配的页在内存中的起始地址
    int offset = buddy_alloc(n);

    struct Page *base = page_base + offset;

    struct Page *page;
    int round_n = 1 << UP_LOG(n);//总共取出的
    // 将每一个取出的块由空闲态改为保留态
    for(page = base; page != base + round_n; page++){
        ClearPageProperty(page);
    }

    free_page_num -= round_n;//更新空闲页数不
    base->property = n;//
    cprintf("finish!\n");
    return base;
}

static void buddy_free_pages(struct Page* base, size_t n) {
    cprintf("free  %u pages", n);
    // 重置pages中对应的page
    assert(n > 0);
    n = 1 << UP_LOG(n);

    // 检查起始地址 base 是否对应保留态的页
    //检查从base开始的连续 n 个页是否正确分配，并且没有被标记为保留态或者属性态
    assert(!PageReserved(base));
    for(struct Page* p = base; p < base + n; p++){
        assert(!PageReserved(p) && !PageProperty(p));
        set_page_ref(p, 0);
    }

    // STEP2: 将buddy中的对应节点释放
    // 开始块序号 相对于整个内存区域的偏移量
    unsigned offset = base - page_base;
    // 对应叶节点索引
    unsigned index = manager_size / 2 + offset;
    unsigned node_size = 1;

    while(node_size!=n){
        // 自底向上
        index = PARENT(index);
        node_size *= 2;
        assert(index);
    }
    //找到在 buddy_manager 数组中对应位置的节点，并将该节点大小设置为 n
    buddy_manager[index] = node_size;
    cprintf(" index:%u offset:%u ", index, offset);

    // 回溯直到根节点，更改沿途值
    index = PARENT(index);
    node_size *= 2;
    while(index){
        unsigned leftSize = buddy_manager[LEFT_LEAF(index)];
        unsigned rightSize = buddy_manager[RIGHT_LEAF(index)];

        if(leftSize + rightSize == node_size){//该节点对应的空闲空间是连续的，可合并
            buddy_manager[index] = node_size;
        }
        else if(leftSize>rightSize){//当前节点的大小更新为左节点的大小
            buddy_manager[index] = leftSize;
        }
        else{
            buddy_manager[index] = rightSize;
        }
        index = PARENT(index);
        node_size *= 2;
    }


    free_page_num += n;//更新空闲页数目
    cprintf("finish!\n");
}

static size_t buddy_nr_free_pages(void) {
    return free_page_num;
}

// static void
// basic_check(void) {

// }


static void
buddy_check(void) {
    cprintf("buddy check!\n");
    struct Page *p0, *A, *B, *C, *D;
    p0 = A = B = C = D = NULL;

    assert((p0 = alloc_page()) != NULL);
    assert((A = alloc_page()) != NULL);
    assert((B = alloc_page()) != NULL);

    assert(p0 != A && p0 != B && A != B);
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);

    free_page(p0);
    free_page(A);
    free_page(B);

    A = alloc_pages(512);
    B = alloc_pages(512);
    free_pages(A, 256);
    free_pages(B, 512);
    free_pages(A + 256, 256);

    p0 = alloc_pages(8192);
    assert(p0 == A);
    // free_pages(p0, 1024);
    //以下是根据链接中的样例测试编写的
    A = alloc_pages(128);
    B = alloc_pages(64);
    // 检查是否相邻
    assert(A + 128 == B);
    C = alloc_pages(128);
    // 检查C有没有和A重叠
    assert(A + 256 == C);
    // 释放A
    free_pages(A, 128);
    D = alloc_pages(64);
    cprintf("D %p\n", D);
    // 检查D是否能够使用A刚刚释放的内存
    assert(D + 128 == B);
    free_pages(C, 128);
    C = alloc_pages(64);
    // 检查C是否在B、D之间
    assert(C == D + 64 && C == B - 64);
    free_pages(B, 64);
    free_pages(D, 64);
    free_pages(C, 64);
    // 全部释放
    free_pages(p0, 8192);
}


const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};