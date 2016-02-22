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
	addq	$24, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28413
	movq	%rbx, %rdi
	movq	$24, %rsi
	callq	collect
	jmp if_end28414
then28413:
if_end28414:
	movq	free_ptr(%rip), %rcx
	addq	$24, free_ptr(%rip)
	movq	%rcx, %r11
	movq	$5, 0(%r11)
	movq	%rcx, %r11
	movq	$1, 8(%r11)
	movq	%rcx, %r11
	movq	$42, 16(%r11)
	movq	free_ptr(%rip), %rdx
	addq	$16, %rdx
	cmpq	%rdx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rdx
	cmpq	$0, %rdx
	je then28415
	movq	%rcx, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rcx
	jmp if_end28416
then28415:
if_end28416:
	movq	free_ptr(%rip), %rdx
	addq	$16, free_ptr(%rip)
	movq	%rdx, %r11
	movq	$3, 0(%r11)
	movq	%rdx, %r11
	movq	$3, 8(%r11)
	movq	free_ptr(%rip), %rsi
	addq	$24, %rsi
	cmpq	%rsi, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rsi
	cmpq	$0, %rsi
	je then28417
	movq	%rdx, 0(%rbx)
	movq	%rcx, 8(%rbx)
	movq	%rbx, %rcx
	addq	$16, %rcx
	movq	%rcx, %rdi
	movq	$24, %rsi
	callq	collect
	movq	0(%rbx), %rdx
	movq	8(%rbx), %rcx
	jmp if_end28418
then28417:
if_end28418:
	movq	free_ptr(%rip), %rsi
	addq	$24, free_ptr(%rip)
	movq	%rsi, %r11
	movq	$389, 0(%r11)
	movq	%rsi, %r11
	movq	%rcx, 8(%r11)
	movq	%rsi, %r11
	movq	%rdx, 16(%r11)
	movq	free_ptr(%rip), %rcx
	addq	$24, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28419
	movq	%rsi, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$24, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	jmp if_end28420
then28419:
if_end28420:
	movq	free_ptr(%rip), %rcx
	addq	$24, free_ptr(%rip)
	movq	%rcx, %r11
	movq	$261, 0(%r11)
	movq	%rcx, %r11
	movq	$6, 8(%r11)
	movq	%rcx, %r11
	movq	%rsi, 16(%r11)
	movq	free_ptr(%rip), %rdx
	addq	$24, %rdx
	cmpq	%rdx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rdx
	cmpq	$0, %rdx
	je then28421
	movq	%rcx, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$24, %rsi
	callq	collect
	movq	0(%rbx), %rcx
	jmp if_end28422
then28421:
if_end28422:
	movq	free_ptr(%rip), %rdx
	addq	$24, free_ptr(%rip)
	movq	%rdx, %r11
	movq	$261, 0(%r11)
	movq	%rdx, %r11
	movq	$2, 8(%r11)
	movq	%rdx, %r11
	movq	%rcx, 16(%r11)
	movq	free_ptr(%rip), %rcx
	addq	$24, %rcx
	cmpq	%rcx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rcx
	cmpq	$0, %rcx
	je then28423
	movq	%rdx, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$24, %rsi
	callq	collect
	movq	0(%rbx), %rdx
	jmp if_end28424
then28423:
if_end28424:
	movq	free_ptr(%rip), %rbx
	addq	$24, free_ptr(%rip)
	movq	%rbx, %r11
	movq	$261, 0(%r11)
	movq	%rbx, %r11
	movq	$4, 8(%r11)
	movq	%rbx, %r11
	movq	%rdx, 16(%r11)
	movq	%rbx, %r11
	movq	16(%r11), %rbx
	movq	%rbx, %r11
	movq	16(%r11), %rbx
	movq	%rbx, %r11
	movq	16(%r11), %rbx
	movq	%rbx, %r11
	movq	8(%r11), %rbx
	movq	%rbx, %r11
	movq	16(%r11), %rbx
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

