[BITS 16]
[ORG 0x0000]      ; This code is intended to be loaded starting at 0x1000:0x0000
                  ; Which is physical address 0x10000. ORG represents the offset
                  ; from the beginning of our segment.

; Our bootloader jumped to 0x1000:0x0000 which sets CS=0x1000 and IP=0x0000
; We need to manually set the DS register so it can properly find our variables

mov ax, cs
mov ds, ax   	; Copy CS to DS (we can't do it directly so we use AX temporarily)

main:
	mov ah, 0x00 	;Set video mode
	mov al, 0x13	;graphics, 320x200 res, 8x8 pixel box
	int 0x10

	mov ah, 0x0c	;Write graphics pixel
	mov bh, 0x00 	;page #0

	;call _print_tittle
	call tittle
	call _lvl1
	call _lvl2
	call _lvl3

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

section .data
	mainMenuDelay dw 5  
	title db '--- TETRIS 86 ---$',0
	lvl1 db 'LEVEL 1',0
	lvl2 db 'LEVEL 2',0
	lvl3 db 'LEVEL 3',0
	exitGame db 'EXIT GAME$',0
	blankText db '         $',0
	v_msg	db 'Retiremos Operavitos', 0
	go_msg	db 'Game Over', 0

	screenWidth dw 320
	sceenHeight dw 200

	lvlSelect db 1
	blink db 1   
