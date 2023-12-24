#include <ulib.h>
#include <unistd.h>
#include <file.h>
#include <stat.h>

int main(int argc, char *argv[]);

// 初始化文件描述符
static int
initfd(int fd2, const char *path, uint32_t open_flags) {
    int fd1, ret;
    // 打开文件
    if ((fd1 = open(path, open_flags)) < 0) {
        return fd1;
    }
    // 如果分配的文件描述符（fd1）不等于目标文件描述符（fd2），则进行处理
    if (fd1 != fd2) {
        // 关闭目标文件描述符（fd2）
        close(fd2);
        // 通过 dup2 系统调用让两个文件描述符指向同一个文件
        ret = dup2(fd1, fd2);// 通过sys_dup让两个文件描述符指向同一个文件
        // 关闭源文件描述符（fd1）
        close(fd1);
    }
    return ret;
}

void
umain(int argc, char *argv[]) {
    int fd;
    // 初始化标准输入文件描述符（stdin，文件描述符为0）
    if ((fd = initfd(0, "stdin:", O_RDONLY)) < 0) {
        warn("open <stdin> failed: %e.\n", fd);
    }
    // 初始化标准输出文件描述符（stdout，文件描述符为1）
    if ((fd = initfd(1, "stdout:", O_WRONLY)) < 0) {
        warn("open <stdout> failed: %e.\n", fd);
    }
    // 调用主程序（用户程序）
    int ret = main(argc, argv);// 真正的“用户程序”
    exit(ret);
}

