#ifndef __KERN_MM_BUDDY_PMM_H__
#define  __KERN_MM_BUDDY_PMM_H__

#include <pmm.h>

extern const struct pmm_manager buddy_pmm_manager;

typedef struct {
    unsigned int order;                           // 伙伴二叉树的层数
    list_entry_t buddy_array[16];     // 链表数组(现在默认有14层，即2^14 = 16384个可分配物理页)，每个数组元素都一个free_list头
    unsigned int nr_free;                             // 伙伴系统中剩余的空闲块
} free_buddy_t;

#endif /* ! __KERN_MM_BUDDY_PMM_H__ */