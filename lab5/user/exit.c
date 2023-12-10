#include <stdio.h>
#include <ulib.h>

int magic = -0x10384;

int
main(void) {
    int pid, code;
    cprintf("I am the parent. Forking the child...\n");
    // 创建子进程
    if ((pid = fork()) == 0) {
        cprintf("I am the child.\n");
        // 模拟运行时间
        yield();
        yield();
        yield();
        yield();
        yield();
        yield();
        yield();
        // 子进程调用exit，传递给父进程一个magic值
        exit(magic);
    }
    else {
        cprintf("I am parent, fork a child pid %d\n",pid);
    }
    assert(pid > 0);
    cprintf("I am the parent, waiting now..\n");

    // 等待子进程退出，获取magic
    assert(waitpid(pid, &code) == 0 && code == magic);
    assert(waitpid(pid, &code) != 0 && wait() != 0);
    cprintf("waitpid %d ok.\n", pid);

    cprintf("exit pass.\n");
    return 0;
}

