#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    // 确保进程的状态不是僵死状态,确保唤醒的进程不是已经结束执行的进程
    assert(proc->state != PROC_ZOMBIE);
    bool intr_flag;// 保存中断状态
    // 禁用中断
    local_intr_save(intr_flag);
    {
        // 如果进程状态不是可运行状态,将进程状态设置为可运行,清空等待状态
        if (proc->state != PROC_RUNNABLE) {
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;// 表示进程不再等待任何事件
        }
        // 打印警告信息，说明唤醒了一个已经是可运行状态的进程
        else {
            warn("wakeup runnable process.\n");
        }
    }
    // 恢复中断状态
    local_intr_restore(intr_flag);
}

/*
一个最简单的FIFO调度器
schedule 函数的目的是从当前可运行的进程列表中选择下一个要执行的进程，并进行上下文切换。
如果没有找到可运行的进程，或者下一个进程与当前进程相同，那么空闲进程将成为下一个执行的进程。
这样，调度器确保了在多任务环境中的进程切换和执行。
*/
void
schedule(void) {
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    // 禁用中断，保存中断状态
    local_intr_save(intr_flag);
    {
        // 清除当前进程的重新调度标志,表示当前进程不需要重新调度。
        current->need_resched = 0;
        // 如果当前进程是空闲进程（idleproc），则将进程列表的尾部作为循环的结束条件
        // 否则，将当前进程的 list_link 作为循环的结束条件
        last = (current == idleproc) ? &proc_list : &(current->list_link);
        // 遍历进程列表，查找下一个可运行的进程
        le = last;
        do {
            // 获取下一个进程的结构体
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                // 如果下一个进程是可运行状态，则跳出循环
                if (next->state == PROC_RUNNABLE) {
                    break;
                }
            }
        } while (le != last);
        // 如果没有找到可运行的进程，或者下一个进程不是可运行状态，则将空闲进程设置为下一个进程
        if (next == NULL || next->state != PROC_RUNNABLE) {
            next = idleproc;
        }
        // 增加下一个进程的运行次数
        next->runs ++;
        // 如果下一个进程不是当前进程，则调用 proc_run(next) 进行上下文切换，将 CPU 的执行权交给下一个进程。
        // proc_run(next): 保存当前进程current的执行现场（进程上下文），恢复新进程的执行现场，完成进程切换
        if (next != current) {
            proc_run(next);
        }
        // proc_list中只有两个内核线程，且idleproc要让出CPU给initproc执行，
        // 可以看到schedule函数通过查找proc_list进程队列，只能找到一个处于“就绪”态的initproc内核线程。
        // 并通过proc_run和进一步的switch_to函数完成两个执行现场的切换
    }
    // 恢复中断状态
    local_intr_restore(intr_flag);
}

