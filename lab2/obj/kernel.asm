
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
ffffffffc0200042:	43a60613          	addi	a2,a2,1082 # ffffffffc0206478 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	0bb010ef          	jal	ra,ffffffffc0201908 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0201920 <etext+0x6>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	140010ef          	jal	ra,ffffffffc02011aa <pmm_init>

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
ffffffffc02000aa:	350010ef          	jal	ra,ffffffffc02013fa <vprintfmt>
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
ffffffffc02000de:	31c010ef          	jal	ra,ffffffffc02013fa <vprintfmt>
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
ffffffffc0200140:	00002517          	auipc	a0,0x2
ffffffffc0200144:	83050513          	addi	a0,a0,-2000 # ffffffffc0201970 <etext+0x56>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	83a50513          	addi	a0,a0,-1990 # ffffffffc0201990 <etext+0x76>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	7b858593          	addi	a1,a1,1976 # ffffffffc020191a <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	84650513          	addi	a0,a0,-1978 # ffffffffc02019b0 <etext+0x96>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	85250513          	addi	a0,a0,-1966 # ffffffffc02019d0 <etext+0xb6>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	2ee58593          	addi	a1,a1,750 # ffffffffc0206478 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	85e50513          	addi	a0,a0,-1954 # ffffffffc02019f0 <etext+0xd6>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	6d958593          	addi	a1,a1,1753 # ffffffffc0206877 <end+0x3ff>
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
ffffffffc02001c4:	85050513          	addi	a0,a0,-1968 # ffffffffc0201a10 <etext+0xf6>
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
ffffffffc02001d4:	77060613          	addi	a2,a2,1904 # ffffffffc0201940 <etext+0x26>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	77c50513          	addi	a0,a0,1916 # ffffffffc0201958 <etext+0x3e>
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
ffffffffc02001f0:	93460613          	addi	a2,a2,-1740 # ffffffffc0201b20 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	94c58593          	addi	a1,a1,-1716 # ffffffffc0201b40 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	94c50513          	addi	a0,a0,-1716 # ffffffffc0201b48 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	94e60613          	addi	a2,a2,-1714 # ffffffffc0201b58 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	96e58593          	addi	a1,a1,-1682 # ffffffffc0201b80 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	92e50513          	addi	a0,a0,-1746 # ffffffffc0201b48 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	96a60613          	addi	a2,a2,-1686 # ffffffffc0201b90 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	98258593          	addi	a1,a1,-1662 # ffffffffc0201bb0 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	91250513          	addi	a0,a0,-1774 # ffffffffc0201b48 <commands+0x108>
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
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	81850513          	addi	a0,a0,-2024 # ffffffffc0201a88 <commands+0x48>
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
ffffffffc0200292:	00002517          	auipc	a0,0x2
ffffffffc0200296:	81e50513          	addi	a0,a0,-2018 # ffffffffc0201ab0 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	798c8c93          	addi	s9,s9,1944 # ffffffffc0201a40 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00002997          	auipc	s3,0x2
ffffffffc02002b4:	82898993          	addi	s3,s3,-2008 # ffffffffc0201ad8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00002917          	auipc	s2,0x2
ffffffffc02002bc:	82890913          	addi	s2,s2,-2008 # ffffffffc0201ae0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00002b17          	auipc	s6,0x2
ffffffffc02002c6:	826b0b13          	addi	s6,s6,-2010 # ffffffffc0201ae8 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	876a8a93          	addi	s5,s5,-1930 # ffffffffc0201b40 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	4b0010ef          	jal	ra,ffffffffc0201786 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	602010ef          	jal	ra,ffffffffc02018ea <strchr>
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
ffffffffc0200302:	742d0d13          	addi	s10,s10,1858 # ffffffffc0201a40 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	5b4010ef          	jal	ra,ffffffffc02018c0 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	5a0010ef          	jal	ra,ffffffffc02018c0 <strcmp>
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
ffffffffc0200386:	564010ef          	jal	ra,ffffffffc02018ea <strchr>
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
ffffffffc02003a2:	76a50513          	addi	a0,a0,1898 # ffffffffc0201b08 <commands+0xc8>
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
ffffffffc02003e2:	7e250513          	addi	a0,a0,2018 # ffffffffc0201bc0 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00001517          	auipc	a0,0x1
ffffffffc02003f8:	64450513          	addi	a0,a0,1604 # ffffffffc0201a38 <etext+0x11e>
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
ffffffffc0200424:	43c010ef          	jal	ra,ffffffffc0201860 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	7ae50513          	addi	a0,a0,1966 # ffffffffc0201be0 <commands+0x1a0>
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
ffffffffc020044c:	4140106f          	j	ffffffffc0201860 <sbi_set_timer>

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
ffffffffc0200456:	3ee0106f          	j	ffffffffc0201844 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	4220106f          	j	ffffffffc020187c <sbi_console_getchar>

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
ffffffffc0200488:	87450513          	addi	a0,a0,-1932 # ffffffffc0201cf8 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	87c50513          	addi	a0,a0,-1924 # ffffffffc0201d10 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	88650513          	addi	a0,a0,-1914 # ffffffffc0201d28 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	89050513          	addi	a0,a0,-1904 # ffffffffc0201d40 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	89a50513          	addi	a0,a0,-1894 # ffffffffc0201d58 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	8a450513          	addi	a0,a0,-1884 # ffffffffc0201d70 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0201d88 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	8b850513          	addi	a0,a0,-1864 # ffffffffc0201da0 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	8c250513          	addi	a0,a0,-1854 # ffffffffc0201db8 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0201dd0 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	8d650513          	addi	a0,a0,-1834 # ffffffffc0201de8 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	8e050513          	addi	a0,a0,-1824 # ffffffffc0201e00 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0201e18 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	8f450513          	addi	a0,a0,-1804 # ffffffffc0201e30 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0201e48 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	90850513          	addi	a0,a0,-1784 # ffffffffc0201e60 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	91250513          	addi	a0,a0,-1774 # ffffffffc0201e78 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	91c50513          	addi	a0,a0,-1764 # ffffffffc0201e90 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	92650513          	addi	a0,a0,-1754 # ffffffffc0201ea8 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	93050513          	addi	a0,a0,-1744 # ffffffffc0201ec0 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	93a50513          	addi	a0,a0,-1734 # ffffffffc0201ed8 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	94450513          	addi	a0,a0,-1724 # ffffffffc0201ef0 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	94e50513          	addi	a0,a0,-1714 # ffffffffc0201f08 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	95850513          	addi	a0,a0,-1704 # ffffffffc0201f20 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	96250513          	addi	a0,a0,-1694 # ffffffffc0201f38 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	96c50513          	addi	a0,a0,-1684 # ffffffffc0201f50 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	97650513          	addi	a0,a0,-1674 # ffffffffc0201f68 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	98050513          	addi	a0,a0,-1664 # ffffffffc0201f80 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	98a50513          	addi	a0,a0,-1654 # ffffffffc0201f98 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	99450513          	addi	a0,a0,-1644 # ffffffffc0201fb0 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	99e50513          	addi	a0,a0,-1634 # ffffffffc0201fc8 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	9a450513          	addi	a0,a0,-1628 # ffffffffc0201fe0 <commands+0x5a0>
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
ffffffffc0200656:	9a650513          	addi	a0,a0,-1626 # ffffffffc0201ff8 <commands+0x5b8>
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
ffffffffc020066e:	9a650513          	addi	a0,a0,-1626 # ffffffffc0202010 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0202028 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	9b650513          	addi	a0,a0,-1610 # ffffffffc0202040 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0202058 <commands+0x618>
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
ffffffffc02006c0:	54070713          	addi	a4,a4,1344 # ffffffffc0201bfc <commands+0x1bc>
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
ffffffffc02006d2:	5c250513          	addi	a0,a0,1474 # ffffffffc0201c90 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	59650513          	addi	a0,a0,1430 # ffffffffc0201c70 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	54a50513          	addi	a0,a0,1354 # ffffffffc0201c30 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	5be50513          	addi	a0,a0,1470 # ffffffffc0201cb0 <commands+0x270>
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
ffffffffc020072e:	5ae50513          	addi	a0,a0,1454 # ffffffffc0201cd8 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	51a50513          	addi	a0,a0,1306 # ffffffffc0201c50 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	57c50513          	addi	a0,a0,1404 # ffffffffc0201cc8 <commands+0x288>
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
    }
    return n;//size的最小2的幂次方的指数
}

static void buddy_init(void) {
    free_page_num = 0;
ffffffffc020081e:	00006797          	auipc	a5,0x6
ffffffffc0200822:	c207a123          	sw	zero,-990(a5) # ffffffffc0206440 <free_page_num>
}
ffffffffc0200826:	8082                	ret

ffffffffc0200828 <buddy_nr_free_pages>:
    free_page_num += n;//更新空闲页数目
    cprintf("finish!\n");
}

static size_t buddy_nr_free_pages(void) {
    return free_page_num;
ffffffffc0200828:	00006797          	auipc	a5,0x6
ffffffffc020082c:	c1878793          	addi	a5,a5,-1000 # ffffffffc0206440 <free_page_num>
}
ffffffffc0200830:	4388                	lw	a0,0(a5)
ffffffffc0200832:	8082                	ret

ffffffffc0200834 <buddy_free_pages>:
static void buddy_free_pages(struct Page* base, size_t n) {
ffffffffc0200834:	7179                	addi	sp,sp,-48
ffffffffc0200836:	f022                	sd	s0,32(sp)
ffffffffc0200838:	ec26                	sd	s1,24(sp)
ffffffffc020083a:	842a                	mv	s0,a0
ffffffffc020083c:	84ae                	mv	s1,a1
    cprintf("free  %u pages", n);
ffffffffc020083e:	00002517          	auipc	a0,0x2
ffffffffc0200842:	98250513          	addi	a0,a0,-1662 # ffffffffc02021c0 <commands+0x780>
static void buddy_free_pages(struct Page* base, size_t n) {
ffffffffc0200846:	f406                	sd	ra,40(sp)
ffffffffc0200848:	e84a                	sd	s2,16(sp)
ffffffffc020084a:	e44e                	sd	s3,8(sp)
    cprintf("free  %u pages", n);
ffffffffc020084c:	86bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert(n > 0);
ffffffffc0200850:	1c048c63          	beqz	s1,ffffffffc0200a28 <buddy_free_pages+0x1f4>
    n = 1 << UP_LOG(n);
ffffffffc0200854:	0004869b          	sext.w	a3,s1
    while(temp>>=1)
ffffffffc0200858:	4016d793          	srai	a5,a3,0x1
ffffffffc020085c:	16078463          	beqz	a5,ffffffffc02009c4 <buddy_free_pages+0x190>
    int n=0;//幂次
ffffffffc0200860:	4901                	li	s2,0
ffffffffc0200862:	a011                	j	ffffffffc0200866 <buddy_free_pages+0x32>
        n++;
ffffffffc0200864:	893a                	mv	s2,a4
    while(temp>>=1)
ffffffffc0200866:	8785                	srai	a5,a5,0x1
        n++;
ffffffffc0200868:	0019071b          	addiw	a4,s2,1
    while(temp>>=1)
ffffffffc020086c:	ffe5                	bnez	a5,ffffffffc0200864 <buddy_free_pages+0x30>
    temp= (size>>n)<<n;
ffffffffc020086e:	40e6d7bb          	sraw	a5,a3,a4
    if(size-temp!=0)//如果不为0说明size的二进制表示中还有1的位
ffffffffc0200872:	00e797bb          	sllw	a5,a5,a4
ffffffffc0200876:	14d78363          	beq	a5,a3,ffffffffc02009bc <buddy_free_pages+0x188>
        n++;//向上取
ffffffffc020087a:	2909                	addiw	s2,s2,2
ffffffffc020087c:	4785                	li	a5,1
ffffffffc020087e:	0127993b          	sllw	s2,a5,s2
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200882:	641c                	ld	a5,8(s0)
    assert(!PageReserved(base));
ffffffffc0200884:	8b85                	andi	a5,a5,1
ffffffffc0200886:	18079163          	bnez	a5,ffffffffc0200a08 <buddy_free_pages+0x1d4>
    for(struct Page* p = base; p < base + n; p++){
ffffffffc020088a:	00291693          	slli	a3,s2,0x2
ffffffffc020088e:	96ca                	add	a3,a3,s2
ffffffffc0200890:	068e                	slli	a3,a3,0x3
ffffffffc0200892:	96a2                	add	a3,a3,s0
ffffffffc0200894:	02d47b63          	bleu	a3,s0,ffffffffc02008ca <buddy_free_pages+0x96>
ffffffffc0200898:	641c                	ld	a5,8(s0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020089a:	8b85                	andi	a5,a5,1
ffffffffc020089c:	12079663          	bnez	a5,ffffffffc02009c8 <buddy_free_pages+0x194>
ffffffffc02008a0:	641c                	ld	a5,8(s0)
ffffffffc02008a2:	8385                	srli	a5,a5,0x1
ffffffffc02008a4:	8b85                	andi	a5,a5,1
ffffffffc02008a6:	12079163          	bnez	a5,ffffffffc02009c8 <buddy_free_pages+0x194>
ffffffffc02008aa:	87a2                	mv	a5,s0
ffffffffc02008ac:	a809                	j	ffffffffc02008be <buddy_free_pages+0x8a>
ffffffffc02008ae:	6798                	ld	a4,8(a5)
ffffffffc02008b0:	8b05                	andi	a4,a4,1
ffffffffc02008b2:	10071b63          	bnez	a4,ffffffffc02009c8 <buddy_free_pages+0x194>
ffffffffc02008b6:	6798                	ld	a4,8(a5)
ffffffffc02008b8:	8b09                	andi	a4,a4,2
ffffffffc02008ba:	10071763          	bnez	a4,ffffffffc02009c8 <buddy_free_pages+0x194>



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02008be:	0007a023          	sw	zero,0(a5)
    for(struct Page* p = base; p < base + n; p++){
ffffffffc02008c2:	02878793          	addi	a5,a5,40
ffffffffc02008c6:	fed7e4e3          	bltu	a5,a3,ffffffffc02008ae <buddy_free_pages+0x7a>
    unsigned offset = base - page_base;
ffffffffc02008ca:	00006797          	auipc	a5,0x6
ffffffffc02008ce:	b7e78793          	addi	a5,a5,-1154 # ffffffffc0206448 <page_base>
ffffffffc02008d2:	6390                	ld	a2,0(a5)
ffffffffc02008d4:	00002797          	auipc	a5,0x2
ffffffffc02008d8:	8e478793          	addi	a5,a5,-1820 # ffffffffc02021b8 <commands+0x778>
ffffffffc02008dc:	639c                	ld	a5,0(a5)
ffffffffc02008de:	40c40633          	sub	a2,s0,a2
ffffffffc02008e2:	860d                	srai	a2,a2,0x3
ffffffffc02008e4:	02f6063b          	mulw	a2,a2,a5
    unsigned index = manager_size / 2 + offset;
ffffffffc02008e8:	00006797          	auipc	a5,0x6
ffffffffc02008ec:	b5c78793          	addi	a5,a5,-1188 # ffffffffc0206444 <manager_size>
ffffffffc02008f0:	439c                	lw	a5,0(a5)
    unsigned node_size = 1;
ffffffffc02008f2:	4705                	li	a4,1
        assert(index);
ffffffffc02008f4:	4805                	li	a6,1
    unsigned index = manager_size / 2 + offset;
ffffffffc02008f6:	01f7d59b          	srliw	a1,a5,0x1f
ffffffffc02008fa:	9dbd                	addw	a1,a1,a5
ffffffffc02008fc:	4015d59b          	sraiw	a1,a1,0x1
ffffffffc0200900:	9db1                	addw	a1,a1,a2
    while(node_size!=n){
ffffffffc0200902:	a029                	j	ffffffffc020090c <buddy_free_pages+0xd8>
        assert(index);
ffffffffc0200904:	8736                	mv	a4,a3
ffffffffc0200906:	0eb87163          	bleu	a1,a6,ffffffffc02009e8 <buddy_free_pages+0x1b4>
ffffffffc020090a:	85aa                	mv	a1,a0
    while(node_size!=n){
ffffffffc020090c:	02071793          	slli	a5,a4,0x20
ffffffffc0200910:	0017141b          	slliw	s0,a4,0x1
ffffffffc0200914:	0015d49b          	srliw	s1,a1,0x1
ffffffffc0200918:	9381                	srli	a5,a5,0x20
ffffffffc020091a:	8526                	mv	a0,s1
ffffffffc020091c:	86a2                	mv	a3,s0
ffffffffc020091e:	ff2793e3          	bne	a5,s2,ffffffffc0200904 <buddy_free_pages+0xd0>
    buddy_manager[index] = node_size;
ffffffffc0200922:	00006997          	auipc	s3,0x6
ffffffffc0200926:	b1698993          	addi	s3,s3,-1258 # ffffffffc0206438 <buddy_manager>
ffffffffc020092a:	0009b783          	ld	a5,0(s3)
ffffffffc020092e:	02059693          	slli	a3,a1,0x20
ffffffffc0200932:	82f9                	srli	a3,a3,0x1e
ffffffffc0200934:	97b6                	add	a5,a5,a3
ffffffffc0200936:	c398                	sw	a4,0(a5)
    cprintf(" index:%u offset:%u ", index, offset);
ffffffffc0200938:	00002517          	auipc	a0,0x2
ffffffffc020093c:	91850513          	addi	a0,a0,-1768 # ffffffffc0202250 <commands+0x810>
ffffffffc0200940:	f76ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    while(index){
ffffffffc0200944:	c0b9                	beqz	s1,ffffffffc020098a <buddy_free_pages+0x156>
        unsigned leftSize = buddy_manager[LEFT_LEAF(index)];
ffffffffc0200946:	0009b683          	ld	a3,0(s3)
ffffffffc020094a:	a801                	j	ffffffffc020095a <buddy_free_pages+0x126>
        else if(leftSize>rightSize){//当前节点的大小更新为左节点的大小
ffffffffc020094c:	06c77663          	bleu	a2,a4,ffffffffc02009b8 <buddy_free_pages+0x184>
            buddy_manager[index] = leftSize;
ffffffffc0200950:	c390                	sw	a2,0(a5)
        index = PARENT(index);
ffffffffc0200952:	8085                	srli	s1,s1,0x1
        node_size *= 2;
ffffffffc0200954:	0014141b          	slliw	s0,s0,0x1
    while(index){
ffffffffc0200958:	c88d                	beqz	s1,ffffffffc020098a <buddy_free_pages+0x156>
        unsigned leftSize = buddy_manager[LEFT_LEAF(index)];
ffffffffc020095a:	0014979b          	slliw	a5,s1,0x1
        unsigned rightSize = buddy_manager[RIGHT_LEAF(index)];
ffffffffc020095e:	2785                	addiw	a5,a5,1
ffffffffc0200960:	1782                	slli	a5,a5,0x20
ffffffffc0200962:	9381                	srli	a5,a5,0x20
        unsigned leftSize = buddy_manager[LEFT_LEAF(index)];
ffffffffc0200964:	00349713          	slli	a4,s1,0x3
        unsigned rightSize = buddy_manager[RIGHT_LEAF(index)];
ffffffffc0200968:	078a                	slli	a5,a5,0x2
        unsigned leftSize = buddy_manager[LEFT_LEAF(index)];
ffffffffc020096a:	9736                	add	a4,a4,a3
        unsigned rightSize = buddy_manager[RIGHT_LEAF(index)];
ffffffffc020096c:	97b6                	add	a5,a5,a3
        unsigned leftSize = buddy_manager[LEFT_LEAF(index)];
ffffffffc020096e:	4310                	lw	a2,0(a4)
        unsigned rightSize = buddy_manager[RIGHT_LEAF(index)];
ffffffffc0200970:	4398                	lw	a4,0(a5)
        if(leftSize + rightSize == node_size){//该节点对应的空闲空间是连续的，可合并
ffffffffc0200972:	00249793          	slli	a5,s1,0x2
ffffffffc0200976:	97b6                	add	a5,a5,a3
ffffffffc0200978:	00e605bb          	addw	a1,a2,a4
ffffffffc020097c:	fc8598e3          	bne	a1,s0,ffffffffc020094c <buddy_free_pages+0x118>
            buddy_manager[index] = node_size;
ffffffffc0200980:	c380                	sw	s0,0(a5)
        index = PARENT(index);
ffffffffc0200982:	8085                	srli	s1,s1,0x1
        node_size *= 2;
ffffffffc0200984:	0014141b          	slliw	s0,s0,0x1
    while(index){
ffffffffc0200988:	f8e9                	bnez	s1,ffffffffc020095a <buddy_free_pages+0x126>
    free_page_num += n;//更新空闲页数目
ffffffffc020098a:	00006797          	auipc	a5,0x6
ffffffffc020098e:	ab678793          	addi	a5,a5,-1354 # ffffffffc0206440 <free_page_num>
ffffffffc0200992:	439c                	lw	a5,0(a5)
}
ffffffffc0200994:	7402                	ld	s0,32(sp)
ffffffffc0200996:	70a2                	ld	ra,40(sp)
    free_page_num += n;//更新空闲页数目
ffffffffc0200998:	0127893b          	addw	s2,a5,s2
ffffffffc020099c:	00006797          	auipc	a5,0x6
ffffffffc02009a0:	ab27a223          	sw	s2,-1372(a5) # ffffffffc0206440 <free_page_num>
}
ffffffffc02009a4:	64e2                	ld	s1,24(sp)
ffffffffc02009a6:	6942                	ld	s2,16(sp)
ffffffffc02009a8:	69a2                	ld	s3,8(sp)
    cprintf("finish!\n");
ffffffffc02009aa:	00002517          	auipc	a0,0x2
ffffffffc02009ae:	8be50513          	addi	a0,a0,-1858 # ffffffffc0202268 <commands+0x828>
}
ffffffffc02009b2:	6145                	addi	sp,sp,48
    cprintf("finish!\n");
ffffffffc02009b4:	f02ff06f          	j	ffffffffc02000b6 <cprintf>
            buddy_manager[index] = rightSize;
ffffffffc02009b8:	c398                	sw	a4,0(a5)
ffffffffc02009ba:	bf61                	j	ffffffffc0200952 <buddy_free_pages+0x11e>
ffffffffc02009bc:	4905                	li	s2,1
ffffffffc02009be:	00e9193b          	sllw	s2,s2,a4
ffffffffc02009c2:	b5c1                	j	ffffffffc0200882 <buddy_free_pages+0x4e>
    while(temp>>=1)
ffffffffc02009c4:	4905                	li	s2,1
ffffffffc02009c6:	bd75                	j	ffffffffc0200882 <buddy_free_pages+0x4e>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02009c8:	00002697          	auipc	a3,0x2
ffffffffc02009cc:	84068693          	addi	a3,a3,-1984 # ffffffffc0202208 <commands+0x7c8>
ffffffffc02009d0:	00002617          	auipc	a2,0x2
ffffffffc02009d4:	80860613          	addi	a2,a2,-2040 # ffffffffc02021d8 <commands+0x798>
ffffffffc02009d8:	0a400593          	li	a1,164
ffffffffc02009dc:	00002517          	auipc	a0,0x2
ffffffffc02009e0:	81450513          	addi	a0,a0,-2028 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc02009e4:	9c9ff0ef          	jal	ra,ffffffffc02003ac <__panic>
        assert(index);
ffffffffc02009e8:	00002697          	auipc	a3,0x2
ffffffffc02009ec:	86068693          	addi	a3,a3,-1952 # ffffffffc0202248 <commands+0x808>
ffffffffc02009f0:	00001617          	auipc	a2,0x1
ffffffffc02009f4:	7e860613          	addi	a2,a2,2024 # ffffffffc02021d8 <commands+0x798>
ffffffffc02009f8:	0b300593          	li	a1,179
ffffffffc02009fc:	00001517          	auipc	a0,0x1
ffffffffc0200a00:	7f450513          	addi	a0,a0,2036 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200a04:	9a9ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageReserved(base));
ffffffffc0200a08:	00002697          	auipc	a3,0x2
ffffffffc0200a0c:	82868693          	addi	a3,a3,-2008 # ffffffffc0202230 <commands+0x7f0>
ffffffffc0200a10:	00001617          	auipc	a2,0x1
ffffffffc0200a14:	7c860613          	addi	a2,a2,1992 # ffffffffc02021d8 <commands+0x798>
ffffffffc0200a18:	0a200593          	li	a1,162
ffffffffc0200a1c:	00001517          	auipc	a0,0x1
ffffffffc0200a20:	7d450513          	addi	a0,a0,2004 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200a24:	989ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200a28:	00001697          	auipc	a3,0x1
ffffffffc0200a2c:	7a868693          	addi	a3,a3,1960 # ffffffffc02021d0 <commands+0x790>
ffffffffc0200a30:	00001617          	auipc	a2,0x1
ffffffffc0200a34:	7a860613          	addi	a2,a2,1960 # ffffffffc02021d8 <commands+0x798>
ffffffffc0200a38:	09d00593          	li	a1,157
ffffffffc0200a3c:	00001517          	auipc	a0,0x1
ffffffffc0200a40:	7b450513          	addi	a0,a0,1972 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200a44:	969ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200a48 <buddy_init_memmap>:
    for(p = base; p != base + n; p++){
ffffffffc0200a48:	00259693          	slli	a3,a1,0x2
ffffffffc0200a4c:	96ae                	add	a3,a3,a1
static void buddy_init_memmap(struct Page *base, size_t n){
ffffffffc0200a4e:	1101                	addi	sp,sp,-32
    for(p = base; p != base + n; p++){
ffffffffc0200a50:	068e                	slli	a3,a3,0x3
static void buddy_init_memmap(struct Page *base, size_t n){
ffffffffc0200a52:	ec06                	sd	ra,24(sp)
ffffffffc0200a54:	e822                	sd	s0,16(sp)
ffffffffc0200a56:	e426                	sd	s1,8(sp)
    for(p = base; p != base + n; p++){
ffffffffc0200a58:	96aa                	add	a3,a3,a0
ffffffffc0200a5a:	02d50a63          	beq	a0,a3,ffffffffc0200a8e <buddy_init_memmap+0x46>
ffffffffc0200a5e:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0200a60:	87aa                	mv	a5,a0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200a62:	4609                	li	a2,2
ffffffffc0200a64:	8b05                	andi	a4,a4,1
ffffffffc0200a66:	e711                	bnez	a4,ffffffffc0200a72 <buddy_init_memmap+0x2a>
ffffffffc0200a68:	a261                	j	ffffffffc0200bf0 <buddy_init_memmap+0x1a8>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a6a:	6798                	ld	a4,8(a5)
ffffffffc0200a6c:	8b05                	andi	a4,a4,1
ffffffffc0200a6e:	18070163          	beqz	a4,ffffffffc0200bf0 <buddy_init_memmap+0x1a8>
        p->flags = p->property = 0;
ffffffffc0200a72:	0007a823          	sw	zero,16(a5)
ffffffffc0200a76:	0007b423          	sd	zero,8(a5)
ffffffffc0200a7a:	0007a023          	sw	zero,0(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200a7e:	00878713          	addi	a4,a5,8
ffffffffc0200a82:	40c7302f          	amoor.d	zero,a2,(a4)
    for(p = base; p != base + n; p++){
ffffffffc0200a86:	02878793          	addi	a5,a5,40
ffffffffc0200a8a:	fed790e3          	bne	a5,a3,ffffffffc0200a6a <buddy_init_memmap+0x22>
    manager_size = 2 * (1<<UP_LOG(n));
ffffffffc0200a8e:	0005861b          	sext.w	a2,a1
    while(temp>>=1)
ffffffffc0200a92:	40165793          	srai	a5,a2,0x1
    int n=0;//幂次
ffffffffc0200a96:	4701                	li	a4,0
    while(temp>>=1)
ffffffffc0200a98:	e399                	bnez	a5,ffffffffc0200a9e <buddy_init_memmap+0x56>
ffffffffc0200a9a:	a2b9                	j	ffffffffc0200be8 <buddy_init_memmap+0x1a0>
        n++;
ffffffffc0200a9c:	8736                	mv	a4,a3
    while(temp>>=1)
ffffffffc0200a9e:	8785                	srai	a5,a5,0x1
        n++;
ffffffffc0200aa0:	0017069b          	addiw	a3,a4,1
    while(temp>>=1)
ffffffffc0200aa4:	ffe5                	bnez	a5,ffffffffc0200a9c <buddy_init_memmap+0x54>
    temp= (size>>n)<<n;
ffffffffc0200aa6:	40d657bb          	sraw	a5,a2,a3
    if(size-temp!=0)//如果不为0说明size的二进制表示中还有1的位
ffffffffc0200aaa:	00d797bb          	sllw	a5,a5,a3
ffffffffc0200aae:	12c78963          	beq	a5,a2,ffffffffc0200be0 <buddy_init_memmap+0x198>
        n++;//向上取
ffffffffc0200ab2:	0027079b          	addiw	a5,a4,2
ffffffffc0200ab6:	4709                	li	a4,2
ffffffffc0200ab8:	00f7173b          	sllw	a4,a4,a5
ffffffffc0200abc:	41f7579b          	sraiw	a5,a4,0x1f
ffffffffc0200ac0:	0167d79b          	srliw	a5,a5,0x16
ffffffffc0200ac4:	9fb9                	addw	a5,a5,a4
ffffffffc0200ac6:	40a7d79b          	sraiw	a5,a5,0xa
ffffffffc0200aca:	00279893          	slli	a7,a5,0x2
ffffffffc0200ace:	98be                	add	a7,a7,a5
ffffffffc0200ad0:	01f7581b          	srliw	a6,a4,0x1f
ffffffffc0200ad4:	088e                	slli	a7,a7,0x3
ffffffffc0200ad6:	00e8083b          	addw	a6,a6,a4
ffffffffc0200ada:	98aa                	add	a7,a7,a0
ffffffffc0200adc:	4018581b          	sraiw	a6,a6,0x1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ae0:	00006697          	auipc	a3,0x6
ffffffffc0200ae4:	99068693          	addi	a3,a3,-1648 # ffffffffc0206470 <pages>
ffffffffc0200ae8:	6294                	ld	a3,0(a3)
ffffffffc0200aea:	00001617          	auipc	a2,0x1
ffffffffc0200aee:	6ce60613          	addi	a2,a2,1742 # ffffffffc02021b8 <commands+0x778>
ffffffffc0200af2:	6210                	ld	a2,0(a2)
ffffffffc0200af4:	40d506b3          	sub	a3,a0,a3
ffffffffc0200af8:	868d                	srai	a3,a3,0x3
ffffffffc0200afa:	02c686b3          	mul	a3,a3,a2
ffffffffc0200afe:	00002617          	auipc	a2,0x2
ffffffffc0200b02:	c1a60613          	addi	a2,a2,-998 # ffffffffc0202718 <nbase>
ffffffffc0200b06:	6210                	ld	a2,0(a2)
    free_page_num = n - 4 * manager_size / 4096;
ffffffffc0200b08:	9d9d                	subw	a1,a1,a5
ffffffffc0200b0a:	00006797          	auipc	a5,0x6
ffffffffc0200b0e:	92b7ab23          	sw	a1,-1738(a5) # ffffffffc0206440 <free_page_num>
    manager_size = 2 * (1<<UP_LOG(n));
ffffffffc0200b12:	00006797          	auipc	a5,0x6
ffffffffc0200b16:	92e7a923          	sw	a4,-1742(a5) # ffffffffc0206444 <manager_size>
    page_base = base;
ffffffffc0200b1a:	00006797          	auipc	a5,0x6
ffffffffc0200b1e:	9317b723          	sd	a7,-1746(a5) # ffffffffc0206448 <page_base>
    unsigned i = 1;
ffffffffc0200b22:	4785                	li	a5,1
ffffffffc0200b24:	00006417          	auipc	s0,0x6
ffffffffc0200b28:	92040413          	addi	s0,s0,-1760 # ffffffffc0206444 <manager_size>
ffffffffc0200b2c:	96b2                	add	a3,a3,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b2e:	06b2                	slli	a3,a3,0xc
    buddy_manager = (unsigned*) page2pa(base);
ffffffffc0200b30:	00006617          	auipc	a2,0x6
ffffffffc0200b34:	90d63423          	sd	a3,-1784(a2) # ffffffffc0206438 <buddy_manager>
    for(; i < manager_size; i++){
ffffffffc0200b38:	02e7f463          	bleu	a4,a5,ffffffffc0200b60 <buddy_init_memmap+0x118>
        buddy_manager[i] = node_size;
ffffffffc0200b3c:	02079713          	slli	a4,a5,0x20
ffffffffc0200b40:	8379                	srli	a4,a4,0x1e
        if(IS_POWER_OF_2(i+1)){
ffffffffc0200b42:	0017861b          	addiw	a2,a5,1
        buddy_manager[i] = node_size;
ffffffffc0200b46:	9736                	add	a4,a4,a3
        if(IS_POWER_OF_2(i+1)){
ffffffffc0200b48:	8ff1                	and	a5,a5,a2
        buddy_manager[i] = node_size;
ffffffffc0200b4a:	01072023          	sw	a6,0(a4)
        if(IS_POWER_OF_2(i+1)){
ffffffffc0200b4e:	2781                	sext.w	a5,a5
ffffffffc0200b50:	e399                	bnez	a5,ffffffffc0200b56 <buddy_init_memmap+0x10e>
            node_size /= 2;//如果 i+1 是2的幂次方，则调整节点大小为原来的一半
ffffffffc0200b52:	0018581b          	srliw	a6,a6,0x1
ffffffffc0200b56:	4018                	lw	a4,0(s0)
        if(IS_POWER_OF_2(i+1)){
ffffffffc0200b58:	0006079b          	sext.w	a5,a2
    for(; i < manager_size; i++){
ffffffffc0200b5c:	fee7e0e3          	bltu	a5,a4,ffffffffc0200b3c <buddy_init_memmap+0xf4>
    base->property = free_page_num;//// 将 base 的属性设置为剩余可用页数
ffffffffc0200b60:	00006497          	auipc	s1,0x6
ffffffffc0200b64:	8e048493          	addi	s1,s1,-1824 # ffffffffc0206440 <free_page_num>
ffffffffc0200b68:	409c                	lw	a5,0(s1)
ffffffffc0200b6a:	00888713          	addi	a4,a7,8
ffffffffc0200b6e:	00f8a823          	sw	a5,16(a7)
ffffffffc0200b72:	4789                	li	a5,2
ffffffffc0200b74:	40f7302f          	amoor.d	zero,a5,(a4)
    cprintf("===================buddy init end===================\n");
ffffffffc0200b78:	00001517          	auipc	a0,0x1
ffffffffc0200b7c:	71050513          	addi	a0,a0,1808 # ffffffffc0202288 <commands+0x848>
ffffffffc0200b80:	d36ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("free_size = %d\n", free_page_num);
ffffffffc0200b84:	408c                	lw	a1,0(s1)
ffffffffc0200b86:	00001517          	auipc	a0,0x1
ffffffffc0200b8a:	73a50513          	addi	a0,a0,1850 # ffffffffc02022c0 <commands+0x880>
ffffffffc0200b8e:	d28ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("buddy_size = %d\n", manager_size);
ffffffffc0200b92:	400c                	lw	a1,0(s0)
ffffffffc0200b94:	00001517          	auipc	a0,0x1
ffffffffc0200b98:	73c50513          	addi	a0,a0,1852 # ffffffffc02022d0 <commands+0x890>
ffffffffc0200b9c:	d1aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("buddy_addr = 0x%08x\n", buddy_manager);
ffffffffc0200ba0:	00006797          	auipc	a5,0x6
ffffffffc0200ba4:	89878793          	addi	a5,a5,-1896 # ffffffffc0206438 <buddy_manager>
ffffffffc0200ba8:	638c                	ld	a1,0(a5)
ffffffffc0200baa:	00001517          	auipc	a0,0x1
ffffffffc0200bae:	73e50513          	addi	a0,a0,1854 # ffffffffc02022e8 <commands+0x8a8>
ffffffffc0200bb2:	d04ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("manager_page_base = 0x%08x\n", page_base);
ffffffffc0200bb6:	00006797          	auipc	a5,0x6
ffffffffc0200bba:	89278793          	addi	a5,a5,-1902 # ffffffffc0206448 <page_base>
ffffffffc0200bbe:	638c                	ld	a1,0(a5)
ffffffffc0200bc0:	00001517          	auipc	a0,0x1
ffffffffc0200bc4:	74050513          	addi	a0,a0,1856 # ffffffffc0202300 <commands+0x8c0>
ffffffffc0200bc8:	ceeff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
}
ffffffffc0200bcc:	6442                	ld	s0,16(sp)
ffffffffc0200bce:	60e2                	ld	ra,24(sp)
ffffffffc0200bd0:	64a2                	ld	s1,8(sp)
    cprintf("====================================================\n");
ffffffffc0200bd2:	00001517          	auipc	a0,0x1
ffffffffc0200bd6:	74e50513          	addi	a0,a0,1870 # ffffffffc0202320 <commands+0x8e0>
}
ffffffffc0200bda:	6105                	addi	sp,sp,32
    cprintf("====================================================\n");
ffffffffc0200bdc:	cdaff06f          	j	ffffffffc02000b6 <cprintf>
ffffffffc0200be0:	4709                	li	a4,2
ffffffffc0200be2:	00d7173b          	sllw	a4,a4,a3
ffffffffc0200be6:	bdd9                	j	ffffffffc0200abc <buddy_init_memmap+0x74>
    while(temp>>=1)
ffffffffc0200be8:	88aa                	mv	a7,a0
ffffffffc0200bea:	4805                	li	a6,1
ffffffffc0200bec:	4709                	li	a4,2
ffffffffc0200bee:	bdcd                	j	ffffffffc0200ae0 <buddy_init_memmap+0x98>
        assert(PageReserved(p));
ffffffffc0200bf0:	00001697          	auipc	a3,0x1
ffffffffc0200bf4:	68868693          	addi	a3,a3,1672 # ffffffffc0202278 <commands+0x838>
ffffffffc0200bf8:	00001617          	auipc	a2,0x1
ffffffffc0200bfc:	5e060613          	addi	a2,a2,1504 # ffffffffc02021d8 <commands+0x798>
ffffffffc0200c00:	02f00593          	li	a1,47
ffffffffc0200c04:	00001517          	auipc	a0,0x1
ffffffffc0200c08:	5ec50513          	addi	a0,a0,1516 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200c0c:	fa0ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c10 <buddy_check>:

// }


static void
buddy_check(void) {
ffffffffc0200c10:	7139                	addi	sp,sp,-64
    cprintf("buddy check!\n");
ffffffffc0200c12:	00001517          	auipc	a0,0x1
ffffffffc0200c16:	47650513          	addi	a0,a0,1142 # ffffffffc0202088 <commands+0x648>
buddy_check(void) {
ffffffffc0200c1a:	fc06                	sd	ra,56(sp)
ffffffffc0200c1c:	f822                	sd	s0,48(sp)
ffffffffc0200c1e:	f426                	sd	s1,40(sp)
ffffffffc0200c20:	f04a                	sd	s2,32(sp)
ffffffffc0200c22:	ec4e                	sd	s3,24(sp)
ffffffffc0200c24:	e852                	sd	s4,16(sp)
ffffffffc0200c26:	e456                	sd	s5,8(sp)
    cprintf("buddy check!\n");
ffffffffc0200c28:	c8eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    struct Page *p0, *A, *B, *C, *D;
    p0 = A = B = C = D = NULL;

    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c2c:	4505                	li	a0,1
ffffffffc0200c2e:	4f2000ef          	jal	ra,ffffffffc0201120 <alloc_pages>
ffffffffc0200c32:	1a050b63          	beqz	a0,ffffffffc0200de8 <buddy_check+0x1d8>
ffffffffc0200c36:	842a                	mv	s0,a0
    assert((A = alloc_page()) != NULL);
ffffffffc0200c38:	4505                	li	a0,1
ffffffffc0200c3a:	4e6000ef          	jal	ra,ffffffffc0201120 <alloc_pages>
ffffffffc0200c3e:	84aa                	mv	s1,a0
ffffffffc0200c40:	1c050463          	beqz	a0,ffffffffc0200e08 <buddy_check+0x1f8>
    assert((B = alloc_page()) != NULL);
ffffffffc0200c44:	4505                	li	a0,1
ffffffffc0200c46:	4da000ef          	jal	ra,ffffffffc0201120 <alloc_pages>
ffffffffc0200c4a:	892a                	mv	s2,a0
ffffffffc0200c4c:	1e050e63          	beqz	a0,ffffffffc0200e48 <buddy_check+0x238>

    assert(p0 != A && p0 != B && A != B);
ffffffffc0200c50:	12940c63          	beq	s0,s1,ffffffffc0200d88 <buddy_check+0x178>
ffffffffc0200c54:	12a40a63          	beq	s0,a0,ffffffffc0200d88 <buddy_check+0x178>
ffffffffc0200c58:	12a48863          	beq	s1,a0,ffffffffc0200d88 <buddy_check+0x178>
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
ffffffffc0200c5c:	401c                	lw	a5,0(s0)
ffffffffc0200c5e:	14079563          	bnez	a5,ffffffffc0200da8 <buddy_check+0x198>
ffffffffc0200c62:	409c                	lw	a5,0(s1)
ffffffffc0200c64:	14079263          	bnez	a5,ffffffffc0200da8 <buddy_check+0x198>
ffffffffc0200c68:	411c                	lw	a5,0(a0)
ffffffffc0200c6a:	12079f63          	bnez	a5,ffffffffc0200da8 <buddy_check+0x198>

    free_page(p0);
ffffffffc0200c6e:	8522                	mv	a0,s0
ffffffffc0200c70:	4585                	li	a1,1
ffffffffc0200c72:	4f2000ef          	jal	ra,ffffffffc0201164 <free_pages>
    free_page(A);
ffffffffc0200c76:	8526                	mv	a0,s1
ffffffffc0200c78:	4585                	li	a1,1
ffffffffc0200c7a:	4ea000ef          	jal	ra,ffffffffc0201164 <free_pages>
    free_page(B);
ffffffffc0200c7e:	4585                	li	a1,1
ffffffffc0200c80:	854a                	mv	a0,s2
ffffffffc0200c82:	4e2000ef          	jal	ra,ffffffffc0201164 <free_pages>

    A = alloc_pages(512);
ffffffffc0200c86:	20000513          	li	a0,512
ffffffffc0200c8a:	496000ef          	jal	ra,ffffffffc0201120 <alloc_pages>
ffffffffc0200c8e:	842a                	mv	s0,a0
    B = alloc_pages(512);
ffffffffc0200c90:	20000513          	li	a0,512
ffffffffc0200c94:	48c000ef          	jal	ra,ffffffffc0201120 <alloc_pages>
ffffffffc0200c98:	84aa                	mv	s1,a0
    free_pages(A, 256);
ffffffffc0200c9a:	10000593          	li	a1,256
ffffffffc0200c9e:	8522                	mv	a0,s0
ffffffffc0200ca0:	4c4000ef          	jal	ra,ffffffffc0201164 <free_pages>
    free_pages(B, 512);
ffffffffc0200ca4:	20000593          	li	a1,512
ffffffffc0200ca8:	8526                	mv	a0,s1
ffffffffc0200caa:	4ba000ef          	jal	ra,ffffffffc0201164 <free_pages>
    free_pages(A + 256, 256);
ffffffffc0200cae:	650d                	lui	a0,0x3
ffffffffc0200cb0:	80050513          	addi	a0,a0,-2048 # 2800 <BASE_ADDRESS-0xffffffffc01fd800>
ffffffffc0200cb4:	10000593          	li	a1,256
ffffffffc0200cb8:	9522                	add	a0,a0,s0
ffffffffc0200cba:	4aa000ef          	jal	ra,ffffffffc0201164 <free_pages>

    p0 = alloc_pages(8192);
ffffffffc0200cbe:	6509                	lui	a0,0x2
ffffffffc0200cc0:	460000ef          	jal	ra,ffffffffc0201120 <alloc_pages>
ffffffffc0200cc4:	8a2a                	mv	s4,a0
    assert(p0 == A);
ffffffffc0200cc6:	1aa41163          	bne	s0,a0,ffffffffc0200e68 <buddy_check+0x258>
    // free_pages(p0, 1024);
    //以下是根据链接中的样例测试编写的
    A = alloc_pages(128);
ffffffffc0200cca:	08000513          	li	a0,128
ffffffffc0200cce:	452000ef          	jal	ra,ffffffffc0201120 <alloc_pages>
ffffffffc0200cd2:	89aa                	mv	s3,a0
    B = alloc_pages(64);
    // 检查是否相邻
    assert(A + 128 == B);
ffffffffc0200cd4:	6405                	lui	s0,0x1
    B = alloc_pages(64);
ffffffffc0200cd6:	04000513          	li	a0,64
ffffffffc0200cda:	446000ef          	jal	ra,ffffffffc0201120 <alloc_pages>
    assert(A + 128 == B);
ffffffffc0200cde:	40040493          	addi	s1,s0,1024 # 1400 <BASE_ADDRESS-0xffffffffc01fec00>
ffffffffc0200ce2:	009987b3          	add	a5,s3,s1
    B = alloc_pages(64);
ffffffffc0200ce6:	892a                	mv	s2,a0
    assert(A + 128 == B);
ffffffffc0200ce8:	14f51063          	bne	a0,a5,ffffffffc0200e28 <buddy_check+0x218>
    C = alloc_pages(128);
ffffffffc0200cec:	08000513          	li	a0,128
ffffffffc0200cf0:	430000ef          	jal	ra,ffffffffc0201120 <alloc_pages>
    // 检查C有没有和A重叠
    assert(A + 256 == C);
ffffffffc0200cf4:	678d                	lui	a5,0x3
ffffffffc0200cf6:	80078793          	addi	a5,a5,-2048 # 2800 <BASE_ADDRESS-0xffffffffc01fd800>
ffffffffc0200cfa:	97ce                	add	a5,a5,s3
    C = alloc_pages(128);
ffffffffc0200cfc:	8aaa                	mv	s5,a0
    assert(A + 256 == C);
ffffffffc0200cfe:	18f51563          	bne	a0,a5,ffffffffc0200e88 <buddy_check+0x278>
    // 释放A
    free_pages(A, 128);
ffffffffc0200d02:	08000593          	li	a1,128
ffffffffc0200d06:	854e                	mv	a0,s3
ffffffffc0200d08:	45c000ef          	jal	ra,ffffffffc0201164 <free_pages>
    D = alloc_pages(64);
ffffffffc0200d0c:	04000513          	li	a0,64
ffffffffc0200d10:	410000ef          	jal	ra,ffffffffc0201120 <alloc_pages>
ffffffffc0200d14:	89aa                	mv	s3,a0
    cprintf("D %p\n", D);
ffffffffc0200d16:	85aa                	mv	a1,a0
    // 检查D是否能够使用A刚刚释放的内存
    assert(D + 128 == B);
ffffffffc0200d18:	94ce                	add	s1,s1,s3
    cprintf("D %p\n", D);
ffffffffc0200d1a:	00001517          	auipc	a0,0x1
ffffffffc0200d1e:	46650513          	addi	a0,a0,1126 # ffffffffc0202180 <commands+0x740>
ffffffffc0200d22:	b94ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert(D + 128 == B);
ffffffffc0200d26:	18991163          	bne	s2,s1,ffffffffc0200ea8 <buddy_check+0x298>
    free_pages(C, 128);
ffffffffc0200d2a:	08000593          	li	a1,128
ffffffffc0200d2e:	8556                	mv	a0,s5
ffffffffc0200d30:	434000ef          	jal	ra,ffffffffc0201164 <free_pages>
    C = alloc_pages(64);
ffffffffc0200d34:	04000513          	li	a0,64
ffffffffc0200d38:	3e8000ef          	jal	ra,ffffffffc0201120 <alloc_pages>
    // 检查C是否在B、D之间
    assert(C == D + 64 && C == B - 64);
ffffffffc0200d3c:	a0040413          	addi	s0,s0,-1536
ffffffffc0200d40:	008987b3          	add	a5,s3,s0
    C = alloc_pages(64);
ffffffffc0200d44:	84aa                	mv	s1,a0
    assert(C == D + 64 && C == B - 64);
ffffffffc0200d46:	08f51163          	bne	a0,a5,ffffffffc0200dc8 <buddy_check+0x1b8>
ffffffffc0200d4a:	40890433          	sub	s0,s2,s0
ffffffffc0200d4e:	06851d63          	bne	a0,s0,ffffffffc0200dc8 <buddy_check+0x1b8>
    free_pages(B, 64);
ffffffffc0200d52:	854a                	mv	a0,s2
ffffffffc0200d54:	04000593          	li	a1,64
ffffffffc0200d58:	40c000ef          	jal	ra,ffffffffc0201164 <free_pages>
    free_pages(D, 64);
ffffffffc0200d5c:	854e                	mv	a0,s3
ffffffffc0200d5e:	04000593          	li	a1,64
ffffffffc0200d62:	402000ef          	jal	ra,ffffffffc0201164 <free_pages>
    free_pages(C, 64);
ffffffffc0200d66:	8526                	mv	a0,s1
ffffffffc0200d68:	04000593          	li	a1,64
ffffffffc0200d6c:	3f8000ef          	jal	ra,ffffffffc0201164 <free_pages>
    // 全部释放
    free_pages(p0, 8192);
}
ffffffffc0200d70:	7442                	ld	s0,48(sp)
ffffffffc0200d72:	70e2                	ld	ra,56(sp)
ffffffffc0200d74:	74a2                	ld	s1,40(sp)
ffffffffc0200d76:	7902                	ld	s2,32(sp)
ffffffffc0200d78:	69e2                	ld	s3,24(sp)
ffffffffc0200d7a:	6aa2                	ld	s5,8(sp)
    free_pages(p0, 8192);
ffffffffc0200d7c:	8552                	mv	a0,s4
}
ffffffffc0200d7e:	6a42                	ld	s4,16(sp)
    free_pages(p0, 8192);
ffffffffc0200d80:	6589                	lui	a1,0x2
}
ffffffffc0200d82:	6121                	addi	sp,sp,64
    free_pages(p0, 8192);
ffffffffc0200d84:	3e00006f          	j	ffffffffc0201164 <free_pages>
    assert(p0 != A && p0 != B && A != B);
ffffffffc0200d88:	00001697          	auipc	a3,0x1
ffffffffc0200d8c:	37068693          	addi	a3,a3,880 # ffffffffc02020f8 <commands+0x6b8>
ffffffffc0200d90:	00001617          	auipc	a2,0x1
ffffffffc0200d94:	44860613          	addi	a2,a2,1096 # ffffffffc02021d8 <commands+0x798>
ffffffffc0200d98:	0e600593          	li	a1,230
ffffffffc0200d9c:	00001517          	auipc	a0,0x1
ffffffffc0200da0:	45450513          	addi	a0,a0,1108 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200da4:	e08ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
ffffffffc0200da8:	00001697          	auipc	a3,0x1
ffffffffc0200dac:	37068693          	addi	a3,a3,880 # ffffffffc0202118 <commands+0x6d8>
ffffffffc0200db0:	00001617          	auipc	a2,0x1
ffffffffc0200db4:	42860613          	addi	a2,a2,1064 # ffffffffc02021d8 <commands+0x798>
ffffffffc0200db8:	0e700593          	li	a1,231
ffffffffc0200dbc:	00001517          	auipc	a0,0x1
ffffffffc0200dc0:	43450513          	addi	a0,a0,1076 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200dc4:	de8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(C == D + 64 && C == B - 64);
ffffffffc0200dc8:	00001697          	auipc	a3,0x1
ffffffffc0200dcc:	3d068693          	addi	a3,a3,976 # ffffffffc0202198 <commands+0x758>
ffffffffc0200dd0:	00001617          	auipc	a2,0x1
ffffffffc0200dd4:	40860613          	addi	a2,a2,1032 # ffffffffc02021d8 <commands+0x798>
ffffffffc0200dd8:	10700593          	li	a1,263
ffffffffc0200ddc:	00001517          	auipc	a0,0x1
ffffffffc0200de0:	41450513          	addi	a0,a0,1044 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200de4:	dc8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200de8:	00001697          	auipc	a3,0x1
ffffffffc0200dec:	2b068693          	addi	a3,a3,688 # ffffffffc0202098 <commands+0x658>
ffffffffc0200df0:	00001617          	auipc	a2,0x1
ffffffffc0200df4:	3e860613          	addi	a2,a2,1000 # ffffffffc02021d8 <commands+0x798>
ffffffffc0200df8:	0e200593          	li	a1,226
ffffffffc0200dfc:	00001517          	auipc	a0,0x1
ffffffffc0200e00:	3f450513          	addi	a0,a0,1012 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200e04:	da8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((A = alloc_page()) != NULL);
ffffffffc0200e08:	00001697          	auipc	a3,0x1
ffffffffc0200e0c:	2b068693          	addi	a3,a3,688 # ffffffffc02020b8 <commands+0x678>
ffffffffc0200e10:	00001617          	auipc	a2,0x1
ffffffffc0200e14:	3c860613          	addi	a2,a2,968 # ffffffffc02021d8 <commands+0x798>
ffffffffc0200e18:	0e300593          	li	a1,227
ffffffffc0200e1c:	00001517          	auipc	a0,0x1
ffffffffc0200e20:	3d450513          	addi	a0,a0,980 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200e24:	d88ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(A + 128 == B);
ffffffffc0200e28:	00001697          	auipc	a3,0x1
ffffffffc0200e2c:	33868693          	addi	a3,a3,824 # ffffffffc0202160 <commands+0x720>
ffffffffc0200e30:	00001617          	auipc	a2,0x1
ffffffffc0200e34:	3a860613          	addi	a2,a2,936 # ffffffffc02021d8 <commands+0x798>
ffffffffc0200e38:	0fa00593          	li	a1,250
ffffffffc0200e3c:	00001517          	auipc	a0,0x1
ffffffffc0200e40:	3b450513          	addi	a0,a0,948 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200e44:	d68ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((B = alloc_page()) != NULL);
ffffffffc0200e48:	00001697          	auipc	a3,0x1
ffffffffc0200e4c:	29068693          	addi	a3,a3,656 # ffffffffc02020d8 <commands+0x698>
ffffffffc0200e50:	00001617          	auipc	a2,0x1
ffffffffc0200e54:	38860613          	addi	a2,a2,904 # ffffffffc02021d8 <commands+0x798>
ffffffffc0200e58:	0e400593          	li	a1,228
ffffffffc0200e5c:	00001517          	auipc	a0,0x1
ffffffffc0200e60:	39450513          	addi	a0,a0,916 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200e64:	d48ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 == A);
ffffffffc0200e68:	00001697          	auipc	a3,0x1
ffffffffc0200e6c:	2f068693          	addi	a3,a3,752 # ffffffffc0202158 <commands+0x718>
ffffffffc0200e70:	00001617          	auipc	a2,0x1
ffffffffc0200e74:	36860613          	addi	a2,a2,872 # ffffffffc02021d8 <commands+0x798>
ffffffffc0200e78:	0f400593          	li	a1,244
ffffffffc0200e7c:	00001517          	auipc	a0,0x1
ffffffffc0200e80:	37450513          	addi	a0,a0,884 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200e84:	d28ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(A + 256 == C);
ffffffffc0200e88:	00001697          	auipc	a3,0x1
ffffffffc0200e8c:	2e868693          	addi	a3,a3,744 # ffffffffc0202170 <commands+0x730>
ffffffffc0200e90:	00001617          	auipc	a2,0x1
ffffffffc0200e94:	34860613          	addi	a2,a2,840 # ffffffffc02021d8 <commands+0x798>
ffffffffc0200e98:	0fd00593          	li	a1,253
ffffffffc0200e9c:	00001517          	auipc	a0,0x1
ffffffffc0200ea0:	35450513          	addi	a0,a0,852 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200ea4:	d08ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(D + 128 == B);
ffffffffc0200ea8:	00001697          	auipc	a3,0x1
ffffffffc0200eac:	2e068693          	addi	a3,a3,736 # ffffffffc0202188 <commands+0x748>
ffffffffc0200eb0:	00001617          	auipc	a2,0x1
ffffffffc0200eb4:	32860613          	addi	a2,a2,808 # ffffffffc02021d8 <commands+0x798>
ffffffffc0200eb8:	10300593          	li	a1,259
ffffffffc0200ebc:	00001517          	auipc	a0,0x1
ffffffffc0200ec0:	33450513          	addi	a0,a0,820 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc0200ec4:	ce8ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ec8 <buddy_alloc>:
int buddy_alloc(int size){
ffffffffc0200ec8:	1101                	addi	sp,sp,-32
ffffffffc0200eca:	e04a                	sd	s2,0(sp)
    if(buddy_manager[index] < size)//如果根节点大小小于需要的快，无内存可用
ffffffffc0200ecc:	00005917          	auipc	s2,0x5
ffffffffc0200ed0:	56c90913          	addi	s2,s2,1388 # ffffffffc0206438 <buddy_manager>
ffffffffc0200ed4:	00093583          	ld	a1,0(s2)
int buddy_alloc(int size){
ffffffffc0200ed8:	ec06                	sd	ra,24(sp)
ffffffffc0200eda:	e822                	sd	s0,16(sp)
    if(buddy_manager[index] < size)//如果根节点大小小于需要的快，无内存可用
ffffffffc0200edc:	41dc                	lw	a5,4(a1)
int buddy_alloc(int size){
ffffffffc0200ede:	e426                	sd	s1,8(sp)
    if(buddy_manager[index] < size)//如果根节点大小小于需要的快，无内存可用
ffffffffc0200ee0:	0005061b          	sext.w	a2,a0
ffffffffc0200ee4:	12c7ed63          	bltu	a5,a2,ffffffffc020101e <buddy_alloc+0x156>
    if(size <= 0)
ffffffffc0200ee8:	0ea05e63          	blez	a0,ffffffffc0200fe4 <buddy_alloc+0x11c>
    else if(!IS_POWER_OF_2(size))
ffffffffc0200eec:	fff5079b          	addiw	a5,a0,-1
ffffffffc0200ef0:	8fe9                	and	a5,a5,a0
ffffffffc0200ef2:	2781                	sext.w	a5,a5
ffffffffc0200ef4:	c795                	beqz	a5,ffffffffc0200f20 <buddy_alloc+0x58>
    while(temp>>=1)
ffffffffc0200ef6:	40155793          	srai	a5,a0,0x1
ffffffffc0200efa:	c7ed                	beqz	a5,ffffffffc0200fe4 <buddy_alloc+0x11c>
    int n=0;//幂次
ffffffffc0200efc:	4601                	li	a2,0
ffffffffc0200efe:	a011                	j	ffffffffc0200f02 <buddy_alloc+0x3a>
        n++;
ffffffffc0200f00:	863a                	mv	a2,a4
    while(temp>>=1)
ffffffffc0200f02:	8785                	srai	a5,a5,0x1
        n++;
ffffffffc0200f04:	0016071b          	addiw	a4,a2,1
    while(temp>>=1)
ffffffffc0200f08:	ffe5                	bnez	a5,ffffffffc0200f00 <buddy_alloc+0x38>
    temp= (size>>n)<<n;
ffffffffc0200f0a:	40e557bb          	sraw	a5,a0,a4
    if(size-temp!=0)//如果不为0说明size的二进制表示中还有1的位
ffffffffc0200f0e:	00e797bb          	sllw	a5,a5,a4
ffffffffc0200f12:	10a78263          	beq	a5,a0,ffffffffc0201016 <buddy_alloc+0x14e>
        n++;//向上取
ffffffffc0200f16:	0026079b          	addiw	a5,a2,2
ffffffffc0200f1a:	4605                	li	a2,1
ffffffffc0200f1c:	00f6163b          	sllw	a2,a2,a5
    for(node_size = manager_size / 2; node_size != size; node_size /= 2){
ffffffffc0200f20:	00005517          	auipc	a0,0x5
ffffffffc0200f24:	52450513          	addi	a0,a0,1316 # ffffffffc0206444 <manager_size>
ffffffffc0200f28:	411c                	lw	a5,0(a0)
ffffffffc0200f2a:	01f7d71b          	srliw	a4,a5,0x1f
ffffffffc0200f2e:	9f3d                	addw	a4,a4,a5
ffffffffc0200f30:	4017571b          	sraiw	a4,a4,0x1
ffffffffc0200f34:	0cc70563          	beq	a4,a2,ffffffffc0200ffe <buddy_alloc+0x136>
    unsigned index = 1;//根节点开始遍历
ffffffffc0200f38:	4405                	li	s0,1
        if(buddy_manager[LEFT_LEAF(index)] >= size)// 如果左子节点的大小大于等于需要的块大小，则向左子节点移动
ffffffffc0200f3a:	0014169b          	slliw	a3,s0,0x1
ffffffffc0200f3e:	02069793          	slli	a5,a3,0x20
ffffffffc0200f42:	83f9                	srli	a5,a5,0x1e
ffffffffc0200f44:	97ae                	add	a5,a5,a1
ffffffffc0200f46:	439c                	lw	a5,0(a5)
    for(node_size = manager_size / 2; node_size != size; node_size /= 2){
ffffffffc0200f48:	0017571b          	srliw	a4,a4,0x1
        if(buddy_manager[LEFT_LEAF(index)] >= size)// 如果左子节点的大小大于等于需要的块大小，则向左子节点移动
ffffffffc0200f4c:	0006841b          	sext.w	s0,a3
ffffffffc0200f50:	00c7f463          	bleu	a2,a5,ffffffffc0200f58 <buddy_alloc+0x90>
            index = RIGHT_LEAF(index);
ffffffffc0200f54:	0016841b          	addiw	s0,a3,1
    for(node_size = manager_size / 2; node_size != size; node_size /= 2){
ffffffffc0200f58:	fec711e3          	bne	a4,a2,ffffffffc0200f3a <buddy_alloc+0x72>
    offset = (index) * node_size - manager_size / 2;
ffffffffc0200f5c:	02e4073b          	mulw	a4,s0,a4
    buddy_manager[index] = 0;
ffffffffc0200f60:	02041793          	slli	a5,s0,0x20
ffffffffc0200f64:	83f9                	srli	a5,a5,0x1e
ffffffffc0200f66:	95be                	add	a1,a1,a5
ffffffffc0200f68:	0005a023          	sw	zero,0(a1) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    offset = (index) * node_size - manager_size / 2;
ffffffffc0200f6c:	411c                	lw	a5,0(a0)
    cprintf(" index:%u offset:%u ", index, offset);
ffffffffc0200f6e:	85a2                	mv	a1,s0
ffffffffc0200f70:	00001517          	auipc	a0,0x1
ffffffffc0200f74:	2e050513          	addi	a0,a0,736 # ffffffffc0202250 <commands+0x810>
    offset = (index) * node_size - manager_size / 2;
ffffffffc0200f78:	01f7d49b          	srliw	s1,a5,0x1f
ffffffffc0200f7c:	9cbd                	addw	s1,s1,a5
ffffffffc0200f7e:	4014d49b          	sraiw	s1,s1,0x1
ffffffffc0200f82:	409704bb          	subw	s1,a4,s1
    cprintf(" index:%u offset:%u ", index, offset);
ffffffffc0200f86:	8626                	mv	a2,s1
ffffffffc0200f88:	92eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    while(index > 1){
ffffffffc0200f8c:	4785                	li	a5,1
ffffffffc0200f8e:	0487f363          	bleu	s0,a5,ffffffffc0200fd4 <buddy_alloc+0x10c>
        buddy_manager[index] = MAX(buddy_manager[LEFT_LEAF(index)],buddy_manager[RIGHT_LEAF(index)]);
ffffffffc0200f92:	00093683          	ld	a3,0(s2)
    while(index > 1){
ffffffffc0200f96:	4805                	li	a6,1
        buddy_manager[index] = MAX(buddy_manager[LEFT_LEAF(index)],buddy_manager[RIGHT_LEAF(index)]);
ffffffffc0200f98:	ffe47793          	andi	a5,s0,-2
ffffffffc0200f9c:	0017871b          	addiw	a4,a5,1
ffffffffc0200fa0:	1702                	slli	a4,a4,0x20
ffffffffc0200fa2:	1782                	slli	a5,a5,0x20
ffffffffc0200fa4:	9301                	srli	a4,a4,0x20
ffffffffc0200fa6:	9381                	srli	a5,a5,0x20
ffffffffc0200fa8:	070a                	slli	a4,a4,0x2
ffffffffc0200faa:	078a                	slli	a5,a5,0x2
ffffffffc0200fac:	97b6                	add	a5,a5,a3
ffffffffc0200fae:	9736                	add	a4,a4,a3
ffffffffc0200fb0:	4390                	lw	a2,0(a5)
ffffffffc0200fb2:	4318                	lw	a4,0(a4)
        index = PARENT(index);
ffffffffc0200fb4:	0014541b          	srliw	s0,s0,0x1
        buddy_manager[index] = MAX(buddy_manager[LEFT_LEAF(index)],buddy_manager[RIGHT_LEAF(index)]);
ffffffffc0200fb8:	02041793          	slli	a5,s0,0x20
ffffffffc0200fbc:	83f9                	srli	a5,a5,0x1e
ffffffffc0200fbe:	0007051b          	sext.w	a0,a4
ffffffffc0200fc2:	0006059b          	sext.w	a1,a2
ffffffffc0200fc6:	97b6                	add	a5,a5,a3
ffffffffc0200fc8:	00b57363          	bleu	a1,a0,ffffffffc0200fce <buddy_alloc+0x106>
ffffffffc0200fcc:	8732                	mv	a4,a2
ffffffffc0200fce:	c398                	sw	a4,0(a5)
    while(index > 1){
ffffffffc0200fd0:	fd0414e3          	bne	s0,a6,ffffffffc0200f98 <buddy_alloc+0xd0>
    return offset;//返回分配块的偏移量即索引
ffffffffc0200fd4:	0004851b          	sext.w	a0,s1
}
ffffffffc0200fd8:	60e2                	ld	ra,24(sp)
ffffffffc0200fda:	6442                	ld	s0,16(sp)
ffffffffc0200fdc:	64a2                	ld	s1,8(sp)
ffffffffc0200fde:	6902                	ld	s2,0(sp)
ffffffffc0200fe0:	6105                	addi	sp,sp,32
ffffffffc0200fe2:	8082                	ret
    for(node_size = manager_size / 2; node_size != size; node_size /= 2){
ffffffffc0200fe4:	00005517          	auipc	a0,0x5
ffffffffc0200fe8:	46050513          	addi	a0,a0,1120 # ffffffffc0206444 <manager_size>
ffffffffc0200fec:	411c                	lw	a5,0(a0)
ffffffffc0200fee:	4605                	li	a2,1
ffffffffc0200ff0:	01f7d71b          	srliw	a4,a5,0x1f
ffffffffc0200ff4:	9f3d                	addw	a4,a4,a5
ffffffffc0200ff6:	4017571b          	sraiw	a4,a4,0x1
ffffffffc0200ffa:	f2c71fe3          	bne	a4,a2,ffffffffc0200f38 <buddy_alloc+0x70>
    buddy_manager[index] = 0;
ffffffffc0200ffe:	0005a223          	sw	zero,4(a1)
    cprintf(" index:%u offset:%u ", index, offset);
ffffffffc0201002:	4601                	li	a2,0
ffffffffc0201004:	4585                	li	a1,1
ffffffffc0201006:	00001517          	auipc	a0,0x1
ffffffffc020100a:	24a50513          	addi	a0,a0,586 # ffffffffc0202250 <commands+0x810>
ffffffffc020100e:	8a8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    offset = (index) * node_size - manager_size / 2;
ffffffffc0201012:	4481                	li	s1,0
ffffffffc0201014:	b7c1                	j	ffffffffc0200fd4 <buddy_alloc+0x10c>
ffffffffc0201016:	4605                	li	a2,1
ffffffffc0201018:	00e6163b          	sllw	a2,a2,a4
ffffffffc020101c:	b711                	j	ffffffffc0200f20 <buddy_alloc+0x58>
        return -1;
ffffffffc020101e:	557d                	li	a0,-1
ffffffffc0201020:	bf65                	j	ffffffffc0200fd8 <buddy_alloc+0x110>

ffffffffc0201022 <buddy_alloc_pages>:
static struct Page* buddy_alloc_pages(size_t n) {
ffffffffc0201022:	7179                	addi	sp,sp,-48
ffffffffc0201024:	ec26                	sd	s1,24(sp)
    cprintf("alloc %u pages", n);
ffffffffc0201026:	85aa                	mv	a1,a0
static struct Page* buddy_alloc_pages(size_t n) {
ffffffffc0201028:	84aa                	mv	s1,a0
    cprintf("alloc %u pages", n);
ffffffffc020102a:	00001517          	auipc	a0,0x1
ffffffffc020102e:	04650513          	addi	a0,a0,70 # ffffffffc0202070 <commands+0x630>
static struct Page* buddy_alloc_pages(size_t n) {
ffffffffc0201032:	f406                	sd	ra,40(sp)
ffffffffc0201034:	f022                	sd	s0,32(sp)
ffffffffc0201036:	e84a                	sd	s2,16(sp)
ffffffffc0201038:	e44e                	sd	s3,8(sp)
    cprintf("alloc %u pages", n);
ffffffffc020103a:	87cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert(n>0);
ffffffffc020103e:	c0e9                	beqz	s1,ffffffffc0201100 <buddy_alloc_pages+0xde>
    if(n > free_page_num)
ffffffffc0201040:	00005997          	auipc	s3,0x5
ffffffffc0201044:	40098993          	addi	s3,s3,1024 # ffffffffc0206440 <free_page_num>
ffffffffc0201048:	0009a783          	lw	a5,0(s3)
        return NULL;
ffffffffc020104c:	4401                	li	s0,0
    if(n > free_page_num)
ffffffffc020104e:	0897e563          	bltu	a5,s1,ffffffffc02010d8 <buddy_alloc_pages+0xb6>
    int offset = buddy_alloc(n);
ffffffffc0201052:	0004891b          	sext.w	s2,s1
ffffffffc0201056:	854a                	mv	a0,s2
ffffffffc0201058:	e71ff0ef          	jal	ra,ffffffffc0200ec8 <buddy_alloc>
    struct Page *base = page_base + offset;
ffffffffc020105c:	00005717          	auipc	a4,0x5
ffffffffc0201060:	3ec70713          	addi	a4,a4,1004 # ffffffffc0206448 <page_base>
ffffffffc0201064:	00251793          	slli	a5,a0,0x2
ffffffffc0201068:	6300                	ld	s0,0(a4)
ffffffffc020106a:	953e                	add	a0,a0,a5
ffffffffc020106c:	050e                	slli	a0,a0,0x3
    while(temp>>=1)
ffffffffc020106e:	40195793          	srai	a5,s2,0x1
    struct Page *base = page_base + offset;
ffffffffc0201072:	942a                	add	s0,s0,a0
    while(temp>>=1)
ffffffffc0201074:	c3d1                	beqz	a5,ffffffffc02010f8 <buddy_alloc_pages+0xd6>
    int n=0;//幂次
ffffffffc0201076:	4701                	li	a4,0
ffffffffc0201078:	a011                	j	ffffffffc020107c <buddy_alloc_pages+0x5a>
        n++;
ffffffffc020107a:	8736                	mv	a4,a3
    while(temp>>=1)
ffffffffc020107c:	8785                	srai	a5,a5,0x1
        n++;
ffffffffc020107e:	0017069b          	addiw	a3,a4,1
    while(temp>>=1)
ffffffffc0201082:	ffe5                	bnez	a5,ffffffffc020107a <buddy_alloc_pages+0x58>
    temp= (size>>n)<<n;
ffffffffc0201084:	40d957bb          	sraw	a5,s2,a3
    if(size-temp!=0)//如果不为0说明size的二进制表示中还有1的位
ffffffffc0201088:	00d797bb          	sllw	a5,a5,a3
ffffffffc020108c:	05278e63          	beq	a5,s2,ffffffffc02010e8 <buddy_alloc_pages+0xc6>
        n++;//向上取
ffffffffc0201090:	2709                	addiw	a4,a4,2
ffffffffc0201092:	4685                	li	a3,1
ffffffffc0201094:	00e6973b          	sllw	a4,a3,a4
ffffffffc0201098:	00271613          	slli	a2,a4,0x2
ffffffffc020109c:	963a                	add	a2,a2,a4
ffffffffc020109e:	060e                	slli	a2,a2,0x3
    for(page = base; page != base + round_n; page++){
ffffffffc02010a0:	9622                	add	a2,a2,s0
ffffffffc02010a2:	00c40c63          	beq	s0,a2,ffffffffc02010ba <buddy_alloc_pages+0x98>
ffffffffc02010a6:	87a2                	mv	a5,s0
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010a8:	55f5                	li	a1,-3
ffffffffc02010aa:	00878693          	addi	a3,a5,8
ffffffffc02010ae:	60b6b02f          	amoand.d	zero,a1,(a3)
ffffffffc02010b2:	02878793          	addi	a5,a5,40
ffffffffc02010b6:	fec79ae3          	bne	a5,a2,ffffffffc02010aa <buddy_alloc_pages+0x88>
    free_page_num -= round_n;//更新空闲页数不
ffffffffc02010ba:	0009a683          	lw	a3,0(s3)
    base->property = n;//
ffffffffc02010be:	c804                	sw	s1,16(s0)
    cprintf("finish!\n");
ffffffffc02010c0:	00001517          	auipc	a0,0x1
ffffffffc02010c4:	1a850513          	addi	a0,a0,424 # ffffffffc0202268 <commands+0x828>
    free_page_num -= round_n;//更新空闲页数不
ffffffffc02010c8:	40e6873b          	subw	a4,a3,a4
ffffffffc02010cc:	00005797          	auipc	a5,0x5
ffffffffc02010d0:	36e7aa23          	sw	a4,884(a5) # ffffffffc0206440 <free_page_num>
    cprintf("finish!\n");
ffffffffc02010d4:	fe3fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
}
ffffffffc02010d8:	8522                	mv	a0,s0
ffffffffc02010da:	70a2                	ld	ra,40(sp)
ffffffffc02010dc:	7402                	ld	s0,32(sp)
ffffffffc02010de:	64e2                	ld	s1,24(sp)
ffffffffc02010e0:	6942                	ld	s2,16(sp)
ffffffffc02010e2:	69a2                	ld	s3,8(sp)
ffffffffc02010e4:	6145                	addi	sp,sp,48
ffffffffc02010e6:	8082                	ret
ffffffffc02010e8:	4705                	li	a4,1
ffffffffc02010ea:	00d7173b          	sllw	a4,a4,a3
ffffffffc02010ee:	00271613          	slli	a2,a4,0x2
ffffffffc02010f2:	963a                	add	a2,a2,a4
ffffffffc02010f4:	060e                	slli	a2,a2,0x3
ffffffffc02010f6:	b76d                	j	ffffffffc02010a0 <buddy_alloc_pages+0x7e>
    while(temp>>=1)
ffffffffc02010f8:	4705                	li	a4,1
ffffffffc02010fa:	02840613          	addi	a2,s0,40
ffffffffc02010fe:	b765                	j	ffffffffc02010a6 <buddy_alloc_pages+0x84>
    assert(n>0);
ffffffffc0201100:	00001697          	auipc	a3,0x1
ffffffffc0201104:	f8068693          	addi	a3,a3,-128 # ffffffffc0202080 <commands+0x640>
ffffffffc0201108:	00001617          	auipc	a2,0x1
ffffffffc020110c:	0d060613          	addi	a2,a2,208 # ffffffffc02021d8 <commands+0x798>
ffffffffc0201110:	08400593          	li	a1,132
ffffffffc0201114:	00001517          	auipc	a0,0x1
ffffffffc0201118:	0dc50513          	addi	a0,a0,220 # ffffffffc02021f0 <commands+0x7b0>
ffffffffc020111c:	a90ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201120 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201120:	100027f3          	csrr	a5,sstatus
ffffffffc0201124:	8b89                	andi	a5,a5,2
ffffffffc0201126:	eb89                	bnez	a5,ffffffffc0201138 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201128:	00005797          	auipc	a5,0x5
ffffffffc020112c:	33878793          	addi	a5,a5,824 # ffffffffc0206460 <pmm_manager>
ffffffffc0201130:	639c                	ld	a5,0(a5)
ffffffffc0201132:	0187b303          	ld	t1,24(a5)
ffffffffc0201136:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0201138:	1141                	addi	sp,sp,-16
ffffffffc020113a:	e406                	sd	ra,8(sp)
ffffffffc020113c:	e022                	sd	s0,0(sp)
ffffffffc020113e:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201140:	b24ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201144:	00005797          	auipc	a5,0x5
ffffffffc0201148:	31c78793          	addi	a5,a5,796 # ffffffffc0206460 <pmm_manager>
ffffffffc020114c:	639c                	ld	a5,0(a5)
ffffffffc020114e:	8522                	mv	a0,s0
ffffffffc0201150:	6f9c                	ld	a5,24(a5)
ffffffffc0201152:	9782                	jalr	a5
ffffffffc0201154:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201156:	b08ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020115a:	8522                	mv	a0,s0
ffffffffc020115c:	60a2                	ld	ra,8(sp)
ffffffffc020115e:	6402                	ld	s0,0(sp)
ffffffffc0201160:	0141                	addi	sp,sp,16
ffffffffc0201162:	8082                	ret

ffffffffc0201164 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201164:	100027f3          	csrr	a5,sstatus
ffffffffc0201168:	8b89                	andi	a5,a5,2
ffffffffc020116a:	eb89                	bnez	a5,ffffffffc020117c <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020116c:	00005797          	auipc	a5,0x5
ffffffffc0201170:	2f478793          	addi	a5,a5,756 # ffffffffc0206460 <pmm_manager>
ffffffffc0201174:	639c                	ld	a5,0(a5)
ffffffffc0201176:	0207b303          	ld	t1,32(a5)
ffffffffc020117a:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020117c:	1101                	addi	sp,sp,-32
ffffffffc020117e:	ec06                	sd	ra,24(sp)
ffffffffc0201180:	e822                	sd	s0,16(sp)
ffffffffc0201182:	e426                	sd	s1,8(sp)
ffffffffc0201184:	842a                	mv	s0,a0
ffffffffc0201186:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201188:	adcff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020118c:	00005797          	auipc	a5,0x5
ffffffffc0201190:	2d478793          	addi	a5,a5,724 # ffffffffc0206460 <pmm_manager>
ffffffffc0201194:	639c                	ld	a5,0(a5)
ffffffffc0201196:	85a6                	mv	a1,s1
ffffffffc0201198:	8522                	mv	a0,s0
ffffffffc020119a:	739c                	ld	a5,32(a5)
ffffffffc020119c:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020119e:	6442                	ld	s0,16(sp)
ffffffffc02011a0:	60e2                	ld	ra,24(sp)
ffffffffc02011a2:	64a2                	ld	s1,8(sp)
ffffffffc02011a4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02011a6:	ab8ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc02011aa <pmm_init>:
    pmm_manager=&buddy_pmm_manager;
ffffffffc02011aa:	00001797          	auipc	a5,0x1
ffffffffc02011ae:	1ae78793          	addi	a5,a5,430 # ffffffffc0202358 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02011b2:	638c                	ld	a1,0(a5)
        fppn=pa2page(mem_begin)-pages+nbase;
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02011b4:	7179                	addi	sp,sp,-48
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02011b6:	00001517          	auipc	a0,0x1
ffffffffc02011ba:	1f250513          	addi	a0,a0,498 # ffffffffc02023a8 <buddy_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc02011be:	f406                	sd	ra,40(sp)
    pmm_manager=&buddy_pmm_manager;
ffffffffc02011c0:	00005717          	auipc	a4,0x5
ffffffffc02011c4:	2af73023          	sd	a5,672(a4) # ffffffffc0206460 <pmm_manager>
void pmm_init(void) {
ffffffffc02011c8:	f022                	sd	s0,32(sp)
ffffffffc02011ca:	ec26                	sd	s1,24(sp)
ffffffffc02011cc:	e84a                	sd	s2,16(sp)
ffffffffc02011ce:	e44e                	sd	s3,8(sp)
ffffffffc02011d0:	e052                	sd	s4,0(sp)
    pmm_manager=&buddy_pmm_manager;
ffffffffc02011d2:	00005497          	auipc	s1,0x5
ffffffffc02011d6:	28e48493          	addi	s1,s1,654 # ffffffffc0206460 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02011da:	eddfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02011de:	609c                	ld	a5,0(s1)
ffffffffc02011e0:	00005917          	auipc	s2,0x5
ffffffffc02011e4:	23890913          	addi	s2,s2,568 # ffffffffc0206418 <npage>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011e8:	fff80437          	lui	s0,0xfff80
    pmm_manager->init();
ffffffffc02011ec:	679c                	ld	a5,8(a5)
ffffffffc02011ee:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02011f0:	57f5                	li	a5,-3
ffffffffc02011f2:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02011f4:	00001517          	auipc	a0,0x1
ffffffffc02011f8:	1cc50513          	addi	a0,a0,460 # ffffffffc02023c0 <buddy_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02011fc:	00005717          	auipc	a4,0x5
ffffffffc0201200:	26f73623          	sd	a5,620(a4) # ffffffffc0206468 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201204:	eb3fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201208:	46c5                	li	a3,17
ffffffffc020120a:	06ee                	slli	a3,a3,0x1b
ffffffffc020120c:	40100613          	li	a2,1025
ffffffffc0201210:	16fd                	addi	a3,a3,-1
ffffffffc0201212:	0656                	slli	a2,a2,0x15
ffffffffc0201214:	07e005b7          	lui	a1,0x7e00
ffffffffc0201218:	00001517          	auipc	a0,0x1
ffffffffc020121c:	1c050513          	addi	a0,a0,448 # ffffffffc02023d8 <buddy_pmm_manager+0x80>
ffffffffc0201220:	e97fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201224:	777d                	lui	a4,0xfffff
ffffffffc0201226:	00006797          	auipc	a5,0x6
ffffffffc020122a:	25178793          	addi	a5,a5,593 # ffffffffc0207477 <end+0xfff>
ffffffffc020122e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201230:	00088737          	lui	a4,0x88
ffffffffc0201234:	00005697          	auipc	a3,0x5
ffffffffc0201238:	1ee6b223          	sd	a4,484(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020123c:	4601                	li	a2,0
ffffffffc020123e:	00005717          	auipc	a4,0x5
ffffffffc0201242:	22f73923          	sd	a5,562(a4) # ffffffffc0206470 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201246:	4681                	li	a3,0
ffffffffc0201248:	00005597          	auipc	a1,0x5
ffffffffc020124c:	22858593          	addi	a1,a1,552 # ffffffffc0206470 <pages>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201250:	4505                	li	a0,1
ffffffffc0201252:	a011                	j	ffffffffc0201256 <pmm_init+0xac>
ffffffffc0201254:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0201256:	97b2                	add	a5,a5,a2
ffffffffc0201258:	07a1                	addi	a5,a5,8
ffffffffc020125a:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020125e:	00093703          	ld	a4,0(s2)
ffffffffc0201262:	0685                	addi	a3,a3,1
ffffffffc0201264:	02860613          	addi	a2,a2,40
ffffffffc0201268:	008707b3          	add	a5,a4,s0
ffffffffc020126c:	fef6e4e3          	bltu	a3,a5,ffffffffc0201254 <pmm_init+0xaa>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201270:	6188                	ld	a0,0(a1)
ffffffffc0201272:	00271793          	slli	a5,a4,0x2
ffffffffc0201276:	97ba                	add	a5,a5,a4
ffffffffc0201278:	fec006b7          	lui	a3,0xfec00
ffffffffc020127c:	078e                	slli	a5,a5,0x3
ffffffffc020127e:	96aa                	add	a3,a3,a0
ffffffffc0201280:	96be                	add	a3,a3,a5
ffffffffc0201282:	c02007b7          	lui	a5,0xc0200
ffffffffc0201286:	0cf6ec63          	bltu	a3,a5,ffffffffc020135e <pmm_init+0x1b4>
ffffffffc020128a:	00005997          	auipc	s3,0x5
ffffffffc020128e:	1de98993          	addi	s3,s3,478 # ffffffffc0206468 <va_pa_offset>
ffffffffc0201292:	0009b783          	ld	a5,0(s3)
    if (freemem < mem_end) {
ffffffffc0201296:	45c5                	li	a1,17
ffffffffc0201298:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020129a:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc020129c:	04b6fa63          	bleu	a1,a3,ffffffffc02012f0 <pmm_init+0x146>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02012a0:	6785                	lui	a5,0x1
ffffffffc02012a2:	17fd                	addi	a5,a5,-1
ffffffffc02012a4:	96be                	add	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02012a6:	00c6da13          	srli	s4,a3,0xc
ffffffffc02012aa:	08ea7e63          	bleu	a4,s4,ffffffffc0201346 <pmm_init+0x19c>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02012ae:	008a07b3          	add	a5,s4,s0
    pmm_manager->init_memmap(base, n);
ffffffffc02012b2:	6098                	ld	a4,0(s1)
ffffffffc02012b4:	00279413          	slli	s0,a5,0x2
ffffffffc02012b8:	943e                	add	s0,s0,a5
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02012ba:	77fd                	lui	a5,0xfffff
ffffffffc02012bc:	8efd                	and	a3,a3,a5
    pmm_manager->init_memmap(base, n);
ffffffffc02012be:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02012c0:	8d95                	sub	a1,a1,a3
ffffffffc02012c2:	040e                	slli	s0,s0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02012c4:	81b1                	srli	a1,a1,0xc
ffffffffc02012c6:	9522                	add	a0,a0,s0
ffffffffc02012c8:	9782                	jalr	a5
    if (PPN(pa) >= npage) {
ffffffffc02012ca:	00093783          	ld	a5,0(s2)
ffffffffc02012ce:	06fa7c63          	bleu	a5,s4,ffffffffc0201346 <pmm_init+0x19c>
        fppn=pa2page(mem_begin)-pages+nbase;
ffffffffc02012d2:	00001797          	auipc	a5,0x1
ffffffffc02012d6:	ee678793          	addi	a5,a5,-282 # ffffffffc02021b8 <commands+0x778>
ffffffffc02012da:	639c                	ld	a5,0(a5)
ffffffffc02012dc:	840d                	srai	s0,s0,0x3
ffffffffc02012de:	02f40433          	mul	s0,s0,a5
ffffffffc02012e2:	000807b7          	lui	a5,0x80
ffffffffc02012e6:	943e                	add	s0,s0,a5
ffffffffc02012e8:	00005797          	auipc	a5,0x5
ffffffffc02012ec:	1687b823          	sd	s0,368(a5) # ffffffffc0206458 <fppn>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02012f0:	609c                	ld	a5,0(s1)
ffffffffc02012f2:	7b9c                	ld	a5,48(a5)
ffffffffc02012f4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02012f6:	00001517          	auipc	a0,0x1
ffffffffc02012fa:	17a50513          	addi	a0,a0,378 # ffffffffc0202470 <buddy_pmm_manager+0x118>
ffffffffc02012fe:	db9fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201302:	00004697          	auipc	a3,0x4
ffffffffc0201306:	cfe68693          	addi	a3,a3,-770 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020130a:	00005797          	auipc	a5,0x5
ffffffffc020130e:	10d7bb23          	sd	a3,278(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201312:	c02007b7          	lui	a5,0xc0200
ffffffffc0201316:	06f6e063          	bltu	a3,a5,ffffffffc0201376 <pmm_init+0x1cc>
ffffffffc020131a:	0009b783          	ld	a5,0(s3)
}
ffffffffc020131e:	7402                	ld	s0,32(sp)
ffffffffc0201320:	70a2                	ld	ra,40(sp)
ffffffffc0201322:	64e2                	ld	s1,24(sp)
ffffffffc0201324:	6942                	ld	s2,16(sp)
ffffffffc0201326:	69a2                	ld	s3,8(sp)
ffffffffc0201328:	6a02                	ld	s4,0(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020132a:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc020132c:	8e9d                	sub	a3,a3,a5
ffffffffc020132e:	00005797          	auipc	a5,0x5
ffffffffc0201332:	12d7b123          	sd	a3,290(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201336:	00001517          	auipc	a0,0x1
ffffffffc020133a:	15a50513          	addi	a0,a0,346 # ffffffffc0202490 <buddy_pmm_manager+0x138>
ffffffffc020133e:	8636                	mv	a2,a3
}
ffffffffc0201340:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201342:	d75fe06f          	j	ffffffffc02000b6 <cprintf>
        panic("pa2page called with invalid pa");
ffffffffc0201346:	00001617          	auipc	a2,0x1
ffffffffc020134a:	0fa60613          	addi	a2,a2,250 # ffffffffc0202440 <buddy_pmm_manager+0xe8>
ffffffffc020134e:	06b00593          	li	a1,107
ffffffffc0201352:	00001517          	auipc	a0,0x1
ffffffffc0201356:	10e50513          	addi	a0,a0,270 # ffffffffc0202460 <buddy_pmm_manager+0x108>
ffffffffc020135a:	852ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020135e:	00001617          	auipc	a2,0x1
ffffffffc0201362:	0aa60613          	addi	a2,a2,170 # ffffffffc0202408 <buddy_pmm_manager+0xb0>
ffffffffc0201366:	07500593          	li	a1,117
ffffffffc020136a:	00001517          	auipc	a0,0x1
ffffffffc020136e:	0c650513          	addi	a0,a0,198 # ffffffffc0202430 <buddy_pmm_manager+0xd8>
ffffffffc0201372:	83aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201376:	00001617          	auipc	a2,0x1
ffffffffc020137a:	09260613          	addi	a2,a2,146 # ffffffffc0202408 <buddy_pmm_manager+0xb0>
ffffffffc020137e:	09100593          	li	a1,145
ffffffffc0201382:	00001517          	auipc	a0,0x1
ffffffffc0201386:	0ae50513          	addi	a0,a0,174 # ffffffffc0202430 <buddy_pmm_manager+0xd8>
ffffffffc020138a:	822ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020138e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020138e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201392:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201394:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201398:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020139a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020139e:	f022                	sd	s0,32(sp)
ffffffffc02013a0:	ec26                	sd	s1,24(sp)
ffffffffc02013a2:	e84a                	sd	s2,16(sp)
ffffffffc02013a4:	f406                	sd	ra,40(sp)
ffffffffc02013a6:	e44e                	sd	s3,8(sp)
ffffffffc02013a8:	84aa                	mv	s1,a0
ffffffffc02013aa:	892e                	mv	s2,a1
ffffffffc02013ac:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02013b0:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02013b2:	03067e63          	bleu	a6,a2,ffffffffc02013ee <printnum+0x60>
ffffffffc02013b6:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02013b8:	00805763          	blez	s0,ffffffffc02013c6 <printnum+0x38>
ffffffffc02013bc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02013be:	85ca                	mv	a1,s2
ffffffffc02013c0:	854e                	mv	a0,s3
ffffffffc02013c2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02013c4:	fc65                	bnez	s0,ffffffffc02013bc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013c6:	1a02                	slli	s4,s4,0x20
ffffffffc02013c8:	020a5a13          	srli	s4,s4,0x20
ffffffffc02013cc:	00001797          	auipc	a5,0x1
ffffffffc02013d0:	29478793          	addi	a5,a5,660 # ffffffffc0202660 <error_string+0x38>
ffffffffc02013d4:	9a3e                	add	s4,s4,a5
}
ffffffffc02013d6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013d8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02013dc:	70a2                	ld	ra,40(sp)
ffffffffc02013de:	69a2                	ld	s3,8(sp)
ffffffffc02013e0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013e2:	85ca                	mv	a1,s2
ffffffffc02013e4:	8326                	mv	t1,s1
}
ffffffffc02013e6:	6942                	ld	s2,16(sp)
ffffffffc02013e8:	64e2                	ld	s1,24(sp)
ffffffffc02013ea:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013ec:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02013ee:	03065633          	divu	a2,a2,a6
ffffffffc02013f2:	8722                	mv	a4,s0
ffffffffc02013f4:	f9bff0ef          	jal	ra,ffffffffc020138e <printnum>
ffffffffc02013f8:	b7f9                	j	ffffffffc02013c6 <printnum+0x38>

ffffffffc02013fa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02013fa:	7119                	addi	sp,sp,-128
ffffffffc02013fc:	f4a6                	sd	s1,104(sp)
ffffffffc02013fe:	f0ca                	sd	s2,96(sp)
ffffffffc0201400:	e8d2                	sd	s4,80(sp)
ffffffffc0201402:	e4d6                	sd	s5,72(sp)
ffffffffc0201404:	e0da                	sd	s6,64(sp)
ffffffffc0201406:	fc5e                	sd	s7,56(sp)
ffffffffc0201408:	f862                	sd	s8,48(sp)
ffffffffc020140a:	f06a                	sd	s10,32(sp)
ffffffffc020140c:	fc86                	sd	ra,120(sp)
ffffffffc020140e:	f8a2                	sd	s0,112(sp)
ffffffffc0201410:	ecce                	sd	s3,88(sp)
ffffffffc0201412:	f466                	sd	s9,40(sp)
ffffffffc0201414:	ec6e                	sd	s11,24(sp)
ffffffffc0201416:	892a                	mv	s2,a0
ffffffffc0201418:	84ae                	mv	s1,a1
ffffffffc020141a:	8d32                	mv	s10,a2
ffffffffc020141c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020141e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201420:	00001a17          	auipc	s4,0x1
ffffffffc0201424:	0b0a0a13          	addi	s4,s4,176 # ffffffffc02024d0 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201428:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020142c:	00001c17          	auipc	s8,0x1
ffffffffc0201430:	1fcc0c13          	addi	s8,s8,508 # ffffffffc0202628 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201434:	000d4503          	lbu	a0,0(s10)
ffffffffc0201438:	02500793          	li	a5,37
ffffffffc020143c:	001d0413          	addi	s0,s10,1
ffffffffc0201440:	00f50e63          	beq	a0,a5,ffffffffc020145c <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201444:	c521                	beqz	a0,ffffffffc020148c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201446:	02500993          	li	s3,37
ffffffffc020144a:	a011                	j	ffffffffc020144e <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020144c:	c121                	beqz	a0,ffffffffc020148c <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020144e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201450:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201452:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201454:	fff44503          	lbu	a0,-1(s0) # fffffffffff7ffff <end+0x3fd79b87>
ffffffffc0201458:	ff351ae3          	bne	a0,s3,ffffffffc020144c <vprintfmt+0x52>
ffffffffc020145c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201460:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201464:	4981                	li	s3,0
ffffffffc0201466:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201468:	5cfd                	li	s9,-1
ffffffffc020146a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020146c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201470:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201472:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201476:	0ff6f693          	andi	a3,a3,255
ffffffffc020147a:	00140d13          	addi	s10,s0,1
ffffffffc020147e:	20d5e563          	bltu	a1,a3,ffffffffc0201688 <vprintfmt+0x28e>
ffffffffc0201482:	068a                	slli	a3,a3,0x2
ffffffffc0201484:	96d2                	add	a3,a3,s4
ffffffffc0201486:	4294                	lw	a3,0(a3)
ffffffffc0201488:	96d2                	add	a3,a3,s4
ffffffffc020148a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020148c:	70e6                	ld	ra,120(sp)
ffffffffc020148e:	7446                	ld	s0,112(sp)
ffffffffc0201490:	74a6                	ld	s1,104(sp)
ffffffffc0201492:	7906                	ld	s2,96(sp)
ffffffffc0201494:	69e6                	ld	s3,88(sp)
ffffffffc0201496:	6a46                	ld	s4,80(sp)
ffffffffc0201498:	6aa6                	ld	s5,72(sp)
ffffffffc020149a:	6b06                	ld	s6,64(sp)
ffffffffc020149c:	7be2                	ld	s7,56(sp)
ffffffffc020149e:	7c42                	ld	s8,48(sp)
ffffffffc02014a0:	7ca2                	ld	s9,40(sp)
ffffffffc02014a2:	7d02                	ld	s10,32(sp)
ffffffffc02014a4:	6de2                	ld	s11,24(sp)
ffffffffc02014a6:	6109                	addi	sp,sp,128
ffffffffc02014a8:	8082                	ret
    if (lflag >= 2) {
ffffffffc02014aa:	4705                	li	a4,1
ffffffffc02014ac:	008a8593          	addi	a1,s5,8
ffffffffc02014b0:	01074463          	blt	a4,a6,ffffffffc02014b8 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02014b4:	26080363          	beqz	a6,ffffffffc020171a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02014b8:	000ab603          	ld	a2,0(s5)
ffffffffc02014bc:	46c1                	li	a3,16
ffffffffc02014be:	8aae                	mv	s5,a1
ffffffffc02014c0:	a06d                	j	ffffffffc020156a <vprintfmt+0x170>
            goto reswitch;
ffffffffc02014c2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02014c6:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014c8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014ca:	b765                	j	ffffffffc0201472 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02014cc:	000aa503          	lw	a0,0(s5)
ffffffffc02014d0:	85a6                	mv	a1,s1
ffffffffc02014d2:	0aa1                	addi	s5,s5,8
ffffffffc02014d4:	9902                	jalr	s2
            break;
ffffffffc02014d6:	bfb9                	j	ffffffffc0201434 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02014d8:	4705                	li	a4,1
ffffffffc02014da:	008a8993          	addi	s3,s5,8
ffffffffc02014de:	01074463          	blt	a4,a6,ffffffffc02014e6 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02014e2:	22080463          	beqz	a6,ffffffffc020170a <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02014e6:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02014ea:	24044463          	bltz	s0,ffffffffc0201732 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02014ee:	8622                	mv	a2,s0
ffffffffc02014f0:	8ace                	mv	s5,s3
ffffffffc02014f2:	46a9                	li	a3,10
ffffffffc02014f4:	a89d                	j	ffffffffc020156a <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02014f6:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014fa:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02014fc:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02014fe:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201502:	8fb5                	xor	a5,a5,a3
ffffffffc0201504:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201508:	1ad74363          	blt	a4,a3,ffffffffc02016ae <vprintfmt+0x2b4>
ffffffffc020150c:	00369793          	slli	a5,a3,0x3
ffffffffc0201510:	97e2                	add	a5,a5,s8
ffffffffc0201512:	639c                	ld	a5,0(a5)
ffffffffc0201514:	18078d63          	beqz	a5,ffffffffc02016ae <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201518:	86be                	mv	a3,a5
ffffffffc020151a:	00001617          	auipc	a2,0x1
ffffffffc020151e:	1f660613          	addi	a2,a2,502 # ffffffffc0202710 <error_string+0xe8>
ffffffffc0201522:	85a6                	mv	a1,s1
ffffffffc0201524:	854a                	mv	a0,s2
ffffffffc0201526:	240000ef          	jal	ra,ffffffffc0201766 <printfmt>
ffffffffc020152a:	b729                	j	ffffffffc0201434 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020152c:	00144603          	lbu	a2,1(s0)
ffffffffc0201530:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201532:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201534:	bf3d                	j	ffffffffc0201472 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201536:	4705                	li	a4,1
ffffffffc0201538:	008a8593          	addi	a1,s5,8
ffffffffc020153c:	01074463          	blt	a4,a6,ffffffffc0201544 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201540:	1e080263          	beqz	a6,ffffffffc0201724 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201544:	000ab603          	ld	a2,0(s5)
ffffffffc0201548:	46a1                	li	a3,8
ffffffffc020154a:	8aae                	mv	s5,a1
ffffffffc020154c:	a839                	j	ffffffffc020156a <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020154e:	03000513          	li	a0,48
ffffffffc0201552:	85a6                	mv	a1,s1
ffffffffc0201554:	e03e                	sd	a5,0(sp)
ffffffffc0201556:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201558:	85a6                	mv	a1,s1
ffffffffc020155a:	07800513          	li	a0,120
ffffffffc020155e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201560:	0aa1                	addi	s5,s5,8
ffffffffc0201562:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201566:	6782                	ld	a5,0(sp)
ffffffffc0201568:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020156a:	876e                	mv	a4,s11
ffffffffc020156c:	85a6                	mv	a1,s1
ffffffffc020156e:	854a                	mv	a0,s2
ffffffffc0201570:	e1fff0ef          	jal	ra,ffffffffc020138e <printnum>
            break;
ffffffffc0201574:	b5c1                	j	ffffffffc0201434 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201576:	000ab603          	ld	a2,0(s5)
ffffffffc020157a:	0aa1                	addi	s5,s5,8
ffffffffc020157c:	1c060663          	beqz	a2,ffffffffc0201748 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201580:	00160413          	addi	s0,a2,1
ffffffffc0201584:	17b05c63          	blez	s11,ffffffffc02016fc <vprintfmt+0x302>
ffffffffc0201588:	02d00593          	li	a1,45
ffffffffc020158c:	14b79263          	bne	a5,a1,ffffffffc02016d0 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201590:	00064783          	lbu	a5,0(a2)
ffffffffc0201594:	0007851b          	sext.w	a0,a5
ffffffffc0201598:	c905                	beqz	a0,ffffffffc02015c8 <vprintfmt+0x1ce>
ffffffffc020159a:	000cc563          	bltz	s9,ffffffffc02015a4 <vprintfmt+0x1aa>
ffffffffc020159e:	3cfd                	addiw	s9,s9,-1
ffffffffc02015a0:	036c8263          	beq	s9,s6,ffffffffc02015c4 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02015a4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015a6:	18098463          	beqz	s3,ffffffffc020172e <vprintfmt+0x334>
ffffffffc02015aa:	3781                	addiw	a5,a5,-32
ffffffffc02015ac:	18fbf163          	bleu	a5,s7,ffffffffc020172e <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02015b0:	03f00513          	li	a0,63
ffffffffc02015b4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015b6:	0405                	addi	s0,s0,1
ffffffffc02015b8:	fff44783          	lbu	a5,-1(s0)
ffffffffc02015bc:	3dfd                	addiw	s11,s11,-1
ffffffffc02015be:	0007851b          	sext.w	a0,a5
ffffffffc02015c2:	fd61                	bnez	a0,ffffffffc020159a <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02015c4:	e7b058e3          	blez	s11,ffffffffc0201434 <vprintfmt+0x3a>
ffffffffc02015c8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02015ca:	85a6                	mv	a1,s1
ffffffffc02015cc:	02000513          	li	a0,32
ffffffffc02015d0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02015d2:	e60d81e3          	beqz	s11,ffffffffc0201434 <vprintfmt+0x3a>
ffffffffc02015d6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02015d8:	85a6                	mv	a1,s1
ffffffffc02015da:	02000513          	li	a0,32
ffffffffc02015de:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02015e0:	fe0d94e3          	bnez	s11,ffffffffc02015c8 <vprintfmt+0x1ce>
ffffffffc02015e4:	bd81                	j	ffffffffc0201434 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02015e6:	4705                	li	a4,1
ffffffffc02015e8:	008a8593          	addi	a1,s5,8
ffffffffc02015ec:	01074463          	blt	a4,a6,ffffffffc02015f4 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02015f0:	12080063          	beqz	a6,ffffffffc0201710 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02015f4:	000ab603          	ld	a2,0(s5)
ffffffffc02015f8:	46a9                	li	a3,10
ffffffffc02015fa:	8aae                	mv	s5,a1
ffffffffc02015fc:	b7bd                	j	ffffffffc020156a <vprintfmt+0x170>
ffffffffc02015fe:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201602:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201606:	846a                	mv	s0,s10
ffffffffc0201608:	b5ad                	j	ffffffffc0201472 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020160a:	85a6                	mv	a1,s1
ffffffffc020160c:	02500513          	li	a0,37
ffffffffc0201610:	9902                	jalr	s2
            break;
ffffffffc0201612:	b50d                	j	ffffffffc0201434 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201614:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201618:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020161c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020161e:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201620:	e40dd9e3          	bgez	s11,ffffffffc0201472 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201624:	8de6                	mv	s11,s9
ffffffffc0201626:	5cfd                	li	s9,-1
ffffffffc0201628:	b5a9                	j	ffffffffc0201472 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020162a:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020162e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201632:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201634:	bd3d                	j	ffffffffc0201472 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201636:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020163a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020163e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201640:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201644:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201648:	fcd56ce3          	bltu	a0,a3,ffffffffc0201620 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020164c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020164e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201652:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201656:	0196873b          	addw	a4,a3,s9
ffffffffc020165a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020165e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201662:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201666:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020166a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020166e:	fcd57fe3          	bleu	a3,a0,ffffffffc020164c <vprintfmt+0x252>
ffffffffc0201672:	b77d                	j	ffffffffc0201620 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201674:	fffdc693          	not	a3,s11
ffffffffc0201678:	96fd                	srai	a3,a3,0x3f
ffffffffc020167a:	00ddfdb3          	and	s11,s11,a3
ffffffffc020167e:	00144603          	lbu	a2,1(s0)
ffffffffc0201682:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201684:	846a                	mv	s0,s10
ffffffffc0201686:	b3f5                	j	ffffffffc0201472 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201688:	85a6                	mv	a1,s1
ffffffffc020168a:	02500513          	li	a0,37
ffffffffc020168e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201690:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201694:	02500793          	li	a5,37
ffffffffc0201698:	8d22                	mv	s10,s0
ffffffffc020169a:	d8f70de3          	beq	a4,a5,ffffffffc0201434 <vprintfmt+0x3a>
ffffffffc020169e:	02500713          	li	a4,37
ffffffffc02016a2:	1d7d                	addi	s10,s10,-1
ffffffffc02016a4:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02016a8:	fee79de3          	bne	a5,a4,ffffffffc02016a2 <vprintfmt+0x2a8>
ffffffffc02016ac:	b361                	j	ffffffffc0201434 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02016ae:	00001617          	auipc	a2,0x1
ffffffffc02016b2:	05260613          	addi	a2,a2,82 # ffffffffc0202700 <error_string+0xd8>
ffffffffc02016b6:	85a6                	mv	a1,s1
ffffffffc02016b8:	854a                	mv	a0,s2
ffffffffc02016ba:	0ac000ef          	jal	ra,ffffffffc0201766 <printfmt>
ffffffffc02016be:	bb9d                	j	ffffffffc0201434 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02016c0:	00001617          	auipc	a2,0x1
ffffffffc02016c4:	03860613          	addi	a2,a2,56 # ffffffffc02026f8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02016c8:	00001417          	auipc	s0,0x1
ffffffffc02016cc:	03140413          	addi	s0,s0,49 # ffffffffc02026f9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016d0:	8532                	mv	a0,a2
ffffffffc02016d2:	85e6                	mv	a1,s9
ffffffffc02016d4:	e032                	sd	a2,0(sp)
ffffffffc02016d6:	e43e                	sd	a5,8(sp)
ffffffffc02016d8:	1c2000ef          	jal	ra,ffffffffc020189a <strnlen>
ffffffffc02016dc:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02016e0:	6602                	ld	a2,0(sp)
ffffffffc02016e2:	01b05d63          	blez	s11,ffffffffc02016fc <vprintfmt+0x302>
ffffffffc02016e6:	67a2                	ld	a5,8(sp)
ffffffffc02016e8:	2781                	sext.w	a5,a5
ffffffffc02016ea:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02016ec:	6522                	ld	a0,8(sp)
ffffffffc02016ee:	85a6                	mv	a1,s1
ffffffffc02016f0:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016f2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02016f4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016f6:	6602                	ld	a2,0(sp)
ffffffffc02016f8:	fe0d9ae3          	bnez	s11,ffffffffc02016ec <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016fc:	00064783          	lbu	a5,0(a2)
ffffffffc0201700:	0007851b          	sext.w	a0,a5
ffffffffc0201704:	e8051be3          	bnez	a0,ffffffffc020159a <vprintfmt+0x1a0>
ffffffffc0201708:	b335                	j	ffffffffc0201434 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020170a:	000aa403          	lw	s0,0(s5)
ffffffffc020170e:	bbf1                	j	ffffffffc02014ea <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0201710:	000ae603          	lwu	a2,0(s5)
ffffffffc0201714:	46a9                	li	a3,10
ffffffffc0201716:	8aae                	mv	s5,a1
ffffffffc0201718:	bd89                	j	ffffffffc020156a <vprintfmt+0x170>
ffffffffc020171a:	000ae603          	lwu	a2,0(s5)
ffffffffc020171e:	46c1                	li	a3,16
ffffffffc0201720:	8aae                	mv	s5,a1
ffffffffc0201722:	b5a1                	j	ffffffffc020156a <vprintfmt+0x170>
ffffffffc0201724:	000ae603          	lwu	a2,0(s5)
ffffffffc0201728:	46a1                	li	a3,8
ffffffffc020172a:	8aae                	mv	s5,a1
ffffffffc020172c:	bd3d                	j	ffffffffc020156a <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020172e:	9902                	jalr	s2
ffffffffc0201730:	b559                	j	ffffffffc02015b6 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201732:	85a6                	mv	a1,s1
ffffffffc0201734:	02d00513          	li	a0,45
ffffffffc0201738:	e03e                	sd	a5,0(sp)
ffffffffc020173a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020173c:	8ace                	mv	s5,s3
ffffffffc020173e:	40800633          	neg	a2,s0
ffffffffc0201742:	46a9                	li	a3,10
ffffffffc0201744:	6782                	ld	a5,0(sp)
ffffffffc0201746:	b515                	j	ffffffffc020156a <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201748:	01b05663          	blez	s11,ffffffffc0201754 <vprintfmt+0x35a>
ffffffffc020174c:	02d00693          	li	a3,45
ffffffffc0201750:	f6d798e3          	bne	a5,a3,ffffffffc02016c0 <vprintfmt+0x2c6>
ffffffffc0201754:	00001417          	auipc	s0,0x1
ffffffffc0201758:	fa540413          	addi	s0,s0,-91 # ffffffffc02026f9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020175c:	02800513          	li	a0,40
ffffffffc0201760:	02800793          	li	a5,40
ffffffffc0201764:	bd1d                	j	ffffffffc020159a <vprintfmt+0x1a0>

ffffffffc0201766 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201766:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201768:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020176c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020176e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201770:	ec06                	sd	ra,24(sp)
ffffffffc0201772:	f83a                	sd	a4,48(sp)
ffffffffc0201774:	fc3e                	sd	a5,56(sp)
ffffffffc0201776:	e0c2                	sd	a6,64(sp)
ffffffffc0201778:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020177a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020177c:	c7fff0ef          	jal	ra,ffffffffc02013fa <vprintfmt>
}
ffffffffc0201780:	60e2                	ld	ra,24(sp)
ffffffffc0201782:	6161                	addi	sp,sp,80
ffffffffc0201784:	8082                	ret

ffffffffc0201786 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201786:	715d                	addi	sp,sp,-80
ffffffffc0201788:	e486                	sd	ra,72(sp)
ffffffffc020178a:	e0a2                	sd	s0,64(sp)
ffffffffc020178c:	fc26                	sd	s1,56(sp)
ffffffffc020178e:	f84a                	sd	s2,48(sp)
ffffffffc0201790:	f44e                	sd	s3,40(sp)
ffffffffc0201792:	f052                	sd	s4,32(sp)
ffffffffc0201794:	ec56                	sd	s5,24(sp)
ffffffffc0201796:	e85a                	sd	s6,16(sp)
ffffffffc0201798:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020179a:	c901                	beqz	a0,ffffffffc02017aa <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020179c:	85aa                	mv	a1,a0
ffffffffc020179e:	00001517          	auipc	a0,0x1
ffffffffc02017a2:	f7250513          	addi	a0,a0,-142 # ffffffffc0202710 <error_string+0xe8>
ffffffffc02017a6:	911fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02017aa:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02017ac:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02017ae:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02017b0:	4aa9                	li	s5,10
ffffffffc02017b2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02017b4:	00005b97          	auipc	s7,0x5
ffffffffc02017b8:	85cb8b93          	addi	s7,s7,-1956 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02017bc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02017c0:	96ffe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02017c4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02017c6:	00054b63          	bltz	a0,ffffffffc02017dc <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02017ca:	00a95b63          	ble	a0,s2,ffffffffc02017e0 <readline+0x5a>
ffffffffc02017ce:	029a5463          	ble	s1,s4,ffffffffc02017f6 <readline+0x70>
        c = getchar();
ffffffffc02017d2:	95dfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02017d6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02017d8:	fe0559e3          	bgez	a0,ffffffffc02017ca <readline+0x44>
            return NULL;
ffffffffc02017dc:	4501                	li	a0,0
ffffffffc02017de:	a099                	j	ffffffffc0201824 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02017e0:	03341463          	bne	s0,s3,ffffffffc0201808 <readline+0x82>
ffffffffc02017e4:	e8b9                	bnez	s1,ffffffffc020183a <readline+0xb4>
        c = getchar();
ffffffffc02017e6:	949fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02017ea:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02017ec:	fe0548e3          	bltz	a0,ffffffffc02017dc <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02017f0:	fea958e3          	ble	a0,s2,ffffffffc02017e0 <readline+0x5a>
ffffffffc02017f4:	4481                	li	s1,0
            cputchar(c);
ffffffffc02017f6:	8522                	mv	a0,s0
ffffffffc02017f8:	8f3fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02017fc:	009b87b3          	add	a5,s7,s1
ffffffffc0201800:	00878023          	sb	s0,0(a5)
ffffffffc0201804:	2485                	addiw	s1,s1,1
ffffffffc0201806:	bf6d                	j	ffffffffc02017c0 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201808:	01540463          	beq	s0,s5,ffffffffc0201810 <readline+0x8a>
ffffffffc020180c:	fb641ae3          	bne	s0,s6,ffffffffc02017c0 <readline+0x3a>
            cputchar(c);
ffffffffc0201810:	8522                	mv	a0,s0
ffffffffc0201812:	8d9fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201816:	00004517          	auipc	a0,0x4
ffffffffc020181a:	7fa50513          	addi	a0,a0,2042 # ffffffffc0206010 <edata>
ffffffffc020181e:	94aa                	add	s1,s1,a0
ffffffffc0201820:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201824:	60a6                	ld	ra,72(sp)
ffffffffc0201826:	6406                	ld	s0,64(sp)
ffffffffc0201828:	74e2                	ld	s1,56(sp)
ffffffffc020182a:	7942                	ld	s2,48(sp)
ffffffffc020182c:	79a2                	ld	s3,40(sp)
ffffffffc020182e:	7a02                	ld	s4,32(sp)
ffffffffc0201830:	6ae2                	ld	s5,24(sp)
ffffffffc0201832:	6b42                	ld	s6,16(sp)
ffffffffc0201834:	6ba2                	ld	s7,8(sp)
ffffffffc0201836:	6161                	addi	sp,sp,80
ffffffffc0201838:	8082                	ret
            cputchar(c);
ffffffffc020183a:	4521                	li	a0,8
ffffffffc020183c:	8affe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201840:	34fd                	addiw	s1,s1,-1
ffffffffc0201842:	bfbd                	j	ffffffffc02017c0 <readline+0x3a>

ffffffffc0201844 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201844:	00004797          	auipc	a5,0x4
ffffffffc0201848:	7c478793          	addi	a5,a5,1988 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc020184c:	6398                	ld	a4,0(a5)
ffffffffc020184e:	4781                	li	a5,0
ffffffffc0201850:	88ba                	mv	a7,a4
ffffffffc0201852:	852a                	mv	a0,a0
ffffffffc0201854:	85be                	mv	a1,a5
ffffffffc0201856:	863e                	mv	a2,a5
ffffffffc0201858:	00000073          	ecall
ffffffffc020185c:	87aa                	mv	a5,a0
}
ffffffffc020185e:	8082                	ret

ffffffffc0201860 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201860:	00005797          	auipc	a5,0x5
ffffffffc0201864:	bc878793          	addi	a5,a5,-1080 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201868:	6398                	ld	a4,0(a5)
ffffffffc020186a:	4781                	li	a5,0
ffffffffc020186c:	88ba                	mv	a7,a4
ffffffffc020186e:	852a                	mv	a0,a0
ffffffffc0201870:	85be                	mv	a1,a5
ffffffffc0201872:	863e                	mv	a2,a5
ffffffffc0201874:	00000073          	ecall
ffffffffc0201878:	87aa                	mv	a5,a0
}
ffffffffc020187a:	8082                	ret

ffffffffc020187c <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc020187c:	00004797          	auipc	a5,0x4
ffffffffc0201880:	78478793          	addi	a5,a5,1924 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201884:	639c                	ld	a5,0(a5)
ffffffffc0201886:	4501                	li	a0,0
ffffffffc0201888:	88be                	mv	a7,a5
ffffffffc020188a:	852a                	mv	a0,a0
ffffffffc020188c:	85aa                	mv	a1,a0
ffffffffc020188e:	862a                	mv	a2,a0
ffffffffc0201890:	00000073          	ecall
ffffffffc0201894:	852a                	mv	a0,a0
ffffffffc0201896:	2501                	sext.w	a0,a0
ffffffffc0201898:	8082                	ret

ffffffffc020189a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020189a:	c185                	beqz	a1,ffffffffc02018ba <strnlen+0x20>
ffffffffc020189c:	00054783          	lbu	a5,0(a0)
ffffffffc02018a0:	cf89                	beqz	a5,ffffffffc02018ba <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02018a2:	4781                	li	a5,0
ffffffffc02018a4:	a021                	j	ffffffffc02018ac <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02018a6:	00074703          	lbu	a4,0(a4)
ffffffffc02018aa:	c711                	beqz	a4,ffffffffc02018b6 <strnlen+0x1c>
        cnt ++;
ffffffffc02018ac:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02018ae:	00f50733          	add	a4,a0,a5
ffffffffc02018b2:	fef59ae3          	bne	a1,a5,ffffffffc02018a6 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02018b6:	853e                	mv	a0,a5
ffffffffc02018b8:	8082                	ret
    size_t cnt = 0;
ffffffffc02018ba:	4781                	li	a5,0
}
ffffffffc02018bc:	853e                	mv	a0,a5
ffffffffc02018be:	8082                	ret

ffffffffc02018c0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02018c0:	00054783          	lbu	a5,0(a0)
ffffffffc02018c4:	0005c703          	lbu	a4,0(a1)
ffffffffc02018c8:	cb91                	beqz	a5,ffffffffc02018dc <strcmp+0x1c>
ffffffffc02018ca:	00e79c63          	bne	a5,a4,ffffffffc02018e2 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02018ce:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02018d0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02018d4:	0585                	addi	a1,a1,1
ffffffffc02018d6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02018da:	fbe5                	bnez	a5,ffffffffc02018ca <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02018dc:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02018de:	9d19                	subw	a0,a0,a4
ffffffffc02018e0:	8082                	ret
ffffffffc02018e2:	0007851b          	sext.w	a0,a5
ffffffffc02018e6:	9d19                	subw	a0,a0,a4
ffffffffc02018e8:	8082                	ret

ffffffffc02018ea <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02018ea:	00054783          	lbu	a5,0(a0)
ffffffffc02018ee:	cb91                	beqz	a5,ffffffffc0201902 <strchr+0x18>
        if (*s == c) {
ffffffffc02018f0:	00b79563          	bne	a5,a1,ffffffffc02018fa <strchr+0x10>
ffffffffc02018f4:	a809                	j	ffffffffc0201906 <strchr+0x1c>
ffffffffc02018f6:	00b78763          	beq	a5,a1,ffffffffc0201904 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02018fa:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02018fc:	00054783          	lbu	a5,0(a0)
ffffffffc0201900:	fbfd                	bnez	a5,ffffffffc02018f6 <strchr+0xc>
    }
    return NULL;
ffffffffc0201902:	4501                	li	a0,0
}
ffffffffc0201904:	8082                	ret
ffffffffc0201906:	8082                	ret

ffffffffc0201908 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201908:	ca01                	beqz	a2,ffffffffc0201918 <memset+0x10>
ffffffffc020190a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020190c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020190e:	0785                	addi	a5,a5,1
ffffffffc0201910:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201914:	fec79de3          	bne	a5,a2,ffffffffc020190e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201918:	8082                	ret
