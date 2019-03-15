%define BGCOLOR 8 ; 0..6, 8

org 0x0000
mov ax, cs
mov ds, ax   	; Copy CS to DS (we can't do it directly so we use AX temporarily)

        clc
        jc      boot
        mov     si,0x0100
        mov     di,0x7c00
        mov     cx,512
        rep     movsb
        xchg    ax,cx
        call    menu
        ret

boot    mov     sp,0xffff
        push    cs
        
menu
	inc     ax
    int     0x10
    mov     ah,0x01
    mov     cx,0x2000
    int     0x10
	cli

		
	call tittle
	call _lvl1
	call _lvl2
	call _lvl3

	;call _clear_screen
    	

	call halt


halt:
	mov ah, 0		;Set ah to 0
	int 0x16		;Get keystroke interrupt
	cmp ah, 0x1c	;Restart if enter arrow pressed
	;call _clear_screen
	je play
	jmp halt

;Print tittle string
tittle:
	mov si, title
	mov bl, 2   ;Set green color
	mov dh, 4	;Set char print row
	mov dl, 12	;Set char print column
	mov bh, 0   ;Set page 0lvl1
	mov cx, 1	;Set number of times
	call msg_loop

	ret 

;Print tittle string
erase:
	mov si, lvl1
	mov bl, 0   ;Set green color
	mov dh, 4	;Set char print row
	mov dl, 12	;Set char print column
	mov bh, 0   ;Set page 0lvl1
	mov cx, 1	;Set number of times
	call msg_loop

	ret 

;Print lvl1 string
_lvl1:
	mov si, lvl1
	mov bl, 2   ;Set green color
	mov dh, 15	;Set char print row
	mov dl, 12	;Set char print column
	mov bh, 0   ;Set page 0lvl1
	mov cx, 1	;Set number of times	
	call msg_loop

	ret
	 
;Print lvl2 string
_lvl2:
	mov si, lvl2
	mov bl, 2   ;Set green color
	mov dh, 17	;Set char print row
	mov dl, 12	;Set char print column
	mov bh, 0   ;Set page 0lvl1
	mov cx, 1	;Set number of times
	call msg_loop

	ret 

;Print lvl3 string
_lvl3:
	mov si, lvl3
	mov bl, 2   ;Set green color
	mov dh, 19	;Set char print row
	mov dl, 12	;Set char print column
	mov bh, 0   ;Set page 0lvl1
	mov cx, 1	;Set number of times
	call msg_loop

	ret

msg_loop:
	mov ah, 0x2	;Set cursor position interrupt
	int 10h
	lodsb		;Move si pointer contents to al
	or al, al	;Break if end of string
	jz return
	mov ah, 0xa	;Teletype output interrupt
	int 10h		;
	inc dl		;Increment column index
	jmp msg_loop	;Loop to itself

;Return from procedure
return:
	ret

fall    push    cs
        pop     ds
        pop     es
        mov     dx,0x03f2
        xor     ax,ax
        out     dx,al
        call    play
        jmp     word 0xffff:0x0000

play    
		inc     ax
        int     0x10
        mov     ah,0x01
        mov     cx,0x2000
        int     0x10
        cli
		call erase
		call _to_fix_text
    	call _print_game_level
    	call _print_hot_keys
    	call _print_next_piece
    	call _print_score_text
    	call _print_score
        xor     ax,ax
        push    ax
        push    ds
        mov     ds,ax
        mov     si,8*4
        mov     di,oldintr
        movsw
        movsw
        movsw
        movsw
        pop     ds
        push    es
        mov     es,ax
        mov     di,8*4
        mov     si,newintr
        mov     ax,cs
		
        movsw
        stosw
        movsw
        stosw
        pop     es
        call    blc_new
        sti
.play   hlt
        cmp     [play],byte 0x40
        je      .play
        cli
        mov     si,oldintr
        pop     es
        mov     di,8*4
        movsw
        movsw
        movsw
        movsw
        sti
        mov     ax,0x0003
        int     0x10
        ret

timer   dec     byte [fall]
        jnz     intrret
        mov     [fall],byte 4
        call    blc_rem
        inc     byte [blocky]
        call    blc_try
        jc      intrret
        call    blc_new
        jmp     short intrret

keyb    call    blc_rem
        in      al,0x60
        cmp     al,72
        je      .72
        cmp     al,75
        je      .75
        cmp     al,77
        je      .77
        cmp     al,80
        je      .80
        cmp     al,1
        je      .1
.end    call    blc_try
        jmp     short intrret
.1      call    blc_new.exit
        jmp     short .end
.72     xchg    ax,bp
        cmp     al,0
        je      .72_end
        cmp     al,3
        jae     .72_1
        test    ah,1
        jnz     .72_1
        call    blc_rot
        call    blc_rot
.72_1   call    blc_rot
        inc     ah
.72_end xchg    bp,ax
        jmp     short .end
.75     dec     byte [blockx]
        jmp     short .end
.77     inc     byte [blockx]
        jmp     short .end
.80     inc     byte [blocky]
        call    blc_tst
        jc      .80
        dec     byte [blocky]
        call    blc_put
        call    blc_new

intrret mov     al,0x20
        out     0x20,al
        iret

blc_new call    lines
        mov     di,block
        mov     si,blocks
.rand   in      ax,0x40
        and     ax,111b
        dec     ax
        js      .rand
        mov     bp,ax
        shl     ax,1
        add     si,ax
        mov     ax,0x0300
        movsw
        stosw
        call    blc_try
        jc      .end
.exit   dec     byte [play]
.end    ret

blc_rot mov     bx,[block]
        mov     cx,4
        rol     bx,cl
.1      push    cx
        mov     cx,0x0404
.2      rol     bx,cl
        rcl     dx,1
        dec     ch
        jnz     .2
        ror     bx,1
        pop     cx
        loop    .1
        mov     [block],dx
        ret

blc_try call    blc_tst
        pushf
        call    blc_pos
        call    blc_put
        popf
        ret

blc_pos mov     si,bsave
        mov     di,block
        jnc     .ok
        xchg    si,di
.ok     movsw
        movsw
        ret

blc_rem mov     bl,BGCOLOR
        jmp     short blc_put.draw
blc_put mov     bl,9
        add     bx,bp
.draw   stc
        call    blc_pos
        jmp     short blc
blc_tst clc
blc     pushf
        mov     cx,15
.next   mov     ax,1
        shl     ax,cl
        test    [block],ax
        jz      .ok
        mov     ax,cx
        mov     dl,4
        div     dl
        add     ax,[blocky]
        dec     al
        xchg    dx,ax
        popf
        pushf
        call    screen
        jc      .ok
        cmp     al,BGCOLOR
        je      .ok
        popf
        ret
.ok     loop    .next
        pop     ax
        stc
        ret

lines   clc
        mov     dl,20
.y      dec     dl
        js      .end
.newx   mov     dh,9
.x      jc      .x2
        call    screen
        cmp     al,BGCOLOR
        je      .y
        clc
        jmp     short .next
.x2     dec     dl
        jns     .1
        mov     al,BGCOLOR
        jmp     short .2
.1      clc
        call    screen
.2      inc     dl
        xchg    bx,ax
        stc
        call    screen
.next   dec     dh
        jns     .x
        jc      .y
        push    dx
        stc
        call    .newx
        clc
        pop     dx
        jmp     short .newx
.end    ret

screen  push    ds
        pushf
        mov     ax,0xb800
        mov     ds,ax
        mov     al,dl
        mov     ah,40
        mul     ah
        add     al,dh
        adc     ah,0
        shl     ax,1
        add     ax,0x00be
        xchg    si,ax
        popf
        jc      .put
.get    inc     si
        lodsb
        pop     ds
        ret
.put    mov     ah,bl
        mov     al,'�'
        mov     [si],ax
        pop     ds
        ret

		;
; Turn black the screen
;
_clear_screen:
    mov ax, word [sceenHeight]
    mov bx, word [screenWidth]
    mov di, 0
    mov dl, 0
    call _draw_rectangle

    ret

;
;   Method used to print current level on game initialization
;
_print_game_level:
    mov si, lvl3
    cmp byte [lvlSelect], 3
    je _print_game_level_aux

    mov si, lvl2
    cmp byte [lvlSelect], 2
    je _print_game_level_aux

    mov si, lvl1

_print_game_level_aux:
    mov DH, 4
    mov DL, 17
    call msg_loop

    ret

_to_fix_text:
    mov si, blankText
    mov bl, 2   ;Set green color
	mov dh, 4	;Set char print row
	mov dl, 12	;Set char print column
	mov bh, 0   ;Set page 0lvl1
	mov cx, 1	;Set number of times
    call msg_loop

;
; Print hotkeys on game initialization 
;
_print_hot_keys:

    mov si, hotkeys
    mov DH, 9
    mov DL, 1
    call msg_loop

    mov si, hotkeys1
    mov DH, 11
    mov DL, 1
    call msg_loop

    mov si, hotkeys2
    mov DH, 12
    mov DL, 1
    call msg_loop

    mov si, hotkeys3
    mov DH, 13
    mov DL, 1
    call msg_loop

    mov BX, hotkeys4
    mov DH, 14
    mov DL, 1
    call msg_loop

    mov si, hotkeys5
    mov DH, 15
    mov DL, 1
    call msg_loop

    mov si, hotkeys6
    mov DH, 16
    mov DL, 1
    call msg_loop

    ret

;
; print next piece on game initialation
;
_print_next_piece:
    mov si, nextPiece
    mov DH, 11
    mov DL, 26
    call msg_loop

    ret    

;
; print next piece on game initialation
;
_print_score_text:
    mov si, scoreText
    mov DH, 8
    mov DL, 26
    call msg_loop

    ret  

;
; print score variable
;
_print_score:

    mov word ax, [score]
    mov dl, 100
    div dl ; hundreds in al, remainder in ah 
    mov cl, '0'
    add cl, al
    mov byte [msg_score_buffer], cl ; set hundreds digit
    
    mov al, ah ; divide remainder again
    xor ah, ah
    mov dl, 10
    div dl ; tens in al, remainder in ah
    mov cl, '0'
    add cl, al
    mov byte [msg_score_buffer + 1], cl ; set tens digit
    
    mov cl, '0'
    add cl, ah
    mov byte [msg_score_buffer + 2], cl ; set units digit
    
    mov si, msg_score_buffer
    mov dh, 9
    mov dl, 26
    call msg_loop
    
    ret

;
; Method used to print press any key
;     
_print_press_any_key:

    mov BX, pressAnyKey
    mov DH, 23
    mov DL, 14

    call msg_loop

    ret

;
; Draw a rectangle at the specified location and using the specified colour
;
; Input:
;      ax - height
;      bx - width
;      di - position
;      dl - colour
;
_draw_rectangle:
    push di
    push dx
    push cx
    mov cx, ax ; for each horizontal line (there are [height] of them)

blocks  dw      1632, 1728, 3168, 240, 736, 1248, 2272
newintr dw      timer, keyb

section .bss

block   resw    1
blocky  resb    1
blockx  resb    1
bsave   resb    4
oldintr resd    2

section .data

    mainMenuDelay dw 5

    lvlSelect db 1
    blink db 1  

    title db '--- TETRIS 86 ---', 0
	lvl1 db 'LEVEL 1', 0
    lvl2 db 'LEVEL 2', 0
    lvl3 db 'LEVEL 3', 0

	exitGame db 'EXIT GAME', 0
    blankText db '         ', 0

    hotkeys  db 'HOTKEYS', 0
    hotkeys1 db 'Left: ->', 0
    hotkeys2 db 'Right: <-', 0

    hotkeys3 db 'Down: v', 0
    hotkeys4 db 'Rotate Left: Q', 0
    hotkeys5 db 'Rotate Right: W', 0
    hotkeys6 db 'Exit Game: Esc', 0

    victory  db 'VICTORY', 0
    gameOver db 'GAME OVER', 0

    scoreText db 'SCORE:', 0

    pressAnyKey db 'Press Any Key', 0

    screenWidth dw 320
    sceenHeight dw 200

    nextPiece db 'NEXT PIECE$'

    previewPieceSpawn dw 30255

    previewPiece0 dw 0
    previewPiece1 dw 0
    previewPiece2 dw 0
    previewPiece3 dw 0
    previewPieceColor dq 0

    gameFieldSpawn dw 30240

    currentPiece0 dw 0
    currentPiece1 dw 0
    currentPiece2 dw 0
    currentPiece3 dw 0
    currentPieceColor dq 0

    square0 dw 0
    square1 dw 1
    square2 dw 320
    square3 dw 321
    squareColor dq 0x9

    bar0 dw 0
    bar1 dw 320
    bar2 dw 640
    bar3 dw 960
    barColor dq 0xE

    zigzag0 dw 0
    zigzag1 dw 1
    zigzag2 dw 321
    zigzag3 dw 322
    zigzagColor dq 0xA

    l0 dw 0
    l1 dw 320
    l2 dw 640
    l3 dw 641
    lColor dq 0xC

    t0 dw 0
    t1 dw 320
    t2 dw 321
    t3 dw 640
    tColor dq 0xB

    random5 db 0

    counter db 0

    msg_score_buffer db "000$" ; holds the string representation of score
    score dw 0 ; keeps score (representing total number of cleared lines)