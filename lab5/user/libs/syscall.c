#include <defs.h>
#include <unistd.h>
#include <stdarg.h>
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
    va_list ap;     //声明一个参数列表ap
    va_start(ap, num);  //从num开始初始化参数列表
    uint64_t a[MAX_ARGS];   
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        //把参数存放到a[i]中
        a[i] = va_arg(ap, uint64_t);
    }
    va_end(ap);     //将ap置为NULL

    asm volatile (
        "ld a0, %1\n"
        "ld a1, %2\n"
        "ld a2, %3\n"
        "ld a3, %4\n"
        "ld a4, %5\n"
    	"ld a5, %6\n"
        "ecall\n"
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
        // 通过内联汇编进行ecall环境调用，产生trap, 进入S mode进行异常处理
        //=m表示ret记录了输出操作数
        //m表示num和a[0]到a[4]是输入操作数
        //memory表示内联汇编可能会修改内存
        //num和a[0]到a[4]依次存放在a0~a5中，返回值存到ret中
    return ret;
}

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
}

int
sys_fork(void) {
    return syscall(SYS_fork);
}

int
sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
}

int
sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
}

int
sys_pgdir(void) {
    return syscall(SYS_pgdir);
}

