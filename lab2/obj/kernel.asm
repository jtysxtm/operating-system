
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	53260613          	addi	a2,a2,1330 # ffffffffc0206570 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	081010ef          	jal	ra,ffffffffc02018ce <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	88a50513          	addi	a0,a0,-1910 # ffffffffc02018e0 <etext>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	0f0010ef          	jal	ra,ffffffffc020115a <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	316010ef          	jal	ra,ffffffffc02013c0 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	2e2010ef          	jal	ra,ffffffffc02013c0 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00001517          	auipc	a0,0x1
ffffffffc0200144:	7f050513          	addi	a0,a0,2032 # ffffffffc0201930 <etext+0x50>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	7fa50513          	addi	a0,a0,2042 # ffffffffc0201950 <etext+0x70>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	77e58593          	addi	a1,a1,1918 # ffffffffc02018e0 <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	80650513          	addi	a0,a0,-2042 # ffffffffc0201970 <etext+0x90>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	81250513          	addi	a0,a0,-2030 # ffffffffc0201990 <etext+0xb0>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	3e658593          	addi	a1,a1,998 # ffffffffc0206570 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	81e50513          	addi	a0,a0,-2018 # ffffffffc02019b0 <etext+0xd0>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	7d158593          	addi	a1,a1,2001 # ffffffffc020696f <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00002517          	auipc	a0,0x2
ffffffffc02001c4:	81050513          	addi	a0,a0,-2032 # ffffffffc02019d0 <etext+0xf0>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00001617          	auipc	a2,0x1
ffffffffc02001d4:	73060613          	addi	a2,a2,1840 # ffffffffc0201900 <etext+0x20>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	73c50513          	addi	a0,a0,1852 # ffffffffc0201918 <etext+0x38>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00002617          	auipc	a2,0x2
ffffffffc02001f0:	8f460613          	addi	a2,a2,-1804 # ffffffffc0201ae0 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	90c58593          	addi	a1,a1,-1780 # ffffffffc0201b00 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	90c50513          	addi	a0,a0,-1780 # ffffffffc0201b08 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	90e60613          	addi	a2,a2,-1778 # ffffffffc0201b18 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	92e58593          	addi	a1,a1,-1746 # ffffffffc0201b40 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0201b08 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	92a60613          	addi	a2,a2,-1750 # ffffffffc0201b50 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	94258593          	addi	a1,a1,-1726 # ffffffffc0201b70 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	8d250513          	addi	a0,a0,-1838 # ffffffffc0201b08 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	7d850513          	addi	a0,a0,2008 # ffffffffc0201a48 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00001517          	auipc	a0,0x1
ffffffffc0200296:	7de50513          	addi	a0,a0,2014 # ffffffffc0201a70 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	758c8c93          	addi	s9,s9,1880 # ffffffffc0201a00 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	7e898993          	addi	s3,s3,2024 # ffffffffc0201a98 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	7e890913          	addi	s2,s2,2024 # ffffffffc0201aa0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	7e6b0b13          	addi	s6,s6,2022 # ffffffffc0201aa8 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	836a8a93          	addi	s5,s5,-1994 # ffffffffc0201b00 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	476010ef          	jal	ra,ffffffffc020174c <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	5c8010ef          	jal	ra,ffffffffc02018b0 <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00001d17          	auipc	s10,0x1
ffffffffc0200302:	702d0d13          	addi	s10,s10,1794 # ffffffffc0201a00 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	57a010ef          	jal	ra,ffffffffc0201886 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	566010ef          	jal	ra,ffffffffc0201886 <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	52a010ef          	jal	ra,ffffffffc02018b0 <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	72a50513          	addi	a0,a0,1834 # ffffffffc0201ac8 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72023          	sw	a5,64(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	7a250513          	addi	a0,a0,1954 # ffffffffc0201b80 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00002517          	auipc	a0,0x2
ffffffffc02003f8:	e4c50513          	addi	a0,a0,-436 # ffffffffc0202240 <commands+0x840>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	402010ef          	jal	ra,ffffffffc0201826 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	76e50513          	addi	a0,a0,1902 # ffffffffc0201ba0 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	3da0106f          	j	ffffffffc0201826 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	3b40106f          	j	ffffffffc020180a <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	3e80106f          	j	ffffffffc0201842 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	2fa78793          	addi	a5,a5,762 # ffffffffc0200768 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	83450513          	addi	a0,a0,-1996 # ffffffffc0201cb8 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	83c50513          	addi	a0,a0,-1988 # ffffffffc0201cd0 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	84650513          	addi	a0,a0,-1978 # ffffffffc0201ce8 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	85050513          	addi	a0,a0,-1968 # ffffffffc0201d00 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	85a50513          	addi	a0,a0,-1958 # ffffffffc0201d18 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	86450513          	addi	a0,a0,-1948 # ffffffffc0201d30 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	86e50513          	addi	a0,a0,-1938 # ffffffffc0201d48 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	87850513          	addi	a0,a0,-1928 # ffffffffc0201d60 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	88250513          	addi	a0,a0,-1918 # ffffffffc0201d78 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	88c50513          	addi	a0,a0,-1908 # ffffffffc0201d90 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	89650513          	addi	a0,a0,-1898 # ffffffffc0201da8 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	8a050513          	addi	a0,a0,-1888 # ffffffffc0201dc0 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0201dd8 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	8b450513          	addi	a0,a0,-1868 # ffffffffc0201df0 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	8be50513          	addi	a0,a0,-1858 # ffffffffc0201e08 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	8c850513          	addi	a0,a0,-1848 # ffffffffc0201e20 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	8d250513          	addi	a0,a0,-1838 # ffffffffc0201e38 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0201e50 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	8e650513          	addi	a0,a0,-1818 # ffffffffc0201e68 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	8f050513          	addi	a0,a0,-1808 # ffffffffc0201e80 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0201e98 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	90450513          	addi	a0,a0,-1788 # ffffffffc0201eb0 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	90e50513          	addi	a0,a0,-1778 # ffffffffc0201ec8 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	91850513          	addi	a0,a0,-1768 # ffffffffc0201ee0 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	92250513          	addi	a0,a0,-1758 # ffffffffc0201ef8 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	92c50513          	addi	a0,a0,-1748 # ffffffffc0201f10 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	93650513          	addi	a0,a0,-1738 # ffffffffc0201f28 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	94050513          	addi	a0,a0,-1728 # ffffffffc0201f40 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	94a50513          	addi	a0,a0,-1718 # ffffffffc0201f58 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	95450513          	addi	a0,a0,-1708 # ffffffffc0201f70 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	95e50513          	addi	a0,a0,-1698 # ffffffffc0201f88 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	96450513          	addi	a0,a0,-1692 # ffffffffc0201fa0 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	96650513          	addi	a0,a0,-1690 # ffffffffc0201fb8 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	96650513          	addi	a0,a0,-1690 # ffffffffc0201fd0 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	96e50513          	addi	a0,a0,-1682 # ffffffffc0201fe8 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	97650513          	addi	a0,a0,-1674 # ffffffffc0202000 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	97a50513          	addi	a0,a0,-1670 # ffffffffc0202018 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	50070713          	addi	a4,a4,1280 # ffffffffc0201bbc <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	58250513          	addi	a0,a0,1410 # ffffffffc0201c50 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	55650513          	addi	a0,a0,1366 # ffffffffc0201c30 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	50a50513          	addi	a0,a0,1290 # ffffffffc0201bf0 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	57e50513          	addi	a0,a0,1406 # ffffffffc0201c70 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0206430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	56e50513          	addi	a0,a0,1390 # ffffffffc0201c98 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	4da50513          	addi	a0,a0,1242 # ffffffffc0201c10 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	53c50513          	addi	a0,a0,1340 # ffffffffc0201c88 <commands+0x288>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c363          	bltz	a5,ffffffffc0200764 <trap+0xa>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200762:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200764:	f49ff06f          	j	ffffffffc02006ac <interrupt_handler>

ffffffffc0200768 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200768:	14011073          	csrw	sscratch,sp
ffffffffc020076c:	712d                	addi	sp,sp,-288
ffffffffc020076e:	e002                	sd	zero,0(sp)
ffffffffc0200770:	e406                	sd	ra,8(sp)
ffffffffc0200772:	ec0e                	sd	gp,24(sp)
ffffffffc0200774:	f012                	sd	tp,32(sp)
ffffffffc0200776:	f416                	sd	t0,40(sp)
ffffffffc0200778:	f81a                	sd	t1,48(sp)
ffffffffc020077a:	fc1e                	sd	t2,56(sp)
ffffffffc020077c:	e0a2                	sd	s0,64(sp)
ffffffffc020077e:	e4a6                	sd	s1,72(sp)
ffffffffc0200780:	e8aa                	sd	a0,80(sp)
ffffffffc0200782:	ecae                	sd	a1,88(sp)
ffffffffc0200784:	f0b2                	sd	a2,96(sp)
ffffffffc0200786:	f4b6                	sd	a3,104(sp)
ffffffffc0200788:	f8ba                	sd	a4,112(sp)
ffffffffc020078a:	fcbe                	sd	a5,120(sp)
ffffffffc020078c:	e142                	sd	a6,128(sp)
ffffffffc020078e:	e546                	sd	a7,136(sp)
ffffffffc0200790:	e94a                	sd	s2,144(sp)
ffffffffc0200792:	ed4e                	sd	s3,152(sp)
ffffffffc0200794:	f152                	sd	s4,160(sp)
ffffffffc0200796:	f556                	sd	s5,168(sp)
ffffffffc0200798:	f95a                	sd	s6,176(sp)
ffffffffc020079a:	fd5e                	sd	s7,184(sp)
ffffffffc020079c:	e1e2                	sd	s8,192(sp)
ffffffffc020079e:	e5e6                	sd	s9,200(sp)
ffffffffc02007a0:	e9ea                	sd	s10,208(sp)
ffffffffc02007a2:	edee                	sd	s11,216(sp)
ffffffffc02007a4:	f1f2                	sd	t3,224(sp)
ffffffffc02007a6:	f5f6                	sd	t4,232(sp)
ffffffffc02007a8:	f9fa                	sd	t5,240(sp)
ffffffffc02007aa:	fdfe                	sd	t6,248(sp)
ffffffffc02007ac:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007b0:	100024f3          	csrr	s1,sstatus
ffffffffc02007b4:	14102973          	csrr	s2,sepc
ffffffffc02007b8:	143029f3          	csrr	s3,stval
ffffffffc02007bc:	14202a73          	csrr	s4,scause
ffffffffc02007c0:	e822                	sd	s0,16(sp)
ffffffffc02007c2:	e226                	sd	s1,256(sp)
ffffffffc02007c4:	e64a                	sd	s2,264(sp)
ffffffffc02007c6:	ea4e                	sd	s3,272(sp)
ffffffffc02007c8:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ca:	850a                	mv	a0,sp
    jal trap
ffffffffc02007cc:	f8fff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007d0 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007d0:	6492                	ld	s1,256(sp)
ffffffffc02007d2:	6932                	ld	s2,264(sp)
ffffffffc02007d4:	10049073          	csrw	sstatus,s1
ffffffffc02007d8:	14191073          	csrw	sepc,s2
ffffffffc02007dc:	60a2                	ld	ra,8(sp)
ffffffffc02007de:	61e2                	ld	gp,24(sp)
ffffffffc02007e0:	7202                	ld	tp,32(sp)
ffffffffc02007e2:	72a2                	ld	t0,40(sp)
ffffffffc02007e4:	7342                	ld	t1,48(sp)
ffffffffc02007e6:	73e2                	ld	t2,56(sp)
ffffffffc02007e8:	6406                	ld	s0,64(sp)
ffffffffc02007ea:	64a6                	ld	s1,72(sp)
ffffffffc02007ec:	6546                	ld	a0,80(sp)
ffffffffc02007ee:	65e6                	ld	a1,88(sp)
ffffffffc02007f0:	7606                	ld	a2,96(sp)
ffffffffc02007f2:	76a6                	ld	a3,104(sp)
ffffffffc02007f4:	7746                	ld	a4,112(sp)
ffffffffc02007f6:	77e6                	ld	a5,120(sp)
ffffffffc02007f8:	680a                	ld	a6,128(sp)
ffffffffc02007fa:	68aa                	ld	a7,136(sp)
ffffffffc02007fc:	694a                	ld	s2,144(sp)
ffffffffc02007fe:	69ea                	ld	s3,152(sp)
ffffffffc0200800:	7a0a                	ld	s4,160(sp)
ffffffffc0200802:	7aaa                	ld	s5,168(sp)
ffffffffc0200804:	7b4a                	ld	s6,176(sp)
ffffffffc0200806:	7bea                	ld	s7,184(sp)
ffffffffc0200808:	6c0e                	ld	s8,192(sp)
ffffffffc020080a:	6cae                	ld	s9,200(sp)
ffffffffc020080c:	6d4e                	ld	s10,208(sp)
ffffffffc020080e:	6dee                	ld	s11,216(sp)
ffffffffc0200810:	7e0e                	ld	t3,224(sp)
ffffffffc0200812:	7eae                	ld	t4,232(sp)
ffffffffc0200814:	7f4e                	ld	t5,240(sp)
ffffffffc0200816:	7fee                	ld	t6,248(sp)
ffffffffc0200818:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc020081a:	10200073          	sret

ffffffffc020081e <buddy_init>:
    return;
}

static void buddy_init(void)
{
    for(int i=0;i<16;i++)
ffffffffc020081e:	00006797          	auipc	a5,0x6
ffffffffc0200822:	c2278793          	addi	a5,a5,-990 # ffffffffc0206440 <free_buddy+0x8>
ffffffffc0200826:	00006717          	auipc	a4,0x6
ffffffffc020082a:	d1a70713          	addi	a4,a4,-742 # ffffffffc0206540 <free_buddy+0x108>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020082e:	e79c                	sd	a5,8(a5)
ffffffffc0200830:	e39c                	sd	a5,0(a5)
ffffffffc0200832:	07c1                	addi	a5,a5,16
ffffffffc0200834:	fee79de3          	bne	a5,a4,ffffffffc020082e <buddy_init+0x10>
    {
        list_init(free_array+i);
    }
    order=0;
ffffffffc0200838:	00006797          	auipc	a5,0x6
ffffffffc020083c:	c007a023          	sw	zero,-1024(a5) # ffffffffc0206438 <free_buddy>
    nr_free=0;
ffffffffc0200840:	00006797          	auipc	a5,0x6
ffffffffc0200844:	d007a023          	sw	zero,-768(a5) # ffffffffc0206540 <free_buddy+0x108>
    return;
}
ffffffffc0200848:	8082                	ret

ffffffffc020084a <buddy_nr_free_pages>:
    return;
}
static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020084a:	00006517          	auipc	a0,0x6
ffffffffc020084e:	cf656503          	lwu	a0,-778(a0) # ffffffffc0206540 <free_buddy+0x108>
ffffffffc0200852:	8082                	ret

ffffffffc0200854 <show_buddy_array>:
static void show_buddy_array(void) {
ffffffffc0200854:	715d                	addi	sp,sp,-80
    cprintf("[!]BS: Printing buddy array:\n");
ffffffffc0200856:	00002517          	auipc	a0,0x2
ffffffffc020085a:	ad250513          	addi	a0,a0,-1326 # ffffffffc0202328 <buddy_pmm_manager_+0x38>
static void show_buddy_array(void) {
ffffffffc020085e:	fc26                	sd	s1,56(sp)
ffffffffc0200860:	f84a                	sd	s2,48(sp)
ffffffffc0200862:	f44e                	sd	s3,40(sp)
ffffffffc0200864:	f052                	sd	s4,32(sp)
ffffffffc0200866:	ec56                	sd	s5,24(sp)
ffffffffc0200868:	e85a                	sd	s6,16(sp)
ffffffffc020086a:	e45e                	sd	s7,8(sp)
ffffffffc020086c:	e486                	sd	ra,72(sp)
ffffffffc020086e:	e0a2                	sd	s0,64(sp)
ffffffffc0200870:	00006497          	auipc	s1,0x6
ffffffffc0200874:	bd048493          	addi	s1,s1,-1072 # ffffffffc0206440 <free_buddy+0x8>
    cprintf("[!]BS: Printing buddy array:\n");
ffffffffc0200878:	83fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    for (int i = 0;i < 16;i ++) {
ffffffffc020087c:	4a01                	li	s4,0
        cprintf("%d layer: ", i);
ffffffffc020087e:	00002b97          	auipc	s7,0x2
ffffffffc0200882:	acab8b93          	addi	s7,s7,-1334 # ffffffffc0202348 <buddy_pmm_manager_+0x58>
            cprintf("%d ", 1 << (p->property));
ffffffffc0200886:	4985                	li	s3,1
ffffffffc0200888:	00002917          	auipc	s2,0x2
ffffffffc020088c:	ad090913          	addi	s2,s2,-1328 # ffffffffc0202358 <buddy_pmm_manager_+0x68>
        cprintf("\n");
ffffffffc0200890:	00002b17          	auipc	s6,0x2
ffffffffc0200894:	9b0b0b13          	addi	s6,s6,-1616 # ffffffffc0202240 <commands+0x840>
    for (int i = 0;i < 16;i ++) {
ffffffffc0200898:	4ac1                	li	s5,16
        cprintf("%d layer: ", i);
ffffffffc020089a:	85d2                	mv	a1,s4
ffffffffc020089c:	855e                	mv	a0,s7
ffffffffc020089e:	819ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02008a2:	6480                	ld	s0,8(s1)
        while ((le = list_next(le)) != &(free_array[i])) {
ffffffffc02008a4:	00940c63          	beq	s0,s1,ffffffffc02008bc <show_buddy_array+0x68>
            cprintf("%d ", 1 << (p->property));
ffffffffc02008a8:	ff842583          	lw	a1,-8(s0)
ffffffffc02008ac:	854a                	mv	a0,s2
ffffffffc02008ae:	00b995bb          	sllw	a1,s3,a1
ffffffffc02008b2:	805ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02008b6:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != &(free_array[i])) {
ffffffffc02008b8:	fe9418e3          	bne	s0,s1,ffffffffc02008a8 <show_buddy_array+0x54>
        cprintf("\n");
ffffffffc02008bc:	855a                	mv	a0,s6
    for (int i = 0;i < 16;i ++) {
ffffffffc02008be:	2a05                	addiw	s4,s4,1
        cprintf("\n");
ffffffffc02008c0:	ff6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02008c4:	04c1                	addi	s1,s1,16
    for (int i = 0;i < 16;i ++) {
ffffffffc02008c6:	fd5a1ae3          	bne	s4,s5,ffffffffc020089a <show_buddy_array+0x46>
}
ffffffffc02008ca:	6406                	ld	s0,64(sp)
ffffffffc02008cc:	60a6                	ld	ra,72(sp)
ffffffffc02008ce:	74e2                	ld	s1,56(sp)
ffffffffc02008d0:	7942                	ld	s2,48(sp)
ffffffffc02008d2:	79a2                	ld	s3,40(sp)
ffffffffc02008d4:	7a02                	ld	s4,32(sp)
ffffffffc02008d6:	6ae2                	ld	s5,24(sp)
ffffffffc02008d8:	6b42                	ld	s6,16(sp)
ffffffffc02008da:	6ba2                	ld	s7,8(sp)
    cprintf("---------------------------\n");
ffffffffc02008dc:	00002517          	auipc	a0,0x2
ffffffffc02008e0:	a8450513          	addi	a0,a0,-1404 # ffffffffc0202360 <buddy_pmm_manager_+0x70>
}
ffffffffc02008e4:	6161                	addi	sp,sp,80
    cprintf("---------------------------\n");
ffffffffc02008e6:	fd0ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02008ea <buddy_check>:
//     free_page(p);
//     free_page(p1);
//     free_page(p2);
}   

static void buddy_check(void) {
ffffffffc02008ea:	1101                	addi	sp,sp,-32
ffffffffc02008ec:	ec06                	sd	ra,24(sp)
ffffffffc02008ee:	e822                	sd	s0,16(sp)
ffffffffc02008f0:	e426                	sd	s1,8(sp)
ffffffffc02008f2:	e04a                	sd	s2,0(sp)
    show_buddy_array();
ffffffffc02008f4:	f61ff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02008f8:	4505                	li	a0,1
ffffffffc02008fa:	7d6000ef          	jal	ra,ffffffffc02010d0 <alloc_pages>
ffffffffc02008fe:	28050f63          	beqz	a0,ffffffffc0200b9c <buddy_check+0x2b2>
    cprintf("nr_free is %d",nr_free);
ffffffffc0200902:	00006497          	auipc	s1,0x6
ffffffffc0200906:	b3648493          	addi	s1,s1,-1226 # ffffffffc0206438 <free_buddy>
ffffffffc020090a:	1084a583          	lw	a1,264(s1)
ffffffffc020090e:	842a                	mv	s0,a0
ffffffffc0200910:	00001517          	auipc	a0,0x1
ffffffffc0200914:	7e850513          	addi	a0,a0,2024 # ffffffffc02020f8 <commands+0x6f8>
ffffffffc0200918:	f9eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020091c:	00006797          	auipc	a5,0x6
ffffffffc0200920:	c4c78793          	addi	a5,a5,-948 # ffffffffc0206568 <pages>
ffffffffc0200924:	639c                	ld	a5,0(a5)
ffffffffc0200926:	00001717          	auipc	a4,0x1
ffffffffc020092a:	77a70713          	addi	a4,a4,1914 # ffffffffc02020a0 <commands+0x6a0>
ffffffffc020092e:	6318                	ld	a4,0(a4)
ffffffffc0200930:	40f407b3          	sub	a5,s0,a5
ffffffffc0200934:	878d                	srai	a5,a5,0x3
ffffffffc0200936:	02e787b3          	mul	a5,a5,a4
ffffffffc020093a:	00002697          	auipc	a3,0x2
ffffffffc020093e:	dde68693          	addi	a3,a3,-546 # ffffffffc0202718 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200942:	00006717          	auipc	a4,0x6
ffffffffc0200946:	ad670713          	addi	a4,a4,-1322 # ffffffffc0206418 <npage>
ffffffffc020094a:	6294                	ld	a3,0(a3)
ffffffffc020094c:	6318                	ld	a4,0(a4)
ffffffffc020094e:	0732                	slli	a4,a4,0xc
ffffffffc0200950:	97b6                	add	a5,a5,a3

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200952:	07b2                	slli	a5,a5,0xc
ffffffffc0200954:	22e7f463          	bleu	a4,a5,ffffffffc0200b7c <buddy_check+0x292>
    free_page(p0);
ffffffffc0200958:	4585                	li	a1,1
ffffffffc020095a:	8522                	mv	a0,s0
ffffffffc020095c:	7b8000ef          	jal	ra,ffffffffc0201114 <free_pages>
    assert(nr_free == 16384);
ffffffffc0200960:	1084a703          	lw	a4,264(s1)
ffffffffc0200964:	6791                	lui	a5,0x4
ffffffffc0200966:	1ef71b63          	bne	a4,a5,ffffffffc0200b5c <buddy_check+0x272>
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc020096a:	4511                	li	a0,4
ffffffffc020096c:	764000ef          	jal	ra,ffffffffc02010d0 <alloc_pages>
ffffffffc0200970:	892a                	mv	s2,a0
ffffffffc0200972:	1c050563          	beqz	a0,ffffffffc0200b3c <buddy_check+0x252>
    assert((p1 = alloc_pages(2)) != NULL);
ffffffffc0200976:	4509                	li	a0,2
ffffffffc0200978:	758000ef          	jal	ra,ffffffffc02010d0 <alloc_pages>
ffffffffc020097c:	84aa                	mv	s1,a0
ffffffffc020097e:	18050f63          	beqz	a0,ffffffffc0200b1c <buddy_check+0x232>
    assert((p2 = alloc_pages(1)) != NULL);show_buddy_array();
ffffffffc0200982:	4505                	li	a0,1
ffffffffc0200984:	74c000ef          	jal	ra,ffffffffc02010d0 <alloc_pages>
ffffffffc0200988:	842a                	mv	s0,a0
ffffffffc020098a:	16050963          	beqz	a0,ffffffffc0200afc <buddy_check+0x212>
ffffffffc020098e:	ec7ff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    free_pages(p0, 4);
ffffffffc0200992:	4591                	li	a1,4
ffffffffc0200994:	854a                	mv	a0,s2
ffffffffc0200996:	77e000ef          	jal	ra,ffffffffc0201114 <free_pages>
    cprintf("p0 free\n");show_buddy_array();
ffffffffc020099a:	00002517          	auipc	a0,0x2
ffffffffc020099e:	80650513          	addi	a0,a0,-2042 # ffffffffc02021a0 <commands+0x7a0>
ffffffffc02009a2:	f14ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02009a6:	eafff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    free_pages(p1, 2);
ffffffffc02009aa:	4589                	li	a1,2
ffffffffc02009ac:	8526                	mv	a0,s1
ffffffffc02009ae:	766000ef          	jal	ra,ffffffffc0201114 <free_pages>
    show_buddy_array();
ffffffffc02009b2:	ea3ff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    cprintf("p1 free\n");
ffffffffc02009b6:	00001517          	auipc	a0,0x1
ffffffffc02009ba:	7fa50513          	addi	a0,a0,2042 # ffffffffc02021b0 <commands+0x7b0>
ffffffffc02009be:	ef8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(p2, 1);
ffffffffc02009c2:	4585                	li	a1,1
ffffffffc02009c4:	8522                	mv	a0,s0
ffffffffc02009c6:	74e000ef          	jal	ra,ffffffffc0201114 <free_pages>
    cprintf("p2 free\n");
ffffffffc02009ca:	00001517          	auipc	a0,0x1
ffffffffc02009ce:	7f650513          	addi	a0,a0,2038 # ffffffffc02021c0 <commands+0x7c0>
ffffffffc02009d2:	ee4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    show_buddy_array();
ffffffffc02009d6:	e7fff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    assert((p0 = alloc_pages(3)) != NULL);
ffffffffc02009da:	450d                	li	a0,3
ffffffffc02009dc:	6f4000ef          	jal	ra,ffffffffc02010d0 <alloc_pages>
ffffffffc02009e0:	84aa                	mv	s1,a0
ffffffffc02009e2:	0e050d63          	beqz	a0,ffffffffc0200adc <buddy_check+0x1f2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02009e6:	450d                	li	a0,3
ffffffffc02009e8:	6e8000ef          	jal	ra,ffffffffc02010d0 <alloc_pages>
ffffffffc02009ec:	842a                	mv	s0,a0
ffffffffc02009ee:	c579                	beqz	a0,ffffffffc0200abc <buddy_check+0x1d2>
    show_buddy_array();
ffffffffc02009f0:	e65ff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    free_pages(p0, 3);
ffffffffc02009f4:	458d                	li	a1,3
ffffffffc02009f6:	8526                	mv	a0,s1
ffffffffc02009f8:	71c000ef          	jal	ra,ffffffffc0201114 <free_pages>
    free_pages(p1, 3);
ffffffffc02009fc:	8522                	mv	a0,s0
ffffffffc02009fe:	458d                	li	a1,3
ffffffffc0200a00:	714000ef          	jal	ra,ffffffffc0201114 <free_pages>
    show_buddy_array();
ffffffffc0200a04:	e51ff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>

    basic_check();// 调用 basic_check 函数，检查基本功能是否正常

    struct Page *p0 = alloc_pages(5), *p1, *p2;// 分配一个包含5个页面的连续内存块
ffffffffc0200a08:	4515                	li	a0,5
ffffffffc0200a0a:	6c6000ef          	jal	ra,ffffffffc02010d0 <alloc_pages>
ffffffffc0200a0e:	842a                	mv	s0,a0
    assert(p0 != NULL);//确保返回的指针不为NULL
ffffffffc0200a10:	c551                	beqz	a0,ffffffffc0200a9c <buddy_check+0x1b2>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a12:	651c                	ld	a5,8(a0)
ffffffffc0200a14:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0));// 确保返回的页面有 PageProperty 标志(被使用)
ffffffffc0200a16:	8b85                	andi	a5,a5,1
ffffffffc0200a18:	c3b5                	beqz	a5,ffffffffc0200a7c <buddy_check+0x192>

    // //存储当前可用页面数量
    // unsigned int nr_free_store = nr_free;
    // nr_free = 0;

    free_pages(p0 + 2, 3);// 释放 p0 中的第3、4、5个页面
ffffffffc0200a1a:	05050493          	addi	s1,a0,80
ffffffffc0200a1e:	458d                	li	a1,3
ffffffffc0200a20:	8526                	mv	a0,s1
ffffffffc0200a22:	6f2000ef          	jal	ra,ffffffffc0201114 <free_pages>
    cprintf("free 345\n");
ffffffffc0200a26:	00002517          	auipc	a0,0x2
ffffffffc0200a2a:	81250513          	addi	a0,a0,-2030 # ffffffffc0202238 <commands+0x838>
ffffffffc0200a2e:	e88ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200a32:	6c3c                	ld	a5,88(s0)
ffffffffc0200a34:	8385                	srli	a5,a5,0x1
    //assert(alloc_pages(4) != NULL);// 确保无法分配包含4个页面的连续内存块
    assert(!PageProperty(p0 + 2) && p0[2].property == 3);// 确保 p0 中的第3个页面有 PageProperty 标志，且 property 值为3
ffffffffc0200a36:	8b85                	andi	a5,a5,1
ffffffffc0200a38:	e395                	bnez	a5,ffffffffc0200a5c <buddy_check+0x172>
ffffffffc0200a3a:	5038                	lw	a4,96(s0)
ffffffffc0200a3c:	478d                	li	a5,3
ffffffffc0200a3e:	00f71f63          	bne	a4,a5,ffffffffc0200a5c <buddy_check+0x172>
    assert((p1 = alloc_pages(3)) != NULL);// 分配一个包含3个页面的连续内存块
ffffffffc0200a42:	450d                	li	a0,3
ffffffffc0200a44:	68c000ef          	jal	ra,ffffffffc02010d0 <alloc_pages>
ffffffffc0200a48:	18050a63          	beqz	a0,ffffffffc0200bdc <buddy_check+0x2f2>
    // assert(alloc_page() == NULL);// 确保无法分配单个页面
    assert(p0 + 2 == p1);// 确保 p1 是 p0 中的第3个页面
ffffffffc0200a4c:	16a49863          	bne	s1,a0,ffffffffc0200bbc <buddy_check+0x2d2>
    //     count --, total -= p->property;
    // }
    // assert(count == 0);
    // assert(total == 0);

}
ffffffffc0200a50:	60e2                	ld	ra,24(sp)
ffffffffc0200a52:	6442                	ld	s0,16(sp)
ffffffffc0200a54:	64a2                	ld	s1,8(sp)
ffffffffc0200a56:	6902                	ld	s2,0(sp)
ffffffffc0200a58:	6105                	addi	sp,sp,32
ffffffffc0200a5a:	8082                	ret
    assert(!PageProperty(p0 + 2) && p0[2].property == 3);// 确保 p0 中的第3个页面有 PageProperty 标志，且 property 值为3
ffffffffc0200a5c:	00001697          	auipc	a3,0x1
ffffffffc0200a60:	7ec68693          	addi	a3,a3,2028 # ffffffffc0202248 <commands+0x848>
ffffffffc0200a64:	00001617          	auipc	a2,0x1
ffffffffc0200a68:	66460613          	addi	a2,a2,1636 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200a6c:	12100593          	li	a1,289
ffffffffc0200a70:	00001517          	auipc	a0,0x1
ffffffffc0200a74:	67050513          	addi	a0,a0,1648 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200a78:	935ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0));// 确保返回的页面有 PageProperty 标志(被使用)
ffffffffc0200a7c:	00001697          	auipc	a3,0x1
ffffffffc0200a80:	7a468693          	addi	a3,a3,1956 # ffffffffc0202220 <commands+0x820>
ffffffffc0200a84:	00001617          	auipc	a2,0x1
ffffffffc0200a88:	64460613          	addi	a2,a2,1604 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200a8c:	11200593          	li	a1,274
ffffffffc0200a90:	00001517          	auipc	a0,0x1
ffffffffc0200a94:	65050513          	addi	a0,a0,1616 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200a98:	915ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);//确保返回的指针不为NULL
ffffffffc0200a9c:	00001697          	auipc	a3,0x1
ffffffffc0200aa0:	77468693          	addi	a3,a3,1908 # ffffffffc0202210 <commands+0x810>
ffffffffc0200aa4:	00001617          	auipc	a2,0x1
ffffffffc0200aa8:	62460613          	addi	a2,a2,1572 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200aac:	11100593          	li	a1,273
ffffffffc0200ab0:	00001517          	auipc	a0,0x1
ffffffffc0200ab4:	63050513          	addi	a0,a0,1584 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200ab8:	8f5ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200abc:	00001697          	auipc	a3,0x1
ffffffffc0200ac0:	73468693          	addi	a3,a3,1844 # ffffffffc02021f0 <commands+0x7f0>
ffffffffc0200ac4:	00001617          	auipc	a2,0x1
ffffffffc0200ac8:	60460613          	addi	a2,a2,1540 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200acc:	0cc00593          	li	a1,204
ffffffffc0200ad0:	00001517          	auipc	a0,0x1
ffffffffc0200ad4:	61050513          	addi	a0,a0,1552 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200ad8:	8d5ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(3)) != NULL);
ffffffffc0200adc:	00001697          	auipc	a3,0x1
ffffffffc0200ae0:	6f468693          	addi	a3,a3,1780 # ffffffffc02021d0 <commands+0x7d0>
ffffffffc0200ae4:	00001617          	auipc	a2,0x1
ffffffffc0200ae8:	5e460613          	addi	a2,a2,1508 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200aec:	0cb00593          	li	a1,203
ffffffffc0200af0:	00001517          	auipc	a0,0x1
ffffffffc0200af4:	5f050513          	addi	a0,a0,1520 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200af8:	8b5ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_pages(1)) != NULL);show_buddy_array();
ffffffffc0200afc:	00001697          	auipc	a3,0x1
ffffffffc0200b00:	68468693          	addi	a3,a3,1668 # ffffffffc0202180 <commands+0x780>
ffffffffc0200b04:	00001617          	auipc	a2,0x1
ffffffffc0200b08:	5c460613          	addi	a2,a2,1476 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200b0c:	0c100593          	li	a1,193
ffffffffc0200b10:	00001517          	auipc	a0,0x1
ffffffffc0200b14:	5d050513          	addi	a0,a0,1488 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200b18:	895ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(2)) != NULL);
ffffffffc0200b1c:	00001697          	auipc	a3,0x1
ffffffffc0200b20:	64468693          	addi	a3,a3,1604 # ffffffffc0202160 <commands+0x760>
ffffffffc0200b24:	00001617          	auipc	a2,0x1
ffffffffc0200b28:	5a460613          	addi	a2,a2,1444 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200b2c:	0c000593          	li	a1,192
ffffffffc0200b30:	00001517          	auipc	a0,0x1
ffffffffc0200b34:	5b050513          	addi	a0,a0,1456 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200b38:	875ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0200b3c:	00001697          	auipc	a3,0x1
ffffffffc0200b40:	60468693          	addi	a3,a3,1540 # ffffffffc0202140 <commands+0x740>
ffffffffc0200b44:	00001617          	auipc	a2,0x1
ffffffffc0200b48:	58460613          	addi	a2,a2,1412 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200b4c:	0bf00593          	li	a1,191
ffffffffc0200b50:	00001517          	auipc	a0,0x1
ffffffffc0200b54:	59050513          	addi	a0,a0,1424 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200b58:	855ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 16384);
ffffffffc0200b5c:	00001697          	auipc	a3,0x1
ffffffffc0200b60:	5cc68693          	addi	a3,a3,1484 # ffffffffc0202128 <commands+0x728>
ffffffffc0200b64:	00001617          	auipc	a2,0x1
ffffffffc0200b68:	56460613          	addi	a2,a2,1380 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200b6c:	0bc00593          	li	a1,188
ffffffffc0200b70:	00001517          	auipc	a0,0x1
ffffffffc0200b74:	57050513          	addi	a0,a0,1392 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200b78:	835ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b7c:	00001697          	auipc	a3,0x1
ffffffffc0200b80:	58c68693          	addi	a3,a3,1420 # ffffffffc0202108 <commands+0x708>
ffffffffc0200b84:	00001617          	auipc	a2,0x1
ffffffffc0200b88:	54460613          	addi	a2,a2,1348 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200b8c:	0b100593          	li	a1,177
ffffffffc0200b90:	00001517          	auipc	a0,0x1
ffffffffc0200b94:	55050513          	addi	a0,a0,1360 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200b98:	815ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b9c:	00001697          	auipc	a3,0x1
ffffffffc0200ba0:	50c68693          	addi	a3,a3,1292 # ffffffffc02020a8 <commands+0x6a8>
ffffffffc0200ba4:	00001617          	auipc	a2,0x1
ffffffffc0200ba8:	52460613          	addi	a2,a2,1316 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200bac:	0a800593          	li	a1,168
ffffffffc0200bb0:	00001517          	auipc	a0,0x1
ffffffffc0200bb4:	53050513          	addi	a0,a0,1328 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200bb8:	ff4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 2 == p1);// 确保 p1 是 p0 中的第3个页面
ffffffffc0200bbc:	00001697          	auipc	a3,0x1
ffffffffc0200bc0:	6bc68693          	addi	a3,a3,1724 # ffffffffc0202278 <commands+0x878>
ffffffffc0200bc4:	00001617          	auipc	a2,0x1
ffffffffc0200bc8:	50460613          	addi	a2,a2,1284 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200bcc:	12400593          	li	a1,292
ffffffffc0200bd0:	00001517          	auipc	a0,0x1
ffffffffc0200bd4:	51050513          	addi	a0,a0,1296 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200bd8:	fd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(3)) != NULL);// 分配一个包含3个页面的连续内存块
ffffffffc0200bdc:	00001697          	auipc	a3,0x1
ffffffffc0200be0:	61468693          	addi	a3,a3,1556 # ffffffffc02021f0 <commands+0x7f0>
ffffffffc0200be4:	00001617          	auipc	a2,0x1
ffffffffc0200be8:	4e460613          	addi	a2,a2,1252 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200bec:	12200593          	li	a1,290
ffffffffc0200bf0:	00001517          	auipc	a0,0x1
ffffffffc0200bf4:	4f050513          	addi	a0,a0,1264 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200bf8:	fb4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bfc <buddy_free_pages>:
{
ffffffffc0200bfc:	7159                	addi	sp,sp,-112
ffffffffc0200bfe:	f486                	sd	ra,104(sp)
ffffffffc0200c00:	f0a2                	sd	s0,96(sp)
ffffffffc0200c02:	eca6                	sd	s1,88(sp)
ffffffffc0200c04:	e8ca                	sd	s2,80(sp)
ffffffffc0200c06:	e4ce                	sd	s3,72(sp)
ffffffffc0200c08:	e0d2                	sd	s4,64(sp)
ffffffffc0200c0a:	fc56                	sd	s5,56(sp)
ffffffffc0200c0c:	f85a                	sd	s6,48(sp)
ffffffffc0200c0e:	f45e                	sd	s7,40(sp)
ffffffffc0200c10:	f062                	sd	s8,32(sp)
ffffffffc0200c12:	ec66                	sd	s9,24(sp)
ffffffffc0200c14:	e86a                	sd	s10,16(sp)
ffffffffc0200c16:	e46e                	sd	s11,8(sp)
    assert(n>0);
ffffffffc0200c18:	18058963          	beqz	a1,ffffffffc0200daa <buddy_free_pages+0x1ae>
    nr_free+=1<<base->property;  
ffffffffc0200c1c:	490c                	lw	a1,16(a0)
ffffffffc0200c1e:	00006c97          	auipc	s9,0x6
ffffffffc0200c22:	81ac8c93          	addi	s9,s9,-2022 # ffffffffc0206438 <free_buddy>
ffffffffc0200c26:	108ca783          	lw	a5,264(s9)
ffffffffc0200c2a:	4405                	li	s0,1
ffffffffc0200c2c:	00b4173b          	sllw	a4,s0,a1
ffffffffc0200c30:	8baa                	mv	s7,a0
ffffffffc0200c32:	9fb9                	addw	a5,a5,a4
    cprintf("base property is %d",base->property);
ffffffffc0200c34:	00001517          	auipc	a0,0x1
ffffffffc0200c38:	65c50513          	addi	a0,a0,1628 # ffffffffc0202290 <commands+0x890>
    nr_free+=1<<base->property;  
ffffffffc0200c3c:	00006717          	auipc	a4,0x6
ffffffffc0200c40:	90f72223          	sw	a5,-1788(a4) # ffffffffc0206540 <free_buddy+0x108>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c44:	00006d17          	auipc	s10,0x6
ffffffffc0200c48:	924d0d13          	addi	s10,s10,-1756 # ffffffffc0206568 <pages>
    cprintf("base property is %d",base->property);
ffffffffc0200c4c:	c6aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200c50:	000d3783          	ld	a5,0(s10)
ffffffffc0200c54:	00001917          	auipc	s2,0x1
ffffffffc0200c58:	44c90913          	addi	s2,s2,1100 # ffffffffc02020a0 <commands+0x6a0>
ffffffffc0200c5c:	00093703          	ld	a4,0(s2)
ffffffffc0200c60:	40fb87b3          	sub	a5,s7,a5
ffffffffc0200c64:	878d                	srai	a5,a5,0x3
ffffffffc0200c66:	02e787b3          	mul	a5,a5,a4
ffffffffc0200c6a:	00002d97          	auipc	s11,0x2
ffffffffc0200c6e:	aaed8d93          	addi	s11,s11,-1362 # ffffffffc0202718 <nbase>
ffffffffc0200c72:	000db583          	ld	a1,0(s11)
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200c76:	00006497          	auipc	s1,0x6
ffffffffc0200c7a:	8da48493          	addi	s1,s1,-1830 # ffffffffc0206550 <fppn>
    uint32_t power=page->property;
ffffffffc0200c7e:	010ba603          	lw	a2,16(s7)
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200c82:	6094                	ld	a3,0(s1)
    list_add(&(free_array[free_page->property]),&(free_page->page_link));
ffffffffc0200c84:	018b8c13          	addi	s8,s7,24
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200c88:	00c4143b          	sllw	s0,s0,a2
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c8c:	02061713          	slli	a4,a2,0x20
ffffffffc0200c90:	8371                	srli	a4,a4,0x1c
ffffffffc0200c92:	97ae                	add	a5,a5,a1
ffffffffc0200c94:	40d785b3          	sub	a1,a5,a3
ffffffffc0200c98:	8c2d                	xor	s0,s0,a1
    return page+(ppn-page2ppn(page));
ffffffffc0200c9a:	40f687b3          	sub	a5,a3,a5
ffffffffc0200c9e:	97a2                	add	a5,a5,s0
ffffffffc0200ca0:	00279413          	slli	s0,a5,0x2
ffffffffc0200ca4:	943e                	add	s0,s0,a5
ffffffffc0200ca6:	00ec85b3          	add	a1,s9,a4
ffffffffc0200caa:	040e                	slli	s0,s0,0x3
ffffffffc0200cac:	6994                	ld	a3,16(a1)
ffffffffc0200cae:	945e                	add	s0,s0,s7
ffffffffc0200cb0:	641c                	ld	a5,8(s0)
    list_add(&(free_array[free_page->property]),&(free_page->page_link));
ffffffffc0200cb2:	0721                	addi	a4,a4,8
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200cb4:	0186b023          	sd	s8,0(a3)
ffffffffc0200cb8:	0185b823          	sd	s8,16(a1)
ffffffffc0200cbc:	9766                	add	a4,a4,s9
ffffffffc0200cbe:	8385                	srli	a5,a5,0x1
    elm->next = next;
ffffffffc0200cc0:	02dbb023          	sd	a3,32(s7)
    elm->prev = prev;
ffffffffc0200cc4:	00ebbc23          	sd	a4,24(s7)
    while(!PageProperty(free_page_buddy)&&free_page->property<14)
ffffffffc0200cc8:	8b85                	andi	a5,a5,1
ffffffffc0200cca:	e3e9                	bnez	a5,ffffffffc0200d8c <buddy_free_pages+0x190>
ffffffffc0200ccc:	47b5                	li	a5,13
ffffffffc0200cce:	0ac7ef63          	bltu	a5,a2,ffffffffc0200d8c <buddy_free_pages+0x190>
        cprintf("in while\n");
ffffffffc0200cd2:	00001a17          	auipc	s4,0x1
ffffffffc0200cd6:	5d6a0a13          	addi	s4,s4,1494 # ffffffffc02022a8 <commands+0x8a8>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200cda:	5b75                	li	s6,-3
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200cdc:	4985                	li	s3,1
    while(!PageProperty(free_page_buddy)&&free_page->property<14)
ffffffffc0200cde:	4ab5                	li	s5,13
ffffffffc0200ce0:	a019                	j	ffffffffc0200ce6 <buddy_free_pages+0xea>
ffffffffc0200ce2:	0abae563          	bltu	s5,a1,ffffffffc0200d8c <buddy_free_pages+0x190>
        cprintf("in while\n");
ffffffffc0200ce6:	8552                	mv	a0,s4
ffffffffc0200ce8:	bceff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        if(free_page_buddy<free_page)
ffffffffc0200cec:	01747d63          	bleu	s7,s0,ffffffffc0200d06 <buddy_free_pages+0x10a>
            free_page->property=0;
ffffffffc0200cf0:	000ba823          	sw	zero,16(s7)
ffffffffc0200cf4:	008b8793          	addi	a5,s7,8
ffffffffc0200cf8:	6167b02f          	amoand.d	zero,s6,(a5)
ffffffffc0200cfc:	87de                	mv	a5,s7
ffffffffc0200cfe:	01840c13          	addi	s8,s0,24
ffffffffc0200d02:	8ba2                	mv	s7,s0
ffffffffc0200d04:	843e                	mv	s0,a5
ffffffffc0200d06:	000d3783          	ld	a5,0(s10)
ffffffffc0200d0a:	00093703          	ld	a4,0(s2)
        free_page->property+=1;
ffffffffc0200d0e:	010ba683          	lw	a3,16(s7)
ffffffffc0200d12:	40fb87b3          	sub	a5,s7,a5
ffffffffc0200d16:	878d                	srai	a5,a5,0x3
ffffffffc0200d18:	02e787b3          	mul	a5,a5,a4
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d1c:	018bb503          	ld	a0,24(s7)
ffffffffc0200d20:	020bb703          	ld	a4,32(s7)
ffffffffc0200d24:	000db803          	ld	a6,0(s11)
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200d28:	6090                	ld	a2,0(s1)
        free_page->property+=1;
ffffffffc0200d2a:	2685                	addiw	a3,a3,1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200d2c:	e518                	sd	a4,8(a0)
ffffffffc0200d2e:	0006859b          	sext.w	a1,a3
    next->prev = prev;
ffffffffc0200d32:	e308                	sd	a0,0(a4)
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200d34:	00b9973b          	sllw	a4,s3,a1
ffffffffc0200d38:	97c2                	add	a5,a5,a6
ffffffffc0200d3a:	40c788b3          	sub	a7,a5,a2
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d3e:	6c08                	ld	a0,24(s0)
ffffffffc0200d40:	02043803          	ld	a6,32(s0)
    return page+(ppn-page2ppn(page));
ffffffffc0200d44:	40f607b3          	sub	a5,a2,a5
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200d48:	01174433          	xor	s0,a4,a7
    return page+(ppn-page2ppn(page));
ffffffffc0200d4c:	97a2                	add	a5,a5,s0
    __list_add(elm, listelm, listelm->next);
ffffffffc0200d4e:	02069713          	slli	a4,a3,0x20
ffffffffc0200d52:	8371                	srli	a4,a4,0x1c
ffffffffc0200d54:	00279413          	slli	s0,a5,0x2
    prev->next = next;
ffffffffc0200d58:	01053423          	sd	a6,8(a0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200d5c:	00ec88b3          	add	a7,s9,a4
ffffffffc0200d60:	943e                	add	s0,s0,a5
ffffffffc0200d62:	0108b603          	ld	a2,16(a7)
ffffffffc0200d66:	040e                	slli	s0,s0,0x3
    next->prev = prev;
ffffffffc0200d68:	00a83023          	sd	a0,0(a6)
ffffffffc0200d6c:	945e                	add	s0,s0,s7
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200d6e:	641c                	ld	a5,8(s0)
        free_page->property+=1;
ffffffffc0200d70:	00dba823          	sw	a3,16(s7)
    prev->next = next->prev = elm;
ffffffffc0200d74:	01863023          	sd	s8,0(a2)
        list_add(&(free_array[free_page->property]),&(free_page->page_link));
ffffffffc0200d78:	0721                	addi	a4,a4,8
ffffffffc0200d7a:	0188b823          	sd	s8,16(a7)
ffffffffc0200d7e:	9766                	add	a4,a4,s9
    elm->next = next;
ffffffffc0200d80:	02cbb023          	sd	a2,32(s7)
    elm->prev = prev;
ffffffffc0200d84:	00ebbc23          	sd	a4,24(s7)
    while(!PageProperty(free_page_buddy)&&free_page->property<14)
ffffffffc0200d88:	8b89                	andi	a5,a5,2
ffffffffc0200d8a:	dfa1                	beqz	a5,ffffffffc0200ce2 <buddy_free_pages+0xe6>
}
ffffffffc0200d8c:	70a6                	ld	ra,104(sp)
ffffffffc0200d8e:	7406                	ld	s0,96(sp)
ffffffffc0200d90:	64e6                	ld	s1,88(sp)
ffffffffc0200d92:	6946                	ld	s2,80(sp)
ffffffffc0200d94:	69a6                	ld	s3,72(sp)
ffffffffc0200d96:	6a06                	ld	s4,64(sp)
ffffffffc0200d98:	7ae2                	ld	s5,56(sp)
ffffffffc0200d9a:	7b42                	ld	s6,48(sp)
ffffffffc0200d9c:	7ba2                	ld	s7,40(sp)
ffffffffc0200d9e:	7c02                	ld	s8,32(sp)
ffffffffc0200da0:	6ce2                	ld	s9,24(sp)
ffffffffc0200da2:	6d42                	ld	s10,16(sp)
ffffffffc0200da4:	6da2                	ld	s11,8(sp)
ffffffffc0200da6:	6165                	addi	sp,sp,112
ffffffffc0200da8:	8082                	ret
    assert(n>0);
ffffffffc0200daa:	00001697          	auipc	a3,0x1
ffffffffc0200dae:	4de68693          	addi	a3,a3,1246 # ffffffffc0202288 <commands+0x888>
ffffffffc0200db2:	00001617          	auipc	a2,0x1
ffffffffc0200db6:	31660613          	addi	a2,a2,790 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200dba:	08300593          	li	a1,131
ffffffffc0200dbe:	00001517          	auipc	a0,0x1
ffffffffc0200dc2:	32250513          	addi	a0,a0,802 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200dc6:	de6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200dca <GET_POWER_OF_2>:
{
ffffffffc0200dca:	1101                	addi	sp,sp,-32
ffffffffc0200dcc:	e822                	sd	s0,16(sp)
ffffffffc0200dce:	ec06                	sd	ra,24(sp)
ffffffffc0200dd0:	e426                	sd	s1,8(sp)
ffffffffc0200dd2:	e04a                	sd	s2,0(sp)
    while(n>>1)
ffffffffc0200dd4:	00155413          	srli	s0,a0,0x1
ffffffffc0200dd8:	cc1d                	beqz	s0,ffffffffc0200e16 <GET_POWER_OF_2+0x4c>
ffffffffc0200dda:	85aa                	mv	a1,a0
    uint32_t power = 0;
ffffffffc0200ddc:	4481                	li	s1,0
        cprintf("n is %d\n",n);
ffffffffc0200dde:	00001917          	auipc	s2,0x1
ffffffffc0200de2:	25290913          	addi	s2,s2,594 # ffffffffc0202030 <commands+0x630>
ffffffffc0200de6:	a011                	j	ffffffffc0200dea <GET_POWER_OF_2+0x20>
ffffffffc0200de8:	843e                	mv	s0,a5
ffffffffc0200dea:	854a                	mv	a0,s2
ffffffffc0200dec:	acaff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    while(n>>1)
ffffffffc0200df0:	00145793          	srli	a5,s0,0x1
ffffffffc0200df4:	85a2                	mv	a1,s0
        power++;
ffffffffc0200df6:	2485                	addiw	s1,s1,1
    while(n>>1)
ffffffffc0200df8:	fbe5                	bnez	a5,ffffffffc0200de8 <GET_POWER_OF_2+0x1e>
    cprintf("power is %d\n",power);
ffffffffc0200dfa:	85a6                	mv	a1,s1
ffffffffc0200dfc:	00001517          	auipc	a0,0x1
ffffffffc0200e00:	24450513          	addi	a0,a0,580 # ffffffffc0202040 <commands+0x640>
ffffffffc0200e04:	ab2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
}
ffffffffc0200e08:	60e2                	ld	ra,24(sp)
ffffffffc0200e0a:	6442                	ld	s0,16(sp)
ffffffffc0200e0c:	8526                	mv	a0,s1
ffffffffc0200e0e:	6902                	ld	s2,0(sp)
ffffffffc0200e10:	64a2                	ld	s1,8(sp)
ffffffffc0200e12:	6105                	addi	sp,sp,32
ffffffffc0200e14:	8082                	ret
    uint32_t power = 0;
ffffffffc0200e16:	4481                	li	s1,0
ffffffffc0200e18:	b7cd                	j	ffffffffc0200dfa <GET_POWER_OF_2+0x30>

ffffffffc0200e1a <buddy_alloc_pages>:
{
ffffffffc0200e1a:	1101                	addi	sp,sp,-32
ffffffffc0200e1c:	ec06                	sd	ra,24(sp)
ffffffffc0200e1e:	e822                	sd	s0,16(sp)
ffffffffc0200e20:	e426                	sd	s1,8(sp)
ffffffffc0200e22:	e04a                	sd	s2,0(sp)
    assert (real_n>0);
ffffffffc0200e24:	18050d63          	beqz	a0,ffffffffc0200fbe <buddy_alloc_pages+0x1a4>
    if(real_n>nr_free)
ffffffffc0200e28:	00005717          	auipc	a4,0x5
ffffffffc0200e2c:	71876703          	lwu	a4,1816(a4) # ffffffffc0206540 <free_buddy+0x108>
ffffffffc0200e30:	16a76f63          	bltu	a4,a0,ffffffffc0200fae <buddy_alloc_pages+0x194>
    order=IS_POWER_OF_2(real_n)?GET_POWER_OF_2(real_n):GET_POWER_OF_2(real_n)+1;
ffffffffc0200e34:	fff50713          	addi	a4,a0,-1
ffffffffc0200e38:	00a777b3          	and	a5,a4,a0
ffffffffc0200e3c:	cbed                	beqz	a5,ffffffffc0200f2e <buddy_alloc_pages+0x114>
ffffffffc0200e3e:	f8dff0ef          	jal	ra,ffffffffc0200dca <GET_POWER_OF_2>
ffffffffc0200e42:	0015079b          	addiw	a5,a0,1
    cprintf("order is %d\n",order);
ffffffffc0200e46:	85be                	mv	a1,a5
ffffffffc0200e48:	00001517          	auipc	a0,0x1
ffffffffc0200e4c:	21850513          	addi	a0,a0,536 # ffffffffc0202060 <commands+0x660>
    order=IS_POWER_OF_2(real_n)?GET_POWER_OF_2(real_n):GET_POWER_OF_2(real_n)+1;
ffffffffc0200e50:	00005417          	auipc	s0,0x5
ffffffffc0200e54:	5e840413          	addi	s0,s0,1512 # ffffffffc0206438 <free_buddy>
ffffffffc0200e58:	00005717          	auipc	a4,0x5
ffffffffc0200e5c:	5ef72023          	sw	a5,1504(a4) # ffffffffc0206438 <free_buddy>
    cprintf("order is %d\n",order);
ffffffffc0200e60:	a56ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    size_t n=1<<order;
ffffffffc0200e64:	401c                	lw	a5,0(s0)
ffffffffc0200e66:	4085                	li	ra,1
        for(int i=order;i<16;i++)
ffffffffc0200e68:	4fbd                	li	t6,15
        if(!list_empty(&(free_array[order])))
ffffffffc0200e6a:	02079293          	slli	t0,a5,0x20
ffffffffc0200e6e:	01c2d293          	srli	t0,t0,0x1c
        for(int i=order;i<16;i++)
ffffffffc0200e72:	0007881b          	sext.w	a6,a5
        if(!list_empty(&(free_array[order])))
ffffffffc0200e76:	00828313          	addi	t1,t0,8
ffffffffc0200e7a:	92a2                	add	t0,t0,s0
            if(!list_empty(&(free_array[i])))
ffffffffc0200e7c:	00481e13          	slli	t3,a6,0x4
ffffffffc0200e80:	00280e93          	addi	t4,a6,2
ffffffffc0200e84:	0102b883          	ld	a7,16(t0)
ffffffffc0200e88:	008e0f13          	addi	t5,t3,8
ffffffffc0200e8c:	0e92                	slli	t4,t4,0x4
    size_t n=1<<order;
ffffffffc0200e8e:	00f090bb          	sllw	ra,ra,a5
        if(!list_empty(&(free_array[order])))
ffffffffc0200e92:	9322                	add	t1,t1,s0
            if(!list_empty(&(free_array[i])))
ffffffffc0200e94:	9f22                	add	t5,t5,s0
ffffffffc0200e96:	9ea2                	add	t4,t4,s0
    return list->next == list;
ffffffffc0200e98:	9e22                	add	t3,t3,s0
        for(int i=order;i<16;i++)
ffffffffc0200e9a:	4541                	li	a0,16
ffffffffc0200e9c:	fff8049b          	addiw	s1,a6,-1
                struct Page *page2=page1+(1<<(i-1));
ffffffffc0200ea0:	4385                	li	t2,1
        if(!list_empty(&(free_array[order])))
ffffffffc0200ea2:	09131b63          	bne	t1,a7,ffffffffc0200f38 <buddy_alloc_pages+0x11e>
        for(int i=order;i<16;i++)
ffffffffc0200ea6:	ff0fcee3          	blt	t6,a6,ffffffffc0200ea2 <buddy_alloc_pages+0x88>
ffffffffc0200eaa:	010e3583          	ld	a1,16(t3)
            if(!list_empty(&(free_array[i])))
ffffffffc0200eae:	0ebf1e63          	bne	t5,a1,ffffffffc0200faa <buddy_alloc_pages+0x190>
ffffffffc0200eb2:	87f6                	mv	a5,t4
ffffffffc0200eb4:	8642                	mv	a2,a6
ffffffffc0200eb6:	a019                	j	ffffffffc0200ebc <buddy_alloc_pages+0xa2>
ffffffffc0200eb8:	87b6                	mv	a5,a3
ffffffffc0200eba:	863a                	mv	a2,a4
        for(int i=order;i<16;i++)
ffffffffc0200ebc:	0016071b          	addiw	a4,a2,1
ffffffffc0200ec0:	fea701e3          	beq	a4,a0,ffffffffc0200ea2 <buddy_alloc_pages+0x88>
ffffffffc0200ec4:	638c                	ld	a1,0(a5)
ffffffffc0200ec6:	01078693          	addi	a3,a5,16 # 4010 <BASE_ADDRESS-0xffffffffc01fbff0>
            if(!list_empty(&(free_array[i])))
ffffffffc0200eca:	17e1                	addi	a5,a5,-8
ffffffffc0200ecc:	fef586e3          	beq	a1,a5,ffffffffc0200eb8 <buddy_alloc_pages+0x9e>
                struct Page *page2=page1+(1<<(i-1));
ffffffffc0200ed0:	00c397bb          	sllw	a5,t2,a2
ffffffffc0200ed4:	00279713          	slli	a4,a5,0x2
ffffffffc0200ed8:	973e                	add	a4,a4,a5
ffffffffc0200eda:	070e                	slli	a4,a4,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200edc:	0085b883          	ld	a7,8(a1)
ffffffffc0200ee0:	0005b903          	ld	s2,0(a1)
                page1->property=i-1;
ffffffffc0200ee4:	0006079b          	sext.w	a5,a2
                struct Page *page2=page1+(1<<(i-1));
ffffffffc0200ee8:	1721                	addi	a4,a4,-24
                page1->property=i-1;
ffffffffc0200eea:	fef5ac23          	sw	a5,-8(a1)
                struct Page *page2=page1+(1<<(i-1));
ffffffffc0200eee:	972e                	add	a4,a4,a1
                page2->property=i-1;
ffffffffc0200ef0:	cb1c                	sw	a5,16(a4)
                list_add(&(free_array[i-1]),&(page2->page_link));
ffffffffc0200ef2:	0612                	slli	a2,a2,0x4
    prev->next = next;
ffffffffc0200ef4:	01193423          	sd	a7,8(s2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ef8:	00c406b3          	add	a3,s0,a2
ffffffffc0200efc:	6a9c                	ld	a5,16(a3)
    next->prev = prev;
ffffffffc0200efe:	0128b023          	sd	s2,0(a7)
ffffffffc0200f02:	01870893          	addi	a7,a4,24
    prev->next = next->prev = elm;
ffffffffc0200f06:	0117b023          	sd	a7,0(a5)
ffffffffc0200f0a:	0116b823          	sd	a7,16(a3)
    elm->next = next;
ffffffffc0200f0e:	f31c                	sd	a5,32(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200f10:	0106b883          	ld	a7,16(a3)
ffffffffc0200f14:	0621                	addi	a2,a2,8
ffffffffc0200f16:	00c407b3          	add	a5,s0,a2
    elm->prev = prev;
ffffffffc0200f1a:	ef1c                	sd	a5,24(a4)
    prev->next = next->prev = elm;
ffffffffc0200f1c:	00b8b023          	sd	a1,0(a7)
ffffffffc0200f20:	ea8c                	sd	a1,16(a3)
    elm->next = next;
ffffffffc0200f22:	0115b423          	sd	a7,8(a1)
    elm->prev = prev;
ffffffffc0200f26:	e19c                	sd	a5,0(a1)
ffffffffc0200f28:	0102b883          	ld	a7,16(t0)
ffffffffc0200f2c:	bf9d                	j	ffffffffc0200ea2 <buddy_alloc_pages+0x88>
    order=IS_POWER_OF_2(real_n)?GET_POWER_OF_2(real_n):GET_POWER_OF_2(real_n)+1;
ffffffffc0200f2e:	e9dff0ef          	jal	ra,ffffffffc0200dca <GET_POWER_OF_2>
ffffffffc0200f32:	0005079b          	sext.w	a5,a0
ffffffffc0200f36:	bf01                	j	ffffffffc0200e46 <buddy_alloc_pages+0x2c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f38:	0008b703          	ld	a4,0(a7)
ffffffffc0200f3c:	0088b783          	ld	a5,8(a7)
            page=le2page(list_next(&(free_array[order])),page_link);
ffffffffc0200f40:	fe888493          	addi	s1,a7,-24
    prev->next = next;
ffffffffc0200f44:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200f46:	e398                	sd	a4,0(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200f48:	4789                	li	a5,2
ffffffffc0200f4a:	ff088713          	addi	a4,a7,-16
ffffffffc0200f4e:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc0200f52:	00005797          	auipc	a5,0x5
ffffffffc0200f56:	61678793          	addi	a5,a5,1558 # ffffffffc0206568 <pages>
ffffffffc0200f5a:	639c                	ld	a5,0(a5)
ffffffffc0200f5c:	00001717          	auipc	a4,0x1
ffffffffc0200f60:	14470713          	addi	a4,a4,324 # ffffffffc02020a0 <commands+0x6a0>
ffffffffc0200f64:	6318                	ld	a4,0(a4)
ffffffffc0200f66:	40f487b3          	sub	a5,s1,a5
ffffffffc0200f6a:	878d                	srai	a5,a5,0x3
ffffffffc0200f6c:	02e787b3          	mul	a5,a5,a4
ffffffffc0200f70:	00001697          	auipc	a3,0x1
ffffffffc0200f74:	7a868693          	addi	a3,a3,1960 # ffffffffc0202718 <nbase>
            nr_free-=n;
ffffffffc0200f78:	10842703          	lw	a4,264(s0)
            cprintf("[!]BS: Buddy array after ALLOC NO.%d page:\n", page2ppn(page));
ffffffffc0200f7c:	628c                	ld	a1,0(a3)
ffffffffc0200f7e:	00001517          	auipc	a0,0x1
ffffffffc0200f82:	0f250513          	addi	a0,a0,242 # ffffffffc0202070 <commands+0x670>
            nr_free-=n;
ffffffffc0200f86:	401700bb          	subw	ra,a4,ra
ffffffffc0200f8a:	00005717          	auipc	a4,0x5
ffffffffc0200f8e:	5a172b23          	sw	ra,1462(a4) # ffffffffc0206540 <free_buddy+0x108>
            cprintf("[!]BS: Buddy array after ALLOC NO.%d page:\n", page2ppn(page));
ffffffffc0200f92:	95be                	add	a1,a1,a5
ffffffffc0200f94:	922ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            show_buddy_array();
ffffffffc0200f98:	8bdff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
}
ffffffffc0200f9c:	60e2                	ld	ra,24(sp)
ffffffffc0200f9e:	6442                	ld	s0,16(sp)
ffffffffc0200fa0:	8526                	mv	a0,s1
ffffffffc0200fa2:	6902                	ld	s2,0(sp)
ffffffffc0200fa4:	64a2                	ld	s1,8(sp)
ffffffffc0200fa6:	6105                	addi	sp,sp,32
ffffffffc0200fa8:	8082                	ret
ffffffffc0200faa:	8626                	mv	a2,s1
ffffffffc0200fac:	b715                	j	ffffffffc0200ed0 <buddy_alloc_pages+0xb6>
ffffffffc0200fae:	60e2                	ld	ra,24(sp)
ffffffffc0200fb0:	6442                	ld	s0,16(sp)
    return NULL;
ffffffffc0200fb2:	4481                	li	s1,0
}
ffffffffc0200fb4:	8526                	mv	a0,s1
ffffffffc0200fb6:	6902                	ld	s2,0(sp)
ffffffffc0200fb8:	64a2                	ld	s1,8(sp)
ffffffffc0200fba:	6105                	addi	sp,sp,32
ffffffffc0200fbc:	8082                	ret
    assert (real_n>0);
ffffffffc0200fbe:	00001697          	auipc	a3,0x1
ffffffffc0200fc2:	09268693          	addi	a3,a3,146 # ffffffffc0202050 <commands+0x650>
ffffffffc0200fc6:	00001617          	auipc	a2,0x1
ffffffffc0200fca:	10260613          	addi	a2,a2,258 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc0200fce:	05500593          	li	a1,85
ffffffffc0200fd2:	00001517          	auipc	a0,0x1
ffffffffc0200fd6:	10e50513          	addi	a0,a0,270 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc0200fda:	bd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200fde <buddy_init_memmap>:
{
ffffffffc0200fde:	1101                	addi	sp,sp,-32
ffffffffc0200fe0:	ec06                	sd	ra,24(sp)
ffffffffc0200fe2:	e822                	sd	s0,16(sp)
ffffffffc0200fe4:	e426                	sd	s1,8(sp)
    assert(real_n>0);
ffffffffc0200fe6:	c5e9                	beqz	a1,ffffffffc02010b0 <buddy_init_memmap+0xd2>
    cprintf("real_n is %d\n",real_n);
ffffffffc0200fe8:	842a                	mv	s0,a0
ffffffffc0200fea:	00001517          	auipc	a0,0x1
ffffffffc0200fee:	2ce50513          	addi	a0,a0,718 # ffffffffc02022b8 <commands+0x8b8>
ffffffffc0200ff2:	84ae                	mv	s1,a1
ffffffffc0200ff4:	8c2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    order=GET_POWER_OF_2(real_n);
ffffffffc0200ff8:	8526                	mv	a0,s1
ffffffffc0200ffa:	dd1ff0ef          	jal	ra,ffffffffc0200dca <GET_POWER_OF_2>
ffffffffc0200ffe:	0005059b          	sext.w	a1,a0
    size_t n=1<<order;
ffffffffc0201002:	4785                	li	a5,1
ffffffffc0201004:	00b7973b          	sllw	a4,a5,a1
    for (; p != base + n; p+=1) 
ffffffffc0201008:	00271693          	slli	a3,a4,0x2
ffffffffc020100c:	96ba                	add	a3,a3,a4
    size_t n=1<<order;
ffffffffc020100e:	87ba                	mv	a5,a4
    for (; p != base + n; p+=1) 
ffffffffc0201010:	068e                	slli	a3,a3,0x3
    order=GET_POWER_OF_2(real_n);
ffffffffc0201012:	00005717          	auipc	a4,0x5
ffffffffc0201016:	42b72323          	sw	a1,1062(a4) # ffffffffc0206438 <free_buddy>
    nr_free=n;
ffffffffc020101a:	00005717          	auipc	a4,0x5
ffffffffc020101e:	52f72323          	sw	a5,1318(a4) # ffffffffc0206540 <free_buddy+0x108>
    for (; p != base + n; p+=1) 
ffffffffc0201022:	96a2                	add	a3,a3,s0
ffffffffc0201024:	00005717          	auipc	a4,0x5
ffffffffc0201028:	41470713          	addi	a4,a4,1044 # ffffffffc0206438 <free_buddy>
ffffffffc020102c:	02d40963          	beq	s0,a3,ffffffffc020105e <buddy_init_memmap+0x80>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201030:	6418                	ld	a4,8(s0)
        assert(PageReserved(p));// 确保页面已保留
ffffffffc0201032:	87a2                	mv	a5,s0
ffffffffc0201034:	8b05                	andi	a4,a4,1
ffffffffc0201036:	e709                	bnez	a4,ffffffffc0201040 <buddy_init_memmap+0x62>
ffffffffc0201038:	a8a1                	j	ffffffffc0201090 <buddy_init_memmap+0xb2>
ffffffffc020103a:	6798                	ld	a4,8(a5)
ffffffffc020103c:	8b05                	andi	a4,a4,1
ffffffffc020103e:	cb29                	beqz	a4,ffffffffc0201090 <buddy_init_memmap+0xb2>
        p->flags =  0;//页面空闲
ffffffffc0201040:	0007b423          	sd	zero,8(a5)
        p->property =0;
ffffffffc0201044:	0007a823          	sw	zero,16(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201048:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p+=1) 
ffffffffc020104c:	02878793          	addi	a5,a5,40
ffffffffc0201050:	fed795e3          	bne	a5,a3,ffffffffc020103a <buddy_init_memmap+0x5c>
ffffffffc0201054:	00005717          	auipc	a4,0x5
ffffffffc0201058:	3e470713          	addi	a4,a4,996 # ffffffffc0206438 <free_buddy>
ffffffffc020105c:	430c                	lw	a1,0(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc020105e:	02059793          	slli	a5,a1,0x20
ffffffffc0201062:	83f1                	srli	a5,a5,0x1c
ffffffffc0201064:	00f70633          	add	a2,a4,a5
ffffffffc0201068:	6a14                	ld	a3,16(a2)
    list_add(&(free_array[order]), &(base->page_link));
ffffffffc020106a:	01840513          	addi	a0,s0,24
ffffffffc020106e:	07a1                	addi	a5,a5,8
    prev->next = next->prev = elm;
ffffffffc0201070:	e288                	sd	a0,0(a3)
ffffffffc0201072:	ea08                	sd	a0,16(a2)
ffffffffc0201074:	97ba                	add	a5,a5,a4
    elm->next = next;
ffffffffc0201076:	f014                	sd	a3,32(s0)
    elm->prev = prev;
ffffffffc0201078:	ec1c                	sd	a5,24(s0)
    base->property=order;
ffffffffc020107a:	c80c                	sw	a1,16(s0)
}
ffffffffc020107c:	6442                	ld	s0,16(sp)
ffffffffc020107e:	60e2                	ld	ra,24(sp)
ffffffffc0201080:	64a2                	ld	s1,8(sp)
    cprintf("base order is %d\n",order);
ffffffffc0201082:	00001517          	auipc	a0,0x1
ffffffffc0201086:	25650513          	addi	a0,a0,598 # ffffffffc02022d8 <commands+0x8d8>
}
ffffffffc020108a:	6105                	addi	sp,sp,32
    cprintf("base order is %d\n",order);
ffffffffc020108c:	82aff06f          	j	ffffffffc02000b6 <cprintf>
        assert(PageReserved(p));// 确保页面已保留
ffffffffc0201090:	00001697          	auipc	a3,0x1
ffffffffc0201094:	23868693          	addi	a3,a3,568 # ffffffffc02022c8 <commands+0x8c8>
ffffffffc0201098:	00001617          	auipc	a2,0x1
ffffffffc020109c:	03060613          	addi	a2,a2,48 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc02010a0:	04800593          	li	a1,72
ffffffffc02010a4:	00001517          	auipc	a0,0x1
ffffffffc02010a8:	03c50513          	addi	a0,a0,60 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc02010ac:	b00ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(real_n>0);
ffffffffc02010b0:	00001697          	auipc	a3,0x1
ffffffffc02010b4:	fa068693          	addi	a3,a3,-96 # ffffffffc0202050 <commands+0x650>
ffffffffc02010b8:	00001617          	auipc	a2,0x1
ffffffffc02010bc:	01060613          	addi	a2,a2,16 # ffffffffc02020c8 <commands+0x6c8>
ffffffffc02010c0:	04000593          	li	a1,64
ffffffffc02010c4:	00001517          	auipc	a0,0x1
ffffffffc02010c8:	01c50513          	addi	a0,a0,28 # ffffffffc02020e0 <commands+0x6e0>
ffffffffc02010cc:	ae0ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02010d0 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02010d0:	100027f3          	csrr	a5,sstatus
ffffffffc02010d4:	8b89                	andi	a5,a5,2
ffffffffc02010d6:	eb89                	bnez	a5,ffffffffc02010e8 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02010d8:	00005797          	auipc	a5,0x5
ffffffffc02010dc:	48078793          	addi	a5,a5,1152 # ffffffffc0206558 <pmm_manager>
ffffffffc02010e0:	639c                	ld	a5,0(a5)
ffffffffc02010e2:	0187b303          	ld	t1,24(a5)
ffffffffc02010e6:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02010e8:	1141                	addi	sp,sp,-16
ffffffffc02010ea:	e406                	sd	ra,8(sp)
ffffffffc02010ec:	e022                	sd	s0,0(sp)
ffffffffc02010ee:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02010f0:	b74ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02010f4:	00005797          	auipc	a5,0x5
ffffffffc02010f8:	46478793          	addi	a5,a5,1124 # ffffffffc0206558 <pmm_manager>
ffffffffc02010fc:	639c                	ld	a5,0(a5)
ffffffffc02010fe:	8522                	mv	a0,s0
ffffffffc0201100:	6f9c                	ld	a5,24(a5)
ffffffffc0201102:	9782                	jalr	a5
ffffffffc0201104:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201106:	b58ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020110a:	8522                	mv	a0,s0
ffffffffc020110c:	60a2                	ld	ra,8(sp)
ffffffffc020110e:	6402                	ld	s0,0(sp)
ffffffffc0201110:	0141                	addi	sp,sp,16
ffffffffc0201112:	8082                	ret

ffffffffc0201114 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201114:	100027f3          	csrr	a5,sstatus
ffffffffc0201118:	8b89                	andi	a5,a5,2
ffffffffc020111a:	eb89                	bnez	a5,ffffffffc020112c <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020111c:	00005797          	auipc	a5,0x5
ffffffffc0201120:	43c78793          	addi	a5,a5,1084 # ffffffffc0206558 <pmm_manager>
ffffffffc0201124:	639c                	ld	a5,0(a5)
ffffffffc0201126:	0207b303          	ld	t1,32(a5)
ffffffffc020112a:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020112c:	1101                	addi	sp,sp,-32
ffffffffc020112e:	ec06                	sd	ra,24(sp)
ffffffffc0201130:	e822                	sd	s0,16(sp)
ffffffffc0201132:	e426                	sd	s1,8(sp)
ffffffffc0201134:	842a                	mv	s0,a0
ffffffffc0201136:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201138:	b2cff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020113c:	00005797          	auipc	a5,0x5
ffffffffc0201140:	41c78793          	addi	a5,a5,1052 # ffffffffc0206558 <pmm_manager>
ffffffffc0201144:	639c                	ld	a5,0(a5)
ffffffffc0201146:	85a6                	mv	a1,s1
ffffffffc0201148:	8522                	mv	a0,s0
ffffffffc020114a:	739c                	ld	a5,32(a5)
ffffffffc020114c:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020114e:	6442                	ld	s0,16(sp)
ffffffffc0201150:	60e2                	ld	ra,24(sp)
ffffffffc0201152:	64a2                	ld	s1,8(sp)
ffffffffc0201154:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201156:	b08ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc020115a <pmm_init>:
    pmm_manager=&buddy_pmm_manager_;
ffffffffc020115a:	00001797          	auipc	a5,0x1
ffffffffc020115e:	19678793          	addi	a5,a5,406 # ffffffffc02022f0 <buddy_pmm_manager_>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201162:	638c                	ld	a1,0(a5)
        fppn=pa2page(mem_begin)-pages+nbase;
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201164:	7139                	addi	sp,sp,-64
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201166:	00001517          	auipc	a0,0x1
ffffffffc020116a:	23250513          	addi	a0,a0,562 # ffffffffc0202398 <buddy_pmm_manager_+0xa8>
void pmm_init(void) {
ffffffffc020116e:	fc06                	sd	ra,56(sp)
    pmm_manager=&buddy_pmm_manager_;
ffffffffc0201170:	00005717          	auipc	a4,0x5
ffffffffc0201174:	3ef73423          	sd	a5,1000(a4) # ffffffffc0206558 <pmm_manager>
void pmm_init(void) {
ffffffffc0201178:	f822                	sd	s0,48(sp)
ffffffffc020117a:	f426                	sd	s1,40(sp)
ffffffffc020117c:	ec4e                	sd	s3,24(sp)
ffffffffc020117e:	f04a                	sd	s2,32(sp)
ffffffffc0201180:	e852                	sd	s4,16(sp)
ffffffffc0201182:	e456                	sd	s5,8(sp)
    pmm_manager=&buddy_pmm_manager_;
ffffffffc0201184:	00005417          	auipc	s0,0x5
ffffffffc0201188:	3d440413          	addi	s0,s0,980 # ffffffffc0206558 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020118c:	f2bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0201190:	601c                	ld	a5,0(s0)
ffffffffc0201192:	00005497          	auipc	s1,0x5
ffffffffc0201196:	28648493          	addi	s1,s1,646 # ffffffffc0206418 <npage>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020119a:	fff809b7          	lui	s3,0xfff80
    pmm_manager->init();
ffffffffc020119e:	679c                	ld	a5,8(a5)
ffffffffc02011a0:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02011a2:	57f5                	li	a5,-3
ffffffffc02011a4:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02011a6:	00001517          	auipc	a0,0x1
ffffffffc02011aa:	20a50513          	addi	a0,a0,522 # ffffffffc02023b0 <buddy_pmm_manager_+0xc0>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02011ae:	00005717          	auipc	a4,0x5
ffffffffc02011b2:	3af73923          	sd	a5,946(a4) # ffffffffc0206560 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02011b6:	f01fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02011ba:	46c5                	li	a3,17
ffffffffc02011bc:	06ee                	slli	a3,a3,0x1b
ffffffffc02011be:	40100613          	li	a2,1025
ffffffffc02011c2:	16fd                	addi	a3,a3,-1
ffffffffc02011c4:	0656                	slli	a2,a2,0x15
ffffffffc02011c6:	07e005b7          	lui	a1,0x7e00
ffffffffc02011ca:	00001517          	auipc	a0,0x1
ffffffffc02011ce:	1fe50513          	addi	a0,a0,510 # ffffffffc02023c8 <buddy_pmm_manager_+0xd8>
ffffffffc02011d2:	ee5fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011d6:	777d                	lui	a4,0xfffff
ffffffffc02011d8:	00006797          	auipc	a5,0x6
ffffffffc02011dc:	39778793          	addi	a5,a5,919 # ffffffffc020756f <end+0xfff>
ffffffffc02011e0:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02011e2:	00088737          	lui	a4,0x88
ffffffffc02011e6:	00005697          	auipc	a3,0x5
ffffffffc02011ea:	22e6b923          	sd	a4,562(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011ee:	4601                	li	a2,0
ffffffffc02011f0:	00005717          	auipc	a4,0x5
ffffffffc02011f4:	36f73c23          	sd	a5,888(a4) # ffffffffc0206568 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011f8:	4681                	li	a3,0
ffffffffc02011fa:	00005597          	auipc	a1,0x5
ffffffffc02011fe:	36e58593          	addi	a1,a1,878 # ffffffffc0206568 <pages>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201202:	4505                	li	a0,1
ffffffffc0201204:	a011                	j	ffffffffc0201208 <pmm_init+0xae>
ffffffffc0201206:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0201208:	97b2                	add	a5,a5,a2
ffffffffc020120a:	07a1                	addi	a5,a5,8
ffffffffc020120c:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201210:	6098                	ld	a4,0(s1)
ffffffffc0201212:	0685                	addi	a3,a3,1
ffffffffc0201214:	02860613          	addi	a2,a2,40
ffffffffc0201218:	013707b3          	add	a5,a4,s3
ffffffffc020121c:	fef6e5e3          	bltu	a3,a5,ffffffffc0201206 <pmm_init+0xac>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201220:	6188                	ld	a0,0(a1)
ffffffffc0201222:	00271793          	slli	a5,a4,0x2
ffffffffc0201226:	97ba                	add	a5,a5,a4
ffffffffc0201228:	fec006b7          	lui	a3,0xfec00
ffffffffc020122c:	078e                	slli	a5,a5,0x3
ffffffffc020122e:	96aa                	add	a3,a3,a0
ffffffffc0201230:	96be                	add	a3,a3,a5
ffffffffc0201232:	c02007b7          	lui	a5,0xc0200
ffffffffc0201236:	0ef6e763          	bltu	a3,a5,ffffffffc0201324 <pmm_init+0x1ca>
ffffffffc020123a:	00005a17          	auipc	s4,0x5
ffffffffc020123e:	326a0a13          	addi	s4,s4,806 # ffffffffc0206560 <va_pa_offset>
ffffffffc0201242:	000a3783          	ld	a5,0(s4)
    if (freemem < mem_end) {
ffffffffc0201246:	45c5                	li	a1,17
ffffffffc0201248:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020124a:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc020124c:	06b6f463          	bleu	a1,a3,ffffffffc02012b4 <pmm_init+0x15a>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201250:	6785                	lui	a5,0x1
ffffffffc0201252:	17fd                	addi	a5,a5,-1
ffffffffc0201254:	96be                	add	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201256:	00c6da93          	srli	s5,a3,0xc
ffffffffc020125a:	0aeaf963          	bleu	a4,s5,ffffffffc020130c <pmm_init+0x1b2>
    pmm_manager->init_memmap(base, n);
ffffffffc020125e:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201260:	013a87b3          	add	a5,s5,s3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201264:	767d                	lui	a2,0xfffff
ffffffffc0201266:	8ef1                	and	a3,a3,a2
ffffffffc0201268:	00279993          	slli	s3,a5,0x2
ffffffffc020126c:	40d586b3          	sub	a3,a1,a3
ffffffffc0201270:	99be                	add	s3,s3,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0201272:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201274:	00c6d913          	srli	s2,a3,0xc
ffffffffc0201278:	098e                	slli	s3,s3,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020127a:	954e                	add	a0,a0,s3
ffffffffc020127c:	85ca                	mv	a1,s2
ffffffffc020127e:	9782                	jalr	a5
        cprintf("size_t n is %d",(mem_end - mem_begin) / PGSIZE);
ffffffffc0201280:	85ca                	mv	a1,s2
ffffffffc0201282:	00001517          	auipc	a0,0x1
ffffffffc0201286:	1de50513          	addi	a0,a0,478 # ffffffffc0202460 <buddy_pmm_manager_+0x170>
ffffffffc020128a:	e2dfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (PPN(pa) >= npage) {
ffffffffc020128e:	609c                	ld	a5,0(s1)
ffffffffc0201290:	06fafe63          	bleu	a5,s5,ffffffffc020130c <pmm_init+0x1b2>
        fppn=pa2page(mem_begin)-pages+nbase;
ffffffffc0201294:	00001797          	auipc	a5,0x1
ffffffffc0201298:	e0c78793          	addi	a5,a5,-500 # ffffffffc02020a0 <commands+0x6a0>
ffffffffc020129c:	639c                	ld	a5,0(a5)
ffffffffc020129e:	4039d993          	srai	s3,s3,0x3
ffffffffc02012a2:	02f989b3          	mul	s3,s3,a5
ffffffffc02012a6:	000807b7          	lui	a5,0x80
ffffffffc02012aa:	99be                	add	s3,s3,a5
ffffffffc02012ac:	00005797          	auipc	a5,0x5
ffffffffc02012b0:	2b37b223          	sd	s3,676(a5) # ffffffffc0206550 <fppn>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02012b4:	601c                	ld	a5,0(s0)
ffffffffc02012b6:	7b9c                	ld	a5,48(a5)
ffffffffc02012b8:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02012ba:	00001517          	auipc	a0,0x1
ffffffffc02012be:	1b650513          	addi	a0,a0,438 # ffffffffc0202470 <buddy_pmm_manager_+0x180>
ffffffffc02012c2:	df5fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02012c6:	00004697          	auipc	a3,0x4
ffffffffc02012ca:	d3a68693          	addi	a3,a3,-710 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02012ce:	00005797          	auipc	a5,0x5
ffffffffc02012d2:	14d7b923          	sd	a3,338(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02012d6:	c02007b7          	lui	a5,0xc0200
ffffffffc02012da:	06f6e163          	bltu	a3,a5,ffffffffc020133c <pmm_init+0x1e2>
ffffffffc02012de:	000a3783          	ld	a5,0(s4)
}
ffffffffc02012e2:	7442                	ld	s0,48(sp)
ffffffffc02012e4:	70e2                	ld	ra,56(sp)
ffffffffc02012e6:	74a2                	ld	s1,40(sp)
ffffffffc02012e8:	7902                	ld	s2,32(sp)
ffffffffc02012ea:	69e2                	ld	s3,24(sp)
ffffffffc02012ec:	6a42                	ld	s4,16(sp)
ffffffffc02012ee:	6aa2                	ld	s5,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02012f0:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02012f2:	8e9d                	sub	a3,a3,a5
ffffffffc02012f4:	00005797          	auipc	a5,0x5
ffffffffc02012f8:	24d7ba23          	sd	a3,596(a5) # ffffffffc0206548 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02012fc:	00001517          	auipc	a0,0x1
ffffffffc0201300:	19450513          	addi	a0,a0,404 # ffffffffc0202490 <buddy_pmm_manager_+0x1a0>
ffffffffc0201304:	8636                	mv	a2,a3
}
ffffffffc0201306:	6121                	addi	sp,sp,64
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201308:	daffe06f          	j	ffffffffc02000b6 <cprintf>
        panic("pa2page called with invalid pa");
ffffffffc020130c:	00001617          	auipc	a2,0x1
ffffffffc0201310:	12460613          	addi	a2,a2,292 # ffffffffc0202430 <buddy_pmm_manager_+0x140>
ffffffffc0201314:	06b00593          	li	a1,107
ffffffffc0201318:	00001517          	auipc	a0,0x1
ffffffffc020131c:	13850513          	addi	a0,a0,312 # ffffffffc0202450 <buddy_pmm_manager_+0x160>
ffffffffc0201320:	88cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201324:	00001617          	auipc	a2,0x1
ffffffffc0201328:	0d460613          	addi	a2,a2,212 # ffffffffc02023f8 <buddy_pmm_manager_+0x108>
ffffffffc020132c:	07500593          	li	a1,117
ffffffffc0201330:	00001517          	auipc	a0,0x1
ffffffffc0201334:	0f050513          	addi	a0,a0,240 # ffffffffc0202420 <buddy_pmm_manager_+0x130>
ffffffffc0201338:	874ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020133c:	00001617          	auipc	a2,0x1
ffffffffc0201340:	0bc60613          	addi	a2,a2,188 # ffffffffc02023f8 <buddy_pmm_manager_+0x108>
ffffffffc0201344:	09200593          	li	a1,146
ffffffffc0201348:	00001517          	auipc	a0,0x1
ffffffffc020134c:	0d850513          	addi	a0,a0,216 # ffffffffc0202420 <buddy_pmm_manager_+0x130>
ffffffffc0201350:	85cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201354 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201354:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201358:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020135a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020135e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201360:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201364:	f022                	sd	s0,32(sp)
ffffffffc0201366:	ec26                	sd	s1,24(sp)
ffffffffc0201368:	e84a                	sd	s2,16(sp)
ffffffffc020136a:	f406                	sd	ra,40(sp)
ffffffffc020136c:	e44e                	sd	s3,8(sp)
ffffffffc020136e:	84aa                	mv	s1,a0
ffffffffc0201370:	892e                	mv	s2,a1
ffffffffc0201372:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201376:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201378:	03067e63          	bleu	a6,a2,ffffffffc02013b4 <printnum+0x60>
ffffffffc020137c:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020137e:	00805763          	blez	s0,ffffffffc020138c <printnum+0x38>
ffffffffc0201382:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201384:	85ca                	mv	a1,s2
ffffffffc0201386:	854e                	mv	a0,s3
ffffffffc0201388:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020138a:	fc65                	bnez	s0,ffffffffc0201382 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020138c:	1a02                	slli	s4,s4,0x20
ffffffffc020138e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201392:	00001797          	auipc	a5,0x1
ffffffffc0201396:	2ce78793          	addi	a5,a5,718 # ffffffffc0202660 <error_string+0x38>
ffffffffc020139a:	9a3e                	add	s4,s4,a5
}
ffffffffc020139c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020139e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02013a2:	70a2                	ld	ra,40(sp)
ffffffffc02013a4:	69a2                	ld	s3,8(sp)
ffffffffc02013a6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013a8:	85ca                	mv	a1,s2
ffffffffc02013aa:	8326                	mv	t1,s1
}
ffffffffc02013ac:	6942                	ld	s2,16(sp)
ffffffffc02013ae:	64e2                	ld	s1,24(sp)
ffffffffc02013b0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013b2:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02013b4:	03065633          	divu	a2,a2,a6
ffffffffc02013b8:	8722                	mv	a4,s0
ffffffffc02013ba:	f9bff0ef          	jal	ra,ffffffffc0201354 <printnum>
ffffffffc02013be:	b7f9                	j	ffffffffc020138c <printnum+0x38>

ffffffffc02013c0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02013c0:	7119                	addi	sp,sp,-128
ffffffffc02013c2:	f4a6                	sd	s1,104(sp)
ffffffffc02013c4:	f0ca                	sd	s2,96(sp)
ffffffffc02013c6:	e8d2                	sd	s4,80(sp)
ffffffffc02013c8:	e4d6                	sd	s5,72(sp)
ffffffffc02013ca:	e0da                	sd	s6,64(sp)
ffffffffc02013cc:	fc5e                	sd	s7,56(sp)
ffffffffc02013ce:	f862                	sd	s8,48(sp)
ffffffffc02013d0:	f06a                	sd	s10,32(sp)
ffffffffc02013d2:	fc86                	sd	ra,120(sp)
ffffffffc02013d4:	f8a2                	sd	s0,112(sp)
ffffffffc02013d6:	ecce                	sd	s3,88(sp)
ffffffffc02013d8:	f466                	sd	s9,40(sp)
ffffffffc02013da:	ec6e                	sd	s11,24(sp)
ffffffffc02013dc:	892a                	mv	s2,a0
ffffffffc02013de:	84ae                	mv	s1,a1
ffffffffc02013e0:	8d32                	mv	s10,a2
ffffffffc02013e2:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02013e4:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013e6:	00001a17          	auipc	s4,0x1
ffffffffc02013ea:	0eaa0a13          	addi	s4,s4,234 # ffffffffc02024d0 <buddy_pmm_manager_+0x1e0>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013ee:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013f2:	00001c17          	auipc	s8,0x1
ffffffffc02013f6:	236c0c13          	addi	s8,s8,566 # ffffffffc0202628 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013fa:	000d4503          	lbu	a0,0(s10)
ffffffffc02013fe:	02500793          	li	a5,37
ffffffffc0201402:	001d0413          	addi	s0,s10,1
ffffffffc0201406:	00f50e63          	beq	a0,a5,ffffffffc0201422 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc020140a:	c521                	beqz	a0,ffffffffc0201452 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020140c:	02500993          	li	s3,37
ffffffffc0201410:	a011                	j	ffffffffc0201414 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201412:	c121                	beqz	a0,ffffffffc0201452 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201414:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201416:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201418:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020141a:	fff44503          	lbu	a0,-1(s0)
ffffffffc020141e:	ff351ae3          	bne	a0,s3,ffffffffc0201412 <vprintfmt+0x52>
ffffffffc0201422:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201426:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020142a:	4981                	li	s3,0
ffffffffc020142c:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020142e:	5cfd                	li	s9,-1
ffffffffc0201430:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201432:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201436:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201438:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020143c:	0ff6f693          	andi	a3,a3,255
ffffffffc0201440:	00140d13          	addi	s10,s0,1
ffffffffc0201444:	20d5e563          	bltu	a1,a3,ffffffffc020164e <vprintfmt+0x28e>
ffffffffc0201448:	068a                	slli	a3,a3,0x2
ffffffffc020144a:	96d2                	add	a3,a3,s4
ffffffffc020144c:	4294                	lw	a3,0(a3)
ffffffffc020144e:	96d2                	add	a3,a3,s4
ffffffffc0201450:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201452:	70e6                	ld	ra,120(sp)
ffffffffc0201454:	7446                	ld	s0,112(sp)
ffffffffc0201456:	74a6                	ld	s1,104(sp)
ffffffffc0201458:	7906                	ld	s2,96(sp)
ffffffffc020145a:	69e6                	ld	s3,88(sp)
ffffffffc020145c:	6a46                	ld	s4,80(sp)
ffffffffc020145e:	6aa6                	ld	s5,72(sp)
ffffffffc0201460:	6b06                	ld	s6,64(sp)
ffffffffc0201462:	7be2                	ld	s7,56(sp)
ffffffffc0201464:	7c42                	ld	s8,48(sp)
ffffffffc0201466:	7ca2                	ld	s9,40(sp)
ffffffffc0201468:	7d02                	ld	s10,32(sp)
ffffffffc020146a:	6de2                	ld	s11,24(sp)
ffffffffc020146c:	6109                	addi	sp,sp,128
ffffffffc020146e:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201470:	4705                	li	a4,1
ffffffffc0201472:	008a8593          	addi	a1,s5,8
ffffffffc0201476:	01074463          	blt	a4,a6,ffffffffc020147e <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc020147a:	26080363          	beqz	a6,ffffffffc02016e0 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020147e:	000ab603          	ld	a2,0(s5)
ffffffffc0201482:	46c1                	li	a3,16
ffffffffc0201484:	8aae                	mv	s5,a1
ffffffffc0201486:	a06d                	j	ffffffffc0201530 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201488:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020148c:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020148e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201490:	b765                	j	ffffffffc0201438 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201492:	000aa503          	lw	a0,0(s5)
ffffffffc0201496:	85a6                	mv	a1,s1
ffffffffc0201498:	0aa1                	addi	s5,s5,8
ffffffffc020149a:	9902                	jalr	s2
            break;
ffffffffc020149c:	bfb9                	j	ffffffffc02013fa <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020149e:	4705                	li	a4,1
ffffffffc02014a0:	008a8993          	addi	s3,s5,8
ffffffffc02014a4:	01074463          	blt	a4,a6,ffffffffc02014ac <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02014a8:	22080463          	beqz	a6,ffffffffc02016d0 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02014ac:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02014b0:	24044463          	bltz	s0,ffffffffc02016f8 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02014b4:	8622                	mv	a2,s0
ffffffffc02014b6:	8ace                	mv	s5,s3
ffffffffc02014b8:	46a9                	li	a3,10
ffffffffc02014ba:	a89d                	j	ffffffffc0201530 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02014bc:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014c0:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02014c2:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02014c4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02014c8:	8fb5                	xor	a5,a5,a3
ffffffffc02014ca:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014ce:	1ad74363          	blt	a4,a3,ffffffffc0201674 <vprintfmt+0x2b4>
ffffffffc02014d2:	00369793          	slli	a5,a3,0x3
ffffffffc02014d6:	97e2                	add	a5,a5,s8
ffffffffc02014d8:	639c                	ld	a5,0(a5)
ffffffffc02014da:	18078d63          	beqz	a5,ffffffffc0201674 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02014de:	86be                	mv	a3,a5
ffffffffc02014e0:	00001617          	auipc	a2,0x1
ffffffffc02014e4:	23060613          	addi	a2,a2,560 # ffffffffc0202710 <error_string+0xe8>
ffffffffc02014e8:	85a6                	mv	a1,s1
ffffffffc02014ea:	854a                	mv	a0,s2
ffffffffc02014ec:	240000ef          	jal	ra,ffffffffc020172c <printfmt>
ffffffffc02014f0:	b729                	j	ffffffffc02013fa <vprintfmt+0x3a>
            lflag ++;
ffffffffc02014f2:	00144603          	lbu	a2,1(s0)
ffffffffc02014f6:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014f8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014fa:	bf3d                	j	ffffffffc0201438 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02014fc:	4705                	li	a4,1
ffffffffc02014fe:	008a8593          	addi	a1,s5,8
ffffffffc0201502:	01074463          	blt	a4,a6,ffffffffc020150a <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201506:	1e080263          	beqz	a6,ffffffffc02016ea <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc020150a:	000ab603          	ld	a2,0(s5)
ffffffffc020150e:	46a1                	li	a3,8
ffffffffc0201510:	8aae                	mv	s5,a1
ffffffffc0201512:	a839                	j	ffffffffc0201530 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201514:	03000513          	li	a0,48
ffffffffc0201518:	85a6                	mv	a1,s1
ffffffffc020151a:	e03e                	sd	a5,0(sp)
ffffffffc020151c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020151e:	85a6                	mv	a1,s1
ffffffffc0201520:	07800513          	li	a0,120
ffffffffc0201524:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201526:	0aa1                	addi	s5,s5,8
ffffffffc0201528:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020152c:	6782                	ld	a5,0(sp)
ffffffffc020152e:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201530:	876e                	mv	a4,s11
ffffffffc0201532:	85a6                	mv	a1,s1
ffffffffc0201534:	854a                	mv	a0,s2
ffffffffc0201536:	e1fff0ef          	jal	ra,ffffffffc0201354 <printnum>
            break;
ffffffffc020153a:	b5c1                	j	ffffffffc02013fa <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020153c:	000ab603          	ld	a2,0(s5)
ffffffffc0201540:	0aa1                	addi	s5,s5,8
ffffffffc0201542:	1c060663          	beqz	a2,ffffffffc020170e <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201546:	00160413          	addi	s0,a2,1
ffffffffc020154a:	17b05c63          	blez	s11,ffffffffc02016c2 <vprintfmt+0x302>
ffffffffc020154e:	02d00593          	li	a1,45
ffffffffc0201552:	14b79263          	bne	a5,a1,ffffffffc0201696 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201556:	00064783          	lbu	a5,0(a2)
ffffffffc020155a:	0007851b          	sext.w	a0,a5
ffffffffc020155e:	c905                	beqz	a0,ffffffffc020158e <vprintfmt+0x1ce>
ffffffffc0201560:	000cc563          	bltz	s9,ffffffffc020156a <vprintfmt+0x1aa>
ffffffffc0201564:	3cfd                	addiw	s9,s9,-1
ffffffffc0201566:	036c8263          	beq	s9,s6,ffffffffc020158a <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc020156a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020156c:	18098463          	beqz	s3,ffffffffc02016f4 <vprintfmt+0x334>
ffffffffc0201570:	3781                	addiw	a5,a5,-32
ffffffffc0201572:	18fbf163          	bleu	a5,s7,ffffffffc02016f4 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201576:	03f00513          	li	a0,63
ffffffffc020157a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020157c:	0405                	addi	s0,s0,1
ffffffffc020157e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201582:	3dfd                	addiw	s11,s11,-1
ffffffffc0201584:	0007851b          	sext.w	a0,a5
ffffffffc0201588:	fd61                	bnez	a0,ffffffffc0201560 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc020158a:	e7b058e3          	blez	s11,ffffffffc02013fa <vprintfmt+0x3a>
ffffffffc020158e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201590:	85a6                	mv	a1,s1
ffffffffc0201592:	02000513          	li	a0,32
ffffffffc0201596:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201598:	e60d81e3          	beqz	s11,ffffffffc02013fa <vprintfmt+0x3a>
ffffffffc020159c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020159e:	85a6                	mv	a1,s1
ffffffffc02015a0:	02000513          	li	a0,32
ffffffffc02015a4:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02015a6:	fe0d94e3          	bnez	s11,ffffffffc020158e <vprintfmt+0x1ce>
ffffffffc02015aa:	bd81                	j	ffffffffc02013fa <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02015ac:	4705                	li	a4,1
ffffffffc02015ae:	008a8593          	addi	a1,s5,8
ffffffffc02015b2:	01074463          	blt	a4,a6,ffffffffc02015ba <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02015b6:	12080063          	beqz	a6,ffffffffc02016d6 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02015ba:	000ab603          	ld	a2,0(s5)
ffffffffc02015be:	46a9                	li	a3,10
ffffffffc02015c0:	8aae                	mv	s5,a1
ffffffffc02015c2:	b7bd                	j	ffffffffc0201530 <vprintfmt+0x170>
ffffffffc02015c4:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02015c8:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015cc:	846a                	mv	s0,s10
ffffffffc02015ce:	b5ad                	j	ffffffffc0201438 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02015d0:	85a6                	mv	a1,s1
ffffffffc02015d2:	02500513          	li	a0,37
ffffffffc02015d6:	9902                	jalr	s2
            break;
ffffffffc02015d8:	b50d                	j	ffffffffc02013fa <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02015da:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02015de:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02015e2:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015e4:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02015e6:	e40dd9e3          	bgez	s11,ffffffffc0201438 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02015ea:	8de6                	mv	s11,s9
ffffffffc02015ec:	5cfd                	li	s9,-1
ffffffffc02015ee:	b5a9                	j	ffffffffc0201438 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02015f0:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02015f4:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015f8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02015fa:	bd3d                	j	ffffffffc0201438 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02015fc:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201600:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201604:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201606:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020160a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020160e:	fcd56ce3          	bltu	a0,a3,ffffffffc02015e6 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201612:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201614:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201618:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020161c:	0196873b          	addw	a4,a3,s9
ffffffffc0201620:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201624:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201628:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020162c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201630:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201634:	fcd57fe3          	bleu	a3,a0,ffffffffc0201612 <vprintfmt+0x252>
ffffffffc0201638:	b77d                	j	ffffffffc02015e6 <vprintfmt+0x226>
            if (width < 0)
ffffffffc020163a:	fffdc693          	not	a3,s11
ffffffffc020163e:	96fd                	srai	a3,a3,0x3f
ffffffffc0201640:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201644:	00144603          	lbu	a2,1(s0)
ffffffffc0201648:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020164a:	846a                	mv	s0,s10
ffffffffc020164c:	b3f5                	j	ffffffffc0201438 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020164e:	85a6                	mv	a1,s1
ffffffffc0201650:	02500513          	li	a0,37
ffffffffc0201654:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201656:	fff44703          	lbu	a4,-1(s0)
ffffffffc020165a:	02500793          	li	a5,37
ffffffffc020165e:	8d22                	mv	s10,s0
ffffffffc0201660:	d8f70de3          	beq	a4,a5,ffffffffc02013fa <vprintfmt+0x3a>
ffffffffc0201664:	02500713          	li	a4,37
ffffffffc0201668:	1d7d                	addi	s10,s10,-1
ffffffffc020166a:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020166e:	fee79de3          	bne	a5,a4,ffffffffc0201668 <vprintfmt+0x2a8>
ffffffffc0201672:	b361                	j	ffffffffc02013fa <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201674:	00001617          	auipc	a2,0x1
ffffffffc0201678:	08c60613          	addi	a2,a2,140 # ffffffffc0202700 <error_string+0xd8>
ffffffffc020167c:	85a6                	mv	a1,s1
ffffffffc020167e:	854a                	mv	a0,s2
ffffffffc0201680:	0ac000ef          	jal	ra,ffffffffc020172c <printfmt>
ffffffffc0201684:	bb9d                	j	ffffffffc02013fa <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201686:	00001617          	auipc	a2,0x1
ffffffffc020168a:	07260613          	addi	a2,a2,114 # ffffffffc02026f8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020168e:	00001417          	auipc	s0,0x1
ffffffffc0201692:	06b40413          	addi	s0,s0,107 # ffffffffc02026f9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201696:	8532                	mv	a0,a2
ffffffffc0201698:	85e6                	mv	a1,s9
ffffffffc020169a:	e032                	sd	a2,0(sp)
ffffffffc020169c:	e43e                	sd	a5,8(sp)
ffffffffc020169e:	1c2000ef          	jal	ra,ffffffffc0201860 <strnlen>
ffffffffc02016a2:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02016a6:	6602                	ld	a2,0(sp)
ffffffffc02016a8:	01b05d63          	blez	s11,ffffffffc02016c2 <vprintfmt+0x302>
ffffffffc02016ac:	67a2                	ld	a5,8(sp)
ffffffffc02016ae:	2781                	sext.w	a5,a5
ffffffffc02016b0:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02016b2:	6522                	ld	a0,8(sp)
ffffffffc02016b4:	85a6                	mv	a1,s1
ffffffffc02016b6:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016b8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02016ba:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016bc:	6602                	ld	a2,0(sp)
ffffffffc02016be:	fe0d9ae3          	bnez	s11,ffffffffc02016b2 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016c2:	00064783          	lbu	a5,0(a2)
ffffffffc02016c6:	0007851b          	sext.w	a0,a5
ffffffffc02016ca:	e8051be3          	bnez	a0,ffffffffc0201560 <vprintfmt+0x1a0>
ffffffffc02016ce:	b335                	j	ffffffffc02013fa <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02016d0:	000aa403          	lw	s0,0(s5)
ffffffffc02016d4:	bbf1                	j	ffffffffc02014b0 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02016d6:	000ae603          	lwu	a2,0(s5)
ffffffffc02016da:	46a9                	li	a3,10
ffffffffc02016dc:	8aae                	mv	s5,a1
ffffffffc02016de:	bd89                	j	ffffffffc0201530 <vprintfmt+0x170>
ffffffffc02016e0:	000ae603          	lwu	a2,0(s5)
ffffffffc02016e4:	46c1                	li	a3,16
ffffffffc02016e6:	8aae                	mv	s5,a1
ffffffffc02016e8:	b5a1                	j	ffffffffc0201530 <vprintfmt+0x170>
ffffffffc02016ea:	000ae603          	lwu	a2,0(s5)
ffffffffc02016ee:	46a1                	li	a3,8
ffffffffc02016f0:	8aae                	mv	s5,a1
ffffffffc02016f2:	bd3d                	j	ffffffffc0201530 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02016f4:	9902                	jalr	s2
ffffffffc02016f6:	b559                	j	ffffffffc020157c <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02016f8:	85a6                	mv	a1,s1
ffffffffc02016fa:	02d00513          	li	a0,45
ffffffffc02016fe:	e03e                	sd	a5,0(sp)
ffffffffc0201700:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201702:	8ace                	mv	s5,s3
ffffffffc0201704:	40800633          	neg	a2,s0
ffffffffc0201708:	46a9                	li	a3,10
ffffffffc020170a:	6782                	ld	a5,0(sp)
ffffffffc020170c:	b515                	j	ffffffffc0201530 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020170e:	01b05663          	blez	s11,ffffffffc020171a <vprintfmt+0x35a>
ffffffffc0201712:	02d00693          	li	a3,45
ffffffffc0201716:	f6d798e3          	bne	a5,a3,ffffffffc0201686 <vprintfmt+0x2c6>
ffffffffc020171a:	00001417          	auipc	s0,0x1
ffffffffc020171e:	fdf40413          	addi	s0,s0,-33 # ffffffffc02026f9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201722:	02800513          	li	a0,40
ffffffffc0201726:	02800793          	li	a5,40
ffffffffc020172a:	bd1d                	j	ffffffffc0201560 <vprintfmt+0x1a0>

ffffffffc020172c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020172c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020172e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201732:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201734:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201736:	ec06                	sd	ra,24(sp)
ffffffffc0201738:	f83a                	sd	a4,48(sp)
ffffffffc020173a:	fc3e                	sd	a5,56(sp)
ffffffffc020173c:	e0c2                	sd	a6,64(sp)
ffffffffc020173e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201740:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201742:	c7fff0ef          	jal	ra,ffffffffc02013c0 <vprintfmt>
}
ffffffffc0201746:	60e2                	ld	ra,24(sp)
ffffffffc0201748:	6161                	addi	sp,sp,80
ffffffffc020174a:	8082                	ret

ffffffffc020174c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020174c:	715d                	addi	sp,sp,-80
ffffffffc020174e:	e486                	sd	ra,72(sp)
ffffffffc0201750:	e0a2                	sd	s0,64(sp)
ffffffffc0201752:	fc26                	sd	s1,56(sp)
ffffffffc0201754:	f84a                	sd	s2,48(sp)
ffffffffc0201756:	f44e                	sd	s3,40(sp)
ffffffffc0201758:	f052                	sd	s4,32(sp)
ffffffffc020175a:	ec56                	sd	s5,24(sp)
ffffffffc020175c:	e85a                	sd	s6,16(sp)
ffffffffc020175e:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201760:	c901                	beqz	a0,ffffffffc0201770 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201762:	85aa                	mv	a1,a0
ffffffffc0201764:	00001517          	auipc	a0,0x1
ffffffffc0201768:	fac50513          	addi	a0,a0,-84 # ffffffffc0202710 <error_string+0xe8>
ffffffffc020176c:	94bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201770:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201772:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201774:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201776:	4aa9                	li	s5,10
ffffffffc0201778:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020177a:	00005b97          	auipc	s7,0x5
ffffffffc020177e:	896b8b93          	addi	s7,s7,-1898 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201782:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201786:	9a9fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020178a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020178c:	00054b63          	bltz	a0,ffffffffc02017a2 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201790:	00a95b63          	ble	a0,s2,ffffffffc02017a6 <readline+0x5a>
ffffffffc0201794:	029a5463          	ble	s1,s4,ffffffffc02017bc <readline+0x70>
        c = getchar();
ffffffffc0201798:	997fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020179c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020179e:	fe0559e3          	bgez	a0,ffffffffc0201790 <readline+0x44>
            return NULL;
ffffffffc02017a2:	4501                	li	a0,0
ffffffffc02017a4:	a099                	j	ffffffffc02017ea <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02017a6:	03341463          	bne	s0,s3,ffffffffc02017ce <readline+0x82>
ffffffffc02017aa:	e8b9                	bnez	s1,ffffffffc0201800 <readline+0xb4>
        c = getchar();
ffffffffc02017ac:	983fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02017b0:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02017b2:	fe0548e3          	bltz	a0,ffffffffc02017a2 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02017b6:	fea958e3          	ble	a0,s2,ffffffffc02017a6 <readline+0x5a>
ffffffffc02017ba:	4481                	li	s1,0
            cputchar(c);
ffffffffc02017bc:	8522                	mv	a0,s0
ffffffffc02017be:	92dfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02017c2:	009b87b3          	add	a5,s7,s1
ffffffffc02017c6:	00878023          	sb	s0,0(a5)
ffffffffc02017ca:	2485                	addiw	s1,s1,1
ffffffffc02017cc:	bf6d                	j	ffffffffc0201786 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02017ce:	01540463          	beq	s0,s5,ffffffffc02017d6 <readline+0x8a>
ffffffffc02017d2:	fb641ae3          	bne	s0,s6,ffffffffc0201786 <readline+0x3a>
            cputchar(c);
ffffffffc02017d6:	8522                	mv	a0,s0
ffffffffc02017d8:	913fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02017dc:	00005517          	auipc	a0,0x5
ffffffffc02017e0:	83450513          	addi	a0,a0,-1996 # ffffffffc0206010 <edata>
ffffffffc02017e4:	94aa                	add	s1,s1,a0
ffffffffc02017e6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02017ea:	60a6                	ld	ra,72(sp)
ffffffffc02017ec:	6406                	ld	s0,64(sp)
ffffffffc02017ee:	74e2                	ld	s1,56(sp)
ffffffffc02017f0:	7942                	ld	s2,48(sp)
ffffffffc02017f2:	79a2                	ld	s3,40(sp)
ffffffffc02017f4:	7a02                	ld	s4,32(sp)
ffffffffc02017f6:	6ae2                	ld	s5,24(sp)
ffffffffc02017f8:	6b42                	ld	s6,16(sp)
ffffffffc02017fa:	6ba2                	ld	s7,8(sp)
ffffffffc02017fc:	6161                	addi	sp,sp,80
ffffffffc02017fe:	8082                	ret
            cputchar(c);
ffffffffc0201800:	4521                	li	a0,8
ffffffffc0201802:	8e9fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201806:	34fd                	addiw	s1,s1,-1
ffffffffc0201808:	bfbd                	j	ffffffffc0201786 <readline+0x3a>

ffffffffc020180a <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc020180a:	00004797          	auipc	a5,0x4
ffffffffc020180e:	7fe78793          	addi	a5,a5,2046 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201812:	6398                	ld	a4,0(a5)
ffffffffc0201814:	4781                	li	a5,0
ffffffffc0201816:	88ba                	mv	a7,a4
ffffffffc0201818:	852a                	mv	a0,a0
ffffffffc020181a:	85be                	mv	a1,a5
ffffffffc020181c:	863e                	mv	a2,a5
ffffffffc020181e:	00000073          	ecall
ffffffffc0201822:	87aa                	mv	a5,a0
}
ffffffffc0201824:	8082                	ret

ffffffffc0201826 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201826:	00005797          	auipc	a5,0x5
ffffffffc020182a:	c0278793          	addi	a5,a5,-1022 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc020182e:	6398                	ld	a4,0(a5)
ffffffffc0201830:	4781                	li	a5,0
ffffffffc0201832:	88ba                	mv	a7,a4
ffffffffc0201834:	852a                	mv	a0,a0
ffffffffc0201836:	85be                	mv	a1,a5
ffffffffc0201838:	863e                	mv	a2,a5
ffffffffc020183a:	00000073          	ecall
ffffffffc020183e:	87aa                	mv	a5,a0
}
ffffffffc0201840:	8082                	ret

ffffffffc0201842 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201842:	00004797          	auipc	a5,0x4
ffffffffc0201846:	7be78793          	addi	a5,a5,1982 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc020184a:	639c                	ld	a5,0(a5)
ffffffffc020184c:	4501                	li	a0,0
ffffffffc020184e:	88be                	mv	a7,a5
ffffffffc0201850:	852a                	mv	a0,a0
ffffffffc0201852:	85aa                	mv	a1,a0
ffffffffc0201854:	862a                	mv	a2,a0
ffffffffc0201856:	00000073          	ecall
ffffffffc020185a:	852a                	mv	a0,a0
ffffffffc020185c:	2501                	sext.w	a0,a0
ffffffffc020185e:	8082                	ret

ffffffffc0201860 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201860:	c185                	beqz	a1,ffffffffc0201880 <strnlen+0x20>
ffffffffc0201862:	00054783          	lbu	a5,0(a0)
ffffffffc0201866:	cf89                	beqz	a5,ffffffffc0201880 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201868:	4781                	li	a5,0
ffffffffc020186a:	a021                	j	ffffffffc0201872 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020186c:	00074703          	lbu	a4,0(a4)
ffffffffc0201870:	c711                	beqz	a4,ffffffffc020187c <strnlen+0x1c>
        cnt ++;
ffffffffc0201872:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201874:	00f50733          	add	a4,a0,a5
ffffffffc0201878:	fef59ae3          	bne	a1,a5,ffffffffc020186c <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020187c:	853e                	mv	a0,a5
ffffffffc020187e:	8082                	ret
    size_t cnt = 0;
ffffffffc0201880:	4781                	li	a5,0
}
ffffffffc0201882:	853e                	mv	a0,a5
ffffffffc0201884:	8082                	ret

ffffffffc0201886 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201886:	00054783          	lbu	a5,0(a0)
ffffffffc020188a:	0005c703          	lbu	a4,0(a1)
ffffffffc020188e:	cb91                	beqz	a5,ffffffffc02018a2 <strcmp+0x1c>
ffffffffc0201890:	00e79c63          	bne	a5,a4,ffffffffc02018a8 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201894:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201896:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020189a:	0585                	addi	a1,a1,1
ffffffffc020189c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02018a0:	fbe5                	bnez	a5,ffffffffc0201890 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02018a2:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02018a4:	9d19                	subw	a0,a0,a4
ffffffffc02018a6:	8082                	ret
ffffffffc02018a8:	0007851b          	sext.w	a0,a5
ffffffffc02018ac:	9d19                	subw	a0,a0,a4
ffffffffc02018ae:	8082                	ret

ffffffffc02018b0 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02018b0:	00054783          	lbu	a5,0(a0)
ffffffffc02018b4:	cb91                	beqz	a5,ffffffffc02018c8 <strchr+0x18>
        if (*s == c) {
ffffffffc02018b6:	00b79563          	bne	a5,a1,ffffffffc02018c0 <strchr+0x10>
ffffffffc02018ba:	a809                	j	ffffffffc02018cc <strchr+0x1c>
ffffffffc02018bc:	00b78763          	beq	a5,a1,ffffffffc02018ca <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02018c0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02018c2:	00054783          	lbu	a5,0(a0)
ffffffffc02018c6:	fbfd                	bnez	a5,ffffffffc02018bc <strchr+0xc>
    }
    return NULL;
ffffffffc02018c8:	4501                	li	a0,0
}
ffffffffc02018ca:	8082                	ret
ffffffffc02018cc:	8082                	ret

ffffffffc02018ce <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02018ce:	ca01                	beqz	a2,ffffffffc02018de <memset+0x10>
ffffffffc02018d0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02018d2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02018d4:	0785                	addi	a5,a5,1
ffffffffc02018d6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02018da:	fec79de3          	bne	a5,a2,ffffffffc02018d4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02018de:	8082                	ret
