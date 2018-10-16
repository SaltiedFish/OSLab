
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
f0100057:	8d 83 78 08 ff ff    	lea    -0xf788(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 99 0a 00 00       	call   f0100afc <cprintf>
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
f010007f:	8d 83 94 08 ff ff    	lea    -0xf76c(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 71 0a 00 00       	call   f0100afc <cprintf>
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
f01000ca:	e8 65 16 00 00       	call   f0101734 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3d 05 00 00       	call   f0100611 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 af 08 ff ff    	lea    -0xf751(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 14 0a 00 00       	call   f0100afc <cprintf>

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
f01000fc:	e8 3f 08 00 00       	call   f0100940 <monitor>
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
f010012d:	e8 0e 08 00 00       	call   f0100940 <monitor>
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
f0100147:	8d 83 ca 08 ff ff    	lea    -0xf736(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 a9 09 00 00       	call   f0100afc <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 68 09 00 00       	call   f0100ac5 <vcprintf>
	cprintf("\n");
f010015d:	8d 83 06 09 ff ff    	lea    -0xf6fa(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 91 09 00 00       	call   f0100afc <cprintf>
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
f010018c:	8d 83 e2 08 ff ff    	lea    -0xf71e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 64 09 00 00       	call   f0100afc <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 21 09 00 00       	call   f0100ac5 <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 06 09 ff ff    	lea    -0xf6fa(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 4a 09 00 00       	call   f0100afc <cprintf>
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
f0100284:	0f b6 84 13 38 0a ff 	movzbl -0xf5c8(%ebx,%edx,1),%eax
f010028b:	ff 
f010028c:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100292:	0f b6 8c 13 38 09 ff 	movzbl -0xf6c8(%ebx,%edx,1),%ecx
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
f01002d7:	8d 83 fc 08 ff ff    	lea    -0xf704(%ebx),%eax
f01002dd:	50                   	push   %eax
f01002de:	e8 19 08 00 00       	call   f0100afc <cprintf>
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
f010031e:	0f b6 84 13 38 0a ff 	movzbl -0xf5c8(%ebx,%edx,1),%eax
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
f010053f:	e8 3d 12 00 00       	call   f0101781 <memmove>
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
f0100722:	8d 83 08 09 ff ff    	lea    -0xf6f8(%ebx),%eax
f0100728:	50                   	push   %eax
f0100729:	e8 ce 03 00 00       	call   f0100afc <cprintf>
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
f0100775:	8d 83 38 0b ff ff    	lea    -0xf4c8(%ebx),%eax
f010077b:	50                   	push   %eax
f010077c:	8d 83 56 0b ff ff    	lea    -0xf4aa(%ebx),%eax
f0100782:	50                   	push   %eax
f0100783:	8d b3 5b 0b ff ff    	lea    -0xf4a5(%ebx),%esi
f0100789:	56                   	push   %esi
f010078a:	e8 6d 03 00 00       	call   f0100afc <cprintf>
f010078f:	83 c4 0c             	add    $0xc,%esp
f0100792:	8d 83 10 0c ff ff    	lea    -0xf3f0(%ebx),%eax
f0100798:	50                   	push   %eax
f0100799:	8d 83 64 0b ff ff    	lea    -0xf49c(%ebx),%eax
f010079f:	50                   	push   %eax
f01007a0:	56                   	push   %esi
f01007a1:	e8 56 03 00 00       	call   f0100afc <cprintf>
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
f01007c6:	8d 83 6d 0b ff ff    	lea    -0xf493(%ebx),%eax
f01007cc:	50                   	push   %eax
f01007cd:	e8 2a 03 00 00       	call   f0100afc <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d2:	83 c4 08             	add    $0x8,%esp
f01007d5:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007db:	8d 83 38 0c ff ff    	lea    -0xf3c8(%ebx),%eax
f01007e1:	50                   	push   %eax
f01007e2:	e8 15 03 00 00       	call   f0100afc <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e7:	83 c4 0c             	add    $0xc,%esp
f01007ea:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007f0:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007f6:	50                   	push   %eax
f01007f7:	57                   	push   %edi
f01007f8:	8d 83 60 0c ff ff    	lea    -0xf3a0(%ebx),%eax
f01007fe:	50                   	push   %eax
f01007ff:	e8 f8 02 00 00       	call   f0100afc <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100804:	83 c4 0c             	add    $0xc,%esp
f0100807:	c7 c0 69 1b 10 f0    	mov    $0xf0101b69,%eax
f010080d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100813:	52                   	push   %edx
f0100814:	50                   	push   %eax
f0100815:	8d 83 84 0c ff ff    	lea    -0xf37c(%ebx),%eax
f010081b:	50                   	push   %eax
f010081c:	e8 db 02 00 00       	call   f0100afc <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100821:	83 c4 0c             	add    $0xc,%esp
f0100824:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f010082a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100830:	52                   	push   %edx
f0100831:	50                   	push   %eax
f0100832:	8d 83 a8 0c ff ff    	lea    -0xf358(%ebx),%eax
f0100838:	50                   	push   %eax
f0100839:	e8 be 02 00 00       	call   f0100afc <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010083e:	83 c4 0c             	add    $0xc,%esp
f0100841:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f0100847:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010084d:	50                   	push   %eax
f010084e:	56                   	push   %esi
f010084f:	8d 83 cc 0c ff ff    	lea    -0xf334(%ebx),%eax
f0100855:	50                   	push   %eax
f0100856:	e8 a1 02 00 00       	call   f0100afc <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085b:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010085e:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f0100864:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	c1 fe 0a             	sar    $0xa,%esi
f0100869:	56                   	push   %esi
f010086a:	8d 83 f0 0c ff ff    	lea    -0xf310(%ebx),%eax
f0100870:	50                   	push   %eax
f0100871:	e8 86 02 00 00       	call   f0100afc <cprintf>
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
f0100897:	8d 83 86 0b ff ff    	lea    -0xf47a(%ebx),%eax
f010089d:	50                   	push   %eax
f010089e:	e8 59 02 00 00       	call   f0100afc <cprintf>

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
		uint32_t *eip=ebp+1;
		int flag=debuginfo_eip((uintptr_t)*eip,&info);
f01008aa:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008ad:	89 45 bc             	mov    %eax,-0x44(%ebp)
		cprintf("  ebp %08x eip %08x args",ebp,*eip);
f01008b0:	8d 83 98 0b ff ff    	lea    -0xf468(%ebx),%eax
f01008b6:	89 45 b8             	mov    %eax,-0x48(%ebp)
	while(ebp)
f01008b9:	eb 74                	jmp    f010092f <mon_backtrace+0xac>
		int flag=debuginfo_eip((uintptr_t)*eip,&info);
f01008bb:	83 ec 08             	sub    $0x8,%esp
f01008be:	ff 75 bc             	pushl  -0x44(%ebp)
f01008c1:	ff 77 04             	pushl  0x4(%edi)
f01008c4:	e8 37 03 00 00       	call   f0100c00 <debuginfo_eip>
		cprintf("  ebp %08x eip %08x args",ebp,*eip);
f01008c9:	83 c4 0c             	add    $0xc,%esp
f01008cc:	ff 77 04             	pushl  0x4(%edi)
f01008cf:	57                   	push   %edi
f01008d0:	ff 75 b8             	pushl  -0x48(%ebp)
f01008d3:	e8 24 02 00 00       	call   f0100afc <cprintf>
f01008d8:	8d 77 08             	lea    0x8(%edi),%esi
f01008db:	8d 47 1c             	lea    0x1c(%edi),%eax
f01008de:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01008e1:	83 c4 10             	add    $0x10,%esp
		for(int i=1;i<=5;++i)
		{
			cprintf(" %08x",*(ebp+i+1));
f01008e4:	8d 83 b1 0b ff ff    	lea    -0xf44f(%ebx),%eax
f01008ea:	89 7d c0             	mov    %edi,-0x40(%ebp)
f01008ed:	89 c7                	mov    %eax,%edi
f01008ef:	83 ec 08             	sub    $0x8,%esp
f01008f2:	ff 36                	pushl  (%esi)
f01008f4:	57                   	push   %edi
f01008f5:	e8 02 02 00 00       	call   f0100afc <cprintf>
f01008fa:	83 c6 04             	add    $0x4,%esi
		for(int i=1;i<=5;++i)
f01008fd:	83 c4 10             	add    $0x10,%esp
f0100900:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f0100903:	75 ea                	jne    f01008ef <mon_backtrace+0x6c>
f0100905:	8b 7d c0             	mov    -0x40(%ebp),%edi
		}
		cprintf("\n         %s:%d: %.*s+%d\n",info.eip_file , info.eip_line , info.eip_fn_namelen , info.eip_fn_name , (ebp[1]-info.eip_fn_addr));
f0100908:	83 ec 08             	sub    $0x8,%esp
f010090b:	8b 47 04             	mov    0x4(%edi),%eax
f010090e:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100911:	50                   	push   %eax
f0100912:	ff 75 d8             	pushl  -0x28(%ebp)
f0100915:	ff 75 dc             	pushl  -0x24(%ebp)
f0100918:	ff 75 d4             	pushl  -0x2c(%ebp)
f010091b:	ff 75 d0             	pushl  -0x30(%ebp)
f010091e:	8d 83 b7 0b ff ff    	lea    -0xf449(%ebx),%eax
f0100924:	50                   	push   %eax
f0100925:	e8 d2 01 00 00       	call   f0100afc <cprintf>

		ebp=(uint32_t *)(*ebp);
f010092a:	8b 3f                	mov    (%edi),%edi
f010092c:	83 c4 20             	add    $0x20,%esp
	while(ebp)
f010092f:	85 ff                	test   %edi,%edi
f0100931:	75 88                	jne    f01008bb <mon_backtrace+0x38>
	}
	return 0;
}
f0100933:	b8 00 00 00 00       	mov    $0x0,%eax
f0100938:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010093b:	5b                   	pop    %ebx
f010093c:	5e                   	pop    %esi
f010093d:	5f                   	pop    %edi
f010093e:	5d                   	pop    %ebp
f010093f:	c3                   	ret    

f0100940 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100940:	55                   	push   %ebp
f0100941:	89 e5                	mov    %esp,%ebp
f0100943:	57                   	push   %edi
f0100944:	56                   	push   %esi
f0100945:	53                   	push   %ebx
f0100946:	83 ec 68             	sub    $0x68,%esp
f0100949:	e8 6e f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010094e:	81 c3 ba 09 01 00    	add    $0x109ba,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100954:	8d 83 1c 0d ff ff    	lea    -0xf2e4(%ebx),%eax
f010095a:	50                   	push   %eax
f010095b:	e8 9c 01 00 00       	call   f0100afc <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100960:	8d 83 40 0d ff ff    	lea    -0xf2c0(%ebx),%eax
f0100966:	89 04 24             	mov    %eax,(%esp)
f0100969:	e8 8e 01 00 00       	call   f0100afc <cprintf>
f010096e:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100971:	8d bb d5 0b ff ff    	lea    -0xf42b(%ebx),%edi
f0100977:	eb 4a                	jmp    f01009c3 <monitor+0x83>
f0100979:	83 ec 08             	sub    $0x8,%esp
f010097c:	0f be c0             	movsbl %al,%eax
f010097f:	50                   	push   %eax
f0100980:	57                   	push   %edi
f0100981:	e8 71 0d 00 00       	call   f01016f7 <strchr>
f0100986:	83 c4 10             	add    $0x10,%esp
f0100989:	85 c0                	test   %eax,%eax
f010098b:	74 08                	je     f0100995 <monitor+0x55>
			*buf++ = 0;
f010098d:	c6 06 00             	movb   $0x0,(%esi)
f0100990:	8d 76 01             	lea    0x1(%esi),%esi
f0100993:	eb 79                	jmp    f0100a0e <monitor+0xce>
		if (*buf == 0)
f0100995:	80 3e 00             	cmpb   $0x0,(%esi)
f0100998:	74 7f                	je     f0100a19 <monitor+0xd9>
		if (argc == MAXARGS-1) {
f010099a:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f010099e:	74 0f                	je     f01009af <monitor+0x6f>
		argv[argc++] = buf;
f01009a0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009a3:	8d 48 01             	lea    0x1(%eax),%ecx
f01009a6:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009a9:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f01009ad:	eb 44                	jmp    f01009f3 <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009af:	83 ec 08             	sub    $0x8,%esp
f01009b2:	6a 10                	push   $0x10
f01009b4:	8d 83 da 0b ff ff    	lea    -0xf426(%ebx),%eax
f01009ba:	50                   	push   %eax
f01009bb:	e8 3c 01 00 00       	call   f0100afc <cprintf>
f01009c0:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009c3:	8d 83 d1 0b ff ff    	lea    -0xf42f(%ebx),%eax
f01009c9:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01009cc:	83 ec 0c             	sub    $0xc,%esp
f01009cf:	ff 75 a4             	pushl  -0x5c(%ebp)
f01009d2:	e8 e8 0a 00 00       	call   f01014bf <readline>
f01009d7:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009d9:	83 c4 10             	add    $0x10,%esp
f01009dc:	85 c0                	test   %eax,%eax
f01009de:	74 ec                	je     f01009cc <monitor+0x8c>
	argv[argc] = 0;
f01009e0:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009e7:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009ee:	eb 1e                	jmp    f0100a0e <monitor+0xce>
			buf++;
f01009f0:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009f3:	0f b6 06             	movzbl (%esi),%eax
f01009f6:	84 c0                	test   %al,%al
f01009f8:	74 14                	je     f0100a0e <monitor+0xce>
f01009fa:	83 ec 08             	sub    $0x8,%esp
f01009fd:	0f be c0             	movsbl %al,%eax
f0100a00:	50                   	push   %eax
f0100a01:	57                   	push   %edi
f0100a02:	e8 f0 0c 00 00       	call   f01016f7 <strchr>
f0100a07:	83 c4 10             	add    $0x10,%esp
f0100a0a:	85 c0                	test   %eax,%eax
f0100a0c:	74 e2                	je     f01009f0 <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a0e:	0f b6 06             	movzbl (%esi),%eax
f0100a11:	84 c0                	test   %al,%al
f0100a13:	0f 85 60 ff ff ff    	jne    f0100979 <monitor+0x39>
	argv[argc] = 0;
f0100a19:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a1c:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a23:	00 
	if (argc == 0)
f0100a24:	85 c0                	test   %eax,%eax
f0100a26:	74 9b                	je     f01009c3 <monitor+0x83>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a28:	83 ec 08             	sub    $0x8,%esp
f0100a2b:	8d 83 56 0b ff ff    	lea    -0xf4aa(%ebx),%eax
f0100a31:	50                   	push   %eax
f0100a32:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a35:	e8 5f 0c 00 00       	call   f0101699 <strcmp>
f0100a3a:	83 c4 10             	add    $0x10,%esp
f0100a3d:	85 c0                	test   %eax,%eax
f0100a3f:	74 38                	je     f0100a79 <monitor+0x139>
f0100a41:	83 ec 08             	sub    $0x8,%esp
f0100a44:	8d 83 64 0b ff ff    	lea    -0xf49c(%ebx),%eax
f0100a4a:	50                   	push   %eax
f0100a4b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a4e:	e8 46 0c 00 00       	call   f0101699 <strcmp>
f0100a53:	83 c4 10             	add    $0x10,%esp
f0100a56:	85 c0                	test   %eax,%eax
f0100a58:	74 1a                	je     f0100a74 <monitor+0x134>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a5a:	83 ec 08             	sub    $0x8,%esp
f0100a5d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a60:	8d 83 f7 0b ff ff    	lea    -0xf409(%ebx),%eax
f0100a66:	50                   	push   %eax
f0100a67:	e8 90 00 00 00       	call   f0100afc <cprintf>
f0100a6c:	83 c4 10             	add    $0x10,%esp
f0100a6f:	e9 4f ff ff ff       	jmp    f01009c3 <monitor+0x83>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a74:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a79:	83 ec 04             	sub    $0x4,%esp
f0100a7c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a7f:	ff 75 08             	pushl  0x8(%ebp)
f0100a82:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a85:	52                   	push   %edx
f0100a86:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a89:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a90:	83 c4 10             	add    $0x10,%esp
f0100a93:	85 c0                	test   %eax,%eax
f0100a95:	0f 89 28 ff ff ff    	jns    f01009c3 <monitor+0x83>
				break;
	}
}
f0100a9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a9e:	5b                   	pop    %ebx
f0100a9f:	5e                   	pop    %esi
f0100aa0:	5f                   	pop    %edi
f0100aa1:	5d                   	pop    %ebp
f0100aa2:	c3                   	ret    

f0100aa3 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100aa3:	55                   	push   %ebp
f0100aa4:	89 e5                	mov    %esp,%ebp
f0100aa6:	53                   	push   %ebx
f0100aa7:	83 ec 10             	sub    $0x10,%esp
f0100aaa:	e8 0d f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100aaf:	81 c3 59 08 01 00    	add    $0x10859,%ebx
	cputchar(ch);
f0100ab5:	ff 75 08             	pushl  0x8(%ebp)
f0100ab8:	e8 76 fc ff ff       	call   f0100733 <cputchar>
	*cnt++;
}
f0100abd:	83 c4 10             	add    $0x10,%esp
f0100ac0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ac3:	c9                   	leave  
f0100ac4:	c3                   	ret    

f0100ac5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100ac5:	55                   	push   %ebp
f0100ac6:	89 e5                	mov    %esp,%ebp
f0100ac8:	53                   	push   %ebx
f0100ac9:	83 ec 14             	sub    $0x14,%esp
f0100acc:	e8 eb f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100ad1:	81 c3 37 08 01 00    	add    $0x10837,%ebx
	int cnt = 0;
f0100ad7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100ade:	ff 75 0c             	pushl  0xc(%ebp)
f0100ae1:	ff 75 08             	pushl  0x8(%ebp)
f0100ae4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100ae7:	50                   	push   %eax
f0100ae8:	8d 83 9b f7 fe ff    	lea    -0x10865(%ebx),%eax
f0100aee:	50                   	push   %eax
f0100aef:	e8 bb 04 00 00       	call   f0100faf <vprintfmt>
	return cnt;
}
f0100af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100af7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100afa:	c9                   	leave  
f0100afb:	c3                   	ret    

f0100afc <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100afc:	55                   	push   %ebp
f0100afd:	89 e5                	mov    %esp,%ebp
f0100aff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b02:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b05:	50                   	push   %eax
f0100b06:	ff 75 08             	pushl  0x8(%ebp)
f0100b09:	e8 b7 ff ff ff       	call   f0100ac5 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b0e:	c9                   	leave  
f0100b0f:	c3                   	ret    

f0100b10 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b10:	55                   	push   %ebp
f0100b11:	89 e5                	mov    %esp,%ebp
f0100b13:	57                   	push   %edi
f0100b14:	56                   	push   %esi
f0100b15:	53                   	push   %ebx
f0100b16:	83 ec 14             	sub    $0x14,%esp
f0100b19:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b1c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b1f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b22:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b25:	8b 32                	mov    (%edx),%esi
f0100b27:	8b 01                	mov    (%ecx),%eax
f0100b29:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b2c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b33:	eb 2f                	jmp    f0100b64 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b35:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b38:	39 c6                	cmp    %eax,%esi
f0100b3a:	7f 49                	jg     f0100b85 <stab_binsearch+0x75>
f0100b3c:	0f b6 0a             	movzbl (%edx),%ecx
f0100b3f:	83 ea 0c             	sub    $0xc,%edx
f0100b42:	39 f9                	cmp    %edi,%ecx
f0100b44:	75 ef                	jne    f0100b35 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b46:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b49:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b4c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b50:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b53:	73 35                	jae    f0100b8a <stab_binsearch+0x7a>
			*region_left = m;
f0100b55:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b58:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100b5a:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100b5d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b64:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100b67:	7f 4e                	jg     f0100bb7 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b6c:	01 f0                	add    %esi,%eax
f0100b6e:	89 c3                	mov    %eax,%ebx
f0100b70:	c1 eb 1f             	shr    $0x1f,%ebx
f0100b73:	01 c3                	add    %eax,%ebx
f0100b75:	d1 fb                	sar    %ebx
f0100b77:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b7a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b7d:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100b81:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b83:	eb b3                	jmp    f0100b38 <stab_binsearch+0x28>
			l = true_m + 1;
f0100b85:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100b88:	eb da                	jmp    f0100b64 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100b8a:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b8d:	76 14                	jbe    f0100ba3 <stab_binsearch+0x93>
			*region_right = m - 1;
f0100b8f:	83 e8 01             	sub    $0x1,%eax
f0100b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b95:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100b98:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100b9a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100ba1:	eb c1                	jmp    f0100b64 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100ba3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ba6:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100ba8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100bac:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100bae:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bb5:	eb ad                	jmp    f0100b64 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100bb7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100bbb:	74 16                	je     f0100bd3 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100bbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bc0:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100bc2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bc5:	8b 0e                	mov    (%esi),%ecx
f0100bc7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bca:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100bcd:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100bd1:	eb 12                	jmp    f0100be5 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100bd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bd6:	8b 00                	mov    (%eax),%eax
f0100bd8:	83 e8 01             	sub    $0x1,%eax
f0100bdb:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bde:	89 07                	mov    %eax,(%edi)
f0100be0:	eb 16                	jmp    f0100bf8 <stab_binsearch+0xe8>
		     l--)
f0100be2:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100be5:	39 c1                	cmp    %eax,%ecx
f0100be7:	7d 0a                	jge    f0100bf3 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100be9:	0f b6 1a             	movzbl (%edx),%ebx
f0100bec:	83 ea 0c             	sub    $0xc,%edx
f0100bef:	39 fb                	cmp    %edi,%ebx
f0100bf1:	75 ef                	jne    f0100be2 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100bf3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bf6:	89 07                	mov    %eax,(%edi)
	}
}
f0100bf8:	83 c4 14             	add    $0x14,%esp
f0100bfb:	5b                   	pop    %ebx
f0100bfc:	5e                   	pop    %esi
f0100bfd:	5f                   	pop    %edi
f0100bfe:	5d                   	pop    %ebp
f0100bff:	c3                   	ret    

f0100c00 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c00:	55                   	push   %ebp
f0100c01:	89 e5                	mov    %esp,%ebp
f0100c03:	57                   	push   %edi
f0100c04:	56                   	push   %esi
f0100c05:	53                   	push   %ebx
f0100c06:	83 ec 3c             	sub    $0x3c,%esp
f0100c09:	e8 ae f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100c0e:	81 c3 fa 06 01 00    	add    $0x106fa,%ebx
f0100c14:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100c17:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c1a:	8d 83 68 0d ff ff    	lea    -0xf298(%ebx),%eax
f0100c20:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100c22:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100c29:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100c2c:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100c33:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100c36:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c3d:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100c43:	0f 86 46 01 00 00    	jbe    f0100d8f <debuginfo_eip+0x18f>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c49:	c7 c0 c5 5f 10 f0    	mov    $0xf0105fc5,%eax
f0100c4f:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100c55:	0f 86 2e 02 00 00    	jbe    f0100e89 <debuginfo_eip+0x289>
f0100c5b:	c7 c0 42 79 10 f0    	mov    $0xf0107942,%eax
f0100c61:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c65:	0f 85 25 02 00 00    	jne    f0100e90 <debuginfo_eip+0x290>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c6b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c72:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100c78:	c7 c2 c4 5f 10 f0    	mov    $0xf0105fc4,%edx
f0100c7e:	29 c2                	sub    %eax,%edx
f0100c80:	c1 fa 02             	sar    $0x2,%edx
f0100c83:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100c89:	83 ea 01             	sub    $0x1,%edx
f0100c8c:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c8f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c92:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c95:	83 ec 08             	sub    $0x8,%esp
f0100c98:	57                   	push   %edi
f0100c99:	6a 64                	push   $0x64
f0100c9b:	e8 70 fe ff ff       	call   f0100b10 <stab_binsearch>
	if (lfile == 0)
f0100ca0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ca3:	83 c4 10             	add    $0x10,%esp
f0100ca6:	85 c0                	test   %eax,%eax
f0100ca8:	0f 84 e9 01 00 00    	je     f0100e97 <debuginfo_eip+0x297>
		return -1;
	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100cae:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cb4:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100cb7:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100cba:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cbd:	83 ec 08             	sub    $0x8,%esp
f0100cc0:	57                   	push   %edi
f0100cc1:	6a 24                	push   $0x24
f0100cc3:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100cc9:	e8 42 fe ff ff       	call   f0100b10 <stab_binsearch>

	if (lfun <= rfun) {
f0100cce:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cd1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100cd4:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100cd7:	83 c4 10             	add    $0x10,%esp
f0100cda:	39 c8                	cmp    %ecx,%eax
f0100cdc:	0f 8f c5 00 00 00    	jg     f0100da7 <debuginfo_eip+0x1a7>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100ce2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ce5:	c7 c1 8c 22 10 f0    	mov    $0xf010228c,%ecx
f0100ceb:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100cee:	8b 11                	mov    (%ecx),%edx
f0100cf0:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100cf3:	c7 c2 42 79 10 f0    	mov    $0xf0107942,%edx
f0100cf9:	81 ea c5 5f 10 f0    	sub    $0xf0105fc5,%edx
f0100cff:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0100d02:	73 0c                	jae    f0100d10 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d04:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100d07:	81 c2 c5 5f 10 f0    	add    $0xf0105fc5,%edx
f0100d0d:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d10:	8b 51 08             	mov    0x8(%ecx),%edx
f0100d13:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100d16:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100d18:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d1b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100d1e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d21:	83 ec 08             	sub    $0x8,%esp
f0100d24:	6a 3a                	push   $0x3a
f0100d26:	ff 76 08             	pushl  0x8(%esi)
f0100d29:	e8 ea 09 00 00       	call   f0101718 <strfind>
f0100d2e:	2b 46 08             	sub    0x8(%esi),%eax
f0100d31:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	info->eip_file=stabstr+stabs[lfile].n_strx;
f0100d34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d37:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d3a:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100d40:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100d43:	81 c2 c5 5f 10 f0    	add    $0xf0105fc5,%edx
f0100d49:	89 16                	mov    %edx,(%esi)
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f0100d4b:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d4e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d51:	83 c4 08             	add    $0x8,%esp
f0100d54:	57                   	push   %edi
f0100d55:	6a 44                	push   $0x44
f0100d57:	e8 b4 fd ff ff       	call   f0100b10 <stab_binsearch>
	if(lline>rline)
f0100d5c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100d5f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100d62:	83 c4 10             	add    $0x10,%esp
f0100d65:	39 c2                	cmp    %eax,%edx
f0100d67:	7f 52                	jg     f0100dbb <debuginfo_eip+0x1bb>
	{
		info->eip_line=stabs[rline].n_desc;
		return -1;
	}else
	{
		info->eip_line=stabs[rline].n_desc;
f0100d69:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100d6c:	c7 c1 8c 22 10 f0    	mov    $0xf010228c,%ecx
f0100d72:	0f b7 44 81 06       	movzwl 0x6(%ecx,%eax,4),%eax
f0100d77:	89 46 04             	mov    %eax,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d7d:	89 d0                	mov    %edx,%eax
f0100d7f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100d82:	8d 54 91 04          	lea    0x4(%ecx,%edx,4),%edx
f0100d86:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0100d8a:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100d8d:	eb 51                	jmp    f0100de0 <debuginfo_eip+0x1e0>
  	        panic("User address");
f0100d8f:	83 ec 04             	sub    $0x4,%esp
f0100d92:	8d 83 72 0d ff ff    	lea    -0xf28e(%ebx),%eax
f0100d98:	50                   	push   %eax
f0100d99:	6a 7f                	push   $0x7f
f0100d9b:	8d 83 7f 0d ff ff    	lea    -0xf281(%ebx),%eax
f0100da1:	50                   	push   %eax
f0100da2:	e8 5f f3 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100da7:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100daa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100dad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100db0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100db3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100db6:	e9 66 ff ff ff       	jmp    f0100d21 <debuginfo_eip+0x121>
		info->eip_line=stabs[rline].n_desc;
f0100dbb:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100dbe:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100dc4:	0f b7 44 90 06       	movzwl 0x6(%eax,%edx,4),%eax
f0100dc9:	89 46 04             	mov    %eax,0x4(%esi)
		return -1;
f0100dcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100dd1:	e9 cd 00 00 00       	jmp    f0100ea3 <debuginfo_eip+0x2a3>
f0100dd6:	83 e8 01             	sub    $0x1,%eax
f0100dd9:	83 ea 0c             	sub    $0xc,%edx
f0100ddc:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0100de0:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0100de3:	39 c7                	cmp    %eax,%edi
f0100de5:	7f 24                	jg     f0100e0b <debuginfo_eip+0x20b>
	       && stabs[lline].n_type != N_SOL
f0100de7:	0f b6 0a             	movzbl (%edx),%ecx
f0100dea:	80 f9 84             	cmp    $0x84,%cl
f0100ded:	74 46                	je     f0100e35 <debuginfo_eip+0x235>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100def:	80 f9 64             	cmp    $0x64,%cl
f0100df2:	75 e2                	jne    f0100dd6 <debuginfo_eip+0x1d6>
f0100df4:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0100df8:	74 dc                	je     f0100dd6 <debuginfo_eip+0x1d6>
f0100dfa:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100dfd:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100e01:	74 3b                	je     f0100e3e <debuginfo_eip+0x23e>
f0100e03:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100e06:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e09:	eb 33                	jmp    f0100e3e <debuginfo_eip+0x23e>
f0100e0b:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e0e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e11:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e14:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100e19:	39 fa                	cmp    %edi,%edx
f0100e1b:	0f 8d 82 00 00 00    	jge    f0100ea3 <debuginfo_eip+0x2a3>
		for (lline = lfun + 1;
f0100e21:	83 c2 01             	add    $0x1,%edx
f0100e24:	89 d0                	mov    %edx,%eax
f0100e26:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100e29:	c7 c2 8c 22 10 f0    	mov    $0xf010228c,%edx
f0100e2f:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100e33:	eb 3b                	jmp    f0100e70 <debuginfo_eip+0x270>
f0100e35:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e38:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100e3c:	75 26                	jne    f0100e64 <debuginfo_eip+0x264>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e3e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e41:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100e47:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e4a:	c7 c0 42 79 10 f0    	mov    $0xf0107942,%eax
f0100e50:	81 e8 c5 5f 10 f0    	sub    $0xf0105fc5,%eax
f0100e56:	39 c2                	cmp    %eax,%edx
f0100e58:	73 b4                	jae    f0100e0e <debuginfo_eip+0x20e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e5a:	81 c2 c5 5f 10 f0    	add    $0xf0105fc5,%edx
f0100e60:	89 16                	mov    %edx,(%esi)
f0100e62:	eb aa                	jmp    f0100e0e <debuginfo_eip+0x20e>
f0100e64:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100e67:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e6a:	eb d2                	jmp    f0100e3e <debuginfo_eip+0x23e>
			info->eip_fn_narg++;
f0100e6c:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100e70:	39 c7                	cmp    %eax,%edi
f0100e72:	7e 2a                	jle    f0100e9e <debuginfo_eip+0x29e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e74:	0f b6 0a             	movzbl (%edx),%ecx
f0100e77:	83 c0 01             	add    $0x1,%eax
f0100e7a:	83 c2 0c             	add    $0xc,%edx
f0100e7d:	80 f9 a0             	cmp    $0xa0,%cl
f0100e80:	74 ea                	je     f0100e6c <debuginfo_eip+0x26c>
	return 0;
f0100e82:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e87:	eb 1a                	jmp    f0100ea3 <debuginfo_eip+0x2a3>
		return -1;
f0100e89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e8e:	eb 13                	jmp    f0100ea3 <debuginfo_eip+0x2a3>
f0100e90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e95:	eb 0c                	jmp    f0100ea3 <debuginfo_eip+0x2a3>
		return -1;
f0100e97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e9c:	eb 05                	jmp    f0100ea3 <debuginfo_eip+0x2a3>
	return 0;
f0100e9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ea3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ea6:	5b                   	pop    %ebx
f0100ea7:	5e                   	pop    %esi
f0100ea8:	5f                   	pop    %edi
f0100ea9:	5d                   	pop    %ebp
f0100eaa:	c3                   	ret    

f0100eab <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100eab:	55                   	push   %ebp
f0100eac:	89 e5                	mov    %esp,%ebp
f0100eae:	57                   	push   %edi
f0100eaf:	56                   	push   %esi
f0100eb0:	53                   	push   %ebx
f0100eb1:	83 ec 2c             	sub    $0x2c,%esp
f0100eb4:	e8 02 06 00 00       	call   f01014bb <__x86.get_pc_thunk.cx>
f0100eb9:	81 c1 4f 04 01 00    	add    $0x1044f,%ecx
f0100ebf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100ec2:	89 c7                	mov    %eax,%edi
f0100ec4:	89 d6                	mov    %edx,%esi
f0100ec6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ec9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ecc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ecf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ed2:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100ed5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100eda:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100edd:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100ee0:	39 d3                	cmp    %edx,%ebx
f0100ee2:	72 09                	jb     f0100eed <printnum+0x42>
f0100ee4:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100ee7:	0f 87 83 00 00 00    	ja     f0100f70 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100eed:	83 ec 0c             	sub    $0xc,%esp
f0100ef0:	ff 75 18             	pushl  0x18(%ebp)
f0100ef3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ef6:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100ef9:	53                   	push   %ebx
f0100efa:	ff 75 10             	pushl  0x10(%ebp)
f0100efd:	83 ec 08             	sub    $0x8,%esp
f0100f00:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f03:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f06:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f09:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f0c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100f0f:	e8 1c 0a 00 00       	call   f0101930 <__udivdi3>
f0100f14:	83 c4 18             	add    $0x18,%esp
f0100f17:	52                   	push   %edx
f0100f18:	50                   	push   %eax
f0100f19:	89 f2                	mov    %esi,%edx
f0100f1b:	89 f8                	mov    %edi,%eax
f0100f1d:	e8 89 ff ff ff       	call   f0100eab <printnum>
f0100f22:	83 c4 20             	add    $0x20,%esp
f0100f25:	eb 13                	jmp    f0100f3a <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f27:	83 ec 08             	sub    $0x8,%esp
f0100f2a:	56                   	push   %esi
f0100f2b:	ff 75 18             	pushl  0x18(%ebp)
f0100f2e:	ff d7                	call   *%edi
f0100f30:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f33:	83 eb 01             	sub    $0x1,%ebx
f0100f36:	85 db                	test   %ebx,%ebx
f0100f38:	7f ed                	jg     f0100f27 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f3a:	83 ec 08             	sub    $0x8,%esp
f0100f3d:	56                   	push   %esi
f0100f3e:	83 ec 04             	sub    $0x4,%esp
f0100f41:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f44:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f47:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f4a:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f4d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f50:	89 f3                	mov    %esi,%ebx
f0100f52:	e8 f9 0a 00 00       	call   f0101a50 <__umoddi3>
f0100f57:	83 c4 14             	add    $0x14,%esp
f0100f5a:	0f be 84 06 8d 0d ff 	movsbl -0xf273(%esi,%eax,1),%eax
f0100f61:	ff 
f0100f62:	50                   	push   %eax
f0100f63:	ff d7                	call   *%edi
}
f0100f65:	83 c4 10             	add    $0x10,%esp
f0100f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f6b:	5b                   	pop    %ebx
f0100f6c:	5e                   	pop    %esi
f0100f6d:	5f                   	pop    %edi
f0100f6e:	5d                   	pop    %ebp
f0100f6f:	c3                   	ret    
f0100f70:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100f73:	eb be                	jmp    f0100f33 <printnum+0x88>

f0100f75 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f75:	55                   	push   %ebp
f0100f76:	89 e5                	mov    %esp,%ebp
f0100f78:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f7b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f7f:	8b 10                	mov    (%eax),%edx
f0100f81:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f84:	73 0a                	jae    f0100f90 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f86:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f89:	89 08                	mov    %ecx,(%eax)
f0100f8b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f8e:	88 02                	mov    %al,(%edx)
}
f0100f90:	5d                   	pop    %ebp
f0100f91:	c3                   	ret    

f0100f92 <printfmt>:
{
f0100f92:	55                   	push   %ebp
f0100f93:	89 e5                	mov    %esp,%ebp
f0100f95:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f98:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f9b:	50                   	push   %eax
f0100f9c:	ff 75 10             	pushl  0x10(%ebp)
f0100f9f:	ff 75 0c             	pushl  0xc(%ebp)
f0100fa2:	ff 75 08             	pushl  0x8(%ebp)
f0100fa5:	e8 05 00 00 00       	call   f0100faf <vprintfmt>
}
f0100faa:	83 c4 10             	add    $0x10,%esp
f0100fad:	c9                   	leave  
f0100fae:	c3                   	ret    

f0100faf <vprintfmt>:
{
f0100faf:	55                   	push   %ebp
f0100fb0:	89 e5                	mov    %esp,%ebp
f0100fb2:	57                   	push   %edi
f0100fb3:	56                   	push   %esi
f0100fb4:	53                   	push   %ebx
f0100fb5:	83 ec 2c             	sub    $0x2c,%esp
f0100fb8:	e8 ff f1 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100fbd:	81 c3 4b 03 01 00    	add    $0x1034b,%ebx
f0100fc3:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100fc6:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100fc9:	e9 c3 03 00 00       	jmp    f0101391 <.L35+0x48>
		padc = ' ';
f0100fce:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100fd2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100fd9:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0100fe0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100fe7:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fec:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100fef:	8d 47 01             	lea    0x1(%edi),%eax
f0100ff2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100ff5:	0f b6 17             	movzbl (%edi),%edx
f0100ff8:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100ffb:	3c 55                	cmp    $0x55,%al
f0100ffd:	0f 87 16 04 00 00    	ja     f0101419 <.L22>
f0101003:	0f b6 c0             	movzbl %al,%eax
f0101006:	89 d9                	mov    %ebx,%ecx
f0101008:	03 8c 83 1c 0e ff ff 	add    -0xf1e4(%ebx,%eax,4),%ecx
f010100f:	ff e1                	jmp    *%ecx

f0101011 <.L69>:
f0101011:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0101014:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0101018:	eb d5                	jmp    f0100fef <vprintfmt+0x40>

f010101a <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f010101a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f010101d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101021:	eb cc                	jmp    f0100fef <vprintfmt+0x40>

f0101023 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0101023:	0f b6 d2             	movzbl %dl,%edx
f0101026:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0101029:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f010102e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101031:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0101035:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0101038:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010103b:	83 f9 09             	cmp    $0x9,%ecx
f010103e:	77 55                	ja     f0101095 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0101040:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0101043:	eb e9                	jmp    f010102e <.L29+0xb>

f0101045 <.L26>:
			precision = va_arg(ap, int);
f0101045:	8b 45 14             	mov    0x14(%ebp),%eax
f0101048:	8b 00                	mov    (%eax),%eax
f010104a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010104d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101050:	8d 40 04             	lea    0x4(%eax),%eax
f0101053:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101056:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0101059:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010105d:	79 90                	jns    f0100fef <vprintfmt+0x40>
				width = precision, precision = -1;
f010105f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101062:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101065:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f010106c:	eb 81                	jmp    f0100fef <vprintfmt+0x40>

f010106e <.L27>:
f010106e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101071:	85 c0                	test   %eax,%eax
f0101073:	ba 00 00 00 00       	mov    $0x0,%edx
f0101078:	0f 49 d0             	cmovns %eax,%edx
f010107b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010107e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101081:	e9 69 ff ff ff       	jmp    f0100fef <vprintfmt+0x40>

f0101086 <.L23>:
f0101086:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0101089:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101090:	e9 5a ff ff ff       	jmp    f0100fef <vprintfmt+0x40>
f0101095:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101098:	eb bf                	jmp    f0101059 <.L26+0x14>

f010109a <.L33>:
			lflag++;
f010109a:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010109e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01010a1:	e9 49 ff ff ff       	jmp    f0100fef <vprintfmt+0x40>

f01010a6 <.L30>:
			putch(va_arg(ap, int), putdat);
f01010a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a9:	8d 78 04             	lea    0x4(%eax),%edi
f01010ac:	83 ec 08             	sub    $0x8,%esp
f01010af:	56                   	push   %esi
f01010b0:	ff 30                	pushl  (%eax)
f01010b2:	ff 55 08             	call   *0x8(%ebp)
			break;
f01010b5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01010b8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01010bb:	e9 ce 02 00 00       	jmp    f010138e <.L35+0x45>

f01010c0 <.L32>:
			err = va_arg(ap, int);
f01010c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c3:	8d 78 04             	lea    0x4(%eax),%edi
f01010c6:	8b 00                	mov    (%eax),%eax
f01010c8:	99                   	cltd   
f01010c9:	31 d0                	xor    %edx,%eax
f01010cb:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01010cd:	83 f8 06             	cmp    $0x6,%eax
f01010d0:	7f 27                	jg     f01010f9 <.L32+0x39>
f01010d2:	8b 94 83 20 1d 00 00 	mov    0x1d20(%ebx,%eax,4),%edx
f01010d9:	85 d2                	test   %edx,%edx
f01010db:	74 1c                	je     f01010f9 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f01010dd:	52                   	push   %edx
f01010de:	8d 83 ae 0d ff ff    	lea    -0xf252(%ebx),%eax
f01010e4:	50                   	push   %eax
f01010e5:	56                   	push   %esi
f01010e6:	ff 75 08             	pushl  0x8(%ebp)
f01010e9:	e8 a4 fe ff ff       	call   f0100f92 <printfmt>
f01010ee:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010f1:	89 7d 14             	mov    %edi,0x14(%ebp)
f01010f4:	e9 95 02 00 00       	jmp    f010138e <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f01010f9:	50                   	push   %eax
f01010fa:	8d 83 a5 0d ff ff    	lea    -0xf25b(%ebx),%eax
f0101100:	50                   	push   %eax
f0101101:	56                   	push   %esi
f0101102:	ff 75 08             	pushl  0x8(%ebp)
f0101105:	e8 88 fe ff ff       	call   f0100f92 <printfmt>
f010110a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010110d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101110:	e9 79 02 00 00       	jmp    f010138e <.L35+0x45>

f0101115 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0101115:	8b 45 14             	mov    0x14(%ebp),%eax
f0101118:	83 c0 04             	add    $0x4,%eax
f010111b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010111e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101121:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0101123:	85 ff                	test   %edi,%edi
f0101125:	8d 83 9e 0d ff ff    	lea    -0xf262(%ebx),%eax
f010112b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010112e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101132:	0f 8e b5 00 00 00    	jle    f01011ed <.L36+0xd8>
f0101138:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010113c:	75 08                	jne    f0101146 <.L36+0x31>
f010113e:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101141:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101144:	eb 6d                	jmp    f01011b3 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101146:	83 ec 08             	sub    $0x8,%esp
f0101149:	ff 75 cc             	pushl  -0x34(%ebp)
f010114c:	57                   	push   %edi
f010114d:	e8 82 04 00 00       	call   f01015d4 <strnlen>
f0101152:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101155:	29 c2                	sub    %eax,%edx
f0101157:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010115a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010115d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101161:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101164:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101167:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101169:	eb 10                	jmp    f010117b <.L36+0x66>
					putch(padc, putdat);
f010116b:	83 ec 08             	sub    $0x8,%esp
f010116e:	56                   	push   %esi
f010116f:	ff 75 e0             	pushl  -0x20(%ebp)
f0101172:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101175:	83 ef 01             	sub    $0x1,%edi
f0101178:	83 c4 10             	add    $0x10,%esp
f010117b:	85 ff                	test   %edi,%edi
f010117d:	7f ec                	jg     f010116b <.L36+0x56>
f010117f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101182:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0101185:	85 d2                	test   %edx,%edx
f0101187:	b8 00 00 00 00       	mov    $0x0,%eax
f010118c:	0f 49 c2             	cmovns %edx,%eax
f010118f:	29 c2                	sub    %eax,%edx
f0101191:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101194:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101197:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010119a:	eb 17                	jmp    f01011b3 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f010119c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01011a0:	75 30                	jne    f01011d2 <.L36+0xbd>
					putch(ch, putdat);
f01011a2:	83 ec 08             	sub    $0x8,%esp
f01011a5:	ff 75 0c             	pushl  0xc(%ebp)
f01011a8:	50                   	push   %eax
f01011a9:	ff 55 08             	call   *0x8(%ebp)
f01011ac:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011af:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01011b3:	83 c7 01             	add    $0x1,%edi
f01011b6:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01011ba:	0f be c2             	movsbl %dl,%eax
f01011bd:	85 c0                	test   %eax,%eax
f01011bf:	74 52                	je     f0101213 <.L36+0xfe>
f01011c1:	85 f6                	test   %esi,%esi
f01011c3:	78 d7                	js     f010119c <.L36+0x87>
f01011c5:	83 ee 01             	sub    $0x1,%esi
f01011c8:	79 d2                	jns    f010119c <.L36+0x87>
f01011ca:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011cd:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01011d0:	eb 32                	jmp    f0101204 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f01011d2:	0f be d2             	movsbl %dl,%edx
f01011d5:	83 ea 20             	sub    $0x20,%edx
f01011d8:	83 fa 5e             	cmp    $0x5e,%edx
f01011db:	76 c5                	jbe    f01011a2 <.L36+0x8d>
					putch('?', putdat);
f01011dd:	83 ec 08             	sub    $0x8,%esp
f01011e0:	ff 75 0c             	pushl  0xc(%ebp)
f01011e3:	6a 3f                	push   $0x3f
f01011e5:	ff 55 08             	call   *0x8(%ebp)
f01011e8:	83 c4 10             	add    $0x10,%esp
f01011eb:	eb c2                	jmp    f01011af <.L36+0x9a>
f01011ed:	89 75 0c             	mov    %esi,0xc(%ebp)
f01011f0:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01011f3:	eb be                	jmp    f01011b3 <.L36+0x9e>
				putch(' ', putdat);
f01011f5:	83 ec 08             	sub    $0x8,%esp
f01011f8:	56                   	push   %esi
f01011f9:	6a 20                	push   $0x20
f01011fb:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f01011fe:	83 ef 01             	sub    $0x1,%edi
f0101201:	83 c4 10             	add    $0x10,%esp
f0101204:	85 ff                	test   %edi,%edi
f0101206:	7f ed                	jg     f01011f5 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f0101208:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010120b:	89 45 14             	mov    %eax,0x14(%ebp)
f010120e:	e9 7b 01 00 00       	jmp    f010138e <.L35+0x45>
f0101213:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101216:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101219:	eb e9                	jmp    f0101204 <.L36+0xef>

f010121b <.L31>:
f010121b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010121e:	83 f9 01             	cmp    $0x1,%ecx
f0101221:	7e 40                	jle    f0101263 <.L31+0x48>
		return va_arg(*ap, long long);
f0101223:	8b 45 14             	mov    0x14(%ebp),%eax
f0101226:	8b 50 04             	mov    0x4(%eax),%edx
f0101229:	8b 00                	mov    (%eax),%eax
f010122b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010122e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101231:	8b 45 14             	mov    0x14(%ebp),%eax
f0101234:	8d 40 08             	lea    0x8(%eax),%eax
f0101237:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010123a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010123e:	79 55                	jns    f0101295 <.L31+0x7a>
				putch('-', putdat);
f0101240:	83 ec 08             	sub    $0x8,%esp
f0101243:	56                   	push   %esi
f0101244:	6a 2d                	push   $0x2d
f0101246:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101249:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010124c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010124f:	f7 da                	neg    %edx
f0101251:	83 d1 00             	adc    $0x0,%ecx
f0101254:	f7 d9                	neg    %ecx
f0101256:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101259:	b8 0a 00 00 00       	mov    $0xa,%eax
f010125e:	e9 10 01 00 00       	jmp    f0101373 <.L35+0x2a>
	else if (lflag)
f0101263:	85 c9                	test   %ecx,%ecx
f0101265:	75 17                	jne    f010127e <.L31+0x63>
		return va_arg(*ap, int);
f0101267:	8b 45 14             	mov    0x14(%ebp),%eax
f010126a:	8b 00                	mov    (%eax),%eax
f010126c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010126f:	99                   	cltd   
f0101270:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101273:	8b 45 14             	mov    0x14(%ebp),%eax
f0101276:	8d 40 04             	lea    0x4(%eax),%eax
f0101279:	89 45 14             	mov    %eax,0x14(%ebp)
f010127c:	eb bc                	jmp    f010123a <.L31+0x1f>
		return va_arg(*ap, long);
f010127e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101281:	8b 00                	mov    (%eax),%eax
f0101283:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101286:	99                   	cltd   
f0101287:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010128a:	8b 45 14             	mov    0x14(%ebp),%eax
f010128d:	8d 40 04             	lea    0x4(%eax),%eax
f0101290:	89 45 14             	mov    %eax,0x14(%ebp)
f0101293:	eb a5                	jmp    f010123a <.L31+0x1f>
			num = getint(&ap, lflag);
f0101295:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101298:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010129b:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012a0:	e9 ce 00 00 00       	jmp    f0101373 <.L35+0x2a>

f01012a5 <.L37>:
f01012a5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01012a8:	83 f9 01             	cmp    $0x1,%ecx
f01012ab:	7e 18                	jle    f01012c5 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f01012ad:	8b 45 14             	mov    0x14(%ebp),%eax
f01012b0:	8b 10                	mov    (%eax),%edx
f01012b2:	8b 48 04             	mov    0x4(%eax),%ecx
f01012b5:	8d 40 08             	lea    0x8(%eax),%eax
f01012b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012bb:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012c0:	e9 ae 00 00 00       	jmp    f0101373 <.L35+0x2a>
	else if (lflag)
f01012c5:	85 c9                	test   %ecx,%ecx
f01012c7:	75 1a                	jne    f01012e3 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f01012c9:	8b 45 14             	mov    0x14(%ebp),%eax
f01012cc:	8b 10                	mov    (%eax),%edx
f01012ce:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012d3:	8d 40 04             	lea    0x4(%eax),%eax
f01012d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012d9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012de:	e9 90 00 00 00       	jmp    f0101373 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01012e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e6:	8b 10                	mov    (%eax),%edx
f01012e8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012ed:	8d 40 04             	lea    0x4(%eax),%eax
f01012f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012f3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012f8:	eb 79                	jmp    f0101373 <.L35+0x2a>

f01012fa <.L34>:
f01012fa:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01012fd:	83 f9 01             	cmp    $0x1,%ecx
f0101300:	7e 15                	jle    f0101317 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f0101302:	8b 45 14             	mov    0x14(%ebp),%eax
f0101305:	8b 10                	mov    (%eax),%edx
f0101307:	8b 48 04             	mov    0x4(%eax),%ecx
f010130a:	8d 40 08             	lea    0x8(%eax),%eax
f010130d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0101310:	b8 08 00 00 00       	mov    $0x8,%eax
f0101315:	eb 5c                	jmp    f0101373 <.L35+0x2a>
	else if (lflag)
f0101317:	85 c9                	test   %ecx,%ecx
f0101319:	75 17                	jne    f0101332 <.L34+0x38>
		return va_arg(*ap, unsigned int);
f010131b:	8b 45 14             	mov    0x14(%ebp),%eax
f010131e:	8b 10                	mov    (%eax),%edx
f0101320:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101325:	8d 40 04             	lea    0x4(%eax),%eax
f0101328:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f010132b:	b8 08 00 00 00       	mov    $0x8,%eax
f0101330:	eb 41                	jmp    f0101373 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0101332:	8b 45 14             	mov    0x14(%ebp),%eax
f0101335:	8b 10                	mov    (%eax),%edx
f0101337:	b9 00 00 00 00       	mov    $0x0,%ecx
f010133c:	8d 40 04             	lea    0x4(%eax),%eax
f010133f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0101342:	b8 08 00 00 00       	mov    $0x8,%eax
f0101347:	eb 2a                	jmp    f0101373 <.L35+0x2a>

f0101349 <.L35>:
			putch('0', putdat);
f0101349:	83 ec 08             	sub    $0x8,%esp
f010134c:	56                   	push   %esi
f010134d:	6a 30                	push   $0x30
f010134f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101352:	83 c4 08             	add    $0x8,%esp
f0101355:	56                   	push   %esi
f0101356:	6a 78                	push   $0x78
f0101358:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f010135b:	8b 45 14             	mov    0x14(%ebp),%eax
f010135e:	8b 10                	mov    (%eax),%edx
f0101360:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0101365:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101368:	8d 40 04             	lea    0x4(%eax),%eax
f010136b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010136e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101373:	83 ec 0c             	sub    $0xc,%esp
f0101376:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010137a:	57                   	push   %edi
f010137b:	ff 75 e0             	pushl  -0x20(%ebp)
f010137e:	50                   	push   %eax
f010137f:	51                   	push   %ecx
f0101380:	52                   	push   %edx
f0101381:	89 f2                	mov    %esi,%edx
f0101383:	8b 45 08             	mov    0x8(%ebp),%eax
f0101386:	e8 20 fb ff ff       	call   f0100eab <printnum>
			break;
f010138b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010138e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101391:	83 c7 01             	add    $0x1,%edi
f0101394:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101398:	83 f8 25             	cmp    $0x25,%eax
f010139b:	0f 84 2d fc ff ff    	je     f0100fce <vprintfmt+0x1f>
			if (ch == '\0')
f01013a1:	85 c0                	test   %eax,%eax
f01013a3:	0f 84 91 00 00 00    	je     f010143a <.L22+0x21>
			putch(ch, putdat);
f01013a9:	83 ec 08             	sub    $0x8,%esp
f01013ac:	56                   	push   %esi
f01013ad:	50                   	push   %eax
f01013ae:	ff 55 08             	call   *0x8(%ebp)
f01013b1:	83 c4 10             	add    $0x10,%esp
f01013b4:	eb db                	jmp    f0101391 <.L35+0x48>

f01013b6 <.L38>:
f01013b6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01013b9:	83 f9 01             	cmp    $0x1,%ecx
f01013bc:	7e 15                	jle    f01013d3 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f01013be:	8b 45 14             	mov    0x14(%ebp),%eax
f01013c1:	8b 10                	mov    (%eax),%edx
f01013c3:	8b 48 04             	mov    0x4(%eax),%ecx
f01013c6:	8d 40 08             	lea    0x8(%eax),%eax
f01013c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013cc:	b8 10 00 00 00       	mov    $0x10,%eax
f01013d1:	eb a0                	jmp    f0101373 <.L35+0x2a>
	else if (lflag)
f01013d3:	85 c9                	test   %ecx,%ecx
f01013d5:	75 17                	jne    f01013ee <.L38+0x38>
		return va_arg(*ap, unsigned int);
f01013d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01013da:	8b 10                	mov    (%eax),%edx
f01013dc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013e1:	8d 40 04             	lea    0x4(%eax),%eax
f01013e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013e7:	b8 10 00 00 00       	mov    $0x10,%eax
f01013ec:	eb 85                	jmp    f0101373 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01013ee:	8b 45 14             	mov    0x14(%ebp),%eax
f01013f1:	8b 10                	mov    (%eax),%edx
f01013f3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013f8:	8d 40 04             	lea    0x4(%eax),%eax
f01013fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013fe:	b8 10 00 00 00       	mov    $0x10,%eax
f0101403:	e9 6b ff ff ff       	jmp    f0101373 <.L35+0x2a>

f0101408 <.L25>:
			putch(ch, putdat);
f0101408:	83 ec 08             	sub    $0x8,%esp
f010140b:	56                   	push   %esi
f010140c:	6a 25                	push   $0x25
f010140e:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101411:	83 c4 10             	add    $0x10,%esp
f0101414:	e9 75 ff ff ff       	jmp    f010138e <.L35+0x45>

f0101419 <.L22>:
			putch('%', putdat);
f0101419:	83 ec 08             	sub    $0x8,%esp
f010141c:	56                   	push   %esi
f010141d:	6a 25                	push   $0x25
f010141f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101422:	83 c4 10             	add    $0x10,%esp
f0101425:	89 f8                	mov    %edi,%eax
f0101427:	eb 03                	jmp    f010142c <.L22+0x13>
f0101429:	83 e8 01             	sub    $0x1,%eax
f010142c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101430:	75 f7                	jne    f0101429 <.L22+0x10>
f0101432:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101435:	e9 54 ff ff ff       	jmp    f010138e <.L35+0x45>
}
f010143a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010143d:	5b                   	pop    %ebx
f010143e:	5e                   	pop    %esi
f010143f:	5f                   	pop    %edi
f0101440:	5d                   	pop    %ebp
f0101441:	c3                   	ret    

f0101442 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101442:	55                   	push   %ebp
f0101443:	89 e5                	mov    %esp,%ebp
f0101445:	53                   	push   %ebx
f0101446:	83 ec 14             	sub    $0x14,%esp
f0101449:	e8 6e ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010144e:	81 c3 ba fe 00 00    	add    $0xfeba,%ebx
f0101454:	8b 45 08             	mov    0x8(%ebp),%eax
f0101457:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010145a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010145d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101461:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101464:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010146b:	85 c0                	test   %eax,%eax
f010146d:	74 2b                	je     f010149a <vsnprintf+0x58>
f010146f:	85 d2                	test   %edx,%edx
f0101471:	7e 27                	jle    f010149a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101473:	ff 75 14             	pushl  0x14(%ebp)
f0101476:	ff 75 10             	pushl  0x10(%ebp)
f0101479:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010147c:	50                   	push   %eax
f010147d:	8d 83 6d fc fe ff    	lea    -0x10393(%ebx),%eax
f0101483:	50                   	push   %eax
f0101484:	e8 26 fb ff ff       	call   f0100faf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101489:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010148c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010148f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101492:	83 c4 10             	add    $0x10,%esp
}
f0101495:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101498:	c9                   	leave  
f0101499:	c3                   	ret    
		return -E_INVAL;
f010149a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010149f:	eb f4                	jmp    f0101495 <vsnprintf+0x53>

f01014a1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01014a1:	55                   	push   %ebp
f01014a2:	89 e5                	mov    %esp,%ebp
f01014a4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01014a7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01014aa:	50                   	push   %eax
f01014ab:	ff 75 10             	pushl  0x10(%ebp)
f01014ae:	ff 75 0c             	pushl  0xc(%ebp)
f01014b1:	ff 75 08             	pushl  0x8(%ebp)
f01014b4:	e8 89 ff ff ff       	call   f0101442 <vsnprintf>
	va_end(ap);

	return rc;
}
f01014b9:	c9                   	leave  
f01014ba:	c3                   	ret    

f01014bb <__x86.get_pc_thunk.cx>:
f01014bb:	8b 0c 24             	mov    (%esp),%ecx
f01014be:	c3                   	ret    

f01014bf <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014bf:	55                   	push   %ebp
f01014c0:	89 e5                	mov    %esp,%ebp
f01014c2:	57                   	push   %edi
f01014c3:	56                   	push   %esi
f01014c4:	53                   	push   %ebx
f01014c5:	83 ec 1c             	sub    $0x1c,%esp
f01014c8:	e8 ef ec ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01014cd:	81 c3 3b fe 00 00    	add    $0xfe3b,%ebx
f01014d3:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014d6:	85 c0                	test   %eax,%eax
f01014d8:	74 13                	je     f01014ed <readline+0x2e>
		cprintf("%s", prompt);
f01014da:	83 ec 08             	sub    $0x8,%esp
f01014dd:	50                   	push   %eax
f01014de:	8d 83 ae 0d ff ff    	lea    -0xf252(%ebx),%eax
f01014e4:	50                   	push   %eax
f01014e5:	e8 12 f6 ff ff       	call   f0100afc <cprintf>
f01014ea:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01014ed:	83 ec 0c             	sub    $0xc,%esp
f01014f0:	6a 00                	push   $0x0
f01014f2:	e8 5d f2 ff ff       	call   f0100754 <iscons>
f01014f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014fa:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01014fd:	bf 00 00 00 00       	mov    $0x0,%edi
f0101502:	eb 46                	jmp    f010154a <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0101504:	83 ec 08             	sub    $0x8,%esp
f0101507:	50                   	push   %eax
f0101508:	8d 83 74 0f ff ff    	lea    -0xf08c(%ebx),%eax
f010150e:	50                   	push   %eax
f010150f:	e8 e8 f5 ff ff       	call   f0100afc <cprintf>
			return NULL;
f0101514:	83 c4 10             	add    $0x10,%esp
f0101517:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010151c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010151f:	5b                   	pop    %ebx
f0101520:	5e                   	pop    %esi
f0101521:	5f                   	pop    %edi
f0101522:	5d                   	pop    %ebp
f0101523:	c3                   	ret    
			if (echoing)
f0101524:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101528:	75 05                	jne    f010152f <readline+0x70>
			i--;
f010152a:	83 ef 01             	sub    $0x1,%edi
f010152d:	eb 1b                	jmp    f010154a <readline+0x8b>
				cputchar('\b');
f010152f:	83 ec 0c             	sub    $0xc,%esp
f0101532:	6a 08                	push   $0x8
f0101534:	e8 fa f1 ff ff       	call   f0100733 <cputchar>
f0101539:	83 c4 10             	add    $0x10,%esp
f010153c:	eb ec                	jmp    f010152a <readline+0x6b>
			buf[i++] = c;
f010153e:	89 f0                	mov    %esi,%eax
f0101540:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f0101547:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f010154a:	e8 f4 f1 ff ff       	call   f0100743 <getchar>
f010154f:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101551:	85 c0                	test   %eax,%eax
f0101553:	78 af                	js     f0101504 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101555:	83 f8 08             	cmp    $0x8,%eax
f0101558:	0f 94 c2             	sete   %dl
f010155b:	83 f8 7f             	cmp    $0x7f,%eax
f010155e:	0f 94 c0             	sete   %al
f0101561:	08 c2                	or     %al,%dl
f0101563:	74 04                	je     f0101569 <readline+0xaa>
f0101565:	85 ff                	test   %edi,%edi
f0101567:	7f bb                	jg     f0101524 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101569:	83 fe 1f             	cmp    $0x1f,%esi
f010156c:	7e 1c                	jle    f010158a <readline+0xcb>
f010156e:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101574:	7f 14                	jg     f010158a <readline+0xcb>
			if (echoing)
f0101576:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010157a:	74 c2                	je     f010153e <readline+0x7f>
				cputchar(c);
f010157c:	83 ec 0c             	sub    $0xc,%esp
f010157f:	56                   	push   %esi
f0101580:	e8 ae f1 ff ff       	call   f0100733 <cputchar>
f0101585:	83 c4 10             	add    $0x10,%esp
f0101588:	eb b4                	jmp    f010153e <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f010158a:	83 fe 0a             	cmp    $0xa,%esi
f010158d:	74 05                	je     f0101594 <readline+0xd5>
f010158f:	83 fe 0d             	cmp    $0xd,%esi
f0101592:	75 b6                	jne    f010154a <readline+0x8b>
			if (echoing)
f0101594:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101598:	75 13                	jne    f01015ad <readline+0xee>
			buf[i] = 0;
f010159a:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f01015a1:	00 
			return buf;
f01015a2:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f01015a8:	e9 6f ff ff ff       	jmp    f010151c <readline+0x5d>
				cputchar('\n');
f01015ad:	83 ec 0c             	sub    $0xc,%esp
f01015b0:	6a 0a                	push   $0xa
f01015b2:	e8 7c f1 ff ff       	call   f0100733 <cputchar>
f01015b7:	83 c4 10             	add    $0x10,%esp
f01015ba:	eb de                	jmp    f010159a <readline+0xdb>

f01015bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01015bc:	55                   	push   %ebp
f01015bd:	89 e5                	mov    %esp,%ebp
f01015bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01015c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01015c7:	eb 03                	jmp    f01015cc <strlen+0x10>
		n++;
f01015c9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01015cc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01015d0:	75 f7                	jne    f01015c9 <strlen+0xd>
	return n;
}
f01015d2:	5d                   	pop    %ebp
f01015d3:	c3                   	ret    

f01015d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01015d4:	55                   	push   %ebp
f01015d5:	89 e5                	mov    %esp,%ebp
f01015d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015da:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01015e2:	eb 03                	jmp    f01015e7 <strnlen+0x13>
		n++;
f01015e4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015e7:	39 d0                	cmp    %edx,%eax
f01015e9:	74 06                	je     f01015f1 <strnlen+0x1d>
f01015eb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01015ef:	75 f3                	jne    f01015e4 <strnlen+0x10>
	return n;
}
f01015f1:	5d                   	pop    %ebp
f01015f2:	c3                   	ret    

f01015f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01015f3:	55                   	push   %ebp
f01015f4:	89 e5                	mov    %esp,%ebp
f01015f6:	53                   	push   %ebx
f01015f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01015fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01015fd:	89 c2                	mov    %eax,%edx
f01015ff:	83 c1 01             	add    $0x1,%ecx
f0101602:	83 c2 01             	add    $0x1,%edx
f0101605:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101609:	88 5a ff             	mov    %bl,-0x1(%edx)
f010160c:	84 db                	test   %bl,%bl
f010160e:	75 ef                	jne    f01015ff <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101610:	5b                   	pop    %ebx
f0101611:	5d                   	pop    %ebp
f0101612:	c3                   	ret    

f0101613 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101613:	55                   	push   %ebp
f0101614:	89 e5                	mov    %esp,%ebp
f0101616:	53                   	push   %ebx
f0101617:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010161a:	53                   	push   %ebx
f010161b:	e8 9c ff ff ff       	call   f01015bc <strlen>
f0101620:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101623:	ff 75 0c             	pushl  0xc(%ebp)
f0101626:	01 d8                	add    %ebx,%eax
f0101628:	50                   	push   %eax
f0101629:	e8 c5 ff ff ff       	call   f01015f3 <strcpy>
	return dst;
}
f010162e:	89 d8                	mov    %ebx,%eax
f0101630:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101633:	c9                   	leave  
f0101634:	c3                   	ret    

f0101635 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101635:	55                   	push   %ebp
f0101636:	89 e5                	mov    %esp,%ebp
f0101638:	56                   	push   %esi
f0101639:	53                   	push   %ebx
f010163a:	8b 75 08             	mov    0x8(%ebp),%esi
f010163d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101640:	89 f3                	mov    %esi,%ebx
f0101642:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101645:	89 f2                	mov    %esi,%edx
f0101647:	eb 0f                	jmp    f0101658 <strncpy+0x23>
		*dst++ = *src;
f0101649:	83 c2 01             	add    $0x1,%edx
f010164c:	0f b6 01             	movzbl (%ecx),%eax
f010164f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101652:	80 39 01             	cmpb   $0x1,(%ecx)
f0101655:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0101658:	39 da                	cmp    %ebx,%edx
f010165a:	75 ed                	jne    f0101649 <strncpy+0x14>
	}
	return ret;
}
f010165c:	89 f0                	mov    %esi,%eax
f010165e:	5b                   	pop    %ebx
f010165f:	5e                   	pop    %esi
f0101660:	5d                   	pop    %ebp
f0101661:	c3                   	ret    

f0101662 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101662:	55                   	push   %ebp
f0101663:	89 e5                	mov    %esp,%ebp
f0101665:	56                   	push   %esi
f0101666:	53                   	push   %ebx
f0101667:	8b 75 08             	mov    0x8(%ebp),%esi
f010166a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010166d:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101670:	89 f0                	mov    %esi,%eax
f0101672:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101676:	85 c9                	test   %ecx,%ecx
f0101678:	75 0b                	jne    f0101685 <strlcpy+0x23>
f010167a:	eb 17                	jmp    f0101693 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010167c:	83 c2 01             	add    $0x1,%edx
f010167f:	83 c0 01             	add    $0x1,%eax
f0101682:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0101685:	39 d8                	cmp    %ebx,%eax
f0101687:	74 07                	je     f0101690 <strlcpy+0x2e>
f0101689:	0f b6 0a             	movzbl (%edx),%ecx
f010168c:	84 c9                	test   %cl,%cl
f010168e:	75 ec                	jne    f010167c <strlcpy+0x1a>
		*dst = '\0';
f0101690:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101693:	29 f0                	sub    %esi,%eax
}
f0101695:	5b                   	pop    %ebx
f0101696:	5e                   	pop    %esi
f0101697:	5d                   	pop    %ebp
f0101698:	c3                   	ret    

f0101699 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101699:	55                   	push   %ebp
f010169a:	89 e5                	mov    %esp,%ebp
f010169c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010169f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01016a2:	eb 06                	jmp    f01016aa <strcmp+0x11>
		p++, q++;
f01016a4:	83 c1 01             	add    $0x1,%ecx
f01016a7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01016aa:	0f b6 01             	movzbl (%ecx),%eax
f01016ad:	84 c0                	test   %al,%al
f01016af:	74 04                	je     f01016b5 <strcmp+0x1c>
f01016b1:	3a 02                	cmp    (%edx),%al
f01016b3:	74 ef                	je     f01016a4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01016b5:	0f b6 c0             	movzbl %al,%eax
f01016b8:	0f b6 12             	movzbl (%edx),%edx
f01016bb:	29 d0                	sub    %edx,%eax
}
f01016bd:	5d                   	pop    %ebp
f01016be:	c3                   	ret    

f01016bf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01016bf:	55                   	push   %ebp
f01016c0:	89 e5                	mov    %esp,%ebp
f01016c2:	53                   	push   %ebx
f01016c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01016c6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016c9:	89 c3                	mov    %eax,%ebx
f01016cb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01016ce:	eb 06                	jmp    f01016d6 <strncmp+0x17>
		n--, p++, q++;
f01016d0:	83 c0 01             	add    $0x1,%eax
f01016d3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01016d6:	39 d8                	cmp    %ebx,%eax
f01016d8:	74 16                	je     f01016f0 <strncmp+0x31>
f01016da:	0f b6 08             	movzbl (%eax),%ecx
f01016dd:	84 c9                	test   %cl,%cl
f01016df:	74 04                	je     f01016e5 <strncmp+0x26>
f01016e1:	3a 0a                	cmp    (%edx),%cl
f01016e3:	74 eb                	je     f01016d0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01016e5:	0f b6 00             	movzbl (%eax),%eax
f01016e8:	0f b6 12             	movzbl (%edx),%edx
f01016eb:	29 d0                	sub    %edx,%eax
}
f01016ed:	5b                   	pop    %ebx
f01016ee:	5d                   	pop    %ebp
f01016ef:	c3                   	ret    
		return 0;
f01016f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01016f5:	eb f6                	jmp    f01016ed <strncmp+0x2e>

f01016f7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01016f7:	55                   	push   %ebp
f01016f8:	89 e5                	mov    %esp,%ebp
f01016fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01016fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101701:	0f b6 10             	movzbl (%eax),%edx
f0101704:	84 d2                	test   %dl,%dl
f0101706:	74 09                	je     f0101711 <strchr+0x1a>
		if (*s == c)
f0101708:	38 ca                	cmp    %cl,%dl
f010170a:	74 0a                	je     f0101716 <strchr+0x1f>
	for (; *s; s++)
f010170c:	83 c0 01             	add    $0x1,%eax
f010170f:	eb f0                	jmp    f0101701 <strchr+0xa>
			return (char *) s;
	return 0;
f0101711:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101716:	5d                   	pop    %ebp
f0101717:	c3                   	ret    

f0101718 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101718:	55                   	push   %ebp
f0101719:	89 e5                	mov    %esp,%ebp
f010171b:	8b 45 08             	mov    0x8(%ebp),%eax
f010171e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101722:	eb 03                	jmp    f0101727 <strfind+0xf>
f0101724:	83 c0 01             	add    $0x1,%eax
f0101727:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010172a:	38 ca                	cmp    %cl,%dl
f010172c:	74 04                	je     f0101732 <strfind+0x1a>
f010172e:	84 d2                	test   %dl,%dl
f0101730:	75 f2                	jne    f0101724 <strfind+0xc>
			break;
	return (char *) s;
}
f0101732:	5d                   	pop    %ebp
f0101733:	c3                   	ret    

f0101734 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101734:	55                   	push   %ebp
f0101735:	89 e5                	mov    %esp,%ebp
f0101737:	57                   	push   %edi
f0101738:	56                   	push   %esi
f0101739:	53                   	push   %ebx
f010173a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010173d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101740:	85 c9                	test   %ecx,%ecx
f0101742:	74 13                	je     f0101757 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101744:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010174a:	75 05                	jne    f0101751 <memset+0x1d>
f010174c:	f6 c1 03             	test   $0x3,%cl
f010174f:	74 0d                	je     f010175e <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101751:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101754:	fc                   	cld    
f0101755:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101757:	89 f8                	mov    %edi,%eax
f0101759:	5b                   	pop    %ebx
f010175a:	5e                   	pop    %esi
f010175b:	5f                   	pop    %edi
f010175c:	5d                   	pop    %ebp
f010175d:	c3                   	ret    
		c &= 0xFF;
f010175e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101762:	89 d3                	mov    %edx,%ebx
f0101764:	c1 e3 08             	shl    $0x8,%ebx
f0101767:	89 d0                	mov    %edx,%eax
f0101769:	c1 e0 18             	shl    $0x18,%eax
f010176c:	89 d6                	mov    %edx,%esi
f010176e:	c1 e6 10             	shl    $0x10,%esi
f0101771:	09 f0                	or     %esi,%eax
f0101773:	09 c2                	or     %eax,%edx
f0101775:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0101777:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010177a:	89 d0                	mov    %edx,%eax
f010177c:	fc                   	cld    
f010177d:	f3 ab                	rep stos %eax,%es:(%edi)
f010177f:	eb d6                	jmp    f0101757 <memset+0x23>

f0101781 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101781:	55                   	push   %ebp
f0101782:	89 e5                	mov    %esp,%ebp
f0101784:	57                   	push   %edi
f0101785:	56                   	push   %esi
f0101786:	8b 45 08             	mov    0x8(%ebp),%eax
f0101789:	8b 75 0c             	mov    0xc(%ebp),%esi
f010178c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010178f:	39 c6                	cmp    %eax,%esi
f0101791:	73 35                	jae    f01017c8 <memmove+0x47>
f0101793:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101796:	39 c2                	cmp    %eax,%edx
f0101798:	76 2e                	jbe    f01017c8 <memmove+0x47>
		s += n;
		d += n;
f010179a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010179d:	89 d6                	mov    %edx,%esi
f010179f:	09 fe                	or     %edi,%esi
f01017a1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01017a7:	74 0c                	je     f01017b5 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01017a9:	83 ef 01             	sub    $0x1,%edi
f01017ac:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01017af:	fd                   	std    
f01017b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01017b2:	fc                   	cld    
f01017b3:	eb 21                	jmp    f01017d6 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017b5:	f6 c1 03             	test   $0x3,%cl
f01017b8:	75 ef                	jne    f01017a9 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01017ba:	83 ef 04             	sub    $0x4,%edi
f01017bd:	8d 72 fc             	lea    -0x4(%edx),%esi
f01017c0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01017c3:	fd                   	std    
f01017c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017c6:	eb ea                	jmp    f01017b2 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017c8:	89 f2                	mov    %esi,%edx
f01017ca:	09 c2                	or     %eax,%edx
f01017cc:	f6 c2 03             	test   $0x3,%dl
f01017cf:	74 09                	je     f01017da <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01017d1:	89 c7                	mov    %eax,%edi
f01017d3:	fc                   	cld    
f01017d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01017d6:	5e                   	pop    %esi
f01017d7:	5f                   	pop    %edi
f01017d8:	5d                   	pop    %ebp
f01017d9:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017da:	f6 c1 03             	test   $0x3,%cl
f01017dd:	75 f2                	jne    f01017d1 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01017df:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01017e2:	89 c7                	mov    %eax,%edi
f01017e4:	fc                   	cld    
f01017e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017e7:	eb ed                	jmp    f01017d6 <memmove+0x55>

f01017e9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01017e9:	55                   	push   %ebp
f01017ea:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01017ec:	ff 75 10             	pushl  0x10(%ebp)
f01017ef:	ff 75 0c             	pushl  0xc(%ebp)
f01017f2:	ff 75 08             	pushl  0x8(%ebp)
f01017f5:	e8 87 ff ff ff       	call   f0101781 <memmove>
}
f01017fa:	c9                   	leave  
f01017fb:	c3                   	ret    

f01017fc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01017fc:	55                   	push   %ebp
f01017fd:	89 e5                	mov    %esp,%ebp
f01017ff:	56                   	push   %esi
f0101800:	53                   	push   %ebx
f0101801:	8b 45 08             	mov    0x8(%ebp),%eax
f0101804:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101807:	89 c6                	mov    %eax,%esi
f0101809:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010180c:	39 f0                	cmp    %esi,%eax
f010180e:	74 1c                	je     f010182c <memcmp+0x30>
		if (*s1 != *s2)
f0101810:	0f b6 08             	movzbl (%eax),%ecx
f0101813:	0f b6 1a             	movzbl (%edx),%ebx
f0101816:	38 d9                	cmp    %bl,%cl
f0101818:	75 08                	jne    f0101822 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010181a:	83 c0 01             	add    $0x1,%eax
f010181d:	83 c2 01             	add    $0x1,%edx
f0101820:	eb ea                	jmp    f010180c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0101822:	0f b6 c1             	movzbl %cl,%eax
f0101825:	0f b6 db             	movzbl %bl,%ebx
f0101828:	29 d8                	sub    %ebx,%eax
f010182a:	eb 05                	jmp    f0101831 <memcmp+0x35>
	}

	return 0;
f010182c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101831:	5b                   	pop    %ebx
f0101832:	5e                   	pop    %esi
f0101833:	5d                   	pop    %ebp
f0101834:	c3                   	ret    

f0101835 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101835:	55                   	push   %ebp
f0101836:	89 e5                	mov    %esp,%ebp
f0101838:	8b 45 08             	mov    0x8(%ebp),%eax
f010183b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010183e:	89 c2                	mov    %eax,%edx
f0101840:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101843:	39 d0                	cmp    %edx,%eax
f0101845:	73 09                	jae    f0101850 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101847:	38 08                	cmp    %cl,(%eax)
f0101849:	74 05                	je     f0101850 <memfind+0x1b>
	for (; s < ends; s++)
f010184b:	83 c0 01             	add    $0x1,%eax
f010184e:	eb f3                	jmp    f0101843 <memfind+0xe>
			break;
	return (void *) s;
}
f0101850:	5d                   	pop    %ebp
f0101851:	c3                   	ret    

f0101852 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101852:	55                   	push   %ebp
f0101853:	89 e5                	mov    %esp,%ebp
f0101855:	57                   	push   %edi
f0101856:	56                   	push   %esi
f0101857:	53                   	push   %ebx
f0101858:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010185b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010185e:	eb 03                	jmp    f0101863 <strtol+0x11>
		s++;
f0101860:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101863:	0f b6 01             	movzbl (%ecx),%eax
f0101866:	3c 20                	cmp    $0x20,%al
f0101868:	74 f6                	je     f0101860 <strtol+0xe>
f010186a:	3c 09                	cmp    $0x9,%al
f010186c:	74 f2                	je     f0101860 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010186e:	3c 2b                	cmp    $0x2b,%al
f0101870:	74 2e                	je     f01018a0 <strtol+0x4e>
	int neg = 0;
f0101872:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101877:	3c 2d                	cmp    $0x2d,%al
f0101879:	74 2f                	je     f01018aa <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010187b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101881:	75 05                	jne    f0101888 <strtol+0x36>
f0101883:	80 39 30             	cmpb   $0x30,(%ecx)
f0101886:	74 2c                	je     f01018b4 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101888:	85 db                	test   %ebx,%ebx
f010188a:	75 0a                	jne    f0101896 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010188c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0101891:	80 39 30             	cmpb   $0x30,(%ecx)
f0101894:	74 28                	je     f01018be <strtol+0x6c>
		base = 10;
f0101896:	b8 00 00 00 00       	mov    $0x0,%eax
f010189b:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010189e:	eb 50                	jmp    f01018f0 <strtol+0x9e>
		s++;
f01018a0:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01018a3:	bf 00 00 00 00       	mov    $0x0,%edi
f01018a8:	eb d1                	jmp    f010187b <strtol+0x29>
		s++, neg = 1;
f01018aa:	83 c1 01             	add    $0x1,%ecx
f01018ad:	bf 01 00 00 00       	mov    $0x1,%edi
f01018b2:	eb c7                	jmp    f010187b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018b4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01018b8:	74 0e                	je     f01018c8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01018ba:	85 db                	test   %ebx,%ebx
f01018bc:	75 d8                	jne    f0101896 <strtol+0x44>
		s++, base = 8;
f01018be:	83 c1 01             	add    $0x1,%ecx
f01018c1:	bb 08 00 00 00       	mov    $0x8,%ebx
f01018c6:	eb ce                	jmp    f0101896 <strtol+0x44>
		s += 2, base = 16;
f01018c8:	83 c1 02             	add    $0x2,%ecx
f01018cb:	bb 10 00 00 00       	mov    $0x10,%ebx
f01018d0:	eb c4                	jmp    f0101896 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01018d2:	8d 72 9f             	lea    -0x61(%edx),%esi
f01018d5:	89 f3                	mov    %esi,%ebx
f01018d7:	80 fb 19             	cmp    $0x19,%bl
f01018da:	77 29                	ja     f0101905 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01018dc:	0f be d2             	movsbl %dl,%edx
f01018df:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01018e2:	3b 55 10             	cmp    0x10(%ebp),%edx
f01018e5:	7d 30                	jge    f0101917 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01018e7:	83 c1 01             	add    $0x1,%ecx
f01018ea:	0f af 45 10          	imul   0x10(%ebp),%eax
f01018ee:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01018f0:	0f b6 11             	movzbl (%ecx),%edx
f01018f3:	8d 72 d0             	lea    -0x30(%edx),%esi
f01018f6:	89 f3                	mov    %esi,%ebx
f01018f8:	80 fb 09             	cmp    $0x9,%bl
f01018fb:	77 d5                	ja     f01018d2 <strtol+0x80>
			dig = *s - '0';
f01018fd:	0f be d2             	movsbl %dl,%edx
f0101900:	83 ea 30             	sub    $0x30,%edx
f0101903:	eb dd                	jmp    f01018e2 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0101905:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101908:	89 f3                	mov    %esi,%ebx
f010190a:	80 fb 19             	cmp    $0x19,%bl
f010190d:	77 08                	ja     f0101917 <strtol+0xc5>
			dig = *s - 'A' + 10;
f010190f:	0f be d2             	movsbl %dl,%edx
f0101912:	83 ea 37             	sub    $0x37,%edx
f0101915:	eb cb                	jmp    f01018e2 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101917:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010191b:	74 05                	je     f0101922 <strtol+0xd0>
		*endptr = (char *) s;
f010191d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101920:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0101922:	89 c2                	mov    %eax,%edx
f0101924:	f7 da                	neg    %edx
f0101926:	85 ff                	test   %edi,%edi
f0101928:	0f 45 c2             	cmovne %edx,%eax
}
f010192b:	5b                   	pop    %ebx
f010192c:	5e                   	pop    %esi
f010192d:	5f                   	pop    %edi
f010192e:	5d                   	pop    %ebp
f010192f:	c3                   	ret    

f0101930 <__udivdi3>:
f0101930:	55                   	push   %ebp
f0101931:	57                   	push   %edi
f0101932:	56                   	push   %esi
f0101933:	53                   	push   %ebx
f0101934:	83 ec 1c             	sub    $0x1c,%esp
f0101937:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010193b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010193f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101943:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101947:	85 d2                	test   %edx,%edx
f0101949:	75 35                	jne    f0101980 <__udivdi3+0x50>
f010194b:	39 f3                	cmp    %esi,%ebx
f010194d:	0f 87 bd 00 00 00    	ja     f0101a10 <__udivdi3+0xe0>
f0101953:	85 db                	test   %ebx,%ebx
f0101955:	89 d9                	mov    %ebx,%ecx
f0101957:	75 0b                	jne    f0101964 <__udivdi3+0x34>
f0101959:	b8 01 00 00 00       	mov    $0x1,%eax
f010195e:	31 d2                	xor    %edx,%edx
f0101960:	f7 f3                	div    %ebx
f0101962:	89 c1                	mov    %eax,%ecx
f0101964:	31 d2                	xor    %edx,%edx
f0101966:	89 f0                	mov    %esi,%eax
f0101968:	f7 f1                	div    %ecx
f010196a:	89 c6                	mov    %eax,%esi
f010196c:	89 e8                	mov    %ebp,%eax
f010196e:	89 f7                	mov    %esi,%edi
f0101970:	f7 f1                	div    %ecx
f0101972:	89 fa                	mov    %edi,%edx
f0101974:	83 c4 1c             	add    $0x1c,%esp
f0101977:	5b                   	pop    %ebx
f0101978:	5e                   	pop    %esi
f0101979:	5f                   	pop    %edi
f010197a:	5d                   	pop    %ebp
f010197b:	c3                   	ret    
f010197c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101980:	39 f2                	cmp    %esi,%edx
f0101982:	77 7c                	ja     f0101a00 <__udivdi3+0xd0>
f0101984:	0f bd fa             	bsr    %edx,%edi
f0101987:	83 f7 1f             	xor    $0x1f,%edi
f010198a:	0f 84 98 00 00 00    	je     f0101a28 <__udivdi3+0xf8>
f0101990:	89 f9                	mov    %edi,%ecx
f0101992:	b8 20 00 00 00       	mov    $0x20,%eax
f0101997:	29 f8                	sub    %edi,%eax
f0101999:	d3 e2                	shl    %cl,%edx
f010199b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010199f:	89 c1                	mov    %eax,%ecx
f01019a1:	89 da                	mov    %ebx,%edx
f01019a3:	d3 ea                	shr    %cl,%edx
f01019a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01019a9:	09 d1                	or     %edx,%ecx
f01019ab:	89 f2                	mov    %esi,%edx
f01019ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01019b1:	89 f9                	mov    %edi,%ecx
f01019b3:	d3 e3                	shl    %cl,%ebx
f01019b5:	89 c1                	mov    %eax,%ecx
f01019b7:	d3 ea                	shr    %cl,%edx
f01019b9:	89 f9                	mov    %edi,%ecx
f01019bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01019bf:	d3 e6                	shl    %cl,%esi
f01019c1:	89 eb                	mov    %ebp,%ebx
f01019c3:	89 c1                	mov    %eax,%ecx
f01019c5:	d3 eb                	shr    %cl,%ebx
f01019c7:	09 de                	or     %ebx,%esi
f01019c9:	89 f0                	mov    %esi,%eax
f01019cb:	f7 74 24 08          	divl   0x8(%esp)
f01019cf:	89 d6                	mov    %edx,%esi
f01019d1:	89 c3                	mov    %eax,%ebx
f01019d3:	f7 64 24 0c          	mull   0xc(%esp)
f01019d7:	39 d6                	cmp    %edx,%esi
f01019d9:	72 0c                	jb     f01019e7 <__udivdi3+0xb7>
f01019db:	89 f9                	mov    %edi,%ecx
f01019dd:	d3 e5                	shl    %cl,%ebp
f01019df:	39 c5                	cmp    %eax,%ebp
f01019e1:	73 5d                	jae    f0101a40 <__udivdi3+0x110>
f01019e3:	39 d6                	cmp    %edx,%esi
f01019e5:	75 59                	jne    f0101a40 <__udivdi3+0x110>
f01019e7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01019ea:	31 ff                	xor    %edi,%edi
f01019ec:	89 fa                	mov    %edi,%edx
f01019ee:	83 c4 1c             	add    $0x1c,%esp
f01019f1:	5b                   	pop    %ebx
f01019f2:	5e                   	pop    %esi
f01019f3:	5f                   	pop    %edi
f01019f4:	5d                   	pop    %ebp
f01019f5:	c3                   	ret    
f01019f6:	8d 76 00             	lea    0x0(%esi),%esi
f01019f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101a00:	31 ff                	xor    %edi,%edi
f0101a02:	31 c0                	xor    %eax,%eax
f0101a04:	89 fa                	mov    %edi,%edx
f0101a06:	83 c4 1c             	add    $0x1c,%esp
f0101a09:	5b                   	pop    %ebx
f0101a0a:	5e                   	pop    %esi
f0101a0b:	5f                   	pop    %edi
f0101a0c:	5d                   	pop    %ebp
f0101a0d:	c3                   	ret    
f0101a0e:	66 90                	xchg   %ax,%ax
f0101a10:	31 ff                	xor    %edi,%edi
f0101a12:	89 e8                	mov    %ebp,%eax
f0101a14:	89 f2                	mov    %esi,%edx
f0101a16:	f7 f3                	div    %ebx
f0101a18:	89 fa                	mov    %edi,%edx
f0101a1a:	83 c4 1c             	add    $0x1c,%esp
f0101a1d:	5b                   	pop    %ebx
f0101a1e:	5e                   	pop    %esi
f0101a1f:	5f                   	pop    %edi
f0101a20:	5d                   	pop    %ebp
f0101a21:	c3                   	ret    
f0101a22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a28:	39 f2                	cmp    %esi,%edx
f0101a2a:	72 06                	jb     f0101a32 <__udivdi3+0x102>
f0101a2c:	31 c0                	xor    %eax,%eax
f0101a2e:	39 eb                	cmp    %ebp,%ebx
f0101a30:	77 d2                	ja     f0101a04 <__udivdi3+0xd4>
f0101a32:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a37:	eb cb                	jmp    f0101a04 <__udivdi3+0xd4>
f0101a39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a40:	89 d8                	mov    %ebx,%eax
f0101a42:	31 ff                	xor    %edi,%edi
f0101a44:	eb be                	jmp    f0101a04 <__udivdi3+0xd4>
f0101a46:	66 90                	xchg   %ax,%ax
f0101a48:	66 90                	xchg   %ax,%ax
f0101a4a:	66 90                	xchg   %ax,%ax
f0101a4c:	66 90                	xchg   %ax,%ax
f0101a4e:	66 90                	xchg   %ax,%ax

f0101a50 <__umoddi3>:
f0101a50:	55                   	push   %ebp
f0101a51:	57                   	push   %edi
f0101a52:	56                   	push   %esi
f0101a53:	53                   	push   %ebx
f0101a54:	83 ec 1c             	sub    $0x1c,%esp
f0101a57:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101a5b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101a5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a63:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101a67:	85 ed                	test   %ebp,%ebp
f0101a69:	89 f0                	mov    %esi,%eax
f0101a6b:	89 da                	mov    %ebx,%edx
f0101a6d:	75 19                	jne    f0101a88 <__umoddi3+0x38>
f0101a6f:	39 df                	cmp    %ebx,%edi
f0101a71:	0f 86 b1 00 00 00    	jbe    f0101b28 <__umoddi3+0xd8>
f0101a77:	f7 f7                	div    %edi
f0101a79:	89 d0                	mov    %edx,%eax
f0101a7b:	31 d2                	xor    %edx,%edx
f0101a7d:	83 c4 1c             	add    $0x1c,%esp
f0101a80:	5b                   	pop    %ebx
f0101a81:	5e                   	pop    %esi
f0101a82:	5f                   	pop    %edi
f0101a83:	5d                   	pop    %ebp
f0101a84:	c3                   	ret    
f0101a85:	8d 76 00             	lea    0x0(%esi),%esi
f0101a88:	39 dd                	cmp    %ebx,%ebp
f0101a8a:	77 f1                	ja     f0101a7d <__umoddi3+0x2d>
f0101a8c:	0f bd cd             	bsr    %ebp,%ecx
f0101a8f:	83 f1 1f             	xor    $0x1f,%ecx
f0101a92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101a96:	0f 84 b4 00 00 00    	je     f0101b50 <__umoddi3+0x100>
f0101a9c:	b8 20 00 00 00       	mov    $0x20,%eax
f0101aa1:	89 c2                	mov    %eax,%edx
f0101aa3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101aa7:	29 c2                	sub    %eax,%edx
f0101aa9:	89 c1                	mov    %eax,%ecx
f0101aab:	89 f8                	mov    %edi,%eax
f0101aad:	d3 e5                	shl    %cl,%ebp
f0101aaf:	89 d1                	mov    %edx,%ecx
f0101ab1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101ab5:	d3 e8                	shr    %cl,%eax
f0101ab7:	09 c5                	or     %eax,%ebp
f0101ab9:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101abd:	89 c1                	mov    %eax,%ecx
f0101abf:	d3 e7                	shl    %cl,%edi
f0101ac1:	89 d1                	mov    %edx,%ecx
f0101ac3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101ac7:	89 df                	mov    %ebx,%edi
f0101ac9:	d3 ef                	shr    %cl,%edi
f0101acb:	89 c1                	mov    %eax,%ecx
f0101acd:	89 f0                	mov    %esi,%eax
f0101acf:	d3 e3                	shl    %cl,%ebx
f0101ad1:	89 d1                	mov    %edx,%ecx
f0101ad3:	89 fa                	mov    %edi,%edx
f0101ad5:	d3 e8                	shr    %cl,%eax
f0101ad7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101adc:	09 d8                	or     %ebx,%eax
f0101ade:	f7 f5                	div    %ebp
f0101ae0:	d3 e6                	shl    %cl,%esi
f0101ae2:	89 d1                	mov    %edx,%ecx
f0101ae4:	f7 64 24 08          	mull   0x8(%esp)
f0101ae8:	39 d1                	cmp    %edx,%ecx
f0101aea:	89 c3                	mov    %eax,%ebx
f0101aec:	89 d7                	mov    %edx,%edi
f0101aee:	72 06                	jb     f0101af6 <__umoddi3+0xa6>
f0101af0:	75 0e                	jne    f0101b00 <__umoddi3+0xb0>
f0101af2:	39 c6                	cmp    %eax,%esi
f0101af4:	73 0a                	jae    f0101b00 <__umoddi3+0xb0>
f0101af6:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101afa:	19 ea                	sbb    %ebp,%edx
f0101afc:	89 d7                	mov    %edx,%edi
f0101afe:	89 c3                	mov    %eax,%ebx
f0101b00:	89 ca                	mov    %ecx,%edx
f0101b02:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101b07:	29 de                	sub    %ebx,%esi
f0101b09:	19 fa                	sbb    %edi,%edx
f0101b0b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0101b0f:	89 d0                	mov    %edx,%eax
f0101b11:	d3 e0                	shl    %cl,%eax
f0101b13:	89 d9                	mov    %ebx,%ecx
f0101b15:	d3 ee                	shr    %cl,%esi
f0101b17:	d3 ea                	shr    %cl,%edx
f0101b19:	09 f0                	or     %esi,%eax
f0101b1b:	83 c4 1c             	add    $0x1c,%esp
f0101b1e:	5b                   	pop    %ebx
f0101b1f:	5e                   	pop    %esi
f0101b20:	5f                   	pop    %edi
f0101b21:	5d                   	pop    %ebp
f0101b22:	c3                   	ret    
f0101b23:	90                   	nop
f0101b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b28:	85 ff                	test   %edi,%edi
f0101b2a:	89 f9                	mov    %edi,%ecx
f0101b2c:	75 0b                	jne    f0101b39 <__umoddi3+0xe9>
f0101b2e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b33:	31 d2                	xor    %edx,%edx
f0101b35:	f7 f7                	div    %edi
f0101b37:	89 c1                	mov    %eax,%ecx
f0101b39:	89 d8                	mov    %ebx,%eax
f0101b3b:	31 d2                	xor    %edx,%edx
f0101b3d:	f7 f1                	div    %ecx
f0101b3f:	89 f0                	mov    %esi,%eax
f0101b41:	f7 f1                	div    %ecx
f0101b43:	e9 31 ff ff ff       	jmp    f0101a79 <__umoddi3+0x29>
f0101b48:	90                   	nop
f0101b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b50:	39 dd                	cmp    %ebx,%ebp
f0101b52:	72 08                	jb     f0101b5c <__umoddi3+0x10c>
f0101b54:	39 f7                	cmp    %esi,%edi
f0101b56:	0f 87 21 ff ff ff    	ja     f0101a7d <__umoddi3+0x2d>
f0101b5c:	89 da                	mov    %ebx,%edx
f0101b5e:	89 f0                	mov    %esi,%eax
f0101b60:	29 f8                	sub    %edi,%eax
f0101b62:	19 ea                	sbb    %ebp,%edx
f0101b64:	e9 14 ff ff ff       	jmp    f0101a7d <__umoddi3+0x2d>
