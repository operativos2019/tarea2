[BITS 16]
[ORG 0x0000] 

section .text

mov ax, cs
mov ds, ax   	; Copy CS to DS (we can't do it directly so we use AX temporarily)

        clc
        jc      boot
        mov     si,0x0100
        mov     di,0x7c00
        mov     cx,512
        rep     movsb
        xchg    ax,cx
        call    start
        ret

boot    mov     sp,0xffff
        push    cs

start:

    mov AX, 0x13  ;enter graphical mode 
    int 0x10

    jmp _main_menu

finish: 

    mov AX, 3  ;exit graphical mode 
    int 0x10

    int 0x21    ;DOS interruption

    ret

;
;main menu display loop 
;
_main_menu: 

    call _print_menu_tittle
    call _print_menu_lvl1
    call _print_menu_lvl2
    call _print_menu_lvl3
    call _print_menu_exitGame

    mov BX, word [mainMenuDelay]
    call _sleep

 	mov AH, 0x1		;Set ah to 1
	int 0x16		    ;Check keystroke interrupt
	jz  _main_menu	;Return if no keystroke

	mov AH, 0x0		;Set ah to 0
	int 0x16		    ;Get keystroke interrupt

    cmp AH, 0x01    
    je _menu_escape ;exit game if Esc pressed

    cmp AH, 0x1C    
    je _menu_enter  ;select option if Enter pressed
    
    cmp AH, 0x48	
	je _menu_up     ;Jump if up arrow pressed

    cmp AH, 0x50	
	je _menu_down   ;Jump if down arrow pressed
    
    jmp _main_menu        

_start_game:

    call _clear_screen
    call _print_game_level
    call _print_hot_keys
    call _print_next_piece
    call _print_score_text
    call _print_score
    call _print_game_field

    call _load_preview_piece
    call _move_preview_to_preview
    call _load_current_piece 

    call _load_preview_piece
    call _move_preview_to_preview
    call _print_preview_piece

    call _move_current_to_spawn
    call _print_current_piece
    call _reset_counter

_game_loop:

    mov BX, 1
    call _sleep

    dec byte [counter]
    cmp byte [counter], 0
    jne _continue
    call _move_down_current_piece
    cmp AX, 1
    je _game_lose
    call _reset_counter
_continue:    

    mov AH, 0x1		;Set ah to 1
	int 0x16		    ;Check keystroke interrupt
	jz  _game_loop	;Return if no keystroke

	mov AH, 0x0		;Set ah to 0
	int 0x16		    ;Get keystroke interrupt

    cmp AH, 0x01    
    je _game_escape ;exit game to menu Esc pressed

    cmp AH, 0x18    
    je _game_win         ;win game

    cmp AH, 0x19    
    je _game_lose        ;lose game

    cmp AH, 0x17
    je _increment_score 

    cmp AH, 0x50   
    je _game_down        ;down key pressed

    cmp AH, 0x4b   
    je _game_left        ;left key pressed

    cmp AH, 0x4d   
    je _game_right       ;right key pressed

    jmp _game_loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                 FUNCTIONS                ;;;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; If escape key pressed on main menu exit execution
;
_menu_escape:
    jmp finish  

;
; select option on main menu
;
_menu_enter: 
    cmp byte [lvlSelect], 4
    je finish 

    mov word [score], 200
    cmp byte [lvlSelect], 3
    je _start_game

    mov word [score], 100
    cmp byte [lvlSelect], 2
    je _start_game

    mov word [score], 0
    jmp _start_game

;
; move one option up on main menu
;
_menu_up:
    cmp byte [lvlSelect], 1
    je _main_menu
    dec byte [lvlSelect]
    jmp _main_menu

;
; move one option down on main menu
;
_menu_down:   
    cmp byte [lvlSelect], 4
    je _main_menu
    inc byte [lvlSelect]
    jmp _main_menu    

;
; Method used to exit game to main menu
;
_game_escape:
    call _clear_screen
    jmp _main_menu

;
; move the piece 1 space down
;
_game_down:
    call _move_down_current_piece
    call _reset_counter
    jmp _game_loop    

;
; move the piece 1 space left
;
_game_left:
    call _move_left_current_piece
    jmp _game_loop    

;
; move the piece 1 space right
;
_game_right:
    call _move_right_current_piece
    jmp _game_loop        


;
; increments the score 10 points
;
_increment_score:
    add word [score], 10
    call _print_score

    cmp byte [lvlSelect], 3 
    jne _increment_score_lvl2
    cmp word [score], 300 
    je _game_win

_increment_score_lvl2:
    cmp byte [lvlSelect], 2 
    jne _increment_score_lvl1
    cmp word [score], 200    
    je _next_level

_increment_score_lvl1:
    cmp word [score], 100
    je _next_level

    jmp _game_loop

_next_level:
    inc byte [lvlSelect]
    jmp _start_game

;
;   Print Victory on screen and wait for user input 
;
_game_win: 
    call _clear_screen

    mov DH, 10
    mov DL, 17
    mov SI, victory

    call _print_string
    call _print_press_any_key
    jmp _wait_key

;
;   Print Game Over on screen and wait for user input 
;
_game_lose: 
    call _clear_screen
    mov DH, 10
    mov DL, 16
    mov SI, gameOver
    call _print_string
    call _print_press_any_key
    jmp _wait_key    

;
;   Wait for user to press any key
;
_wait_key:
    mov AH, 0x1		;Set ah to 1
	int 0x16		    ;Check keystroke interrupt
	
    jz  _wait_key	;Return if no keystroke

    mov AH, 0x0		;Set ah to 0
	int 0x16		    ;Get keystroke interrupt

    call _clear_screen

    jmp _main_menu

;
; Method used to display title on main menu
;
_print_menu_tittle:
    mov DH, 4
    mov DL, 12
    mov SI, title
    call _print_string

    ret

;
; Method used to print lvl 1 on main menu, 
; verifies if lvl 1 is selected, if it is 
; it blinks the text
;
_print_menu_lvl1:
    mov DH, 9      ;set row
    mov DL, 17     ;set column
    mov SI, lvl1   ;set text to print
    mov CL, 1      ;option number
    call _display

    ret

;
; Method used to print lvl 2 on main menu, 
; verifies if lvl 2 is selected, if it is 
; it blinks the text
;
_print_menu_lvl2:
    mov DH, 12     ;set row
    mov DL, 17     ;set column
    mov SI, lvl2   ;set text to print
    mov CL, 2      ;option number
    call _display

    ret

;
; Method used to print lvl 3 on main menu, 
; verifies if lvl 3 is selected, if it is 
; it blinks the text
;
_print_menu_lvl3:
    mov DH, 15     ;set row
    mov DL, 17     ;set column
    mov SI, lvl3   ;set text to print
    mov CL, 3      ;option number
    call _display

    ret

;
; Method used to print exit game on main menu, 
; verifies if exit game is selected, if it is 
; it blinks the text
;
_print_menu_exitGame:
    mov DH, 19     ;set row
    mov DL, 16     ;set column
    mov SI, exitGame   ;set text to print
    mov CL, 4      ;option number
    call _display

    ret    

;
;   Method used to print current level on game initialization
;
_print_game_level:
    mov SI, lvl3
    cmp byte [lvlSelect], 3
    je _print_game_level_aux

    mov SI, lvl2
    cmp byte [lvlSelect], 2
    je _print_game_level_aux

    mov SI, lvl1

_print_game_level_aux:
    mov DH, 4
    mov DL, 17
    call _print_string

    ret

;
; Print hotkeys on game initialization 
;
_print_hot_keys:

    mov SI, hotkeys
    mov DH, 9
    mov DL, 1
    call _print_string

    mov SI, hotkeys1
    mov DH, 11
    mov DL, 1
    call _print_string

    mov SI, hotkeys2
    mov DH, 12
    mov DL, 1
    call _print_string

    mov SI, hotkeys3
    mov DH, 13
    mov DL, 1
    call _print_string

    mov SI, hotkeys4
    mov DH, 14
    mov DL, 1
    call _print_string

    mov SI, hotkeys5
    mov DH, 15
    mov DL, 1
    call _print_string

    mov SI, hotkeys6
    mov DH, 16
    mov DL, 1
    call _print_string

    ret

;
; print next piece on game initialation
;
_print_next_piece:
    mov SI, nextPiece
    mov DH, 11
    mov DL, 26
    call _print_string

    ret    

;
; print next piece on game initialation
;
_print_score_text:
    mov SI, scoreText
    mov DH, 8
    mov DL, 26
    call _print_string

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
    
    mov SI, msg_score_buffer
    mov dh, 9
    mov dl, 26
    call _print_string
    
    ret

;
; Method used to print press any key
;     
_print_press_any_key:

    mov SI, pressAnyKey
    mov DH, 23
    mov DL, 14

    call _print_string

    ret

; 
; Method used to print the box around the gamefield
;
_print_game_field: 
    mov ax, 22
    mov bx, 12
    mov di, 29915
    mov dl, 0xF
    call _draw_rectangle

    mov ax, 20
    mov bx, 10
    mov di, 30236
    mov dl, 0x00
    call _draw_rectangle

    ret  
;
; loads preview piece on variables based on random number
;
_load_preview_piece:

    cmp byte [random5], 4
    je _load_preview_piece_t

    cmp byte [random5], 3
    je _load_preview_piece_l

    cmp byte [random5], 2
    je _load_preview_piece_zigzag

    cmp byte [random5], 1
    je _load_preview_piece_bar

    mov AX, word [square0]
    mov word [previewPiece0], AX
    mov AX, word [square1]
    mov word [previewPiece1], AX
    mov AX, word [square2]
    mov word [previewPiece2], AX
    mov AX, word [square3]
    mov word [previewPiece3], AX 
    mov AL, byte [squareColor]
    mov byte [previewPieceColor], AL

    ret 

_load_preview_piece_t:

    mov AX, word [t0]
    mov word [previewPiece0], AX
    mov AX, word [t1]
    mov word [previewPiece1], AX
    mov AX, word [t2]
    mov word [previewPiece2], AX
    mov AX, word [t3]
    mov word [previewPiece3], AX 
    mov AL, byte [tColor]
    mov byte [previewPieceColor], AL

    ret    

_load_preview_piece_l:

    mov AX, word [l0]
    mov word [previewPiece0], AX
    mov AX, word [l1]
    mov word [previewPiece1], AX
    mov AX, word [l2]
    mov word [previewPiece2], AX
    mov AX, word [l3]
    mov word [previewPiece3], AX 
    mov AL, byte [lColor]
    mov byte [previewPieceColor], AL

    ret 

_load_preview_piece_zigzag:

    mov AX, word [zigzag0]
    mov word [previewPiece0], AX
    mov AX, word [zigzag1]
    mov word [previewPiece1], AX
    mov AX, word [zigzag2]
    mov word [previewPiece2], AX
    mov AX, word [zigzag3]
    mov word [previewPiece3], AX 
    mov AL, byte [zigzagColor]
    mov byte [previewPieceColor], AL

    ret 

_load_preview_piece_bar:

    mov AX, word [bar0]
    mov word [previewPiece0], AX
    mov AX, word [bar1]
    mov word [previewPiece1], AX
    mov AX, word [bar2]
    mov word [previewPiece2], AX
    mov AX, word [bar3]
    mov word [previewPiece3], AX 
    mov AL, byte [barColor]
    mov byte [previewPieceColor], AL

    ret     

;
; loads piece on 
;    
_load_current_piece:

    mov AX, word [previewPiece0]
    mov word [currentPiece0], AX

    mov AX, word [previewPiece1]
    mov word [currentPiece1], AX
    
    mov AX, word [previewPiece2]
    mov word [currentPiece2], AX
    
    mov AX, word [previewPiece3]
    mov word [currentPiece3], AX 
    
    mov AL, byte [previewPieceColor]
    mov byte [currentPieceColor], AL 

    ret

;
; moves preview piece to preview position
;
_move_preview_to_preview:

    mov AX, word [previewPieceSpawn]

    add word [previewPiece0], AX
    add word [previewPiece1], AX
    add word [previewPiece2], AX
    add word [previewPiece3], AX

    ret       

;
; moves current piece to spawn position on gamefield
;
_move_current_to_spawn:

    ;mov AX, word [gameFieldSpawn]

    ;add word [currentPiece0], AX
    ;add word [currentPiece1], AX
    ;add word [currentPiece2], AX
    ;add word [currentPiece3], AX

    sub word [currentPiece0], 15
    sub word [currentPiece1], 15
    sub word [currentPiece2], 15
    sub word [currentPiece3], 15

    ret   

;
; print preview piece on screen
;
_print_preview_piece: 
    mov DL, byte [previewPieceColor]
    mov DI, word [previewPiece0]
    call _draw_pixel

    mov DI, word [previewPiece1]
    call _draw_pixel

    mov DI, word [previewPiece2]
    call _draw_pixel

    mov DI, word [previewPiece3]
    call _draw_pixel

    ret    

;
; print current piece on screen
;
_print_current_piece: 
    mov DL, byte [currentPieceColor]
    mov DI, word [currentPiece0]
    call _draw_pixel

    mov DI, word [currentPiece1]
    call _draw_pixel

    mov DI, word [currentPiece2]
    call _draw_pixel

    mov DI, word [currentPiece3]
    call _draw_pixel

    ret

;
;   remove preview piece from screen
;
_erase_preview_piece:   
    mov DL, 0x0
    mov DI, word [previewPiece0]
    call _draw_pixel
    mov DI, word [previewPiece1]
    call _draw_pixel
    mov DI, word [previewPiece2]
    call _draw_pixel
    mov DI, word [previewPiece3]
    call _draw_pixel
    ret

;
;   remove current piece from screen
;
_erase_current_piece:   
    mov DL, 0x0
    mov DI, word [currentPiece0]
    call _draw_pixel
    mov DI, word [currentPiece1]
    call _draw_pixel
    mov DI, word [currentPiece2]
    call _draw_pixel
    mov DI, word [currentPiece3]
    call _draw_pixel
    ret

;
; move piece one space down and verifies if is valid
; if its not posible to move it, fix it and create a new piece
;
_move_down_current_piece:

    call _erase_current_piece

    mov AX, word [screenWidth]

    add word [currentPiece0], AX
    add word [currentPiece1], AX
    add word [currentPiece2], AX
    add word [currentPiece3], AX

    call _detect_collision

    cmp AX, 0
    jne _lock_piece
    call _print_current_piece
    ret

_lock_piece:

    mov AX, word [screenWidth]
    
    sub word [currentPiece0], AX
    sub word [currentPiece1], AX
    sub word [currentPiece2], AX
    sub word [currentPiece3], AX

    call _print_current_piece
    call _load_current_piece   

    call _erase_preview_piece
    call _load_preview_piece
    call _move_preview_to_preview
    call _print_preview_piece

    call _move_current_to_spawn
    call _detect_collision
    call _print_current_piece
    ret

;
; moves piece left and verfies if it is a valid move
;
_move_left_current_piece:

    call _erase_current_piece

    dec word [currentPiece0]
    dec word [currentPiece1]
    dec word [currentPiece2]
    dec word [currentPiece3]

    call _detect_collision

    cmp AX, 0                 
    jne _move_left_invalid
    call _print_current_piece

    ret

_move_left_invalid:
    inc word [currentPiece0]
    inc word [currentPiece1]
    inc word [currentPiece2]
    inc word [currentPiece3]

    call _print_current_piece

    ret

;
; moves piece right and verfies if it is a valid move
;
_move_right_current_piece:

    call _erase_current_piece

    inc word [currentPiece0]
    inc word [currentPiece1]
    inc word [currentPiece2]
    inc word [currentPiece3]

    call _detect_collision

    cmp AX, 0                 
    jne _move_right_invalid
    call _print_current_piece
    ret

_move_right_invalid:
    dec word [currentPiece0]
    dec word [currentPiece1]
    dec word [currentPiece2]
    dec word [currentPiece3]

    call _print_current_piece
    ret


;
; Detect collsion
;       Output:
;        AX  = 1 colision detected, 0 no colision detected
_detect_collision:
    
    mov AX, 1                    ;collision = true

    mov DI, word[currentPiece0]
    call _read_pixel
    cmp Dl, 0x0
    jne _return                  ;if piece 0 collides return 

    mov DI, word[currentPiece1]
    call _read_pixel
    cmp Dl, 0x0
    jne _return                  ;if piece 1 collides return    
    
    mov DI, word[currentPiece2]
    call _read_pixel
    cmp Dl, 0x0
    jne _return                  ;if piece 2 collides return 
    
    mov DI, word[currentPiece3]
    call _read_pixel
    cmp Dl, 0x0
    jne _return                  ;if piece 3 collides return   

    mov AX, 0                    ;collision = false 

    ret

;
; Method used to print options on menu, 
; they blink if they are selected 
;  
;  Input:
;       CL = lvlSelect option number        
;       DH = row
;       DL = column
;       SI = address of string
;       
_display: 
    cmp byte [lvlSelect], CL
    je _display_blink ; if  current selected level is 1 verify blink
    call _print_string ;print lvl 1 on screen
    ret
_display_blink:
    cmp byte [blink], 0         
    je _display_no_blink ;if blink == 0 jmp _lvl1noprint
    mov byte [blink], 0 ;turn blink to 0
    call _print_string    ;print lvl 1 on screen
    ret 
_display_no_blink:
    mov byte [blink], 1 ; turn blink to 1
    mov SI, blankText
    call _print_string
    ret    

;
; Print a string at the specified location
;
;  Input:
;       DH = row
;       DL = column
;       SI = address of string
;
_print_string:

    mov bh, 0   ;Set page 0lvl1
    mov cx, 1	;Set number of times
    mov bl, 0xf   ;Set green color
	mov ah, 0x2	;Set cursor position interrupt
	int 10h
	lodsb		;Move si pointer contents to al
	or al, al	;Break if end of string
	jz return
	mov ah, 0xa	;Teletype output interrupt
	int 10h		;
	inc dl		;Increment column index
	jmp _print_string	;Loop to itself

return:
	ret        


; Draw a pixel
;
;  Input: 
;       DI - position
;       DL - colour
;
_draw_pixel:

    push AX
    push ES

    mov AX, 0x0A000
    mov ES, AX
    mov byte [ES:DI], DL
    
    pop ES
    pop AX
    
    ret
    
;
; Draw a vertical line di is modified to point to the first address 
; after the end of the line
;
;  Input: 
;       cx - line length
;       di - position
;       dl - colour
;
_draw_vertical_line:

    call _draw_pixel
    add di, [screenWidth]
    loop _draw_vertical_line
    
    ret


;
; Draw a horizontal line, di is modified to point to the first address after the end of the line
;
; Input: 
;      cx - line length
;      di - position
;      dl - colour
;
_draw_horizontal_line:

    call _draw_pixel
    
    inc di ; move di one pixel to the right
    
    loop _draw_horizontal_line     ; next pixel
    
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

_draw_rectangle_loop:    
    push cx  ; draw a bx wide horizontal line
    push di
    mov cx, bx
    call _draw_horizontal_line
    pop di    ; restore di to the beginning of this line
    add di, [screenWidth]     ; move di down one line, to the beginning of the next line
    pop cx     ; restore loop counter
    loop _draw_rectangle_loop     ; next horizontal line

    pop cx
    pop dx
    pop di
    
    ret


; Read a pixel's colour
;
; Input:
;       di - position
; Output:
;       dl - colour
;
_read_pixel:

    push ax
    push es

    mov ax, 0x0A000
    mov es, ax
    mov byte dl, [es:di]
    
    pop es
    pop ax
    
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
; sleep n 100 milisecons 
;  input:
;       BX = number of 100 miliseconds
;  
_sleep:
    call _ms_delay
    dec BX
    jnz _sleep 

    call _increment_random5
    
    ret

;
; Method used to sleep the procesor
;  for 100miliseconds 
;
_ms_delay: 
    mov CX, 0x0000
    mov DX, 0xffff
    mov AH, 0x86
    xor AL, AL
    int 0x15
    
    ret   

;
; increments random counter, if random5 is 5 reset it to 0
; 
;
_increment_random5:
    inc byte [random5]
    cmp byte [random5], 5
    je  _reset_random5 
    ret
_reset_random5:
    mov byte[random5], 0
    ret

; 
;   method used to reset counter after each move
;    
_reset_counter:
    mov byte [counter], 3    ;if 
    cmp byte [lvlSelect], 3
    je _return 

    mov byte [counter], 5    ;if
    cmp byte [lvlSelect], 2  
    je _return

    mov byte [counter], 7    ;else

_return:
    ret
    

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

    hotkeys  db 'HOTKEYS$', 0
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

    nextPiece db 'NEXT PIECE', 0

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

    msg_score_buffer db '000', 0 ; holds the string representation of score
    score dw 0 ; keeps score (representing total number of cleared lines)

    

     
