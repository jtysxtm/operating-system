#include <defs.h>
#include <wait.h>
#include <atomic.h>
#include <kmalloc.h>
#include <sem.h>
#include <proc.h>
#include <sync.h>
#include <assert.h>

void
sem_init(semaphore_t *sem, int value) {
    // 初始化信号量，设置初始值和等待队列
    sem->value = value;
    wait_queue_init(&(sem->wait_queue));
}

// 信号量上升操作，用于释放信号量
static __noinline void __up(semaphore_t *sem, uint32_t wait_state) {
    bool intr_flag;
    local_intr_save(intr_flag);// 保存中断状态并关闭中断
    {
        wait_t *wait;

        // 如果等待队列为空，增加信号量的值
        if ((wait = wait_queue_first(&(sem->wait_queue))) == NULL) {
            sem->value ++;
        }
        // 如果等待队列不为空，唤醒等待队列中的第一个等待者
        else {
            assert(wait->proc->wait_state == wait_state);
            wakeup_wait(&(sem->wait_queue), wait, wait_state, 1);
        }
    }
    local_intr_restore(intr_flag); // 恢复中断状态
}

// 信号量下降操作，用于获取信号量
static __noinline uint32_t __down(semaphore_t *sem, uint32_t wait_state) {
    bool intr_flag;
    local_intr_save(intr_flag);// 保存中断状态并关闭中断
    if (sem->value > 0) {
        sem->value --;
        local_intr_restore(intr_flag);// 恢复中断状态
        return 0;// 信号量获取成功，返回 0 表示没有等待
    }
    wait_t __wait, *wait = &__wait;
    wait_current_set(&(sem->wait_queue), wait, wait_state);// 将当前进程设置为等待状态并加入等待队列
    local_intr_restore(intr_flag);// 恢复中断状态

    schedule();// 切换到其他可执行的进程，等待被唤醒

    local_intr_save(intr_flag);// 保存中断状态并关闭中断
    wait_current_del(&(sem->wait_queue), wait);// 从等待队列中移除当前进程
    local_intr_restore(intr_flag);// 恢复中断状态

    // 检查被唤醒的原因，如果不是指定的 wait_state，则返回对应的唤醒标志
    if (wait->wakeup_flags != wait_state) {
        return wait->wakeup_flags;
    }
    return 0;// 信号量获取成功，返回 0 表示没有等待
}

void
up(semaphore_t *sem) {
    __up(sem, WT_KSEM);
}// 信号量上升操作，用于释放信号量

// 信号量下降操作，用于获取信号量
void
down(semaphore_t *sem) {
    uint32_t flags = __down(sem, WT_KSEM);
    assert(flags == 0);// 确保 flags 为 0，表示正常获取信号量
}

bool
try_down(semaphore_t *sem) {
    bool intr_flag, ret = 0;
    local_intr_save(intr_flag);
    if (sem->value > 0) {
        sem->value --, ret = 1;
    }
    local_intr_restore(intr_flag);
    return ret;
}

