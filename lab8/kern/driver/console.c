#include <console.h>
#include <defs.h>
#include <sbi.h>
#include <sync.h>

#define CONSBUFSIZE 512

static struct {
    uint8_t buf[CONSBUFSIZE];
    uint32_t rpos;
    uint32_t wpos; //控制台的输入缓冲区是一个队列
} cons;

/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
void cons_intr(int (*proc)(void)) {
    int c;
    // 通过调用 proc 函数将输入字符放入输入缓冲区
    while ((c = (*proc)()) != -1) {
        if (c != 0) {
            cons.buf[cons.wpos++] = c;
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}

/* kbd_intr - try to feed input characters from keyboard */
void kbd_intr(void) {
    serial_intr();// 尝试从键盘读取输入字符
}

/* serial_proc_data - get data from serial port */
// 从串口获取数据
int serial_proc_data(void) {
    int c = sbi_console_getchar();
    if (c < 0) {
        return -1;
    }
    if (c == 127) {
        c = '\b';
    }
    return c;
}

/* serial_intr - try to feed input characters from serial port */
// 尝试从串口读取输入字符
void serial_intr(void) {
    cons_intr(serial_proc_data);
}

/* serial_putc - print character to serial port */
// 将字符打印到串口
void serial_putc(int c) {
    if (c != '\b') {
        sbi_console_putchar(c);
    } else {
        sbi_console_putchar('\b');
        sbi_console_putchar(' ');
        sbi_console_putchar('\b');
    }
}

/* cons_init - initializes the console devices */
// 初始化控制台设备
void cons_init(void) {
    sbi_console_getchar();
}

/* cons_putc - print a single character @c to console devices */
// 将单个字符 @c 打印到控制台设备
void cons_putc(int c) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        serial_putc(c);
    }
    local_intr_restore(intr_flag);
}

/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
//从控制台获取下一个输入字符，如果没有等待的字符，则返回0。
int cons_getc(void) {
    int c = 0;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        // 轮询任何挂起的输入字符，
        // 这样即使在禁用中断的情况下（例如从内核监视器调用时）该函数也能工作。
        serial_intr();

        // grab the next character from the input buffer.
        // 从输入缓冲区中获取下一个字符。
        if (cons.rpos != cons.wpos) {
            c = cons.buf[cons.rpos++];
            if (cons.rpos == CONSBUFSIZE) {
                cons.rpos = 0;
            }
        }
    }
    local_intr_restore(intr_flag);
    return c;
}
