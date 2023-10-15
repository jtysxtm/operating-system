
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
ffffffffc020004e:	2b3010ef          	jal	ra,ffffffffc0201b00 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	ac250513          	addi	a0,a0,-1342 # ffffffffc0201b18 <etext+0x6>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	322010ef          	jal	ra,ffffffffc020138c <pmm_init>

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
ffffffffc02000aa:	548010ef          	jal	ra,ffffffffc02015f2 <vprintfmt>
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
ffffffffc02000de:	514010ef          	jal	ra,ffffffffc02015f2 <vprintfmt>
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
ffffffffc0200144:	a2850513          	addi	a0,a0,-1496 # ffffffffc0201b68 <etext+0x56>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	a3250513          	addi	a0,a0,-1486 # ffffffffc0201b88 <etext+0x76>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00002597          	auipc	a1,0x2
ffffffffc0200166:	9b058593          	addi	a1,a1,-1616 # ffffffffc0201b12 <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0201ba8 <etext+0x96>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0201bc8 <etext+0xb6>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	2ee58593          	addi	a1,a1,750 # ffffffffc0206478 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	a5650513          	addi	a0,a0,-1450 # ffffffffc0201be8 <etext+0xd6>
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
ffffffffc02001c4:	a4850513          	addi	a0,a0,-1464 # ffffffffc0201c08 <etext+0xf6>
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
ffffffffc02001d0:	00002617          	auipc	a2,0x2
ffffffffc02001d4:	96860613          	addi	a2,a2,-1688 # ffffffffc0201b38 <etext+0x26>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00002517          	auipc	a0,0x2
ffffffffc02001e0:	97450513          	addi	a0,a0,-1676 # ffffffffc0201b50 <etext+0x3e>
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
ffffffffc02001f0:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0201d18 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	b4458593          	addi	a1,a1,-1212 # ffffffffc0201d38 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	b4450513          	addi	a0,a0,-1212 # ffffffffc0201d40 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	b4660613          	addi	a2,a2,-1210 # ffffffffc0201d50 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	b6658593          	addi	a1,a1,-1178 # ffffffffc0201d78 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	b2650513          	addi	a0,a0,-1242 # ffffffffc0201d40 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	b6260613          	addi	a2,a2,-1182 # ffffffffc0201d88 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	b7a58593          	addi	a1,a1,-1158 # ffffffffc0201da8 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0201d40 <commands+0x108>
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
ffffffffc0200274:	a1050513          	addi	a0,a0,-1520 # ffffffffc0201c80 <commands+0x48>
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
ffffffffc0200296:	a1650513          	addi	a0,a0,-1514 # ffffffffc0201ca8 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00002c97          	auipc	s9,0x2
ffffffffc02002ac:	990c8c93          	addi	s9,s9,-1648 # ffffffffc0201c38 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00002997          	auipc	s3,0x2
ffffffffc02002b4:	a2098993          	addi	s3,s3,-1504 # ffffffffc0201cd0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00002917          	auipc	s2,0x2
ffffffffc02002bc:	a2090913          	addi	s2,s2,-1504 # ffffffffc0201cd8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00002b17          	auipc	s6,0x2
ffffffffc02002c6:	a1eb0b13          	addi	s6,s6,-1506 # ffffffffc0201ce0 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	a6ea8a93          	addi	s5,s5,-1426 # ffffffffc0201d38 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	6a8010ef          	jal	ra,ffffffffc020197e <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	7fa010ef          	jal	ra,ffffffffc0201ae2 <strchr>
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
ffffffffc02002fe:	00002d17          	auipc	s10,0x2
ffffffffc0200302:	93ad0d13          	addi	s10,s10,-1734 # ffffffffc0201c38 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	7ac010ef          	jal	ra,ffffffffc0201ab8 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	798010ef          	jal	ra,ffffffffc0201ab8 <strcmp>
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
ffffffffc0200386:	75c010ef          	jal	ra,ffffffffc0201ae2 <strchr>
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
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	96250513          	addi	a0,a0,-1694 # ffffffffc0201d00 <commands+0xc8>
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
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	9da50513          	addi	a0,a0,-1574 # ffffffffc0201db8 <commands+0x180>
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
ffffffffc02003f8:	83c50513          	addi	a0,a0,-1988 # ffffffffc0201c30 <etext+0x11e>
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
ffffffffc0200424:	634010ef          	jal	ra,ffffffffc0201a58 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	9a650513          	addi	a0,a0,-1626 # ffffffffc0201dd8 <commands+0x1a0>
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
ffffffffc020044c:	60c0106f          	j	ffffffffc0201a58 <sbi_set_timer>

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
ffffffffc0200456:	5e60106f          	j	ffffffffc0201a3c <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	61a0106f          	j	ffffffffc0201a74 <sbi_console_getchar>

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
ffffffffc0200488:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0201ef0 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	a7450513          	addi	a0,a0,-1420 # ffffffffc0201f08 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0201f20 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	a8850513          	addi	a0,a0,-1400 # ffffffffc0201f38 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	a9250513          	addi	a0,a0,-1390 # ffffffffc0201f50 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0201f68 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	aa650513          	addi	a0,a0,-1370 # ffffffffc0201f80 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	ab050513          	addi	a0,a0,-1360 # ffffffffc0201f98 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	aba50513          	addi	a0,a0,-1350 # ffffffffc0201fb0 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	ac450513          	addi	a0,a0,-1340 # ffffffffc0201fc8 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	ace50513          	addi	a0,a0,-1330 # ffffffffc0201fe0 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	ad850513          	addi	a0,a0,-1320 # ffffffffc0201ff8 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	ae250513          	addi	a0,a0,-1310 # ffffffffc0202010 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	aec50513          	addi	a0,a0,-1300 # ffffffffc0202028 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	af650513          	addi	a0,a0,-1290 # ffffffffc0202040 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0202058 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0202070 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	b1450513          	addi	a0,a0,-1260 # ffffffffc0202088 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	b1e50513          	addi	a0,a0,-1250 # ffffffffc02020a0 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	b2850513          	addi	a0,a0,-1240 # ffffffffc02020b8 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	b3250513          	addi	a0,a0,-1230 # ffffffffc02020d0 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	b3c50513          	addi	a0,a0,-1220 # ffffffffc02020e8 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	b4650513          	addi	a0,a0,-1210 # ffffffffc0202100 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	b5050513          	addi	a0,a0,-1200 # ffffffffc0202118 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0202130 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	b6450513          	addi	a0,a0,-1180 # ffffffffc0202148 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0202160 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	b7850513          	addi	a0,a0,-1160 # ffffffffc0202178 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	b8250513          	addi	a0,a0,-1150 # ffffffffc0202190 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	b8c50513          	addi	a0,a0,-1140 # ffffffffc02021a8 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	b9650513          	addi	a0,a0,-1130 # ffffffffc02021c0 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	b9c50513          	addi	a0,a0,-1124 # ffffffffc02021d8 <commands+0x5a0>
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
ffffffffc0200656:	b9e50513          	addi	a0,a0,-1122 # ffffffffc02021f0 <commands+0x5b8>
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
ffffffffc020066e:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0202208 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	ba650513          	addi	a0,a0,-1114 # ffffffffc0202220 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	bae50513          	addi	a0,a0,-1106 # ffffffffc0202238 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	bb250513          	addi	a0,a0,-1102 # ffffffffc0202250 <commands+0x618>
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
ffffffffc02006c0:	73870713          	addi	a4,a4,1848 # ffffffffc0201df4 <commands+0x1bc>
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
ffffffffc02006d2:	7ba50513          	addi	a0,a0,1978 # ffffffffc0201e88 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	78e50513          	addi	a0,a0,1934 # ffffffffc0201e68 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	74250513          	addi	a0,a0,1858 # ffffffffc0201e28 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	7b650513          	addi	a0,a0,1974 # ffffffffc0201ea8 <commands+0x270>
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
ffffffffc020072e:	7a650513          	addi	a0,a0,1958 # ffffffffc0201ed0 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	71250513          	addi	a0,a0,1810 # ffffffffc0201e48 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	77450513          	addi	a0,a0,1908 # ffffffffc0201ec0 <commands+0x288>
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

ffffffffc020081e <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020081e:	00006797          	auipc	a5,0x6
ffffffffc0200822:	c1a78793          	addi	a5,a5,-998 # ffffffffc0206438 <free_area>
ffffffffc0200826:	e79c                	sd	a5,8(a5)
ffffffffc0200828:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020082a:	0007a823          	sw	zero,16(a5)
}
ffffffffc020082e:	8082                	ret

ffffffffc0200830 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200830:	00006517          	auipc	a0,0x6
ffffffffc0200834:	c1856503          	lwu	a0,-1000(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200838:	8082                	ret

ffffffffc020083a <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc020083a:	c15d                	beqz	a0,ffffffffc02008e0 <best_fit_alloc_pages+0xa6>
    if (n > nr_free) {
ffffffffc020083c:	00006617          	auipc	a2,0x6
ffffffffc0200840:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0206438 <free_area>
ffffffffc0200844:	01062803          	lw	a6,16(a2)
ffffffffc0200848:	86aa                	mv	a3,a0
ffffffffc020084a:	02081793          	slli	a5,a6,0x20
ffffffffc020084e:	9381                	srli	a5,a5,0x20
ffffffffc0200850:	08a7e663          	bltu	a5,a0,ffffffffc02008dc <best_fit_alloc_pages+0xa2>
    size_t min_size = nr_free + 1;//最小连续空闲页框数量
ffffffffc0200854:	0018059b          	addiw	a1,a6,1
ffffffffc0200858:	1582                	slli	a1,a1,0x20
ffffffffc020085a:	9181                	srli	a1,a1,0x20
    struct Page *temp = NULL;
ffffffffc020085c:	4501                	li	a0,0
    list_entry_t *le = &free_list;
ffffffffc020085e:	87b2                	mv	a5,a2
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200860:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200862:	00c78e63          	beq	a5,a2,ffffffffc020087e <best_fit_alloc_pages+0x44>
         if (p->property >= n) {
ffffffffc0200866:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020086a:	fed76be3          	bltu	a4,a3,ffffffffc0200860 <best_fit_alloc_pages+0x26>
            if(p->property < min_size){
ffffffffc020086e:	feb779e3          	bleu	a1,a4,ffffffffc0200860 <best_fit_alloc_pages+0x26>
        struct Page *p = le2page(le, page_link);
ffffffffc0200872:	fe878513          	addi	a0,a5,-24
ffffffffc0200876:	679c                	ld	a5,8(a5)
ffffffffc0200878:	85ba                	mv	a1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020087a:	fec796e3          	bne	a5,a2,ffffffffc0200866 <best_fit_alloc_pages+0x2c>
    if (page != NULL) {
ffffffffc020087e:	c125                	beqz	a0,ffffffffc02008de <best_fit_alloc_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200880:	7118                	ld	a4,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200882:	6d10                	ld	a2,24(a0)
        if (page->property > n) {
ffffffffc0200884:	490c                	lw	a1,16(a0)
ffffffffc0200886:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020088a:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc020088c:	e310                	sd	a2,0(a4)
ffffffffc020088e:	02059713          	slli	a4,a1,0x20
ffffffffc0200892:	9301                	srli	a4,a4,0x20
ffffffffc0200894:	02e6f863          	bleu	a4,a3,ffffffffc02008c4 <best_fit_alloc_pages+0x8a>
            struct Page *p = page + n;
ffffffffc0200898:	00269713          	slli	a4,a3,0x2
ffffffffc020089c:	9736                	add	a4,a4,a3
ffffffffc020089e:	070e                	slli	a4,a4,0x3
ffffffffc02008a0:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02008a2:	411585bb          	subw	a1,a1,a7
ffffffffc02008a6:	cb0c                	sw	a1,16(a4)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02008a8:	4689                	li	a3,2
ffffffffc02008aa:	00870593          	addi	a1,a4,8
ffffffffc02008ae:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02008b2:	6614                	ld	a3,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc02008b4:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc02008b8:	0107a803          	lw	a6,16(a5)
ffffffffc02008bc:	e28c                	sd	a1,0(a3)
ffffffffc02008be:	e60c                	sd	a1,8(a2)
    elm->next = next;
ffffffffc02008c0:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02008c2:	ef10                	sd	a2,24(a4)
        nr_free -= n; //减少当前可用的空闲页面数量 nr_free
ffffffffc02008c4:	4118083b          	subw	a6,a6,a7
ffffffffc02008c8:	00006797          	auipc	a5,0x6
ffffffffc02008cc:	b907a023          	sw	a6,-1152(a5) # ffffffffc0206448 <free_area+0x10>
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008d0:	57f5                	li	a5,-3
ffffffffc02008d2:	00850713          	addi	a4,a0,8
ffffffffc02008d6:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc02008da:	8082                	ret
        return NULL;
ffffffffc02008dc:	4501                	li	a0,0
}
ffffffffc02008de:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02008e0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008e2:	00002697          	auipc	a3,0x2
ffffffffc02008e6:	98668693          	addi	a3,a3,-1658 # ffffffffc0202268 <commands+0x630>
ffffffffc02008ea:	00002617          	auipc	a2,0x2
ffffffffc02008ee:	98660613          	addi	a2,a2,-1658 # ffffffffc0202270 <commands+0x638>
ffffffffc02008f2:	06b00593          	li	a1,107
ffffffffc02008f6:	00002517          	auipc	a0,0x2
ffffffffc02008fa:	99250513          	addi	a0,a0,-1646 # ffffffffc0202288 <commands+0x650>
best_fit_alloc_pages(size_t n) {
ffffffffc02008fe:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200900:	aadff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200904 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200904:	715d                	addi	sp,sp,-80
ffffffffc0200906:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0200908:	00006917          	auipc	s2,0x6
ffffffffc020090c:	b3090913          	addi	s2,s2,-1232 # ffffffffc0206438 <free_area>
ffffffffc0200910:	00893783          	ld	a5,8(s2)
ffffffffc0200914:	e486                	sd	ra,72(sp)
ffffffffc0200916:	e0a2                	sd	s0,64(sp)
ffffffffc0200918:	fc26                	sd	s1,56(sp)
ffffffffc020091a:	f44e                	sd	s3,40(sp)
ffffffffc020091c:	f052                	sd	s4,32(sp)
ffffffffc020091e:	ec56                	sd	s5,24(sp)
ffffffffc0200920:	e85a                	sd	s6,16(sp)
ffffffffc0200922:	e45e                	sd	s7,8(sp)
ffffffffc0200924:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200926:	2d278363          	beq	a5,s2,ffffffffc0200bec <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020092a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020092e:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200930:	8b05                	andi	a4,a4,1
ffffffffc0200932:	2c070163          	beqz	a4,ffffffffc0200bf4 <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc0200936:	4401                	li	s0,0
ffffffffc0200938:	4481                	li	s1,0
ffffffffc020093a:	a031                	j	ffffffffc0200946 <best_fit_check+0x42>
ffffffffc020093c:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200940:	8b09                	andi	a4,a4,2
ffffffffc0200942:	2a070963          	beqz	a4,ffffffffc0200bf4 <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc0200946:	ff87a703          	lw	a4,-8(a5)
ffffffffc020094a:	679c                	ld	a5,8(a5)
ffffffffc020094c:	2485                	addiw	s1,s1,1
ffffffffc020094e:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200950:	ff2796e3          	bne	a5,s2,ffffffffc020093c <best_fit_check+0x38>
ffffffffc0200954:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200956:	1f7000ef          	jal	ra,ffffffffc020134c <nr_free_pages>
ffffffffc020095a:	37351d63          	bne	a0,s3,ffffffffc0200cd4 <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020095e:	4505                	li	a0,1
ffffffffc0200960:	163000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200964:	8a2a                	mv	s4,a0
ffffffffc0200966:	3a050763          	beqz	a0,ffffffffc0200d14 <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020096a:	4505                	li	a0,1
ffffffffc020096c:	157000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200970:	89aa                	mv	s3,a0
ffffffffc0200972:	38050163          	beqz	a0,ffffffffc0200cf4 <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200976:	4505                	li	a0,1
ffffffffc0200978:	14b000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc020097c:	8aaa                	mv	s5,a0
ffffffffc020097e:	30050b63          	beqz	a0,ffffffffc0200c94 <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200982:	293a0963          	beq	s4,s3,ffffffffc0200c14 <best_fit_check+0x310>
ffffffffc0200986:	28aa0763          	beq	s4,a0,ffffffffc0200c14 <best_fit_check+0x310>
ffffffffc020098a:	28a98563          	beq	s3,a0,ffffffffc0200c14 <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020098e:	000a2783          	lw	a5,0(s4)
ffffffffc0200992:	2a079163          	bnez	a5,ffffffffc0200c34 <best_fit_check+0x330>
ffffffffc0200996:	0009a783          	lw	a5,0(s3)
ffffffffc020099a:	28079d63          	bnez	a5,ffffffffc0200c34 <best_fit_check+0x330>
ffffffffc020099e:	411c                	lw	a5,0(a0)
ffffffffc02009a0:	28079a63          	bnez	a5,ffffffffc0200c34 <best_fit_check+0x330>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009a4:	00006797          	auipc	a5,0x6
ffffffffc02009a8:	acc78793          	addi	a5,a5,-1332 # ffffffffc0206470 <pages>
ffffffffc02009ac:	639c                	ld	a5,0(a5)
ffffffffc02009ae:	00002717          	auipc	a4,0x2
ffffffffc02009b2:	8f270713          	addi	a4,a4,-1806 # ffffffffc02022a0 <commands+0x668>
ffffffffc02009b6:	630c                	ld	a1,0(a4)
ffffffffc02009b8:	40fa0733          	sub	a4,s4,a5
ffffffffc02009bc:	870d                	srai	a4,a4,0x3
ffffffffc02009be:	02b70733          	mul	a4,a4,a1
ffffffffc02009c2:	00002697          	auipc	a3,0x2
ffffffffc02009c6:	fae68693          	addi	a3,a3,-82 # ffffffffc0202970 <nbase>
ffffffffc02009ca:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02009cc:	00006697          	auipc	a3,0x6
ffffffffc02009d0:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0206418 <npage>
ffffffffc02009d4:	6294                	ld	a3,0(a3)
ffffffffc02009d6:	06b2                	slli	a3,a3,0xc
ffffffffc02009d8:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009da:	0732                	slli	a4,a4,0xc
ffffffffc02009dc:	26d77c63          	bleu	a3,a4,ffffffffc0200c54 <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009e0:	40f98733          	sub	a4,s3,a5
ffffffffc02009e4:	870d                	srai	a4,a4,0x3
ffffffffc02009e6:	02b70733          	mul	a4,a4,a1
ffffffffc02009ea:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009ec:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02009ee:	42d77363          	bleu	a3,a4,ffffffffc0200e14 <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009f2:	40f507b3          	sub	a5,a0,a5
ffffffffc02009f6:	878d                	srai	a5,a5,0x3
ffffffffc02009f8:	02b787b3          	mul	a5,a5,a1
ffffffffc02009fc:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009fe:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200a00:	3ed7fa63          	bleu	a3,a5,ffffffffc0200df4 <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200a04:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a06:	00093c03          	ld	s8,0(s2)
ffffffffc0200a0a:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200a0e:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200a12:	00006797          	auipc	a5,0x6
ffffffffc0200a16:	a327b723          	sd	s2,-1490(a5) # ffffffffc0206440 <free_area+0x8>
ffffffffc0200a1a:	00006797          	auipc	a5,0x6
ffffffffc0200a1e:	a127bf23          	sd	s2,-1506(a5) # ffffffffc0206438 <free_area>
    nr_free = 0;
ffffffffc0200a22:	00006797          	auipc	a5,0x6
ffffffffc0200a26:	a207a323          	sw	zero,-1498(a5) # ffffffffc0206448 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200a2a:	099000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200a2e:	3a051363          	bnez	a0,ffffffffc0200dd4 <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200a32:	4585                	li	a1,1
ffffffffc0200a34:	8552                	mv	a0,s4
ffffffffc0200a36:	0d1000ef          	jal	ra,ffffffffc0201306 <free_pages>
    free_page(p1);
ffffffffc0200a3a:	4585                	li	a1,1
ffffffffc0200a3c:	854e                	mv	a0,s3
ffffffffc0200a3e:	0c9000ef          	jal	ra,ffffffffc0201306 <free_pages>
    free_page(p2);
ffffffffc0200a42:	4585                	li	a1,1
ffffffffc0200a44:	8556                	mv	a0,s5
ffffffffc0200a46:	0c1000ef          	jal	ra,ffffffffc0201306 <free_pages>
    assert(nr_free == 3);
ffffffffc0200a4a:	01092703          	lw	a4,16(s2)
ffffffffc0200a4e:	478d                	li	a5,3
ffffffffc0200a50:	36f71263          	bne	a4,a5,ffffffffc0200db4 <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a54:	4505                	li	a0,1
ffffffffc0200a56:	06d000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200a5a:	89aa                	mv	s3,a0
ffffffffc0200a5c:	32050c63          	beqz	a0,ffffffffc0200d94 <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a60:	4505                	li	a0,1
ffffffffc0200a62:	061000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200a66:	8aaa                	mv	s5,a0
ffffffffc0200a68:	30050663          	beqz	a0,ffffffffc0200d74 <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a6c:	4505                	li	a0,1
ffffffffc0200a6e:	055000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200a72:	8a2a                	mv	s4,a0
ffffffffc0200a74:	2e050063          	beqz	a0,ffffffffc0200d54 <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200a78:	4505                	li	a0,1
ffffffffc0200a7a:	049000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200a7e:	2a051b63          	bnez	a0,ffffffffc0200d34 <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200a82:	4585                	li	a1,1
ffffffffc0200a84:	854e                	mv	a0,s3
ffffffffc0200a86:	081000ef          	jal	ra,ffffffffc0201306 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a8a:	00893783          	ld	a5,8(s2)
ffffffffc0200a8e:	1f278363          	beq	a5,s2,ffffffffc0200c74 <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200a92:	4505                	li	a0,1
ffffffffc0200a94:	02f000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200a98:	54a99e63          	bne	s3,a0,ffffffffc0200ff4 <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200a9c:	4505                	li	a0,1
ffffffffc0200a9e:	025000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200aa2:	52051963          	bnez	a0,ffffffffc0200fd4 <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200aa6:	01092783          	lw	a5,16(s2)
ffffffffc0200aaa:	50079563          	bnez	a5,ffffffffc0200fb4 <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200aae:	854e                	mv	a0,s3
ffffffffc0200ab0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200ab2:	00006797          	auipc	a5,0x6
ffffffffc0200ab6:	9987b323          	sd	s8,-1658(a5) # ffffffffc0206438 <free_area>
ffffffffc0200aba:	00006797          	auipc	a5,0x6
ffffffffc0200abe:	9977b323          	sd	s7,-1658(a5) # ffffffffc0206440 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200ac2:	00006797          	auipc	a5,0x6
ffffffffc0200ac6:	9967a323          	sw	s6,-1658(a5) # ffffffffc0206448 <free_area+0x10>
    free_page(p);
ffffffffc0200aca:	03d000ef          	jal	ra,ffffffffc0201306 <free_pages>
    free_page(p1);
ffffffffc0200ace:	4585                	li	a1,1
ffffffffc0200ad0:	8556                	mv	a0,s5
ffffffffc0200ad2:	035000ef          	jal	ra,ffffffffc0201306 <free_pages>
    free_page(p2);
ffffffffc0200ad6:	4585                	li	a1,1
ffffffffc0200ad8:	8552                	mv	a0,s4
ffffffffc0200ada:	02d000ef          	jal	ra,ffffffffc0201306 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200ade:	4515                	li	a0,5
ffffffffc0200ae0:	7e2000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200ae4:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200ae6:	4a050763          	beqz	a0,ffffffffc0200f94 <best_fit_check+0x690>
ffffffffc0200aea:	651c                	ld	a5,8(a0)
ffffffffc0200aec:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200aee:	8b85                	andi	a5,a5,1
ffffffffc0200af0:	48079263          	bnez	a5,ffffffffc0200f74 <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200af4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200af6:	00093b03          	ld	s6,0(s2)
ffffffffc0200afa:	00893a83          	ld	s5,8(s2)
ffffffffc0200afe:	00006797          	auipc	a5,0x6
ffffffffc0200b02:	9327bd23          	sd	s2,-1734(a5) # ffffffffc0206438 <free_area>
ffffffffc0200b06:	00006797          	auipc	a5,0x6
ffffffffc0200b0a:	9327bd23          	sd	s2,-1734(a5) # ffffffffc0206440 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200b0e:	7b4000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200b12:	44051163          	bnez	a0,ffffffffc0200f54 <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200b16:	4589                	li	a1,2
ffffffffc0200b18:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200b1c:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200b20:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200b24:	00006797          	auipc	a5,0x6
ffffffffc0200b28:	9207a223          	sw	zero,-1756(a5) # ffffffffc0206448 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200b2c:	7da000ef          	jal	ra,ffffffffc0201306 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200b30:	8562                	mv	a0,s8
ffffffffc0200b32:	4585                	li	a1,1
ffffffffc0200b34:	7d2000ef          	jal	ra,ffffffffc0201306 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200b38:	4511                	li	a0,4
ffffffffc0200b3a:	788000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200b3e:	3e051b63          	bnez	a0,ffffffffc0200f34 <best_fit_check+0x630>
ffffffffc0200b42:	0309b783          	ld	a5,48(s3)
ffffffffc0200b46:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200b48:	8b85                	andi	a5,a5,1
ffffffffc0200b4a:	3c078563          	beqz	a5,ffffffffc0200f14 <best_fit_check+0x610>
ffffffffc0200b4e:	0389a703          	lw	a4,56(s3)
ffffffffc0200b52:	4789                	li	a5,2
ffffffffc0200b54:	3cf71063          	bne	a4,a5,ffffffffc0200f14 <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b58:	4505                	li	a0,1
ffffffffc0200b5a:	768000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200b5e:	8a2a                	mv	s4,a0
ffffffffc0200b60:	38050a63          	beqz	a0,ffffffffc0200ef4 <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b64:	4509                	li	a0,2
ffffffffc0200b66:	75c000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200b6a:	36050563          	beqz	a0,ffffffffc0200ed4 <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200b6e:	354c1363          	bne	s8,s4,ffffffffc0200eb4 <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b72:	854e                	mv	a0,s3
ffffffffc0200b74:	4595                	li	a1,5
ffffffffc0200b76:	790000ef          	jal	ra,ffffffffc0201306 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b7a:	4515                	li	a0,5
ffffffffc0200b7c:	746000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200b80:	89aa                	mv	s3,a0
ffffffffc0200b82:	30050963          	beqz	a0,ffffffffc0200e94 <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200b86:	4505                	li	a0,1
ffffffffc0200b88:	73a000ef          	jal	ra,ffffffffc02012c2 <alloc_pages>
ffffffffc0200b8c:	2e051463          	bnez	a0,ffffffffc0200e74 <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200b90:	01092783          	lw	a5,16(s2)
ffffffffc0200b94:	2c079063          	bnez	a5,ffffffffc0200e54 <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200b98:	4595                	li	a1,5
ffffffffc0200b9a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200b9c:	00006797          	auipc	a5,0x6
ffffffffc0200ba0:	8b77a623          	sw	s7,-1876(a5) # ffffffffc0206448 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200ba4:	00006797          	auipc	a5,0x6
ffffffffc0200ba8:	8967ba23          	sd	s6,-1900(a5) # ffffffffc0206438 <free_area>
ffffffffc0200bac:	00006797          	auipc	a5,0x6
ffffffffc0200bb0:	8957ba23          	sd	s5,-1900(a5) # ffffffffc0206440 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200bb4:	752000ef          	jal	ra,ffffffffc0201306 <free_pages>
    return listelm->next;
ffffffffc0200bb8:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bbc:	01278963          	beq	a5,s2,ffffffffc0200bce <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200bc0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bc4:	679c                	ld	a5,8(a5)
ffffffffc0200bc6:	34fd                	addiw	s1,s1,-1
ffffffffc0200bc8:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bca:	ff279be3          	bne	a5,s2,ffffffffc0200bc0 <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200bce:	26049363          	bnez	s1,ffffffffc0200e34 <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200bd2:	e06d                	bnez	s0,ffffffffc0200cb4 <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200bd4:	60a6                	ld	ra,72(sp)
ffffffffc0200bd6:	6406                	ld	s0,64(sp)
ffffffffc0200bd8:	74e2                	ld	s1,56(sp)
ffffffffc0200bda:	7942                	ld	s2,48(sp)
ffffffffc0200bdc:	79a2                	ld	s3,40(sp)
ffffffffc0200bde:	7a02                	ld	s4,32(sp)
ffffffffc0200be0:	6ae2                	ld	s5,24(sp)
ffffffffc0200be2:	6b42                	ld	s6,16(sp)
ffffffffc0200be4:	6ba2                	ld	s7,8(sp)
ffffffffc0200be6:	6c02                	ld	s8,0(sp)
ffffffffc0200be8:	6161                	addi	sp,sp,80
ffffffffc0200bea:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bec:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200bee:	4401                	li	s0,0
ffffffffc0200bf0:	4481                	li	s1,0
ffffffffc0200bf2:	b395                	j	ffffffffc0200956 <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200bf4:	00001697          	auipc	a3,0x1
ffffffffc0200bf8:	6b468693          	addi	a3,a3,1716 # ffffffffc02022a8 <commands+0x670>
ffffffffc0200bfc:	00001617          	auipc	a2,0x1
ffffffffc0200c00:	67460613          	addi	a2,a2,1652 # ffffffffc0202270 <commands+0x638>
ffffffffc0200c04:	11400593          	li	a1,276
ffffffffc0200c08:	00001517          	auipc	a0,0x1
ffffffffc0200c0c:	68050513          	addi	a0,a0,1664 # ffffffffc0202288 <commands+0x650>
ffffffffc0200c10:	f9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c14:	00001697          	auipc	a3,0x1
ffffffffc0200c18:	72468693          	addi	a3,a3,1828 # ffffffffc0202338 <commands+0x700>
ffffffffc0200c1c:	00001617          	auipc	a2,0x1
ffffffffc0200c20:	65460613          	addi	a2,a2,1620 # ffffffffc0202270 <commands+0x638>
ffffffffc0200c24:	0e000593          	li	a1,224
ffffffffc0200c28:	00001517          	auipc	a0,0x1
ffffffffc0200c2c:	66050513          	addi	a0,a0,1632 # ffffffffc0202288 <commands+0x650>
ffffffffc0200c30:	f7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c34:	00001697          	auipc	a3,0x1
ffffffffc0200c38:	72c68693          	addi	a3,a3,1836 # ffffffffc0202360 <commands+0x728>
ffffffffc0200c3c:	00001617          	auipc	a2,0x1
ffffffffc0200c40:	63460613          	addi	a2,a2,1588 # ffffffffc0202270 <commands+0x638>
ffffffffc0200c44:	0e100593          	li	a1,225
ffffffffc0200c48:	00001517          	auipc	a0,0x1
ffffffffc0200c4c:	64050513          	addi	a0,a0,1600 # ffffffffc0202288 <commands+0x650>
ffffffffc0200c50:	f5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c54:	00001697          	auipc	a3,0x1
ffffffffc0200c58:	74c68693          	addi	a3,a3,1868 # ffffffffc02023a0 <commands+0x768>
ffffffffc0200c5c:	00001617          	auipc	a2,0x1
ffffffffc0200c60:	61460613          	addi	a2,a2,1556 # ffffffffc0202270 <commands+0x638>
ffffffffc0200c64:	0e300593          	li	a1,227
ffffffffc0200c68:	00001517          	auipc	a0,0x1
ffffffffc0200c6c:	62050513          	addi	a0,a0,1568 # ffffffffc0202288 <commands+0x650>
ffffffffc0200c70:	f3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c74:	00001697          	auipc	a3,0x1
ffffffffc0200c78:	7b468693          	addi	a3,a3,1972 # ffffffffc0202428 <commands+0x7f0>
ffffffffc0200c7c:	00001617          	auipc	a2,0x1
ffffffffc0200c80:	5f460613          	addi	a2,a2,1524 # ffffffffc0202270 <commands+0x638>
ffffffffc0200c84:	0fc00593          	li	a1,252
ffffffffc0200c88:	00001517          	auipc	a0,0x1
ffffffffc0200c8c:	60050513          	addi	a0,a0,1536 # ffffffffc0202288 <commands+0x650>
ffffffffc0200c90:	f1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c94:	00001697          	auipc	a3,0x1
ffffffffc0200c98:	68468693          	addi	a3,a3,1668 # ffffffffc0202318 <commands+0x6e0>
ffffffffc0200c9c:	00001617          	auipc	a2,0x1
ffffffffc0200ca0:	5d460613          	addi	a2,a2,1492 # ffffffffc0202270 <commands+0x638>
ffffffffc0200ca4:	0de00593          	li	a1,222
ffffffffc0200ca8:	00001517          	auipc	a0,0x1
ffffffffc0200cac:	5e050513          	addi	a0,a0,1504 # ffffffffc0202288 <commands+0x650>
ffffffffc0200cb0:	efcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200cb4:	00002697          	auipc	a3,0x2
ffffffffc0200cb8:	8a468693          	addi	a3,a3,-1884 # ffffffffc0202558 <commands+0x920>
ffffffffc0200cbc:	00001617          	auipc	a2,0x1
ffffffffc0200cc0:	5b460613          	addi	a2,a2,1460 # ffffffffc0202270 <commands+0x638>
ffffffffc0200cc4:	15600593          	li	a1,342
ffffffffc0200cc8:	00001517          	auipc	a0,0x1
ffffffffc0200ccc:	5c050513          	addi	a0,a0,1472 # ffffffffc0202288 <commands+0x650>
ffffffffc0200cd0:	edcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200cd4:	00001697          	auipc	a3,0x1
ffffffffc0200cd8:	5e468693          	addi	a3,a3,1508 # ffffffffc02022b8 <commands+0x680>
ffffffffc0200cdc:	00001617          	auipc	a2,0x1
ffffffffc0200ce0:	59460613          	addi	a2,a2,1428 # ffffffffc0202270 <commands+0x638>
ffffffffc0200ce4:	11700593          	li	a1,279
ffffffffc0200ce8:	00001517          	auipc	a0,0x1
ffffffffc0200cec:	5a050513          	addi	a0,a0,1440 # ffffffffc0202288 <commands+0x650>
ffffffffc0200cf0:	ebcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cf4:	00001697          	auipc	a3,0x1
ffffffffc0200cf8:	60468693          	addi	a3,a3,1540 # ffffffffc02022f8 <commands+0x6c0>
ffffffffc0200cfc:	00001617          	auipc	a2,0x1
ffffffffc0200d00:	57460613          	addi	a2,a2,1396 # ffffffffc0202270 <commands+0x638>
ffffffffc0200d04:	0dd00593          	li	a1,221
ffffffffc0200d08:	00001517          	auipc	a0,0x1
ffffffffc0200d0c:	58050513          	addi	a0,a0,1408 # ffffffffc0202288 <commands+0x650>
ffffffffc0200d10:	e9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d14:	00001697          	auipc	a3,0x1
ffffffffc0200d18:	5c468693          	addi	a3,a3,1476 # ffffffffc02022d8 <commands+0x6a0>
ffffffffc0200d1c:	00001617          	auipc	a2,0x1
ffffffffc0200d20:	55460613          	addi	a2,a2,1364 # ffffffffc0202270 <commands+0x638>
ffffffffc0200d24:	0dc00593          	li	a1,220
ffffffffc0200d28:	00001517          	auipc	a0,0x1
ffffffffc0200d2c:	56050513          	addi	a0,a0,1376 # ffffffffc0202288 <commands+0x650>
ffffffffc0200d30:	e7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d34:	00001697          	auipc	a3,0x1
ffffffffc0200d38:	6cc68693          	addi	a3,a3,1740 # ffffffffc0202400 <commands+0x7c8>
ffffffffc0200d3c:	00001617          	auipc	a2,0x1
ffffffffc0200d40:	53460613          	addi	a2,a2,1332 # ffffffffc0202270 <commands+0x638>
ffffffffc0200d44:	0f900593          	li	a1,249
ffffffffc0200d48:	00001517          	auipc	a0,0x1
ffffffffc0200d4c:	54050513          	addi	a0,a0,1344 # ffffffffc0202288 <commands+0x650>
ffffffffc0200d50:	e5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d54:	00001697          	auipc	a3,0x1
ffffffffc0200d58:	5c468693          	addi	a3,a3,1476 # ffffffffc0202318 <commands+0x6e0>
ffffffffc0200d5c:	00001617          	auipc	a2,0x1
ffffffffc0200d60:	51460613          	addi	a2,a2,1300 # ffffffffc0202270 <commands+0x638>
ffffffffc0200d64:	0f700593          	li	a1,247
ffffffffc0200d68:	00001517          	auipc	a0,0x1
ffffffffc0200d6c:	52050513          	addi	a0,a0,1312 # ffffffffc0202288 <commands+0x650>
ffffffffc0200d70:	e3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d74:	00001697          	auipc	a3,0x1
ffffffffc0200d78:	58468693          	addi	a3,a3,1412 # ffffffffc02022f8 <commands+0x6c0>
ffffffffc0200d7c:	00001617          	auipc	a2,0x1
ffffffffc0200d80:	4f460613          	addi	a2,a2,1268 # ffffffffc0202270 <commands+0x638>
ffffffffc0200d84:	0f600593          	li	a1,246
ffffffffc0200d88:	00001517          	auipc	a0,0x1
ffffffffc0200d8c:	50050513          	addi	a0,a0,1280 # ffffffffc0202288 <commands+0x650>
ffffffffc0200d90:	e1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d94:	00001697          	auipc	a3,0x1
ffffffffc0200d98:	54468693          	addi	a3,a3,1348 # ffffffffc02022d8 <commands+0x6a0>
ffffffffc0200d9c:	00001617          	auipc	a2,0x1
ffffffffc0200da0:	4d460613          	addi	a2,a2,1236 # ffffffffc0202270 <commands+0x638>
ffffffffc0200da4:	0f500593          	li	a1,245
ffffffffc0200da8:	00001517          	auipc	a0,0x1
ffffffffc0200dac:	4e050513          	addi	a0,a0,1248 # ffffffffc0202288 <commands+0x650>
ffffffffc0200db0:	dfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200db4:	00001697          	auipc	a3,0x1
ffffffffc0200db8:	66468693          	addi	a3,a3,1636 # ffffffffc0202418 <commands+0x7e0>
ffffffffc0200dbc:	00001617          	auipc	a2,0x1
ffffffffc0200dc0:	4b460613          	addi	a2,a2,1204 # ffffffffc0202270 <commands+0x638>
ffffffffc0200dc4:	0f300593          	li	a1,243
ffffffffc0200dc8:	00001517          	auipc	a0,0x1
ffffffffc0200dcc:	4c050513          	addi	a0,a0,1216 # ffffffffc0202288 <commands+0x650>
ffffffffc0200dd0:	ddcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200dd4:	00001697          	auipc	a3,0x1
ffffffffc0200dd8:	62c68693          	addi	a3,a3,1580 # ffffffffc0202400 <commands+0x7c8>
ffffffffc0200ddc:	00001617          	auipc	a2,0x1
ffffffffc0200de0:	49460613          	addi	a2,a2,1172 # ffffffffc0202270 <commands+0x638>
ffffffffc0200de4:	0ee00593          	li	a1,238
ffffffffc0200de8:	00001517          	auipc	a0,0x1
ffffffffc0200dec:	4a050513          	addi	a0,a0,1184 # ffffffffc0202288 <commands+0x650>
ffffffffc0200df0:	dbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200df4:	00001697          	auipc	a3,0x1
ffffffffc0200df8:	5ec68693          	addi	a3,a3,1516 # ffffffffc02023e0 <commands+0x7a8>
ffffffffc0200dfc:	00001617          	auipc	a2,0x1
ffffffffc0200e00:	47460613          	addi	a2,a2,1140 # ffffffffc0202270 <commands+0x638>
ffffffffc0200e04:	0e500593          	li	a1,229
ffffffffc0200e08:	00001517          	auipc	a0,0x1
ffffffffc0200e0c:	48050513          	addi	a0,a0,1152 # ffffffffc0202288 <commands+0x650>
ffffffffc0200e10:	d9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e14:	00001697          	auipc	a3,0x1
ffffffffc0200e18:	5ac68693          	addi	a3,a3,1452 # ffffffffc02023c0 <commands+0x788>
ffffffffc0200e1c:	00001617          	auipc	a2,0x1
ffffffffc0200e20:	45460613          	addi	a2,a2,1108 # ffffffffc0202270 <commands+0x638>
ffffffffc0200e24:	0e400593          	li	a1,228
ffffffffc0200e28:	00001517          	auipc	a0,0x1
ffffffffc0200e2c:	46050513          	addi	a0,a0,1120 # ffffffffc0202288 <commands+0x650>
ffffffffc0200e30:	d7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200e34:	00001697          	auipc	a3,0x1
ffffffffc0200e38:	71468693          	addi	a3,a3,1812 # ffffffffc0202548 <commands+0x910>
ffffffffc0200e3c:	00001617          	auipc	a2,0x1
ffffffffc0200e40:	43460613          	addi	a2,a2,1076 # ffffffffc0202270 <commands+0x638>
ffffffffc0200e44:	15500593          	li	a1,341
ffffffffc0200e48:	00001517          	auipc	a0,0x1
ffffffffc0200e4c:	44050513          	addi	a0,a0,1088 # ffffffffc0202288 <commands+0x650>
ffffffffc0200e50:	d5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200e54:	00001697          	auipc	a3,0x1
ffffffffc0200e58:	60c68693          	addi	a3,a3,1548 # ffffffffc0202460 <commands+0x828>
ffffffffc0200e5c:	00001617          	auipc	a2,0x1
ffffffffc0200e60:	41460613          	addi	a2,a2,1044 # ffffffffc0202270 <commands+0x638>
ffffffffc0200e64:	14a00593          	li	a1,330
ffffffffc0200e68:	00001517          	auipc	a0,0x1
ffffffffc0200e6c:	42050513          	addi	a0,a0,1056 # ffffffffc0202288 <commands+0x650>
ffffffffc0200e70:	d3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e74:	00001697          	auipc	a3,0x1
ffffffffc0200e78:	58c68693          	addi	a3,a3,1420 # ffffffffc0202400 <commands+0x7c8>
ffffffffc0200e7c:	00001617          	auipc	a2,0x1
ffffffffc0200e80:	3f460613          	addi	a2,a2,1012 # ffffffffc0202270 <commands+0x638>
ffffffffc0200e84:	14400593          	li	a1,324
ffffffffc0200e88:	00001517          	auipc	a0,0x1
ffffffffc0200e8c:	40050513          	addi	a0,a0,1024 # ffffffffc0202288 <commands+0x650>
ffffffffc0200e90:	d1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e94:	00001697          	auipc	a3,0x1
ffffffffc0200e98:	69468693          	addi	a3,a3,1684 # ffffffffc0202528 <commands+0x8f0>
ffffffffc0200e9c:	00001617          	auipc	a2,0x1
ffffffffc0200ea0:	3d460613          	addi	a2,a2,980 # ffffffffc0202270 <commands+0x638>
ffffffffc0200ea4:	14300593          	li	a1,323
ffffffffc0200ea8:	00001517          	auipc	a0,0x1
ffffffffc0200eac:	3e050513          	addi	a0,a0,992 # ffffffffc0202288 <commands+0x650>
ffffffffc0200eb0:	cfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200eb4:	00001697          	auipc	a3,0x1
ffffffffc0200eb8:	66468693          	addi	a3,a3,1636 # ffffffffc0202518 <commands+0x8e0>
ffffffffc0200ebc:	00001617          	auipc	a2,0x1
ffffffffc0200ec0:	3b460613          	addi	a2,a2,948 # ffffffffc0202270 <commands+0x638>
ffffffffc0200ec4:	13b00593          	li	a1,315
ffffffffc0200ec8:	00001517          	auipc	a0,0x1
ffffffffc0200ecc:	3c050513          	addi	a0,a0,960 # ffffffffc0202288 <commands+0x650>
ffffffffc0200ed0:	cdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200ed4:	00001697          	auipc	a3,0x1
ffffffffc0200ed8:	62c68693          	addi	a3,a3,1580 # ffffffffc0202500 <commands+0x8c8>
ffffffffc0200edc:	00001617          	auipc	a2,0x1
ffffffffc0200ee0:	39460613          	addi	a2,a2,916 # ffffffffc0202270 <commands+0x638>
ffffffffc0200ee4:	13a00593          	li	a1,314
ffffffffc0200ee8:	00001517          	auipc	a0,0x1
ffffffffc0200eec:	3a050513          	addi	a0,a0,928 # ffffffffc0202288 <commands+0x650>
ffffffffc0200ef0:	cbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200ef4:	00001697          	auipc	a3,0x1
ffffffffc0200ef8:	5ec68693          	addi	a3,a3,1516 # ffffffffc02024e0 <commands+0x8a8>
ffffffffc0200efc:	00001617          	auipc	a2,0x1
ffffffffc0200f00:	37460613          	addi	a2,a2,884 # ffffffffc0202270 <commands+0x638>
ffffffffc0200f04:	13900593          	li	a1,313
ffffffffc0200f08:	00001517          	auipc	a0,0x1
ffffffffc0200f0c:	38050513          	addi	a0,a0,896 # ffffffffc0202288 <commands+0x650>
ffffffffc0200f10:	c9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200f14:	00001697          	auipc	a3,0x1
ffffffffc0200f18:	59c68693          	addi	a3,a3,1436 # ffffffffc02024b0 <commands+0x878>
ffffffffc0200f1c:	00001617          	auipc	a2,0x1
ffffffffc0200f20:	35460613          	addi	a2,a2,852 # ffffffffc0202270 <commands+0x638>
ffffffffc0200f24:	13700593          	li	a1,311
ffffffffc0200f28:	00001517          	auipc	a0,0x1
ffffffffc0200f2c:	36050513          	addi	a0,a0,864 # ffffffffc0202288 <commands+0x650>
ffffffffc0200f30:	c7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f34:	00001697          	auipc	a3,0x1
ffffffffc0200f38:	56468693          	addi	a3,a3,1380 # ffffffffc0202498 <commands+0x860>
ffffffffc0200f3c:	00001617          	auipc	a2,0x1
ffffffffc0200f40:	33460613          	addi	a2,a2,820 # ffffffffc0202270 <commands+0x638>
ffffffffc0200f44:	13600593          	li	a1,310
ffffffffc0200f48:	00001517          	auipc	a0,0x1
ffffffffc0200f4c:	34050513          	addi	a0,a0,832 # ffffffffc0202288 <commands+0x650>
ffffffffc0200f50:	c5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f54:	00001697          	auipc	a3,0x1
ffffffffc0200f58:	4ac68693          	addi	a3,a3,1196 # ffffffffc0202400 <commands+0x7c8>
ffffffffc0200f5c:	00001617          	auipc	a2,0x1
ffffffffc0200f60:	31460613          	addi	a2,a2,788 # ffffffffc0202270 <commands+0x638>
ffffffffc0200f64:	12a00593          	li	a1,298
ffffffffc0200f68:	00001517          	auipc	a0,0x1
ffffffffc0200f6c:	32050513          	addi	a0,a0,800 # ffffffffc0202288 <commands+0x650>
ffffffffc0200f70:	c3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f74:	00001697          	auipc	a3,0x1
ffffffffc0200f78:	50c68693          	addi	a3,a3,1292 # ffffffffc0202480 <commands+0x848>
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	2f460613          	addi	a2,a2,756 # ffffffffc0202270 <commands+0x638>
ffffffffc0200f84:	12100593          	li	a1,289
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	30050513          	addi	a0,a0,768 # ffffffffc0202288 <commands+0x650>
ffffffffc0200f90:	c1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200f94:	00001697          	auipc	a3,0x1
ffffffffc0200f98:	4dc68693          	addi	a3,a3,1244 # ffffffffc0202470 <commands+0x838>
ffffffffc0200f9c:	00001617          	auipc	a2,0x1
ffffffffc0200fa0:	2d460613          	addi	a2,a2,724 # ffffffffc0202270 <commands+0x638>
ffffffffc0200fa4:	12000593          	li	a1,288
ffffffffc0200fa8:	00001517          	auipc	a0,0x1
ffffffffc0200fac:	2e050513          	addi	a0,a0,736 # ffffffffc0202288 <commands+0x650>
ffffffffc0200fb0:	bfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200fb4:	00001697          	auipc	a3,0x1
ffffffffc0200fb8:	4ac68693          	addi	a3,a3,1196 # ffffffffc0202460 <commands+0x828>
ffffffffc0200fbc:	00001617          	auipc	a2,0x1
ffffffffc0200fc0:	2b460613          	addi	a2,a2,692 # ffffffffc0202270 <commands+0x638>
ffffffffc0200fc4:	10200593          	li	a1,258
ffffffffc0200fc8:	00001517          	auipc	a0,0x1
ffffffffc0200fcc:	2c050513          	addi	a0,a0,704 # ffffffffc0202288 <commands+0x650>
ffffffffc0200fd0:	bdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fd4:	00001697          	auipc	a3,0x1
ffffffffc0200fd8:	42c68693          	addi	a3,a3,1068 # ffffffffc0202400 <commands+0x7c8>
ffffffffc0200fdc:	00001617          	auipc	a2,0x1
ffffffffc0200fe0:	29460613          	addi	a2,a2,660 # ffffffffc0202270 <commands+0x638>
ffffffffc0200fe4:	10000593          	li	a1,256
ffffffffc0200fe8:	00001517          	auipc	a0,0x1
ffffffffc0200fec:	2a050513          	addi	a0,a0,672 # ffffffffc0202288 <commands+0x650>
ffffffffc0200ff0:	bbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200ff4:	00001697          	auipc	a3,0x1
ffffffffc0200ff8:	44c68693          	addi	a3,a3,1100 # ffffffffc0202440 <commands+0x808>
ffffffffc0200ffc:	00001617          	auipc	a2,0x1
ffffffffc0201000:	27460613          	addi	a2,a2,628 # ffffffffc0202270 <commands+0x638>
ffffffffc0201004:	0ff00593          	li	a1,255
ffffffffc0201008:	00001517          	auipc	a0,0x1
ffffffffc020100c:	28050513          	addi	a0,a0,640 # ffffffffc0202288 <commands+0x650>
ffffffffc0201010:	b9cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201014 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201014:	1141                	addi	sp,sp,-16
ffffffffc0201016:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201018:	18058063          	beqz	a1,ffffffffc0201198 <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc020101c:	00259693          	slli	a3,a1,0x2
ffffffffc0201020:	96ae                	add	a3,a3,a1
ffffffffc0201022:	068e                	slli	a3,a3,0x3
ffffffffc0201024:	96aa                	add	a3,a3,a0
ffffffffc0201026:	02d50d63          	beq	a0,a3,ffffffffc0201060 <best_fit_free_pages+0x4c>
ffffffffc020102a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020102c:	8b85                	andi	a5,a5,1
ffffffffc020102e:	14079563          	bnez	a5,ffffffffc0201178 <best_fit_free_pages+0x164>
ffffffffc0201032:	651c                	ld	a5,8(a0)
ffffffffc0201034:	8385                	srli	a5,a5,0x1
ffffffffc0201036:	8b85                	andi	a5,a5,1
ffffffffc0201038:	14079063          	bnez	a5,ffffffffc0201178 <best_fit_free_pages+0x164>
ffffffffc020103c:	87aa                	mv	a5,a0
ffffffffc020103e:	a809                	j	ffffffffc0201050 <best_fit_free_pages+0x3c>
ffffffffc0201040:	6798                	ld	a4,8(a5)
ffffffffc0201042:	8b05                	andi	a4,a4,1
ffffffffc0201044:	12071a63          	bnez	a4,ffffffffc0201178 <best_fit_free_pages+0x164>
ffffffffc0201048:	6798                	ld	a4,8(a5)
ffffffffc020104a:	8b09                	andi	a4,a4,2
ffffffffc020104c:	12071663          	bnez	a4,ffffffffc0201178 <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc0201050:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201054:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201058:	02878793          	addi	a5,a5,40
ffffffffc020105c:	fed792e3          	bne	a5,a3,ffffffffc0201040 <best_fit_free_pages+0x2c>
    base->property = n; //当前页块的属性为释放的页块数
ffffffffc0201060:	2581                	sext.w	a1,a1
ffffffffc0201062:	c90c                	sw	a1,16(a0)
    SetPageProperty(base); //使用 SetPageProperty 函数将其标记为属性页框。
ffffffffc0201064:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201068:	4789                	li	a5,2
ffffffffc020106a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n; //最后增加nr_free的值
ffffffffc020106e:	00005697          	auipc	a3,0x5
ffffffffc0201072:	3ca68693          	addi	a3,a3,970 # ffffffffc0206438 <free_area>
ffffffffc0201076:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201078:	669c                	ld	a5,8(a3)
ffffffffc020107a:	9db9                	addw	a1,a1,a4
ffffffffc020107c:	00005717          	auipc	a4,0x5
ffffffffc0201080:	3cb72623          	sw	a1,972(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201084:	08d78f63          	beq	a5,a3,ffffffffc0201122 <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201088:	fe878713          	addi	a4,a5,-24
ffffffffc020108c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020108e:	4801                	li	a6,0
ffffffffc0201090:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201094:	00e56a63          	bltu	a0,a4,ffffffffc02010a8 <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc0201098:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020109a:	02d70563          	beq	a4,a3,ffffffffc02010c4 <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020109e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02010a0:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02010a4:	fee57ae3          	bleu	a4,a0,ffffffffc0201098 <best_fit_free_pages+0x84>
ffffffffc02010a8:	00080663          	beqz	a6,ffffffffc02010b4 <best_fit_free_pages+0xa0>
ffffffffc02010ac:	00005817          	auipc	a6,0x5
ffffffffc02010b0:	38b83623          	sd	a1,908(a6) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010b4:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc02010b6:	e390                	sd	a2,0(a5)
ffffffffc02010b8:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02010ba:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010bc:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02010be:	02d59163          	bne	a1,a3,ffffffffc02010e0 <best_fit_free_pages+0xcc>
ffffffffc02010c2:	a091                	j	ffffffffc0201106 <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02010c4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010c6:	f114                	sd	a3,32(a0)
ffffffffc02010c8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02010ca:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02010cc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010ce:	00d70563          	beq	a4,a3,ffffffffc02010d8 <best_fit_free_pages+0xc4>
ffffffffc02010d2:	4805                	li	a6,1
ffffffffc02010d4:	87ba                	mv	a5,a4
ffffffffc02010d6:	b7e9                	j	ffffffffc02010a0 <best_fit_free_pages+0x8c>
ffffffffc02010d8:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02010da:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02010dc:	02d78163          	beq	a5,a3,ffffffffc02010fe <best_fit_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02010e0:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02010e4:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base) {
ffffffffc02010e8:	02081713          	slli	a4,a6,0x20
ffffffffc02010ec:	9301                	srli	a4,a4,0x20
ffffffffc02010ee:	00271793          	slli	a5,a4,0x2
ffffffffc02010f2:	97ba                	add	a5,a5,a4
ffffffffc02010f4:	078e                	slli	a5,a5,0x3
ffffffffc02010f6:	97b2                	add	a5,a5,a2
ffffffffc02010f8:	02f50e63          	beq	a0,a5,ffffffffc0201134 <best_fit_free_pages+0x120>
ffffffffc02010fc:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02010fe:	fe878713          	addi	a4,a5,-24
ffffffffc0201102:	00d78d63          	beq	a5,a3,ffffffffc020111c <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0201106:	490c                	lw	a1,16(a0)
ffffffffc0201108:	02059613          	slli	a2,a1,0x20
ffffffffc020110c:	9201                	srli	a2,a2,0x20
ffffffffc020110e:	00261693          	slli	a3,a2,0x2
ffffffffc0201112:	96b2                	add	a3,a3,a2
ffffffffc0201114:	068e                	slli	a3,a3,0x3
ffffffffc0201116:	96aa                	add	a3,a3,a0
ffffffffc0201118:	04d70063          	beq	a4,a3,ffffffffc0201158 <best_fit_free_pages+0x144>
}
ffffffffc020111c:	60a2                	ld	ra,8(sp)
ffffffffc020111e:	0141                	addi	sp,sp,16
ffffffffc0201120:	8082                	ret
ffffffffc0201122:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201124:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201128:	e398                	sd	a4,0(a5)
ffffffffc020112a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020112c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020112e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201130:	0141                	addi	sp,sp,16
ffffffffc0201132:	8082                	ret
            p->property += base->property;
ffffffffc0201134:	491c                	lw	a5,16(a0)
ffffffffc0201136:	0107883b          	addw	a6,a5,a6
ffffffffc020113a:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020113e:	57f5                	li	a5,-3
ffffffffc0201140:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201144:	01853803          	ld	a6,24(a0)
ffffffffc0201148:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc020114a:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc020114c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201150:	659c                	ld	a5,8(a1)
ffffffffc0201152:	01073023          	sd	a6,0(a4)
ffffffffc0201156:	b765                	j	ffffffffc02010fe <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc0201158:	ff87a703          	lw	a4,-8(a5)
ffffffffc020115c:	ff078693          	addi	a3,a5,-16
ffffffffc0201160:	9db9                	addw	a1,a1,a4
ffffffffc0201162:	c90c                	sw	a1,16(a0)
ffffffffc0201164:	5775                	li	a4,-3
ffffffffc0201166:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020116a:	6398                	ld	a4,0(a5)
ffffffffc020116c:	679c                	ld	a5,8(a5)
}
ffffffffc020116e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201170:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201172:	e398                	sd	a4,0(a5)
ffffffffc0201174:	0141                	addi	sp,sp,16
ffffffffc0201176:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201178:	00001697          	auipc	a3,0x1
ffffffffc020117c:	3f068693          	addi	a3,a3,1008 # ffffffffc0202568 <commands+0x930>
ffffffffc0201180:	00001617          	auipc	a2,0x1
ffffffffc0201184:	0f060613          	addi	a2,a2,240 # ffffffffc0202270 <commands+0x638>
ffffffffc0201188:	09800593          	li	a1,152
ffffffffc020118c:	00001517          	auipc	a0,0x1
ffffffffc0201190:	0fc50513          	addi	a0,a0,252 # ffffffffc0202288 <commands+0x650>
ffffffffc0201194:	a18ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201198:	00001697          	auipc	a3,0x1
ffffffffc020119c:	0d068693          	addi	a3,a3,208 # ffffffffc0202268 <commands+0x630>
ffffffffc02011a0:	00001617          	auipc	a2,0x1
ffffffffc02011a4:	0d060613          	addi	a2,a2,208 # ffffffffc0202270 <commands+0x638>
ffffffffc02011a8:	09500593          	li	a1,149
ffffffffc02011ac:	00001517          	auipc	a0,0x1
ffffffffc02011b0:	0dc50513          	addi	a0,a0,220 # ffffffffc0202288 <commands+0x650>
ffffffffc02011b4:	9f8ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011b8 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02011b8:	1141                	addi	sp,sp,-16
ffffffffc02011ba:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011bc:	c1fd                	beqz	a1,ffffffffc02012a2 <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02011be:	00259693          	slli	a3,a1,0x2
ffffffffc02011c2:	96ae                	add	a3,a3,a1
ffffffffc02011c4:	068e                	slli	a3,a3,0x3
ffffffffc02011c6:	96aa                	add	a3,a3,a0
ffffffffc02011c8:	02d50463          	beq	a0,a3,ffffffffc02011f0 <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011cc:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02011ce:	87aa                	mv	a5,a0
ffffffffc02011d0:	8b05                	andi	a4,a4,1
ffffffffc02011d2:	e709                	bnez	a4,ffffffffc02011dc <best_fit_init_memmap+0x24>
ffffffffc02011d4:	a07d                	j	ffffffffc0201282 <best_fit_init_memmap+0xca>
ffffffffc02011d6:	6798                	ld	a4,8(a5)
ffffffffc02011d8:	8b05                	andi	a4,a4,1
ffffffffc02011da:	c745                	beqz	a4,ffffffffc0201282 <best_fit_init_memmap+0xca>
        p->flags = 0;
ffffffffc02011dc:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc02011e0:	0007a823          	sw	zero,16(a5)
ffffffffc02011e4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02011e8:	02878793          	addi	a5,a5,40
ffffffffc02011ec:	fed795e3          	bne	a5,a3,ffffffffc02011d6 <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc02011f0:	2581                	sext.w	a1,a1
ffffffffc02011f2:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02011f4:	4789                	li	a5,2
ffffffffc02011f6:	00850713          	addi	a4,a0,8
ffffffffc02011fa:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02011fe:	00005697          	auipc	a3,0x5
ffffffffc0201202:	23a68693          	addi	a3,a3,570 # ffffffffc0206438 <free_area>
ffffffffc0201206:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201208:	669c                	ld	a5,8(a3)
ffffffffc020120a:	9db9                	addw	a1,a1,a4
ffffffffc020120c:	00005717          	auipc	a4,0x5
ffffffffc0201210:	22b72e23          	sw	a1,572(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201214:	04d78a63          	beq	a5,a3,ffffffffc0201268 <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0201218:	fe878713          	addi	a4,a5,-24
ffffffffc020121c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020121e:	4801                	li	a6,0
ffffffffc0201220:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201224:	00e56a63          	bltu	a0,a4,ffffffffc0201238 <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc0201228:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020122a:	02d70563          	beq	a4,a3,ffffffffc0201254 <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020122e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201230:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201234:	fee57ae3          	bleu	a4,a0,ffffffffc0201228 <best_fit_init_memmap+0x70>
ffffffffc0201238:	00080663          	beqz	a6,ffffffffc0201244 <best_fit_init_memmap+0x8c>
ffffffffc020123c:	00005717          	auipc	a4,0x5
ffffffffc0201240:	1eb73e23          	sd	a1,508(a4) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201244:	6398                	ld	a4,0(a5)
}
ffffffffc0201246:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201248:	e390                	sd	a2,0(a5)
ffffffffc020124a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020124c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020124e:	ed18                	sd	a4,24(a0)
ffffffffc0201250:	0141                	addi	sp,sp,16
ffffffffc0201252:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201254:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201256:	f114                	sd	a3,32(a0)
ffffffffc0201258:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020125a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020125c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020125e:	00d70e63          	beq	a4,a3,ffffffffc020127a <best_fit_init_memmap+0xc2>
ffffffffc0201262:	4805                	li	a6,1
ffffffffc0201264:	87ba                	mv	a5,a4
ffffffffc0201266:	b7e9                	j	ffffffffc0201230 <best_fit_init_memmap+0x78>
}
ffffffffc0201268:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020126a:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020126e:	e398                	sd	a4,0(a5)
ffffffffc0201270:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201272:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201274:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201276:	0141                	addi	sp,sp,16
ffffffffc0201278:	8082                	ret
ffffffffc020127a:	60a2                	ld	ra,8(sp)
ffffffffc020127c:	e290                	sd	a2,0(a3)
ffffffffc020127e:	0141                	addi	sp,sp,16
ffffffffc0201280:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201282:	00001697          	auipc	a3,0x1
ffffffffc0201286:	30e68693          	addi	a3,a3,782 # ffffffffc0202590 <commands+0x958>
ffffffffc020128a:	00001617          	auipc	a2,0x1
ffffffffc020128e:	fe660613          	addi	a2,a2,-26 # ffffffffc0202270 <commands+0x638>
ffffffffc0201292:	04a00593          	li	a1,74
ffffffffc0201296:	00001517          	auipc	a0,0x1
ffffffffc020129a:	ff250513          	addi	a0,a0,-14 # ffffffffc0202288 <commands+0x650>
ffffffffc020129e:	90eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02012a2:	00001697          	auipc	a3,0x1
ffffffffc02012a6:	fc668693          	addi	a3,a3,-58 # ffffffffc0202268 <commands+0x630>
ffffffffc02012aa:	00001617          	auipc	a2,0x1
ffffffffc02012ae:	fc660613          	addi	a2,a2,-58 # ffffffffc0202270 <commands+0x638>
ffffffffc02012b2:	04700593          	li	a1,71
ffffffffc02012b6:	00001517          	auipc	a0,0x1
ffffffffc02012ba:	fd250513          	addi	a0,a0,-46 # ffffffffc0202288 <commands+0x650>
ffffffffc02012be:	8eeff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02012c2 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012c2:	100027f3          	csrr	a5,sstatus
ffffffffc02012c6:	8b89                	andi	a5,a5,2
ffffffffc02012c8:	eb89                	bnez	a5,ffffffffc02012da <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02012ca:	00005797          	auipc	a5,0x5
ffffffffc02012ce:	19678793          	addi	a5,a5,406 # ffffffffc0206460 <pmm_manager>
ffffffffc02012d2:	639c                	ld	a5,0(a5)
ffffffffc02012d4:	0187b303          	ld	t1,24(a5)
ffffffffc02012d8:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02012da:	1141                	addi	sp,sp,-16
ffffffffc02012dc:	e406                	sd	ra,8(sp)
ffffffffc02012de:	e022                	sd	s0,0(sp)
ffffffffc02012e0:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02012e2:	982ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02012e6:	00005797          	auipc	a5,0x5
ffffffffc02012ea:	17a78793          	addi	a5,a5,378 # ffffffffc0206460 <pmm_manager>
ffffffffc02012ee:	639c                	ld	a5,0(a5)
ffffffffc02012f0:	8522                	mv	a0,s0
ffffffffc02012f2:	6f9c                	ld	a5,24(a5)
ffffffffc02012f4:	9782                	jalr	a5
ffffffffc02012f6:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02012f8:	966ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02012fc:	8522                	mv	a0,s0
ffffffffc02012fe:	60a2                	ld	ra,8(sp)
ffffffffc0201300:	6402                	ld	s0,0(sp)
ffffffffc0201302:	0141                	addi	sp,sp,16
ffffffffc0201304:	8082                	ret

ffffffffc0201306 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201306:	100027f3          	csrr	a5,sstatus
ffffffffc020130a:	8b89                	andi	a5,a5,2
ffffffffc020130c:	eb89                	bnez	a5,ffffffffc020131e <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020130e:	00005797          	auipc	a5,0x5
ffffffffc0201312:	15278793          	addi	a5,a5,338 # ffffffffc0206460 <pmm_manager>
ffffffffc0201316:	639c                	ld	a5,0(a5)
ffffffffc0201318:	0207b303          	ld	t1,32(a5)
ffffffffc020131c:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020131e:	1101                	addi	sp,sp,-32
ffffffffc0201320:	ec06                	sd	ra,24(sp)
ffffffffc0201322:	e822                	sd	s0,16(sp)
ffffffffc0201324:	e426                	sd	s1,8(sp)
ffffffffc0201326:	842a                	mv	s0,a0
ffffffffc0201328:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020132a:	93aff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020132e:	00005797          	auipc	a5,0x5
ffffffffc0201332:	13278793          	addi	a5,a5,306 # ffffffffc0206460 <pmm_manager>
ffffffffc0201336:	639c                	ld	a5,0(a5)
ffffffffc0201338:	85a6                	mv	a1,s1
ffffffffc020133a:	8522                	mv	a0,s0
ffffffffc020133c:	739c                	ld	a5,32(a5)
ffffffffc020133e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201340:	6442                	ld	s0,16(sp)
ffffffffc0201342:	60e2                	ld	ra,24(sp)
ffffffffc0201344:	64a2                	ld	s1,8(sp)
ffffffffc0201346:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201348:	916ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc020134c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020134c:	100027f3          	csrr	a5,sstatus
ffffffffc0201350:	8b89                	andi	a5,a5,2
ffffffffc0201352:	eb89                	bnez	a5,ffffffffc0201364 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201354:	00005797          	auipc	a5,0x5
ffffffffc0201358:	10c78793          	addi	a5,a5,268 # ffffffffc0206460 <pmm_manager>
ffffffffc020135c:	639c                	ld	a5,0(a5)
ffffffffc020135e:	0287b303          	ld	t1,40(a5)
ffffffffc0201362:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201364:	1141                	addi	sp,sp,-16
ffffffffc0201366:	e406                	sd	ra,8(sp)
ffffffffc0201368:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020136a:	8faff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020136e:	00005797          	auipc	a5,0x5
ffffffffc0201372:	0f278793          	addi	a5,a5,242 # ffffffffc0206460 <pmm_manager>
ffffffffc0201376:	639c                	ld	a5,0(a5)
ffffffffc0201378:	779c                	ld	a5,40(a5)
ffffffffc020137a:	9782                	jalr	a5
ffffffffc020137c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020137e:	8e0ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201382:	8522                	mv	a0,s0
ffffffffc0201384:	60a2                	ld	ra,8(sp)
ffffffffc0201386:	6402                	ld	s0,0(sp)
ffffffffc0201388:	0141                	addi	sp,sp,16
ffffffffc020138a:	8082                	ret

ffffffffc020138c <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020138c:	00001797          	auipc	a5,0x1
ffffffffc0201390:	21478793          	addi	a5,a5,532 # ffffffffc02025a0 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201394:	638c                	ld	a1,0(a5)
        fppn=pa2page(mem_begin)-pages+nbase;
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201396:	7139                	addi	sp,sp,-64
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201398:	00001517          	auipc	a0,0x1
ffffffffc020139c:	25850513          	addi	a0,a0,600 # ffffffffc02025f0 <best_fit_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc02013a0:	fc06                	sd	ra,56(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013a2:	00005717          	auipc	a4,0x5
ffffffffc02013a6:	0af73f23          	sd	a5,190(a4) # ffffffffc0206460 <pmm_manager>
void pmm_init(void) {
ffffffffc02013aa:	f822                	sd	s0,48(sp)
ffffffffc02013ac:	f426                	sd	s1,40(sp)
ffffffffc02013ae:	ec4e                	sd	s3,24(sp)
ffffffffc02013b0:	f04a                	sd	s2,32(sp)
ffffffffc02013b2:	e852                	sd	s4,16(sp)
ffffffffc02013b4:	e456                	sd	s5,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013b6:	00005417          	auipc	s0,0x5
ffffffffc02013ba:	0aa40413          	addi	s0,s0,170 # ffffffffc0206460 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013be:	cf9fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02013c2:	601c                	ld	a5,0(s0)
ffffffffc02013c4:	00005497          	auipc	s1,0x5
ffffffffc02013c8:	05448493          	addi	s1,s1,84 # ffffffffc0206418 <npage>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02013cc:	fff809b7          	lui	s3,0xfff80
    pmm_manager->init();
ffffffffc02013d0:	679c                	ld	a5,8(a5)
ffffffffc02013d2:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013d4:	57f5                	li	a5,-3
ffffffffc02013d6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02013d8:	00001517          	auipc	a0,0x1
ffffffffc02013dc:	23050513          	addi	a0,a0,560 # ffffffffc0202608 <best_fit_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013e0:	00005717          	auipc	a4,0x5
ffffffffc02013e4:	08f73423          	sd	a5,136(a4) # ffffffffc0206468 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02013e8:	ccffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02013ec:	46c5                	li	a3,17
ffffffffc02013ee:	06ee                	slli	a3,a3,0x1b
ffffffffc02013f0:	40100613          	li	a2,1025
ffffffffc02013f4:	16fd                	addi	a3,a3,-1
ffffffffc02013f6:	0656                	slli	a2,a2,0x15
ffffffffc02013f8:	07e005b7          	lui	a1,0x7e00
ffffffffc02013fc:	00001517          	auipc	a0,0x1
ffffffffc0201400:	22450513          	addi	a0,a0,548 # ffffffffc0202620 <best_fit_pmm_manager+0x80>
ffffffffc0201404:	cb3fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201408:	777d                	lui	a4,0xfffff
ffffffffc020140a:	00006797          	auipc	a5,0x6
ffffffffc020140e:	06d78793          	addi	a5,a5,109 # ffffffffc0207477 <end+0xfff>
ffffffffc0201412:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201414:	00088737          	lui	a4,0x88
ffffffffc0201418:	00005697          	auipc	a3,0x5
ffffffffc020141c:	00e6b023          	sd	a4,0(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201420:	4601                	li	a2,0
ffffffffc0201422:	00005717          	auipc	a4,0x5
ffffffffc0201426:	04f73723          	sd	a5,78(a4) # ffffffffc0206470 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020142a:	4681                	li	a3,0
ffffffffc020142c:	00005597          	auipc	a1,0x5
ffffffffc0201430:	04458593          	addi	a1,a1,68 # ffffffffc0206470 <pages>
ffffffffc0201434:	4505                	li	a0,1
ffffffffc0201436:	a011                	j	ffffffffc020143a <pmm_init+0xae>
ffffffffc0201438:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020143a:	97b2                	add	a5,a5,a2
ffffffffc020143c:	07a1                	addi	a5,a5,8
ffffffffc020143e:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201442:	6098                	ld	a4,0(s1)
ffffffffc0201444:	0685                	addi	a3,a3,1
ffffffffc0201446:	02860613          	addi	a2,a2,40
ffffffffc020144a:	013707b3          	add	a5,a4,s3
ffffffffc020144e:	fef6e5e3          	bltu	a3,a5,ffffffffc0201438 <pmm_init+0xac>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201452:	6188                	ld	a0,0(a1)
ffffffffc0201454:	00271793          	slli	a5,a4,0x2
ffffffffc0201458:	97ba                	add	a5,a5,a4
ffffffffc020145a:	fec006b7          	lui	a3,0xfec00
ffffffffc020145e:	078e                	slli	a5,a5,0x3
ffffffffc0201460:	96aa                	add	a3,a3,a0
ffffffffc0201462:	96be                	add	a3,a3,a5
ffffffffc0201464:	c02007b7          	lui	a5,0xc0200
ffffffffc0201468:	0ef6e763          	bltu	a3,a5,ffffffffc0201556 <pmm_init+0x1ca>
ffffffffc020146c:	00005a17          	auipc	s4,0x5
ffffffffc0201470:	ffca0a13          	addi	s4,s4,-4 # ffffffffc0206468 <va_pa_offset>
ffffffffc0201474:	000a3783          	ld	a5,0(s4)
    if (freemem < mem_end) {
ffffffffc0201478:	45c5                	li	a1,17
ffffffffc020147a:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020147c:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc020147e:	06b6f463          	bleu	a1,a3,ffffffffc02014e6 <pmm_init+0x15a>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201482:	6785                	lui	a5,0x1
ffffffffc0201484:	17fd                	addi	a5,a5,-1
ffffffffc0201486:	96be                	add	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201488:	00c6da93          	srli	s5,a3,0xc
ffffffffc020148c:	0aeaf963          	bleu	a4,s5,ffffffffc020153e <pmm_init+0x1b2>
    pmm_manager->init_memmap(base, n);
ffffffffc0201490:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201492:	013a87b3          	add	a5,s5,s3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201496:	767d                	lui	a2,0xfffff
ffffffffc0201498:	8ef1                	and	a3,a3,a2
ffffffffc020149a:	00279993          	slli	s3,a5,0x2
ffffffffc020149e:	40d586b3          	sub	a3,a1,a3
ffffffffc02014a2:	99be                	add	s3,s3,a5
    pmm_manager->init_memmap(base, n);
ffffffffc02014a4:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02014a6:	00c6d913          	srli	s2,a3,0xc
ffffffffc02014aa:	098e                	slli	s3,s3,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02014ac:	954e                	add	a0,a0,s3
ffffffffc02014ae:	85ca                	mv	a1,s2
ffffffffc02014b0:	9782                	jalr	a5
        cprintf("size_t n is %d",(mem_end - mem_begin) / PGSIZE);
ffffffffc02014b2:	85ca                	mv	a1,s2
ffffffffc02014b4:	00001517          	auipc	a0,0x1
ffffffffc02014b8:	20450513          	addi	a0,a0,516 # ffffffffc02026b8 <best_fit_pmm_manager+0x118>
ffffffffc02014bc:	bfbfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (PPN(pa) >= npage) {
ffffffffc02014c0:	609c                	ld	a5,0(s1)
ffffffffc02014c2:	06fafe63          	bleu	a5,s5,ffffffffc020153e <pmm_init+0x1b2>
        fppn=pa2page(mem_begin)-pages+nbase;
ffffffffc02014c6:	00001797          	auipc	a5,0x1
ffffffffc02014ca:	dda78793          	addi	a5,a5,-550 # ffffffffc02022a0 <commands+0x668>
ffffffffc02014ce:	639c                	ld	a5,0(a5)
ffffffffc02014d0:	4039d993          	srai	s3,s3,0x3
ffffffffc02014d4:	02f989b3          	mul	s3,s3,a5
ffffffffc02014d8:	000807b7          	lui	a5,0x80
ffffffffc02014dc:	99be                	add	s3,s3,a5
ffffffffc02014de:	00005797          	auipc	a5,0x5
ffffffffc02014e2:	f737bd23          	sd	s3,-134(a5) # ffffffffc0206458 <fppn>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02014e6:	601c                	ld	a5,0(s0)
ffffffffc02014e8:	7b9c                	ld	a5,48(a5)
ffffffffc02014ea:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02014ec:	00001517          	auipc	a0,0x1
ffffffffc02014f0:	1dc50513          	addi	a0,a0,476 # ffffffffc02026c8 <best_fit_pmm_manager+0x128>
ffffffffc02014f4:	bc3fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02014f8:	00004697          	auipc	a3,0x4
ffffffffc02014fc:	b0868693          	addi	a3,a3,-1272 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201500:	00005797          	auipc	a5,0x5
ffffffffc0201504:	f2d7b023          	sd	a3,-224(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201508:	c02007b7          	lui	a5,0xc0200
ffffffffc020150c:	06f6e163          	bltu	a3,a5,ffffffffc020156e <pmm_init+0x1e2>
ffffffffc0201510:	000a3783          	ld	a5,0(s4)
}
ffffffffc0201514:	7442                	ld	s0,48(sp)
ffffffffc0201516:	70e2                	ld	ra,56(sp)
ffffffffc0201518:	74a2                	ld	s1,40(sp)
ffffffffc020151a:	7902                	ld	s2,32(sp)
ffffffffc020151c:	69e2                	ld	s3,24(sp)
ffffffffc020151e:	6a42                	ld	s4,16(sp)
ffffffffc0201520:	6aa2                	ld	s5,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201522:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0201524:	8e9d                	sub	a3,a3,a5
ffffffffc0201526:	00005797          	auipc	a5,0x5
ffffffffc020152a:	f2d7b523          	sd	a3,-214(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020152e:	00001517          	auipc	a0,0x1
ffffffffc0201532:	1ba50513          	addi	a0,a0,442 # ffffffffc02026e8 <best_fit_pmm_manager+0x148>
ffffffffc0201536:	8636                	mv	a2,a3
}
ffffffffc0201538:	6121                	addi	sp,sp,64
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020153a:	b7dfe06f          	j	ffffffffc02000b6 <cprintf>
        panic("pa2page called with invalid pa");
ffffffffc020153e:	00001617          	auipc	a2,0x1
ffffffffc0201542:	14a60613          	addi	a2,a2,330 # ffffffffc0202688 <best_fit_pmm_manager+0xe8>
ffffffffc0201546:	06b00593          	li	a1,107
ffffffffc020154a:	00001517          	auipc	a0,0x1
ffffffffc020154e:	15e50513          	addi	a0,a0,350 # ffffffffc02026a8 <best_fit_pmm_manager+0x108>
ffffffffc0201552:	e5bfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201556:	00001617          	auipc	a2,0x1
ffffffffc020155a:	0fa60613          	addi	a2,a2,250 # ffffffffc0202650 <best_fit_pmm_manager+0xb0>
ffffffffc020155e:	07300593          	li	a1,115
ffffffffc0201562:	00001517          	auipc	a0,0x1
ffffffffc0201566:	11650513          	addi	a0,a0,278 # ffffffffc0202678 <best_fit_pmm_manager+0xd8>
ffffffffc020156a:	e43fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020156e:	00001617          	auipc	a2,0x1
ffffffffc0201572:	0e260613          	addi	a2,a2,226 # ffffffffc0202650 <best_fit_pmm_manager+0xb0>
ffffffffc0201576:	09000593          	li	a1,144
ffffffffc020157a:	00001517          	auipc	a0,0x1
ffffffffc020157e:	0fe50513          	addi	a0,a0,254 # ffffffffc0202678 <best_fit_pmm_manager+0xd8>
ffffffffc0201582:	e2bfe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201586 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201586:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020158a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020158c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201590:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201592:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201596:	f022                	sd	s0,32(sp)
ffffffffc0201598:	ec26                	sd	s1,24(sp)
ffffffffc020159a:	e84a                	sd	s2,16(sp)
ffffffffc020159c:	f406                	sd	ra,40(sp)
ffffffffc020159e:	e44e                	sd	s3,8(sp)
ffffffffc02015a0:	84aa                	mv	s1,a0
ffffffffc02015a2:	892e                	mv	s2,a1
ffffffffc02015a4:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02015a8:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02015aa:	03067e63          	bleu	a6,a2,ffffffffc02015e6 <printnum+0x60>
ffffffffc02015ae:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02015b0:	00805763          	blez	s0,ffffffffc02015be <printnum+0x38>
ffffffffc02015b4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02015b6:	85ca                	mv	a1,s2
ffffffffc02015b8:	854e                	mv	a0,s3
ffffffffc02015ba:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02015bc:	fc65                	bnez	s0,ffffffffc02015b4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015be:	1a02                	slli	s4,s4,0x20
ffffffffc02015c0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02015c4:	00001797          	auipc	a5,0x1
ffffffffc02015c8:	2f478793          	addi	a5,a5,756 # ffffffffc02028b8 <error_string+0x38>
ffffffffc02015cc:	9a3e                	add	s4,s4,a5
}
ffffffffc02015ce:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015d0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02015d4:	70a2                	ld	ra,40(sp)
ffffffffc02015d6:	69a2                	ld	s3,8(sp)
ffffffffc02015d8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015da:	85ca                	mv	a1,s2
ffffffffc02015dc:	8326                	mv	t1,s1
}
ffffffffc02015de:	6942                	ld	s2,16(sp)
ffffffffc02015e0:	64e2                	ld	s1,24(sp)
ffffffffc02015e2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015e4:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02015e6:	03065633          	divu	a2,a2,a6
ffffffffc02015ea:	8722                	mv	a4,s0
ffffffffc02015ec:	f9bff0ef          	jal	ra,ffffffffc0201586 <printnum>
ffffffffc02015f0:	b7f9                	j	ffffffffc02015be <printnum+0x38>

ffffffffc02015f2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02015f2:	7119                	addi	sp,sp,-128
ffffffffc02015f4:	f4a6                	sd	s1,104(sp)
ffffffffc02015f6:	f0ca                	sd	s2,96(sp)
ffffffffc02015f8:	e8d2                	sd	s4,80(sp)
ffffffffc02015fa:	e4d6                	sd	s5,72(sp)
ffffffffc02015fc:	e0da                	sd	s6,64(sp)
ffffffffc02015fe:	fc5e                	sd	s7,56(sp)
ffffffffc0201600:	f862                	sd	s8,48(sp)
ffffffffc0201602:	f06a                	sd	s10,32(sp)
ffffffffc0201604:	fc86                	sd	ra,120(sp)
ffffffffc0201606:	f8a2                	sd	s0,112(sp)
ffffffffc0201608:	ecce                	sd	s3,88(sp)
ffffffffc020160a:	f466                	sd	s9,40(sp)
ffffffffc020160c:	ec6e                	sd	s11,24(sp)
ffffffffc020160e:	892a                	mv	s2,a0
ffffffffc0201610:	84ae                	mv	s1,a1
ffffffffc0201612:	8d32                	mv	s10,a2
ffffffffc0201614:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201616:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201618:	00001a17          	auipc	s4,0x1
ffffffffc020161c:	110a0a13          	addi	s4,s4,272 # ffffffffc0202728 <best_fit_pmm_manager+0x188>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201620:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201624:	00001c17          	auipc	s8,0x1
ffffffffc0201628:	25cc0c13          	addi	s8,s8,604 # ffffffffc0202880 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020162c:	000d4503          	lbu	a0,0(s10)
ffffffffc0201630:	02500793          	li	a5,37
ffffffffc0201634:	001d0413          	addi	s0,s10,1
ffffffffc0201638:	00f50e63          	beq	a0,a5,ffffffffc0201654 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc020163c:	c521                	beqz	a0,ffffffffc0201684 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020163e:	02500993          	li	s3,37
ffffffffc0201642:	a011                	j	ffffffffc0201646 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201644:	c121                	beqz	a0,ffffffffc0201684 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201646:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201648:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020164a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020164c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201650:	ff351ae3          	bne	a0,s3,ffffffffc0201644 <vprintfmt+0x52>
ffffffffc0201654:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201658:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020165c:	4981                	li	s3,0
ffffffffc020165e:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201660:	5cfd                	li	s9,-1
ffffffffc0201662:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201664:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201668:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020166a:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020166e:	0ff6f693          	andi	a3,a3,255
ffffffffc0201672:	00140d13          	addi	s10,s0,1
ffffffffc0201676:	20d5e563          	bltu	a1,a3,ffffffffc0201880 <vprintfmt+0x28e>
ffffffffc020167a:	068a                	slli	a3,a3,0x2
ffffffffc020167c:	96d2                	add	a3,a3,s4
ffffffffc020167e:	4294                	lw	a3,0(a3)
ffffffffc0201680:	96d2                	add	a3,a3,s4
ffffffffc0201682:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201684:	70e6                	ld	ra,120(sp)
ffffffffc0201686:	7446                	ld	s0,112(sp)
ffffffffc0201688:	74a6                	ld	s1,104(sp)
ffffffffc020168a:	7906                	ld	s2,96(sp)
ffffffffc020168c:	69e6                	ld	s3,88(sp)
ffffffffc020168e:	6a46                	ld	s4,80(sp)
ffffffffc0201690:	6aa6                	ld	s5,72(sp)
ffffffffc0201692:	6b06                	ld	s6,64(sp)
ffffffffc0201694:	7be2                	ld	s7,56(sp)
ffffffffc0201696:	7c42                	ld	s8,48(sp)
ffffffffc0201698:	7ca2                	ld	s9,40(sp)
ffffffffc020169a:	7d02                	ld	s10,32(sp)
ffffffffc020169c:	6de2                	ld	s11,24(sp)
ffffffffc020169e:	6109                	addi	sp,sp,128
ffffffffc02016a0:	8082                	ret
    if (lflag >= 2) {
ffffffffc02016a2:	4705                	li	a4,1
ffffffffc02016a4:	008a8593          	addi	a1,s5,8
ffffffffc02016a8:	01074463          	blt	a4,a6,ffffffffc02016b0 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02016ac:	26080363          	beqz	a6,ffffffffc0201912 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02016b0:	000ab603          	ld	a2,0(s5)
ffffffffc02016b4:	46c1                	li	a3,16
ffffffffc02016b6:	8aae                	mv	s5,a1
ffffffffc02016b8:	a06d                	j	ffffffffc0201762 <vprintfmt+0x170>
            goto reswitch;
ffffffffc02016ba:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02016be:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016c0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016c2:	b765                	j	ffffffffc020166a <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02016c4:	000aa503          	lw	a0,0(s5)
ffffffffc02016c8:	85a6                	mv	a1,s1
ffffffffc02016ca:	0aa1                	addi	s5,s5,8
ffffffffc02016cc:	9902                	jalr	s2
            break;
ffffffffc02016ce:	bfb9                	j	ffffffffc020162c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02016d0:	4705                	li	a4,1
ffffffffc02016d2:	008a8993          	addi	s3,s5,8
ffffffffc02016d6:	01074463          	blt	a4,a6,ffffffffc02016de <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02016da:	22080463          	beqz	a6,ffffffffc0201902 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02016de:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02016e2:	24044463          	bltz	s0,ffffffffc020192a <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02016e6:	8622                	mv	a2,s0
ffffffffc02016e8:	8ace                	mv	s5,s3
ffffffffc02016ea:	46a9                	li	a3,10
ffffffffc02016ec:	a89d                	j	ffffffffc0201762 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02016ee:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016f2:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02016f4:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02016f6:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02016fa:	8fb5                	xor	a5,a5,a3
ffffffffc02016fc:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201700:	1ad74363          	blt	a4,a3,ffffffffc02018a6 <vprintfmt+0x2b4>
ffffffffc0201704:	00369793          	slli	a5,a3,0x3
ffffffffc0201708:	97e2                	add	a5,a5,s8
ffffffffc020170a:	639c                	ld	a5,0(a5)
ffffffffc020170c:	18078d63          	beqz	a5,ffffffffc02018a6 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201710:	86be                	mv	a3,a5
ffffffffc0201712:	00001617          	auipc	a2,0x1
ffffffffc0201716:	25660613          	addi	a2,a2,598 # ffffffffc0202968 <error_string+0xe8>
ffffffffc020171a:	85a6                	mv	a1,s1
ffffffffc020171c:	854a                	mv	a0,s2
ffffffffc020171e:	240000ef          	jal	ra,ffffffffc020195e <printfmt>
ffffffffc0201722:	b729                	j	ffffffffc020162c <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201724:	00144603          	lbu	a2,1(s0)
ffffffffc0201728:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020172a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020172c:	bf3d                	j	ffffffffc020166a <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc020172e:	4705                	li	a4,1
ffffffffc0201730:	008a8593          	addi	a1,s5,8
ffffffffc0201734:	01074463          	blt	a4,a6,ffffffffc020173c <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201738:	1e080263          	beqz	a6,ffffffffc020191c <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc020173c:	000ab603          	ld	a2,0(s5)
ffffffffc0201740:	46a1                	li	a3,8
ffffffffc0201742:	8aae                	mv	s5,a1
ffffffffc0201744:	a839                	j	ffffffffc0201762 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201746:	03000513          	li	a0,48
ffffffffc020174a:	85a6                	mv	a1,s1
ffffffffc020174c:	e03e                	sd	a5,0(sp)
ffffffffc020174e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201750:	85a6                	mv	a1,s1
ffffffffc0201752:	07800513          	li	a0,120
ffffffffc0201756:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201758:	0aa1                	addi	s5,s5,8
ffffffffc020175a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020175e:	6782                	ld	a5,0(sp)
ffffffffc0201760:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201762:	876e                	mv	a4,s11
ffffffffc0201764:	85a6                	mv	a1,s1
ffffffffc0201766:	854a                	mv	a0,s2
ffffffffc0201768:	e1fff0ef          	jal	ra,ffffffffc0201586 <printnum>
            break;
ffffffffc020176c:	b5c1                	j	ffffffffc020162c <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020176e:	000ab603          	ld	a2,0(s5)
ffffffffc0201772:	0aa1                	addi	s5,s5,8
ffffffffc0201774:	1c060663          	beqz	a2,ffffffffc0201940 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201778:	00160413          	addi	s0,a2,1
ffffffffc020177c:	17b05c63          	blez	s11,ffffffffc02018f4 <vprintfmt+0x302>
ffffffffc0201780:	02d00593          	li	a1,45
ffffffffc0201784:	14b79263          	bne	a5,a1,ffffffffc02018c8 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201788:	00064783          	lbu	a5,0(a2)
ffffffffc020178c:	0007851b          	sext.w	a0,a5
ffffffffc0201790:	c905                	beqz	a0,ffffffffc02017c0 <vprintfmt+0x1ce>
ffffffffc0201792:	000cc563          	bltz	s9,ffffffffc020179c <vprintfmt+0x1aa>
ffffffffc0201796:	3cfd                	addiw	s9,s9,-1
ffffffffc0201798:	036c8263          	beq	s9,s6,ffffffffc02017bc <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc020179c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020179e:	18098463          	beqz	s3,ffffffffc0201926 <vprintfmt+0x334>
ffffffffc02017a2:	3781                	addiw	a5,a5,-32
ffffffffc02017a4:	18fbf163          	bleu	a5,s7,ffffffffc0201926 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02017a8:	03f00513          	li	a0,63
ffffffffc02017ac:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017ae:	0405                	addi	s0,s0,1
ffffffffc02017b0:	fff44783          	lbu	a5,-1(s0)
ffffffffc02017b4:	3dfd                	addiw	s11,s11,-1
ffffffffc02017b6:	0007851b          	sext.w	a0,a5
ffffffffc02017ba:	fd61                	bnez	a0,ffffffffc0201792 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02017bc:	e7b058e3          	blez	s11,ffffffffc020162c <vprintfmt+0x3a>
ffffffffc02017c0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02017c2:	85a6                	mv	a1,s1
ffffffffc02017c4:	02000513          	li	a0,32
ffffffffc02017c8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02017ca:	e60d81e3          	beqz	s11,ffffffffc020162c <vprintfmt+0x3a>
ffffffffc02017ce:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02017d0:	85a6                	mv	a1,s1
ffffffffc02017d2:	02000513          	li	a0,32
ffffffffc02017d6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02017d8:	fe0d94e3          	bnez	s11,ffffffffc02017c0 <vprintfmt+0x1ce>
ffffffffc02017dc:	bd81                	j	ffffffffc020162c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017de:	4705                	li	a4,1
ffffffffc02017e0:	008a8593          	addi	a1,s5,8
ffffffffc02017e4:	01074463          	blt	a4,a6,ffffffffc02017ec <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02017e8:	12080063          	beqz	a6,ffffffffc0201908 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02017ec:	000ab603          	ld	a2,0(s5)
ffffffffc02017f0:	46a9                	li	a3,10
ffffffffc02017f2:	8aae                	mv	s5,a1
ffffffffc02017f4:	b7bd                	j	ffffffffc0201762 <vprintfmt+0x170>
ffffffffc02017f6:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02017fa:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017fe:	846a                	mv	s0,s10
ffffffffc0201800:	b5ad                	j	ffffffffc020166a <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201802:	85a6                	mv	a1,s1
ffffffffc0201804:	02500513          	li	a0,37
ffffffffc0201808:	9902                	jalr	s2
            break;
ffffffffc020180a:	b50d                	j	ffffffffc020162c <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc020180c:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201810:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201814:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201816:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201818:	e40dd9e3          	bgez	s11,ffffffffc020166a <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020181c:	8de6                	mv	s11,s9
ffffffffc020181e:	5cfd                	li	s9,-1
ffffffffc0201820:	b5a9                	j	ffffffffc020166a <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201822:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201826:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020182a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020182c:	bd3d                	j	ffffffffc020166a <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc020182e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201832:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201836:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201838:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020183c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201840:	fcd56ce3          	bltu	a0,a3,ffffffffc0201818 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201844:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201846:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020184a:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020184e:	0196873b          	addw	a4,a3,s9
ffffffffc0201852:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201856:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020185a:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020185e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201862:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201866:	fcd57fe3          	bleu	a3,a0,ffffffffc0201844 <vprintfmt+0x252>
ffffffffc020186a:	b77d                	j	ffffffffc0201818 <vprintfmt+0x226>
            if (width < 0)
ffffffffc020186c:	fffdc693          	not	a3,s11
ffffffffc0201870:	96fd                	srai	a3,a3,0x3f
ffffffffc0201872:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201876:	00144603          	lbu	a2,1(s0)
ffffffffc020187a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020187c:	846a                	mv	s0,s10
ffffffffc020187e:	b3f5                	j	ffffffffc020166a <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201880:	85a6                	mv	a1,s1
ffffffffc0201882:	02500513          	li	a0,37
ffffffffc0201886:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201888:	fff44703          	lbu	a4,-1(s0)
ffffffffc020188c:	02500793          	li	a5,37
ffffffffc0201890:	8d22                	mv	s10,s0
ffffffffc0201892:	d8f70de3          	beq	a4,a5,ffffffffc020162c <vprintfmt+0x3a>
ffffffffc0201896:	02500713          	li	a4,37
ffffffffc020189a:	1d7d                	addi	s10,s10,-1
ffffffffc020189c:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02018a0:	fee79de3          	bne	a5,a4,ffffffffc020189a <vprintfmt+0x2a8>
ffffffffc02018a4:	b361                	j	ffffffffc020162c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02018a6:	00001617          	auipc	a2,0x1
ffffffffc02018aa:	0b260613          	addi	a2,a2,178 # ffffffffc0202958 <error_string+0xd8>
ffffffffc02018ae:	85a6                	mv	a1,s1
ffffffffc02018b0:	854a                	mv	a0,s2
ffffffffc02018b2:	0ac000ef          	jal	ra,ffffffffc020195e <printfmt>
ffffffffc02018b6:	bb9d                	j	ffffffffc020162c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02018b8:	00001617          	auipc	a2,0x1
ffffffffc02018bc:	09860613          	addi	a2,a2,152 # ffffffffc0202950 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02018c0:	00001417          	auipc	s0,0x1
ffffffffc02018c4:	09140413          	addi	s0,s0,145 # ffffffffc0202951 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018c8:	8532                	mv	a0,a2
ffffffffc02018ca:	85e6                	mv	a1,s9
ffffffffc02018cc:	e032                	sd	a2,0(sp)
ffffffffc02018ce:	e43e                	sd	a5,8(sp)
ffffffffc02018d0:	1c2000ef          	jal	ra,ffffffffc0201a92 <strnlen>
ffffffffc02018d4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02018d8:	6602                	ld	a2,0(sp)
ffffffffc02018da:	01b05d63          	blez	s11,ffffffffc02018f4 <vprintfmt+0x302>
ffffffffc02018de:	67a2                	ld	a5,8(sp)
ffffffffc02018e0:	2781                	sext.w	a5,a5
ffffffffc02018e2:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02018e4:	6522                	ld	a0,8(sp)
ffffffffc02018e6:	85a6                	mv	a1,s1
ffffffffc02018e8:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018ea:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02018ec:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018ee:	6602                	ld	a2,0(sp)
ffffffffc02018f0:	fe0d9ae3          	bnez	s11,ffffffffc02018e4 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018f4:	00064783          	lbu	a5,0(a2)
ffffffffc02018f8:	0007851b          	sext.w	a0,a5
ffffffffc02018fc:	e8051be3          	bnez	a0,ffffffffc0201792 <vprintfmt+0x1a0>
ffffffffc0201900:	b335                	j	ffffffffc020162c <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201902:	000aa403          	lw	s0,0(s5)
ffffffffc0201906:	bbf1                	j	ffffffffc02016e2 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0201908:	000ae603          	lwu	a2,0(s5)
ffffffffc020190c:	46a9                	li	a3,10
ffffffffc020190e:	8aae                	mv	s5,a1
ffffffffc0201910:	bd89                	j	ffffffffc0201762 <vprintfmt+0x170>
ffffffffc0201912:	000ae603          	lwu	a2,0(s5)
ffffffffc0201916:	46c1                	li	a3,16
ffffffffc0201918:	8aae                	mv	s5,a1
ffffffffc020191a:	b5a1                	j	ffffffffc0201762 <vprintfmt+0x170>
ffffffffc020191c:	000ae603          	lwu	a2,0(s5)
ffffffffc0201920:	46a1                	li	a3,8
ffffffffc0201922:	8aae                	mv	s5,a1
ffffffffc0201924:	bd3d                	j	ffffffffc0201762 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201926:	9902                	jalr	s2
ffffffffc0201928:	b559                	j	ffffffffc02017ae <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020192a:	85a6                	mv	a1,s1
ffffffffc020192c:	02d00513          	li	a0,45
ffffffffc0201930:	e03e                	sd	a5,0(sp)
ffffffffc0201932:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201934:	8ace                	mv	s5,s3
ffffffffc0201936:	40800633          	neg	a2,s0
ffffffffc020193a:	46a9                	li	a3,10
ffffffffc020193c:	6782                	ld	a5,0(sp)
ffffffffc020193e:	b515                	j	ffffffffc0201762 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201940:	01b05663          	blez	s11,ffffffffc020194c <vprintfmt+0x35a>
ffffffffc0201944:	02d00693          	li	a3,45
ffffffffc0201948:	f6d798e3          	bne	a5,a3,ffffffffc02018b8 <vprintfmt+0x2c6>
ffffffffc020194c:	00001417          	auipc	s0,0x1
ffffffffc0201950:	00540413          	addi	s0,s0,5 # ffffffffc0202951 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201954:	02800513          	li	a0,40
ffffffffc0201958:	02800793          	li	a5,40
ffffffffc020195c:	bd1d                	j	ffffffffc0201792 <vprintfmt+0x1a0>

ffffffffc020195e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020195e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201960:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201964:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201966:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201968:	ec06                	sd	ra,24(sp)
ffffffffc020196a:	f83a                	sd	a4,48(sp)
ffffffffc020196c:	fc3e                	sd	a5,56(sp)
ffffffffc020196e:	e0c2                	sd	a6,64(sp)
ffffffffc0201970:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201972:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201974:	c7fff0ef          	jal	ra,ffffffffc02015f2 <vprintfmt>
}
ffffffffc0201978:	60e2                	ld	ra,24(sp)
ffffffffc020197a:	6161                	addi	sp,sp,80
ffffffffc020197c:	8082                	ret

ffffffffc020197e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020197e:	715d                	addi	sp,sp,-80
ffffffffc0201980:	e486                	sd	ra,72(sp)
ffffffffc0201982:	e0a2                	sd	s0,64(sp)
ffffffffc0201984:	fc26                	sd	s1,56(sp)
ffffffffc0201986:	f84a                	sd	s2,48(sp)
ffffffffc0201988:	f44e                	sd	s3,40(sp)
ffffffffc020198a:	f052                	sd	s4,32(sp)
ffffffffc020198c:	ec56                	sd	s5,24(sp)
ffffffffc020198e:	e85a                	sd	s6,16(sp)
ffffffffc0201990:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201992:	c901                	beqz	a0,ffffffffc02019a2 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201994:	85aa                	mv	a1,a0
ffffffffc0201996:	00001517          	auipc	a0,0x1
ffffffffc020199a:	fd250513          	addi	a0,a0,-46 # ffffffffc0202968 <error_string+0xe8>
ffffffffc020199e:	f18fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02019a2:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019a4:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02019a6:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02019a8:	4aa9                	li	s5,10
ffffffffc02019aa:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02019ac:	00004b97          	auipc	s7,0x4
ffffffffc02019b0:	664b8b93          	addi	s7,s7,1636 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019b4:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02019b8:	f76fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02019bc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019be:	00054b63          	bltz	a0,ffffffffc02019d4 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019c2:	00a95b63          	ble	a0,s2,ffffffffc02019d8 <readline+0x5a>
ffffffffc02019c6:	029a5463          	ble	s1,s4,ffffffffc02019ee <readline+0x70>
        c = getchar();
ffffffffc02019ca:	f64fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02019ce:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019d0:	fe0559e3          	bgez	a0,ffffffffc02019c2 <readline+0x44>
            return NULL;
ffffffffc02019d4:	4501                	li	a0,0
ffffffffc02019d6:	a099                	j	ffffffffc0201a1c <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02019d8:	03341463          	bne	s0,s3,ffffffffc0201a00 <readline+0x82>
ffffffffc02019dc:	e8b9                	bnez	s1,ffffffffc0201a32 <readline+0xb4>
        c = getchar();
ffffffffc02019de:	f50fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02019e2:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019e4:	fe0548e3          	bltz	a0,ffffffffc02019d4 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019e8:	fea958e3          	ble	a0,s2,ffffffffc02019d8 <readline+0x5a>
ffffffffc02019ec:	4481                	li	s1,0
            cputchar(c);
ffffffffc02019ee:	8522                	mv	a0,s0
ffffffffc02019f0:	efafe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02019f4:	009b87b3          	add	a5,s7,s1
ffffffffc02019f8:	00878023          	sb	s0,0(a5)
ffffffffc02019fc:	2485                	addiw	s1,s1,1
ffffffffc02019fe:	bf6d                	j	ffffffffc02019b8 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201a00:	01540463          	beq	s0,s5,ffffffffc0201a08 <readline+0x8a>
ffffffffc0201a04:	fb641ae3          	bne	s0,s6,ffffffffc02019b8 <readline+0x3a>
            cputchar(c);
ffffffffc0201a08:	8522                	mv	a0,s0
ffffffffc0201a0a:	ee0fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201a0e:	00004517          	auipc	a0,0x4
ffffffffc0201a12:	60250513          	addi	a0,a0,1538 # ffffffffc0206010 <edata>
ffffffffc0201a16:	94aa                	add	s1,s1,a0
ffffffffc0201a18:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201a1c:	60a6                	ld	ra,72(sp)
ffffffffc0201a1e:	6406                	ld	s0,64(sp)
ffffffffc0201a20:	74e2                	ld	s1,56(sp)
ffffffffc0201a22:	7942                	ld	s2,48(sp)
ffffffffc0201a24:	79a2                	ld	s3,40(sp)
ffffffffc0201a26:	7a02                	ld	s4,32(sp)
ffffffffc0201a28:	6ae2                	ld	s5,24(sp)
ffffffffc0201a2a:	6b42                	ld	s6,16(sp)
ffffffffc0201a2c:	6ba2                	ld	s7,8(sp)
ffffffffc0201a2e:	6161                	addi	sp,sp,80
ffffffffc0201a30:	8082                	ret
            cputchar(c);
ffffffffc0201a32:	4521                	li	a0,8
ffffffffc0201a34:	eb6fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201a38:	34fd                	addiw	s1,s1,-1
ffffffffc0201a3a:	bfbd                	j	ffffffffc02019b8 <readline+0x3a>

ffffffffc0201a3c <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201a3c:	00004797          	auipc	a5,0x4
ffffffffc0201a40:	5cc78793          	addi	a5,a5,1484 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201a44:	6398                	ld	a4,0(a5)
ffffffffc0201a46:	4781                	li	a5,0
ffffffffc0201a48:	88ba                	mv	a7,a4
ffffffffc0201a4a:	852a                	mv	a0,a0
ffffffffc0201a4c:	85be                	mv	a1,a5
ffffffffc0201a4e:	863e                	mv	a2,a5
ffffffffc0201a50:	00000073          	ecall
ffffffffc0201a54:	87aa                	mv	a5,a0
}
ffffffffc0201a56:	8082                	ret

ffffffffc0201a58 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201a58:	00005797          	auipc	a5,0x5
ffffffffc0201a5c:	9d078793          	addi	a5,a5,-1584 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201a60:	6398                	ld	a4,0(a5)
ffffffffc0201a62:	4781                	li	a5,0
ffffffffc0201a64:	88ba                	mv	a7,a4
ffffffffc0201a66:	852a                	mv	a0,a0
ffffffffc0201a68:	85be                	mv	a1,a5
ffffffffc0201a6a:	863e                	mv	a2,a5
ffffffffc0201a6c:	00000073          	ecall
ffffffffc0201a70:	87aa                	mv	a5,a0
}
ffffffffc0201a72:	8082                	ret

ffffffffc0201a74 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201a74:	00004797          	auipc	a5,0x4
ffffffffc0201a78:	58c78793          	addi	a5,a5,1420 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201a7c:	639c                	ld	a5,0(a5)
ffffffffc0201a7e:	4501                	li	a0,0
ffffffffc0201a80:	88be                	mv	a7,a5
ffffffffc0201a82:	852a                	mv	a0,a0
ffffffffc0201a84:	85aa                	mv	a1,a0
ffffffffc0201a86:	862a                	mv	a2,a0
ffffffffc0201a88:	00000073          	ecall
ffffffffc0201a8c:	852a                	mv	a0,a0
ffffffffc0201a8e:	2501                	sext.w	a0,a0
ffffffffc0201a90:	8082                	ret

ffffffffc0201a92 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a92:	c185                	beqz	a1,ffffffffc0201ab2 <strnlen+0x20>
ffffffffc0201a94:	00054783          	lbu	a5,0(a0)
ffffffffc0201a98:	cf89                	beqz	a5,ffffffffc0201ab2 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201a9a:	4781                	li	a5,0
ffffffffc0201a9c:	a021                	j	ffffffffc0201aa4 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a9e:	00074703          	lbu	a4,0(a4)
ffffffffc0201aa2:	c711                	beqz	a4,ffffffffc0201aae <strnlen+0x1c>
        cnt ++;
ffffffffc0201aa4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201aa6:	00f50733          	add	a4,a0,a5
ffffffffc0201aaa:	fef59ae3          	bne	a1,a5,ffffffffc0201a9e <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201aae:	853e                	mv	a0,a5
ffffffffc0201ab0:	8082                	ret
    size_t cnt = 0;
ffffffffc0201ab2:	4781                	li	a5,0
}
ffffffffc0201ab4:	853e                	mv	a0,a5
ffffffffc0201ab6:	8082                	ret

ffffffffc0201ab8 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201ab8:	00054783          	lbu	a5,0(a0)
ffffffffc0201abc:	0005c703          	lbu	a4,0(a1)
ffffffffc0201ac0:	cb91                	beqz	a5,ffffffffc0201ad4 <strcmp+0x1c>
ffffffffc0201ac2:	00e79c63          	bne	a5,a4,ffffffffc0201ada <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201ac6:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201ac8:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201acc:	0585                	addi	a1,a1,1
ffffffffc0201ace:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201ad2:	fbe5                	bnez	a5,ffffffffc0201ac2 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201ad4:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201ad6:	9d19                	subw	a0,a0,a4
ffffffffc0201ad8:	8082                	ret
ffffffffc0201ada:	0007851b          	sext.w	a0,a5
ffffffffc0201ade:	9d19                	subw	a0,a0,a4
ffffffffc0201ae0:	8082                	ret

ffffffffc0201ae2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201ae2:	00054783          	lbu	a5,0(a0)
ffffffffc0201ae6:	cb91                	beqz	a5,ffffffffc0201afa <strchr+0x18>
        if (*s == c) {
ffffffffc0201ae8:	00b79563          	bne	a5,a1,ffffffffc0201af2 <strchr+0x10>
ffffffffc0201aec:	a809                	j	ffffffffc0201afe <strchr+0x1c>
ffffffffc0201aee:	00b78763          	beq	a5,a1,ffffffffc0201afc <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201af2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201af4:	00054783          	lbu	a5,0(a0)
ffffffffc0201af8:	fbfd                	bnez	a5,ffffffffc0201aee <strchr+0xc>
    }
    return NULL;
ffffffffc0201afa:	4501                	li	a0,0
}
ffffffffc0201afc:	8082                	ret
ffffffffc0201afe:	8082                	ret

ffffffffc0201b00 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201b00:	ca01                	beqz	a2,ffffffffc0201b10 <memset+0x10>
ffffffffc0201b02:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201b04:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201b06:	0785                	addi	a5,a5,1
ffffffffc0201b08:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201b0c:	fec79de3          	bne	a5,a2,ffffffffc0201b06 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201b10:	8082                	ret
