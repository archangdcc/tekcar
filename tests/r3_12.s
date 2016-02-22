	.globl main
main:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$88, %rsp

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
	je then28331
	movq	%rbx, %rdi
	movq	$16, %rsi
	callq	collect
	jmp if_end28332
then28331:
if_end28332:
	movq	free_ptr(%rip), %rcx
	addq	$16, free_ptr(%rip)
	movq	%rcx, %r11
	movq	$3, 0(%r11)
	movq	%rcx, %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %rdx
	addq	$16, %rdx
	cmpq	%rdx, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rdx
	cmpq	$0, %rdx
	je then28333
	movq	%rcx, 0(%rbx)
	movq	%rbx, %rcx
	addq	$8, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rcx
	jmp if_end28334
then28333:
if_end28334:
	movq	free_ptr(%rip), %rdx
	addq	$16, free_ptr(%rip)
	movq	%rdx, %r11
	movq	$3, 0(%r11)
	movq	%rdx, %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %rsi
	addq	$16, %rsi
	cmpq	%rsi, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rsi
	cmpq	$0, %rsi
	je then28335
	movq	%rdx, 0(%rbx)
	movq	%rcx, 8(%rbx)
	movq	%rbx, %rcx
	addq	$16, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rdx
	movq	8(%rbx), %rcx
	jmp if_end28336
then28335:
if_end28336:
	movq	free_ptr(%rip), %rsi
	addq	$16, free_ptr(%rip)
	movq	%rsi, %r11
	movq	$3, 0(%r11)
	movq	%rsi, %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %rdi
	addq	$16, %rdi
	cmpq	%rdi, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %rdi
	cmpq	$0, %rdi
	je then28337
	movq	%rsi, 0(%rbx)
	movq	%rdx, 8(%rbx)
	movq	%rcx, 16(%rbx)
	movq	%rbx, %rcx
	addq	$24, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rsi
	movq	8(%rbx), %rdx
	movq	16(%rbx), %rcx
	jmp if_end28338
then28337:
if_end28338:
	movq	free_ptr(%rip), %rdi
	addq	$16, free_ptr(%rip)
	movq	%rdi, %r11
	movq	$3, 0(%r11)
	movq	%rdi, %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %r8
	addq	$16, %r8
	cmpq	%r8, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %r8
	cmpq	$0, %r8
	je then28339
	movq	%rdi, 0(%rbx)
	movq	%rsi, 8(%rbx)
	movq	%rdx, 16(%rbx)
	movq	%rcx, 24(%rbx)
	movq	%rbx, %rcx
	addq	$32, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rdi
	movq	8(%rbx), %rsi
	movq	16(%rbx), %rdx
	movq	24(%rbx), %rcx
	jmp if_end28340
then28339:
if_end28340:
	movq	free_ptr(%rip), %r8
	addq	$16, free_ptr(%rip)
	movq	%r8, %r11
	movq	$3, 0(%r11)
	movq	%r8, %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %r9
	addq	$16, %r9
	cmpq	%r9, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %r9
	cmpq	$0, %r9
	je then28341
	movq	%r8, 0(%rbx)
	movq	%rdi, 8(%rbx)
	movq	%rsi, 16(%rbx)
	movq	%rdx, 24(%rbx)
	movq	%rcx, 32(%rbx)
	movq	%rbx, %rcx
	addq	$40, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %r8
	movq	8(%rbx), %rdi
	movq	16(%rbx), %rsi
	movq	24(%rbx), %rdx
	movq	32(%rbx), %rcx
	jmp if_end28342
then28341:
if_end28342:
	movq	free_ptr(%rip), %r9
	addq	$16, free_ptr(%rip)
	movq	%r9, %r11
	movq	$3, 0(%r11)
	movq	%r9, %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %r10
	addq	$16, %r10
	cmpq	%r10, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %r10
	cmpq	$0, %r10
	je then28343
	movq	%r9, 0(%rbx)
	movq	%r8, 8(%rbx)
	movq	%rdi, 16(%rbx)
	movq	%rsi, 24(%rbx)
	movq	%rdx, 32(%rbx)
	movq	%rcx, 40(%rbx)
	movq	%rbx, %rcx
	addq	$48, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %r9
	movq	8(%rbx), %r8
	movq	16(%rbx), %rdi
	movq	24(%rbx), %rsi
	movq	32(%rbx), %rdx
	movq	40(%rbx), %rcx
	jmp if_end28344
then28343:
if_end28344:
	movq	free_ptr(%rip), %r10
	addq	$16, free_ptr(%rip)
	movq	%r10, %r11
	movq	$3, 0(%r11)
	movq	%r10, %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %r12
	addq	$16, %r12
	cmpq	%r12, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %r12
	cmpq	$0, %r12
	je then28345
	movq	%r10, 0(%rbx)
	movq	%r9, 8(%rbx)
	movq	%r8, 16(%rbx)
	movq	%rdi, 24(%rbx)
	movq	%rsi, 32(%rbx)
	movq	%rdx, 40(%rbx)
	movq	%rcx, 48(%rbx)
	movq	%rbx, %rcx
	addq	$56, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %r10
	movq	8(%rbx), %r9
	movq	16(%rbx), %r8
	movq	24(%rbx), %rdi
	movq	32(%rbx), %rsi
	movq	40(%rbx), %rdx
	movq	48(%rbx), %rcx
	jmp if_end28346
then28345:
if_end28346:
	movq	free_ptr(%rip), %r12
	addq	$16, free_ptr(%rip)
	movq	%r12, %r11
	movq	$3, 0(%r11)
	movq	%r12, %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %r13
	addq	$16, %r13
	cmpq	%r13, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %r13
	cmpq	$0, %r13
	je then28347
	movq	%r12, 0(%rbx)
	movq	%r10, 8(%rbx)
	movq	%r9, 16(%rbx)
	movq	%r8, 24(%rbx)
	movq	%rdi, 32(%rbx)
	movq	%rsi, 40(%rbx)
	movq	%rdx, 48(%rbx)
	movq	%rcx, 56(%rbx)
	movq	%rbx, %rcx
	addq	$64, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %r12
	movq	8(%rbx), %r10
	movq	16(%rbx), %r9
	movq	24(%rbx), %r8
	movq	32(%rbx), %rdi
	movq	40(%rbx), %rsi
	movq	48(%rbx), %rdx
	movq	56(%rbx), %rcx
	jmp if_end28348
then28347:
if_end28348:
	movq	free_ptr(%rip), %r13
	addq	$16, free_ptr(%rip)
	movq	%r13, %r11
	movq	$3, 0(%r11)
	movq	%r13, %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %r14
	addq	$16, %r14
	cmpq	%r14, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %r14
	cmpq	$0, %r14
	je then28349
	movq	%r13, 0(%rbx)
	movq	%r12, 8(%rbx)
	movq	%r10, 16(%rbx)
	movq	%r9, 24(%rbx)
	movq	%r8, 32(%rbx)
	movq	%rdi, 40(%rbx)
	movq	%rsi, 48(%rbx)
	movq	%rdx, 56(%rbx)
	movq	%rcx, 64(%rbx)
	movq	%rbx, %rcx
	addq	$72, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %r13
	movq	8(%rbx), %r12
	movq	16(%rbx), %r10
	movq	24(%rbx), %r9
	movq	32(%rbx), %r8
	movq	40(%rbx), %rdi
	movq	48(%rbx), %rsi
	movq	56(%rbx), %rdx
	movq	64(%rbx), %rcx
	jmp if_end28350
then28349:
if_end28350:
	movq	free_ptr(%rip), %r14
	addq	$16, free_ptr(%rip)
	movq	%r14, %r11
	movq	$3, 0(%r11)
	movq	%r14, %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %r15
	addq	$16, %r15
	cmpq	%r15, fromspace_end(%rip)
	setl	%al
	movzbq	%al, %r15
	cmpq	$0, %r15
	je then28351
	movq	%r14, 0(%rbx)
	movq	%r13, 8(%rbx)
	movq	%r12, 16(%rbx)
	movq	%r10, 24(%rbx)
	movq	%r9, 32(%rbx)
	movq	%r8, 40(%rbx)
	movq	%rdi, 48(%rbx)
	movq	%rsi, 56(%rbx)
	movq	%rdx, 64(%rbx)
	movq	%rcx, 72(%rbx)
	movq	%rbx, %rcx
	addq	$80, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %r14
	movq	8(%rbx), %r13
	movq	16(%rbx), %r12
	movq	24(%rbx), %r10
	movq	32(%rbx), %r9
	movq	40(%rbx), %r8
	movq	48(%rbx), %rdi
	movq	56(%rbx), %rsi
	movq	64(%rbx), %rdx
	movq	72(%rbx), %rcx
	jmp if_end28352
then28351:
if_end28352:
	movq	free_ptr(%rip), %r15
	addq	$16, free_ptr(%rip)
	movq	%r15, %r11
	movq	$3, 0(%r11)
	movq	%r15, %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %rax
	movq	%rax, -8(%rbp)
	addq	$16, -8(%rbp)
	movq	fromspace_end(%rip), %rax
	cmpq	-8(%rbp), %rax
	setl	%al
	movzbq	%al, %rax
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	je then28353
	movq	%r15, 0(%rbx)
	movq	%r14, 8(%rbx)
	movq	%r13, 16(%rbx)
	movq	%r12, 24(%rbx)
	movq	%r10, 32(%rbx)
	movq	%r9, 40(%rbx)
	movq	%r8, 48(%rbx)
	movq	%rdi, 56(%rbx)
	movq	%rsi, 64(%rbx)
	movq	%rdx, 72(%rbx)
	movq	%rcx, 80(%rbx)
	movq	%rbx, %rcx
	addq	$88, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %r15
	movq	8(%rbx), %r14
	movq	16(%rbx), %r13
	movq	24(%rbx), %r12
	movq	32(%rbx), %r10
	movq	40(%rbx), %r9
	movq	48(%rbx), %r8
	movq	56(%rbx), %rdi
	movq	64(%rbx), %rsi
	movq	72(%rbx), %rdx
	movq	80(%rbx), %rcx
	jmp if_end28354
then28353:
if_end28354:
	movq	free_ptr(%rip), %rax
	movq	%rax, -8(%rbp)
	addq	$16, free_ptr(%rip)
	movq	-8(%rbp), %r11
	movq	$3, 0(%r11)
	movq	-8(%rbp), %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %rax
	movq	%rax, -16(%rbp)
	addq	$16, -16(%rbp)
	movq	fromspace_end(%rip), %rax
	cmpq	-16(%rbp), %rax
	setl	%al
	movzbq	%al, %rax
	movq	%rax, -16(%rbp)
	cmpq	$0, -16(%rbp)
	je then28355
	movq	-8(%rbp), %rax
	movq	%rax, 0(%rbx)
	movq	%r15, 8(%rbx)
	movq	%r14, 16(%rbx)
	movq	%r13, 24(%rbx)
	movq	%r12, 32(%rbx)
	movq	%r10, 40(%rbx)
	movq	%r9, 48(%rbx)
	movq	%r8, 56(%rbx)
	movq	%rdi, 64(%rbx)
	movq	%rsi, 72(%rbx)
	movq	%rdx, 80(%rbx)
	movq	%rcx, 88(%rbx)
	movq	%rbx, %rcx
	addq	$96, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rax
	movq	%rax, -8(%rbp)
	movq	8(%rbx), %r15
	movq	16(%rbx), %r14
	movq	24(%rbx), %r13
	movq	32(%rbx), %r12
	movq	40(%rbx), %r10
	movq	48(%rbx), %r9
	movq	56(%rbx), %r8
	movq	64(%rbx), %rdi
	movq	72(%rbx), %rsi
	movq	80(%rbx), %rdx
	movq	88(%rbx), %rcx
	jmp if_end28356
then28355:
if_end28356:
	movq	free_ptr(%rip), %rax
	movq	%rax, -16(%rbp)
	addq	$16, free_ptr(%rip)
	movq	-16(%rbp), %r11
	movq	$3, 0(%r11)
	movq	-16(%rbp), %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %rax
	movq	%rax, -24(%rbp)
	addq	$16, -24(%rbp)
	movq	fromspace_end(%rip), %rax
	cmpq	-24(%rbp), %rax
	setl	%al
	movzbq	%al, %rax
	movq	%rax, -24(%rbp)
	cmpq	$0, -24(%rbp)
	je then28357
	movq	-16(%rbp), %rax
	movq	%rax, 0(%rbx)
	movq	-8(%rbp), %rax
	movq	%rax, 8(%rbx)
	movq	%r15, 16(%rbx)
	movq	%r14, 24(%rbx)
	movq	%r13, 32(%rbx)
	movq	%r12, 40(%rbx)
	movq	%r10, 48(%rbx)
	movq	%r9, 56(%rbx)
	movq	%r8, 64(%rbx)
	movq	%rdi, 72(%rbx)
	movq	%rsi, 80(%rbx)
	movq	%rdx, 88(%rbx)
	movq	%rcx, 96(%rbx)
	movq	%rbx, %rcx
	addq	$104, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rax
	movq	%rax, -16(%rbp)
	movq	8(%rbx), %rax
	movq	%rax, -8(%rbp)
	movq	16(%rbx), %r15
	movq	24(%rbx), %r14
	movq	32(%rbx), %r13
	movq	40(%rbx), %r12
	movq	48(%rbx), %r10
	movq	56(%rbx), %r9
	movq	64(%rbx), %r8
	movq	72(%rbx), %rdi
	movq	80(%rbx), %rsi
	movq	88(%rbx), %rdx
	movq	96(%rbx), %rcx
	jmp if_end28358
then28357:
if_end28358:
	movq	free_ptr(%rip), %rax
	movq	%rax, -24(%rbp)
	addq	$16, free_ptr(%rip)
	movq	-24(%rbp), %r11
	movq	$3, 0(%r11)
	movq	-24(%rbp), %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %rax
	movq	%rax, -32(%rbp)
	addq	$16, -32(%rbp)
	movq	fromspace_end(%rip), %rax
	cmpq	-32(%rbp), %rax
	setl	%al
	movzbq	%al, %rax
	movq	%rax, -32(%rbp)
	cmpq	$0, -32(%rbp)
	je then28359
	movq	-24(%rbp), %rax
	movq	%rax, 0(%rbx)
	movq	-16(%rbp), %rax
	movq	%rax, 8(%rbx)
	movq	-8(%rbp), %rax
	movq	%rax, 16(%rbx)
	movq	%r15, 24(%rbx)
	movq	%r14, 32(%rbx)
	movq	%r13, 40(%rbx)
	movq	%r12, 48(%rbx)
	movq	%r10, 56(%rbx)
	movq	%r9, 64(%rbx)
	movq	%r8, 72(%rbx)
	movq	%rdi, 80(%rbx)
	movq	%rsi, 88(%rbx)
	movq	%rdx, 96(%rbx)
	movq	%rcx, 104(%rbx)
	movq	%rbx, %rcx
	addq	$112, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rax
	movq	%rax, -24(%rbp)
	movq	8(%rbx), %rax
	movq	%rax, -16(%rbp)
	movq	16(%rbx), %rax
	movq	%rax, -8(%rbp)
	movq	24(%rbx), %r15
	movq	32(%rbx), %r14
	movq	40(%rbx), %r13
	movq	48(%rbx), %r12
	movq	56(%rbx), %r10
	movq	64(%rbx), %r9
	movq	72(%rbx), %r8
	movq	80(%rbx), %rdi
	movq	88(%rbx), %rsi
	movq	96(%rbx), %rdx
	movq	104(%rbx), %rcx
	jmp if_end28360
then28359:
if_end28360:
	movq	free_ptr(%rip), %rax
	movq	%rax, -32(%rbp)
	addq	$16, free_ptr(%rip)
	movq	-32(%rbp), %r11
	movq	$3, 0(%r11)
	movq	-32(%rbp), %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %rax
	movq	%rax, -40(%rbp)
	addq	$16, -40(%rbp)
	movq	fromspace_end(%rip), %rax
	cmpq	-40(%rbp), %rax
	setl	%al
	movzbq	%al, %rax
	movq	%rax, -40(%rbp)
	cmpq	$0, -40(%rbp)
	je then28361
	movq	-32(%rbp), %rax
	movq	%rax, 0(%rbx)
	movq	-24(%rbp), %rax
	movq	%rax, 8(%rbx)
	movq	-16(%rbp), %rax
	movq	%rax, 16(%rbx)
	movq	-8(%rbp), %rax
	movq	%rax, 24(%rbx)
	movq	%r15, 32(%rbx)
	movq	%r14, 40(%rbx)
	movq	%r13, 48(%rbx)
	movq	%r12, 56(%rbx)
	movq	%r10, 64(%rbx)
	movq	%r9, 72(%rbx)
	movq	%r8, 80(%rbx)
	movq	%rdi, 88(%rbx)
	movq	%rsi, 96(%rbx)
	movq	%rdx, 104(%rbx)
	movq	%rcx, 112(%rbx)
	movq	%rbx, %rcx
	addq	$120, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rax
	movq	%rax, -32(%rbp)
	movq	8(%rbx), %rax
	movq	%rax, -24(%rbp)
	movq	16(%rbx), %rax
	movq	%rax, -16(%rbp)
	movq	24(%rbx), %rax
	movq	%rax, -8(%rbp)
	movq	32(%rbx), %r15
	movq	40(%rbx), %r14
	movq	48(%rbx), %r13
	movq	56(%rbx), %r12
	movq	64(%rbx), %r10
	movq	72(%rbx), %r9
	movq	80(%rbx), %r8
	movq	88(%rbx), %rdi
	movq	96(%rbx), %rsi
	movq	104(%rbx), %rdx
	movq	112(%rbx), %rcx
	jmp if_end28362
then28361:
if_end28362:
	movq	free_ptr(%rip), %rax
	movq	%rax, -40(%rbp)
	addq	$16, free_ptr(%rip)
	movq	-40(%rbp), %r11
	movq	$3, 0(%r11)
	movq	-40(%rbp), %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %rax
	movq	%rax, -48(%rbp)
	addq	$16, -48(%rbp)
	movq	fromspace_end(%rip), %rax
	cmpq	-48(%rbp), %rax
	setl	%al
	movzbq	%al, %rax
	movq	%rax, -48(%rbp)
	cmpq	$0, -48(%rbp)
	je then28363
	movq	-40(%rbp), %rax
	movq	%rax, 0(%rbx)
	movq	-32(%rbp), %rax
	movq	%rax, 8(%rbx)
	movq	-24(%rbp), %rax
	movq	%rax, 16(%rbx)
	movq	-16(%rbp), %rax
	movq	%rax, 24(%rbx)
	movq	-8(%rbp), %rax
	movq	%rax, 32(%rbx)
	movq	%r15, 40(%rbx)
	movq	%r14, 48(%rbx)
	movq	%r13, 56(%rbx)
	movq	%r12, 64(%rbx)
	movq	%r10, 72(%rbx)
	movq	%r9, 80(%rbx)
	movq	%r8, 88(%rbx)
	movq	%rdi, 96(%rbx)
	movq	%rsi, 104(%rbx)
	movq	%rdx, 112(%rbx)
	movq	%rcx, 120(%rbx)
	movq	%rbx, %rcx
	addq	$128, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rax
	movq	%rax, -40(%rbp)
	movq	8(%rbx), %rax
	movq	%rax, -32(%rbp)
	movq	16(%rbx), %rax
	movq	%rax, -24(%rbp)
	movq	24(%rbx), %rax
	movq	%rax, -16(%rbp)
	movq	32(%rbx), %rax
	movq	%rax, -8(%rbp)
	movq	40(%rbx), %r15
	movq	48(%rbx), %r14
	movq	56(%rbx), %r13
	movq	64(%rbx), %r12
	movq	72(%rbx), %r10
	movq	80(%rbx), %r9
	movq	88(%rbx), %r8
	movq	96(%rbx), %rdi
	movq	104(%rbx), %rsi
	movq	112(%rbx), %rdx
	movq	120(%rbx), %rcx
	jmp if_end28364
then28363:
if_end28364:
	movq	free_ptr(%rip), %rax
	movq	%rax, -48(%rbp)
	addq	$16, free_ptr(%rip)
	movq	-48(%rbp), %r11
	movq	$3, 0(%r11)
	movq	-48(%rbp), %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %rax
	movq	%rax, -56(%rbp)
	addq	$16, -56(%rbp)
	movq	fromspace_end(%rip), %rax
	cmpq	-56(%rbp), %rax
	setl	%al
	movzbq	%al, %rax
	movq	%rax, -56(%rbp)
	cmpq	$0, -56(%rbp)
	je then28365
	movq	-48(%rbp), %rax
	movq	%rax, 0(%rbx)
	movq	-40(%rbp), %rax
	movq	%rax, 8(%rbx)
	movq	-32(%rbp), %rax
	movq	%rax, 16(%rbx)
	movq	-24(%rbp), %rax
	movq	%rax, 24(%rbx)
	movq	-16(%rbp), %rax
	movq	%rax, 32(%rbx)
	movq	-8(%rbp), %rax
	movq	%rax, 40(%rbx)
	movq	%r15, 48(%rbx)
	movq	%r14, 56(%rbx)
	movq	%r13, 64(%rbx)
	movq	%r12, 72(%rbx)
	movq	%r10, 80(%rbx)
	movq	%r9, 88(%rbx)
	movq	%r8, 96(%rbx)
	movq	%rdi, 104(%rbx)
	movq	%rsi, 112(%rbx)
	movq	%rdx, 120(%rbx)
	movq	%rcx, 128(%rbx)
	movq	%rbx, %rcx
	addq	$136, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rax
	movq	%rax, -48(%rbp)
	movq	8(%rbx), %rax
	movq	%rax, -40(%rbp)
	movq	16(%rbx), %rax
	movq	%rax, -32(%rbp)
	movq	24(%rbx), %rax
	movq	%rax, -24(%rbp)
	movq	32(%rbx), %rax
	movq	%rax, -16(%rbp)
	movq	40(%rbx), %rax
	movq	%rax, -8(%rbp)
	movq	48(%rbx), %r15
	movq	56(%rbx), %r14
	movq	64(%rbx), %r13
	movq	72(%rbx), %r12
	movq	80(%rbx), %r10
	movq	88(%rbx), %r9
	movq	96(%rbx), %r8
	movq	104(%rbx), %rdi
	movq	112(%rbx), %rsi
	movq	120(%rbx), %rdx
	movq	128(%rbx), %rcx
	jmp if_end28366
then28365:
if_end28366:
	movq	free_ptr(%rip), %rax
	movq	%rax, -56(%rbp)
	addq	$16, free_ptr(%rip)
	movq	-56(%rbp), %r11
	movq	$3, 0(%r11)
	movq	-56(%rbp), %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %rax
	movq	%rax, -64(%rbp)
	addq	$16, -64(%rbp)
	movq	fromspace_end(%rip), %rax
	cmpq	-64(%rbp), %rax
	setl	%al
	movzbq	%al, %rax
	movq	%rax, -64(%rbp)
	cmpq	$0, -64(%rbp)
	je then28367
	movq	-56(%rbp), %rax
	movq	%rax, 0(%rbx)
	movq	-48(%rbp), %rax
	movq	%rax, 8(%rbx)
	movq	-40(%rbp), %rax
	movq	%rax, 16(%rbx)
	movq	-32(%rbp), %rax
	movq	%rax, 24(%rbx)
	movq	-24(%rbp), %rax
	movq	%rax, 32(%rbx)
	movq	-16(%rbp), %rax
	movq	%rax, 40(%rbx)
	movq	-8(%rbp), %rax
	movq	%rax, 48(%rbx)
	movq	%r15, 56(%rbx)
	movq	%r14, 64(%rbx)
	movq	%r13, 72(%rbx)
	movq	%r12, 80(%rbx)
	movq	%r10, 88(%rbx)
	movq	%r9, 96(%rbx)
	movq	%r8, 104(%rbx)
	movq	%rdi, 112(%rbx)
	movq	%rsi, 120(%rbx)
	movq	%rdx, 128(%rbx)
	movq	%rcx, 136(%rbx)
	movq	%rbx, %rcx
	addq	$144, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rax
	movq	%rax, -56(%rbp)
	movq	8(%rbx), %rax
	movq	%rax, -48(%rbp)
	movq	16(%rbx), %rax
	movq	%rax, -40(%rbp)
	movq	24(%rbx), %rax
	movq	%rax, -32(%rbp)
	movq	32(%rbx), %rax
	movq	%rax, -24(%rbp)
	movq	40(%rbx), %rax
	movq	%rax, -16(%rbp)
	movq	48(%rbx), %rax
	movq	%rax, -8(%rbp)
	movq	56(%rbx), %r15
	movq	64(%rbx), %r14
	movq	72(%rbx), %r13
	movq	80(%rbx), %r12
	movq	88(%rbx), %r10
	movq	96(%rbx), %r9
	movq	104(%rbx), %r8
	movq	112(%rbx), %rdi
	movq	120(%rbx), %rsi
	movq	128(%rbx), %rdx
	movq	136(%rbx), %rcx
	jmp if_end28368
then28367:
if_end28368:
	movq	free_ptr(%rip), %rax
	movq	%rax, -64(%rbp)
	addq	$16, free_ptr(%rip)
	movq	-64(%rbp), %r11
	movq	$3, 0(%r11)
	movq	-64(%rbp), %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %rax
	movq	%rax, -72(%rbp)
	addq	$16, -72(%rbp)
	movq	fromspace_end(%rip), %rax
	cmpq	-72(%rbp), %rax
	setl	%al
	movzbq	%al, %rax
	movq	%rax, -72(%rbp)
	cmpq	$0, -72(%rbp)
	je then28369
	movq	-64(%rbp), %rax
	movq	%rax, 0(%rbx)
	movq	-56(%rbp), %rax
	movq	%rax, 8(%rbx)
	movq	-48(%rbp), %rax
	movq	%rax, 16(%rbx)
	movq	-40(%rbp), %rax
	movq	%rax, 24(%rbx)
	movq	-32(%rbp), %rax
	movq	%rax, 32(%rbx)
	movq	-24(%rbp), %rax
	movq	%rax, 40(%rbx)
	movq	-16(%rbp), %rax
	movq	%rax, 48(%rbx)
	movq	-8(%rbp), %rax
	movq	%rax, 56(%rbx)
	movq	%r15, 64(%rbx)
	movq	%r14, 72(%rbx)
	movq	%r13, 80(%rbx)
	movq	%r12, 88(%rbx)
	movq	%r10, 96(%rbx)
	movq	%r9, 104(%rbx)
	movq	%r8, 112(%rbx)
	movq	%rdi, 120(%rbx)
	movq	%rsi, 128(%rbx)
	movq	%rdx, 136(%rbx)
	movq	%rcx, 144(%rbx)
	movq	%rbx, %rcx
	addq	$152, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rax
	movq	%rax, -64(%rbp)
	movq	8(%rbx), %rax
	movq	%rax, -56(%rbp)
	movq	16(%rbx), %rax
	movq	%rax, -48(%rbp)
	movq	24(%rbx), %rax
	movq	%rax, -40(%rbp)
	movq	32(%rbx), %rax
	movq	%rax, -32(%rbp)
	movq	40(%rbx), %rax
	movq	%rax, -24(%rbp)
	movq	48(%rbx), %rax
	movq	%rax, -16(%rbp)
	movq	56(%rbx), %rax
	movq	%rax, -8(%rbp)
	movq	64(%rbx), %r15
	movq	72(%rbx), %r14
	movq	80(%rbx), %r13
	movq	88(%rbx), %r12
	movq	96(%rbx), %r10
	movq	104(%rbx), %r9
	movq	112(%rbx), %r8
	movq	120(%rbx), %rdi
	movq	128(%rbx), %rsi
	movq	136(%rbx), %rdx
	movq	144(%rbx), %rcx
	jmp if_end28370
then28369:
if_end28370:
	movq	free_ptr(%rip), %rax
	movq	%rax, -72(%rbp)
	addq	$16, free_ptr(%rip)
	movq	-72(%rbp), %r11
	movq	$3, 0(%r11)
	movq	-72(%rbp), %r11
	movq	$1, 8(%r11)
	movq	free_ptr(%rip), %rax
	movq	%rax, -80(%rbp)
	addq	$16, -80(%rbp)
	movq	fromspace_end(%rip), %rax
	cmpq	-80(%rbp), %rax
	setl	%al
	movzbq	%al, %rax
	movq	%rax, -80(%rbp)
	cmpq	$0, -80(%rbp)
	je then28371
	movq	-72(%rbp), %rax
	movq	%rax, 0(%rbx)
	movq	-64(%rbp), %rax
	movq	%rax, 8(%rbx)
	movq	-56(%rbp), %rax
	movq	%rax, 16(%rbx)
	movq	-48(%rbp), %rax
	movq	%rax, 24(%rbx)
	movq	-40(%rbp), %rax
	movq	%rax, 32(%rbx)
	movq	-32(%rbp), %rax
	movq	%rax, 40(%rbx)
	movq	-24(%rbp), %rax
	movq	%rax, 48(%rbx)
	movq	-16(%rbp), %rax
	movq	%rax, 56(%rbx)
	movq	-8(%rbp), %rax
	movq	%rax, 64(%rbx)
	movq	%r15, 72(%rbx)
	movq	%r14, 80(%rbx)
	movq	%r13, 88(%rbx)
	movq	%r12, 96(%rbx)
	movq	%r10, 104(%rbx)
	movq	%r9, 112(%rbx)
	movq	%r8, 120(%rbx)
	movq	%rdi, 128(%rbx)
	movq	%rsi, 136(%rbx)
	movq	%rdx, 144(%rbx)
	movq	%rcx, 152(%rbx)
	movq	%rbx, %rcx
	addq	$160, %rcx
	movq	%rcx, %rdi
	movq	$16, %rsi
	callq	collect
	movq	0(%rbx), %rax
	movq	%rax, -72(%rbp)
	movq	8(%rbx), %rax
	movq	%rax, -64(%rbp)
	movq	16(%rbx), %rax
	movq	%rax, -56(%rbp)
	movq	24(%rbx), %rax
	movq	%rax, -48(%rbp)
	movq	32(%rbx), %rax
	movq	%rax, -40(%rbp)
	movq	40(%rbx), %rax
	movq	%rax, -32(%rbp)
	movq	48(%rbx), %rax
	movq	%rax, -24(%rbp)
	movq	56(%rbx), %rax
	movq	%rax, -16(%rbp)
	movq	64(%rbx), %rax
	movq	%rax, -8(%rbp)
	movq	72(%rbx), %r15
	movq	80(%rbx), %r14
	movq	88(%rbx), %r13
	movq	96(%rbx), %r12
	movq	104(%rbx), %r10
	movq	112(%rbx), %r9
	movq	120(%rbx), %r8
	movq	128(%rbx), %rdi
	movq	136(%rbx), %rsi
	movq	144(%rbx), %rdx
	movq	152(%rbx), %rcx
	jmp if_end28372
then28371:
if_end28372:
	movq	free_ptr(%rip), %rbx
	addq	$16, free_ptr(%rip)
	movq	%rbx, %r11
	movq	$3, 0(%r11)
	movq	%rbx, %r11
	movq	$1, 8(%r11)
	movq	%rcx, %r11
	movq	8(%r11), %rcx
	movq	%rdx, %r11
	movq	8(%r11), %rdx
	movq	%rsi, %r11
	movq	8(%r11), %rsi
	movq	%rdi, %r11
	movq	8(%r11), %rdi
	movq	%r8, %r11
	movq	8(%r11), %r8
	movq	%r9, %r11
	movq	8(%r11), %r9
	movq	%r10, %r11
	movq	8(%r11), %r10
	movq	%r12, %r11
	movq	8(%r11), %r12
	movq	%r13, %r11
	movq	8(%r11), %r13
	movq	%r14, %r11
	movq	8(%r11), %r14
	movq	%r15, %r11
	movq	8(%r11), %r15
	movq	-8(%rbp), %r11
	movq	8(%r11), %rax
	movq	%rax, -8(%rbp)
	movq	-16(%rbp), %r11
	movq	8(%r11), %rax
	movq	%rax, -16(%rbp)
	movq	-24(%rbp), %r11
	movq	8(%r11), %rax
	movq	%rax, -24(%rbp)
	movq	-32(%rbp), %r11
	movq	8(%r11), %rax
	movq	%rax, -32(%rbp)
	movq	-40(%rbp), %r11
	movq	8(%r11), %rax
	movq	%rax, -40(%rbp)
	movq	-48(%rbp), %r11
	movq	8(%r11), %rax
	movq	%rax, -48(%rbp)
	movq	-56(%rbp), %r11
	movq	8(%r11), %rax
	movq	%rax, -56(%rbp)
	movq	-64(%rbp), %r11
	movq	8(%r11), %rax
	movq	%rax, -64(%rbp)
	movq	-72(%rbp), %r11
	movq	8(%r11), %rax
	movq	%rax, -72(%rbp)
	movq	%rbx, %r11
	movq	8(%r11), %rbx
	addq	$21, %rbx
	addq	%rbx, -72(%rbp)
	movq	-64(%rbp), %rbx
	addq	-72(%rbp), %rbx
	addq	%rbx, -56(%rbp)
	movq	-48(%rbp), %rbx
	addq	-56(%rbp), %rbx
	addq	%rbx, -40(%rbp)
	movq	-32(%rbp), %rbx
	addq	-40(%rbp), %rbx
	addq	%rbx, -24(%rbp)
	movq	-16(%rbp), %rbx
	addq	-24(%rbp), %rbx
	addq	%rbx, -8(%rbp)
	movq	%r15, %rbx
	addq	-8(%rbp), %rbx
	addq	%rbx, %r14
	movq	%r13, %rbx
	addq	%r14, %rbx
	addq	%rbx, %r12
	movq	%r10, %rbx
	addq	%r12, %rbx
	addq	%rbx, %r9
	movq	%r8, %rbx
	addq	%r9, %rbx
	addq	%rbx, %rdi
	movq	%rsi, %rbx
	addq	%rdi, %rbx
	addq	%rbx, %rdx
	movq	%rcx, %rbx
	addq	%rdx, %rbx
	movq	%rbx, %rax

	movq	%rax, %rdi
	callq	print_int
	movq	$0, %rax
	addq	$88, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq

