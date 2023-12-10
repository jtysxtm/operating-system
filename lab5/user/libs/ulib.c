#include <defs.h>
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
    sys_exit(error_code);// 通知内核进程退出
    //执行完sys_exit后，按理说进程就结束了，后面的语句不应该再执行，
    //所以执行到这里就说明exit失败了
    cprintf("BUG: exit failed.\n");
    while (1);
}

int
fork(void) {
    return sys_fork();// 创建新进程
}

int
wait(void) {
    return sys_wait(0, NULL);//等待子进程退出
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);// 等待指定pid的子进程退出
}

void
yield(void) {
    sys_yield();//让出CPU时间片，允许其他进程运行
}

int
kill(int pid) {
    return sys_kill(pid);// 发送信号给指定pid进程
}

int
getpid(void) {
    return sys_getpid();// 获取当前进程pid
}

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    sys_pgdir(); // 打印当前进程的页目录表和页表
}

