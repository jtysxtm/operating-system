
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
ffffffffc0200042:	57260613          	addi	a2,a2,1394 # ffffffffc02065b0 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	728010ef          	jal	ra,ffffffffc0201776 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	73250513          	addi	a0,a0,1842 # ffffffffc0201788 <etext>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	799000ef          	jal	ra,ffffffffc0201002 <pmm_init>

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
ffffffffc02000aa:	1be010ef          	jal	ra,ffffffffc0201268 <vprintfmt>
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
ffffffffc02000de:	18a010ef          	jal	ra,ffffffffc0201268 <vprintfmt>
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
ffffffffc0200144:	69850513          	addi	a0,a0,1688 # ffffffffc02017d8 <etext+0x50>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	6a250513          	addi	a0,a0,1698 # ffffffffc02017f8 <etext+0x70>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	62658593          	addi	a1,a1,1574 # ffffffffc0201788 <etext>
ffffffffc020016a:	00001517          	auipc	a0,0x1
ffffffffc020016e:	6ae50513          	addi	a0,a0,1710 # ffffffffc0201818 <etext+0x90>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	6ba50513          	addi	a0,a0,1722 # ffffffffc0201838 <etext+0xb0>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	42658593          	addi	a1,a1,1062 # ffffffffc02065b0 <end>
ffffffffc0200192:	00001517          	auipc	a0,0x1
ffffffffc0200196:	6c650513          	addi	a0,a0,1734 # ffffffffc0201858 <etext+0xd0>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00007597          	auipc	a1,0x7
ffffffffc02001a2:	81158593          	addi	a1,a1,-2031 # ffffffffc02069af <end+0x3ff>
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
ffffffffc02001c0:	00001517          	auipc	a0,0x1
ffffffffc02001c4:	6b850513          	addi	a0,a0,1720 # ffffffffc0201878 <etext+0xf0>
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
ffffffffc02001d4:	5d860613          	addi	a2,a2,1496 # ffffffffc02017a8 <etext+0x20>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	5e450513          	addi	a0,a0,1508 # ffffffffc02017c0 <etext+0x38>
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
ffffffffc02001ec:	00001617          	auipc	a2,0x1
ffffffffc02001f0:	79c60613          	addi	a2,a2,1948 # ffffffffc0201988 <commands+0xe0>
ffffffffc02001f4:	00001597          	auipc	a1,0x1
ffffffffc02001f8:	7b458593          	addi	a1,a1,1972 # ffffffffc02019a8 <commands+0x100>
ffffffffc02001fc:	00001517          	auipc	a0,0x1
ffffffffc0200200:	7b450513          	addi	a0,a0,1972 # ffffffffc02019b0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00001617          	auipc	a2,0x1
ffffffffc020020e:	7b660613          	addi	a2,a2,1974 # ffffffffc02019c0 <commands+0x118>
ffffffffc0200212:	00001597          	auipc	a1,0x1
ffffffffc0200216:	7d658593          	addi	a1,a1,2006 # ffffffffc02019e8 <commands+0x140>
ffffffffc020021a:	00001517          	auipc	a0,0x1
ffffffffc020021e:	79650513          	addi	a0,a0,1942 # ffffffffc02019b0 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	7d260613          	addi	a2,a2,2002 # ffffffffc02019f8 <commands+0x150>
ffffffffc020022e:	00001597          	auipc	a1,0x1
ffffffffc0200232:	7ea58593          	addi	a1,a1,2026 # ffffffffc0201a18 <commands+0x170>
ffffffffc0200236:	00001517          	auipc	a0,0x1
ffffffffc020023a:	77a50513          	addi	a0,a0,1914 # ffffffffc02019b0 <commands+0x108>
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
ffffffffc0200274:	68050513          	addi	a0,a0,1664 # ffffffffc02018f0 <commands+0x48>
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
ffffffffc0200296:	68650513          	addi	a0,a0,1670 # ffffffffc0201918 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	600c8c93          	addi	s9,s9,1536 # ffffffffc02018a8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	69098993          	addi	s3,s3,1680 # ffffffffc0201940 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	69090913          	addi	s2,s2,1680 # ffffffffc0201948 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	68eb0b13          	addi	s6,s6,1678 # ffffffffc0201950 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00001a97          	auipc	s5,0x1
ffffffffc02002ce:	6dea8a93          	addi	s5,s5,1758 # ffffffffc02019a8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	31e010ef          	jal	ra,ffffffffc02015f4 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	470010ef          	jal	ra,ffffffffc0201758 <strchr>
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
ffffffffc0200302:	5aad0d13          	addi	s10,s10,1450 # ffffffffc02018a8 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	422010ef          	jal	ra,ffffffffc020172e <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	40e010ef          	jal	ra,ffffffffc020172e <strcmp>
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
ffffffffc0200386:	3d2010ef          	jal	ra,ffffffffc0201758 <strchr>
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
ffffffffc02003a2:	5d250513          	addi	a0,a0,1490 # ffffffffc0201970 <commands+0xc8>
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
ffffffffc02003e2:	64a50513          	addi	a0,a0,1610 # ffffffffc0201a28 <commands+0x180>
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
ffffffffc02003f8:	4ac50513          	addi	a0,a0,1196 # ffffffffc02018a0 <etext+0x118>
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
ffffffffc0200424:	2aa010ef          	jal	ra,ffffffffc02016ce <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	61650513          	addi	a0,a0,1558 # ffffffffc0201a48 <commands+0x1a0>
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
ffffffffc020044c:	2820106f          	j	ffffffffc02016ce <sbi_set_timer>

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
ffffffffc0200456:	25c0106f          	j	ffffffffc02016b2 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	2900106f          	j	ffffffffc02016ea <sbi_console_getchar>

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
ffffffffc0200484:	00001517          	auipc	a0,0x1
ffffffffc0200488:	6dc50513          	addi	a0,a0,1756 # ffffffffc0201b60 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	6e450513          	addi	a0,a0,1764 # ffffffffc0201b78 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	6ee50513          	addi	a0,a0,1774 # ffffffffc0201b90 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	6f850513          	addi	a0,a0,1784 # ffffffffc0201ba8 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	70250513          	addi	a0,a0,1794 # ffffffffc0201bc0 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	70c50513          	addi	a0,a0,1804 # ffffffffc0201bd8 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	71650513          	addi	a0,a0,1814 # ffffffffc0201bf0 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00001517          	auipc	a0,0x1
ffffffffc02004ec:	72050513          	addi	a0,a0,1824 # ffffffffc0201c08 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00001517          	auipc	a0,0x1
ffffffffc02004fa:	72a50513          	addi	a0,a0,1834 # ffffffffc0201c20 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00001517          	auipc	a0,0x1
ffffffffc0200508:	73450513          	addi	a0,a0,1844 # ffffffffc0201c38 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00001517          	auipc	a0,0x1
ffffffffc0200516:	73e50513          	addi	a0,a0,1854 # ffffffffc0201c50 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00001517          	auipc	a0,0x1
ffffffffc0200524:	74850513          	addi	a0,a0,1864 # ffffffffc0201c68 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00001517          	auipc	a0,0x1
ffffffffc0200532:	75250513          	addi	a0,a0,1874 # ffffffffc0201c80 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00001517          	auipc	a0,0x1
ffffffffc0200540:	75c50513          	addi	a0,a0,1884 # ffffffffc0201c98 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00001517          	auipc	a0,0x1
ffffffffc020054e:	76650513          	addi	a0,a0,1894 # ffffffffc0201cb0 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00001517          	auipc	a0,0x1
ffffffffc020055c:	77050513          	addi	a0,a0,1904 # ffffffffc0201cc8 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00001517          	auipc	a0,0x1
ffffffffc020056a:	77a50513          	addi	a0,a0,1914 # ffffffffc0201ce0 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00001517          	auipc	a0,0x1
ffffffffc0200578:	78450513          	addi	a0,a0,1924 # ffffffffc0201cf8 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00001517          	auipc	a0,0x1
ffffffffc0200586:	78e50513          	addi	a0,a0,1934 # ffffffffc0201d10 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00001517          	auipc	a0,0x1
ffffffffc0200594:	79850513          	addi	a0,a0,1944 # ffffffffc0201d28 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00001517          	auipc	a0,0x1
ffffffffc02005a2:	7a250513          	addi	a0,a0,1954 # ffffffffc0201d40 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00001517          	auipc	a0,0x1
ffffffffc02005b0:	7ac50513          	addi	a0,a0,1964 # ffffffffc0201d58 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00001517          	auipc	a0,0x1
ffffffffc02005be:	7b650513          	addi	a0,a0,1974 # ffffffffc0201d70 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00001517          	auipc	a0,0x1
ffffffffc02005cc:	7c050513          	addi	a0,a0,1984 # ffffffffc0201d88 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00001517          	auipc	a0,0x1
ffffffffc02005da:	7ca50513          	addi	a0,a0,1994 # ffffffffc0201da0 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00001517          	auipc	a0,0x1
ffffffffc02005e8:	7d450513          	addi	a0,a0,2004 # ffffffffc0201db8 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00001517          	auipc	a0,0x1
ffffffffc02005f6:	7de50513          	addi	a0,a0,2014 # ffffffffc0201dd0 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00001517          	auipc	a0,0x1
ffffffffc0200604:	7e850513          	addi	a0,a0,2024 # ffffffffc0201de8 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00001517          	auipc	a0,0x1
ffffffffc0200612:	7f250513          	addi	a0,a0,2034 # ffffffffc0201e00 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00001517          	auipc	a0,0x1
ffffffffc0200620:	7fc50513          	addi	a0,a0,2044 # ffffffffc0201e18 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	80650513          	addi	a0,a0,-2042 # ffffffffc0201e30 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	80c50513          	addi	a0,a0,-2036 # ffffffffc0201e48 <commands+0x5a0>
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
ffffffffc0200656:	80e50513          	addi	a0,a0,-2034 # ffffffffc0201e60 <commands+0x5b8>
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
ffffffffc020066e:	80e50513          	addi	a0,a0,-2034 # ffffffffc0201e78 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	81650513          	addi	a0,a0,-2026 # ffffffffc0201e90 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	81e50513          	addi	a0,a0,-2018 # ffffffffc0201ea8 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	82250513          	addi	a0,a0,-2014 # ffffffffc0201ec0 <commands+0x618>
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
ffffffffc02006c0:	3a870713          	addi	a4,a4,936 # ffffffffc0201a64 <commands+0x1bc>
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
ffffffffc02006d2:	42a50513          	addi	a0,a0,1066 # ffffffffc0201af8 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	3fe50513          	addi	a0,a0,1022 # ffffffffc0201ad8 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	3b250513          	addi	a0,a0,946 # ffffffffc0201a98 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	42650513          	addi	a0,a0,1062 # ffffffffc0201b18 <commands+0x270>
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
ffffffffc020072e:	41650513          	addi	a0,a0,1046 # ffffffffc0201b40 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	38250513          	addi	a0,a0,898 # ffffffffc0201ab8 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	3e450513          	addi	a0,a0,996 # ffffffffc0201b30 <commands+0x288>
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
    for(int i=0;i<15;i++)
ffffffffc020081e:	00006797          	auipc	a5,0x6
ffffffffc0200822:	c2278793          	addi	a5,a5,-990 # ffffffffc0206440 <free_buddy+0x8>
ffffffffc0200826:	00006717          	auipc	a4,0x6
ffffffffc020082a:	d0a70713          	addi	a4,a4,-758 # ffffffffc0206530 <free_buddy+0xf8>
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
ffffffffc0200844:	d407a023          	sw	zero,-704(a5) # ffffffffc0206580 <free_buddy+0x148>
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
ffffffffc020084e:	d3656503          	lwu	a0,-714(a0) # ffffffffc0206580 <free_buddy+0x148>
ffffffffc0200852:	8082                	ret

ffffffffc0200854 <show_buddy_array>:
static void show_buddy_array(void) {
ffffffffc0200854:	715d                	addi	sp,sp,-80
    cprintf("[!]BS: Printing buddy array:\n");
ffffffffc0200856:	00002517          	auipc	a0,0x2
ffffffffc020085a:	8a250513          	addi	a0,a0,-1886 # ffffffffc02020f8 <buddy_pmm_manager_+0x38>
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
    for (int i = 0;i < 15;i ++) {
ffffffffc020087c:	4a01                	li	s4,0
        cprintf("%d layer: ", i);
ffffffffc020087e:	00002b97          	auipc	s7,0x2
ffffffffc0200882:	89ab8b93          	addi	s7,s7,-1894 # ffffffffc0202118 <buddy_pmm_manager_+0x58>
            cprintf("%d ", 1 << (p->property));
ffffffffc0200886:	4985                	li	s3,1
ffffffffc0200888:	00002917          	auipc	s2,0x2
ffffffffc020088c:	8a090913          	addi	s2,s2,-1888 # ffffffffc0202128 <buddy_pmm_manager_+0x68>
        cprintf("\n");
ffffffffc0200890:	00001b17          	auipc	s6,0x1
ffffffffc0200894:	010b0b13          	addi	s6,s6,16 # ffffffffc02018a0 <etext+0x118>
    for (int i = 0;i < 15;i ++) {
ffffffffc0200898:	4abd                	li	s5,15
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
    for (int i = 0;i < 15;i ++) {
ffffffffc02008be:	2a05                	addiw	s4,s4,1
        cprintf("\n");
ffffffffc02008c0:	ff6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02008c4:	04c1                	addi	s1,s1,16
    for (int i = 0;i < 15;i ++) {
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
ffffffffc02008e0:	85450513          	addi	a0,a0,-1964 # ffffffffc0202130 <buddy_pmm_manager_+0x70>
}
ffffffffc02008e4:	6161                	addi	sp,sp,80
    cprintf("---------------------------\n");
ffffffffc02008e6:	fd0ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02008ea <buddy_check>:
//     free_page(p);
//     free_page(p1);
//     free_page(p2);
// }   

static void buddy_check(void) {
ffffffffc02008ea:	1101                	addi	sp,sp,-32
    // assert(count == 0);
    // assert(total == 0);
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    //show_buddy_array();
    assert((p0 = alloc_page()) != NULL);
ffffffffc02008ec:	4505                	li	a0,1
static void buddy_check(void) {
ffffffffc02008ee:	ec06                	sd	ra,24(sp)
ffffffffc02008f0:	e822                	sd	s0,16(sp)
ffffffffc02008f2:	e426                	sd	s1,8(sp)
ffffffffc02008f4:	e04a                	sd	s2,0(sp)
    assert((p0 = alloc_page()) != NULL);
ffffffffc02008f6:	682000ef          	jal	ra,ffffffffc0200f78 <alloc_pages>
ffffffffc02008fa:	0c050b63          	beqz	a0,ffffffffc02009d0 <buddy_check+0xe6>
ffffffffc02008fe:	842a                	mv	s0,a0
    //show_buddy_array();
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200900:	4505                	li	a0,1
ffffffffc0200902:	676000ef          	jal	ra,ffffffffc0200f78 <alloc_pages>
ffffffffc0200906:	892a                	mv	s2,a0
ffffffffc0200908:	1a050463          	beqz	a0,ffffffffc0200ab0 <buddy_check+0x1c6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020090c:	4505                	li	a0,1
ffffffffc020090e:	66a000ef          	jal	ra,ffffffffc0200f78 <alloc_pages>
ffffffffc0200912:	84aa                	mv	s1,a0
ffffffffc0200914:	16050e63          	beqz	a0,ffffffffc0200a90 <buddy_check+0x1a6>
    show_buddy_array();
ffffffffc0200918:	f3dff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    free_page(p0);cprintf("1done\n");
ffffffffc020091c:	4585                	li	a1,1
ffffffffc020091e:	8522                	mv	a0,s0
ffffffffc0200920:	69c000ef          	jal	ra,ffffffffc0200fbc <free_pages>
ffffffffc0200924:	00001517          	auipc	a0,0x1
ffffffffc0200928:	67450513          	addi	a0,a0,1652 # ffffffffc0201f98 <commands+0x6f0>
ffffffffc020092c:	f8aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    show_buddy_array();
ffffffffc0200930:	f25ff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    free_page(p1);cprintf("2done\n");
ffffffffc0200934:	4585                	li	a1,1
ffffffffc0200936:	854a                	mv	a0,s2
ffffffffc0200938:	684000ef          	jal	ra,ffffffffc0200fbc <free_pages>
ffffffffc020093c:	00001517          	auipc	a0,0x1
ffffffffc0200940:	66450513          	addi	a0,a0,1636 # ffffffffc0201fa0 <commands+0x6f8>
ffffffffc0200944:	f72ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_page(p2);cprintf("3done\n");
ffffffffc0200948:	4585                	li	a1,1
ffffffffc020094a:	8526                	mv	a0,s1
ffffffffc020094c:	670000ef          	jal	ra,ffffffffc0200fbc <free_pages>
ffffffffc0200950:	00001517          	auipc	a0,0x1
ffffffffc0200954:	65850513          	addi	a0,a0,1624 # ffffffffc0201fa8 <commands+0x700>
ffffffffc0200958:	f5eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    show_buddy_array();
ffffffffc020095c:	ef9ff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>

    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0200960:	4511                	li	a0,4
ffffffffc0200962:	616000ef          	jal	ra,ffffffffc0200f78 <alloc_pages>
ffffffffc0200966:	892a                	mv	s2,a0
ffffffffc0200968:	10050463          	beqz	a0,ffffffffc0200a70 <buddy_check+0x186>
    assert((p1 = alloc_pages(2)) != NULL);
ffffffffc020096c:	4509                	li	a0,2
ffffffffc020096e:	60a000ef          	jal	ra,ffffffffc0200f78 <alloc_pages>
ffffffffc0200972:	84aa                	mv	s1,a0
ffffffffc0200974:	0c050e63          	beqz	a0,ffffffffc0200a50 <buddy_check+0x166>
    assert((p2 = alloc_pages(1)) != NULL);
ffffffffc0200978:	4505                	li	a0,1
ffffffffc020097a:	5fe000ef          	jal	ra,ffffffffc0200f78 <alloc_pages>
ffffffffc020097e:	842a                	mv	s0,a0
ffffffffc0200980:	c945                	beqz	a0,ffffffffc0200a30 <buddy_check+0x146>
    free_pages(p0, 4);
ffffffffc0200982:	4591                	li	a1,4
ffffffffc0200984:	854a                	mv	a0,s2
ffffffffc0200986:	636000ef          	jal	ra,ffffffffc0200fbc <free_pages>
    free_pages(p1, 2);
ffffffffc020098a:	8526                	mv	a0,s1
ffffffffc020098c:	4589                	li	a1,2
ffffffffc020098e:	62e000ef          	jal	ra,ffffffffc0200fbc <free_pages>
    free_pages(p2, 1);
ffffffffc0200992:	4585                	li	a1,1
ffffffffc0200994:	8522                	mv	a0,s0
ffffffffc0200996:	626000ef          	jal	ra,ffffffffc0200fbc <free_pages>
    show_buddy_array();
ffffffffc020099a:	ebbff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>

    assert((p0 = alloc_pages(3)) != NULL);
ffffffffc020099e:	450d                	li	a0,3
ffffffffc02009a0:	5d8000ef          	jal	ra,ffffffffc0200f78 <alloc_pages>
ffffffffc02009a4:	84aa                	mv	s1,a0
ffffffffc02009a6:	c52d                	beqz	a0,ffffffffc0200a10 <buddy_check+0x126>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02009a8:	450d                	li	a0,3
ffffffffc02009aa:	5ce000ef          	jal	ra,ffffffffc0200f78 <alloc_pages>
ffffffffc02009ae:	842a                	mv	s0,a0
ffffffffc02009b0:	c121                	beqz	a0,ffffffffc02009f0 <buddy_check+0x106>
    free_pages(p0, 3);
ffffffffc02009b2:	8526                	mv	a0,s1
ffffffffc02009b4:	458d                	li	a1,3
ffffffffc02009b6:	606000ef          	jal	ra,ffffffffc0200fbc <free_pages>
    free_pages(p1, 3);
ffffffffc02009ba:	8522                	mv	a0,s0
ffffffffc02009bc:	458d                	li	a1,3
ffffffffc02009be:	5fe000ef          	jal	ra,ffffffffc0200fbc <free_pages>

    show_buddy_array();
}
ffffffffc02009c2:	6442                	ld	s0,16(sp)
ffffffffc02009c4:	60e2                	ld	ra,24(sp)
ffffffffc02009c6:	64a2                	ld	s1,8(sp)
ffffffffc02009c8:	6902                	ld	s2,0(sp)
ffffffffc02009ca:	6105                	addi	sp,sp,32
    show_buddy_array();
ffffffffc02009cc:	e89ff06f          	j	ffffffffc0200854 <show_buddy_array>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02009d0:	00001697          	auipc	a3,0x1
ffffffffc02009d4:	53868693          	addi	a3,a3,1336 # ffffffffc0201f08 <commands+0x660>
ffffffffc02009d8:	00001617          	auipc	a2,0x1
ffffffffc02009dc:	55060613          	addi	a2,a2,1360 # ffffffffc0201f28 <commands+0x680>
ffffffffc02009e0:	11f00593          	li	a1,287
ffffffffc02009e4:	00001517          	auipc	a0,0x1
ffffffffc02009e8:	55c50513          	addi	a0,a0,1372 # ffffffffc0201f40 <commands+0x698>
ffffffffc02009ec:	9c1ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02009f0:	00001697          	auipc	a3,0x1
ffffffffc02009f4:	64068693          	addi	a3,a3,1600 # ffffffffc0202030 <commands+0x788>
ffffffffc02009f8:	00001617          	auipc	a2,0x1
ffffffffc02009fc:	53060613          	addi	a2,a2,1328 # ffffffffc0201f28 <commands+0x680>
ffffffffc0200a00:	13300593          	li	a1,307
ffffffffc0200a04:	00001517          	auipc	a0,0x1
ffffffffc0200a08:	53c50513          	addi	a0,a0,1340 # ffffffffc0201f40 <commands+0x698>
ffffffffc0200a0c:	9a1ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(3)) != NULL);
ffffffffc0200a10:	00001697          	auipc	a3,0x1
ffffffffc0200a14:	60068693          	addi	a3,a3,1536 # ffffffffc0202010 <commands+0x768>
ffffffffc0200a18:	00001617          	auipc	a2,0x1
ffffffffc0200a1c:	51060613          	addi	a2,a2,1296 # ffffffffc0201f28 <commands+0x680>
ffffffffc0200a20:	13200593          	li	a1,306
ffffffffc0200a24:	00001517          	auipc	a0,0x1
ffffffffc0200a28:	51c50513          	addi	a0,a0,1308 # ffffffffc0201f40 <commands+0x698>
ffffffffc0200a2c:	981ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_pages(1)) != NULL);
ffffffffc0200a30:	00001697          	auipc	a3,0x1
ffffffffc0200a34:	5c068693          	addi	a3,a3,1472 # ffffffffc0201ff0 <commands+0x748>
ffffffffc0200a38:	00001617          	auipc	a2,0x1
ffffffffc0200a3c:	4f060613          	addi	a2,a2,1264 # ffffffffc0201f28 <commands+0x680>
ffffffffc0200a40:	12c00593          	li	a1,300
ffffffffc0200a44:	00001517          	auipc	a0,0x1
ffffffffc0200a48:	4fc50513          	addi	a0,a0,1276 # ffffffffc0201f40 <commands+0x698>
ffffffffc0200a4c:	961ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(2)) != NULL);
ffffffffc0200a50:	00001697          	auipc	a3,0x1
ffffffffc0200a54:	58068693          	addi	a3,a3,1408 # ffffffffc0201fd0 <commands+0x728>
ffffffffc0200a58:	00001617          	auipc	a2,0x1
ffffffffc0200a5c:	4d060613          	addi	a2,a2,1232 # ffffffffc0201f28 <commands+0x680>
ffffffffc0200a60:	12b00593          	li	a1,299
ffffffffc0200a64:	00001517          	auipc	a0,0x1
ffffffffc0200a68:	4dc50513          	addi	a0,a0,1244 # ffffffffc0201f40 <commands+0x698>
ffffffffc0200a6c:	941ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0200a70:	00001697          	auipc	a3,0x1
ffffffffc0200a74:	54068693          	addi	a3,a3,1344 # ffffffffc0201fb0 <commands+0x708>
ffffffffc0200a78:	00001617          	auipc	a2,0x1
ffffffffc0200a7c:	4b060613          	addi	a2,a2,1200 # ffffffffc0201f28 <commands+0x680>
ffffffffc0200a80:	12a00593          	li	a1,298
ffffffffc0200a84:	00001517          	auipc	a0,0x1
ffffffffc0200a88:	4bc50513          	addi	a0,a0,1212 # ffffffffc0201f40 <commands+0x698>
ffffffffc0200a8c:	921ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a90:	00001697          	auipc	a3,0x1
ffffffffc0200a94:	4e868693          	addi	a3,a3,1256 # ffffffffc0201f78 <commands+0x6d0>
ffffffffc0200a98:	00001617          	auipc	a2,0x1
ffffffffc0200a9c:	49060613          	addi	a2,a2,1168 # ffffffffc0201f28 <commands+0x680>
ffffffffc0200aa0:	12200593          	li	a1,290
ffffffffc0200aa4:	00001517          	auipc	a0,0x1
ffffffffc0200aa8:	49c50513          	addi	a0,a0,1180 # ffffffffc0201f40 <commands+0x698>
ffffffffc0200aac:	901ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ab0:	00001697          	auipc	a3,0x1
ffffffffc0200ab4:	4a868693          	addi	a3,a3,1192 # ffffffffc0201f58 <commands+0x6b0>
ffffffffc0200ab8:	00001617          	auipc	a2,0x1
ffffffffc0200abc:	47060613          	addi	a2,a2,1136 # ffffffffc0201f28 <commands+0x680>
ffffffffc0200ac0:	12100593          	li	a1,289
ffffffffc0200ac4:	00001517          	auipc	a0,0x1
ffffffffc0200ac8:	47c50513          	addi	a0,a0,1148 # ffffffffc0201f40 <commands+0x698>
ffffffffc0200acc:	8e1ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ad0 <buddy_free_pages>:
{
ffffffffc0200ad0:	7159                	addi	sp,sp,-112
ffffffffc0200ad2:	f486                	sd	ra,104(sp)
ffffffffc0200ad4:	f0a2                	sd	s0,96(sp)
ffffffffc0200ad6:	eca6                	sd	s1,88(sp)
ffffffffc0200ad8:	e8ca                	sd	s2,80(sp)
ffffffffc0200ada:	e4ce                	sd	s3,72(sp)
ffffffffc0200adc:	e0d2                	sd	s4,64(sp)
ffffffffc0200ade:	fc56                	sd	s5,56(sp)
ffffffffc0200ae0:	f85a                	sd	s6,48(sp)
ffffffffc0200ae2:	f45e                	sd	s7,40(sp)
ffffffffc0200ae4:	f062                	sd	s8,32(sp)
ffffffffc0200ae6:	ec66                	sd	s9,24(sp)
ffffffffc0200ae8:	e86a                	sd	s10,16(sp)
ffffffffc0200aea:	e46e                	sd	s11,8(sp)
    assert(n>0);
ffffffffc0200aec:	1a058b63          	beqz	a1,ffffffffc0200ca2 <buddy_free_pages+0x1d2>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200af0:	00006a17          	auipc	s4,0x6
ffffffffc0200af4:	ab8a0a13          	addi	s4,s4,-1352 # ffffffffc02065a8 <pages>
ffffffffc0200af8:	000a3783          	ld	a5,0(s4)
ffffffffc0200afc:	00001497          	auipc	s1,0x1
ffffffffc0200b00:	55448493          	addi	s1,s1,1364 # ffffffffc0202050 <commands+0x7a8>
ffffffffc0200b04:	6098                	ld	a4,0(s1)
ffffffffc0200b06:	40f507b3          	sub	a5,a0,a5
ffffffffc0200b0a:	878d                	srai	a5,a5,0x3
ffffffffc0200b0c:	02e787b3          	mul	a5,a5,a4
ffffffffc0200b10:	00002917          	auipc	s2,0x2
ffffffffc0200b14:	9d890913          	addi	s2,s2,-1576 # ffffffffc02024e8 <nbase>
ffffffffc0200b18:	00093603          	ld	a2,0(s2)
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200b1c:	00006997          	auipc	s3,0x6
ffffffffc0200b20:	a7498993          	addi	s3,s3,-1420 # ffffffffc0206590 <fppn>
ffffffffc0200b24:	8c2a                	mv	s8,a0
ffffffffc0200b26:	0009b583          	ld	a1,0(s3)
    uint32_t power=page->property;
ffffffffc0200b2a:	4908                	lw	a0,16(a0)
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200b2c:	4685                	li	a3,1
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b2e:	00006417          	auipc	s0,0x6
ffffffffc0200b32:	90a40413          	addi	s0,s0,-1782 # ffffffffc0206438 <free_buddy>
ffffffffc0200b36:	00a696bb          	sllw	a3,a3,a0
ffffffffc0200b3a:	97b2                	add	a5,a5,a2
ffffffffc0200b3c:	40b78633          	sub	a2,a5,a1
ffffffffc0200b40:	8e35                	xor	a2,a2,a3
    return page+(ppn-page2ppn(page));
ffffffffc0200b42:	40f587b3          	sub	a5,a1,a5
ffffffffc0200b46:	97b2                	add	a5,a5,a2
ffffffffc0200b48:	02051713          	slli	a4,a0,0x20
ffffffffc0200b4c:	00279613          	slli	a2,a5,0x2
ffffffffc0200b50:	9301                	srli	a4,a4,0x20
ffffffffc0200b52:	0712                	slli	a4,a4,0x4
ffffffffc0200b54:	97b2                	add	a5,a5,a2
ffffffffc0200b56:	00e40833          	add	a6,s0,a4
ffffffffc0200b5a:	078e                	slli	a5,a5,0x3
ffffffffc0200b5c:	01083583          	ld	a1,16(a6)
ffffffffc0200b60:	00fc0db3          	add	s11,s8,a5
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b64:	008db603          	ld	a2,8(s11)
    list_add(&(free_array[free_page->property]),&(free_page->page_link));
ffffffffc0200b68:	018c0893          	addi	a7,s8,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200b6c:	0115b023          	sd	a7,0(a1)
ffffffffc0200b70:	0721                	addi	a4,a4,8
ffffffffc0200b72:	01183823          	sd	a7,16(a6)
ffffffffc0200b76:	9722                	add	a4,a4,s0
ffffffffc0200b78:	8205                	srli	a2,a2,0x1
    elm->next = next;
    elm->prev = prev;
ffffffffc0200b7a:	00ec3c23          	sd	a4,24(s8)
    elm->next = next;
ffffffffc0200b7e:	02bc3023          	sd	a1,32(s8)
    while(!PageProperty(free_page_buddy)&&free_page->property<15)
ffffffffc0200b82:	00167713          	andi	a4,a2,1
ffffffffc0200b86:	eb65                	bnez	a4,ffffffffc0200c76 <buddy_free_pages+0x1a6>
ffffffffc0200b88:	4739                	li	a4,14
ffffffffc0200b8a:	0ea76663          	bltu	a4,a0,ffffffffc0200c76 <buddy_free_pages+0x1a6>
ffffffffc0200b8e:	8d62                	mv	s10,s8
        cprintf("inwhile\n");
ffffffffc0200b90:	00001b97          	auipc	s7,0x1
ffffffffc0200b94:	4d0b8b93          	addi	s7,s7,1232 # ffffffffc0202060 <commands+0x7b8>
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200b98:	4b05                	li	s6,1
        cprintf("buddy's property is %d\n",free_page_buddy->property);
ffffffffc0200b9a:	00001a97          	auipc	s5,0x1
ffffffffc0200b9e:	4d6a8a93          	addi	s5,s5,1238 # ffffffffc0202070 <commands+0x7c8>
    while(!PageProperty(free_page_buddy)&&free_page->property<15)
ffffffffc0200ba2:	4cb9                	li	s9,14
ffffffffc0200ba4:	a029                	j	ffffffffc0200bae <buddy_free_pages+0xde>
ffffffffc0200ba6:	010d2683          	lw	a3,16(s10)
ffffffffc0200baa:	0cdce163          	bltu	s9,a3,ffffffffc0200c6c <buddy_free_pages+0x19c>
        cprintf("inwhile\n");
ffffffffc0200bae:	855e                	mv	a0,s7
ffffffffc0200bb0:	d06ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        if(free_page_buddy<free_page)
ffffffffc0200bb4:	01adfd63          	bleu	s10,s11,ffffffffc0200bce <buddy_free_pages+0xfe>
            free_page->property=-1;
ffffffffc0200bb8:	57fd                	li	a5,-1
ffffffffc0200bba:	00fd2823          	sw	a5,16(s10)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200bbe:	5775                	li	a4,-3
ffffffffc0200bc0:	008d0793          	addi	a5,s10,8
ffffffffc0200bc4:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0200bc8:	86ea                	mv	a3,s10
ffffffffc0200bca:	8d6e                	mv	s10,s11
ffffffffc0200bcc:	8db6                	mv	s11,a3
ffffffffc0200bce:	000a3683          	ld	a3,0(s4)
ffffffffc0200bd2:	6090                	ld	a2,0(s1)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200bd4:	018d3803          	ld	a6,24(s10)
ffffffffc0200bd8:	40dd06b3          	sub	a3,s10,a3
ffffffffc0200bdc:	868d                	srai	a3,a3,0x3
ffffffffc0200bde:	02c686b3          	mul	a3,a3,a2
ffffffffc0200be2:	020d3603          	ld	a2,32(s10)
        free_page->property+=1;
ffffffffc0200be6:	010d2583          	lw	a1,16(s10)
ffffffffc0200bea:	00093303          	ld	t1,0(s2)
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200bee:	0009b503          	ld	a0,0(s3)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200bf2:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0200bf6:	01063023          	sd	a6,0(a2)
        free_page->property+=1;
ffffffffc0200bfa:	2585                	addiw	a1,a1,1
    __list_del(listelm->prev, listelm->next);
ffffffffc0200bfc:	018db803          	ld	a6,24(s11)
ffffffffc0200c00:	020db883          	ld	a7,32(s11)
ffffffffc0200c04:	969a                	add	a3,a3,t1
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200c06:	40a68333          	sub	t1,a3,a0
ffffffffc0200c0a:	00bb17bb          	sllw	a5,s6,a1
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c0e:	02059613          	slli	a2,a1,0x20
ffffffffc0200c12:	0067c7b3          	xor	a5,a5,t1
    return page+(ppn-page2ppn(page));
ffffffffc0200c16:	40d506b3          	sub	a3,a0,a3
ffffffffc0200c1a:	9201                	srli	a2,a2,0x20
ffffffffc0200c1c:	96be                	add	a3,a3,a5
ffffffffc0200c1e:	0612                	slli	a2,a2,0x4
    prev->next = next;
ffffffffc0200c20:	01183423          	sd	a7,8(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c24:	00c40333          	add	t1,s0,a2
ffffffffc0200c28:	00269793          	slli	a5,a3,0x2
ffffffffc0200c2c:	01033503          	ld	a0,16(t1)
ffffffffc0200c30:	97b6                	add	a5,a5,a3
    next->prev = prev;
ffffffffc0200c32:	0108b023          	sd	a6,0(a7)
ffffffffc0200c36:	078e                	slli	a5,a5,0x3
        list_add(&(free_array[free_page->property]),&(free_page->page_link));
ffffffffc0200c38:	018d0693          	addi	a3,s10,24
        free_page->property+=1;
ffffffffc0200c3c:	00bd2823          	sw	a1,16(s10)
    return page+(ppn-page2ppn(page));
ffffffffc0200c40:	00fd0db3          	add	s11,s10,a5
    prev->next = next->prev = elm;
ffffffffc0200c44:	e114                	sd	a3,0(a0)
        cprintf("buddy's property is %d\n",free_page_buddy->property);
ffffffffc0200c46:	010da583          	lw	a1,16(s11)
        list_add(&(free_array[free_page->property]),&(free_page->page_link));
ffffffffc0200c4a:	0621                	addi	a2,a2,8
ffffffffc0200c4c:	00d33823          	sd	a3,16(t1)
ffffffffc0200c50:	9622                	add	a2,a2,s0
    elm->next = next;
ffffffffc0200c52:	02ad3023          	sd	a0,32(s10)
    elm->prev = prev;
ffffffffc0200c56:	00cd3c23          	sd	a2,24(s10)
        cprintf("buddy's property is %d\n",free_page_buddy->property);
ffffffffc0200c5a:	8556                	mv	a0,s5
ffffffffc0200c5c:	c5aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        show_buddy_array();
ffffffffc0200c60:	bf5ff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200c64:	008db683          	ld	a3,8(s11)
    while(!PageProperty(free_page_buddy)&&free_page->property<15)
ffffffffc0200c68:	8a89                	andi	a3,a3,2
ffffffffc0200c6a:	de95                	beqz	a3,ffffffffc0200ba6 <buddy_free_pages+0xd6>
ffffffffc0200c6c:	010c2783          	lw	a5,16(s8)
ffffffffc0200c70:	4685                	li	a3,1
ffffffffc0200c72:	00f696bb          	sllw	a3,a3,a5
    nr_free+=1<<base->property;   
ffffffffc0200c76:	14842783          	lw	a5,328(s0)
}
ffffffffc0200c7a:	70a6                	ld	ra,104(sp)
ffffffffc0200c7c:	7406                	ld	s0,96(sp)
    nr_free+=1<<base->property;   
ffffffffc0200c7e:	9ebd                	addw	a3,a3,a5
ffffffffc0200c80:	00006797          	auipc	a5,0x6
ffffffffc0200c84:	90d7a023          	sw	a3,-1792(a5) # ffffffffc0206580 <free_buddy+0x148>
}
ffffffffc0200c88:	64e6                	ld	s1,88(sp)
ffffffffc0200c8a:	6946                	ld	s2,80(sp)
ffffffffc0200c8c:	69a6                	ld	s3,72(sp)
ffffffffc0200c8e:	6a06                	ld	s4,64(sp)
ffffffffc0200c90:	7ae2                	ld	s5,56(sp)
ffffffffc0200c92:	7b42                	ld	s6,48(sp)
ffffffffc0200c94:	7ba2                	ld	s7,40(sp)
ffffffffc0200c96:	7c02                	ld	s8,32(sp)
ffffffffc0200c98:	6ce2                	ld	s9,24(sp)
ffffffffc0200c9a:	6d42                	ld	s10,16(sp)
ffffffffc0200c9c:	6da2                	ld	s11,8(sp)
ffffffffc0200c9e:	6165                	addi	sp,sp,112
ffffffffc0200ca0:	8082                	ret
    assert(n>0);
ffffffffc0200ca2:	00001697          	auipc	a3,0x1
ffffffffc0200ca6:	3b668693          	addi	a3,a3,950 # ffffffffc0202058 <commands+0x7b0>
ffffffffc0200caa:	00001617          	auipc	a2,0x1
ffffffffc0200cae:	27e60613          	addi	a2,a2,638 # ffffffffc0201f28 <commands+0x680>
ffffffffc0200cb2:	07f00593          	li	a1,127
ffffffffc0200cb6:	00001517          	auipc	a0,0x1
ffffffffc0200cba:	28a50513          	addi	a0,a0,650 # ffffffffc0201f40 <commands+0x698>
ffffffffc0200cbe:	eeeff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200cc2 <GET_POWER_OF_2>:
{
ffffffffc0200cc2:	1101                	addi	sp,sp,-32
ffffffffc0200cc4:	e822                	sd	s0,16(sp)
ffffffffc0200cc6:	ec06                	sd	ra,24(sp)
ffffffffc0200cc8:	e426                	sd	s1,8(sp)
ffffffffc0200cca:	e04a                	sd	s2,0(sp)
    while(n>>1)
ffffffffc0200ccc:	00155413          	srli	s0,a0,0x1
ffffffffc0200cd0:	cc1d                	beqz	s0,ffffffffc0200d0e <GET_POWER_OF_2+0x4c>
ffffffffc0200cd2:	85aa                	mv	a1,a0
    uint32_t power = 0;
ffffffffc0200cd4:	4481                	li	s1,0
        cprintf("n is %d\n",n);
ffffffffc0200cd6:	00001917          	auipc	s2,0x1
ffffffffc0200cda:	20290913          	addi	s2,s2,514 # ffffffffc0201ed8 <commands+0x630>
ffffffffc0200cde:	a011                	j	ffffffffc0200ce2 <GET_POWER_OF_2+0x20>
ffffffffc0200ce0:	843e                	mv	s0,a5
ffffffffc0200ce2:	854a                	mv	a0,s2
ffffffffc0200ce4:	bd2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    while(n>>1)
ffffffffc0200ce8:	00145793          	srli	a5,s0,0x1
ffffffffc0200cec:	85a2                	mv	a1,s0
        power++;
ffffffffc0200cee:	2485                	addiw	s1,s1,1
    while(n>>1)
ffffffffc0200cf0:	fbe5                	bnez	a5,ffffffffc0200ce0 <GET_POWER_OF_2+0x1e>
    cprintf("power is %d\n",power);
ffffffffc0200cf2:	85a6                	mv	a1,s1
ffffffffc0200cf4:	00001517          	auipc	a0,0x1
ffffffffc0200cf8:	1f450513          	addi	a0,a0,500 # ffffffffc0201ee8 <commands+0x640>
ffffffffc0200cfc:	bbaff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
}
ffffffffc0200d00:	60e2                	ld	ra,24(sp)
ffffffffc0200d02:	6442                	ld	s0,16(sp)
ffffffffc0200d04:	8526                	mv	a0,s1
ffffffffc0200d06:	6902                	ld	s2,0(sp)
ffffffffc0200d08:	64a2                	ld	s1,8(sp)
ffffffffc0200d0a:	6105                	addi	sp,sp,32
ffffffffc0200d0c:	8082                	ret
    uint32_t power = 0;
ffffffffc0200d0e:	4481                	li	s1,0
ffffffffc0200d10:	b7cd                	j	ffffffffc0200cf2 <GET_POWER_OF_2+0x30>

ffffffffc0200d12 <buddy_alloc_pages>:
{
ffffffffc0200d12:	7179                	addi	sp,sp,-48
ffffffffc0200d14:	f406                	sd	ra,40(sp)
ffffffffc0200d16:	f022                	sd	s0,32(sp)
ffffffffc0200d18:	ec26                	sd	s1,24(sp)
ffffffffc0200d1a:	e84a                	sd	s2,16(sp)
ffffffffc0200d1c:	e44e                	sd	s3,8(sp)
    assert (real_n>0);
ffffffffc0200d1e:	14050463          	beqz	a0,ffffffffc0200e66 <buddy_alloc_pages+0x154>
    if(real_n>nr_free)
ffffffffc0200d22:	00006717          	auipc	a4,0x6
ffffffffc0200d26:	85e76703          	lwu	a4,-1954(a4) # ffffffffc0206580 <free_buddy+0x148>
ffffffffc0200d2a:	12a76663          	bltu	a4,a0,ffffffffc0200e56 <buddy_alloc_pages+0x144>
    order=IS_POWER_OF_2(real_n)?GET_POWER_OF_2(real_n):GET_POWER_OF_2(real_n)+1;
ffffffffc0200d2e:	fff50713          	addi	a4,a0,-1
ffffffffc0200d32:	00a777b3          	and	a5,a4,a0
ffffffffc0200d36:	cff1                	beqz	a5,ffffffffc0200e12 <buddy_alloc_pages+0x100>
ffffffffc0200d38:	f8bff0ef          	jal	ra,ffffffffc0200cc2 <GET_POWER_OF_2>
ffffffffc0200d3c:	2505                	addiw	a0,a0,1
        if(!list_empty(&(free_array[order])))
ffffffffc0200d3e:	02051293          	slli	t0,a0,0x20
    order=IS_POWER_OF_2(real_n)?GET_POWER_OF_2(real_n):GET_POWER_OF_2(real_n)+1;
ffffffffc0200d42:	00005897          	auipc	a7,0x5
ffffffffc0200d46:	6f688893          	addi	a7,a7,1782 # ffffffffc0206438 <free_buddy>
        if(!list_empty(&(free_array[order])))
ffffffffc0200d4a:	01c2d293          	srli	t0,t0,0x1c
        for(int i=order;i<15;i++)
ffffffffc0200d4e:	0005081b          	sext.w	a6,a0
        if(!list_empty(&(free_array[order])))
ffffffffc0200d52:	00828313          	addi	t1,t0,8
ffffffffc0200d56:	92c6                	add	t0,t0,a7
            if(!list_empty(&(free_array[i])))
ffffffffc0200d58:	00481e13          	slli	t3,a6,0x4
ffffffffc0200d5c:	00280e93          	addi	t4,a6,2
ffffffffc0200d60:	0102b903          	ld	s2,16(t0)
ffffffffc0200d64:	008e0f13          	addi	t5,t3,8
ffffffffc0200d68:	0e92                	slli	t4,t4,0x4
    size_t n=1<<order;
ffffffffc0200d6a:	4405                	li	s0,1
    order=IS_POWER_OF_2(real_n)?GET_POWER_OF_2(real_n):GET_POWER_OF_2(real_n)+1;
ffffffffc0200d6c:	00005797          	auipc	a5,0x5
ffffffffc0200d70:	6ca7a623          	sw	a0,1740(a5) # ffffffffc0206438 <free_buddy>
    size_t n=1<<order;
ffffffffc0200d74:	00a4143b          	sllw	s0,s0,a0
        if(!list_empty(&(free_array[order])))
ffffffffc0200d78:	9346                	add	t1,t1,a7
            if(!list_empty(&(free_array[i])))
ffffffffc0200d7a:	9f46                	add	t5,t5,a7
ffffffffc0200d7c:	9ec6                	add	t4,t4,a7
        for(int i=order;i<15;i++)
ffffffffc0200d7e:	4fb9                	li	t6,14
    return list->next == list;
ffffffffc0200d80:	9e46                	add	t3,t3,a7
ffffffffc0200d82:	453d                	li	a0,15
ffffffffc0200d84:	fff8049b          	addiw	s1,a6,-1
                struct Page *page2=page1+(1<<(i-1));
ffffffffc0200d88:	4385                	li	t2,1
        if(!list_empty(&(free_array[order])))
ffffffffc0200d8a:	09231863          	bne	t1,s2,ffffffffc0200e1a <buddy_alloc_pages+0x108>
        for(int i=order;i<15;i++)
ffffffffc0200d8e:	ff0fcee3          	blt	t6,a6,ffffffffc0200d8a <buddy_alloc_pages+0x78>
ffffffffc0200d92:	010e3583          	ld	a1,16(t3)
            if(!list_empty(&(free_array[i])))
ffffffffc0200d96:	0abf1e63          	bne	t5,a1,ffffffffc0200e52 <buddy_alloc_pages+0x140>
ffffffffc0200d9a:	87f6                	mv	a5,t4
ffffffffc0200d9c:	8642                	mv	a2,a6
ffffffffc0200d9e:	a019                	j	ffffffffc0200da4 <buddy_alloc_pages+0x92>
ffffffffc0200da0:	87b6                	mv	a5,a3
ffffffffc0200da2:	863a                	mv	a2,a4
        for(int i=order;i<15;i++)
ffffffffc0200da4:	0016071b          	addiw	a4,a2,1
ffffffffc0200da8:	fea701e3          	beq	a4,a0,ffffffffc0200d8a <buddy_alloc_pages+0x78>
ffffffffc0200dac:	638c                	ld	a1,0(a5)
ffffffffc0200dae:	01078693          	addi	a3,a5,16
            if(!list_empty(&(free_array[i])))
ffffffffc0200db2:	17e1                	addi	a5,a5,-8
ffffffffc0200db4:	fef586e3          	beq	a1,a5,ffffffffc0200da0 <buddy_alloc_pages+0x8e>
                struct Page *page2=page1+(1<<(i-1));
ffffffffc0200db8:	00c397bb          	sllw	a5,t2,a2
ffffffffc0200dbc:	00279713          	slli	a4,a5,0x2
ffffffffc0200dc0:	973e                	add	a4,a4,a5
ffffffffc0200dc2:	070e                	slli	a4,a4,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200dc4:	0085b903          	ld	s2,8(a1)
ffffffffc0200dc8:	0005b983          	ld	s3,0(a1)
                page1->property=i-1;
ffffffffc0200dcc:	0006079b          	sext.w	a5,a2
                struct Page *page2=page1+(1<<(i-1));
ffffffffc0200dd0:	1721                	addi	a4,a4,-24
                page1->property=i-1;
ffffffffc0200dd2:	fef5ac23          	sw	a5,-8(a1)
                struct Page *page2=page1+(1<<(i-1));
ffffffffc0200dd6:	972e                	add	a4,a4,a1
                page2->property=i-1;
ffffffffc0200dd8:	cb1c                	sw	a5,16(a4)
                list_add(&(free_array[i-1]),&(page1->page_link));
ffffffffc0200dda:	0612                	slli	a2,a2,0x4
    prev->next = next;
ffffffffc0200ddc:	0129b423          	sd	s2,8(s3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200de0:	00c886b3          	add	a3,a7,a2
ffffffffc0200de4:	6a9c                	ld	a5,16(a3)
    next->prev = prev;
ffffffffc0200de6:	01393023          	sd	s3,0(s2)
ffffffffc0200dea:	0621                	addi	a2,a2,8
    prev->next = next->prev = elm;
ffffffffc0200dec:	e38c                	sd	a1,0(a5)
ffffffffc0200dee:	ea8c                	sd	a1,16(a3)
    elm->next = next;
ffffffffc0200df0:	e59c                	sd	a5,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200df2:	0106b903          	ld	s2,16(a3)
ffffffffc0200df6:	00c887b3          	add	a5,a7,a2
    elm->prev = prev;
ffffffffc0200dfa:	e19c                	sd	a5,0(a1)
                list_add(&(free_array[i-1]),&(page2->page_link));
ffffffffc0200dfc:	01870613          	addi	a2,a4,24
    prev->next = next->prev = elm;
ffffffffc0200e00:	00c93023          	sd	a2,0(s2)
ffffffffc0200e04:	ea90                	sd	a2,16(a3)
    elm->next = next;
ffffffffc0200e06:	03273023          	sd	s2,32(a4)
    elm->prev = prev;
ffffffffc0200e0a:	ef1c                	sd	a5,24(a4)
ffffffffc0200e0c:	0102b903          	ld	s2,16(t0)
ffffffffc0200e10:	bfad                	j	ffffffffc0200d8a <buddy_alloc_pages+0x78>
    order=IS_POWER_OF_2(real_n)?GET_POWER_OF_2(real_n):GET_POWER_OF_2(real_n)+1;
ffffffffc0200e12:	eb1ff0ef          	jal	ra,ffffffffc0200cc2 <GET_POWER_OF_2>
ffffffffc0200e16:	2501                	sext.w	a0,a0
ffffffffc0200e18:	b71d                	j	ffffffffc0200d3e <buddy_alloc_pages+0x2c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200e1a:	00093703          	ld	a4,0(s2)
ffffffffc0200e1e:	00893783          	ld	a5,8(s2)
            page=le2page(list_next(&(free_array[order])),page_link);
ffffffffc0200e22:	fe890513          	addi	a0,s2,-24
    prev->next = next;
ffffffffc0200e26:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200e28:	e398                	sd	a4,0(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200e2a:	4789                	li	a5,2
ffffffffc0200e2c:	ff090713          	addi	a4,s2,-16
ffffffffc0200e30:	40f7302f          	amoor.d	zero,a5,(a4)
            nr_free-=n;
ffffffffc0200e34:	1488a783          	lw	a5,328(a7)
}
ffffffffc0200e38:	70a2                	ld	ra,40(sp)
ffffffffc0200e3a:	64e2                	ld	s1,24(sp)
            nr_free-=n;
ffffffffc0200e3c:	4087843b          	subw	s0,a5,s0
ffffffffc0200e40:	00005797          	auipc	a5,0x5
ffffffffc0200e44:	7487a023          	sw	s0,1856(a5) # ffffffffc0206580 <free_buddy+0x148>
}
ffffffffc0200e48:	7402                	ld	s0,32(sp)
ffffffffc0200e4a:	6942                	ld	s2,16(sp)
ffffffffc0200e4c:	69a2                	ld	s3,8(sp)
ffffffffc0200e4e:	6145                	addi	sp,sp,48
ffffffffc0200e50:	8082                	ret
ffffffffc0200e52:	8626                	mv	a2,s1
ffffffffc0200e54:	b795                	j	ffffffffc0200db8 <buddy_alloc_pages+0xa6>
ffffffffc0200e56:	70a2                	ld	ra,40(sp)
ffffffffc0200e58:	7402                	ld	s0,32(sp)
ffffffffc0200e5a:	64e2                	ld	s1,24(sp)
ffffffffc0200e5c:	6942                	ld	s2,16(sp)
ffffffffc0200e5e:	69a2                	ld	s3,8(sp)
    return NULL;
ffffffffc0200e60:	4501                	li	a0,0
}
ffffffffc0200e62:	6145                	addi	sp,sp,48
ffffffffc0200e64:	8082                	ret
    assert (real_n>0);
ffffffffc0200e66:	00001697          	auipc	a3,0x1
ffffffffc0200e6a:	09268693          	addi	a3,a3,146 # ffffffffc0201ef8 <commands+0x650>
ffffffffc0200e6e:	00001617          	auipc	a2,0x1
ffffffffc0200e72:	0ba60613          	addi	a2,a2,186 # ffffffffc0201f28 <commands+0x680>
ffffffffc0200e76:	05500593          	li	a1,85
ffffffffc0200e7a:	00001517          	auipc	a0,0x1
ffffffffc0200e7e:	0c650513          	addi	a0,a0,198 # ffffffffc0201f40 <commands+0x698>
ffffffffc0200e82:	d2aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e86 <buddy_init_memmap>:
{
ffffffffc0200e86:	1101                	addi	sp,sp,-32
ffffffffc0200e88:	ec06                	sd	ra,24(sp)
ffffffffc0200e8a:	e822                	sd	s0,16(sp)
ffffffffc0200e8c:	e426                	sd	s1,8(sp)
    assert(real_n>0);
ffffffffc0200e8e:	c5e9                	beqz	a1,ffffffffc0200f58 <buddy_init_memmap+0xd2>
    cprintf("real_n is %d\n",real_n);
ffffffffc0200e90:	842a                	mv	s0,a0
ffffffffc0200e92:	00001517          	auipc	a0,0x1
ffffffffc0200e96:	1f650513          	addi	a0,a0,502 # ffffffffc0202088 <commands+0x7e0>
ffffffffc0200e9a:	84ae                	mv	s1,a1
ffffffffc0200e9c:	a1aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    order=GET_POWER_OF_2(real_n);
ffffffffc0200ea0:	8526                	mv	a0,s1
ffffffffc0200ea2:	e21ff0ef          	jal	ra,ffffffffc0200cc2 <GET_POWER_OF_2>
ffffffffc0200ea6:	0005059b          	sext.w	a1,a0
    size_t n=1<<order;
ffffffffc0200eaa:	4785                	li	a5,1
ffffffffc0200eac:	00b7973b          	sllw	a4,a5,a1
    for (; p != base + n; p+=1) 
ffffffffc0200eb0:	00271693          	slli	a3,a4,0x2
ffffffffc0200eb4:	96ba                	add	a3,a3,a4
    size_t n=1<<order;
ffffffffc0200eb6:	87ba                	mv	a5,a4
    for (; p != base + n; p+=1) 
ffffffffc0200eb8:	068e                	slli	a3,a3,0x3
    order=GET_POWER_OF_2(real_n);
ffffffffc0200eba:	00005717          	auipc	a4,0x5
ffffffffc0200ebe:	56b72f23          	sw	a1,1406(a4) # ffffffffc0206438 <free_buddy>
    nr_free=n;
ffffffffc0200ec2:	00005717          	auipc	a4,0x5
ffffffffc0200ec6:	6af72f23          	sw	a5,1726(a4) # ffffffffc0206580 <free_buddy+0x148>
    for (; p != base + n; p+=1) 
ffffffffc0200eca:	96a2                	add	a3,a3,s0
ffffffffc0200ecc:	00005717          	auipc	a4,0x5
ffffffffc0200ed0:	56c70713          	addi	a4,a4,1388 # ffffffffc0206438 <free_buddy>
ffffffffc0200ed4:	02d40963          	beq	s0,a3,ffffffffc0200f06 <buddy_init_memmap+0x80>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ed8:	6418                	ld	a4,8(s0)
        assert(PageReserved(p));// 确保页面已保留
ffffffffc0200eda:	87a2                	mv	a5,s0
        p->property =-1;
ffffffffc0200edc:	567d                	li	a2,-1
        assert(PageReserved(p));// 确保页面已保留
ffffffffc0200ede:	8b05                	andi	a4,a4,1
ffffffffc0200ee0:	e709                	bnez	a4,ffffffffc0200eea <buddy_init_memmap+0x64>
ffffffffc0200ee2:	a899                	j	ffffffffc0200f38 <buddy_init_memmap+0xb2>
ffffffffc0200ee4:	6798                	ld	a4,8(a5)
ffffffffc0200ee6:	8b05                	andi	a4,a4,1
ffffffffc0200ee8:	cb21                	beqz	a4,ffffffffc0200f38 <buddy_init_memmap+0xb2>
        p->flags =  0;//页面空闲
ffffffffc0200eea:	0007b423          	sd	zero,8(a5)
        p->property =-1;
ffffffffc0200eee:	cb90                	sw	a2,16(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200ef0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p+=1) 
ffffffffc0200ef4:	02878793          	addi	a5,a5,40
ffffffffc0200ef8:	fed796e3          	bne	a5,a3,ffffffffc0200ee4 <buddy_init_memmap+0x5e>
ffffffffc0200efc:	00005717          	auipc	a4,0x5
ffffffffc0200f00:	53c70713          	addi	a4,a4,1340 # ffffffffc0206438 <free_buddy>
ffffffffc0200f04:	430c                	lw	a1,0(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200f06:	02059793          	slli	a5,a1,0x20
ffffffffc0200f0a:	83f1                	srli	a5,a5,0x1c
ffffffffc0200f0c:	00f70633          	add	a2,a4,a5
ffffffffc0200f10:	6a14                	ld	a3,16(a2)
    list_add(&(free_array[order]), &(base->page_link));
ffffffffc0200f12:	01840513          	addi	a0,s0,24
ffffffffc0200f16:	07a1                	addi	a5,a5,8
    prev->next = next->prev = elm;
ffffffffc0200f18:	e288                	sd	a0,0(a3)
ffffffffc0200f1a:	ea08                	sd	a0,16(a2)
ffffffffc0200f1c:	97ba                	add	a5,a5,a4
    elm->next = next;
ffffffffc0200f1e:	f014                	sd	a3,32(s0)
    elm->prev = prev;
ffffffffc0200f20:	ec1c                	sd	a5,24(s0)
    base->property=order;
ffffffffc0200f22:	c80c                	sw	a1,16(s0)
}
ffffffffc0200f24:	6442                	ld	s0,16(sp)
ffffffffc0200f26:	60e2                	ld	ra,24(sp)
ffffffffc0200f28:	64a2                	ld	s1,8(sp)
    cprintf("base order is %d\n",order);
ffffffffc0200f2a:	00001517          	auipc	a0,0x1
ffffffffc0200f2e:	17e50513          	addi	a0,a0,382 # ffffffffc02020a8 <commands+0x800>
}
ffffffffc0200f32:	6105                	addi	sp,sp,32
    cprintf("base order is %d\n",order);
ffffffffc0200f34:	982ff06f          	j	ffffffffc02000b6 <cprintf>
        assert(PageReserved(p));// 确保页面已保留
ffffffffc0200f38:	00001697          	auipc	a3,0x1
ffffffffc0200f3c:	16068693          	addi	a3,a3,352 # ffffffffc0202098 <commands+0x7f0>
ffffffffc0200f40:	00001617          	auipc	a2,0x1
ffffffffc0200f44:	fe860613          	addi	a2,a2,-24 # ffffffffc0201f28 <commands+0x680>
ffffffffc0200f48:	04800593          	li	a1,72
ffffffffc0200f4c:	00001517          	auipc	a0,0x1
ffffffffc0200f50:	ff450513          	addi	a0,a0,-12 # ffffffffc0201f40 <commands+0x698>
ffffffffc0200f54:	c58ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(real_n>0);
ffffffffc0200f58:	00001697          	auipc	a3,0x1
ffffffffc0200f5c:	fa068693          	addi	a3,a3,-96 # ffffffffc0201ef8 <commands+0x650>
ffffffffc0200f60:	00001617          	auipc	a2,0x1
ffffffffc0200f64:	fc860613          	addi	a2,a2,-56 # ffffffffc0201f28 <commands+0x680>
ffffffffc0200f68:	04000593          	li	a1,64
ffffffffc0200f6c:	00001517          	auipc	a0,0x1
ffffffffc0200f70:	fd450513          	addi	a0,a0,-44 # ffffffffc0201f40 <commands+0x698>
ffffffffc0200f74:	c38ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f78 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f78:	100027f3          	csrr	a5,sstatus
ffffffffc0200f7c:	8b89                	andi	a5,a5,2
ffffffffc0200f7e:	eb89                	bnez	a5,ffffffffc0200f90 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200f80:	00005797          	auipc	a5,0x5
ffffffffc0200f84:	61878793          	addi	a5,a5,1560 # ffffffffc0206598 <pmm_manager>
ffffffffc0200f88:	639c                	ld	a5,0(a5)
ffffffffc0200f8a:	0187b303          	ld	t1,24(a5)
ffffffffc0200f8e:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200f90:	1141                	addi	sp,sp,-16
ffffffffc0200f92:	e406                	sd	ra,8(sp)
ffffffffc0200f94:	e022                	sd	s0,0(sp)
ffffffffc0200f96:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200f98:	cccff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200f9c:	00005797          	auipc	a5,0x5
ffffffffc0200fa0:	5fc78793          	addi	a5,a5,1532 # ffffffffc0206598 <pmm_manager>
ffffffffc0200fa4:	639c                	ld	a5,0(a5)
ffffffffc0200fa6:	8522                	mv	a0,s0
ffffffffc0200fa8:	6f9c                	ld	a5,24(a5)
ffffffffc0200faa:	9782                	jalr	a5
ffffffffc0200fac:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200fae:	cb0ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200fb2:	8522                	mv	a0,s0
ffffffffc0200fb4:	60a2                	ld	ra,8(sp)
ffffffffc0200fb6:	6402                	ld	s0,0(sp)
ffffffffc0200fb8:	0141                	addi	sp,sp,16
ffffffffc0200fba:	8082                	ret

ffffffffc0200fbc <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200fbc:	100027f3          	csrr	a5,sstatus
ffffffffc0200fc0:	8b89                	andi	a5,a5,2
ffffffffc0200fc2:	eb89                	bnez	a5,ffffffffc0200fd4 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200fc4:	00005797          	auipc	a5,0x5
ffffffffc0200fc8:	5d478793          	addi	a5,a5,1492 # ffffffffc0206598 <pmm_manager>
ffffffffc0200fcc:	639c                	ld	a5,0(a5)
ffffffffc0200fce:	0207b303          	ld	t1,32(a5)
ffffffffc0200fd2:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200fd4:	1101                	addi	sp,sp,-32
ffffffffc0200fd6:	ec06                	sd	ra,24(sp)
ffffffffc0200fd8:	e822                	sd	s0,16(sp)
ffffffffc0200fda:	e426                	sd	s1,8(sp)
ffffffffc0200fdc:	842a                	mv	s0,a0
ffffffffc0200fde:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200fe0:	c84ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200fe4:	00005797          	auipc	a5,0x5
ffffffffc0200fe8:	5b478793          	addi	a5,a5,1460 # ffffffffc0206598 <pmm_manager>
ffffffffc0200fec:	639c                	ld	a5,0(a5)
ffffffffc0200fee:	85a6                	mv	a1,s1
ffffffffc0200ff0:	8522                	mv	a0,s0
ffffffffc0200ff2:	739c                	ld	a5,32(a5)
ffffffffc0200ff4:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200ff6:	6442                	ld	s0,16(sp)
ffffffffc0200ff8:	60e2                	ld	ra,24(sp)
ffffffffc0200ffa:	64a2                	ld	s1,8(sp)
ffffffffc0200ffc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200ffe:	c60ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201002 <pmm_init>:
    pmm_manager=&buddy_pmm_manager_;
ffffffffc0201002:	00001797          	auipc	a5,0x1
ffffffffc0201006:	0be78793          	addi	a5,a5,190 # ffffffffc02020c0 <buddy_pmm_manager_>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020100a:	638c                	ld	a1,0(a5)
        fppn=pa2page(mem_begin)-pages+nbase;
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020100c:	7139                	addi	sp,sp,-64
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020100e:	00001517          	auipc	a0,0x1
ffffffffc0201012:	15a50513          	addi	a0,a0,346 # ffffffffc0202168 <buddy_pmm_manager_+0xa8>
void pmm_init(void) {
ffffffffc0201016:	fc06                	sd	ra,56(sp)
    pmm_manager=&buddy_pmm_manager_;
ffffffffc0201018:	00005717          	auipc	a4,0x5
ffffffffc020101c:	58f73023          	sd	a5,1408(a4) # ffffffffc0206598 <pmm_manager>
void pmm_init(void) {
ffffffffc0201020:	f822                	sd	s0,48(sp)
ffffffffc0201022:	f426                	sd	s1,40(sp)
ffffffffc0201024:	ec4e                	sd	s3,24(sp)
ffffffffc0201026:	f04a                	sd	s2,32(sp)
ffffffffc0201028:	e852                	sd	s4,16(sp)
ffffffffc020102a:	e456                	sd	s5,8(sp)
    pmm_manager=&buddy_pmm_manager_;
ffffffffc020102c:	00005417          	auipc	s0,0x5
ffffffffc0201030:	56c40413          	addi	s0,s0,1388 # ffffffffc0206598 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201034:	882ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0201038:	601c                	ld	a5,0(s0)
ffffffffc020103a:	00005497          	auipc	s1,0x5
ffffffffc020103e:	3de48493          	addi	s1,s1,990 # ffffffffc0206418 <npage>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201042:	fff809b7          	lui	s3,0xfff80
    pmm_manager->init();
ffffffffc0201046:	679c                	ld	a5,8(a5)
ffffffffc0201048:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020104a:	57f5                	li	a5,-3
ffffffffc020104c:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020104e:	00001517          	auipc	a0,0x1
ffffffffc0201052:	13250513          	addi	a0,a0,306 # ffffffffc0202180 <buddy_pmm_manager_+0xc0>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201056:	00005717          	auipc	a4,0x5
ffffffffc020105a:	54f73523          	sd	a5,1354(a4) # ffffffffc02065a0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020105e:	858ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201062:	46c5                	li	a3,17
ffffffffc0201064:	06ee                	slli	a3,a3,0x1b
ffffffffc0201066:	40100613          	li	a2,1025
ffffffffc020106a:	16fd                	addi	a3,a3,-1
ffffffffc020106c:	0656                	slli	a2,a2,0x15
ffffffffc020106e:	07e005b7          	lui	a1,0x7e00
ffffffffc0201072:	00001517          	auipc	a0,0x1
ffffffffc0201076:	12650513          	addi	a0,a0,294 # ffffffffc0202198 <buddy_pmm_manager_+0xd8>
ffffffffc020107a:	83cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020107e:	777d                	lui	a4,0xfffff
ffffffffc0201080:	00006797          	auipc	a5,0x6
ffffffffc0201084:	52f78793          	addi	a5,a5,1327 # ffffffffc02075af <end+0xfff>
ffffffffc0201088:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020108a:	00088737          	lui	a4,0x88
ffffffffc020108e:	00005697          	auipc	a3,0x5
ffffffffc0201092:	38e6b523          	sd	a4,906(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201096:	4601                	li	a2,0
ffffffffc0201098:	00005717          	auipc	a4,0x5
ffffffffc020109c:	50f73823          	sd	a5,1296(a4) # ffffffffc02065a8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010a0:	4681                	li	a3,0
ffffffffc02010a2:	00005597          	auipc	a1,0x5
ffffffffc02010a6:	50658593          	addi	a1,a1,1286 # ffffffffc02065a8 <pages>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010aa:	4505                	li	a0,1
ffffffffc02010ac:	a011                	j	ffffffffc02010b0 <pmm_init+0xae>
ffffffffc02010ae:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc02010b0:	97b2                	add	a5,a5,a2
ffffffffc02010b2:	07a1                	addi	a5,a5,8
ffffffffc02010b4:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010b8:	6098                	ld	a4,0(s1)
ffffffffc02010ba:	0685                	addi	a3,a3,1
ffffffffc02010bc:	02860613          	addi	a2,a2,40
ffffffffc02010c0:	013707b3          	add	a5,a4,s3
ffffffffc02010c4:	fef6e5e3          	bltu	a3,a5,ffffffffc02010ae <pmm_init+0xac>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010c8:	6188                	ld	a0,0(a1)
ffffffffc02010ca:	00271793          	slli	a5,a4,0x2
ffffffffc02010ce:	97ba                	add	a5,a5,a4
ffffffffc02010d0:	fec006b7          	lui	a3,0xfec00
ffffffffc02010d4:	078e                	slli	a5,a5,0x3
ffffffffc02010d6:	96aa                	add	a3,a3,a0
ffffffffc02010d8:	96be                	add	a3,a3,a5
ffffffffc02010da:	c02007b7          	lui	a5,0xc0200
ffffffffc02010de:	0ef6e763          	bltu	a3,a5,ffffffffc02011cc <pmm_init+0x1ca>
ffffffffc02010e2:	00005a17          	auipc	s4,0x5
ffffffffc02010e6:	4bea0a13          	addi	s4,s4,1214 # ffffffffc02065a0 <va_pa_offset>
ffffffffc02010ea:	000a3783          	ld	a5,0(s4)
    if (freemem < mem_end) {
ffffffffc02010ee:	45c5                	li	a1,17
ffffffffc02010f0:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010f2:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc02010f4:	06b6f463          	bleu	a1,a3,ffffffffc020115c <pmm_init+0x15a>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02010f8:	6785                	lui	a5,0x1
ffffffffc02010fa:	17fd                	addi	a5,a5,-1
ffffffffc02010fc:	96be                	add	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02010fe:	00c6da93          	srli	s5,a3,0xc
ffffffffc0201102:	0aeaf963          	bleu	a4,s5,ffffffffc02011b4 <pmm_init+0x1b2>
    pmm_manager->init_memmap(base, n);
ffffffffc0201106:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201108:	013a87b3          	add	a5,s5,s3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020110c:	767d                	lui	a2,0xfffff
ffffffffc020110e:	8ef1                	and	a3,a3,a2
ffffffffc0201110:	00279993          	slli	s3,a5,0x2
ffffffffc0201114:	40d586b3          	sub	a3,a1,a3
ffffffffc0201118:	99be                	add	s3,s3,a5
    pmm_manager->init_memmap(base, n);
ffffffffc020111a:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020111c:	00c6d913          	srli	s2,a3,0xc
ffffffffc0201120:	098e                	slli	s3,s3,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201122:	954e                	add	a0,a0,s3
ffffffffc0201124:	85ca                	mv	a1,s2
ffffffffc0201126:	9782                	jalr	a5
        cprintf("size_t n is %d",(mem_end - mem_begin) / PGSIZE);
ffffffffc0201128:	85ca                	mv	a1,s2
ffffffffc020112a:	00001517          	auipc	a0,0x1
ffffffffc020112e:	10650513          	addi	a0,a0,262 # ffffffffc0202230 <buddy_pmm_manager_+0x170>
ffffffffc0201132:	f85fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (PPN(pa) >= npage) {
ffffffffc0201136:	609c                	ld	a5,0(s1)
ffffffffc0201138:	06fafe63          	bleu	a5,s5,ffffffffc02011b4 <pmm_init+0x1b2>
        fppn=pa2page(mem_begin)-pages+nbase;
ffffffffc020113c:	00001797          	auipc	a5,0x1
ffffffffc0201140:	f1478793          	addi	a5,a5,-236 # ffffffffc0202050 <commands+0x7a8>
ffffffffc0201144:	639c                	ld	a5,0(a5)
ffffffffc0201146:	4039d993          	srai	s3,s3,0x3
ffffffffc020114a:	02f989b3          	mul	s3,s3,a5
ffffffffc020114e:	000807b7          	lui	a5,0x80
ffffffffc0201152:	99be                	add	s3,s3,a5
ffffffffc0201154:	00005797          	auipc	a5,0x5
ffffffffc0201158:	4337be23          	sd	s3,1084(a5) # ffffffffc0206590 <fppn>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020115c:	601c                	ld	a5,0(s0)
ffffffffc020115e:	7b9c                	ld	a5,48(a5)
ffffffffc0201160:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201162:	00001517          	auipc	a0,0x1
ffffffffc0201166:	0de50513          	addi	a0,a0,222 # ffffffffc0202240 <buddy_pmm_manager_+0x180>
ffffffffc020116a:	f4dfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020116e:	00004697          	auipc	a3,0x4
ffffffffc0201172:	e9268693          	addi	a3,a3,-366 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201176:	00005797          	auipc	a5,0x5
ffffffffc020117a:	2ad7b523          	sd	a3,682(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020117e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201182:	06f6e163          	bltu	a3,a5,ffffffffc02011e4 <pmm_init+0x1e2>
ffffffffc0201186:	000a3783          	ld	a5,0(s4)
}
ffffffffc020118a:	7442                	ld	s0,48(sp)
ffffffffc020118c:	70e2                	ld	ra,56(sp)
ffffffffc020118e:	74a2                	ld	s1,40(sp)
ffffffffc0201190:	7902                	ld	s2,32(sp)
ffffffffc0201192:	69e2                	ld	s3,24(sp)
ffffffffc0201194:	6a42                	ld	s4,16(sp)
ffffffffc0201196:	6aa2                	ld	s5,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201198:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc020119a:	8e9d                	sub	a3,a3,a5
ffffffffc020119c:	00005797          	auipc	a5,0x5
ffffffffc02011a0:	3ed7b623          	sd	a3,1004(a5) # ffffffffc0206588 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02011a4:	00001517          	auipc	a0,0x1
ffffffffc02011a8:	0bc50513          	addi	a0,a0,188 # ffffffffc0202260 <buddy_pmm_manager_+0x1a0>
ffffffffc02011ac:	8636                	mv	a2,a3
}
ffffffffc02011ae:	6121                	addi	sp,sp,64
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02011b0:	f07fe06f          	j	ffffffffc02000b6 <cprintf>
        panic("pa2page called with invalid pa");
ffffffffc02011b4:	00001617          	auipc	a2,0x1
ffffffffc02011b8:	04c60613          	addi	a2,a2,76 # ffffffffc0202200 <buddy_pmm_manager_+0x140>
ffffffffc02011bc:	06b00593          	li	a1,107
ffffffffc02011c0:	00001517          	auipc	a0,0x1
ffffffffc02011c4:	06050513          	addi	a0,a0,96 # ffffffffc0202220 <buddy_pmm_manager_+0x160>
ffffffffc02011c8:	9e4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011cc:	00001617          	auipc	a2,0x1
ffffffffc02011d0:	ffc60613          	addi	a2,a2,-4 # ffffffffc02021c8 <buddy_pmm_manager_+0x108>
ffffffffc02011d4:	07500593          	li	a1,117
ffffffffc02011d8:	00001517          	auipc	a0,0x1
ffffffffc02011dc:	01850513          	addi	a0,a0,24 # ffffffffc02021f0 <buddy_pmm_manager_+0x130>
ffffffffc02011e0:	9ccff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02011e4:	00001617          	auipc	a2,0x1
ffffffffc02011e8:	fe460613          	addi	a2,a2,-28 # ffffffffc02021c8 <buddy_pmm_manager_+0x108>
ffffffffc02011ec:	09200593          	li	a1,146
ffffffffc02011f0:	00001517          	auipc	a0,0x1
ffffffffc02011f4:	00050513          	mv	a0,a0
ffffffffc02011f8:	9b4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011fc <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02011fc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201200:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201202:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201206:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201208:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020120c:	f022                	sd	s0,32(sp)
ffffffffc020120e:	ec26                	sd	s1,24(sp)
ffffffffc0201210:	e84a                	sd	s2,16(sp)
ffffffffc0201212:	f406                	sd	ra,40(sp)
ffffffffc0201214:	e44e                	sd	s3,8(sp)
ffffffffc0201216:	84aa                	mv	s1,a0
ffffffffc0201218:	892e                	mv	s2,a1
ffffffffc020121a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020121e:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201220:	03067e63          	bleu	a6,a2,ffffffffc020125c <printnum+0x60>
ffffffffc0201224:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201226:	00805763          	blez	s0,ffffffffc0201234 <printnum+0x38>
ffffffffc020122a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020122c:	85ca                	mv	a1,s2
ffffffffc020122e:	854e                	mv	a0,s3
ffffffffc0201230:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201232:	fc65                	bnez	s0,ffffffffc020122a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201234:	1a02                	slli	s4,s4,0x20
ffffffffc0201236:	020a5a13          	srli	s4,s4,0x20
ffffffffc020123a:	00001797          	auipc	a5,0x1
ffffffffc020123e:	1f678793          	addi	a5,a5,502 # ffffffffc0202430 <error_string+0x38>
ffffffffc0201242:	9a3e                	add	s4,s4,a5
}
ffffffffc0201244:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201246:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020124a:	70a2                	ld	ra,40(sp)
ffffffffc020124c:	69a2                	ld	s3,8(sp)
ffffffffc020124e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201250:	85ca                	mv	a1,s2
ffffffffc0201252:	8326                	mv	t1,s1
}
ffffffffc0201254:	6942                	ld	s2,16(sp)
ffffffffc0201256:	64e2                	ld	s1,24(sp)
ffffffffc0201258:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020125a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020125c:	03065633          	divu	a2,a2,a6
ffffffffc0201260:	8722                	mv	a4,s0
ffffffffc0201262:	f9bff0ef          	jal	ra,ffffffffc02011fc <printnum>
ffffffffc0201266:	b7f9                	j	ffffffffc0201234 <printnum+0x38>

ffffffffc0201268 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201268:	7119                	addi	sp,sp,-128
ffffffffc020126a:	f4a6                	sd	s1,104(sp)
ffffffffc020126c:	f0ca                	sd	s2,96(sp)
ffffffffc020126e:	e8d2                	sd	s4,80(sp)
ffffffffc0201270:	e4d6                	sd	s5,72(sp)
ffffffffc0201272:	e0da                	sd	s6,64(sp)
ffffffffc0201274:	fc5e                	sd	s7,56(sp)
ffffffffc0201276:	f862                	sd	s8,48(sp)
ffffffffc0201278:	f06a                	sd	s10,32(sp)
ffffffffc020127a:	fc86                	sd	ra,120(sp)
ffffffffc020127c:	f8a2                	sd	s0,112(sp)
ffffffffc020127e:	ecce                	sd	s3,88(sp)
ffffffffc0201280:	f466                	sd	s9,40(sp)
ffffffffc0201282:	ec6e                	sd	s11,24(sp)
ffffffffc0201284:	892a                	mv	s2,a0
ffffffffc0201286:	84ae                	mv	s1,a1
ffffffffc0201288:	8d32                	mv	s10,a2
ffffffffc020128a:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020128c:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020128e:	00001a17          	auipc	s4,0x1
ffffffffc0201292:	012a0a13          	addi	s4,s4,18 # ffffffffc02022a0 <buddy_pmm_manager_+0x1e0>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201296:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020129a:	00001c17          	auipc	s8,0x1
ffffffffc020129e:	15ec0c13          	addi	s8,s8,350 # ffffffffc02023f8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012a2:	000d4503          	lbu	a0,0(s10)
ffffffffc02012a6:	02500793          	li	a5,37
ffffffffc02012aa:	001d0413          	addi	s0,s10,1
ffffffffc02012ae:	00f50e63          	beq	a0,a5,ffffffffc02012ca <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02012b2:	c521                	beqz	a0,ffffffffc02012fa <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012b4:	02500993          	li	s3,37
ffffffffc02012b8:	a011                	j	ffffffffc02012bc <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02012ba:	c121                	beqz	a0,ffffffffc02012fa <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02012bc:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012be:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02012c0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012c2:	fff44503          	lbu	a0,-1(s0)
ffffffffc02012c6:	ff351ae3          	bne	a0,s3,ffffffffc02012ba <vprintfmt+0x52>
ffffffffc02012ca:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02012ce:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02012d2:	4981                	li	s3,0
ffffffffc02012d4:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02012d6:	5cfd                	li	s9,-1
ffffffffc02012d8:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012da:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02012de:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012e0:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02012e4:	0ff6f693          	andi	a3,a3,255
ffffffffc02012e8:	00140d13          	addi	s10,s0,1
ffffffffc02012ec:	20d5e563          	bltu	a1,a3,ffffffffc02014f6 <vprintfmt+0x28e>
ffffffffc02012f0:	068a                	slli	a3,a3,0x2
ffffffffc02012f2:	96d2                	add	a3,a3,s4
ffffffffc02012f4:	4294                	lw	a3,0(a3)
ffffffffc02012f6:	96d2                	add	a3,a3,s4
ffffffffc02012f8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02012fa:	70e6                	ld	ra,120(sp)
ffffffffc02012fc:	7446                	ld	s0,112(sp)
ffffffffc02012fe:	74a6                	ld	s1,104(sp)
ffffffffc0201300:	7906                	ld	s2,96(sp)
ffffffffc0201302:	69e6                	ld	s3,88(sp)
ffffffffc0201304:	6a46                	ld	s4,80(sp)
ffffffffc0201306:	6aa6                	ld	s5,72(sp)
ffffffffc0201308:	6b06                	ld	s6,64(sp)
ffffffffc020130a:	7be2                	ld	s7,56(sp)
ffffffffc020130c:	7c42                	ld	s8,48(sp)
ffffffffc020130e:	7ca2                	ld	s9,40(sp)
ffffffffc0201310:	7d02                	ld	s10,32(sp)
ffffffffc0201312:	6de2                	ld	s11,24(sp)
ffffffffc0201314:	6109                	addi	sp,sp,128
ffffffffc0201316:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201318:	4705                	li	a4,1
ffffffffc020131a:	008a8593          	addi	a1,s5,8
ffffffffc020131e:	01074463          	blt	a4,a6,ffffffffc0201326 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201322:	26080363          	beqz	a6,ffffffffc0201588 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201326:	000ab603          	ld	a2,0(s5)
ffffffffc020132a:	46c1                	li	a3,16
ffffffffc020132c:	8aae                	mv	s5,a1
ffffffffc020132e:	a06d                	j	ffffffffc02013d8 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201330:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201334:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201336:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201338:	b765                	j	ffffffffc02012e0 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc020133a:	000aa503          	lw	a0,0(s5)
ffffffffc020133e:	85a6                	mv	a1,s1
ffffffffc0201340:	0aa1                	addi	s5,s5,8
ffffffffc0201342:	9902                	jalr	s2
            break;
ffffffffc0201344:	bfb9                	j	ffffffffc02012a2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201346:	4705                	li	a4,1
ffffffffc0201348:	008a8993          	addi	s3,s5,8
ffffffffc020134c:	01074463          	blt	a4,a6,ffffffffc0201354 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201350:	22080463          	beqz	a6,ffffffffc0201578 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201354:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201358:	24044463          	bltz	s0,ffffffffc02015a0 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020135c:	8622                	mv	a2,s0
ffffffffc020135e:	8ace                	mv	s5,s3
ffffffffc0201360:	46a9                	li	a3,10
ffffffffc0201362:	a89d                	j	ffffffffc02013d8 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0201364:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201368:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020136a:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc020136c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201370:	8fb5                	xor	a5,a5,a3
ffffffffc0201372:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201376:	1ad74363          	blt	a4,a3,ffffffffc020151c <vprintfmt+0x2b4>
ffffffffc020137a:	00369793          	slli	a5,a3,0x3
ffffffffc020137e:	97e2                	add	a5,a5,s8
ffffffffc0201380:	639c                	ld	a5,0(a5)
ffffffffc0201382:	18078d63          	beqz	a5,ffffffffc020151c <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201386:	86be                	mv	a3,a5
ffffffffc0201388:	00001617          	auipc	a2,0x1
ffffffffc020138c:	15860613          	addi	a2,a2,344 # ffffffffc02024e0 <error_string+0xe8>
ffffffffc0201390:	85a6                	mv	a1,s1
ffffffffc0201392:	854a                	mv	a0,s2
ffffffffc0201394:	240000ef          	jal	ra,ffffffffc02015d4 <printfmt>
ffffffffc0201398:	b729                	j	ffffffffc02012a2 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020139a:	00144603          	lbu	a2,1(s0)
ffffffffc020139e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013a0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02013a2:	bf3d                	j	ffffffffc02012e0 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02013a4:	4705                	li	a4,1
ffffffffc02013a6:	008a8593          	addi	a1,s5,8
ffffffffc02013aa:	01074463          	blt	a4,a6,ffffffffc02013b2 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02013ae:	1e080263          	beqz	a6,ffffffffc0201592 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02013b2:	000ab603          	ld	a2,0(s5)
ffffffffc02013b6:	46a1                	li	a3,8
ffffffffc02013b8:	8aae                	mv	s5,a1
ffffffffc02013ba:	a839                	j	ffffffffc02013d8 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02013bc:	03000513          	li	a0,48
ffffffffc02013c0:	85a6                	mv	a1,s1
ffffffffc02013c2:	e03e                	sd	a5,0(sp)
ffffffffc02013c4:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02013c6:	85a6                	mv	a1,s1
ffffffffc02013c8:	07800513          	li	a0,120
ffffffffc02013cc:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02013ce:	0aa1                	addi	s5,s5,8
ffffffffc02013d0:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02013d4:	6782                	ld	a5,0(sp)
ffffffffc02013d6:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02013d8:	876e                	mv	a4,s11
ffffffffc02013da:	85a6                	mv	a1,s1
ffffffffc02013dc:	854a                	mv	a0,s2
ffffffffc02013de:	e1fff0ef          	jal	ra,ffffffffc02011fc <printnum>
            break;
ffffffffc02013e2:	b5c1                	j	ffffffffc02012a2 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02013e4:	000ab603          	ld	a2,0(s5)
ffffffffc02013e8:	0aa1                	addi	s5,s5,8
ffffffffc02013ea:	1c060663          	beqz	a2,ffffffffc02015b6 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02013ee:	00160413          	addi	s0,a2,1
ffffffffc02013f2:	17b05c63          	blez	s11,ffffffffc020156a <vprintfmt+0x302>
ffffffffc02013f6:	02d00593          	li	a1,45
ffffffffc02013fa:	14b79263          	bne	a5,a1,ffffffffc020153e <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013fe:	00064783          	lbu	a5,0(a2)
ffffffffc0201402:	0007851b          	sext.w	a0,a5
ffffffffc0201406:	c905                	beqz	a0,ffffffffc0201436 <vprintfmt+0x1ce>
ffffffffc0201408:	000cc563          	bltz	s9,ffffffffc0201412 <vprintfmt+0x1aa>
ffffffffc020140c:	3cfd                	addiw	s9,s9,-1
ffffffffc020140e:	036c8263          	beq	s9,s6,ffffffffc0201432 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201412:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201414:	18098463          	beqz	s3,ffffffffc020159c <vprintfmt+0x334>
ffffffffc0201418:	3781                	addiw	a5,a5,-32
ffffffffc020141a:	18fbf163          	bleu	a5,s7,ffffffffc020159c <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020141e:	03f00513          	li	a0,63
ffffffffc0201422:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201424:	0405                	addi	s0,s0,1
ffffffffc0201426:	fff44783          	lbu	a5,-1(s0)
ffffffffc020142a:	3dfd                	addiw	s11,s11,-1
ffffffffc020142c:	0007851b          	sext.w	a0,a5
ffffffffc0201430:	fd61                	bnez	a0,ffffffffc0201408 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201432:	e7b058e3          	blez	s11,ffffffffc02012a2 <vprintfmt+0x3a>
ffffffffc0201436:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201438:	85a6                	mv	a1,s1
ffffffffc020143a:	02000513          	li	a0,32
ffffffffc020143e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201440:	e60d81e3          	beqz	s11,ffffffffc02012a2 <vprintfmt+0x3a>
ffffffffc0201444:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201446:	85a6                	mv	a1,s1
ffffffffc0201448:	02000513          	li	a0,32
ffffffffc020144c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020144e:	fe0d94e3          	bnez	s11,ffffffffc0201436 <vprintfmt+0x1ce>
ffffffffc0201452:	bd81                	j	ffffffffc02012a2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201454:	4705                	li	a4,1
ffffffffc0201456:	008a8593          	addi	a1,s5,8
ffffffffc020145a:	01074463          	blt	a4,a6,ffffffffc0201462 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020145e:	12080063          	beqz	a6,ffffffffc020157e <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201462:	000ab603          	ld	a2,0(s5)
ffffffffc0201466:	46a9                	li	a3,10
ffffffffc0201468:	8aae                	mv	s5,a1
ffffffffc020146a:	b7bd                	j	ffffffffc02013d8 <vprintfmt+0x170>
ffffffffc020146c:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201470:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201474:	846a                	mv	s0,s10
ffffffffc0201476:	b5ad                	j	ffffffffc02012e0 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201478:	85a6                	mv	a1,s1
ffffffffc020147a:	02500513          	li	a0,37
ffffffffc020147e:	9902                	jalr	s2
            break;
ffffffffc0201480:	b50d                	j	ffffffffc02012a2 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201482:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201486:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020148a:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020148c:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020148e:	e40dd9e3          	bgez	s11,ffffffffc02012e0 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201492:	8de6                	mv	s11,s9
ffffffffc0201494:	5cfd                	li	s9,-1
ffffffffc0201496:	b5a9                	j	ffffffffc02012e0 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201498:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020149c:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014a0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014a2:	bd3d                	j	ffffffffc02012e0 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02014a4:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02014a8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014ac:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02014ae:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02014b2:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02014b6:	fcd56ce3          	bltu	a0,a3,ffffffffc020148e <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02014ba:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02014bc:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02014c0:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02014c4:	0196873b          	addw	a4,a3,s9
ffffffffc02014c8:	0017171b          	slliw	a4,a4,0x1
ffffffffc02014cc:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02014d0:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02014d4:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02014d8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02014dc:	fcd57fe3          	bleu	a3,a0,ffffffffc02014ba <vprintfmt+0x252>
ffffffffc02014e0:	b77d                	j	ffffffffc020148e <vprintfmt+0x226>
            if (width < 0)
ffffffffc02014e2:	fffdc693          	not	a3,s11
ffffffffc02014e6:	96fd                	srai	a3,a3,0x3f
ffffffffc02014e8:	00ddfdb3          	and	s11,s11,a3
ffffffffc02014ec:	00144603          	lbu	a2,1(s0)
ffffffffc02014f0:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014f2:	846a                	mv	s0,s10
ffffffffc02014f4:	b3f5                	j	ffffffffc02012e0 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02014f6:	85a6                	mv	a1,s1
ffffffffc02014f8:	02500513          	li	a0,37
ffffffffc02014fc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02014fe:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201502:	02500793          	li	a5,37
ffffffffc0201506:	8d22                	mv	s10,s0
ffffffffc0201508:	d8f70de3          	beq	a4,a5,ffffffffc02012a2 <vprintfmt+0x3a>
ffffffffc020150c:	02500713          	li	a4,37
ffffffffc0201510:	1d7d                	addi	s10,s10,-1
ffffffffc0201512:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201516:	fee79de3          	bne	a5,a4,ffffffffc0201510 <vprintfmt+0x2a8>
ffffffffc020151a:	b361                	j	ffffffffc02012a2 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020151c:	00001617          	auipc	a2,0x1
ffffffffc0201520:	fb460613          	addi	a2,a2,-76 # ffffffffc02024d0 <error_string+0xd8>
ffffffffc0201524:	85a6                	mv	a1,s1
ffffffffc0201526:	854a                	mv	a0,s2
ffffffffc0201528:	0ac000ef          	jal	ra,ffffffffc02015d4 <printfmt>
ffffffffc020152c:	bb9d                	j	ffffffffc02012a2 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020152e:	00001617          	auipc	a2,0x1
ffffffffc0201532:	f9a60613          	addi	a2,a2,-102 # ffffffffc02024c8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201536:	00001417          	auipc	s0,0x1
ffffffffc020153a:	f9340413          	addi	s0,s0,-109 # ffffffffc02024c9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020153e:	8532                	mv	a0,a2
ffffffffc0201540:	85e6                	mv	a1,s9
ffffffffc0201542:	e032                	sd	a2,0(sp)
ffffffffc0201544:	e43e                	sd	a5,8(sp)
ffffffffc0201546:	1c2000ef          	jal	ra,ffffffffc0201708 <strnlen>
ffffffffc020154a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020154e:	6602                	ld	a2,0(sp)
ffffffffc0201550:	01b05d63          	blez	s11,ffffffffc020156a <vprintfmt+0x302>
ffffffffc0201554:	67a2                	ld	a5,8(sp)
ffffffffc0201556:	2781                	sext.w	a5,a5
ffffffffc0201558:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020155a:	6522                	ld	a0,8(sp)
ffffffffc020155c:	85a6                	mv	a1,s1
ffffffffc020155e:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201560:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201562:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201564:	6602                	ld	a2,0(sp)
ffffffffc0201566:	fe0d9ae3          	bnez	s11,ffffffffc020155a <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020156a:	00064783          	lbu	a5,0(a2)
ffffffffc020156e:	0007851b          	sext.w	a0,a5
ffffffffc0201572:	e8051be3          	bnez	a0,ffffffffc0201408 <vprintfmt+0x1a0>
ffffffffc0201576:	b335                	j	ffffffffc02012a2 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201578:	000aa403          	lw	s0,0(s5)
ffffffffc020157c:	bbf1                	j	ffffffffc0201358 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020157e:	000ae603          	lwu	a2,0(s5)
ffffffffc0201582:	46a9                	li	a3,10
ffffffffc0201584:	8aae                	mv	s5,a1
ffffffffc0201586:	bd89                	j	ffffffffc02013d8 <vprintfmt+0x170>
ffffffffc0201588:	000ae603          	lwu	a2,0(s5)
ffffffffc020158c:	46c1                	li	a3,16
ffffffffc020158e:	8aae                	mv	s5,a1
ffffffffc0201590:	b5a1                	j	ffffffffc02013d8 <vprintfmt+0x170>
ffffffffc0201592:	000ae603          	lwu	a2,0(s5)
ffffffffc0201596:	46a1                	li	a3,8
ffffffffc0201598:	8aae                	mv	s5,a1
ffffffffc020159a:	bd3d                	j	ffffffffc02013d8 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020159c:	9902                	jalr	s2
ffffffffc020159e:	b559                	j	ffffffffc0201424 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02015a0:	85a6                	mv	a1,s1
ffffffffc02015a2:	02d00513          	li	a0,45
ffffffffc02015a6:	e03e                	sd	a5,0(sp)
ffffffffc02015a8:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02015aa:	8ace                	mv	s5,s3
ffffffffc02015ac:	40800633          	neg	a2,s0
ffffffffc02015b0:	46a9                	li	a3,10
ffffffffc02015b2:	6782                	ld	a5,0(sp)
ffffffffc02015b4:	b515                	j	ffffffffc02013d8 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02015b6:	01b05663          	blez	s11,ffffffffc02015c2 <vprintfmt+0x35a>
ffffffffc02015ba:	02d00693          	li	a3,45
ffffffffc02015be:	f6d798e3          	bne	a5,a3,ffffffffc020152e <vprintfmt+0x2c6>
ffffffffc02015c2:	00001417          	auipc	s0,0x1
ffffffffc02015c6:	f0740413          	addi	s0,s0,-249 # ffffffffc02024c9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015ca:	02800513          	li	a0,40
ffffffffc02015ce:	02800793          	li	a5,40
ffffffffc02015d2:	bd1d                	j	ffffffffc0201408 <vprintfmt+0x1a0>

ffffffffc02015d4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015d4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02015d6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015da:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02015dc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015de:	ec06                	sd	ra,24(sp)
ffffffffc02015e0:	f83a                	sd	a4,48(sp)
ffffffffc02015e2:	fc3e                	sd	a5,56(sp)
ffffffffc02015e4:	e0c2                	sd	a6,64(sp)
ffffffffc02015e6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02015e8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02015ea:	c7fff0ef          	jal	ra,ffffffffc0201268 <vprintfmt>
}
ffffffffc02015ee:	60e2                	ld	ra,24(sp)
ffffffffc02015f0:	6161                	addi	sp,sp,80
ffffffffc02015f2:	8082                	ret

ffffffffc02015f4 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02015f4:	715d                	addi	sp,sp,-80
ffffffffc02015f6:	e486                	sd	ra,72(sp)
ffffffffc02015f8:	e0a2                	sd	s0,64(sp)
ffffffffc02015fa:	fc26                	sd	s1,56(sp)
ffffffffc02015fc:	f84a                	sd	s2,48(sp)
ffffffffc02015fe:	f44e                	sd	s3,40(sp)
ffffffffc0201600:	f052                	sd	s4,32(sp)
ffffffffc0201602:	ec56                	sd	s5,24(sp)
ffffffffc0201604:	e85a                	sd	s6,16(sp)
ffffffffc0201606:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201608:	c901                	beqz	a0,ffffffffc0201618 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020160a:	85aa                	mv	a1,a0
ffffffffc020160c:	00001517          	auipc	a0,0x1
ffffffffc0201610:	ed450513          	addi	a0,a0,-300 # ffffffffc02024e0 <error_string+0xe8>
ffffffffc0201614:	aa3fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201618:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020161a:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020161c:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020161e:	4aa9                	li	s5,10
ffffffffc0201620:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201622:	00005b97          	auipc	s7,0x5
ffffffffc0201626:	9eeb8b93          	addi	s7,s7,-1554 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020162a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020162e:	b01fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201632:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201634:	00054b63          	bltz	a0,ffffffffc020164a <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201638:	00a95b63          	ble	a0,s2,ffffffffc020164e <readline+0x5a>
ffffffffc020163c:	029a5463          	ble	s1,s4,ffffffffc0201664 <readline+0x70>
        c = getchar();
ffffffffc0201640:	aeffe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201644:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201646:	fe0559e3          	bgez	a0,ffffffffc0201638 <readline+0x44>
            return NULL;
ffffffffc020164a:	4501                	li	a0,0
ffffffffc020164c:	a099                	j	ffffffffc0201692 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc020164e:	03341463          	bne	s0,s3,ffffffffc0201676 <readline+0x82>
ffffffffc0201652:	e8b9                	bnez	s1,ffffffffc02016a8 <readline+0xb4>
        c = getchar();
ffffffffc0201654:	adbfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201658:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020165a:	fe0548e3          	bltz	a0,ffffffffc020164a <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020165e:	fea958e3          	ble	a0,s2,ffffffffc020164e <readline+0x5a>
ffffffffc0201662:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201664:	8522                	mv	a0,s0
ffffffffc0201666:	a85fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc020166a:	009b87b3          	add	a5,s7,s1
ffffffffc020166e:	00878023          	sb	s0,0(a5)
ffffffffc0201672:	2485                	addiw	s1,s1,1
ffffffffc0201674:	bf6d                	j	ffffffffc020162e <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201676:	01540463          	beq	s0,s5,ffffffffc020167e <readline+0x8a>
ffffffffc020167a:	fb641ae3          	bne	s0,s6,ffffffffc020162e <readline+0x3a>
            cputchar(c);
ffffffffc020167e:	8522                	mv	a0,s0
ffffffffc0201680:	a6bfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201684:	00005517          	auipc	a0,0x5
ffffffffc0201688:	98c50513          	addi	a0,a0,-1652 # ffffffffc0206010 <edata>
ffffffffc020168c:	94aa                	add	s1,s1,a0
ffffffffc020168e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201692:	60a6                	ld	ra,72(sp)
ffffffffc0201694:	6406                	ld	s0,64(sp)
ffffffffc0201696:	74e2                	ld	s1,56(sp)
ffffffffc0201698:	7942                	ld	s2,48(sp)
ffffffffc020169a:	79a2                	ld	s3,40(sp)
ffffffffc020169c:	7a02                	ld	s4,32(sp)
ffffffffc020169e:	6ae2                	ld	s5,24(sp)
ffffffffc02016a0:	6b42                	ld	s6,16(sp)
ffffffffc02016a2:	6ba2                	ld	s7,8(sp)
ffffffffc02016a4:	6161                	addi	sp,sp,80
ffffffffc02016a6:	8082                	ret
            cputchar(c);
ffffffffc02016a8:	4521                	li	a0,8
ffffffffc02016aa:	a41fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc02016ae:	34fd                	addiw	s1,s1,-1
ffffffffc02016b0:	bfbd                	j	ffffffffc020162e <readline+0x3a>

ffffffffc02016b2 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc02016b2:	00005797          	auipc	a5,0x5
ffffffffc02016b6:	95678793          	addi	a5,a5,-1706 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc02016ba:	6398                	ld	a4,0(a5)
ffffffffc02016bc:	4781                	li	a5,0
ffffffffc02016be:	88ba                	mv	a7,a4
ffffffffc02016c0:	852a                	mv	a0,a0
ffffffffc02016c2:	85be                	mv	a1,a5
ffffffffc02016c4:	863e                	mv	a2,a5
ffffffffc02016c6:	00000073          	ecall
ffffffffc02016ca:	87aa                	mv	a5,a0
}
ffffffffc02016cc:	8082                	ret

ffffffffc02016ce <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc02016ce:	00005797          	auipc	a5,0x5
ffffffffc02016d2:	d5a78793          	addi	a5,a5,-678 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc02016d6:	6398                	ld	a4,0(a5)
ffffffffc02016d8:	4781                	li	a5,0
ffffffffc02016da:	88ba                	mv	a7,a4
ffffffffc02016dc:	852a                	mv	a0,a0
ffffffffc02016de:	85be                	mv	a1,a5
ffffffffc02016e0:	863e                	mv	a2,a5
ffffffffc02016e2:	00000073          	ecall
ffffffffc02016e6:	87aa                	mv	a5,a0
}
ffffffffc02016e8:	8082                	ret

ffffffffc02016ea <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02016ea:	00005797          	auipc	a5,0x5
ffffffffc02016ee:	91678793          	addi	a5,a5,-1770 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc02016f2:	639c                	ld	a5,0(a5)
ffffffffc02016f4:	4501                	li	a0,0
ffffffffc02016f6:	88be                	mv	a7,a5
ffffffffc02016f8:	852a                	mv	a0,a0
ffffffffc02016fa:	85aa                	mv	a1,a0
ffffffffc02016fc:	862a                	mv	a2,a0
ffffffffc02016fe:	00000073          	ecall
ffffffffc0201702:	852a                	mv	a0,a0
ffffffffc0201704:	2501                	sext.w	a0,a0
ffffffffc0201706:	8082                	ret

ffffffffc0201708 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201708:	c185                	beqz	a1,ffffffffc0201728 <strnlen+0x20>
ffffffffc020170a:	00054783          	lbu	a5,0(a0)
ffffffffc020170e:	cf89                	beqz	a5,ffffffffc0201728 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201710:	4781                	li	a5,0
ffffffffc0201712:	a021                	j	ffffffffc020171a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201714:	00074703          	lbu	a4,0(a4)
ffffffffc0201718:	c711                	beqz	a4,ffffffffc0201724 <strnlen+0x1c>
        cnt ++;
ffffffffc020171a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020171c:	00f50733          	add	a4,a0,a5
ffffffffc0201720:	fef59ae3          	bne	a1,a5,ffffffffc0201714 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201724:	853e                	mv	a0,a5
ffffffffc0201726:	8082                	ret
    size_t cnt = 0;
ffffffffc0201728:	4781                	li	a5,0
}
ffffffffc020172a:	853e                	mv	a0,a5
ffffffffc020172c:	8082                	ret

ffffffffc020172e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020172e:	00054783          	lbu	a5,0(a0)
ffffffffc0201732:	0005c703          	lbu	a4,0(a1)
ffffffffc0201736:	cb91                	beqz	a5,ffffffffc020174a <strcmp+0x1c>
ffffffffc0201738:	00e79c63          	bne	a5,a4,ffffffffc0201750 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020173c:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020173e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201742:	0585                	addi	a1,a1,1
ffffffffc0201744:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201748:	fbe5                	bnez	a5,ffffffffc0201738 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020174a:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020174c:	9d19                	subw	a0,a0,a4
ffffffffc020174e:	8082                	ret
ffffffffc0201750:	0007851b          	sext.w	a0,a5
ffffffffc0201754:	9d19                	subw	a0,a0,a4
ffffffffc0201756:	8082                	ret

ffffffffc0201758 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201758:	00054783          	lbu	a5,0(a0)
ffffffffc020175c:	cb91                	beqz	a5,ffffffffc0201770 <strchr+0x18>
        if (*s == c) {
ffffffffc020175e:	00b79563          	bne	a5,a1,ffffffffc0201768 <strchr+0x10>
ffffffffc0201762:	a809                	j	ffffffffc0201774 <strchr+0x1c>
ffffffffc0201764:	00b78763          	beq	a5,a1,ffffffffc0201772 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201768:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020176a:	00054783          	lbu	a5,0(a0)
ffffffffc020176e:	fbfd                	bnez	a5,ffffffffc0201764 <strchr+0xc>
    }
    return NULL;
ffffffffc0201770:	4501                	li	a0,0
}
ffffffffc0201772:	8082                	ret
ffffffffc0201774:	8082                	ret

ffffffffc0201776 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201776:	ca01                	beqz	a2,ffffffffc0201786 <memset+0x10>
ffffffffc0201778:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020177a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020177c:	0785                	addi	a5,a5,1
ffffffffc020177e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201782:	fec79de3          	bne	a5,a2,ffffffffc020177c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201786:	8082                	ret
