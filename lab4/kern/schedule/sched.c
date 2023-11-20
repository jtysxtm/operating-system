#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}

void
schedule(void) {
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;//设置当前进程为不需要调度
        //判断last是否为idle进程，是则从头开始搜索链表，否则获取下一链表
        last = (current == idleproc) ? &proc_list : &(current->list_link);
        le = last;
        do {//循环找到可调度的进程
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
                    break;
                }
            }
        } while (le != last);
        //未找到则继续idle进程
        if (next == NULL || next->state != PROC_RUNNABLE) {
            next = idleproc;
        }
        next->runs ++;//运行次数++
        if (next != current) {
            //新进程，则运行
            proc_run(next);
        }
    }
    local_intr_restore(intr_flag);
}

