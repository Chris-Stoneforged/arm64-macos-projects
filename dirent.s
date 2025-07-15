    .global 	_main
    .align 	2
    .text

    .equ	INODE_OFF, 0
    .equ	TYPE_OFF, 18
    .equ	DNAME_OFF, 20

    // x19: DIR*
    // sp+24: argv[1] (for perror)
    // sp+0: d_ino, d_type (stack)
    // sp+16: d_name pointer

_main:
    stp		x29, x30, [sp, -16]!
    mov		x29, sp

    sub		sp, sp, 32
    ldr		x0, [x1, 8]		// Deref the pointer to the first argv
    str		x0, [sp, 24]		// Store that pointer on the stack

    bl		_opendir
    cbz		x0, on_error
    mov		x19, x0			// Store DIR* in x19

    bl		___error		// Reset errno
    str		xzr, [x0]

loop_start:
    mov		x0, x19			// Make sure x0 has the DIR*
    bl		_readdir
    cbz		x0, loop_end

    ldr		x1, [x0, INODE_OFF]	// Laod inode number at offset 0
    ldrb	w2, [x0, TYPE_OFF]	// Load file type at offset 18
    stp		x1, x2, [sp]		// Store that pair on the stack

    add		x3, x0, DNAME_OFF	// Add dname offset to x0, gives pointer to dname
    str		x3, [sp, 16]		// Store pointer to dname on stack

    adrp	x0, fmt@PAGE
    add		x0, x0, fmt@PAGEOFF
    bl		_printf
    b		loop_start
    
loop_end:
    bl		___error
    ldr		x0, [x0]
    cbnz	x0, on_error		// Got to the end of the loop, but check errno to see if we got an error

    mov		x0, x19
    bl		_closedir
    cbnz	x0, on_error

    mov		w0, wzr
    b		program_end

on_error:
    ldr		x0, [sp, 24]		// Load the pointer to the first argv and pass to perror so we can see the argument
    bl		_perror
    mov		w0, 1

program_end:
    add 	sp, sp, 32
    ldp		x29, x30, [sp], 16
    ret


    .data
    .align 3

fmt:
    .asciz	"%-20lu 0x%02x %s\n"
