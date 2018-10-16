
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 b8 07 ff ff    	lea    -0xf848(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 84 0a 00 00       	call   f0100ae7 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7f 2b                	jg     f0100095 <test_backtrace+0x55>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010006a:	83 ec 04             	sub    $0x4,%esp
f010006d:	6a 00                	push   $0x0
f010006f:	6a 00                	push   $0x0
f0100071:	6a 00                	push   $0x0
f0100073:	e8 0b 08 00 00       	call   f0100883 <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 d4 07 ff ff    	lea    -0xf82c(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 5c 0a 00 00       	call   f0100ae7 <cprintf>
}
f010008b:	83 c4 10             	add    $0x10,%esp
f010008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100091:	5b                   	pop    %ebx
f0100092:	5e                   	pop    %esi
f0100093:	5d                   	pop    %ebp
f0100094:	c3                   	ret    
		test_backtrace(x-1);
f0100095:	83 ec 0c             	sub    $0xc,%esp
f0100098:	8d 46 ff             	lea    -0x1(%esi),%eax
f010009b:	50                   	push   %eax
f010009c:	e8 9f ff ff ff       	call   f0100040 <test_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d5                	jmp    f010007b <test_backtrace+0x3b>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 ad 15 00 00       	call   f010167c <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3d 05 00 00       	call   f0100611 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 ef 07 ff ff    	lea    -0xf811(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 ff 09 00 00       	call   f0100ae7 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 2a 08 00 00       	call   f010092b <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	57                   	push   %edi
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	83 ec 0c             	sub    $0xc,%esp
f010010f:	e8 a8 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100114:	81 c3 f4 11 01 00    	add    $0x111f4,%ebx
f010011a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010011d:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f0100123:	83 38 00             	cmpl   $0x0,(%eax)
f0100126:	74 0f                	je     f0100137 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100128:	83 ec 0c             	sub    $0xc,%esp
f010012b:	6a 00                	push   $0x0
f010012d:	e8 f9 07 00 00       	call   f010092b <monitor>
f0100132:	83 c4 10             	add    $0x10,%esp
f0100135:	eb f1                	jmp    f0100128 <_panic+0x22>
	panicstr = fmt;
f0100137:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    
	va_start(ap, fmt);
f010013b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	8d 83 0a 08 ff ff    	lea    -0xf7f6(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 94 09 00 00       	call   f0100ae7 <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 53 09 00 00       	call   f0100ab0 <vcprintf>
	cprintf("\n");
f010015d:	8d 83 46 08 ff ff    	lea    -0xf7ba(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 7c 09 00 00       	call   f0100ae7 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb b8                	jmp    f0100128 <_panic+0x22>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 22 08 ff ff    	lea    -0xf7de(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 4f 09 00 00       	call   f0100ae7 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 0c 09 00 00       	call   f0100ab0 <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 46 08 ff ff    	lea    -0xf7ba(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 35 09 00 00       	call   f0100ae7 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c9:	a8 01                	test   $0x1,%al
f01001cb:	74 0b                	je     f01001d8 <serial_proc_data+0x18>
f01001cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d3:	0f b6 c0             	movzbl %al,%eax
}
f01001d6:	5d                   	pop    %ebp
f01001d7:	c3                   	ret    
		return -1;
f01001d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001dd:	eb f7                	jmp    f01001d6 <serial_proc_data+0x16>

f01001df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	e8 d3 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01001e9:	81 c3 1f 11 01 00    	add    $0x1111f,%ebx
f01001ef:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d6                	call   *%esi
f01001f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f6:	74 2e                	je     f0100226 <cons_intr+0x47>
		if (c == 0)
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	74 f5                	je     f01001f1 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fc:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010020b:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100212:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100218:	75 d7                	jne    f01001f1 <cons_intr+0x12>
			cons.wpos = 0;
f010021a:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f0100221:	00 00 00 
f0100224:	eb cb                	jmp    f01001f1 <cons_intr+0x12>
	}
}
f0100226:	5b                   	pop    %ebx
f0100227:	5e                   	pop    %esi
f0100228:	5d                   	pop    %ebp
f0100229:	c3                   	ret    

f010022a <kbd_proc_data>:
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	56                   	push   %esi
f010022e:	53                   	push   %ebx
f010022f:	e8 88 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100234:	81 c3 d4 10 01 00    	add    $0x110d4,%ebx
f010023a:	ba 64 00 00 00       	mov    $0x64,%edx
f010023f:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100240:	a8 01                	test   $0x1,%al
f0100242:	0f 84 06 01 00 00    	je     f010034e <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100248:	a8 20                	test   $0x20,%al
f010024a:	0f 85 05 01 00 00    	jne    f0100355 <kbd_proc_data+0x12b>
f0100250:	ba 60 00 00 00       	mov    $0x60,%edx
f0100255:	ec                   	in     (%dx),%al
f0100256:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100258:	3c e0                	cmp    $0xe0,%al
f010025a:	0f 84 93 00 00 00    	je     f01002f3 <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f0100260:	84 c0                	test   %al,%al
f0100262:	0f 88 a0 00 00 00    	js     f0100308 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100268:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010026e:	f6 c1 40             	test   $0x40,%cl
f0100271:	74 0e                	je     f0100281 <kbd_proc_data+0x57>
		data |= 0x80;
f0100273:	83 c8 80             	or     $0xffffff80,%eax
f0100276:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100278:	83 e1 bf             	and    $0xffffffbf,%ecx
f010027b:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100281:	0f b6 d2             	movzbl %dl,%edx
f0100284:	0f b6 84 13 78 09 ff 	movzbl -0xf688(%ebx,%edx,1),%eax
f010028b:	ff 
f010028c:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100292:	0f b6 8c 13 78 08 ff 	movzbl -0xf788(%ebx,%edx,1),%ecx
f0100299:	ff 
f010029a:	31 c8                	xor    %ecx,%eax
f010029c:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a2:	89 c1                	mov    %eax,%ecx
f01002a4:	83 e1 03             	and    $0x3,%ecx
f01002a7:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ae:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002b2:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002b5:	a8 08                	test   $0x8,%al
f01002b7:	74 0d                	je     f01002c6 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002b9:	89 f2                	mov    %esi,%edx
f01002bb:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002be:	83 f9 19             	cmp    $0x19,%ecx
f01002c1:	77 7a                	ja     f010033d <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002c3:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c6:	f7 d0                	not    %eax
f01002c8:	a8 06                	test   $0x6,%al
f01002ca:	75 33                	jne    f01002ff <kbd_proc_data+0xd5>
f01002cc:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002d2:	75 2b                	jne    f01002ff <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01002d4:	83 ec 0c             	sub    $0xc,%esp
f01002d7:	8d 83 3c 08 ff ff    	lea    -0xf7c4(%ebx),%eax
f01002dd:	50                   	push   %eax
f01002de:	e8 04 08 00 00       	call   f0100ae7 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e8:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ed:	ee                   	out    %al,(%dx)
f01002ee:	83 c4 10             	add    $0x10,%esp
f01002f1:	eb 0c                	jmp    f01002ff <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002f3:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002fa:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002ff:	89 f0                	mov    %esi,%eax
f0100301:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100304:	5b                   	pop    %ebx
f0100305:	5e                   	pop    %esi
f0100306:	5d                   	pop    %ebp
f0100307:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100308:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010030e:	89 ce                	mov    %ecx,%esi
f0100310:	83 e6 40             	and    $0x40,%esi
f0100313:	83 e0 7f             	and    $0x7f,%eax
f0100316:	85 f6                	test   %esi,%esi
f0100318:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031b:	0f b6 d2             	movzbl %dl,%edx
f010031e:	0f b6 84 13 78 09 ff 	movzbl -0xf688(%ebx,%edx,1),%eax
f0100325:	ff 
f0100326:	83 c8 40             	or     $0x40,%eax
f0100329:	0f b6 c0             	movzbl %al,%eax
f010032c:	f7 d0                	not    %eax
f010032e:	21 c8                	and    %ecx,%eax
f0100330:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f0100336:	be 00 00 00 00       	mov    $0x0,%esi
f010033b:	eb c2                	jmp    f01002ff <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f010033d:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100340:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100343:	83 fa 1a             	cmp    $0x1a,%edx
f0100346:	0f 42 f1             	cmovb  %ecx,%esi
f0100349:	e9 78 ff ff ff       	jmp    f01002c6 <kbd_proc_data+0x9c>
		return -1;
f010034e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100353:	eb aa                	jmp    f01002ff <kbd_proc_data+0xd5>
		return -1;
f0100355:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035a:	eb a3                	jmp    f01002ff <kbd_proc_data+0xd5>

f010035c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010035c:	55                   	push   %ebp
f010035d:	89 e5                	mov    %esp,%ebp
f010035f:	57                   	push   %edi
f0100360:	56                   	push   %esi
f0100361:	53                   	push   %ebx
f0100362:	83 ec 1c             	sub    $0x1c,%esp
f0100365:	e8 52 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010036a:	81 c3 9e 0f 01 00    	add    $0x10f9e,%ebx
f0100370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100373:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100378:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010037d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100382:	eb 09                	jmp    f010038d <cons_putc+0x31>
f0100384:	89 ca                	mov    %ecx,%edx
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
f0100389:	ec                   	in     (%dx),%al
	     i++)
f010038a:	83 c6 01             	add    $0x1,%esi
f010038d:	89 fa                	mov    %edi,%edx
f010038f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100390:	a8 20                	test   $0x20,%al
f0100392:	75 08                	jne    f010039c <cons_putc+0x40>
f0100394:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010039a:	7e e8                	jle    f0100384 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039f:	89 f8                	mov    %edi,%eax
f01003a1:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a9:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003aa:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003af:	bf 79 03 00 00       	mov    $0x379,%edi
f01003b4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b9:	eb 09                	jmp    f01003c4 <cons_putc+0x68>
f01003bb:	89 ca                	mov    %ecx,%edx
f01003bd:	ec                   	in     (%dx),%al
f01003be:	ec                   	in     (%dx),%al
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	83 c6 01             	add    $0x1,%esi
f01003c4:	89 fa                	mov    %edi,%edx
f01003c6:	ec                   	in     (%dx),%al
f01003c7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003cd:	7f 04                	jg     f01003d3 <cons_putc+0x77>
f01003cf:	84 c0                	test   %al,%al
f01003d1:	79 e8                	jns    f01003bb <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d3:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d8:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003dc:	ee                   	out    %al,(%dx)
f01003dd:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e7:	ee                   	out    %al,(%dx)
f01003e8:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ed:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f1:	89 fa                	mov    %edi,%edx
f01003f3:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003f9:	89 f8                	mov    %edi,%eax
f01003fb:	80 cc 07             	or     $0x7,%ah
f01003fe:	85 d2                	test   %edx,%edx
f0100400:	0f 45 c7             	cmovne %edi,%eax
f0100403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100406:	0f b6 c0             	movzbl %al,%eax
f0100409:	83 f8 09             	cmp    $0x9,%eax
f010040c:	0f 84 b9 00 00 00    	je     f01004cb <cons_putc+0x16f>
f0100412:	83 f8 09             	cmp    $0x9,%eax
f0100415:	7e 74                	jle    f010048b <cons_putc+0x12f>
f0100417:	83 f8 0a             	cmp    $0xa,%eax
f010041a:	0f 84 9e 00 00 00    	je     f01004be <cons_putc+0x162>
f0100420:	83 f8 0d             	cmp    $0xd,%eax
f0100423:	0f 85 d9 00 00 00    	jne    f0100502 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100429:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100430:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100436:	c1 e8 16             	shr    $0x16,%eax
f0100439:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043c:	c1 e0 04             	shl    $0x4,%eax
f010043f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100446:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010044d:	cf 07 
f010044f:	0f 87 d4 00 00 00    	ja     f0100529 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100455:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f010045b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100460:	89 ca                	mov    %ecx,%edx
f0100462:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100463:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f010046a:	8d 71 01             	lea    0x1(%ecx),%esi
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	66 c1 e8 08          	shr    $0x8,%ax
f0100473:	89 f2                	mov    %esi,%edx
f0100475:	ee                   	out    %al,(%dx)
f0100476:	b8 0f 00 00 00       	mov    $0xf,%eax
f010047b:	89 ca                	mov    %ecx,%edx
f010047d:	ee                   	out    %al,(%dx)
f010047e:	89 d8                	mov    %ebx,%eax
f0100480:	89 f2                	mov    %esi,%edx
f0100482:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100483:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100486:	5b                   	pop    %ebx
f0100487:	5e                   	pop    %esi
f0100488:	5f                   	pop    %edi
f0100489:	5d                   	pop    %ebp
f010048a:	c3                   	ret    
	switch (c & 0xff) {
f010048b:	83 f8 08             	cmp    $0x8,%eax
f010048e:	75 72                	jne    f0100502 <cons_putc+0x1a6>
		if (crt_pos > 0) {
f0100490:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100497:	66 85 c0             	test   %ax,%ax
f010049a:	74 b9                	je     f0100455 <cons_putc+0xf9>
			crt_pos--;
f010049c:	83 e8 01             	sub    $0x1,%eax
f010049f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ad:	b2 00                	mov    $0x0,%dl
f01004af:	83 ca 20             	or     $0x20,%edx
f01004b2:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004b8:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004bc:	eb 88                	jmp    f0100446 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01004be:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004c5:	50 
f01004c6:	e9 5e ff ff ff       	jmp    f0100429 <cons_putc+0xcd>
		cons_putc(' ');
f01004cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d0:	e8 87 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004da:	e8 7d fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004df:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e4:	e8 73 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ee:	e8 69 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f8:	e8 5f fe ff ff       	call   f010035c <cons_putc>
f01004fd:	e9 44 ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100502:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100509:	8d 50 01             	lea    0x1(%eax),%edx
f010050c:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100513:	0f b7 c0             	movzwl %ax,%eax
f0100516:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010051c:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100520:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100524:	e9 1d ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100529:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010052f:	83 ec 04             	sub    $0x4,%esp
f0100532:	68 00 0f 00 00       	push   $0xf00
f0100537:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010053d:	52                   	push   %edx
f010053e:	50                   	push   %eax
f010053f:	e8 85 11 00 00       	call   f01016c9 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100544:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010054a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100550:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100556:	83 c4 10             	add    $0x10,%esp
f0100559:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010055e:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100561:	39 d0                	cmp    %edx,%eax
f0100563:	75 f4                	jne    f0100559 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100565:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010056c:	50 
f010056d:	e9 e3 fe ff ff       	jmp    f0100455 <cons_putc+0xf9>

f0100572 <serial_intr>:
{
f0100572:	e8 e7 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f0100577:	05 91 0d 01 00       	add    $0x10d91,%eax
	if (serial_exists)
f010057c:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100583:	75 02                	jne    f0100587 <serial_intr+0x15>
f0100585:	f3 c3                	repz ret 
{
f0100587:	55                   	push   %ebp
f0100588:	89 e5                	mov    %esp,%ebp
f010058a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010058d:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f0100593:	e8 47 fc ff ff       	call   f01001df <cons_intr>
}
f0100598:	c9                   	leave  
f0100599:	c3                   	ret    

f010059a <kbd_intr>:
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	83 ec 08             	sub    $0x8,%esp
f01005a0:	e8 b9 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f01005a5:	05 63 0d 01 00       	add    $0x10d63,%eax
	cons_intr(kbd_proc_data);
f01005aa:	8d 80 22 ef fe ff    	lea    -0x110de(%eax),%eax
f01005b0:	e8 2a fc ff ff       	call   f01001df <cons_intr>
}
f01005b5:	c9                   	leave  
f01005b6:	c3                   	ret    

f01005b7 <cons_getc>:
{
f01005b7:	55                   	push   %ebp
f01005b8:	89 e5                	mov    %esp,%ebp
f01005ba:	53                   	push   %ebx
f01005bb:	83 ec 04             	sub    $0x4,%esp
f01005be:	e8 f9 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005c3:	81 c3 45 0d 01 00    	add    $0x10d45,%ebx
	serial_intr();
f01005c9:	e8 a4 ff ff ff       	call   f0100572 <serial_intr>
	kbd_intr();
f01005ce:	e8 c7 ff ff ff       	call   f010059a <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005d3:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f01005d9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005de:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f01005e4:	74 19                	je     f01005ff <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005e9:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f01005ef:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f01005f6:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005f7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005fd:	74 06                	je     f0100605 <cons_getc+0x4e>
}
f01005ff:	83 c4 04             	add    $0x4,%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5d                   	pop    %ebp
f0100604:	c3                   	ret    
			cons.rpos = 0;
f0100605:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010060c:	00 00 00 
f010060f:	eb ee                	jmp    f01005ff <cons_getc+0x48>

f0100611 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	57                   	push   %edi
f0100615:	56                   	push   %esi
f0100616:	53                   	push   %ebx
f0100617:	83 ec 1c             	sub    $0x1c,%esp
f010061a:	e8 9d fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010061f:	81 c3 e9 0c 01 00    	add    $0x10ce9,%ebx
	was = *cp;
f0100625:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100633:	5a a5 
	if (*cp != 0xA55A) {
f0100635:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100640:	0f 84 bc 00 00 00    	je     f0100702 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100646:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010064d:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100650:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100657:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010065d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100662:	89 fa                	mov    %edi,%edx
f0100664:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100665:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100668:	89 ca                	mov    %ecx,%edx
f010066a:	ec                   	in     (%dx),%al
f010066b:	0f b6 f0             	movzbl %al,%esi
f010066e:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100671:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100676:	89 fa                	mov    %edi,%edx
f0100678:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100679:	89 ca                	mov    %ecx,%edx
f010067b:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010067f:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100685:	0f b6 c0             	movzbl %al,%eax
f0100688:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010068a:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100691:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100696:	89 c8                	mov    %ecx,%eax
f0100698:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010069d:	ee                   	out    %al,(%dx)
f010069e:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006a3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a8:	89 fa                	mov    %edi,%edx
f01006aa:	ee                   	out    %al,(%dx)
f01006ab:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006b0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b5:	ee                   	out    %al,(%dx)
f01006b6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006bb:	89 c8                	mov    %ecx,%eax
f01006bd:	89 f2                	mov    %esi,%edx
f01006bf:	ee                   	out    %al,(%dx)
f01006c0:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c5:	89 fa                	mov    %edi,%edx
f01006c7:	ee                   	out    %al,(%dx)
f01006c8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006cd:	89 c8                	mov    %ecx,%eax
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d5:	89 f2                	mov    %esi,%edx
f01006d7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006dd:	ec                   	in     (%dx),%al
f01006de:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006e0:	3c ff                	cmp    $0xff,%al
f01006e2:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006e9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006ee:	ec                   	in     (%dx),%al
f01006ef:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f4:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f5:	80 f9 ff             	cmp    $0xff,%cl
f01006f8:	74 25                	je     f010071f <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006fd:	5b                   	pop    %ebx
f01006fe:	5e                   	pop    %esi
f01006ff:	5f                   	pop    %edi
f0100700:	5d                   	pop    %ebp
f0100701:	c3                   	ret    
		*cp = was;
f0100702:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100709:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100710:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100713:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010071a:	e9 38 ff ff ff       	jmp    f0100657 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f010071f:	83 ec 0c             	sub    $0xc,%esp
f0100722:	8d 83 48 08 ff ff    	lea    -0xf7b8(%ebx),%eax
f0100728:	50                   	push   %eax
f0100729:	e8 b9 03 00 00       	call   f0100ae7 <cprintf>
f010072e:	83 c4 10             	add    $0x10,%esp
}
f0100731:	eb c7                	jmp    f01006fa <cons_init+0xe9>

f0100733 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100739:	8b 45 08             	mov    0x8(%ebp),%eax
f010073c:	e8 1b fc ff ff       	call   f010035c <cons_putc>
}
f0100741:	c9                   	leave  
f0100742:	c3                   	ret    

f0100743 <getchar>:

int
getchar(void)
{
f0100743:	55                   	push   %ebp
f0100744:	89 e5                	mov    %esp,%ebp
f0100746:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100749:	e8 69 fe ff ff       	call   f01005b7 <cons_getc>
f010074e:	85 c0                	test   %eax,%eax
f0100750:	74 f7                	je     f0100749 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100752:	c9                   	leave  
f0100753:	c3                   	ret    

f0100754 <iscons>:

int
iscons(int fdnum)
{
f0100754:	55                   	push   %ebp
f0100755:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100757:	b8 01 00 00 00       	mov    $0x1,%eax
f010075c:	5d                   	pop    %ebp
f010075d:	c3                   	ret    

f010075e <__x86.get_pc_thunk.ax>:
f010075e:	8b 04 24             	mov    (%esp),%eax
f0100761:	c3                   	ret    

f0100762 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100762:	55                   	push   %ebp
f0100763:	89 e5                	mov    %esp,%ebp
f0100765:	56                   	push   %esi
f0100766:	53                   	push   %ebx
f0100767:	e8 50 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010076c:	81 c3 9c 0b 01 00    	add    $0x10b9c,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100772:	83 ec 04             	sub    $0x4,%esp
f0100775:	8d 83 78 0a ff ff    	lea    -0xf588(%ebx),%eax
f010077b:	50                   	push   %eax
f010077c:	8d 83 96 0a ff ff    	lea    -0xf56a(%ebx),%eax
f0100782:	50                   	push   %eax
f0100783:	8d b3 9b 0a ff ff    	lea    -0xf565(%ebx),%esi
f0100789:	56                   	push   %esi
f010078a:	e8 58 03 00 00       	call   f0100ae7 <cprintf>
f010078f:	83 c4 0c             	add    $0xc,%esp
f0100792:	8d 83 34 0b ff ff    	lea    -0xf4cc(%ebx),%eax
f0100798:	50                   	push   %eax
f0100799:	8d 83 a4 0a ff ff    	lea    -0xf55c(%ebx),%eax
f010079f:	50                   	push   %eax
f01007a0:	56                   	push   %esi
f01007a1:	e8 41 03 00 00       	call   f0100ae7 <cprintf>
	return 0;
}
f01007a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007ae:	5b                   	pop    %ebx
f01007af:	5e                   	pop    %esi
f01007b0:	5d                   	pop    %ebp
f01007b1:	c3                   	ret    

f01007b2 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b2:	55                   	push   %ebp
f01007b3:	89 e5                	mov    %esp,%ebp
f01007b5:	57                   	push   %edi
f01007b6:	56                   	push   %esi
f01007b7:	53                   	push   %ebx
f01007b8:	83 ec 18             	sub    $0x18,%esp
f01007bb:	e8 fc f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007c0:	81 c3 48 0b 01 00    	add    $0x10b48,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c6:	8d 83 ad 0a ff ff    	lea    -0xf553(%ebx),%eax
f01007cc:	50                   	push   %eax
f01007cd:	e8 15 03 00 00       	call   f0100ae7 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d2:	83 c4 08             	add    $0x8,%esp
f01007d5:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007db:	8d 83 5c 0b ff ff    	lea    -0xf4a4(%ebx),%eax
f01007e1:	50                   	push   %eax
f01007e2:	e8 00 03 00 00       	call   f0100ae7 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e7:	83 c4 0c             	add    $0xc,%esp
f01007ea:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007f0:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007f6:	50                   	push   %eax
f01007f7:	57                   	push   %edi
f01007f8:	8d 83 84 0b ff ff    	lea    -0xf47c(%ebx),%eax
f01007fe:	50                   	push   %eax
f01007ff:	e8 e3 02 00 00       	call   f0100ae7 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100804:	83 c4 0c             	add    $0xc,%esp
f0100807:	c7 c0 b9 1a 10 f0    	mov    $0xf0101ab9,%eax
f010080d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100813:	52                   	push   %edx
f0100814:	50                   	push   %eax
f0100815:	8d 83 a8 0b ff ff    	lea    -0xf458(%ebx),%eax
f010081b:	50                   	push   %eax
f010081c:	e8 c6 02 00 00       	call   f0100ae7 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100821:	83 c4 0c             	add    $0xc,%esp
f0100824:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f010082a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100830:	52                   	push   %edx
f0100831:	50                   	push   %eax
f0100832:	8d 83 cc 0b ff ff    	lea    -0xf434(%ebx),%eax
f0100838:	50                   	push   %eax
f0100839:	e8 a9 02 00 00       	call   f0100ae7 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010083e:	83 c4 0c             	add    $0xc,%esp
f0100841:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f0100847:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010084d:	50                   	push   %eax
f010084e:	56                   	push   %esi
f010084f:	8d 83 f0 0b ff ff    	lea    -0xf410(%ebx),%eax
f0100855:	50                   	push   %eax
f0100856:	e8 8c 02 00 00       	call   f0100ae7 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085b:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010085e:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f0100864:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	c1 fe 0a             	sar    $0xa,%esi
f0100869:	56                   	push   %esi
f010086a:	8d 83 14 0c ff ff    	lea    -0xf3ec(%ebx),%eax
f0100870:	50                   	push   %eax
f0100871:	e8 71 02 00 00       	call   f0100ae7 <cprintf>
	return 0;
}
f0100876:	b8 00 00 00 00       	mov    $0x0,%eax
f010087b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010087e:	5b                   	pop    %ebx
f010087f:	5e                   	pop    %esi
f0100880:	5f                   	pop    %edi
f0100881:	5d                   	pop    %ebp
f0100882:	c3                   	ret    

f0100883 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100883:	55                   	push   %ebp
f0100884:	89 e5                	mov    %esp,%ebp
f0100886:	57                   	push   %edi
f0100887:	56                   	push   %esi
f0100888:	53                   	push   %ebx
f0100889:	83 ec 48             	sub    $0x48,%esp
f010088c:	e8 2b f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100891:	81 c3 77 0a 01 00    	add    $0x10a77,%ebx
	// Your code here.
	cprintf("Stack backtrace:\n");
f0100897:	8d 83 c6 0a ff ff    	lea    -0xf53a(%ebx),%eax
f010089d:	50                   	push   %eax
f010089e:	e8 44 02 00 00       	call   f0100ae7 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008a3:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp=(uint32_t *)read_ebp();
f01008a5:	89 c7                	mov    %eax,%edi
	struct Eipdebuginfo info;
	while(ebp)
f01008a7:	83 c4 10             	add    $0x10,%esp
	{
		int flag=debuginfo_eip((uintptr_t)ebp,&info);
f01008aa:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008ad:	89 45 bc             	mov    %eax,-0x44(%ebp)
		uint32_t *eip=ebp+1;
		cprintf("%s ebp %08x eip %08x args",info.eip_fn_name,ebp,*eip);
f01008b0:	8d 83 d8 0a ff ff    	lea    -0xf528(%ebx),%eax
f01008b6:	89 45 b8             	mov    %eax,-0x48(%ebp)
	while(ebp)
f01008b9:	eb 5f                	jmp    f010091a <mon_backtrace+0x97>
		int flag=debuginfo_eip((uintptr_t)ebp,&info);
f01008bb:	83 ec 08             	sub    $0x8,%esp
f01008be:	ff 75 bc             	pushl  -0x44(%ebp)
f01008c1:	57                   	push   %edi
f01008c2:	e8 24 03 00 00       	call   f0100beb <debuginfo_eip>
		cprintf("%s ebp %08x eip %08x args",info.eip_fn_name,ebp,*eip);
f01008c7:	ff 77 04             	pushl  0x4(%edi)
f01008ca:	57                   	push   %edi
f01008cb:	ff 75 d8             	pushl  -0x28(%ebp)
f01008ce:	ff 75 b8             	pushl  -0x48(%ebp)
f01008d1:	e8 11 02 00 00       	call   f0100ae7 <cprintf>
f01008d6:	8d 77 08             	lea    0x8(%edi),%esi
f01008d9:	8d 47 1c             	lea    0x1c(%edi),%eax
f01008dc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01008df:	83 c4 20             	add    $0x20,%esp
		for(int i=1;i<=5;++i)
		{
			cprintf(" %08x",*(ebp+i+1));
f01008e2:	8d 83 f2 0a ff ff    	lea    -0xf50e(%ebx),%eax
f01008e8:	89 7d c0             	mov    %edi,-0x40(%ebp)
f01008eb:	89 c7                	mov    %eax,%edi
f01008ed:	83 ec 08             	sub    $0x8,%esp
f01008f0:	ff 36                	pushl  (%esi)
f01008f2:	57                   	push   %edi
f01008f3:	e8 ef 01 00 00       	call   f0100ae7 <cprintf>
f01008f8:	83 c6 04             	add    $0x4,%esi
		for(int i=1;i<=5;++i)
f01008fb:	83 c4 10             	add    $0x10,%esp
f01008fe:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f0100901:	75 ea                	jne    f01008ed <mon_backtrace+0x6a>
f0100903:	8b 7d c0             	mov    -0x40(%ebp),%edi
		}
		cprintf("\n");
f0100906:	83 ec 0c             	sub    $0xc,%esp
f0100909:	8d 83 46 08 ff ff    	lea    -0xf7ba(%ebx),%eax
f010090f:	50                   	push   %eax
f0100910:	e8 d2 01 00 00       	call   f0100ae7 <cprintf>
		ebp=(uint32_t *)(*ebp);
f0100915:	8b 3f                	mov    (%edi),%edi
f0100917:	83 c4 10             	add    $0x10,%esp
	while(ebp)
f010091a:	85 ff                	test   %edi,%edi
f010091c:	75 9d                	jne    f01008bb <mon_backtrace+0x38>
	}
	return 0;
}
f010091e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100923:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100926:	5b                   	pop    %ebx
f0100927:	5e                   	pop    %esi
f0100928:	5f                   	pop    %edi
f0100929:	5d                   	pop    %ebp
f010092a:	c3                   	ret    

f010092b <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010092b:	55                   	push   %ebp
f010092c:	89 e5                	mov    %esp,%ebp
f010092e:	57                   	push   %edi
f010092f:	56                   	push   %esi
f0100930:	53                   	push   %ebx
f0100931:	83 ec 68             	sub    $0x68,%esp
f0100934:	e8 83 f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100939:	81 c3 cf 09 01 00    	add    $0x109cf,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010093f:	8d 83 40 0c ff ff    	lea    -0xf3c0(%ebx),%eax
f0100945:	50                   	push   %eax
f0100946:	e8 9c 01 00 00       	call   f0100ae7 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010094b:	8d 83 64 0c ff ff    	lea    -0xf39c(%ebx),%eax
f0100951:	89 04 24             	mov    %eax,(%esp)
f0100954:	e8 8e 01 00 00       	call   f0100ae7 <cprintf>
f0100959:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010095c:	8d bb fc 0a ff ff    	lea    -0xf504(%ebx),%edi
f0100962:	eb 4a                	jmp    f01009ae <monitor+0x83>
f0100964:	83 ec 08             	sub    $0x8,%esp
f0100967:	0f be c0             	movsbl %al,%eax
f010096a:	50                   	push   %eax
f010096b:	57                   	push   %edi
f010096c:	e8 ce 0c 00 00       	call   f010163f <strchr>
f0100971:	83 c4 10             	add    $0x10,%esp
f0100974:	85 c0                	test   %eax,%eax
f0100976:	74 08                	je     f0100980 <monitor+0x55>
			*buf++ = 0;
f0100978:	c6 06 00             	movb   $0x0,(%esi)
f010097b:	8d 76 01             	lea    0x1(%esi),%esi
f010097e:	eb 79                	jmp    f01009f9 <monitor+0xce>
		if (*buf == 0)
f0100980:	80 3e 00             	cmpb   $0x0,(%esi)
f0100983:	74 7f                	je     f0100a04 <monitor+0xd9>
		if (argc == MAXARGS-1) {
f0100985:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100989:	74 0f                	je     f010099a <monitor+0x6f>
		argv[argc++] = buf;
f010098b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010098e:	8d 48 01             	lea    0x1(%eax),%ecx
f0100991:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100994:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f0100998:	eb 44                	jmp    f01009de <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010099a:	83 ec 08             	sub    $0x8,%esp
f010099d:	6a 10                	push   $0x10
f010099f:	8d 83 01 0b ff ff    	lea    -0xf4ff(%ebx),%eax
f01009a5:	50                   	push   %eax
f01009a6:	e8 3c 01 00 00       	call   f0100ae7 <cprintf>
f01009ab:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009ae:	8d 83 f8 0a ff ff    	lea    -0xf508(%ebx),%eax
f01009b4:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01009b7:	83 ec 0c             	sub    $0xc,%esp
f01009ba:	ff 75 a4             	pushl  -0x5c(%ebp)
f01009bd:	e8 45 0a 00 00       	call   f0101407 <readline>
f01009c2:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009c4:	83 c4 10             	add    $0x10,%esp
f01009c7:	85 c0                	test   %eax,%eax
f01009c9:	74 ec                	je     f01009b7 <monitor+0x8c>
	argv[argc] = 0;
f01009cb:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009d2:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009d9:	eb 1e                	jmp    f01009f9 <monitor+0xce>
			buf++;
f01009db:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009de:	0f b6 06             	movzbl (%esi),%eax
f01009e1:	84 c0                	test   %al,%al
f01009e3:	74 14                	je     f01009f9 <monitor+0xce>
f01009e5:	83 ec 08             	sub    $0x8,%esp
f01009e8:	0f be c0             	movsbl %al,%eax
f01009eb:	50                   	push   %eax
f01009ec:	57                   	push   %edi
f01009ed:	e8 4d 0c 00 00       	call   f010163f <strchr>
f01009f2:	83 c4 10             	add    $0x10,%esp
f01009f5:	85 c0                	test   %eax,%eax
f01009f7:	74 e2                	je     f01009db <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f01009f9:	0f b6 06             	movzbl (%esi),%eax
f01009fc:	84 c0                	test   %al,%al
f01009fe:	0f 85 60 ff ff ff    	jne    f0100964 <monitor+0x39>
	argv[argc] = 0;
f0100a04:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a07:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a0e:	00 
	if (argc == 0)
f0100a0f:	85 c0                	test   %eax,%eax
f0100a11:	74 9b                	je     f01009ae <monitor+0x83>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a13:	83 ec 08             	sub    $0x8,%esp
f0100a16:	8d 83 96 0a ff ff    	lea    -0xf56a(%ebx),%eax
f0100a1c:	50                   	push   %eax
f0100a1d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a20:	e8 bc 0b 00 00       	call   f01015e1 <strcmp>
f0100a25:	83 c4 10             	add    $0x10,%esp
f0100a28:	85 c0                	test   %eax,%eax
f0100a2a:	74 38                	je     f0100a64 <monitor+0x139>
f0100a2c:	83 ec 08             	sub    $0x8,%esp
f0100a2f:	8d 83 a4 0a ff ff    	lea    -0xf55c(%ebx),%eax
f0100a35:	50                   	push   %eax
f0100a36:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a39:	e8 a3 0b 00 00       	call   f01015e1 <strcmp>
f0100a3e:	83 c4 10             	add    $0x10,%esp
f0100a41:	85 c0                	test   %eax,%eax
f0100a43:	74 1a                	je     f0100a5f <monitor+0x134>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a45:	83 ec 08             	sub    $0x8,%esp
f0100a48:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a4b:	8d 83 1e 0b ff ff    	lea    -0xf4e2(%ebx),%eax
f0100a51:	50                   	push   %eax
f0100a52:	e8 90 00 00 00       	call   f0100ae7 <cprintf>
f0100a57:	83 c4 10             	add    $0x10,%esp
f0100a5a:	e9 4f ff ff ff       	jmp    f01009ae <monitor+0x83>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a5f:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a64:	83 ec 04             	sub    $0x4,%esp
f0100a67:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a6a:	ff 75 08             	pushl  0x8(%ebp)
f0100a6d:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a70:	52                   	push   %edx
f0100a71:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a74:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a7b:	83 c4 10             	add    $0x10,%esp
f0100a7e:	85 c0                	test   %eax,%eax
f0100a80:	0f 89 28 ff ff ff    	jns    f01009ae <monitor+0x83>
				break;
	}
}
f0100a86:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a89:	5b                   	pop    %ebx
f0100a8a:	5e                   	pop    %esi
f0100a8b:	5f                   	pop    %edi
f0100a8c:	5d                   	pop    %ebp
f0100a8d:	c3                   	ret    

f0100a8e <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a8e:	55                   	push   %ebp
f0100a8f:	89 e5                	mov    %esp,%ebp
f0100a91:	53                   	push   %ebx
f0100a92:	83 ec 10             	sub    $0x10,%esp
f0100a95:	e8 22 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100a9a:	81 c3 6e 08 01 00    	add    $0x1086e,%ebx
	cputchar(ch);
f0100aa0:	ff 75 08             	pushl  0x8(%ebp)
f0100aa3:	e8 8b fc ff ff       	call   f0100733 <cputchar>
	*cnt++;
}
f0100aa8:	83 c4 10             	add    $0x10,%esp
f0100aab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100aae:	c9                   	leave  
f0100aaf:	c3                   	ret    

f0100ab0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100ab0:	55                   	push   %ebp
f0100ab1:	89 e5                	mov    %esp,%ebp
f0100ab3:	53                   	push   %ebx
f0100ab4:	83 ec 14             	sub    $0x14,%esp
f0100ab7:	e8 00 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100abc:	81 c3 4c 08 01 00    	add    $0x1084c,%ebx
	int cnt = 0;
f0100ac2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100ac9:	ff 75 0c             	pushl  0xc(%ebp)
f0100acc:	ff 75 08             	pushl  0x8(%ebp)
f0100acf:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100ad2:	50                   	push   %eax
f0100ad3:	8d 83 86 f7 fe ff    	lea    -0x1087a(%ebx),%eax
f0100ad9:	50                   	push   %eax
f0100ada:	e8 1c 04 00 00       	call   f0100efb <vprintfmt>
	return cnt;
}
f0100adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100ae2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ae5:	c9                   	leave  
f0100ae6:	c3                   	ret    

f0100ae7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100ae7:	55                   	push   %ebp
f0100ae8:	89 e5                	mov    %esp,%ebp
f0100aea:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100aed:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100af0:	50                   	push   %eax
f0100af1:	ff 75 08             	pushl  0x8(%ebp)
f0100af4:	e8 b7 ff ff ff       	call   f0100ab0 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100af9:	c9                   	leave  
f0100afa:	c3                   	ret    

f0100afb <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100afb:	55                   	push   %ebp
f0100afc:	89 e5                	mov    %esp,%ebp
f0100afe:	57                   	push   %edi
f0100aff:	56                   	push   %esi
f0100b00:	53                   	push   %ebx
f0100b01:	83 ec 14             	sub    $0x14,%esp
f0100b04:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b07:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b0a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b0d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b10:	8b 32                	mov    (%edx),%esi
f0100b12:	8b 01                	mov    (%ecx),%eax
f0100b14:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b17:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b1e:	eb 2f                	jmp    f0100b4f <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b20:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b23:	39 c6                	cmp    %eax,%esi
f0100b25:	7f 49                	jg     f0100b70 <stab_binsearch+0x75>
f0100b27:	0f b6 0a             	movzbl (%edx),%ecx
f0100b2a:	83 ea 0c             	sub    $0xc,%edx
f0100b2d:	39 f9                	cmp    %edi,%ecx
f0100b2f:	75 ef                	jne    f0100b20 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b31:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b34:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b37:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b3b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b3e:	73 35                	jae    f0100b75 <stab_binsearch+0x7a>
			*region_left = m;
f0100b40:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b43:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100b45:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100b48:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b4f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100b52:	7f 4e                	jg     f0100ba2 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100b54:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b57:	01 f0                	add    %esi,%eax
f0100b59:	89 c3                	mov    %eax,%ebx
f0100b5b:	c1 eb 1f             	shr    $0x1f,%ebx
f0100b5e:	01 c3                	add    %eax,%ebx
f0100b60:	d1 fb                	sar    %ebx
f0100b62:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b65:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b68:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100b6c:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b6e:	eb b3                	jmp    f0100b23 <stab_binsearch+0x28>
			l = true_m + 1;
f0100b70:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100b73:	eb da                	jmp    f0100b4f <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100b75:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b78:	76 14                	jbe    f0100b8e <stab_binsearch+0x93>
			*region_right = m - 1;
f0100b7a:	83 e8 01             	sub    $0x1,%eax
f0100b7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b80:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100b83:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100b85:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b8c:	eb c1                	jmp    f0100b4f <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b8e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b91:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100b93:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100b97:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100b99:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100ba0:	eb ad                	jmp    f0100b4f <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100ba2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100ba6:	74 16                	je     f0100bbe <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ba8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bab:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100bad:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bb0:	8b 0e                	mov    (%esi),%ecx
f0100bb2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bb5:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100bb8:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100bbc:	eb 12                	jmp    f0100bd0 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100bbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bc1:	8b 00                	mov    (%eax),%eax
f0100bc3:	83 e8 01             	sub    $0x1,%eax
f0100bc6:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bc9:	89 07                	mov    %eax,(%edi)
f0100bcb:	eb 16                	jmp    f0100be3 <stab_binsearch+0xe8>
		     l--)
f0100bcd:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100bd0:	39 c1                	cmp    %eax,%ecx
f0100bd2:	7d 0a                	jge    f0100bde <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100bd4:	0f b6 1a             	movzbl (%edx),%ebx
f0100bd7:	83 ea 0c             	sub    $0xc,%edx
f0100bda:	39 fb                	cmp    %edi,%ebx
f0100bdc:	75 ef                	jne    f0100bcd <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100bde:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100be1:	89 07                	mov    %eax,(%edi)
	}
}
f0100be3:	83 c4 14             	add    $0x14,%esp
f0100be6:	5b                   	pop    %ebx
f0100be7:	5e                   	pop    %esi
f0100be8:	5f                   	pop    %edi
f0100be9:	5d                   	pop    %ebp
f0100bea:	c3                   	ret    

f0100beb <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100beb:	55                   	push   %ebp
f0100bec:	89 e5                	mov    %esp,%ebp
f0100bee:	57                   	push   %edi
f0100bef:	56                   	push   %esi
f0100bf0:	53                   	push   %ebx
f0100bf1:	83 ec 2c             	sub    $0x2c,%esp
f0100bf4:	e8 fa 01 00 00       	call   f0100df3 <__x86.get_pc_thunk.cx>
f0100bf9:	81 c1 0f 07 01 00    	add    $0x1070f,%ecx
f0100bff:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100c02:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100c05:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c08:	8d 81 8c 0c ff ff    	lea    -0xf374(%ecx),%eax
f0100c0e:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0100c10:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0100c17:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0100c1a:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0100c21:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f0100c24:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c2b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0100c31:	0f 86 f4 00 00 00    	jbe    f0100d2b <debuginfo_eip+0x140>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c37:	c7 c0 71 5e 10 f0    	mov    $0xf0105e71,%eax
f0100c3d:	39 81 fc ff ff ff    	cmp    %eax,-0x4(%ecx)
f0100c43:	0f 86 88 01 00 00    	jbe    f0100dd1 <debuginfo_eip+0x1e6>
f0100c49:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100c4c:	c7 c0 d6 77 10 f0    	mov    $0xf01077d6,%eax
f0100c52:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c56:	0f 85 7c 01 00 00    	jne    f0100dd8 <debuginfo_eip+0x1ed>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c5c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c63:	c7 c0 b0 21 10 f0    	mov    $0xf01021b0,%eax
f0100c69:	c7 c2 70 5e 10 f0    	mov    $0xf0105e70,%edx
f0100c6f:	29 c2                	sub    %eax,%edx
f0100c71:	c1 fa 02             	sar    $0x2,%edx
f0100c74:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100c7a:	83 ea 01             	sub    $0x1,%edx
f0100c7d:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c80:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c83:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c86:	83 ec 08             	sub    $0x8,%esp
f0100c89:	53                   	push   %ebx
f0100c8a:	6a 64                	push   $0x64
f0100c8c:	e8 6a fe ff ff       	call   f0100afb <stab_binsearch>
	if (lfile == 0)
f0100c91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c94:	83 c4 10             	add    $0x10,%esp
f0100c97:	85 c0                	test   %eax,%eax
f0100c99:	0f 84 40 01 00 00    	je     f0100ddf <debuginfo_eip+0x1f4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c9f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100ca2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ca5:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100ca8:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100cab:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cae:	83 ec 08             	sub    $0x8,%esp
f0100cb1:	53                   	push   %ebx
f0100cb2:	6a 24                	push   $0x24
f0100cb4:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0100cb7:	c7 c0 b0 21 10 f0    	mov    $0xf01021b0,%eax
f0100cbd:	e8 39 fe ff ff       	call   f0100afb <stab_binsearch>

	if (lfun <= rfun) {
f0100cc2:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100cc5:	83 c4 10             	add    $0x10,%esp
f0100cc8:	3b 75 d8             	cmp    -0x28(%ebp),%esi
f0100ccb:	7f 79                	jg     f0100d46 <debuginfo_eip+0x15b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100ccd:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100cd0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cd3:	c7 c2 b0 21 10 f0    	mov    $0xf01021b0,%edx
f0100cd9:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0100cdc:	8b 11                	mov    (%ecx),%edx
f0100cde:	c7 c0 d6 77 10 f0    	mov    $0xf01077d6,%eax
f0100ce4:	81 e8 71 5e 10 f0    	sub    $0xf0105e71,%eax
f0100cea:	39 c2                	cmp    %eax,%edx
f0100cec:	73 09                	jae    f0100cf7 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100cee:	81 c2 71 5e 10 f0    	add    $0xf0105e71,%edx
f0100cf4:	89 57 08             	mov    %edx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100cf7:	8b 41 08             	mov    0x8(%ecx),%eax
f0100cfa:	89 47 10             	mov    %eax,0x10(%edi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100cfd:	83 ec 08             	sub    $0x8,%esp
f0100d00:	6a 3a                	push   $0x3a
f0100d02:	ff 77 08             	pushl  0x8(%edi)
f0100d05:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d08:	e8 53 09 00 00       	call   f0101660 <strfind>
f0100d0d:	2b 47 08             	sub    0x8(%edi),%eax
f0100d10:	89 47 0c             	mov    %eax,0xc(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d13:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100d16:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100d19:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100d1c:	c7 c2 b0 21 10 f0    	mov    $0xf01021b0,%edx
f0100d22:	8d 44 82 04          	lea    0x4(%edx,%eax,4),%eax
f0100d26:	83 c4 10             	add    $0x10,%esp
f0100d29:	eb 29                	jmp    f0100d54 <debuginfo_eip+0x169>
  	        panic("User address");
f0100d2b:	83 ec 04             	sub    $0x4,%esp
f0100d2e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d31:	8d 83 96 0c ff ff    	lea    -0xf36a(%ebx),%eax
f0100d37:	50                   	push   %eax
f0100d38:	6a 7f                	push   $0x7f
f0100d3a:	8d 83 a3 0c ff ff    	lea    -0xf35d(%ebx),%eax
f0100d40:	50                   	push   %eax
f0100d41:	e8 c0 f3 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100d46:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f0100d49:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100d4c:	eb af                	jmp    f0100cfd <debuginfo_eip+0x112>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100d4e:	83 ee 01             	sub    $0x1,%esi
f0100d51:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100d54:	39 f3                	cmp    %esi,%ebx
f0100d56:	7f 3a                	jg     f0100d92 <debuginfo_eip+0x1a7>
	       && stabs[lline].n_type != N_SOL
f0100d58:	0f b6 10             	movzbl (%eax),%edx
f0100d5b:	80 fa 84             	cmp    $0x84,%dl
f0100d5e:	74 0b                	je     f0100d6b <debuginfo_eip+0x180>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d60:	80 fa 64             	cmp    $0x64,%dl
f0100d63:	75 e9                	jne    f0100d4e <debuginfo_eip+0x163>
f0100d65:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100d69:	74 e3                	je     f0100d4e <debuginfo_eip+0x163>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100d6b:	8d 14 76             	lea    (%esi,%esi,2),%edx
f0100d6e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d71:	c7 c0 b0 21 10 f0    	mov    $0xf01021b0,%eax
f0100d77:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100d7a:	c7 c0 d6 77 10 f0    	mov    $0xf01077d6,%eax
f0100d80:	81 e8 71 5e 10 f0    	sub    $0xf0105e71,%eax
f0100d86:	39 c2                	cmp    %eax,%edx
f0100d88:	73 08                	jae    f0100d92 <debuginfo_eip+0x1a7>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100d8a:	81 c2 71 5e 10 f0    	add    $0xf0105e71,%edx
f0100d90:	89 17                	mov    %edx,(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d92:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100d95:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d98:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100d9d:	39 cb                	cmp    %ecx,%ebx
f0100d9f:	7d 4a                	jge    f0100deb <debuginfo_eip+0x200>
		for (lline = lfun + 1;
f0100da1:	8d 53 01             	lea    0x1(%ebx),%edx
f0100da4:	8d 1c 5b             	lea    (%ebx,%ebx,2),%ebx
f0100da7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100daa:	c7 c0 b0 21 10 f0    	mov    $0xf01021b0,%eax
f0100db0:	8d 44 98 10          	lea    0x10(%eax,%ebx,4),%eax
f0100db4:	eb 07                	jmp    f0100dbd <debuginfo_eip+0x1d2>
			info->eip_fn_narg++;
f0100db6:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0100dba:	83 c2 01             	add    $0x1,%edx
		for (lline = lfun + 1;
f0100dbd:	39 d1                	cmp    %edx,%ecx
f0100dbf:	74 25                	je     f0100de6 <debuginfo_eip+0x1fb>
f0100dc1:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100dc4:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100dc8:	74 ec                	je     f0100db6 <debuginfo_eip+0x1cb>
	return 0;
f0100dca:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dcf:	eb 1a                	jmp    f0100deb <debuginfo_eip+0x200>
		return -1;
f0100dd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100dd6:	eb 13                	jmp    f0100deb <debuginfo_eip+0x200>
f0100dd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ddd:	eb 0c                	jmp    f0100deb <debuginfo_eip+0x200>
		return -1;
f0100ddf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100de4:	eb 05                	jmp    f0100deb <debuginfo_eip+0x200>
	return 0;
f0100de6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100deb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dee:	5b                   	pop    %ebx
f0100def:	5e                   	pop    %esi
f0100df0:	5f                   	pop    %edi
f0100df1:	5d                   	pop    %ebp
f0100df2:	c3                   	ret    

f0100df3 <__x86.get_pc_thunk.cx>:
f0100df3:	8b 0c 24             	mov    (%esp),%ecx
f0100df6:	c3                   	ret    

f0100df7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100df7:	55                   	push   %ebp
f0100df8:	89 e5                	mov    %esp,%ebp
f0100dfa:	57                   	push   %edi
f0100dfb:	56                   	push   %esi
f0100dfc:	53                   	push   %ebx
f0100dfd:	83 ec 2c             	sub    $0x2c,%esp
f0100e00:	e8 ee ff ff ff       	call   f0100df3 <__x86.get_pc_thunk.cx>
f0100e05:	81 c1 03 05 01 00    	add    $0x10503,%ecx
f0100e0b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100e0e:	89 c7                	mov    %eax,%edi
f0100e10:	89 d6                	mov    %edx,%esi
f0100e12:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e15:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100e18:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e1b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100e21:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e26:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100e29:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100e2c:	39 d3                	cmp    %edx,%ebx
f0100e2e:	72 09                	jb     f0100e39 <printnum+0x42>
f0100e30:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100e33:	0f 87 83 00 00 00    	ja     f0100ebc <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100e39:	83 ec 0c             	sub    $0xc,%esp
f0100e3c:	ff 75 18             	pushl  0x18(%ebp)
f0100e3f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e42:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100e45:	53                   	push   %ebx
f0100e46:	ff 75 10             	pushl  0x10(%ebp)
f0100e49:	83 ec 08             	sub    $0x8,%esp
f0100e4c:	ff 75 dc             	pushl  -0x24(%ebp)
f0100e4f:	ff 75 d8             	pushl  -0x28(%ebp)
f0100e52:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100e55:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e58:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100e5b:	e8 20 0a 00 00       	call   f0101880 <__udivdi3>
f0100e60:	83 c4 18             	add    $0x18,%esp
f0100e63:	52                   	push   %edx
f0100e64:	50                   	push   %eax
f0100e65:	89 f2                	mov    %esi,%edx
f0100e67:	89 f8                	mov    %edi,%eax
f0100e69:	e8 89 ff ff ff       	call   f0100df7 <printnum>
f0100e6e:	83 c4 20             	add    $0x20,%esp
f0100e71:	eb 13                	jmp    f0100e86 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100e73:	83 ec 08             	sub    $0x8,%esp
f0100e76:	56                   	push   %esi
f0100e77:	ff 75 18             	pushl  0x18(%ebp)
f0100e7a:	ff d7                	call   *%edi
f0100e7c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100e7f:	83 eb 01             	sub    $0x1,%ebx
f0100e82:	85 db                	test   %ebx,%ebx
f0100e84:	7f ed                	jg     f0100e73 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100e86:	83 ec 08             	sub    $0x8,%esp
f0100e89:	56                   	push   %esi
f0100e8a:	83 ec 04             	sub    $0x4,%esp
f0100e8d:	ff 75 dc             	pushl  -0x24(%ebp)
f0100e90:	ff 75 d8             	pushl  -0x28(%ebp)
f0100e93:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100e96:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e99:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100e9c:	89 f3                	mov    %esi,%ebx
f0100e9e:	e8 fd 0a 00 00       	call   f01019a0 <__umoddi3>
f0100ea3:	83 c4 14             	add    $0x14,%esp
f0100ea6:	0f be 84 06 b1 0c ff 	movsbl -0xf34f(%esi,%eax,1),%eax
f0100ead:	ff 
f0100eae:	50                   	push   %eax
f0100eaf:	ff d7                	call   *%edi
}
f0100eb1:	83 c4 10             	add    $0x10,%esp
f0100eb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100eb7:	5b                   	pop    %ebx
f0100eb8:	5e                   	pop    %esi
f0100eb9:	5f                   	pop    %edi
f0100eba:	5d                   	pop    %ebp
f0100ebb:	c3                   	ret    
f0100ebc:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100ebf:	eb be                	jmp    f0100e7f <printnum+0x88>

f0100ec1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100ec1:	55                   	push   %ebp
f0100ec2:	89 e5                	mov    %esp,%ebp
f0100ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100ec7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100ecb:	8b 10                	mov    (%eax),%edx
f0100ecd:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ed0:	73 0a                	jae    f0100edc <sprintputch+0x1b>
		*b->buf++ = ch;
f0100ed2:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100ed5:	89 08                	mov    %ecx,(%eax)
f0100ed7:	8b 45 08             	mov    0x8(%ebp),%eax
f0100eda:	88 02                	mov    %al,(%edx)
}
f0100edc:	5d                   	pop    %ebp
f0100edd:	c3                   	ret    

f0100ede <printfmt>:
{
f0100ede:	55                   	push   %ebp
f0100edf:	89 e5                	mov    %esp,%ebp
f0100ee1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100ee4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100ee7:	50                   	push   %eax
f0100ee8:	ff 75 10             	pushl  0x10(%ebp)
f0100eeb:	ff 75 0c             	pushl  0xc(%ebp)
f0100eee:	ff 75 08             	pushl  0x8(%ebp)
f0100ef1:	e8 05 00 00 00       	call   f0100efb <vprintfmt>
}
f0100ef6:	83 c4 10             	add    $0x10,%esp
f0100ef9:	c9                   	leave  
f0100efa:	c3                   	ret    

f0100efb <vprintfmt>:
{
f0100efb:	55                   	push   %ebp
f0100efc:	89 e5                	mov    %esp,%ebp
f0100efe:	57                   	push   %edi
f0100eff:	56                   	push   %esi
f0100f00:	53                   	push   %ebx
f0100f01:	83 ec 2c             	sub    $0x2c,%esp
f0100f04:	e8 b3 f2 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100f09:	81 c3 ff 03 01 00    	add    $0x103ff,%ebx
f0100f0f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100f12:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100f15:	e9 c3 03 00 00       	jmp    f01012dd <.L35+0x48>
		padc = ' ';
f0100f1a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100f1e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100f25:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0100f2c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100f33:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f38:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f3b:	8d 47 01             	lea    0x1(%edi),%eax
f0100f3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f41:	0f b6 17             	movzbl (%edi),%edx
f0100f44:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100f47:	3c 55                	cmp    $0x55,%al
f0100f49:	0f 87 16 04 00 00    	ja     f0101365 <.L22>
f0100f4f:	0f b6 c0             	movzbl %al,%eax
f0100f52:	89 d9                	mov    %ebx,%ecx
f0100f54:	03 8c 83 40 0d ff ff 	add    -0xf2c0(%ebx,%eax,4),%ecx
f0100f5b:	ff e1                	jmp    *%ecx

f0100f5d <.L69>:
f0100f5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100f60:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100f64:	eb d5                	jmp    f0100f3b <vprintfmt+0x40>

f0100f66 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0100f66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0100f69:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100f6d:	eb cc                	jmp    f0100f3b <vprintfmt+0x40>

f0100f6f <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0100f6f:	0f b6 d2             	movzbl %dl,%edx
f0100f72:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0100f75:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0100f7a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100f7d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100f81:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100f84:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100f87:	83 f9 09             	cmp    $0x9,%ecx
f0100f8a:	77 55                	ja     f0100fe1 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0100f8c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0100f8f:	eb e9                	jmp    f0100f7a <.L29+0xb>

f0100f91 <.L26>:
			precision = va_arg(ap, int);
f0100f91:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f94:	8b 00                	mov    (%eax),%eax
f0100f96:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100f99:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f9c:	8d 40 04             	lea    0x4(%eax),%eax
f0100f9f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100fa2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0100fa5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100fa9:	79 90                	jns    f0100f3b <vprintfmt+0x40>
				width = precision, precision = -1;
f0100fab:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100fae:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100fb1:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0100fb8:	eb 81                	jmp    f0100f3b <vprintfmt+0x40>

f0100fba <.L27>:
f0100fba:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fbd:	85 c0                	test   %eax,%eax
f0100fbf:	ba 00 00 00 00       	mov    $0x0,%edx
f0100fc4:	0f 49 d0             	cmovns %eax,%edx
f0100fc7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100fca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100fcd:	e9 69 ff ff ff       	jmp    f0100f3b <vprintfmt+0x40>

f0100fd2 <.L23>:
f0100fd2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0100fd5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100fdc:	e9 5a ff ff ff       	jmp    f0100f3b <vprintfmt+0x40>
f0100fe1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100fe4:	eb bf                	jmp    f0100fa5 <.L26+0x14>

f0100fe6 <.L33>:
			lflag++;
f0100fe6:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100fea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0100fed:	e9 49 ff ff ff       	jmp    f0100f3b <vprintfmt+0x40>

f0100ff2 <.L30>:
			putch(va_arg(ap, int), putdat);
f0100ff2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff5:	8d 78 04             	lea    0x4(%eax),%edi
f0100ff8:	83 ec 08             	sub    $0x8,%esp
f0100ffb:	56                   	push   %esi
f0100ffc:	ff 30                	pushl  (%eax)
f0100ffe:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101001:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101004:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0101007:	e9 ce 02 00 00       	jmp    f01012da <.L35+0x45>

f010100c <.L32>:
			err = va_arg(ap, int);
f010100c:	8b 45 14             	mov    0x14(%ebp),%eax
f010100f:	8d 78 04             	lea    0x4(%eax),%edi
f0101012:	8b 00                	mov    (%eax),%eax
f0101014:	99                   	cltd   
f0101015:	31 d0                	xor    %edx,%eax
f0101017:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101019:	83 f8 06             	cmp    $0x6,%eax
f010101c:	7f 27                	jg     f0101045 <.L32+0x39>
f010101e:	8b 94 83 20 1d 00 00 	mov    0x1d20(%ebx,%eax,4),%edx
f0101025:	85 d2                	test   %edx,%edx
f0101027:	74 1c                	je     f0101045 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f0101029:	52                   	push   %edx
f010102a:	8d 83 d2 0c ff ff    	lea    -0xf32e(%ebx),%eax
f0101030:	50                   	push   %eax
f0101031:	56                   	push   %esi
f0101032:	ff 75 08             	pushl  0x8(%ebp)
f0101035:	e8 a4 fe ff ff       	call   f0100ede <printfmt>
f010103a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010103d:	89 7d 14             	mov    %edi,0x14(%ebp)
f0101040:	e9 95 02 00 00       	jmp    f01012da <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f0101045:	50                   	push   %eax
f0101046:	8d 83 c9 0c ff ff    	lea    -0xf337(%ebx),%eax
f010104c:	50                   	push   %eax
f010104d:	56                   	push   %esi
f010104e:	ff 75 08             	pushl  0x8(%ebp)
f0101051:	e8 88 fe ff ff       	call   f0100ede <printfmt>
f0101056:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101059:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010105c:	e9 79 02 00 00       	jmp    f01012da <.L35+0x45>

f0101061 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0101061:	8b 45 14             	mov    0x14(%ebp),%eax
f0101064:	83 c0 04             	add    $0x4,%eax
f0101067:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010106a:	8b 45 14             	mov    0x14(%ebp),%eax
f010106d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010106f:	85 ff                	test   %edi,%edi
f0101071:	8d 83 c2 0c ff ff    	lea    -0xf33e(%ebx),%eax
f0101077:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010107a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010107e:	0f 8e b5 00 00 00    	jle    f0101139 <.L36+0xd8>
f0101084:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101088:	75 08                	jne    f0101092 <.L36+0x31>
f010108a:	89 75 0c             	mov    %esi,0xc(%ebp)
f010108d:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101090:	eb 6d                	jmp    f01010ff <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101092:	83 ec 08             	sub    $0x8,%esp
f0101095:	ff 75 cc             	pushl  -0x34(%ebp)
f0101098:	57                   	push   %edi
f0101099:	e8 7e 04 00 00       	call   f010151c <strnlen>
f010109e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01010a1:	29 c2                	sub    %eax,%edx
f01010a3:	89 55 c8             	mov    %edx,-0x38(%ebp)
f01010a6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01010a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01010ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01010b3:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f01010b5:	eb 10                	jmp    f01010c7 <.L36+0x66>
					putch(padc, putdat);
f01010b7:	83 ec 08             	sub    $0x8,%esp
f01010ba:	56                   	push   %esi
f01010bb:	ff 75 e0             	pushl  -0x20(%ebp)
f01010be:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01010c1:	83 ef 01             	sub    $0x1,%edi
f01010c4:	83 c4 10             	add    $0x10,%esp
f01010c7:	85 ff                	test   %edi,%edi
f01010c9:	7f ec                	jg     f01010b7 <.L36+0x56>
f01010cb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01010ce:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01010d1:	85 d2                	test   %edx,%edx
f01010d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01010d8:	0f 49 c2             	cmovns %edx,%eax
f01010db:	29 c2                	sub    %eax,%edx
f01010dd:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01010e0:	89 75 0c             	mov    %esi,0xc(%ebp)
f01010e3:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01010e6:	eb 17                	jmp    f01010ff <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f01010e8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01010ec:	75 30                	jne    f010111e <.L36+0xbd>
					putch(ch, putdat);
f01010ee:	83 ec 08             	sub    $0x8,%esp
f01010f1:	ff 75 0c             	pushl  0xc(%ebp)
f01010f4:	50                   	push   %eax
f01010f5:	ff 55 08             	call   *0x8(%ebp)
f01010f8:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01010fb:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01010ff:	83 c7 01             	add    $0x1,%edi
f0101102:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0101106:	0f be c2             	movsbl %dl,%eax
f0101109:	85 c0                	test   %eax,%eax
f010110b:	74 52                	je     f010115f <.L36+0xfe>
f010110d:	85 f6                	test   %esi,%esi
f010110f:	78 d7                	js     f01010e8 <.L36+0x87>
f0101111:	83 ee 01             	sub    $0x1,%esi
f0101114:	79 d2                	jns    f01010e8 <.L36+0x87>
f0101116:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101119:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010111c:	eb 32                	jmp    f0101150 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f010111e:	0f be d2             	movsbl %dl,%edx
f0101121:	83 ea 20             	sub    $0x20,%edx
f0101124:	83 fa 5e             	cmp    $0x5e,%edx
f0101127:	76 c5                	jbe    f01010ee <.L36+0x8d>
					putch('?', putdat);
f0101129:	83 ec 08             	sub    $0x8,%esp
f010112c:	ff 75 0c             	pushl  0xc(%ebp)
f010112f:	6a 3f                	push   $0x3f
f0101131:	ff 55 08             	call   *0x8(%ebp)
f0101134:	83 c4 10             	add    $0x10,%esp
f0101137:	eb c2                	jmp    f01010fb <.L36+0x9a>
f0101139:	89 75 0c             	mov    %esi,0xc(%ebp)
f010113c:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010113f:	eb be                	jmp    f01010ff <.L36+0x9e>
				putch(' ', putdat);
f0101141:	83 ec 08             	sub    $0x8,%esp
f0101144:	56                   	push   %esi
f0101145:	6a 20                	push   $0x20
f0101147:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f010114a:	83 ef 01             	sub    $0x1,%edi
f010114d:	83 c4 10             	add    $0x10,%esp
f0101150:	85 ff                	test   %edi,%edi
f0101152:	7f ed                	jg     f0101141 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f0101154:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101157:	89 45 14             	mov    %eax,0x14(%ebp)
f010115a:	e9 7b 01 00 00       	jmp    f01012da <.L35+0x45>
f010115f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101162:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101165:	eb e9                	jmp    f0101150 <.L36+0xef>

f0101167 <.L31>:
f0101167:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010116a:	83 f9 01             	cmp    $0x1,%ecx
f010116d:	7e 40                	jle    f01011af <.L31+0x48>
		return va_arg(*ap, long long);
f010116f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101172:	8b 50 04             	mov    0x4(%eax),%edx
f0101175:	8b 00                	mov    (%eax),%eax
f0101177:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010117a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010117d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101180:	8d 40 08             	lea    0x8(%eax),%eax
f0101183:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101186:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010118a:	79 55                	jns    f01011e1 <.L31+0x7a>
				putch('-', putdat);
f010118c:	83 ec 08             	sub    $0x8,%esp
f010118f:	56                   	push   %esi
f0101190:	6a 2d                	push   $0x2d
f0101192:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101195:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101198:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010119b:	f7 da                	neg    %edx
f010119d:	83 d1 00             	adc    $0x0,%ecx
f01011a0:	f7 d9                	neg    %ecx
f01011a2:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01011a5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01011aa:	e9 10 01 00 00       	jmp    f01012bf <.L35+0x2a>
	else if (lflag)
f01011af:	85 c9                	test   %ecx,%ecx
f01011b1:	75 17                	jne    f01011ca <.L31+0x63>
		return va_arg(*ap, int);
f01011b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01011b6:	8b 00                	mov    (%eax),%eax
f01011b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011bb:	99                   	cltd   
f01011bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01011bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01011c2:	8d 40 04             	lea    0x4(%eax),%eax
f01011c5:	89 45 14             	mov    %eax,0x14(%ebp)
f01011c8:	eb bc                	jmp    f0101186 <.L31+0x1f>
		return va_arg(*ap, long);
f01011ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01011cd:	8b 00                	mov    (%eax),%eax
f01011cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011d2:	99                   	cltd   
f01011d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01011d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01011d9:	8d 40 04             	lea    0x4(%eax),%eax
f01011dc:	89 45 14             	mov    %eax,0x14(%ebp)
f01011df:	eb a5                	jmp    f0101186 <.L31+0x1f>
			num = getint(&ap, lflag);
f01011e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01011e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01011e7:	b8 0a 00 00 00       	mov    $0xa,%eax
f01011ec:	e9 ce 00 00 00       	jmp    f01012bf <.L35+0x2a>

f01011f1 <.L37>:
f01011f1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01011f4:	83 f9 01             	cmp    $0x1,%ecx
f01011f7:	7e 18                	jle    f0101211 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f01011f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01011fc:	8b 10                	mov    (%eax),%edx
f01011fe:	8b 48 04             	mov    0x4(%eax),%ecx
f0101201:	8d 40 08             	lea    0x8(%eax),%eax
f0101204:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101207:	b8 0a 00 00 00       	mov    $0xa,%eax
f010120c:	e9 ae 00 00 00       	jmp    f01012bf <.L35+0x2a>
	else if (lflag)
f0101211:	85 c9                	test   %ecx,%ecx
f0101213:	75 1a                	jne    f010122f <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f0101215:	8b 45 14             	mov    0x14(%ebp),%eax
f0101218:	8b 10                	mov    (%eax),%edx
f010121a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010121f:	8d 40 04             	lea    0x4(%eax),%eax
f0101222:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101225:	b8 0a 00 00 00       	mov    $0xa,%eax
f010122a:	e9 90 00 00 00       	jmp    f01012bf <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f010122f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101232:	8b 10                	mov    (%eax),%edx
f0101234:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101239:	8d 40 04             	lea    0x4(%eax),%eax
f010123c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010123f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101244:	eb 79                	jmp    f01012bf <.L35+0x2a>

f0101246 <.L34>:
f0101246:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101249:	83 f9 01             	cmp    $0x1,%ecx
f010124c:	7e 15                	jle    f0101263 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f010124e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101251:	8b 10                	mov    (%eax),%edx
f0101253:	8b 48 04             	mov    0x4(%eax),%ecx
f0101256:	8d 40 08             	lea    0x8(%eax),%eax
f0101259:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f010125c:	b8 08 00 00 00       	mov    $0x8,%eax
f0101261:	eb 5c                	jmp    f01012bf <.L35+0x2a>
	else if (lflag)
f0101263:	85 c9                	test   %ecx,%ecx
f0101265:	75 17                	jne    f010127e <.L34+0x38>
		return va_arg(*ap, unsigned int);
f0101267:	8b 45 14             	mov    0x14(%ebp),%eax
f010126a:	8b 10                	mov    (%eax),%edx
f010126c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101271:	8d 40 04             	lea    0x4(%eax),%eax
f0101274:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0101277:	b8 08 00 00 00       	mov    $0x8,%eax
f010127c:	eb 41                	jmp    f01012bf <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f010127e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101281:	8b 10                	mov    (%eax),%edx
f0101283:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101288:	8d 40 04             	lea    0x4(%eax),%eax
f010128b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f010128e:	b8 08 00 00 00       	mov    $0x8,%eax
f0101293:	eb 2a                	jmp    f01012bf <.L35+0x2a>

f0101295 <.L35>:
			putch('0', putdat);
f0101295:	83 ec 08             	sub    $0x8,%esp
f0101298:	56                   	push   %esi
f0101299:	6a 30                	push   $0x30
f010129b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010129e:	83 c4 08             	add    $0x8,%esp
f01012a1:	56                   	push   %esi
f01012a2:	6a 78                	push   $0x78
f01012a4:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f01012a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01012aa:	8b 10                	mov    (%eax),%edx
f01012ac:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01012b1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01012b4:	8d 40 04             	lea    0x4(%eax),%eax
f01012b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01012ba:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01012bf:	83 ec 0c             	sub    $0xc,%esp
f01012c2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01012c6:	57                   	push   %edi
f01012c7:	ff 75 e0             	pushl  -0x20(%ebp)
f01012ca:	50                   	push   %eax
f01012cb:	51                   	push   %ecx
f01012cc:	52                   	push   %edx
f01012cd:	89 f2                	mov    %esi,%edx
f01012cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01012d2:	e8 20 fb ff ff       	call   f0100df7 <printnum>
			break;
f01012d7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01012da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01012dd:	83 c7 01             	add    $0x1,%edi
f01012e0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01012e4:	83 f8 25             	cmp    $0x25,%eax
f01012e7:	0f 84 2d fc ff ff    	je     f0100f1a <vprintfmt+0x1f>
			if (ch == '\0')
f01012ed:	85 c0                	test   %eax,%eax
f01012ef:	0f 84 91 00 00 00    	je     f0101386 <.L22+0x21>
			putch(ch, putdat);
f01012f5:	83 ec 08             	sub    $0x8,%esp
f01012f8:	56                   	push   %esi
f01012f9:	50                   	push   %eax
f01012fa:	ff 55 08             	call   *0x8(%ebp)
f01012fd:	83 c4 10             	add    $0x10,%esp
f0101300:	eb db                	jmp    f01012dd <.L35+0x48>

f0101302 <.L38>:
f0101302:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101305:	83 f9 01             	cmp    $0x1,%ecx
f0101308:	7e 15                	jle    f010131f <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f010130a:	8b 45 14             	mov    0x14(%ebp),%eax
f010130d:	8b 10                	mov    (%eax),%edx
f010130f:	8b 48 04             	mov    0x4(%eax),%ecx
f0101312:	8d 40 08             	lea    0x8(%eax),%eax
f0101315:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101318:	b8 10 00 00 00       	mov    $0x10,%eax
f010131d:	eb a0                	jmp    f01012bf <.L35+0x2a>
	else if (lflag)
f010131f:	85 c9                	test   %ecx,%ecx
f0101321:	75 17                	jne    f010133a <.L38+0x38>
		return va_arg(*ap, unsigned int);
f0101323:	8b 45 14             	mov    0x14(%ebp),%eax
f0101326:	8b 10                	mov    (%eax),%edx
f0101328:	b9 00 00 00 00       	mov    $0x0,%ecx
f010132d:	8d 40 04             	lea    0x4(%eax),%eax
f0101330:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101333:	b8 10 00 00 00       	mov    $0x10,%eax
f0101338:	eb 85                	jmp    f01012bf <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f010133a:	8b 45 14             	mov    0x14(%ebp),%eax
f010133d:	8b 10                	mov    (%eax),%edx
f010133f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101344:	8d 40 04             	lea    0x4(%eax),%eax
f0101347:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010134a:	b8 10 00 00 00       	mov    $0x10,%eax
f010134f:	e9 6b ff ff ff       	jmp    f01012bf <.L35+0x2a>

f0101354 <.L25>:
			putch(ch, putdat);
f0101354:	83 ec 08             	sub    $0x8,%esp
f0101357:	56                   	push   %esi
f0101358:	6a 25                	push   $0x25
f010135a:	ff 55 08             	call   *0x8(%ebp)
			break;
f010135d:	83 c4 10             	add    $0x10,%esp
f0101360:	e9 75 ff ff ff       	jmp    f01012da <.L35+0x45>

f0101365 <.L22>:
			putch('%', putdat);
f0101365:	83 ec 08             	sub    $0x8,%esp
f0101368:	56                   	push   %esi
f0101369:	6a 25                	push   $0x25
f010136b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010136e:	83 c4 10             	add    $0x10,%esp
f0101371:	89 f8                	mov    %edi,%eax
f0101373:	eb 03                	jmp    f0101378 <.L22+0x13>
f0101375:	83 e8 01             	sub    $0x1,%eax
f0101378:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010137c:	75 f7                	jne    f0101375 <.L22+0x10>
f010137e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101381:	e9 54 ff ff ff       	jmp    f01012da <.L35+0x45>
}
f0101386:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101389:	5b                   	pop    %ebx
f010138a:	5e                   	pop    %esi
f010138b:	5f                   	pop    %edi
f010138c:	5d                   	pop    %ebp
f010138d:	c3                   	ret    

f010138e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010138e:	55                   	push   %ebp
f010138f:	89 e5                	mov    %esp,%ebp
f0101391:	53                   	push   %ebx
f0101392:	83 ec 14             	sub    $0x14,%esp
f0101395:	e8 22 ee ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010139a:	81 c3 6e ff 00 00    	add    $0xff6e,%ebx
f01013a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01013a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01013a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01013a9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01013ad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01013b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01013b7:	85 c0                	test   %eax,%eax
f01013b9:	74 2b                	je     f01013e6 <vsnprintf+0x58>
f01013bb:	85 d2                	test   %edx,%edx
f01013bd:	7e 27                	jle    f01013e6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01013bf:	ff 75 14             	pushl  0x14(%ebp)
f01013c2:	ff 75 10             	pushl  0x10(%ebp)
f01013c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01013c8:	50                   	push   %eax
f01013c9:	8d 83 b9 fb fe ff    	lea    -0x10447(%ebx),%eax
f01013cf:	50                   	push   %eax
f01013d0:	e8 26 fb ff ff       	call   f0100efb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01013d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01013d8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01013db:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01013de:	83 c4 10             	add    $0x10,%esp
}
f01013e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013e4:	c9                   	leave  
f01013e5:	c3                   	ret    
		return -E_INVAL;
f01013e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01013eb:	eb f4                	jmp    f01013e1 <vsnprintf+0x53>

f01013ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01013ed:	55                   	push   %ebp
f01013ee:	89 e5                	mov    %esp,%ebp
f01013f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01013f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01013f6:	50                   	push   %eax
f01013f7:	ff 75 10             	pushl  0x10(%ebp)
f01013fa:	ff 75 0c             	pushl  0xc(%ebp)
f01013fd:	ff 75 08             	pushl  0x8(%ebp)
f0101400:	e8 89 ff ff ff       	call   f010138e <vsnprintf>
	va_end(ap);

	return rc;
}
f0101405:	c9                   	leave  
f0101406:	c3                   	ret    

f0101407 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101407:	55                   	push   %ebp
f0101408:	89 e5                	mov    %esp,%ebp
f010140a:	57                   	push   %edi
f010140b:	56                   	push   %esi
f010140c:	53                   	push   %ebx
f010140d:	83 ec 1c             	sub    $0x1c,%esp
f0101410:	e8 a7 ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101415:	81 c3 f3 fe 00 00    	add    $0xfef3,%ebx
f010141b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010141e:	85 c0                	test   %eax,%eax
f0101420:	74 13                	je     f0101435 <readline+0x2e>
		cprintf("%s", prompt);
f0101422:	83 ec 08             	sub    $0x8,%esp
f0101425:	50                   	push   %eax
f0101426:	8d 83 d2 0c ff ff    	lea    -0xf32e(%ebx),%eax
f010142c:	50                   	push   %eax
f010142d:	e8 b5 f6 ff ff       	call   f0100ae7 <cprintf>
f0101432:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101435:	83 ec 0c             	sub    $0xc,%esp
f0101438:	6a 00                	push   $0x0
f010143a:	e8 15 f3 ff ff       	call   f0100754 <iscons>
f010143f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101442:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101445:	bf 00 00 00 00       	mov    $0x0,%edi
f010144a:	eb 46                	jmp    f0101492 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010144c:	83 ec 08             	sub    $0x8,%esp
f010144f:	50                   	push   %eax
f0101450:	8d 83 98 0e ff ff    	lea    -0xf168(%ebx),%eax
f0101456:	50                   	push   %eax
f0101457:	e8 8b f6 ff ff       	call   f0100ae7 <cprintf>
			return NULL;
f010145c:	83 c4 10             	add    $0x10,%esp
f010145f:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101464:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101467:	5b                   	pop    %ebx
f0101468:	5e                   	pop    %esi
f0101469:	5f                   	pop    %edi
f010146a:	5d                   	pop    %ebp
f010146b:	c3                   	ret    
			if (echoing)
f010146c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101470:	75 05                	jne    f0101477 <readline+0x70>
			i--;
f0101472:	83 ef 01             	sub    $0x1,%edi
f0101475:	eb 1b                	jmp    f0101492 <readline+0x8b>
				cputchar('\b');
f0101477:	83 ec 0c             	sub    $0xc,%esp
f010147a:	6a 08                	push   $0x8
f010147c:	e8 b2 f2 ff ff       	call   f0100733 <cputchar>
f0101481:	83 c4 10             	add    $0x10,%esp
f0101484:	eb ec                	jmp    f0101472 <readline+0x6b>
			buf[i++] = c;
f0101486:	89 f0                	mov    %esi,%eax
f0101488:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f010148f:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0101492:	e8 ac f2 ff ff       	call   f0100743 <getchar>
f0101497:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101499:	85 c0                	test   %eax,%eax
f010149b:	78 af                	js     f010144c <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010149d:	83 f8 08             	cmp    $0x8,%eax
f01014a0:	0f 94 c2             	sete   %dl
f01014a3:	83 f8 7f             	cmp    $0x7f,%eax
f01014a6:	0f 94 c0             	sete   %al
f01014a9:	08 c2                	or     %al,%dl
f01014ab:	74 04                	je     f01014b1 <readline+0xaa>
f01014ad:	85 ff                	test   %edi,%edi
f01014af:	7f bb                	jg     f010146c <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01014b1:	83 fe 1f             	cmp    $0x1f,%esi
f01014b4:	7e 1c                	jle    f01014d2 <readline+0xcb>
f01014b6:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01014bc:	7f 14                	jg     f01014d2 <readline+0xcb>
			if (echoing)
f01014be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01014c2:	74 c2                	je     f0101486 <readline+0x7f>
				cputchar(c);
f01014c4:	83 ec 0c             	sub    $0xc,%esp
f01014c7:	56                   	push   %esi
f01014c8:	e8 66 f2 ff ff       	call   f0100733 <cputchar>
f01014cd:	83 c4 10             	add    $0x10,%esp
f01014d0:	eb b4                	jmp    f0101486 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f01014d2:	83 fe 0a             	cmp    $0xa,%esi
f01014d5:	74 05                	je     f01014dc <readline+0xd5>
f01014d7:	83 fe 0d             	cmp    $0xd,%esi
f01014da:	75 b6                	jne    f0101492 <readline+0x8b>
			if (echoing)
f01014dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01014e0:	75 13                	jne    f01014f5 <readline+0xee>
			buf[i] = 0;
f01014e2:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f01014e9:	00 
			return buf;
f01014ea:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f01014f0:	e9 6f ff ff ff       	jmp    f0101464 <readline+0x5d>
				cputchar('\n');
f01014f5:	83 ec 0c             	sub    $0xc,%esp
f01014f8:	6a 0a                	push   $0xa
f01014fa:	e8 34 f2 ff ff       	call   f0100733 <cputchar>
f01014ff:	83 c4 10             	add    $0x10,%esp
f0101502:	eb de                	jmp    f01014e2 <readline+0xdb>

f0101504 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101504:	55                   	push   %ebp
f0101505:	89 e5                	mov    %esp,%ebp
f0101507:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010150a:	b8 00 00 00 00       	mov    $0x0,%eax
f010150f:	eb 03                	jmp    f0101514 <strlen+0x10>
		n++;
f0101511:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0101514:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101518:	75 f7                	jne    f0101511 <strlen+0xd>
	return n;
}
f010151a:	5d                   	pop    %ebp
f010151b:	c3                   	ret    

f010151c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010151c:	55                   	push   %ebp
f010151d:	89 e5                	mov    %esp,%ebp
f010151f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101522:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101525:	b8 00 00 00 00       	mov    $0x0,%eax
f010152a:	eb 03                	jmp    f010152f <strnlen+0x13>
		n++;
f010152c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010152f:	39 d0                	cmp    %edx,%eax
f0101531:	74 06                	je     f0101539 <strnlen+0x1d>
f0101533:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101537:	75 f3                	jne    f010152c <strnlen+0x10>
	return n;
}
f0101539:	5d                   	pop    %ebp
f010153a:	c3                   	ret    

f010153b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010153b:	55                   	push   %ebp
f010153c:	89 e5                	mov    %esp,%ebp
f010153e:	53                   	push   %ebx
f010153f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101542:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101545:	89 c2                	mov    %eax,%edx
f0101547:	83 c1 01             	add    $0x1,%ecx
f010154a:	83 c2 01             	add    $0x1,%edx
f010154d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101551:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101554:	84 db                	test   %bl,%bl
f0101556:	75 ef                	jne    f0101547 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101558:	5b                   	pop    %ebx
f0101559:	5d                   	pop    %ebp
f010155a:	c3                   	ret    

f010155b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010155b:	55                   	push   %ebp
f010155c:	89 e5                	mov    %esp,%ebp
f010155e:	53                   	push   %ebx
f010155f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101562:	53                   	push   %ebx
f0101563:	e8 9c ff ff ff       	call   f0101504 <strlen>
f0101568:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010156b:	ff 75 0c             	pushl  0xc(%ebp)
f010156e:	01 d8                	add    %ebx,%eax
f0101570:	50                   	push   %eax
f0101571:	e8 c5 ff ff ff       	call   f010153b <strcpy>
	return dst;
}
f0101576:	89 d8                	mov    %ebx,%eax
f0101578:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010157b:	c9                   	leave  
f010157c:	c3                   	ret    

f010157d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010157d:	55                   	push   %ebp
f010157e:	89 e5                	mov    %esp,%ebp
f0101580:	56                   	push   %esi
f0101581:	53                   	push   %ebx
f0101582:	8b 75 08             	mov    0x8(%ebp),%esi
f0101585:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101588:	89 f3                	mov    %esi,%ebx
f010158a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010158d:	89 f2                	mov    %esi,%edx
f010158f:	eb 0f                	jmp    f01015a0 <strncpy+0x23>
		*dst++ = *src;
f0101591:	83 c2 01             	add    $0x1,%edx
f0101594:	0f b6 01             	movzbl (%ecx),%eax
f0101597:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010159a:	80 39 01             	cmpb   $0x1,(%ecx)
f010159d:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f01015a0:	39 da                	cmp    %ebx,%edx
f01015a2:	75 ed                	jne    f0101591 <strncpy+0x14>
	}
	return ret;
}
f01015a4:	89 f0                	mov    %esi,%eax
f01015a6:	5b                   	pop    %ebx
f01015a7:	5e                   	pop    %esi
f01015a8:	5d                   	pop    %ebp
f01015a9:	c3                   	ret    

f01015aa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01015aa:	55                   	push   %ebp
f01015ab:	89 e5                	mov    %esp,%ebp
f01015ad:	56                   	push   %esi
f01015ae:	53                   	push   %ebx
f01015af:	8b 75 08             	mov    0x8(%ebp),%esi
f01015b2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01015b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01015b8:	89 f0                	mov    %esi,%eax
f01015ba:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01015be:	85 c9                	test   %ecx,%ecx
f01015c0:	75 0b                	jne    f01015cd <strlcpy+0x23>
f01015c2:	eb 17                	jmp    f01015db <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01015c4:	83 c2 01             	add    $0x1,%edx
f01015c7:	83 c0 01             	add    $0x1,%eax
f01015ca:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01015cd:	39 d8                	cmp    %ebx,%eax
f01015cf:	74 07                	je     f01015d8 <strlcpy+0x2e>
f01015d1:	0f b6 0a             	movzbl (%edx),%ecx
f01015d4:	84 c9                	test   %cl,%cl
f01015d6:	75 ec                	jne    f01015c4 <strlcpy+0x1a>
		*dst = '\0';
f01015d8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01015db:	29 f0                	sub    %esi,%eax
}
f01015dd:	5b                   	pop    %ebx
f01015de:	5e                   	pop    %esi
f01015df:	5d                   	pop    %ebp
f01015e0:	c3                   	ret    

f01015e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01015e1:	55                   	push   %ebp
f01015e2:	89 e5                	mov    %esp,%ebp
f01015e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01015ea:	eb 06                	jmp    f01015f2 <strcmp+0x11>
		p++, q++;
f01015ec:	83 c1 01             	add    $0x1,%ecx
f01015ef:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01015f2:	0f b6 01             	movzbl (%ecx),%eax
f01015f5:	84 c0                	test   %al,%al
f01015f7:	74 04                	je     f01015fd <strcmp+0x1c>
f01015f9:	3a 02                	cmp    (%edx),%al
f01015fb:	74 ef                	je     f01015ec <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01015fd:	0f b6 c0             	movzbl %al,%eax
f0101600:	0f b6 12             	movzbl (%edx),%edx
f0101603:	29 d0                	sub    %edx,%eax
}
f0101605:	5d                   	pop    %ebp
f0101606:	c3                   	ret    

f0101607 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101607:	55                   	push   %ebp
f0101608:	89 e5                	mov    %esp,%ebp
f010160a:	53                   	push   %ebx
f010160b:	8b 45 08             	mov    0x8(%ebp),%eax
f010160e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101611:	89 c3                	mov    %eax,%ebx
f0101613:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101616:	eb 06                	jmp    f010161e <strncmp+0x17>
		n--, p++, q++;
f0101618:	83 c0 01             	add    $0x1,%eax
f010161b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f010161e:	39 d8                	cmp    %ebx,%eax
f0101620:	74 16                	je     f0101638 <strncmp+0x31>
f0101622:	0f b6 08             	movzbl (%eax),%ecx
f0101625:	84 c9                	test   %cl,%cl
f0101627:	74 04                	je     f010162d <strncmp+0x26>
f0101629:	3a 0a                	cmp    (%edx),%cl
f010162b:	74 eb                	je     f0101618 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010162d:	0f b6 00             	movzbl (%eax),%eax
f0101630:	0f b6 12             	movzbl (%edx),%edx
f0101633:	29 d0                	sub    %edx,%eax
}
f0101635:	5b                   	pop    %ebx
f0101636:	5d                   	pop    %ebp
f0101637:	c3                   	ret    
		return 0;
f0101638:	b8 00 00 00 00       	mov    $0x0,%eax
f010163d:	eb f6                	jmp    f0101635 <strncmp+0x2e>

f010163f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010163f:	55                   	push   %ebp
f0101640:	89 e5                	mov    %esp,%ebp
f0101642:	8b 45 08             	mov    0x8(%ebp),%eax
f0101645:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101649:	0f b6 10             	movzbl (%eax),%edx
f010164c:	84 d2                	test   %dl,%dl
f010164e:	74 09                	je     f0101659 <strchr+0x1a>
		if (*s == c)
f0101650:	38 ca                	cmp    %cl,%dl
f0101652:	74 0a                	je     f010165e <strchr+0x1f>
	for (; *s; s++)
f0101654:	83 c0 01             	add    $0x1,%eax
f0101657:	eb f0                	jmp    f0101649 <strchr+0xa>
			return (char *) s;
	return 0;
f0101659:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010165e:	5d                   	pop    %ebp
f010165f:	c3                   	ret    

f0101660 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101660:	55                   	push   %ebp
f0101661:	89 e5                	mov    %esp,%ebp
f0101663:	8b 45 08             	mov    0x8(%ebp),%eax
f0101666:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010166a:	eb 03                	jmp    f010166f <strfind+0xf>
f010166c:	83 c0 01             	add    $0x1,%eax
f010166f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101672:	38 ca                	cmp    %cl,%dl
f0101674:	74 04                	je     f010167a <strfind+0x1a>
f0101676:	84 d2                	test   %dl,%dl
f0101678:	75 f2                	jne    f010166c <strfind+0xc>
			break;
	return (char *) s;
}
f010167a:	5d                   	pop    %ebp
f010167b:	c3                   	ret    

f010167c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010167c:	55                   	push   %ebp
f010167d:	89 e5                	mov    %esp,%ebp
f010167f:	57                   	push   %edi
f0101680:	56                   	push   %esi
f0101681:	53                   	push   %ebx
f0101682:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101685:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101688:	85 c9                	test   %ecx,%ecx
f010168a:	74 13                	je     f010169f <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010168c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101692:	75 05                	jne    f0101699 <memset+0x1d>
f0101694:	f6 c1 03             	test   $0x3,%cl
f0101697:	74 0d                	je     f01016a6 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101699:	8b 45 0c             	mov    0xc(%ebp),%eax
f010169c:	fc                   	cld    
f010169d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010169f:	89 f8                	mov    %edi,%eax
f01016a1:	5b                   	pop    %ebx
f01016a2:	5e                   	pop    %esi
f01016a3:	5f                   	pop    %edi
f01016a4:	5d                   	pop    %ebp
f01016a5:	c3                   	ret    
		c &= 0xFF;
f01016a6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01016aa:	89 d3                	mov    %edx,%ebx
f01016ac:	c1 e3 08             	shl    $0x8,%ebx
f01016af:	89 d0                	mov    %edx,%eax
f01016b1:	c1 e0 18             	shl    $0x18,%eax
f01016b4:	89 d6                	mov    %edx,%esi
f01016b6:	c1 e6 10             	shl    $0x10,%esi
f01016b9:	09 f0                	or     %esi,%eax
f01016bb:	09 c2                	or     %eax,%edx
f01016bd:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f01016bf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01016c2:	89 d0                	mov    %edx,%eax
f01016c4:	fc                   	cld    
f01016c5:	f3 ab                	rep stos %eax,%es:(%edi)
f01016c7:	eb d6                	jmp    f010169f <memset+0x23>

f01016c9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01016c9:	55                   	push   %ebp
f01016ca:	89 e5                	mov    %esp,%ebp
f01016cc:	57                   	push   %edi
f01016cd:	56                   	push   %esi
f01016ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01016d1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01016d7:	39 c6                	cmp    %eax,%esi
f01016d9:	73 35                	jae    f0101710 <memmove+0x47>
f01016db:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01016de:	39 c2                	cmp    %eax,%edx
f01016e0:	76 2e                	jbe    f0101710 <memmove+0x47>
		s += n;
		d += n;
f01016e2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01016e5:	89 d6                	mov    %edx,%esi
f01016e7:	09 fe                	or     %edi,%esi
f01016e9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01016ef:	74 0c                	je     f01016fd <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01016f1:	83 ef 01             	sub    $0x1,%edi
f01016f4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01016f7:	fd                   	std    
f01016f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01016fa:	fc                   	cld    
f01016fb:	eb 21                	jmp    f010171e <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01016fd:	f6 c1 03             	test   $0x3,%cl
f0101700:	75 ef                	jne    f01016f1 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101702:	83 ef 04             	sub    $0x4,%edi
f0101705:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101708:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010170b:	fd                   	std    
f010170c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010170e:	eb ea                	jmp    f01016fa <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101710:	89 f2                	mov    %esi,%edx
f0101712:	09 c2                	or     %eax,%edx
f0101714:	f6 c2 03             	test   $0x3,%dl
f0101717:	74 09                	je     f0101722 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101719:	89 c7                	mov    %eax,%edi
f010171b:	fc                   	cld    
f010171c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010171e:	5e                   	pop    %esi
f010171f:	5f                   	pop    %edi
f0101720:	5d                   	pop    %ebp
f0101721:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101722:	f6 c1 03             	test   $0x3,%cl
f0101725:	75 f2                	jne    f0101719 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101727:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010172a:	89 c7                	mov    %eax,%edi
f010172c:	fc                   	cld    
f010172d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010172f:	eb ed                	jmp    f010171e <memmove+0x55>

f0101731 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101731:	55                   	push   %ebp
f0101732:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101734:	ff 75 10             	pushl  0x10(%ebp)
f0101737:	ff 75 0c             	pushl  0xc(%ebp)
f010173a:	ff 75 08             	pushl  0x8(%ebp)
f010173d:	e8 87 ff ff ff       	call   f01016c9 <memmove>
}
f0101742:	c9                   	leave  
f0101743:	c3                   	ret    

f0101744 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101744:	55                   	push   %ebp
f0101745:	89 e5                	mov    %esp,%ebp
f0101747:	56                   	push   %esi
f0101748:	53                   	push   %ebx
f0101749:	8b 45 08             	mov    0x8(%ebp),%eax
f010174c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010174f:	89 c6                	mov    %eax,%esi
f0101751:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101754:	39 f0                	cmp    %esi,%eax
f0101756:	74 1c                	je     f0101774 <memcmp+0x30>
		if (*s1 != *s2)
f0101758:	0f b6 08             	movzbl (%eax),%ecx
f010175b:	0f b6 1a             	movzbl (%edx),%ebx
f010175e:	38 d9                	cmp    %bl,%cl
f0101760:	75 08                	jne    f010176a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101762:	83 c0 01             	add    $0x1,%eax
f0101765:	83 c2 01             	add    $0x1,%edx
f0101768:	eb ea                	jmp    f0101754 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010176a:	0f b6 c1             	movzbl %cl,%eax
f010176d:	0f b6 db             	movzbl %bl,%ebx
f0101770:	29 d8                	sub    %ebx,%eax
f0101772:	eb 05                	jmp    f0101779 <memcmp+0x35>
	}

	return 0;
f0101774:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101779:	5b                   	pop    %ebx
f010177a:	5e                   	pop    %esi
f010177b:	5d                   	pop    %ebp
f010177c:	c3                   	ret    

f010177d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010177d:	55                   	push   %ebp
f010177e:	89 e5                	mov    %esp,%ebp
f0101780:	8b 45 08             	mov    0x8(%ebp),%eax
f0101783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101786:	89 c2                	mov    %eax,%edx
f0101788:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010178b:	39 d0                	cmp    %edx,%eax
f010178d:	73 09                	jae    f0101798 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010178f:	38 08                	cmp    %cl,(%eax)
f0101791:	74 05                	je     f0101798 <memfind+0x1b>
	for (; s < ends; s++)
f0101793:	83 c0 01             	add    $0x1,%eax
f0101796:	eb f3                	jmp    f010178b <memfind+0xe>
			break;
	return (void *) s;
}
f0101798:	5d                   	pop    %ebp
f0101799:	c3                   	ret    

f010179a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010179a:	55                   	push   %ebp
f010179b:	89 e5                	mov    %esp,%ebp
f010179d:	57                   	push   %edi
f010179e:	56                   	push   %esi
f010179f:	53                   	push   %ebx
f01017a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01017a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01017a6:	eb 03                	jmp    f01017ab <strtol+0x11>
		s++;
f01017a8:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01017ab:	0f b6 01             	movzbl (%ecx),%eax
f01017ae:	3c 20                	cmp    $0x20,%al
f01017b0:	74 f6                	je     f01017a8 <strtol+0xe>
f01017b2:	3c 09                	cmp    $0x9,%al
f01017b4:	74 f2                	je     f01017a8 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01017b6:	3c 2b                	cmp    $0x2b,%al
f01017b8:	74 2e                	je     f01017e8 <strtol+0x4e>
	int neg = 0;
f01017ba:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01017bf:	3c 2d                	cmp    $0x2d,%al
f01017c1:	74 2f                	je     f01017f2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01017c3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01017c9:	75 05                	jne    f01017d0 <strtol+0x36>
f01017cb:	80 39 30             	cmpb   $0x30,(%ecx)
f01017ce:	74 2c                	je     f01017fc <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01017d0:	85 db                	test   %ebx,%ebx
f01017d2:	75 0a                	jne    f01017de <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01017d4:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01017d9:	80 39 30             	cmpb   $0x30,(%ecx)
f01017dc:	74 28                	je     f0101806 <strtol+0x6c>
		base = 10;
f01017de:	b8 00 00 00 00       	mov    $0x0,%eax
f01017e3:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01017e6:	eb 50                	jmp    f0101838 <strtol+0x9e>
		s++;
f01017e8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01017eb:	bf 00 00 00 00       	mov    $0x0,%edi
f01017f0:	eb d1                	jmp    f01017c3 <strtol+0x29>
		s++, neg = 1;
f01017f2:	83 c1 01             	add    $0x1,%ecx
f01017f5:	bf 01 00 00 00       	mov    $0x1,%edi
f01017fa:	eb c7                	jmp    f01017c3 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01017fc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101800:	74 0e                	je     f0101810 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0101802:	85 db                	test   %ebx,%ebx
f0101804:	75 d8                	jne    f01017de <strtol+0x44>
		s++, base = 8;
f0101806:	83 c1 01             	add    $0x1,%ecx
f0101809:	bb 08 00 00 00       	mov    $0x8,%ebx
f010180e:	eb ce                	jmp    f01017de <strtol+0x44>
		s += 2, base = 16;
f0101810:	83 c1 02             	add    $0x2,%ecx
f0101813:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101818:	eb c4                	jmp    f01017de <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f010181a:	8d 72 9f             	lea    -0x61(%edx),%esi
f010181d:	89 f3                	mov    %esi,%ebx
f010181f:	80 fb 19             	cmp    $0x19,%bl
f0101822:	77 29                	ja     f010184d <strtol+0xb3>
			dig = *s - 'a' + 10;
f0101824:	0f be d2             	movsbl %dl,%edx
f0101827:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010182a:	3b 55 10             	cmp    0x10(%ebp),%edx
f010182d:	7d 30                	jge    f010185f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f010182f:	83 c1 01             	add    $0x1,%ecx
f0101832:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101836:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101838:	0f b6 11             	movzbl (%ecx),%edx
f010183b:	8d 72 d0             	lea    -0x30(%edx),%esi
f010183e:	89 f3                	mov    %esi,%ebx
f0101840:	80 fb 09             	cmp    $0x9,%bl
f0101843:	77 d5                	ja     f010181a <strtol+0x80>
			dig = *s - '0';
f0101845:	0f be d2             	movsbl %dl,%edx
f0101848:	83 ea 30             	sub    $0x30,%edx
f010184b:	eb dd                	jmp    f010182a <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f010184d:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101850:	89 f3                	mov    %esi,%ebx
f0101852:	80 fb 19             	cmp    $0x19,%bl
f0101855:	77 08                	ja     f010185f <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101857:	0f be d2             	movsbl %dl,%edx
f010185a:	83 ea 37             	sub    $0x37,%edx
f010185d:	eb cb                	jmp    f010182a <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f010185f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101863:	74 05                	je     f010186a <strtol+0xd0>
		*endptr = (char *) s;
f0101865:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101868:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010186a:	89 c2                	mov    %eax,%edx
f010186c:	f7 da                	neg    %edx
f010186e:	85 ff                	test   %edi,%edi
f0101870:	0f 45 c2             	cmovne %edx,%eax
}
f0101873:	5b                   	pop    %ebx
f0101874:	5e                   	pop    %esi
f0101875:	5f                   	pop    %edi
f0101876:	5d                   	pop    %ebp
f0101877:	c3                   	ret    
f0101878:	66 90                	xchg   %ax,%ax
f010187a:	66 90                	xchg   %ax,%ax
f010187c:	66 90                	xchg   %ax,%ax
f010187e:	66 90                	xchg   %ax,%ax

f0101880 <__udivdi3>:
f0101880:	55                   	push   %ebp
f0101881:	57                   	push   %edi
f0101882:	56                   	push   %esi
f0101883:	53                   	push   %ebx
f0101884:	83 ec 1c             	sub    $0x1c,%esp
f0101887:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010188b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010188f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101893:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101897:	85 d2                	test   %edx,%edx
f0101899:	75 35                	jne    f01018d0 <__udivdi3+0x50>
f010189b:	39 f3                	cmp    %esi,%ebx
f010189d:	0f 87 bd 00 00 00    	ja     f0101960 <__udivdi3+0xe0>
f01018a3:	85 db                	test   %ebx,%ebx
f01018a5:	89 d9                	mov    %ebx,%ecx
f01018a7:	75 0b                	jne    f01018b4 <__udivdi3+0x34>
f01018a9:	b8 01 00 00 00       	mov    $0x1,%eax
f01018ae:	31 d2                	xor    %edx,%edx
f01018b0:	f7 f3                	div    %ebx
f01018b2:	89 c1                	mov    %eax,%ecx
f01018b4:	31 d2                	xor    %edx,%edx
f01018b6:	89 f0                	mov    %esi,%eax
f01018b8:	f7 f1                	div    %ecx
f01018ba:	89 c6                	mov    %eax,%esi
f01018bc:	89 e8                	mov    %ebp,%eax
f01018be:	89 f7                	mov    %esi,%edi
f01018c0:	f7 f1                	div    %ecx
f01018c2:	89 fa                	mov    %edi,%edx
f01018c4:	83 c4 1c             	add    $0x1c,%esp
f01018c7:	5b                   	pop    %ebx
f01018c8:	5e                   	pop    %esi
f01018c9:	5f                   	pop    %edi
f01018ca:	5d                   	pop    %ebp
f01018cb:	c3                   	ret    
f01018cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018d0:	39 f2                	cmp    %esi,%edx
f01018d2:	77 7c                	ja     f0101950 <__udivdi3+0xd0>
f01018d4:	0f bd fa             	bsr    %edx,%edi
f01018d7:	83 f7 1f             	xor    $0x1f,%edi
f01018da:	0f 84 98 00 00 00    	je     f0101978 <__udivdi3+0xf8>
f01018e0:	89 f9                	mov    %edi,%ecx
f01018e2:	b8 20 00 00 00       	mov    $0x20,%eax
f01018e7:	29 f8                	sub    %edi,%eax
f01018e9:	d3 e2                	shl    %cl,%edx
f01018eb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01018ef:	89 c1                	mov    %eax,%ecx
f01018f1:	89 da                	mov    %ebx,%edx
f01018f3:	d3 ea                	shr    %cl,%edx
f01018f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01018f9:	09 d1                	or     %edx,%ecx
f01018fb:	89 f2                	mov    %esi,%edx
f01018fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101901:	89 f9                	mov    %edi,%ecx
f0101903:	d3 e3                	shl    %cl,%ebx
f0101905:	89 c1                	mov    %eax,%ecx
f0101907:	d3 ea                	shr    %cl,%edx
f0101909:	89 f9                	mov    %edi,%ecx
f010190b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010190f:	d3 e6                	shl    %cl,%esi
f0101911:	89 eb                	mov    %ebp,%ebx
f0101913:	89 c1                	mov    %eax,%ecx
f0101915:	d3 eb                	shr    %cl,%ebx
f0101917:	09 de                	or     %ebx,%esi
f0101919:	89 f0                	mov    %esi,%eax
f010191b:	f7 74 24 08          	divl   0x8(%esp)
f010191f:	89 d6                	mov    %edx,%esi
f0101921:	89 c3                	mov    %eax,%ebx
f0101923:	f7 64 24 0c          	mull   0xc(%esp)
f0101927:	39 d6                	cmp    %edx,%esi
f0101929:	72 0c                	jb     f0101937 <__udivdi3+0xb7>
f010192b:	89 f9                	mov    %edi,%ecx
f010192d:	d3 e5                	shl    %cl,%ebp
f010192f:	39 c5                	cmp    %eax,%ebp
f0101931:	73 5d                	jae    f0101990 <__udivdi3+0x110>
f0101933:	39 d6                	cmp    %edx,%esi
f0101935:	75 59                	jne    f0101990 <__udivdi3+0x110>
f0101937:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010193a:	31 ff                	xor    %edi,%edi
f010193c:	89 fa                	mov    %edi,%edx
f010193e:	83 c4 1c             	add    $0x1c,%esp
f0101941:	5b                   	pop    %ebx
f0101942:	5e                   	pop    %esi
f0101943:	5f                   	pop    %edi
f0101944:	5d                   	pop    %ebp
f0101945:	c3                   	ret    
f0101946:	8d 76 00             	lea    0x0(%esi),%esi
f0101949:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101950:	31 ff                	xor    %edi,%edi
f0101952:	31 c0                	xor    %eax,%eax
f0101954:	89 fa                	mov    %edi,%edx
f0101956:	83 c4 1c             	add    $0x1c,%esp
f0101959:	5b                   	pop    %ebx
f010195a:	5e                   	pop    %esi
f010195b:	5f                   	pop    %edi
f010195c:	5d                   	pop    %ebp
f010195d:	c3                   	ret    
f010195e:	66 90                	xchg   %ax,%ax
f0101960:	31 ff                	xor    %edi,%edi
f0101962:	89 e8                	mov    %ebp,%eax
f0101964:	89 f2                	mov    %esi,%edx
f0101966:	f7 f3                	div    %ebx
f0101968:	89 fa                	mov    %edi,%edx
f010196a:	83 c4 1c             	add    $0x1c,%esp
f010196d:	5b                   	pop    %ebx
f010196e:	5e                   	pop    %esi
f010196f:	5f                   	pop    %edi
f0101970:	5d                   	pop    %ebp
f0101971:	c3                   	ret    
f0101972:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101978:	39 f2                	cmp    %esi,%edx
f010197a:	72 06                	jb     f0101982 <__udivdi3+0x102>
f010197c:	31 c0                	xor    %eax,%eax
f010197e:	39 eb                	cmp    %ebp,%ebx
f0101980:	77 d2                	ja     f0101954 <__udivdi3+0xd4>
f0101982:	b8 01 00 00 00       	mov    $0x1,%eax
f0101987:	eb cb                	jmp    f0101954 <__udivdi3+0xd4>
f0101989:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101990:	89 d8                	mov    %ebx,%eax
f0101992:	31 ff                	xor    %edi,%edi
f0101994:	eb be                	jmp    f0101954 <__udivdi3+0xd4>
f0101996:	66 90                	xchg   %ax,%ax
f0101998:	66 90                	xchg   %ax,%ax
f010199a:	66 90                	xchg   %ax,%ax
f010199c:	66 90                	xchg   %ax,%ax
f010199e:	66 90                	xchg   %ax,%ax

f01019a0 <__umoddi3>:
f01019a0:	55                   	push   %ebp
f01019a1:	57                   	push   %edi
f01019a2:	56                   	push   %esi
f01019a3:	53                   	push   %ebx
f01019a4:	83 ec 1c             	sub    $0x1c,%esp
f01019a7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01019ab:	8b 74 24 30          	mov    0x30(%esp),%esi
f01019af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01019b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01019b7:	85 ed                	test   %ebp,%ebp
f01019b9:	89 f0                	mov    %esi,%eax
f01019bb:	89 da                	mov    %ebx,%edx
f01019bd:	75 19                	jne    f01019d8 <__umoddi3+0x38>
f01019bf:	39 df                	cmp    %ebx,%edi
f01019c1:	0f 86 b1 00 00 00    	jbe    f0101a78 <__umoddi3+0xd8>
f01019c7:	f7 f7                	div    %edi
f01019c9:	89 d0                	mov    %edx,%eax
f01019cb:	31 d2                	xor    %edx,%edx
f01019cd:	83 c4 1c             	add    $0x1c,%esp
f01019d0:	5b                   	pop    %ebx
f01019d1:	5e                   	pop    %esi
f01019d2:	5f                   	pop    %edi
f01019d3:	5d                   	pop    %ebp
f01019d4:	c3                   	ret    
f01019d5:	8d 76 00             	lea    0x0(%esi),%esi
f01019d8:	39 dd                	cmp    %ebx,%ebp
f01019da:	77 f1                	ja     f01019cd <__umoddi3+0x2d>
f01019dc:	0f bd cd             	bsr    %ebp,%ecx
f01019df:	83 f1 1f             	xor    $0x1f,%ecx
f01019e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01019e6:	0f 84 b4 00 00 00    	je     f0101aa0 <__umoddi3+0x100>
f01019ec:	b8 20 00 00 00       	mov    $0x20,%eax
f01019f1:	89 c2                	mov    %eax,%edx
f01019f3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01019f7:	29 c2                	sub    %eax,%edx
f01019f9:	89 c1                	mov    %eax,%ecx
f01019fb:	89 f8                	mov    %edi,%eax
f01019fd:	d3 e5                	shl    %cl,%ebp
f01019ff:	89 d1                	mov    %edx,%ecx
f0101a01:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a05:	d3 e8                	shr    %cl,%eax
f0101a07:	09 c5                	or     %eax,%ebp
f0101a09:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101a0d:	89 c1                	mov    %eax,%ecx
f0101a0f:	d3 e7                	shl    %cl,%edi
f0101a11:	89 d1                	mov    %edx,%ecx
f0101a13:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101a17:	89 df                	mov    %ebx,%edi
f0101a19:	d3 ef                	shr    %cl,%edi
f0101a1b:	89 c1                	mov    %eax,%ecx
f0101a1d:	89 f0                	mov    %esi,%eax
f0101a1f:	d3 e3                	shl    %cl,%ebx
f0101a21:	89 d1                	mov    %edx,%ecx
f0101a23:	89 fa                	mov    %edi,%edx
f0101a25:	d3 e8                	shr    %cl,%eax
f0101a27:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101a2c:	09 d8                	or     %ebx,%eax
f0101a2e:	f7 f5                	div    %ebp
f0101a30:	d3 e6                	shl    %cl,%esi
f0101a32:	89 d1                	mov    %edx,%ecx
f0101a34:	f7 64 24 08          	mull   0x8(%esp)
f0101a38:	39 d1                	cmp    %edx,%ecx
f0101a3a:	89 c3                	mov    %eax,%ebx
f0101a3c:	89 d7                	mov    %edx,%edi
f0101a3e:	72 06                	jb     f0101a46 <__umoddi3+0xa6>
f0101a40:	75 0e                	jne    f0101a50 <__umoddi3+0xb0>
f0101a42:	39 c6                	cmp    %eax,%esi
f0101a44:	73 0a                	jae    f0101a50 <__umoddi3+0xb0>
f0101a46:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101a4a:	19 ea                	sbb    %ebp,%edx
f0101a4c:	89 d7                	mov    %edx,%edi
f0101a4e:	89 c3                	mov    %eax,%ebx
f0101a50:	89 ca                	mov    %ecx,%edx
f0101a52:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101a57:	29 de                	sub    %ebx,%esi
f0101a59:	19 fa                	sbb    %edi,%edx
f0101a5b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0101a5f:	89 d0                	mov    %edx,%eax
f0101a61:	d3 e0                	shl    %cl,%eax
f0101a63:	89 d9                	mov    %ebx,%ecx
f0101a65:	d3 ee                	shr    %cl,%esi
f0101a67:	d3 ea                	shr    %cl,%edx
f0101a69:	09 f0                	or     %esi,%eax
f0101a6b:	83 c4 1c             	add    $0x1c,%esp
f0101a6e:	5b                   	pop    %ebx
f0101a6f:	5e                   	pop    %esi
f0101a70:	5f                   	pop    %edi
f0101a71:	5d                   	pop    %ebp
f0101a72:	c3                   	ret    
f0101a73:	90                   	nop
f0101a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101a78:	85 ff                	test   %edi,%edi
f0101a7a:	89 f9                	mov    %edi,%ecx
f0101a7c:	75 0b                	jne    f0101a89 <__umoddi3+0xe9>
f0101a7e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a83:	31 d2                	xor    %edx,%edx
f0101a85:	f7 f7                	div    %edi
f0101a87:	89 c1                	mov    %eax,%ecx
f0101a89:	89 d8                	mov    %ebx,%eax
f0101a8b:	31 d2                	xor    %edx,%edx
f0101a8d:	f7 f1                	div    %ecx
f0101a8f:	89 f0                	mov    %esi,%eax
f0101a91:	f7 f1                	div    %ecx
f0101a93:	e9 31 ff ff ff       	jmp    f01019c9 <__umoddi3+0x29>
f0101a98:	90                   	nop
f0101a99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101aa0:	39 dd                	cmp    %ebx,%ebp
f0101aa2:	72 08                	jb     f0101aac <__umoddi3+0x10c>
f0101aa4:	39 f7                	cmp    %esi,%edi
f0101aa6:	0f 87 21 ff ff ff    	ja     f01019cd <__umoddi3+0x2d>
f0101aac:	89 da                	mov    %ebx,%edx
f0101aae:	89 f0                	mov    %esi,%eax
f0101ab0:	29 f8                	sub    %edi,%eax
f0101ab2:	19 ea                	sbb    %ebp,%edx
f0101ab4:	e9 14 ff ff ff       	jmp    f01019cd <__umoddi3+0x2d>
