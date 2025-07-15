    .global _main
    .align 2
    .text

_main:
    stp		x29, x30, [sp, -16]!
    mov		x29, sp

1:
    mov		x0, 1
    adrp	x1, buf@PAGE
    add		x1, x1, buf@PAGEOFF
    mov		x2, 8
    bl		_read

    # Check return value
    cmp		x0, 1
    ble		2f

    mov		x0, 1
    adrp	x1, buf@PAGE
    add		x1, x1, buf@PAGEOFF
    mov		x2, 8
    bl		_write

    # Zero out the buffer
    adrp	x1, buf@PAGE
    add		x1, x1, buf@PAGEOFF
    str		xzr, [x1]
    
    b		1b
2:
    mov		x0, xzr
    bl		_perror

    ldp		x29, x30, [sp], 16
    mov		w0, wzr
    ret
    

    .data
    .align 3

buf:
    .space	8
fmt:
    .asciz	"%d\n"
