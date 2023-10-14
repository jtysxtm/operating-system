
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
ffffffffc020004e:	067010ef          	jal	ra,ffffffffc02018b4 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	87250513          	addi	a0,a0,-1934 # ffffffffc02018c8 <etext+0x2>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	0d6010ef          	jal	ra,ffffffffc0201140 <pmm_init>

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
ffffffffc02000aa:	2fc010ef          	jal	ra,ffffffffc02013a6 <vprintfmt>
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
ffffffffc02000de:	2c8010ef          	jal	ra,ffffffffc02013a6 <vprintfmt>
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
ffffffffc0200144:	7d850513          	addi	a0,a0,2008 # ffffffffc0201918 <etext+0x52>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	7e250513          	addi	a0,a0,2018 # ffffffffc0201938 <etext+0x72>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	76458593          	addi	a1,a1,1892 # ffffffffc02018c6 <etext>
ffffffffc020016a:	00001517          	auipc	a0,0x1
ffffffffc020016e:	7ee50513          	addi	a0,a0,2030 # ffffffffc0201958 <etext+0x92>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	7fa50513          	addi	a0,a0,2042 # ffffffffc0201978 <etext+0xb2>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	3e658593          	addi	a1,a1,998 # ffffffffc0206570 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	80650513          	addi	a0,a0,-2042 # ffffffffc0201998 <etext+0xd2>
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
ffffffffc02001c0:	00001517          	auipc	a0,0x1
ffffffffc02001c4:	7f850513          	addi	a0,a0,2040 # ffffffffc02019b8 <etext+0xf2>
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
ffffffffc02001d4:	71860613          	addi	a2,a2,1816 # ffffffffc02018e8 <etext+0x22>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	72450513          	addi	a0,a0,1828 # ffffffffc0201900 <etext+0x3a>
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
ffffffffc02001f0:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0201ac8 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	8f458593          	addi	a1,a1,-1804 # ffffffffc0201ae8 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	8f450513          	addi	a0,a0,-1804 # ffffffffc0201af0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	8f660613          	addi	a2,a2,-1802 # ffffffffc0201b00 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	91658593          	addi	a1,a1,-1770 # ffffffffc0201b28 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	8d650513          	addi	a0,a0,-1834 # ffffffffc0201af0 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	91260613          	addi	a2,a2,-1774 # ffffffffc0201b38 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	92a58593          	addi	a1,a1,-1750 # ffffffffc0201b58 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0201af0 <commands+0x108>
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
ffffffffc0200274:	7c050513          	addi	a0,a0,1984 # ffffffffc0201a30 <commands+0x48>
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
ffffffffc0200296:	7c650513          	addi	a0,a0,1990 # ffffffffc0201a58 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	740c8c93          	addi	s9,s9,1856 # ffffffffc02019e8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	7d098993          	addi	s3,s3,2000 # ffffffffc0201a80 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	7d090913          	addi	s2,s2,2000 # ffffffffc0201a88 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	7ceb0b13          	addi	s6,s6,1998 # ffffffffc0201a90 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	81ea8a93          	addi	s5,s5,-2018 # ffffffffc0201ae8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	45c010ef          	jal	ra,ffffffffc0201732 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	5ae010ef          	jal	ra,ffffffffc0201896 <strchr>
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
ffffffffc0200302:	6ead0d13          	addi	s10,s10,1770 # ffffffffc02019e8 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	560010ef          	jal	ra,ffffffffc020186c <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	54c010ef          	jal	ra,ffffffffc020186c <strcmp>
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
ffffffffc0200386:	510010ef          	jal	ra,ffffffffc0201896 <strchr>
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
ffffffffc02003a2:	71250513          	addi	a0,a0,1810 # ffffffffc0201ab0 <commands+0xc8>
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
ffffffffc02003e2:	78a50513          	addi	a0,a0,1930 # ffffffffc0201b68 <commands+0x180>
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
ffffffffc02003f8:	5ec50513          	addi	a0,a0,1516 # ffffffffc02019e0 <etext+0x11a>
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
ffffffffc0200424:	3e8010ef          	jal	ra,ffffffffc020180c <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	75650513          	addi	a0,a0,1878 # ffffffffc0201b88 <commands+0x1a0>
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
ffffffffc020044c:	3c00106f          	j	ffffffffc020180c <sbi_set_timer>

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
ffffffffc0200456:	39a0106f          	j	ffffffffc02017f0 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	3ce0106f          	j	ffffffffc0201828 <sbi_console_getchar>

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
ffffffffc0200488:	81c50513          	addi	a0,a0,-2020 # ffffffffc0201ca0 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	82450513          	addi	a0,a0,-2012 # ffffffffc0201cb8 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	82e50513          	addi	a0,a0,-2002 # ffffffffc0201cd0 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	83850513          	addi	a0,a0,-1992 # ffffffffc0201ce8 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	84250513          	addi	a0,a0,-1982 # ffffffffc0201d00 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	84c50513          	addi	a0,a0,-1972 # ffffffffc0201d18 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	85650513          	addi	a0,a0,-1962 # ffffffffc0201d30 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	86050513          	addi	a0,a0,-1952 # ffffffffc0201d48 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	86a50513          	addi	a0,a0,-1942 # ffffffffc0201d60 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	87450513          	addi	a0,a0,-1932 # ffffffffc0201d78 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	87e50513          	addi	a0,a0,-1922 # ffffffffc0201d90 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	88850513          	addi	a0,a0,-1912 # ffffffffc0201da8 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	89250513          	addi	a0,a0,-1902 # ffffffffc0201dc0 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	89c50513          	addi	a0,a0,-1892 # ffffffffc0201dd8 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	8a650513          	addi	a0,a0,-1882 # ffffffffc0201df0 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	8b050513          	addi	a0,a0,-1872 # ffffffffc0201e08 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0201e20 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	8c450513          	addi	a0,a0,-1852 # ffffffffc0201e38 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0201e50 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	8d850513          	addi	a0,a0,-1832 # ffffffffc0201e68 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201e80 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0201e98 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	8f650513          	addi	a0,a0,-1802 # ffffffffc0201eb0 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	90050513          	addi	a0,a0,-1792 # ffffffffc0201ec8 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	90a50513          	addi	a0,a0,-1782 # ffffffffc0201ee0 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	91450513          	addi	a0,a0,-1772 # ffffffffc0201ef8 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	91e50513          	addi	a0,a0,-1762 # ffffffffc0201f10 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	92850513          	addi	a0,a0,-1752 # ffffffffc0201f28 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	93250513          	addi	a0,a0,-1742 # ffffffffc0201f40 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	93c50513          	addi	a0,a0,-1732 # ffffffffc0201f58 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	94650513          	addi	a0,a0,-1722 # ffffffffc0201f70 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	94c50513          	addi	a0,a0,-1716 # ffffffffc0201f88 <commands+0x5a0>
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
ffffffffc0200656:	94e50513          	addi	a0,a0,-1714 # ffffffffc0201fa0 <commands+0x5b8>
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
ffffffffc020066e:	94e50513          	addi	a0,a0,-1714 # ffffffffc0201fb8 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	95650513          	addi	a0,a0,-1706 # ffffffffc0201fd0 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	95e50513          	addi	a0,a0,-1698 # ffffffffc0201fe8 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	96250513          	addi	a0,a0,-1694 # ffffffffc0202000 <commands+0x618>
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
ffffffffc02006c0:	4e870713          	addi	a4,a4,1256 # ffffffffc0201ba4 <commands+0x1bc>
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
ffffffffc02006d2:	56a50513          	addi	a0,a0,1386 # ffffffffc0201c38 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	53e50513          	addi	a0,a0,1342 # ffffffffc0201c18 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	4f250513          	addi	a0,a0,1266 # ffffffffc0201bd8 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	56650513          	addi	a0,a0,1382 # ffffffffc0201c58 <commands+0x270>
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
ffffffffc020072e:	55650513          	addi	a0,a0,1366 # ffffffffc0201c80 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	4c250513          	addi	a0,a0,1218 # ffffffffc0201bf8 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	52450513          	addi	a0,a0,1316 # ffffffffc0201c70 <commands+0x288>
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
ffffffffc020085a:	a7a50513          	addi	a0,a0,-1414 # ffffffffc02022d0 <buddy_pmm_manager_+0x38>
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
ffffffffc0200882:	a72b8b93          	addi	s7,s7,-1422 # ffffffffc02022f0 <buddy_pmm_manager_+0x58>
            cprintf("%d ", 1 << (p->property));
ffffffffc0200886:	4985                	li	s3,1
ffffffffc0200888:	00002917          	auipc	s2,0x2
ffffffffc020088c:	a7890913          	addi	s2,s2,-1416 # ffffffffc0202300 <buddy_pmm_manager_+0x68>
        cprintf("\n");
ffffffffc0200890:	00001b17          	auipc	s6,0x1
ffffffffc0200894:	150b0b13          	addi	s6,s6,336 # ffffffffc02019e0 <etext+0x11a>
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
ffffffffc02008e0:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0202308 <buddy_pmm_manager_+0x70>
}
ffffffffc02008e4:	6161                	addi	sp,sp,80
    cprintf("---------------------------\n");
ffffffffc02008e6:	fd0ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02008ea <buddy_free_pages>:
{
ffffffffc02008ea:	7179                	addi	sp,sp,-48
ffffffffc02008ec:	f406                	sd	ra,40(sp)
ffffffffc02008ee:	f022                	sd	s0,32(sp)
ffffffffc02008f0:	ec26                	sd	s1,24(sp)
ffffffffc02008f2:	e84a                	sd	s2,16(sp)
ffffffffc02008f4:	e44e                	sd	s3,8(sp)
    assert(n>0);
ffffffffc02008f6:	14058a63          	beqz	a1,ffffffffc0200a4a <buddy_free_pages+0x160>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008fa:	00006e17          	auipc	t3,0x6
ffffffffc02008fe:	c6ee0e13          	addi	t3,t3,-914 # ffffffffc0206568 <pages>
ffffffffc0200902:	000e3783          	ld	a5,0(t3)
ffffffffc0200906:	00002717          	auipc	a4,0x2
ffffffffc020090a:	94270713          	addi	a4,a4,-1726 # ffffffffc0202248 <commands+0x860>
ffffffffc020090e:	00073303          	ld	t1,0(a4)
ffffffffc0200912:	40f507b3          	sub	a5,a0,a5
ffffffffc0200916:	878d                	srai	a5,a5,0x3
ffffffffc0200918:	026787b3          	mul	a5,a5,t1
ffffffffc020091c:	00002717          	auipc	a4,0x2
ffffffffc0200920:	da470713          	addi	a4,a4,-604 # ffffffffc02026c0 <nbase>
ffffffffc0200924:	00073883          	ld	a7,0(a4)
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200928:	00006e97          	auipc	t4,0x6
ffffffffc020092c:	c28e8e93          	addi	t4,t4,-984 # ffffffffc0206550 <fppn>
    nr_free+=1<<base->property;  
ffffffffc0200930:	01052f03          	lw	t5,16(a0)
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc0200934:	000eb683          	ld	a3,0(t4)
    nr_free+=1<<base->property;  
ffffffffc0200938:	4605                	li	a2,1
ffffffffc020093a:	01e615bb          	sllw	a1,a2,t5
ffffffffc020093e:	00006817          	auipc	a6,0x6
ffffffffc0200942:	afa80813          	addi	a6,a6,-1286 # ffffffffc0206438 <free_buddy>
ffffffffc0200946:	862e                	mv	a2,a1
ffffffffc0200948:	97c6                	add	a5,a5,a7
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc020094a:	40d78733          	sub	a4,a5,a3
ffffffffc020094e:	8f2d                	xor	a4,a4,a1
    return page+(ppn-page2ppn(page));
ffffffffc0200950:	40f687b3          	sub	a5,a3,a5
ffffffffc0200954:	97ba                	add	a5,a5,a4
    __list_add(elm, listelm, listelm->next);
ffffffffc0200956:	020f1713          	slli	a4,t5,0x20
    nr_free+=1<<base->property;  
ffffffffc020095a:	10882583          	lw	a1,264(a6)
    return page+(ppn-page2ppn(page));
ffffffffc020095e:	00279693          	slli	a3,a5,0x2
ffffffffc0200962:	9301                	srli	a4,a4,0x20
ffffffffc0200964:	0712                	slli	a4,a4,0x4
ffffffffc0200966:	97b6                	add	a5,a5,a3
ffffffffc0200968:	00e802b3          	add	t0,a6,a4
ffffffffc020096c:	078e                	slli	a5,a5,0x3
ffffffffc020096e:	0102bf83          	ld	t6,16(t0)
    nr_free+=1<<base->property;  
ffffffffc0200972:	9e2d                	addw	a2,a2,a1
    return page+(ppn-page2ppn(page));
ffffffffc0200974:	97aa                	add	a5,a5,a0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200976:	6794                	ld	a3,8(a5)
    nr_free+=1<<base->property;  
ffffffffc0200978:	00006597          	auipc	a1,0x6
ffffffffc020097c:	bcc5a423          	sw	a2,-1080(a1) # ffffffffc0206540 <free_buddy+0x108>
    list_add(&(free_array[free_page->property]),&(free_page->page_link));
ffffffffc0200980:	01850593          	addi	a1,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200984:	00bfb023          	sd	a1,0(t6)
ffffffffc0200988:	0721                	addi	a4,a4,8
ffffffffc020098a:	00b2b823          	sd	a1,16(t0)
ffffffffc020098e:	9742                	add	a4,a4,a6
ffffffffc0200990:	8285                	srli	a3,a3,0x1
    elm->next = next;
    elm->prev = prev;
ffffffffc0200992:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0200994:	03f53023          	sd	t6,32(a0)
    while(!PageProperty(free_page_buddy)&&free_page->property<14)
ffffffffc0200998:	0016f713          	andi	a4,a3,1
ffffffffc020099c:	e345                	bnez	a4,ffffffffc0200a3c <buddy_free_pages+0x152>
ffffffffc020099e:	4735                	li	a4,13
ffffffffc02009a0:	09e76e63          	bltu	a4,t5,ffffffffc0200a3c <buddy_free_pages+0x152>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02009a4:	52f5                	li	t0,-3
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc02009a6:	4f05                	li	t5,1
    while(!PageProperty(free_page_buddy)&&free_page->property<14)
ffffffffc02009a8:	4fb5                	li	t6,13
        if(free_page_buddy<free_page)
ffffffffc02009aa:	00a7fd63          	bleu	a0,a5,ffffffffc02009c4 <buddy_free_pages+0xda>
            free_page->property=0;
ffffffffc02009ae:	00052823          	sw	zero,16(a0)
ffffffffc02009b2:	00850713          	addi	a4,a0,8
ffffffffc02009b6:	6057302f          	amoand.d	zero,t0,(a4)
ffffffffc02009ba:	872a                	mv	a4,a0
ffffffffc02009bc:	01878593          	addi	a1,a5,24
ffffffffc02009c0:	853e                	mv	a0,a5
ffffffffc02009c2:	87ba                	mv	a5,a4
ffffffffc02009c4:	000e3703          	ld	a4,0(t3)
        free_page->property+=1;
ffffffffc02009c8:	4910                	lw	a2,16(a0)
    __list_del(listelm->prev, listelm->next);
ffffffffc02009ca:	6d04                	ld	s1,24(a0)
ffffffffc02009cc:	40e50733          	sub	a4,a0,a4
ffffffffc02009d0:	870d                	srai	a4,a4,0x3
ffffffffc02009d2:	02670733          	mul	a4,a4,t1
ffffffffc02009d6:	7114                	ld	a3,32(a0)
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc02009d8:	000eb383          	ld	t2,0(t4)
        free_page->property+=1;
ffffffffc02009dc:	2605                	addiw	a2,a2,1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02009de:	e494                	sd	a3,8(s1)
    next->prev = prev;
ffffffffc02009e0:	e284                	sd	s1,0(a3)
ffffffffc02009e2:	0006041b          	sext.w	s0,a2
    __list_del(listelm->prev, listelm->next);
ffffffffc02009e6:	6f84                	ld	s1,24(a5)
ffffffffc02009e8:	0207b903          	ld	s2,32(a5)
    size_t ppn=fppn+((1<<power)^(page2ppn(page)-fppn));
ffffffffc02009ec:	008f16bb          	sllw	a3,t5,s0
ffffffffc02009f0:	9746                	add	a4,a4,a7
ffffffffc02009f2:	407707b3          	sub	a5,a4,t2
ffffffffc02009f6:	8fb5                	xor	a5,a5,a3
    return page+(ppn-page2ppn(page));
ffffffffc02009f8:	40e38733          	sub	a4,t2,a4
ffffffffc02009fc:	973e                	add	a4,a4,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02009fe:	02061693          	slli	a3,a2,0x20
ffffffffc0200a02:	82f1                	srli	a3,a3,0x1c
ffffffffc0200a04:	00271793          	slli	a5,a4,0x2
    prev->next = next;
ffffffffc0200a08:	0124b423          	sd	s2,8(s1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a0c:	00d809b3          	add	s3,a6,a3
ffffffffc0200a10:	97ba                	add	a5,a5,a4
ffffffffc0200a12:	0109b383          	ld	t2,16(s3)
ffffffffc0200a16:	078e                	slli	a5,a5,0x3
    next->prev = prev;
ffffffffc0200a18:	00993023          	sd	s1,0(s2)
ffffffffc0200a1c:	97aa                	add	a5,a5,a0
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a1e:	6798                	ld	a4,8(a5)
        free_page->property+=1;
ffffffffc0200a20:	c910                	sw	a2,16(a0)
    prev->next = next->prev = elm;
ffffffffc0200a22:	00b3b023          	sd	a1,0(t2)
        list_add(&(free_array[free_page->property]),&(free_page->page_link));
ffffffffc0200a26:	06a1                	addi	a3,a3,8
ffffffffc0200a28:	00b9b823          	sd	a1,16(s3)
ffffffffc0200a2c:	96c2                	add	a3,a3,a6
    elm->next = next;
ffffffffc0200a2e:	02753023          	sd	t2,32(a0)
    elm->prev = prev;
ffffffffc0200a32:	ed14                	sd	a3,24(a0)
    while(!PageProperty(free_page_buddy)&&free_page->property<14)
ffffffffc0200a34:	8b09                	andi	a4,a4,2
ffffffffc0200a36:	e319                	bnez	a4,ffffffffc0200a3c <buddy_free_pages+0x152>
ffffffffc0200a38:	f68ff9e3          	bleu	s0,t6,ffffffffc02009aa <buddy_free_pages+0xc0>
}
ffffffffc0200a3c:	70a2                	ld	ra,40(sp)
ffffffffc0200a3e:	7402                	ld	s0,32(sp)
ffffffffc0200a40:	64e2                	ld	s1,24(sp)
ffffffffc0200a42:	6942                	ld	s2,16(sp)
ffffffffc0200a44:	69a2                	ld	s3,8(sp)
ffffffffc0200a46:	6145                	addi	sp,sp,48
ffffffffc0200a48:	8082                	ret
    assert(n>0);
ffffffffc0200a4a:	00002697          	auipc	a3,0x2
ffffffffc0200a4e:	80668693          	addi	a3,a3,-2042 # ffffffffc0202250 <commands+0x868>
ffffffffc0200a52:	00002617          	auipc	a2,0x2
ffffffffc0200a56:	80660613          	addi	a2,a2,-2042 # ffffffffc0202258 <commands+0x870>
ffffffffc0200a5a:	07f00593          	li	a1,127
ffffffffc0200a5e:	00002517          	auipc	a0,0x2
ffffffffc0200a62:	81250513          	addi	a0,a0,-2030 # ffffffffc0202270 <commands+0x888>
ffffffffc0200a66:	947ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200a6a <buddy_alloc_pages>:
{
ffffffffc0200a6a:	7179                	addi	sp,sp,-48
ffffffffc0200a6c:	f406                	sd	ra,40(sp)
ffffffffc0200a6e:	f022                	sd	s0,32(sp)
ffffffffc0200a70:	ec26                	sd	s1,24(sp)
ffffffffc0200a72:	e84a                	sd	s2,16(sp)
ffffffffc0200a74:	e44e                	sd	s3,8(sp)
    assert (real_n>0);
ffffffffc0200a76:	1a050163          	beqz	a0,ffffffffc0200c18 <buddy_alloc_pages+0x1ae>
    if(real_n>nr_free)
ffffffffc0200a7a:	00006797          	auipc	a5,0x6
ffffffffc0200a7e:	ac67e783          	lwu	a5,-1338(a5) # ffffffffc0206540 <free_buddy+0x108>
ffffffffc0200a82:	16a7e563          	bltu	a5,a0,ffffffffc0200bec <buddy_alloc_pages+0x182>
    order=IS_POWER_OF_2(real_n)?GET_POWER_OF_2(real_n):GET_POWER_OF_2(real_n)+1;
ffffffffc0200a86:	fff50713          	addi	a4,a0,-1
ffffffffc0200a8a:	8f69                	and	a4,a4,a0
ffffffffc0200a8c:	00155793          	srli	a5,a0,0x1
ffffffffc0200a90:	e775                	bnez	a4,ffffffffc0200b7c <buddy_alloc_pages+0x112>
    while(n>>1)
ffffffffc0200a92:	16078563          	beqz	a5,ffffffffc0200bfc <buddy_alloc_pages+0x192>
    uint32_t power = 0;
ffffffffc0200a96:	4681                	li	a3,0
    while(n>>1)
ffffffffc0200a98:	8385                	srli	a5,a5,0x1
        power++;
ffffffffc0200a9a:	2685                	addiw	a3,a3,1
    while(n>>1)
ffffffffc0200a9c:	fff5                	bnez	a5,ffffffffc0200a98 <buddy_alloc_pages+0x2e>
ffffffffc0200a9e:	02069793          	slli	a5,a3,0x20
ffffffffc0200aa2:	0006881b          	sext.w	a6,a3
ffffffffc0200aa6:	9381                	srli	a5,a5,0x20
ffffffffc0200aa8:	00479893          	slli	a7,a5,0x4
ffffffffc0200aac:	00481f13          	slli	t5,a6,0x4
ffffffffc0200ab0:	4405                	li	s0,1
ffffffffc0200ab2:	00d4143b          	sllw	s0,s0,a3
ffffffffc0200ab6:	08a1                	addi	a7,a7,8
ffffffffc0200ab8:	0f21                	addi	t5,t5,8
    order=IS_POWER_OF_2(real_n)?GET_POWER_OF_2(real_n):GET_POWER_OF_2(real_n)+1;
ffffffffc0200aba:	00006317          	auipc	t1,0x6
ffffffffc0200abe:	97e30313          	addi	t1,t1,-1666 # ffffffffc0206438 <free_buddy>
ffffffffc0200ac2:	0792                	slli	a5,a5,0x4
ffffffffc0200ac4:	00f302b3          	add	t0,t1,a5
ffffffffc0200ac8:	00280e13          	addi	t3,a6,2
ffffffffc0200acc:	0102b903          	ld	s2,16(t0)
ffffffffc0200ad0:	0e12                	slli	t3,t3,0x4
    return list->next == list;
ffffffffc0200ad2:	00481e93          	slli	t4,a6,0x4
ffffffffc0200ad6:	00006717          	auipc	a4,0x6
ffffffffc0200ada:	96d72123          	sw	a3,-1694(a4) # ffffffffc0206438 <free_buddy>
        if(!list_empty(&(free_array[order])))
ffffffffc0200ade:	989a                	add	a7,a7,t1
            if(!list_empty(&(free_array[i])))
ffffffffc0200ae0:	9f1a                	add	t5,t5,t1
ffffffffc0200ae2:	9e1a                	add	t3,t3,t1
        for(int i=order;i<16;i++)
ffffffffc0200ae4:	4fbd                	li	t6,15
ffffffffc0200ae6:	9e9a                	add	t4,t4,t1
ffffffffc0200ae8:	4541                	li	a0,16
ffffffffc0200aea:	fff8049b          	addiw	s1,a6,-1
                struct Page *page2=page1+(1<<(i-1));
ffffffffc0200aee:	4385                	li	t2,1
        if(!list_empty(&(free_array[order])))
ffffffffc0200af0:	0d289063          	bne	a7,s2,ffffffffc0200bb0 <buddy_alloc_pages+0x146>
        for(int i=order;i<16;i++)
ffffffffc0200af4:	ff0fcee3          	blt	t6,a6,ffffffffc0200af0 <buddy_alloc_pages+0x86>
ffffffffc0200af8:	010eb583          	ld	a1,16(t4)
            if(!list_empty(&(free_array[i])))
ffffffffc0200afc:	0ebf1663          	bne	t5,a1,ffffffffc0200be8 <buddy_alloc_pages+0x17e>
ffffffffc0200b00:	87f2                	mv	a5,t3
ffffffffc0200b02:	8642                	mv	a2,a6
ffffffffc0200b04:	a019                	j	ffffffffc0200b0a <buddy_alloc_pages+0xa0>
ffffffffc0200b06:	87b6                	mv	a5,a3
ffffffffc0200b08:	863a                	mv	a2,a4
        for(int i=order;i<16;i++)
ffffffffc0200b0a:	0016071b          	addiw	a4,a2,1
ffffffffc0200b0e:	fea701e3          	beq	a4,a0,ffffffffc0200af0 <buddy_alloc_pages+0x86>
ffffffffc0200b12:	638c                	ld	a1,0(a5)
ffffffffc0200b14:	01078693          	addi	a3,a5,16
            if(!list_empty(&(free_array[i])))
ffffffffc0200b18:	17e1                	addi	a5,a5,-8
ffffffffc0200b1a:	fef586e3          	beq	a1,a5,ffffffffc0200b06 <buddy_alloc_pages+0x9c>
                struct Page *page2=page1+(1<<(i-1));
ffffffffc0200b1e:	00c397bb          	sllw	a5,t2,a2
ffffffffc0200b22:	00279713          	slli	a4,a5,0x2
ffffffffc0200b26:	973e                	add	a4,a4,a5
ffffffffc0200b28:	070e                	slli	a4,a4,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b2a:	0085b903          	ld	s2,8(a1)
ffffffffc0200b2e:	0005b983          	ld	s3,0(a1)
                page1->property=i-1;
ffffffffc0200b32:	0006079b          	sext.w	a5,a2
                struct Page *page2=page1+(1<<(i-1));
ffffffffc0200b36:	1721                	addi	a4,a4,-24
                page1->property=i-1;
ffffffffc0200b38:	fef5ac23          	sw	a5,-8(a1)
                struct Page *page2=page1+(1<<(i-1));
ffffffffc0200b3c:	972e                	add	a4,a4,a1
                page2->property=i-1;
ffffffffc0200b3e:	cb1c                	sw	a5,16(a4)
                list_add(&(free_array[i-1]),&(page2->page_link));
ffffffffc0200b40:	0612                	slli	a2,a2,0x4
    prev->next = next;
ffffffffc0200b42:	0129b423          	sd	s2,8(s3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b46:	00c306b3          	add	a3,t1,a2
ffffffffc0200b4a:	6a9c                	ld	a5,16(a3)
    next->prev = prev;
ffffffffc0200b4c:	01393023          	sd	s3,0(s2)
ffffffffc0200b50:	01870913          	addi	s2,a4,24
    prev->next = next->prev = elm;
ffffffffc0200b54:	0127b023          	sd	s2,0(a5)
ffffffffc0200b58:	0126b823          	sd	s2,16(a3)
    elm->next = next;
ffffffffc0200b5c:	f31c                	sd	a5,32(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b5e:	0106b903          	ld	s2,16(a3)
ffffffffc0200b62:	0621                	addi	a2,a2,8
ffffffffc0200b64:	00c307b3          	add	a5,t1,a2
    elm->prev = prev;
ffffffffc0200b68:	ef1c                	sd	a5,24(a4)
    prev->next = next->prev = elm;
ffffffffc0200b6a:	00b93023          	sd	a1,0(s2)
ffffffffc0200b6e:	ea8c                	sd	a1,16(a3)
    elm->next = next;
ffffffffc0200b70:	0125b423          	sd	s2,8(a1)
    elm->prev = prev;
ffffffffc0200b74:	e19c                	sd	a5,0(a1)
ffffffffc0200b76:	0102b903          	ld	s2,16(t0)
ffffffffc0200b7a:	bf9d                	j	ffffffffc0200af0 <buddy_alloc_pages+0x86>
    uint32_t power = 0;
ffffffffc0200b7c:	4701                	li	a4,0
    while(n>>1)
ffffffffc0200b7e:	e399                	bnez	a5,ffffffffc0200b84 <buddy_alloc_pages+0x11a>
ffffffffc0200b80:	a069                	j	ffffffffc0200c0a <buddy_alloc_pages+0x1a0>
        power++;
ffffffffc0200b82:	8736                	mv	a4,a3
    while(n>>1)
ffffffffc0200b84:	8385                	srli	a5,a5,0x1
        power++;
ffffffffc0200b86:	0017069b          	addiw	a3,a4,1
    while(n>>1)
ffffffffc0200b8a:	ffe5                	bnez	a5,ffffffffc0200b82 <buddy_alloc_pages+0x118>
ffffffffc0200b8c:	2709                	addiw	a4,a4,2
ffffffffc0200b8e:	0007069b          	sext.w	a3,a4
ffffffffc0200b92:	1702                	slli	a4,a4,0x20
ffffffffc0200b94:	01c75893          	srli	a7,a4,0x1c
ffffffffc0200b98:	00469f13          	slli	t5,a3,0x4
ffffffffc0200b9c:	4405                	li	s0,1
ffffffffc0200b9e:	02069793          	slli	a5,a3,0x20
ffffffffc0200ba2:	08a1                	addi	a7,a7,8
ffffffffc0200ba4:	00d4143b          	sllw	s0,s0,a3
ffffffffc0200ba8:	8836                	mv	a6,a3
ffffffffc0200baa:	0f21                	addi	t5,t5,8
    return power;
ffffffffc0200bac:	9381                	srli	a5,a5,0x20
ffffffffc0200bae:	b731                	j	ffffffffc0200aba <buddy_alloc_pages+0x50>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200bb0:	00093703          	ld	a4,0(s2)
ffffffffc0200bb4:	00893783          	ld	a5,8(s2)
            page=le2page(list_next(&(free_array[order])),page_link);
ffffffffc0200bb8:	fe890513          	addi	a0,s2,-24
    prev->next = next;
ffffffffc0200bbc:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200bbe:	e398                	sd	a4,0(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200bc0:	4789                	li	a5,2
ffffffffc0200bc2:	ff090713          	addi	a4,s2,-16
ffffffffc0200bc6:	40f7302f          	amoor.d	zero,a5,(a4)
            nr_free-=n;
ffffffffc0200bca:	10832783          	lw	a5,264(t1)
}
ffffffffc0200bce:	70a2                	ld	ra,40(sp)
ffffffffc0200bd0:	64e2                	ld	s1,24(sp)
            nr_free-=n;
ffffffffc0200bd2:	4087843b          	subw	s0,a5,s0
ffffffffc0200bd6:	00006797          	auipc	a5,0x6
ffffffffc0200bda:	9687a523          	sw	s0,-1686(a5) # ffffffffc0206540 <free_buddy+0x108>
}
ffffffffc0200bde:	7402                	ld	s0,32(sp)
ffffffffc0200be0:	6942                	ld	s2,16(sp)
ffffffffc0200be2:	69a2                	ld	s3,8(sp)
ffffffffc0200be4:	6145                	addi	sp,sp,48
ffffffffc0200be6:	8082                	ret
ffffffffc0200be8:	8626                	mv	a2,s1
ffffffffc0200bea:	bf15                	j	ffffffffc0200b1e <buddy_alloc_pages+0xb4>
ffffffffc0200bec:	70a2                	ld	ra,40(sp)
ffffffffc0200bee:	7402                	ld	s0,32(sp)
ffffffffc0200bf0:	64e2                	ld	s1,24(sp)
ffffffffc0200bf2:	6942                	ld	s2,16(sp)
ffffffffc0200bf4:	69a2                	ld	s3,8(sp)
    return NULL;
ffffffffc0200bf6:	4501                	li	a0,0
}
ffffffffc0200bf8:	6145                	addi	sp,sp,48
ffffffffc0200bfa:	8082                	ret
    while(n>>1)
ffffffffc0200bfc:	4f21                	li	t5,8
ffffffffc0200bfe:	48a1                	li	a7,8
ffffffffc0200c00:	4801                	li	a6,0
ffffffffc0200c02:	4405                	li	s0,1
    uint32_t power = 0;
ffffffffc0200c04:	4681                	li	a3,0
ffffffffc0200c06:	4781                	li	a5,0
ffffffffc0200c08:	bd4d                	j	ffffffffc0200aba <buddy_alloc_pages+0x50>
    while(n>>1)
ffffffffc0200c0a:	4f61                	li	t5,24
ffffffffc0200c0c:	4805                	li	a6,1
ffffffffc0200c0e:	4409                	li	s0,2
ffffffffc0200c10:	48e1                	li	a7,24
ffffffffc0200c12:	4685                	li	a3,1
ffffffffc0200c14:	4785                	li	a5,1
ffffffffc0200c16:	b555                	j	ffffffffc0200aba <buddy_alloc_pages+0x50>
    assert (real_n>0);
ffffffffc0200c18:	00001697          	auipc	a3,0x1
ffffffffc0200c1c:	40068693          	addi	a3,a3,1024 # ffffffffc0202018 <commands+0x630>
ffffffffc0200c20:	00001617          	auipc	a2,0x1
ffffffffc0200c24:	63860613          	addi	a2,a2,1592 # ffffffffc0202258 <commands+0x870>
ffffffffc0200c28:	05200593          	li	a1,82
ffffffffc0200c2c:	00001517          	auipc	a0,0x1
ffffffffc0200c30:	64450513          	addi	a0,a0,1604 # ffffffffc0202270 <commands+0x888>
ffffffffc0200c34:	f78ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c38 <buddy_check>:
    free_pages(p0, 3);
    free_pages(p1, 3);
    show_buddy_array();
}   

static void buddy_check(void) {
ffffffffc0200c38:	7139                	addi	sp,sp,-64
ffffffffc0200c3a:	fc06                	sd	ra,56(sp)
ffffffffc0200c3c:	f822                	sd	s0,48(sp)
ffffffffc0200c3e:	f426                	sd	s1,40(sp)
ffffffffc0200c40:	f04a                	sd	s2,32(sp)
ffffffffc0200c42:	ec4e                	sd	s3,24(sp)
ffffffffc0200c44:	e852                	sd	s4,16(sp)
ffffffffc0200c46:	e456                	sd	s5,8(sp)
    show_buddy_array();
ffffffffc0200c48:	c0dff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c4c:	4505                	li	a0,1
ffffffffc0200c4e:	468000ef          	jal	ra,ffffffffc02010b6 <alloc_pages>
ffffffffc0200c52:	26050463          	beqz	a0,ffffffffc0200eba <buddy_check+0x282>
ffffffffc0200c56:	89aa                	mv	s3,a0
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c58:	4505                	li	a0,1
ffffffffc0200c5a:	45c000ef          	jal	ra,ffffffffc02010b6 <alloc_pages>
ffffffffc0200c5e:	8a2a                	mv	s4,a0
ffffffffc0200c60:	30050d63          	beqz	a0,ffffffffc0200f7a <buddy_check+0x342>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c64:	4505                	li	a0,1
ffffffffc0200c66:	450000ef          	jal	ra,ffffffffc02010b6 <alloc_pages>
ffffffffc0200c6a:	8aaa                	mv	s5,a0
ffffffffc0200c6c:	1e050763          	beqz	a0,ffffffffc0200e5a <buddy_check+0x222>
    assert(p0 != p1 && p0 != p2 && p1 != p2); // 确保分配的页面不同
ffffffffc0200c70:	1b498563          	beq	s3,s4,ffffffffc0200e1a <buddy_check+0x1e2>
ffffffffc0200c74:	1aa98363          	beq	s3,a0,ffffffffc0200e1a <buddy_check+0x1e2>
ffffffffc0200c78:	1aaa0163          	beq	s4,a0,ffffffffc0200e1a <buddy_check+0x1e2>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0); // 确保引用计数都为0。
ffffffffc0200c7c:	0009a783          	lw	a5,0(s3)
ffffffffc0200c80:	1a079d63          	bnez	a5,ffffffffc0200e3a <buddy_check+0x202>
ffffffffc0200c84:	000a2783          	lw	a5,0(s4)
ffffffffc0200c88:	1a079963          	bnez	a5,ffffffffc0200e3a <buddy_check+0x202>
ffffffffc0200c8c:	411c                	lw	a5,0(a0)
ffffffffc0200c8e:	1a079663          	bnez	a5,ffffffffc0200e3a <buddy_check+0x202>
ffffffffc0200c92:	00006917          	auipc	s2,0x6
ffffffffc0200c96:	8d690913          	addi	s2,s2,-1834 # ffffffffc0206568 <pages>
ffffffffc0200c9a:	00093783          	ld	a5,0(s2)
ffffffffc0200c9e:	00001617          	auipc	a2,0x1
ffffffffc0200ca2:	5aa60613          	addi	a2,a2,1450 # ffffffffc0202248 <commands+0x860>
ffffffffc0200ca6:	6214                	ld	a3,0(a2)
ffffffffc0200ca8:	40f98733          	sub	a4,s3,a5
ffffffffc0200cac:	870d                	srai	a4,a4,0x3
ffffffffc0200cae:	02d70733          	mul	a4,a4,a3
ffffffffc0200cb2:	00002697          	auipc	a3,0x2
ffffffffc0200cb6:	a0e68693          	addi	a3,a3,-1522 # ffffffffc02026c0 <nbase>
ffffffffc0200cba:	6280                	ld	s0,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200cbc:	00005697          	auipc	a3,0x5
ffffffffc0200cc0:	75c68693          	addi	a3,a3,1884 # ffffffffc0206418 <npage>
ffffffffc0200cc4:	6294                	ld	a3,0(a3)
ffffffffc0200cc6:	06b2                	slli	a3,a3,0xc
ffffffffc0200cc8:	9722                	add	a4,a4,s0

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cca:	0732                	slli	a4,a4,0xc
ffffffffc0200ccc:	1ad77763          	bleu	a3,a4,ffffffffc0200e7a <buddy_check+0x242>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cd0:	6204                	ld	s1,0(a2)
ffffffffc0200cd2:	40fa0733          	sub	a4,s4,a5
ffffffffc0200cd6:	870d                	srai	a4,a4,0x3
ffffffffc0200cd8:	02970733          	mul	a4,a4,s1
ffffffffc0200cdc:	9722                	add	a4,a4,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cde:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ce0:	2cd77d63          	bleu	a3,a4,ffffffffc0200fba <buddy_check+0x382>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ce4:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ce8:	878d                	srai	a5,a5,0x3
ffffffffc0200cea:	029787b3          	mul	a5,a5,s1
ffffffffc0200cee:	97a2                	add	a5,a5,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cf0:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200cf2:	1ad7f463          	bleu	a3,a5,ffffffffc0200e9a <buddy_check+0x262>
    show_buddy_array();
ffffffffc0200cf6:	b5fff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    free_page(p0);
ffffffffc0200cfa:	4585                	li	a1,1
ffffffffc0200cfc:	854e                	mv	a0,s3
ffffffffc0200cfe:	3fc000ef          	jal	ra,ffffffffc02010fa <free_pages>
    free_page(p1);
ffffffffc0200d02:	4585                	li	a1,1
ffffffffc0200d04:	8552                	mv	a0,s4
ffffffffc0200d06:	3f4000ef          	jal	ra,ffffffffc02010fa <free_pages>
    free_page(p2);
ffffffffc0200d0a:	4585                	li	a1,1
ffffffffc0200d0c:	8556                	mv	a0,s5
ffffffffc0200d0e:	3ec000ef          	jal	ra,ffffffffc02010fa <free_pages>
    show_buddy_array();
ffffffffc0200d12:	b43ff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    assert(nr_free == 16384);
ffffffffc0200d16:	00005797          	auipc	a5,0x5
ffffffffc0200d1a:	72278793          	addi	a5,a5,1826 # ffffffffc0206438 <free_buddy>
ffffffffc0200d1e:	1087a703          	lw	a4,264(a5)
ffffffffc0200d22:	6791                	lui	a5,0x4
ffffffffc0200d24:	26f71b63          	bne	a4,a5,ffffffffc0200f9a <buddy_check+0x362>
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0200d28:	4511                	li	a0,4
ffffffffc0200d2a:	38c000ef          	jal	ra,ffffffffc02010b6 <alloc_pages>
ffffffffc0200d2e:	89aa                	mv	s3,a0
ffffffffc0200d30:	1c050563          	beqz	a0,ffffffffc0200efa <buddy_check+0x2c2>
    assert((p1 = alloc_pages(2)) != NULL);
ffffffffc0200d34:	4509                	li	a0,2
ffffffffc0200d36:	380000ef          	jal	ra,ffffffffc02010b6 <alloc_pages>
ffffffffc0200d3a:	8aaa                	mv	s5,a0
ffffffffc0200d3c:	1e050f63          	beqz	a0,ffffffffc0200f3a <buddy_check+0x302>
    assert((p2 = alloc_pages(1)) != NULL);
ffffffffc0200d40:	4505                	li	a0,1
ffffffffc0200d42:	374000ef          	jal	ra,ffffffffc02010b6 <alloc_pages>
ffffffffc0200d46:	8a2a                	mv	s4,a0
ffffffffc0200d48:	1c050963          	beqz	a0,ffffffffc0200f1a <buddy_check+0x2e2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d4c:	00093783          	ld	a5,0(s2)
    cprintf("%p,%p,%p\n",page2pa(p0),page2pa(p1),page2pa(p2));show_buddy_array();
ffffffffc0200d50:	00001517          	auipc	a0,0x1
ffffffffc0200d54:	47850513          	addi	a0,a0,1144 # ffffffffc02021c8 <commands+0x7e0>
ffffffffc0200d58:	40fa06b3          	sub	a3,s4,a5
ffffffffc0200d5c:	40fa8633          	sub	a2,s5,a5
ffffffffc0200d60:	40f985b3          	sub	a1,s3,a5
ffffffffc0200d64:	868d                	srai	a3,a3,0x3
ffffffffc0200d66:	860d                	srai	a2,a2,0x3
ffffffffc0200d68:	858d                	srai	a1,a1,0x3
ffffffffc0200d6a:	029686b3          	mul	a3,a3,s1
ffffffffc0200d6e:	02960633          	mul	a2,a2,s1
ffffffffc0200d72:	96a2                	add	a3,a3,s0
ffffffffc0200d74:	06b2                	slli	a3,a3,0xc
ffffffffc0200d76:	029585b3          	mul	a1,a1,s1
ffffffffc0200d7a:	9622                	add	a2,a2,s0
ffffffffc0200d7c:	0632                	slli	a2,a2,0xc
ffffffffc0200d7e:	95a2                	add	a1,a1,s0
ffffffffc0200d80:	05b2                	slli	a1,a1,0xc
ffffffffc0200d82:	b34ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200d86:	acfff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    free_pages(p0, 4);
ffffffffc0200d8a:	4591                	li	a1,4
ffffffffc0200d8c:	854e                	mv	a0,s3
ffffffffc0200d8e:	36c000ef          	jal	ra,ffffffffc02010fa <free_pages>
    cprintf("p0 free\n");show_buddy_array();
ffffffffc0200d92:	00001517          	auipc	a0,0x1
ffffffffc0200d96:	44650513          	addi	a0,a0,1094 # ffffffffc02021d8 <commands+0x7f0>
ffffffffc0200d9a:	b1cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200d9e:	ab7ff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    free_pages(p1, 2);
ffffffffc0200da2:	4589                	li	a1,2
ffffffffc0200da4:	8556                	mv	a0,s5
ffffffffc0200da6:	354000ef          	jal	ra,ffffffffc02010fa <free_pages>
    show_buddy_array();
ffffffffc0200daa:	aabff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    cprintf("p1 free\n");show_buddy_array();
ffffffffc0200dae:	00001517          	auipc	a0,0x1
ffffffffc0200db2:	43a50513          	addi	a0,a0,1082 # ffffffffc02021e8 <commands+0x800>
ffffffffc0200db6:	b00ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200dba:	a9bff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    free_pages(p2, 1);
ffffffffc0200dbe:	4585                	li	a1,1
ffffffffc0200dc0:	8552                	mv	a0,s4
ffffffffc0200dc2:	338000ef          	jal	ra,ffffffffc02010fa <free_pages>
    cprintf("p2 free\n");show_buddy_array();
ffffffffc0200dc6:	00001517          	auipc	a0,0x1
ffffffffc0200dca:	43250513          	addi	a0,a0,1074 # ffffffffc02021f8 <commands+0x810>
ffffffffc0200dce:	ae8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200dd2:	a83ff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    show_buddy_array();
ffffffffc0200dd6:	a7fff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    assert((p0 = alloc_pages(3)) != NULL);
ffffffffc0200dda:	450d                	li	a0,3
ffffffffc0200ddc:	2da000ef          	jal	ra,ffffffffc02010b6 <alloc_pages>
ffffffffc0200de0:	84aa                	mv	s1,a0
ffffffffc0200de2:	0e050c63          	beqz	a0,ffffffffc0200eda <buddy_check+0x2a2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200de6:	450d                	li	a0,3
ffffffffc0200de8:	2ce000ef          	jal	ra,ffffffffc02010b6 <alloc_pages>
ffffffffc0200dec:	842a                	mv	s0,a0
ffffffffc0200dee:	16050663          	beqz	a0,ffffffffc0200f5a <buddy_check+0x322>
    show_buddy_array();
ffffffffc0200df2:	a63ff0ef          	jal	ra,ffffffffc0200854 <show_buddy_array>
    free_pages(p0, 3);
ffffffffc0200df6:	8526                	mv	a0,s1
ffffffffc0200df8:	458d                	li	a1,3
ffffffffc0200dfa:	300000ef          	jal	ra,ffffffffc02010fa <free_pages>
    free_pages(p1, 3);
ffffffffc0200dfe:	8522                	mv	a0,s0
ffffffffc0200e00:	458d                	li	a1,3
ffffffffc0200e02:	2f8000ef          	jal	ra,ffffffffc02010fa <free_pages>

    basic_check();// 调用 basic_check 函数，检查基本功能是否正常



}
ffffffffc0200e06:	7442                	ld	s0,48(sp)
ffffffffc0200e08:	70e2                	ld	ra,56(sp)
ffffffffc0200e0a:	74a2                	ld	s1,40(sp)
ffffffffc0200e0c:	7902                	ld	s2,32(sp)
ffffffffc0200e0e:	69e2                	ld	s3,24(sp)
ffffffffc0200e10:	6a42                	ld	s4,16(sp)
ffffffffc0200e12:	6aa2                	ld	s5,8(sp)
ffffffffc0200e14:	6121                	addi	sp,sp,64
    show_buddy_array();
ffffffffc0200e16:	a3fff06f          	j	ffffffffc0200854 <show_buddy_array>
    assert(p0 != p1 && p0 != p2 && p1 != p2); // 确保分配的页面不同
ffffffffc0200e1a:	00001697          	auipc	a3,0x1
ffffffffc0200e1e:	26e68693          	addi	a3,a3,622 # ffffffffc0202088 <commands+0x6a0>
ffffffffc0200e22:	00001617          	auipc	a2,0x1
ffffffffc0200e26:	43660613          	addi	a2,a2,1078 # ffffffffc0202258 <commands+0x870>
ffffffffc0200e2a:	0a800593          	li	a1,168
ffffffffc0200e2e:	00001517          	auipc	a0,0x1
ffffffffc0200e32:	44250513          	addi	a0,a0,1090 # ffffffffc0202270 <commands+0x888>
ffffffffc0200e36:	d76ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0); // 确保引用计数都为0。
ffffffffc0200e3a:	00001697          	auipc	a3,0x1
ffffffffc0200e3e:	27668693          	addi	a3,a3,630 # ffffffffc02020b0 <commands+0x6c8>
ffffffffc0200e42:	00001617          	auipc	a2,0x1
ffffffffc0200e46:	41660613          	addi	a2,a2,1046 # ffffffffc0202258 <commands+0x870>
ffffffffc0200e4a:	0a900593          	li	a1,169
ffffffffc0200e4e:	00001517          	auipc	a0,0x1
ffffffffc0200e52:	42250513          	addi	a0,a0,1058 # ffffffffc0202270 <commands+0x888>
ffffffffc0200e56:	d56ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e5a:	00001697          	auipc	a3,0x1
ffffffffc0200e5e:	20e68693          	addi	a3,a3,526 # ffffffffc0202068 <commands+0x680>
ffffffffc0200e62:	00001617          	auipc	a2,0x1
ffffffffc0200e66:	3f660613          	addi	a2,a2,1014 # ffffffffc0202258 <commands+0x870>
ffffffffc0200e6a:	0a600593          	li	a1,166
ffffffffc0200e6e:	00001517          	auipc	a0,0x1
ffffffffc0200e72:	40250513          	addi	a0,a0,1026 # ffffffffc0202270 <commands+0x888>
ffffffffc0200e76:	d36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e7a:	00001697          	auipc	a3,0x1
ffffffffc0200e7e:	27668693          	addi	a3,a3,630 # ffffffffc02020f0 <commands+0x708>
ffffffffc0200e82:	00001617          	auipc	a2,0x1
ffffffffc0200e86:	3d660613          	addi	a2,a2,982 # ffffffffc0202258 <commands+0x870>
ffffffffc0200e8a:	0ac00593          	li	a1,172
ffffffffc0200e8e:	00001517          	auipc	a0,0x1
ffffffffc0200e92:	3e250513          	addi	a0,a0,994 # ffffffffc0202270 <commands+0x888>
ffffffffc0200e96:	d16ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e9a:	00001697          	auipc	a3,0x1
ffffffffc0200e9e:	29668693          	addi	a3,a3,662 # ffffffffc0202130 <commands+0x748>
ffffffffc0200ea2:	00001617          	auipc	a2,0x1
ffffffffc0200ea6:	3b660613          	addi	a2,a2,950 # ffffffffc0202258 <commands+0x870>
ffffffffc0200eaa:	0ae00593          	li	a1,174
ffffffffc0200eae:	00001517          	auipc	a0,0x1
ffffffffc0200eb2:	3c250513          	addi	a0,a0,962 # ffffffffc0202270 <commands+0x888>
ffffffffc0200eb6:	cf6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200eba:	00001697          	auipc	a3,0x1
ffffffffc0200ebe:	16e68693          	addi	a3,a3,366 # ffffffffc0202028 <commands+0x640>
ffffffffc0200ec2:	00001617          	auipc	a2,0x1
ffffffffc0200ec6:	39660613          	addi	a2,a2,918 # ffffffffc0202258 <commands+0x870>
ffffffffc0200eca:	0a400593          	li	a1,164
ffffffffc0200ece:	00001517          	auipc	a0,0x1
ffffffffc0200ed2:	3a250513          	addi	a0,a0,930 # ffffffffc0202270 <commands+0x888>
ffffffffc0200ed6:	cd6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(3)) != NULL);
ffffffffc0200eda:	00001697          	auipc	a3,0x1
ffffffffc0200ede:	32e68693          	addi	a3,a3,814 # ffffffffc0202208 <commands+0x820>
ffffffffc0200ee2:	00001617          	auipc	a2,0x1
ffffffffc0200ee6:	37660613          	addi	a2,a2,886 # ffffffffc0202258 <commands+0x870>
ffffffffc0200eea:	0c900593          	li	a1,201
ffffffffc0200eee:	00001517          	auipc	a0,0x1
ffffffffc0200ef2:	38250513          	addi	a0,a0,898 # ffffffffc0202270 <commands+0x888>
ffffffffc0200ef6:	cb6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0200efa:	00001697          	auipc	a3,0x1
ffffffffc0200efe:	26e68693          	addi	a3,a3,622 # ffffffffc0202168 <commands+0x780>
ffffffffc0200f02:	00001617          	auipc	a2,0x1
ffffffffc0200f06:	35660613          	addi	a2,a2,854 # ffffffffc0202258 <commands+0x870>
ffffffffc0200f0a:	0bc00593          	li	a1,188
ffffffffc0200f0e:	00001517          	auipc	a0,0x1
ffffffffc0200f12:	36250513          	addi	a0,a0,866 # ffffffffc0202270 <commands+0x888>
ffffffffc0200f16:	c96ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_pages(1)) != NULL);
ffffffffc0200f1a:	00001697          	auipc	a3,0x1
ffffffffc0200f1e:	28e68693          	addi	a3,a3,654 # ffffffffc02021a8 <commands+0x7c0>
ffffffffc0200f22:	00001617          	auipc	a2,0x1
ffffffffc0200f26:	33660613          	addi	a2,a2,822 # ffffffffc0202258 <commands+0x870>
ffffffffc0200f2a:	0be00593          	li	a1,190
ffffffffc0200f2e:	00001517          	auipc	a0,0x1
ffffffffc0200f32:	34250513          	addi	a0,a0,834 # ffffffffc0202270 <commands+0x888>
ffffffffc0200f36:	c76ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(2)) != NULL);
ffffffffc0200f3a:	00001697          	auipc	a3,0x1
ffffffffc0200f3e:	24e68693          	addi	a3,a3,590 # ffffffffc0202188 <commands+0x7a0>
ffffffffc0200f42:	00001617          	auipc	a2,0x1
ffffffffc0200f46:	31660613          	addi	a2,a2,790 # ffffffffc0202258 <commands+0x870>
ffffffffc0200f4a:	0bd00593          	li	a1,189
ffffffffc0200f4e:	00001517          	auipc	a0,0x1
ffffffffc0200f52:	32250513          	addi	a0,a0,802 # ffffffffc0202270 <commands+0x888>
ffffffffc0200f56:	c56ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200f5a:	00001697          	auipc	a3,0x1
ffffffffc0200f5e:	2ce68693          	addi	a3,a3,718 # ffffffffc0202228 <commands+0x840>
ffffffffc0200f62:	00001617          	auipc	a2,0x1
ffffffffc0200f66:	2f660613          	addi	a2,a2,758 # ffffffffc0202258 <commands+0x870>
ffffffffc0200f6a:	0ca00593          	li	a1,202
ffffffffc0200f6e:	00001517          	auipc	a0,0x1
ffffffffc0200f72:	30250513          	addi	a0,a0,770 # ffffffffc0202270 <commands+0x888>
ffffffffc0200f76:	c36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f7a:	00001697          	auipc	a3,0x1
ffffffffc0200f7e:	0ce68693          	addi	a3,a3,206 # ffffffffc0202048 <commands+0x660>
ffffffffc0200f82:	00001617          	auipc	a2,0x1
ffffffffc0200f86:	2d660613          	addi	a2,a2,726 # ffffffffc0202258 <commands+0x870>
ffffffffc0200f8a:	0a500593          	li	a1,165
ffffffffc0200f8e:	00001517          	auipc	a0,0x1
ffffffffc0200f92:	2e250513          	addi	a0,a0,738 # ffffffffc0202270 <commands+0x888>
ffffffffc0200f96:	c16ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 16384);
ffffffffc0200f9a:	00001697          	auipc	a3,0x1
ffffffffc0200f9e:	1b668693          	addi	a3,a3,438 # ffffffffc0202150 <commands+0x768>
ffffffffc0200fa2:	00001617          	auipc	a2,0x1
ffffffffc0200fa6:	2b660613          	addi	a2,a2,694 # ffffffffc0202258 <commands+0x870>
ffffffffc0200faa:	0b900593          	li	a1,185
ffffffffc0200fae:	00001517          	auipc	a0,0x1
ffffffffc0200fb2:	2c250513          	addi	a0,a0,706 # ffffffffc0202270 <commands+0x888>
ffffffffc0200fb6:	bf6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200fba:	00001697          	auipc	a3,0x1
ffffffffc0200fbe:	15668693          	addi	a3,a3,342 # ffffffffc0202110 <commands+0x728>
ffffffffc0200fc2:	00001617          	auipc	a2,0x1
ffffffffc0200fc6:	29660613          	addi	a2,a2,662 # ffffffffc0202258 <commands+0x870>
ffffffffc0200fca:	0ad00593          	li	a1,173
ffffffffc0200fce:	00001517          	auipc	a0,0x1
ffffffffc0200fd2:	2a250513          	addi	a0,a0,674 # ffffffffc0202270 <commands+0x888>
ffffffffc0200fd6:	bd6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200fda <buddy_init_memmap>:
{
ffffffffc0200fda:	1141                	addi	sp,sp,-16
ffffffffc0200fdc:	e406                	sd	ra,8(sp)
    assert(real_n>0);
ffffffffc0200fde:	cdc5                	beqz	a1,ffffffffc0201096 <buddy_init_memmap+0xbc>
    while(n>>1)
ffffffffc0200fe0:	8185                	srli	a1,a1,0x1
    uint32_t power = 0;
ffffffffc0200fe2:	4781                	li	a5,0
    while(n>>1)
ffffffffc0200fe4:	02800693          	li	a3,40
ffffffffc0200fe8:	4705                	li	a4,1
ffffffffc0200fea:	c999                	beqz	a1,ffffffffc0201000 <buddy_init_memmap+0x26>
ffffffffc0200fec:	8185                	srli	a1,a1,0x1
        power++;
ffffffffc0200fee:	2785                	addiw	a5,a5,1
    while(n>>1)
ffffffffc0200ff0:	fdf5                	bnez	a1,ffffffffc0200fec <buddy_init_memmap+0x12>
ffffffffc0200ff2:	4705                	li	a4,1
ffffffffc0200ff4:	00f7173b          	sllw	a4,a4,a5
ffffffffc0200ff8:	00271693          	slli	a3,a4,0x2
ffffffffc0200ffc:	96ba                	add	a3,a3,a4
ffffffffc0200ffe:	068e                	slli	a3,a3,0x3
    order=GET_POWER_OF_2(real_n);
ffffffffc0201000:	00005617          	auipc	a2,0x5
ffffffffc0201004:	42f62c23          	sw	a5,1080(a2) # ffffffffc0206438 <free_buddy>
    nr_free=n;
ffffffffc0201008:	00005617          	auipc	a2,0x5
ffffffffc020100c:	52e62c23          	sw	a4,1336(a2) # ffffffffc0206540 <free_buddy+0x108>
    for (; p != base + n; p+=1) 
ffffffffc0201010:	96aa                	add	a3,a3,a0
ffffffffc0201012:	04d50d63          	beq	a0,a3,ffffffffc020106c <buddy_init_memmap+0x92>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201016:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));// 确保页面已保留
ffffffffc0201018:	87aa                	mv	a5,a0
ffffffffc020101a:	8b05                	andi	a4,a4,1
ffffffffc020101c:	e709                	bnez	a4,ffffffffc0201026 <buddy_init_memmap+0x4c>
ffffffffc020101e:	a8a1                	j	ffffffffc0201076 <buddy_init_memmap+0x9c>
ffffffffc0201020:	6798                	ld	a4,8(a5)
ffffffffc0201022:	8b05                	andi	a4,a4,1
ffffffffc0201024:	cb29                	beqz	a4,ffffffffc0201076 <buddy_init_memmap+0x9c>
        p->flags =  0;//页面空闲
ffffffffc0201026:	0007b423          	sd	zero,8(a5) # 4008 <BASE_ADDRESS-0xffffffffc01fbff8>
        p->property =0;
ffffffffc020102a:	0007a823          	sw	zero,16(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020102e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p+=1) 
ffffffffc0201032:	02878793          	addi	a5,a5,40
ffffffffc0201036:	fed795e3          	bne	a5,a3,ffffffffc0201020 <buddy_init_memmap+0x46>
ffffffffc020103a:	00005697          	auipc	a3,0x5
ffffffffc020103e:	3fe68693          	addi	a3,a3,1022 # ffffffffc0206438 <free_buddy>
ffffffffc0201042:	429c                	lw	a5,0(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201044:	02079713          	slli	a4,a5,0x20
ffffffffc0201048:	8371                	srli	a4,a4,0x1c
ffffffffc020104a:	00e685b3          	add	a1,a3,a4
ffffffffc020104e:	6990                	ld	a2,16(a1)
    list_add(&(free_array[order]), &(base->page_link));
ffffffffc0201050:	01850813          	addi	a6,a0,24
}
ffffffffc0201054:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201056:	01063023          	sd	a6,0(a2)
    list_add(&(free_array[order]), &(base->page_link));
ffffffffc020105a:	0721                	addi	a4,a4,8
ffffffffc020105c:	0105b823          	sd	a6,16(a1)
ffffffffc0201060:	9736                	add	a4,a4,a3
    elm->next = next;
ffffffffc0201062:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc0201064:	ed18                	sd	a4,24(a0)
    base->property=order;
ffffffffc0201066:	c91c                	sw	a5,16(a0)
}
ffffffffc0201068:	0141                	addi	sp,sp,16
ffffffffc020106a:	8082                	ret
ffffffffc020106c:	00005697          	auipc	a3,0x5
ffffffffc0201070:	3cc68693          	addi	a3,a3,972 # ffffffffc0206438 <free_buddy>
ffffffffc0201074:	bfc1                	j	ffffffffc0201044 <buddy_init_memmap+0x6a>
        assert(PageReserved(p));// 确保页面已保留
ffffffffc0201076:	00001697          	auipc	a3,0x1
ffffffffc020107a:	21268693          	addi	a3,a3,530 # ffffffffc0202288 <commands+0x8a0>
ffffffffc020107e:	00001617          	auipc	a2,0x1
ffffffffc0201082:	1da60613          	addi	a2,a2,474 # ffffffffc0202258 <commands+0x870>
ffffffffc0201086:	04500593          	li	a1,69
ffffffffc020108a:	00001517          	auipc	a0,0x1
ffffffffc020108e:	1e650513          	addi	a0,a0,486 # ffffffffc0202270 <commands+0x888>
ffffffffc0201092:	b1aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(real_n>0);
ffffffffc0201096:	00001697          	auipc	a3,0x1
ffffffffc020109a:	f8268693          	addi	a3,a3,-126 # ffffffffc0202018 <commands+0x630>
ffffffffc020109e:	00001617          	auipc	a2,0x1
ffffffffc02010a2:	1ba60613          	addi	a2,a2,442 # ffffffffc0202258 <commands+0x870>
ffffffffc02010a6:	03e00593          	li	a1,62
ffffffffc02010aa:	00001517          	auipc	a0,0x1
ffffffffc02010ae:	1c650513          	addi	a0,a0,454 # ffffffffc0202270 <commands+0x888>
ffffffffc02010b2:	afaff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02010b6 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02010b6:	100027f3          	csrr	a5,sstatus
ffffffffc02010ba:	8b89                	andi	a5,a5,2
ffffffffc02010bc:	eb89                	bnez	a5,ffffffffc02010ce <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02010be:	00005797          	auipc	a5,0x5
ffffffffc02010c2:	49a78793          	addi	a5,a5,1178 # ffffffffc0206558 <pmm_manager>
ffffffffc02010c6:	639c                	ld	a5,0(a5)
ffffffffc02010c8:	0187b303          	ld	t1,24(a5)
ffffffffc02010cc:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02010ce:	1141                	addi	sp,sp,-16
ffffffffc02010d0:	e406                	sd	ra,8(sp)
ffffffffc02010d2:	e022                	sd	s0,0(sp)
ffffffffc02010d4:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02010d6:	b8eff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02010da:	00005797          	auipc	a5,0x5
ffffffffc02010de:	47e78793          	addi	a5,a5,1150 # ffffffffc0206558 <pmm_manager>
ffffffffc02010e2:	639c                	ld	a5,0(a5)
ffffffffc02010e4:	8522                	mv	a0,s0
ffffffffc02010e6:	6f9c                	ld	a5,24(a5)
ffffffffc02010e8:	9782                	jalr	a5
ffffffffc02010ea:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02010ec:	b72ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02010f0:	8522                	mv	a0,s0
ffffffffc02010f2:	60a2                	ld	ra,8(sp)
ffffffffc02010f4:	6402                	ld	s0,0(sp)
ffffffffc02010f6:	0141                	addi	sp,sp,16
ffffffffc02010f8:	8082                	ret

ffffffffc02010fa <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02010fa:	100027f3          	csrr	a5,sstatus
ffffffffc02010fe:	8b89                	andi	a5,a5,2
ffffffffc0201100:	eb89                	bnez	a5,ffffffffc0201112 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201102:	00005797          	auipc	a5,0x5
ffffffffc0201106:	45678793          	addi	a5,a5,1110 # ffffffffc0206558 <pmm_manager>
ffffffffc020110a:	639c                	ld	a5,0(a5)
ffffffffc020110c:	0207b303          	ld	t1,32(a5)
ffffffffc0201110:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201112:	1101                	addi	sp,sp,-32
ffffffffc0201114:	ec06                	sd	ra,24(sp)
ffffffffc0201116:	e822                	sd	s0,16(sp)
ffffffffc0201118:	e426                	sd	s1,8(sp)
ffffffffc020111a:	842a                	mv	s0,a0
ffffffffc020111c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020111e:	b46ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201122:	00005797          	auipc	a5,0x5
ffffffffc0201126:	43678793          	addi	a5,a5,1078 # ffffffffc0206558 <pmm_manager>
ffffffffc020112a:	639c                	ld	a5,0(a5)
ffffffffc020112c:	85a6                	mv	a1,s1
ffffffffc020112e:	8522                	mv	a0,s0
ffffffffc0201130:	739c                	ld	a5,32(a5)
ffffffffc0201132:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201134:	6442                	ld	s0,16(sp)
ffffffffc0201136:	60e2                	ld	ra,24(sp)
ffffffffc0201138:	64a2                	ld	s1,8(sp)
ffffffffc020113a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020113c:	b22ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201140 <pmm_init>:
    pmm_manager=&buddy_pmm_manager_;
ffffffffc0201140:	00001797          	auipc	a5,0x1
ffffffffc0201144:	15878793          	addi	a5,a5,344 # ffffffffc0202298 <buddy_pmm_manager_>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201148:	638c                	ld	a1,0(a5)
        fppn=pa2page(mem_begin)-pages+nbase;
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020114a:	7139                	addi	sp,sp,-64
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020114c:	00001517          	auipc	a0,0x1
ffffffffc0201150:	1f450513          	addi	a0,a0,500 # ffffffffc0202340 <buddy_pmm_manager_+0xa8>
void pmm_init(void) {
ffffffffc0201154:	fc06                	sd	ra,56(sp)
    pmm_manager=&buddy_pmm_manager_;
ffffffffc0201156:	00005717          	auipc	a4,0x5
ffffffffc020115a:	40f73123          	sd	a5,1026(a4) # ffffffffc0206558 <pmm_manager>
void pmm_init(void) {
ffffffffc020115e:	f822                	sd	s0,48(sp)
ffffffffc0201160:	f426                	sd	s1,40(sp)
ffffffffc0201162:	ec4e                	sd	s3,24(sp)
ffffffffc0201164:	f04a                	sd	s2,32(sp)
ffffffffc0201166:	e852                	sd	s4,16(sp)
ffffffffc0201168:	e456                	sd	s5,8(sp)
    pmm_manager=&buddy_pmm_manager_;
ffffffffc020116a:	00005417          	auipc	s0,0x5
ffffffffc020116e:	3ee40413          	addi	s0,s0,1006 # ffffffffc0206558 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201172:	f45fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0201176:	601c                	ld	a5,0(s0)
ffffffffc0201178:	00005497          	auipc	s1,0x5
ffffffffc020117c:	2a048493          	addi	s1,s1,672 # ffffffffc0206418 <npage>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201180:	fff809b7          	lui	s3,0xfff80
    pmm_manager->init();
ffffffffc0201184:	679c                	ld	a5,8(a5)
ffffffffc0201186:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201188:	57f5                	li	a5,-3
ffffffffc020118a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020118c:	00001517          	auipc	a0,0x1
ffffffffc0201190:	1cc50513          	addi	a0,a0,460 # ffffffffc0202358 <buddy_pmm_manager_+0xc0>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201194:	00005717          	auipc	a4,0x5
ffffffffc0201198:	3cf73623          	sd	a5,972(a4) # ffffffffc0206560 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020119c:	f1bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02011a0:	46c5                	li	a3,17
ffffffffc02011a2:	06ee                	slli	a3,a3,0x1b
ffffffffc02011a4:	40100613          	li	a2,1025
ffffffffc02011a8:	16fd                	addi	a3,a3,-1
ffffffffc02011aa:	0656                	slli	a2,a2,0x15
ffffffffc02011ac:	07e005b7          	lui	a1,0x7e00
ffffffffc02011b0:	00001517          	auipc	a0,0x1
ffffffffc02011b4:	1c050513          	addi	a0,a0,448 # ffffffffc0202370 <buddy_pmm_manager_+0xd8>
ffffffffc02011b8:	efffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011bc:	777d                	lui	a4,0xfffff
ffffffffc02011be:	00006797          	auipc	a5,0x6
ffffffffc02011c2:	3b178793          	addi	a5,a5,945 # ffffffffc020756f <end+0xfff>
ffffffffc02011c6:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02011c8:	00088737          	lui	a4,0x88
ffffffffc02011cc:	00005697          	auipc	a3,0x5
ffffffffc02011d0:	24e6b623          	sd	a4,588(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011d4:	4601                	li	a2,0
ffffffffc02011d6:	00005717          	auipc	a4,0x5
ffffffffc02011da:	38f73923          	sd	a5,914(a4) # ffffffffc0206568 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011de:	4681                	li	a3,0
ffffffffc02011e0:	00005597          	auipc	a1,0x5
ffffffffc02011e4:	38858593          	addi	a1,a1,904 # ffffffffc0206568 <pages>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02011e8:	4505                	li	a0,1
ffffffffc02011ea:	a011                	j	ffffffffc02011ee <pmm_init+0xae>
ffffffffc02011ec:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc02011ee:	97b2                	add	a5,a5,a2
ffffffffc02011f0:	07a1                	addi	a5,a5,8
ffffffffc02011f2:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011f6:	6098                	ld	a4,0(s1)
ffffffffc02011f8:	0685                	addi	a3,a3,1
ffffffffc02011fa:	02860613          	addi	a2,a2,40
ffffffffc02011fe:	013707b3          	add	a5,a4,s3
ffffffffc0201202:	fef6e5e3          	bltu	a3,a5,ffffffffc02011ec <pmm_init+0xac>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201206:	6188                	ld	a0,0(a1)
ffffffffc0201208:	00271793          	slli	a5,a4,0x2
ffffffffc020120c:	97ba                	add	a5,a5,a4
ffffffffc020120e:	fec006b7          	lui	a3,0xfec00
ffffffffc0201212:	078e                	slli	a5,a5,0x3
ffffffffc0201214:	96aa                	add	a3,a3,a0
ffffffffc0201216:	96be                	add	a3,a3,a5
ffffffffc0201218:	c02007b7          	lui	a5,0xc0200
ffffffffc020121c:	0ef6e763          	bltu	a3,a5,ffffffffc020130a <pmm_init+0x1ca>
ffffffffc0201220:	00005a17          	auipc	s4,0x5
ffffffffc0201224:	340a0a13          	addi	s4,s4,832 # ffffffffc0206560 <va_pa_offset>
ffffffffc0201228:	000a3783          	ld	a5,0(s4)
    if (freemem < mem_end) {
ffffffffc020122c:	45c5                	li	a1,17
ffffffffc020122e:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201230:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0201232:	06b6f463          	bleu	a1,a3,ffffffffc020129a <pmm_init+0x15a>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201236:	6785                	lui	a5,0x1
ffffffffc0201238:	17fd                	addi	a5,a5,-1
ffffffffc020123a:	96be                	add	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020123c:	00c6da93          	srli	s5,a3,0xc
ffffffffc0201240:	0aeaf963          	bleu	a4,s5,ffffffffc02012f2 <pmm_init+0x1b2>
    pmm_manager->init_memmap(base, n);
ffffffffc0201244:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201246:	013a87b3          	add	a5,s5,s3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020124a:	767d                	lui	a2,0xfffff
ffffffffc020124c:	8ef1                	and	a3,a3,a2
ffffffffc020124e:	00279993          	slli	s3,a5,0x2
ffffffffc0201252:	40d586b3          	sub	a3,a1,a3
ffffffffc0201256:	99be                	add	s3,s3,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0201258:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020125a:	00c6d913          	srli	s2,a3,0xc
ffffffffc020125e:	098e                	slli	s3,s3,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201260:	954e                	add	a0,a0,s3
ffffffffc0201262:	85ca                	mv	a1,s2
ffffffffc0201264:	9782                	jalr	a5
        cprintf("size_t n is %d",(mem_end - mem_begin) / PGSIZE);
ffffffffc0201266:	85ca                	mv	a1,s2
ffffffffc0201268:	00001517          	auipc	a0,0x1
ffffffffc020126c:	1a050513          	addi	a0,a0,416 # ffffffffc0202408 <buddy_pmm_manager_+0x170>
ffffffffc0201270:	e47fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (PPN(pa) >= npage) {
ffffffffc0201274:	609c                	ld	a5,0(s1)
ffffffffc0201276:	06fafe63          	bleu	a5,s5,ffffffffc02012f2 <pmm_init+0x1b2>
        fppn=pa2page(mem_begin)-pages+nbase;
ffffffffc020127a:	00001797          	auipc	a5,0x1
ffffffffc020127e:	fce78793          	addi	a5,a5,-50 # ffffffffc0202248 <commands+0x860>
ffffffffc0201282:	639c                	ld	a5,0(a5)
ffffffffc0201284:	4039d993          	srai	s3,s3,0x3
ffffffffc0201288:	02f989b3          	mul	s3,s3,a5
ffffffffc020128c:	000807b7          	lui	a5,0x80
ffffffffc0201290:	99be                	add	s3,s3,a5
ffffffffc0201292:	00005797          	auipc	a5,0x5
ffffffffc0201296:	2b37bf23          	sd	s3,702(a5) # ffffffffc0206550 <fppn>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020129a:	601c                	ld	a5,0(s0)
ffffffffc020129c:	7b9c                	ld	a5,48(a5)
ffffffffc020129e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02012a0:	00001517          	auipc	a0,0x1
ffffffffc02012a4:	17850513          	addi	a0,a0,376 # ffffffffc0202418 <buddy_pmm_manager_+0x180>
ffffffffc02012a8:	e0ffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02012ac:	00004697          	auipc	a3,0x4
ffffffffc02012b0:	d5468693          	addi	a3,a3,-684 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02012b4:	00005797          	auipc	a5,0x5
ffffffffc02012b8:	16d7b623          	sd	a3,364(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02012bc:	c02007b7          	lui	a5,0xc0200
ffffffffc02012c0:	06f6e163          	bltu	a3,a5,ffffffffc0201322 <pmm_init+0x1e2>
ffffffffc02012c4:	000a3783          	ld	a5,0(s4)
}
ffffffffc02012c8:	7442                	ld	s0,48(sp)
ffffffffc02012ca:	70e2                	ld	ra,56(sp)
ffffffffc02012cc:	74a2                	ld	s1,40(sp)
ffffffffc02012ce:	7902                	ld	s2,32(sp)
ffffffffc02012d0:	69e2                	ld	s3,24(sp)
ffffffffc02012d2:	6a42                	ld	s4,16(sp)
ffffffffc02012d4:	6aa2                	ld	s5,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02012d6:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02012d8:	8e9d                	sub	a3,a3,a5
ffffffffc02012da:	00005797          	auipc	a5,0x5
ffffffffc02012de:	26d7b723          	sd	a3,622(a5) # ffffffffc0206548 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02012e2:	00001517          	auipc	a0,0x1
ffffffffc02012e6:	15650513          	addi	a0,a0,342 # ffffffffc0202438 <buddy_pmm_manager_+0x1a0>
ffffffffc02012ea:	8636                	mv	a2,a3
}
ffffffffc02012ec:	6121                	addi	sp,sp,64
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02012ee:	dc9fe06f          	j	ffffffffc02000b6 <cprintf>
        panic("pa2page called with invalid pa");
ffffffffc02012f2:	00001617          	auipc	a2,0x1
ffffffffc02012f6:	0e660613          	addi	a2,a2,230 # ffffffffc02023d8 <buddy_pmm_manager_+0x140>
ffffffffc02012fa:	06b00593          	li	a1,107
ffffffffc02012fe:	00001517          	auipc	a0,0x1
ffffffffc0201302:	0fa50513          	addi	a0,a0,250 # ffffffffc02023f8 <buddy_pmm_manager_+0x160>
ffffffffc0201306:	8a6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020130a:	00001617          	auipc	a2,0x1
ffffffffc020130e:	09660613          	addi	a2,a2,150 # ffffffffc02023a0 <buddy_pmm_manager_+0x108>
ffffffffc0201312:	07500593          	li	a1,117
ffffffffc0201316:	00001517          	auipc	a0,0x1
ffffffffc020131a:	0b250513          	addi	a0,a0,178 # ffffffffc02023c8 <buddy_pmm_manager_+0x130>
ffffffffc020131e:	88eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201322:	00001617          	auipc	a2,0x1
ffffffffc0201326:	07e60613          	addi	a2,a2,126 # ffffffffc02023a0 <buddy_pmm_manager_+0x108>
ffffffffc020132a:	09200593          	li	a1,146
ffffffffc020132e:	00001517          	auipc	a0,0x1
ffffffffc0201332:	09a50513          	addi	a0,a0,154 # ffffffffc02023c8 <buddy_pmm_manager_+0x130>
ffffffffc0201336:	876ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020133a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020133a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020133e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201340:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201344:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201346:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020134a:	f022                	sd	s0,32(sp)
ffffffffc020134c:	ec26                	sd	s1,24(sp)
ffffffffc020134e:	e84a                	sd	s2,16(sp)
ffffffffc0201350:	f406                	sd	ra,40(sp)
ffffffffc0201352:	e44e                	sd	s3,8(sp)
ffffffffc0201354:	84aa                	mv	s1,a0
ffffffffc0201356:	892e                	mv	s2,a1
ffffffffc0201358:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020135c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020135e:	03067e63          	bleu	a6,a2,ffffffffc020139a <printnum+0x60>
ffffffffc0201362:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201364:	00805763          	blez	s0,ffffffffc0201372 <printnum+0x38>
ffffffffc0201368:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020136a:	85ca                	mv	a1,s2
ffffffffc020136c:	854e                	mv	a0,s3
ffffffffc020136e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201370:	fc65                	bnez	s0,ffffffffc0201368 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201372:	1a02                	slli	s4,s4,0x20
ffffffffc0201374:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201378:	00001797          	auipc	a5,0x1
ffffffffc020137c:	29078793          	addi	a5,a5,656 # ffffffffc0202608 <error_string+0x38>
ffffffffc0201380:	9a3e                	add	s4,s4,a5
}
ffffffffc0201382:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201384:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201388:	70a2                	ld	ra,40(sp)
ffffffffc020138a:	69a2                	ld	s3,8(sp)
ffffffffc020138c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020138e:	85ca                	mv	a1,s2
ffffffffc0201390:	8326                	mv	t1,s1
}
ffffffffc0201392:	6942                	ld	s2,16(sp)
ffffffffc0201394:	64e2                	ld	s1,24(sp)
ffffffffc0201396:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201398:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020139a:	03065633          	divu	a2,a2,a6
ffffffffc020139e:	8722                	mv	a4,s0
ffffffffc02013a0:	f9bff0ef          	jal	ra,ffffffffc020133a <printnum>
ffffffffc02013a4:	b7f9                	j	ffffffffc0201372 <printnum+0x38>

ffffffffc02013a6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02013a6:	7119                	addi	sp,sp,-128
ffffffffc02013a8:	f4a6                	sd	s1,104(sp)
ffffffffc02013aa:	f0ca                	sd	s2,96(sp)
ffffffffc02013ac:	e8d2                	sd	s4,80(sp)
ffffffffc02013ae:	e4d6                	sd	s5,72(sp)
ffffffffc02013b0:	e0da                	sd	s6,64(sp)
ffffffffc02013b2:	fc5e                	sd	s7,56(sp)
ffffffffc02013b4:	f862                	sd	s8,48(sp)
ffffffffc02013b6:	f06a                	sd	s10,32(sp)
ffffffffc02013b8:	fc86                	sd	ra,120(sp)
ffffffffc02013ba:	f8a2                	sd	s0,112(sp)
ffffffffc02013bc:	ecce                	sd	s3,88(sp)
ffffffffc02013be:	f466                	sd	s9,40(sp)
ffffffffc02013c0:	ec6e                	sd	s11,24(sp)
ffffffffc02013c2:	892a                	mv	s2,a0
ffffffffc02013c4:	84ae                	mv	s1,a1
ffffffffc02013c6:	8d32                	mv	s10,a2
ffffffffc02013c8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02013ca:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013cc:	00001a17          	auipc	s4,0x1
ffffffffc02013d0:	0aca0a13          	addi	s4,s4,172 # ffffffffc0202478 <buddy_pmm_manager_+0x1e0>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013d4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013d8:	00001c17          	auipc	s8,0x1
ffffffffc02013dc:	1f8c0c13          	addi	s8,s8,504 # ffffffffc02025d0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013e0:	000d4503          	lbu	a0,0(s10)
ffffffffc02013e4:	02500793          	li	a5,37
ffffffffc02013e8:	001d0413          	addi	s0,s10,1
ffffffffc02013ec:	00f50e63          	beq	a0,a5,ffffffffc0201408 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02013f0:	c521                	beqz	a0,ffffffffc0201438 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013f2:	02500993          	li	s3,37
ffffffffc02013f6:	a011                	j	ffffffffc02013fa <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02013f8:	c121                	beqz	a0,ffffffffc0201438 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02013fa:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013fc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02013fe:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201400:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201404:	ff351ae3          	bne	a0,s3,ffffffffc02013f8 <vprintfmt+0x52>
ffffffffc0201408:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020140c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201410:	4981                	li	s3,0
ffffffffc0201412:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201414:	5cfd                	li	s9,-1
ffffffffc0201416:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201418:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020141c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020141e:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201422:	0ff6f693          	andi	a3,a3,255
ffffffffc0201426:	00140d13          	addi	s10,s0,1
ffffffffc020142a:	20d5e563          	bltu	a1,a3,ffffffffc0201634 <vprintfmt+0x28e>
ffffffffc020142e:	068a                	slli	a3,a3,0x2
ffffffffc0201430:	96d2                	add	a3,a3,s4
ffffffffc0201432:	4294                	lw	a3,0(a3)
ffffffffc0201434:	96d2                	add	a3,a3,s4
ffffffffc0201436:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201438:	70e6                	ld	ra,120(sp)
ffffffffc020143a:	7446                	ld	s0,112(sp)
ffffffffc020143c:	74a6                	ld	s1,104(sp)
ffffffffc020143e:	7906                	ld	s2,96(sp)
ffffffffc0201440:	69e6                	ld	s3,88(sp)
ffffffffc0201442:	6a46                	ld	s4,80(sp)
ffffffffc0201444:	6aa6                	ld	s5,72(sp)
ffffffffc0201446:	6b06                	ld	s6,64(sp)
ffffffffc0201448:	7be2                	ld	s7,56(sp)
ffffffffc020144a:	7c42                	ld	s8,48(sp)
ffffffffc020144c:	7ca2                	ld	s9,40(sp)
ffffffffc020144e:	7d02                	ld	s10,32(sp)
ffffffffc0201450:	6de2                	ld	s11,24(sp)
ffffffffc0201452:	6109                	addi	sp,sp,128
ffffffffc0201454:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201456:	4705                	li	a4,1
ffffffffc0201458:	008a8593          	addi	a1,s5,8
ffffffffc020145c:	01074463          	blt	a4,a6,ffffffffc0201464 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201460:	26080363          	beqz	a6,ffffffffc02016c6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201464:	000ab603          	ld	a2,0(s5)
ffffffffc0201468:	46c1                	li	a3,16
ffffffffc020146a:	8aae                	mv	s5,a1
ffffffffc020146c:	a06d                	j	ffffffffc0201516 <vprintfmt+0x170>
            goto reswitch;
ffffffffc020146e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201472:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201474:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201476:	b765                	j	ffffffffc020141e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201478:	000aa503          	lw	a0,0(s5)
ffffffffc020147c:	85a6                	mv	a1,s1
ffffffffc020147e:	0aa1                	addi	s5,s5,8
ffffffffc0201480:	9902                	jalr	s2
            break;
ffffffffc0201482:	bfb9                	j	ffffffffc02013e0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201484:	4705                	li	a4,1
ffffffffc0201486:	008a8993          	addi	s3,s5,8
ffffffffc020148a:	01074463          	blt	a4,a6,ffffffffc0201492 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc020148e:	22080463          	beqz	a6,ffffffffc02016b6 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201492:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201496:	24044463          	bltz	s0,ffffffffc02016de <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020149a:	8622                	mv	a2,s0
ffffffffc020149c:	8ace                	mv	s5,s3
ffffffffc020149e:	46a9                	li	a3,10
ffffffffc02014a0:	a89d                	j	ffffffffc0201516 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02014a2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014a6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02014a8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02014aa:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02014ae:	8fb5                	xor	a5,a5,a3
ffffffffc02014b0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014b4:	1ad74363          	blt	a4,a3,ffffffffc020165a <vprintfmt+0x2b4>
ffffffffc02014b8:	00369793          	slli	a5,a3,0x3
ffffffffc02014bc:	97e2                	add	a5,a5,s8
ffffffffc02014be:	639c                	ld	a5,0(a5)
ffffffffc02014c0:	18078d63          	beqz	a5,ffffffffc020165a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02014c4:	86be                	mv	a3,a5
ffffffffc02014c6:	00001617          	auipc	a2,0x1
ffffffffc02014ca:	1f260613          	addi	a2,a2,498 # ffffffffc02026b8 <error_string+0xe8>
ffffffffc02014ce:	85a6                	mv	a1,s1
ffffffffc02014d0:	854a                	mv	a0,s2
ffffffffc02014d2:	240000ef          	jal	ra,ffffffffc0201712 <printfmt>
ffffffffc02014d6:	b729                	j	ffffffffc02013e0 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02014d8:	00144603          	lbu	a2,1(s0)
ffffffffc02014dc:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014de:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014e0:	bf3d                	j	ffffffffc020141e <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02014e2:	4705                	li	a4,1
ffffffffc02014e4:	008a8593          	addi	a1,s5,8
ffffffffc02014e8:	01074463          	blt	a4,a6,ffffffffc02014f0 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02014ec:	1e080263          	beqz	a6,ffffffffc02016d0 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02014f0:	000ab603          	ld	a2,0(s5)
ffffffffc02014f4:	46a1                	li	a3,8
ffffffffc02014f6:	8aae                	mv	s5,a1
ffffffffc02014f8:	a839                	j	ffffffffc0201516 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02014fa:	03000513          	li	a0,48
ffffffffc02014fe:	85a6                	mv	a1,s1
ffffffffc0201500:	e03e                	sd	a5,0(sp)
ffffffffc0201502:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201504:	85a6                	mv	a1,s1
ffffffffc0201506:	07800513          	li	a0,120
ffffffffc020150a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020150c:	0aa1                	addi	s5,s5,8
ffffffffc020150e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201512:	6782                	ld	a5,0(sp)
ffffffffc0201514:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201516:	876e                	mv	a4,s11
ffffffffc0201518:	85a6                	mv	a1,s1
ffffffffc020151a:	854a                	mv	a0,s2
ffffffffc020151c:	e1fff0ef          	jal	ra,ffffffffc020133a <printnum>
            break;
ffffffffc0201520:	b5c1                	j	ffffffffc02013e0 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201522:	000ab603          	ld	a2,0(s5)
ffffffffc0201526:	0aa1                	addi	s5,s5,8
ffffffffc0201528:	1c060663          	beqz	a2,ffffffffc02016f4 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020152c:	00160413          	addi	s0,a2,1
ffffffffc0201530:	17b05c63          	blez	s11,ffffffffc02016a8 <vprintfmt+0x302>
ffffffffc0201534:	02d00593          	li	a1,45
ffffffffc0201538:	14b79263          	bne	a5,a1,ffffffffc020167c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020153c:	00064783          	lbu	a5,0(a2)
ffffffffc0201540:	0007851b          	sext.w	a0,a5
ffffffffc0201544:	c905                	beqz	a0,ffffffffc0201574 <vprintfmt+0x1ce>
ffffffffc0201546:	000cc563          	bltz	s9,ffffffffc0201550 <vprintfmt+0x1aa>
ffffffffc020154a:	3cfd                	addiw	s9,s9,-1
ffffffffc020154c:	036c8263          	beq	s9,s6,ffffffffc0201570 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201550:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201552:	18098463          	beqz	s3,ffffffffc02016da <vprintfmt+0x334>
ffffffffc0201556:	3781                	addiw	a5,a5,-32
ffffffffc0201558:	18fbf163          	bleu	a5,s7,ffffffffc02016da <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020155c:	03f00513          	li	a0,63
ffffffffc0201560:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201562:	0405                	addi	s0,s0,1
ffffffffc0201564:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201568:	3dfd                	addiw	s11,s11,-1
ffffffffc020156a:	0007851b          	sext.w	a0,a5
ffffffffc020156e:	fd61                	bnez	a0,ffffffffc0201546 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201570:	e7b058e3          	blez	s11,ffffffffc02013e0 <vprintfmt+0x3a>
ffffffffc0201574:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201576:	85a6                	mv	a1,s1
ffffffffc0201578:	02000513          	li	a0,32
ffffffffc020157c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020157e:	e60d81e3          	beqz	s11,ffffffffc02013e0 <vprintfmt+0x3a>
ffffffffc0201582:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201584:	85a6                	mv	a1,s1
ffffffffc0201586:	02000513          	li	a0,32
ffffffffc020158a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020158c:	fe0d94e3          	bnez	s11,ffffffffc0201574 <vprintfmt+0x1ce>
ffffffffc0201590:	bd81                	j	ffffffffc02013e0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201592:	4705                	li	a4,1
ffffffffc0201594:	008a8593          	addi	a1,s5,8
ffffffffc0201598:	01074463          	blt	a4,a6,ffffffffc02015a0 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020159c:	12080063          	beqz	a6,ffffffffc02016bc <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02015a0:	000ab603          	ld	a2,0(s5)
ffffffffc02015a4:	46a9                	li	a3,10
ffffffffc02015a6:	8aae                	mv	s5,a1
ffffffffc02015a8:	b7bd                	j	ffffffffc0201516 <vprintfmt+0x170>
ffffffffc02015aa:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02015ae:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015b2:	846a                	mv	s0,s10
ffffffffc02015b4:	b5ad                	j	ffffffffc020141e <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02015b6:	85a6                	mv	a1,s1
ffffffffc02015b8:	02500513          	li	a0,37
ffffffffc02015bc:	9902                	jalr	s2
            break;
ffffffffc02015be:	b50d                	j	ffffffffc02013e0 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02015c0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02015c4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02015c8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015ca:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02015cc:	e40dd9e3          	bgez	s11,ffffffffc020141e <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02015d0:	8de6                	mv	s11,s9
ffffffffc02015d2:	5cfd                	li	s9,-1
ffffffffc02015d4:	b5a9                	j	ffffffffc020141e <vprintfmt+0x78>
            goto reswitch;
ffffffffc02015d6:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02015da:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015de:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02015e0:	bd3d                	j	ffffffffc020141e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02015e2:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02015e6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015ea:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02015ec:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02015f0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015f4:	fcd56ce3          	bltu	a0,a3,ffffffffc02015cc <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02015f8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02015fa:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02015fe:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201602:	0196873b          	addw	a4,a3,s9
ffffffffc0201606:	0017171b          	slliw	a4,a4,0x1
ffffffffc020160a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020160e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201612:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201616:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020161a:	fcd57fe3          	bleu	a3,a0,ffffffffc02015f8 <vprintfmt+0x252>
ffffffffc020161e:	b77d                	j	ffffffffc02015cc <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201620:	fffdc693          	not	a3,s11
ffffffffc0201624:	96fd                	srai	a3,a3,0x3f
ffffffffc0201626:	00ddfdb3          	and	s11,s11,a3
ffffffffc020162a:	00144603          	lbu	a2,1(s0)
ffffffffc020162e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201630:	846a                	mv	s0,s10
ffffffffc0201632:	b3f5                	j	ffffffffc020141e <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201634:	85a6                	mv	a1,s1
ffffffffc0201636:	02500513          	li	a0,37
ffffffffc020163a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020163c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201640:	02500793          	li	a5,37
ffffffffc0201644:	8d22                	mv	s10,s0
ffffffffc0201646:	d8f70de3          	beq	a4,a5,ffffffffc02013e0 <vprintfmt+0x3a>
ffffffffc020164a:	02500713          	li	a4,37
ffffffffc020164e:	1d7d                	addi	s10,s10,-1
ffffffffc0201650:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201654:	fee79de3          	bne	a5,a4,ffffffffc020164e <vprintfmt+0x2a8>
ffffffffc0201658:	b361                	j	ffffffffc02013e0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020165a:	00001617          	auipc	a2,0x1
ffffffffc020165e:	04e60613          	addi	a2,a2,78 # ffffffffc02026a8 <error_string+0xd8>
ffffffffc0201662:	85a6                	mv	a1,s1
ffffffffc0201664:	854a                	mv	a0,s2
ffffffffc0201666:	0ac000ef          	jal	ra,ffffffffc0201712 <printfmt>
ffffffffc020166a:	bb9d                	j	ffffffffc02013e0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020166c:	00001617          	auipc	a2,0x1
ffffffffc0201670:	03460613          	addi	a2,a2,52 # ffffffffc02026a0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201674:	00001417          	auipc	s0,0x1
ffffffffc0201678:	02d40413          	addi	s0,s0,45 # ffffffffc02026a1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020167c:	8532                	mv	a0,a2
ffffffffc020167e:	85e6                	mv	a1,s9
ffffffffc0201680:	e032                	sd	a2,0(sp)
ffffffffc0201682:	e43e                	sd	a5,8(sp)
ffffffffc0201684:	1c2000ef          	jal	ra,ffffffffc0201846 <strnlen>
ffffffffc0201688:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020168c:	6602                	ld	a2,0(sp)
ffffffffc020168e:	01b05d63          	blez	s11,ffffffffc02016a8 <vprintfmt+0x302>
ffffffffc0201692:	67a2                	ld	a5,8(sp)
ffffffffc0201694:	2781                	sext.w	a5,a5
ffffffffc0201696:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201698:	6522                	ld	a0,8(sp)
ffffffffc020169a:	85a6                	mv	a1,s1
ffffffffc020169c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020169e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02016a0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016a2:	6602                	ld	a2,0(sp)
ffffffffc02016a4:	fe0d9ae3          	bnez	s11,ffffffffc0201698 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016a8:	00064783          	lbu	a5,0(a2)
ffffffffc02016ac:	0007851b          	sext.w	a0,a5
ffffffffc02016b0:	e8051be3          	bnez	a0,ffffffffc0201546 <vprintfmt+0x1a0>
ffffffffc02016b4:	b335                	j	ffffffffc02013e0 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02016b6:	000aa403          	lw	s0,0(s5)
ffffffffc02016ba:	bbf1                	j	ffffffffc0201496 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02016bc:	000ae603          	lwu	a2,0(s5)
ffffffffc02016c0:	46a9                	li	a3,10
ffffffffc02016c2:	8aae                	mv	s5,a1
ffffffffc02016c4:	bd89                	j	ffffffffc0201516 <vprintfmt+0x170>
ffffffffc02016c6:	000ae603          	lwu	a2,0(s5)
ffffffffc02016ca:	46c1                	li	a3,16
ffffffffc02016cc:	8aae                	mv	s5,a1
ffffffffc02016ce:	b5a1                	j	ffffffffc0201516 <vprintfmt+0x170>
ffffffffc02016d0:	000ae603          	lwu	a2,0(s5)
ffffffffc02016d4:	46a1                	li	a3,8
ffffffffc02016d6:	8aae                	mv	s5,a1
ffffffffc02016d8:	bd3d                	j	ffffffffc0201516 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02016da:	9902                	jalr	s2
ffffffffc02016dc:	b559                	j	ffffffffc0201562 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02016de:	85a6                	mv	a1,s1
ffffffffc02016e0:	02d00513          	li	a0,45
ffffffffc02016e4:	e03e                	sd	a5,0(sp)
ffffffffc02016e6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02016e8:	8ace                	mv	s5,s3
ffffffffc02016ea:	40800633          	neg	a2,s0
ffffffffc02016ee:	46a9                	li	a3,10
ffffffffc02016f0:	6782                	ld	a5,0(sp)
ffffffffc02016f2:	b515                	j	ffffffffc0201516 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02016f4:	01b05663          	blez	s11,ffffffffc0201700 <vprintfmt+0x35a>
ffffffffc02016f8:	02d00693          	li	a3,45
ffffffffc02016fc:	f6d798e3          	bne	a5,a3,ffffffffc020166c <vprintfmt+0x2c6>
ffffffffc0201700:	00001417          	auipc	s0,0x1
ffffffffc0201704:	fa140413          	addi	s0,s0,-95 # ffffffffc02026a1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201708:	02800513          	li	a0,40
ffffffffc020170c:	02800793          	li	a5,40
ffffffffc0201710:	bd1d                	j	ffffffffc0201546 <vprintfmt+0x1a0>

ffffffffc0201712 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201712:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201714:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201718:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020171a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020171c:	ec06                	sd	ra,24(sp)
ffffffffc020171e:	f83a                	sd	a4,48(sp)
ffffffffc0201720:	fc3e                	sd	a5,56(sp)
ffffffffc0201722:	e0c2                	sd	a6,64(sp)
ffffffffc0201724:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201726:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201728:	c7fff0ef          	jal	ra,ffffffffc02013a6 <vprintfmt>
}
ffffffffc020172c:	60e2                	ld	ra,24(sp)
ffffffffc020172e:	6161                	addi	sp,sp,80
ffffffffc0201730:	8082                	ret

ffffffffc0201732 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201732:	715d                	addi	sp,sp,-80
ffffffffc0201734:	e486                	sd	ra,72(sp)
ffffffffc0201736:	e0a2                	sd	s0,64(sp)
ffffffffc0201738:	fc26                	sd	s1,56(sp)
ffffffffc020173a:	f84a                	sd	s2,48(sp)
ffffffffc020173c:	f44e                	sd	s3,40(sp)
ffffffffc020173e:	f052                	sd	s4,32(sp)
ffffffffc0201740:	ec56                	sd	s5,24(sp)
ffffffffc0201742:	e85a                	sd	s6,16(sp)
ffffffffc0201744:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201746:	c901                	beqz	a0,ffffffffc0201756 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201748:	85aa                	mv	a1,a0
ffffffffc020174a:	00001517          	auipc	a0,0x1
ffffffffc020174e:	f6e50513          	addi	a0,a0,-146 # ffffffffc02026b8 <error_string+0xe8>
ffffffffc0201752:	965fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201756:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201758:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020175a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020175c:	4aa9                	li	s5,10
ffffffffc020175e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201760:	00005b97          	auipc	s7,0x5
ffffffffc0201764:	8b0b8b93          	addi	s7,s7,-1872 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201768:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020176c:	9c3fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201770:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201772:	00054b63          	bltz	a0,ffffffffc0201788 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201776:	00a95b63          	ble	a0,s2,ffffffffc020178c <readline+0x5a>
ffffffffc020177a:	029a5463          	ble	s1,s4,ffffffffc02017a2 <readline+0x70>
        c = getchar();
ffffffffc020177e:	9b1fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201782:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201784:	fe0559e3          	bgez	a0,ffffffffc0201776 <readline+0x44>
            return NULL;
ffffffffc0201788:	4501                	li	a0,0
ffffffffc020178a:	a099                	j	ffffffffc02017d0 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc020178c:	03341463          	bne	s0,s3,ffffffffc02017b4 <readline+0x82>
ffffffffc0201790:	e8b9                	bnez	s1,ffffffffc02017e6 <readline+0xb4>
        c = getchar();
ffffffffc0201792:	99dfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201796:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201798:	fe0548e3          	bltz	a0,ffffffffc0201788 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020179c:	fea958e3          	ble	a0,s2,ffffffffc020178c <readline+0x5a>
ffffffffc02017a0:	4481                	li	s1,0
            cputchar(c);
ffffffffc02017a2:	8522                	mv	a0,s0
ffffffffc02017a4:	947fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02017a8:	009b87b3          	add	a5,s7,s1
ffffffffc02017ac:	00878023          	sb	s0,0(a5)
ffffffffc02017b0:	2485                	addiw	s1,s1,1
ffffffffc02017b2:	bf6d                	j	ffffffffc020176c <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02017b4:	01540463          	beq	s0,s5,ffffffffc02017bc <readline+0x8a>
ffffffffc02017b8:	fb641ae3          	bne	s0,s6,ffffffffc020176c <readline+0x3a>
            cputchar(c);
ffffffffc02017bc:	8522                	mv	a0,s0
ffffffffc02017be:	92dfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02017c2:	00005517          	auipc	a0,0x5
ffffffffc02017c6:	84e50513          	addi	a0,a0,-1970 # ffffffffc0206010 <edata>
ffffffffc02017ca:	94aa                	add	s1,s1,a0
ffffffffc02017cc:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02017d0:	60a6                	ld	ra,72(sp)
ffffffffc02017d2:	6406                	ld	s0,64(sp)
ffffffffc02017d4:	74e2                	ld	s1,56(sp)
ffffffffc02017d6:	7942                	ld	s2,48(sp)
ffffffffc02017d8:	79a2                	ld	s3,40(sp)
ffffffffc02017da:	7a02                	ld	s4,32(sp)
ffffffffc02017dc:	6ae2                	ld	s5,24(sp)
ffffffffc02017de:	6b42                	ld	s6,16(sp)
ffffffffc02017e0:	6ba2                	ld	s7,8(sp)
ffffffffc02017e2:	6161                	addi	sp,sp,80
ffffffffc02017e4:	8082                	ret
            cputchar(c);
ffffffffc02017e6:	4521                	li	a0,8
ffffffffc02017e8:	903fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc02017ec:	34fd                	addiw	s1,s1,-1
ffffffffc02017ee:	bfbd                	j	ffffffffc020176c <readline+0x3a>

ffffffffc02017f0 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc02017f0:	00005797          	auipc	a5,0x5
ffffffffc02017f4:	81878793          	addi	a5,a5,-2024 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc02017f8:	6398                	ld	a4,0(a5)
ffffffffc02017fa:	4781                	li	a5,0
ffffffffc02017fc:	88ba                	mv	a7,a4
ffffffffc02017fe:	852a                	mv	a0,a0
ffffffffc0201800:	85be                	mv	a1,a5
ffffffffc0201802:	863e                	mv	a2,a5
ffffffffc0201804:	00000073          	ecall
ffffffffc0201808:	87aa                	mv	a5,a0
}
ffffffffc020180a:	8082                	ret

ffffffffc020180c <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc020180c:	00005797          	auipc	a5,0x5
ffffffffc0201810:	c1c78793          	addi	a5,a5,-996 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201814:	6398                	ld	a4,0(a5)
ffffffffc0201816:	4781                	li	a5,0
ffffffffc0201818:	88ba                	mv	a7,a4
ffffffffc020181a:	852a                	mv	a0,a0
ffffffffc020181c:	85be                	mv	a1,a5
ffffffffc020181e:	863e                	mv	a2,a5
ffffffffc0201820:	00000073          	ecall
ffffffffc0201824:	87aa                	mv	a5,a0
}
ffffffffc0201826:	8082                	ret

ffffffffc0201828 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201828:	00004797          	auipc	a5,0x4
ffffffffc020182c:	7d878793          	addi	a5,a5,2008 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201830:	639c                	ld	a5,0(a5)
ffffffffc0201832:	4501                	li	a0,0
ffffffffc0201834:	88be                	mv	a7,a5
ffffffffc0201836:	852a                	mv	a0,a0
ffffffffc0201838:	85aa                	mv	a1,a0
ffffffffc020183a:	862a                	mv	a2,a0
ffffffffc020183c:	00000073          	ecall
ffffffffc0201840:	852a                	mv	a0,a0
ffffffffc0201842:	2501                	sext.w	a0,a0
ffffffffc0201844:	8082                	ret

ffffffffc0201846 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201846:	c185                	beqz	a1,ffffffffc0201866 <strnlen+0x20>
ffffffffc0201848:	00054783          	lbu	a5,0(a0)
ffffffffc020184c:	cf89                	beqz	a5,ffffffffc0201866 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020184e:	4781                	li	a5,0
ffffffffc0201850:	a021                	j	ffffffffc0201858 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201852:	00074703          	lbu	a4,0(a4)
ffffffffc0201856:	c711                	beqz	a4,ffffffffc0201862 <strnlen+0x1c>
        cnt ++;
ffffffffc0201858:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020185a:	00f50733          	add	a4,a0,a5
ffffffffc020185e:	fef59ae3          	bne	a1,a5,ffffffffc0201852 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201862:	853e                	mv	a0,a5
ffffffffc0201864:	8082                	ret
    size_t cnt = 0;
ffffffffc0201866:	4781                	li	a5,0
}
ffffffffc0201868:	853e                	mv	a0,a5
ffffffffc020186a:	8082                	ret

ffffffffc020186c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020186c:	00054783          	lbu	a5,0(a0)
ffffffffc0201870:	0005c703          	lbu	a4,0(a1)
ffffffffc0201874:	cb91                	beqz	a5,ffffffffc0201888 <strcmp+0x1c>
ffffffffc0201876:	00e79c63          	bne	a5,a4,ffffffffc020188e <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020187a:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020187c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201880:	0585                	addi	a1,a1,1
ffffffffc0201882:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201886:	fbe5                	bnez	a5,ffffffffc0201876 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201888:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020188a:	9d19                	subw	a0,a0,a4
ffffffffc020188c:	8082                	ret
ffffffffc020188e:	0007851b          	sext.w	a0,a5
ffffffffc0201892:	9d19                	subw	a0,a0,a4
ffffffffc0201894:	8082                	ret

ffffffffc0201896 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201896:	00054783          	lbu	a5,0(a0)
ffffffffc020189a:	cb91                	beqz	a5,ffffffffc02018ae <strchr+0x18>
        if (*s == c) {
ffffffffc020189c:	00b79563          	bne	a5,a1,ffffffffc02018a6 <strchr+0x10>
ffffffffc02018a0:	a809                	j	ffffffffc02018b2 <strchr+0x1c>
ffffffffc02018a2:	00b78763          	beq	a5,a1,ffffffffc02018b0 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02018a6:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02018a8:	00054783          	lbu	a5,0(a0)
ffffffffc02018ac:	fbfd                	bnez	a5,ffffffffc02018a2 <strchr+0xc>
    }
    return NULL;
ffffffffc02018ae:	4501                	li	a0,0
}
ffffffffc02018b0:	8082                	ret
ffffffffc02018b2:	8082                	ret

ffffffffc02018b4 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02018b4:	ca01                	beqz	a2,ffffffffc02018c4 <memset+0x10>
ffffffffc02018b6:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02018b8:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02018ba:	0785                	addi	a5,a5,1
ffffffffc02018bc:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02018c0:	fec79de3          	bne	a5,a2,ffffffffc02018ba <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02018c4:	8082                	ret
