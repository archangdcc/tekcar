	.globl main
main:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$8, %rsp

	movq	$8192, %rdi
	movq	$16, %rsi
	callq	initialize
	movq	rootstack_begin(%rip), %rbx
	movq	free_ptr(%rip), %rcx
	addq	$16, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28558
	movq	%rbx, %rdi
	movq	$16, %rsi
	callq	collect
	jmp if_end28559
then28558:
if_end28559:
	movq	free_ptr(%rip), %rsi
	addq	$16, free_ptr(%rip)
	movq	%rsi, %r11
	movq	$3, 0(%r11)
	movq	%rsi, %r11
	movq	$20, 8(%r11)
	movq	free_ptr(%rip), %rcx
	addq	$48, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28560
	movq	%rsi, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	jmp if_end28561
then28560:
if_end28561:
	movq	free_ptr(%rip), %rcx
	addq	$48, free_ptr(%rip)
	movq	%rcx, %r11
	movq	$11, 0(%r11)
	movq	%rcx, %r11
	movq	$1, 8(%r11)
	movq	%rcx, %r11
	movq	$2, 16(%r11)
	movq	%rcx, %r11
	movq	$3, 24(%r11)
	movq	%rcx, %r11
	movq	$4, 32(%r11)
	movq	%rcx, %r11
	movq	$5, 40(%r11)
	movq	free_ptr(%rip), %rdx
	addq	$48, %rdx
	cmpq	%rdx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rdx
	cmpq	$0, %rdx
	je then28562
	movq	%rcx, 0(%rbx)
	movq	%rsi, 8(%rbx)
	movq	%rbx, %rcx
	addq	$16, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rcx
	movq	8(%rbx), %rsi
	jmp if_end28563
then28562:
if_end28563:
	movq	free_ptr(%rip), %rdx
	addq	$48, free_ptr(%rip)
	movq	%rdx, %r11
	movq	$139, 0(%r11)
	movq	%rdx, %r11
	movq	%rcx, 8(%r11)
	movq	%rdx, %r11
	movq	$2, 16(%r11)
	movq	%rdx, %r11
	movq	$3, 24(%r11)
	movq	%rdx, %r11
	movq	$4, 32(%r11)
	movq	%rdx, %r11
	movq	$5, 40(%r11)
	movq	free_ptr(%rip), %rcx
	addq	$48, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28564
	movq	%rdx, 0(%rbx)
	movq	%rsi, 8(%rbx)
	movq	%rbx, %rcx
	addq	$16, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rdx
	movq	8(%rbx), %rsi
	jmp if_end28565
then28564:
if_end28565:
	movq	free_ptr(%rip), %rcx
	addq	$48, free_ptr(%rip)
	movq	%rcx, %r11
	movq	$267, 0(%r11)
	movq	%rcx, %r11
	movq	$1, 8(%r11)
	movq	%rcx, %r11
	movq	%rdx, 16(%r11)
	movq	%rcx, %r11
	movq	$3, 24(%r11)
	movq	%rcx, %r11
	movq	$4, 32(%r11)
	movq	%rcx, %r11
	movq	$5, 40(%r11)
	movq	free_ptr(%rip), %rdx
	addq	$48, %rdx
	cmpq	%rdx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rdx
	cmpq	$0, %rdx
	je then28566
	movq	%rsi, 0(%rbx)
	movq	%rcx, 8(%rbx)
	movq	%rbx, %rcx
	addq	$16, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	movq	8(%rbx), %rcx
	jmp if_end28567
then28566:
if_end28567:
	movq	free_ptr(%rip), %rdx
	addq	$48, free_ptr(%rip)
	movq	%rdx, %r11
	movq	$523, 0(%r11)
	movq	%rdx, %r11
	movq	$1, 8(%r11)
	movq	%rdx, %r11
	movq	$2, 16(%r11)
	movq	%rdx, %r11
	movq	%rcx, 24(%r11)
	movq	%rdx, %r11
	movq	$4, 32(%r11)
	movq	%rdx, %r11
	movq	$5, 40(%r11)
	movq	free_ptr(%rip), %rcx
	addq	$48, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28568
	movq	%rsi, 0(%rbx)
	movq	%rdx, 8(%rbx)
	movq	%rbx, %rcx
	addq	$16, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	movq	8(%rbx), %rdx
	jmp if_end28569
then28568:
if_end28569:
	movq	free_ptr(%rip), %rcx
	addq	$48, free_ptr(%rip)
	movq	%rcx, %r11
	movq	$1035, 0(%r11)
	movq	%rcx, %r11
	movq	$1, 8(%r11)
	movq	%rcx, %r11
	movq	$2, 16(%r11)
	movq	%rcx, %r11
	movq	$3, 24(%r11)
	movq	%rcx, %r11
	movq	%rdx, 32(%r11)
	movq	%rcx, %r11
	movq	$5, 40(%r11)
	movq	free_ptr(%rip), %rdx
	addq	$48, %rdx
	cmpq	%rdx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rdx
	cmpq	$0, %rdx
	je then28570
	movq	%rsi, 0(%rbx)
	movq	%rcx, 8(%rbx)
	movq	%rbx, %rcx
	addq	$16, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	movq	8(%rbx), %rcx
	jmp if_end28571
then28570:
if_end28571:
	movq	free_ptr(%rip), %rdx
	addq	$48, free_ptr(%rip)
	movq	%rdx, %r11
	movq	$2059, 0(%r11)
	movq	%rdx, %r11
	movq	$1, 8(%r11)
	movq	%rdx, %r11
	movq	$2, 16(%r11)
	movq	%rdx, %r11
	movq	$3, 24(%r11)
	movq	%rdx, %r11
	movq	$4, 32(%r11)
	movq	%rdx, %r11
	movq	%rcx, 40(%r11)
	movq	free_ptr(%rip), %rcx
	addq	$48, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28572
	movq	%rsi, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	jmp if_end28573
then28572:
if_end28573:
	movq	free_ptr(%rip), %rcx
	addq	$48, free_ptr(%rip)
	movq	%rcx, %r11
	movq	$11, 0(%r11)
	movq	%rcx, %r11
	movq	$1, 8(%r11)
	movq	%rcx, %r11
	movq	$2, 16(%r11)
	movq	%rcx, %r11
	movq	$3, 24(%r11)
	movq	%rcx, %r11
	movq	$4, 32(%r11)
	movq	%rcx, %r11
	movq	$5, 40(%r11)
	movq	free_ptr(%rip), %rcx
	addq	$48, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28574
	movq	%rsi, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	jmp if_end28575
then28574:
if_end28575:
	movq	free_ptr(%rip), %rcx
	addq	$48, free_ptr(%rip)
	movq	%rcx, %r11
	movq	$11, 0(%r11)
	movq	%rcx, %r11
	movq	$1, 8(%r11)
	movq	%rcx, %r11
	movq	$2, 16(%r11)
	movq	%rcx, %r11
	movq	$3, 24(%r11)
	movq	%rcx, %r11
	movq	$4, 32(%r11)
	movq	%rcx, %r11
	movq	$5, 40(%r11)
	movq	free_ptr(%rip), %rcx
	addq	$48, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28576
	movq	%rsi, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	jmp if_end28577
then28576:
if_end28577:
	movq	free_ptr(%rip), %rcx
	addq	$48, free_ptr(%rip)
	movq	%rcx, %r11
	movq	$11, 0(%r11)
	movq	%rcx, %r11
	movq	$1, 8(%r11)
	movq	%rcx, %r11
	movq	$2, 16(%r11)
	movq	%rcx, %r11
	movq	$3, 24(%r11)
	movq	%rcx, %r11
	movq	$4, 32(%r11)
	movq	%rcx, %r11
	movq	$5, 40(%r11)
	movq	free_ptr(%rip), %rcx
	addq	$48, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28578
	movq	%rsi, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	jmp if_end28579
then28578:
if_end28579:
	movq	free_ptr(%rip), %rcx
	addq	$48, free_ptr(%rip)
	movq	%rcx, %r11
	movq	$11, 0(%r11)
	movq	%rcx, %r11
	movq	$1, 8(%r11)
	movq	%rcx, %r11
	movq	$2, 16(%r11)
	movq	%rcx, %r11
	movq	$3, 24(%r11)
	movq	%rcx, %r11
	movq	$4, 32(%r11)
	movq	%rcx, %r11
	movq	$5, 40(%r11)
	movq	free_ptr(%rip), %rcx
	addq	$48, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28580
	movq	%rsi, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	jmp if_end28581
then28580:
if_end28581:
	movq	free_ptr(%rip), %rcx
	addq	$48, free_ptr(%rip)
	movq	%rcx, %r11
	movq	$11, 0(%r11)
	movq	%rcx, %r11
	movq	$1, 8(%r11)
	movq	%rcx, %r11
	movq	$2, 16(%r11)
	movq	%rcx, %r11
	movq	$3, 24(%r11)
	movq	%rcx, %r11
	movq	$4, 32(%r11)
	movq	%rcx, %r11
	movq	$5, 40(%r11)
	movq	free_ptr(%rip), %rcx
	addq	$48, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28582
	movq	%rsi, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	jmp if_end28583
then28582:
if_end28583:
	movq	free_ptr(%rip), %rcx
	addq	$48, free_ptr(%rip)
	movq	%rcx, %r11
	movq	$11, 0(%r11)
	movq	%rcx, %r11
	movq	$1, 8(%r11)
	movq	%rcx, %r11
	movq	$2, 16(%r11)
	movq	%rcx, %r11
	movq	$3, 24(%r11)
	movq	%rcx, %r11
	movq	$4, 32(%r11)
	movq	%rcx, %r11
	movq	$5, 40(%r11)
	movq	free_ptr(%rip), %rcx
	addq	$48, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28584
	movq	%rsi, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	jmp if_end28585
then28584:
if_end28585:
	movq	free_ptr(%rip), %rcx
	addq	$48, free_ptr(%rip)
	movq	%rcx, %r11
	movq	$11, 0(%r11)
	movq	%rcx, %r11
	movq	$1, 8(%r11)
	movq	%rcx, %r11
	movq	$2, 16(%r11)
	movq	%rcx, %r11
	movq	$3, 24(%r11)
	movq	%rcx, %r11
	movq	$4, 32(%r11)
	movq	%rcx, %r11
	movq	$5, 40(%r11)
	movq	free_ptr(%rip), %rcx
	addq	$48, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28586
	movq	%rsi, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$48, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	jmp if_end28587
then28586:
if_end28587:
	movq	free_ptr(%rip), %rbx
	addq	$48, free_ptr(%rip)
	movq	%rbx, %r11
	movq	$11, 0(%r11)
	movq	%rbx, %r11
	movq	$1, 8(%r11)
	movq	%rbx, %r11
	movq	$2, 16(%r11)
	movq	%rbx, %r11
	movq	$3, 24(%r11)
	movq	%rbx, %r11
	movq	$4, 32(%r11)
	movq	%rbx, %r11
	movq	$5, 40(%r11)
	movq	%rsi, %r11
	movq	8(%r11), %rbx
	addq	$22, %rbx
	movq	%rbx, %rax

	movq	%rax, %rdi
	callq	print_int
	movq	$0, %rax
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq

