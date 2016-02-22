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
	je then27925
	movq	%rbx, %rdi
	movq	$24, %rsi
	callq	collect
	jmp if_end27926
then27925:
if_end27926:
	movq	free_ptr(%rip), %rbx
	addq	$24, free_ptr(%rip)
	movq	%rbx, %r11
	movq	$5, 0(%r11)
	movq	%rbx, %r11
	movq	$20, 8(%r11)
	movq	%rbx, %r11
	movq	$22, 16(%r11)
	movq	%rbx, %r11
	movq	8(%r11), %rcx
	movq	%rbx, %r11
	movq	16(%r11), %rbx
	addq	%rbx, %rcx
	movq	%rcx, %rax

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

