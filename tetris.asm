[BITS 16]
org 100h

section .text

jmp start

start:

    mov AX, 13h  ;enter grphical mode 
    int 10h

    jmp _main_menu

finish: 

    mov AX, 3  ;exit graphical mode 
    int 10h

    int 21h    ;DOS interruption

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

 	mov AH, 1h		;Set ah to 1
	int 16h		    ;Check keystroke interrupt
	jz  _main_menu	;Return if no keystroke

	mov AH, 0h		;Set ah to 0
	int 16h		    ;Get keystroke interrupt

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
    call _print_game_field

_loop:

    mov AH, 1h		;Set ah to 1
	int 16h		    ;Check keystroke interrupt
	jz  _loop	;Return if no keystroke

	mov AH, 0h		;Set ah to 0
	int 16h		    ;Get keystroke interrupt

    cmp AH, 0x01    
    je _game_escape ;exit game to menu Esc pressed

    cmp AH, 0x18    
    je _game_win         ;win game

    cmp AH, 0x19    
    je _game_lose        ;lose game

    jmp _loop


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

_game_win: 
    call _clear_screen

    mov DH, 10
    mov DL, 17
    mov BX, victory

    call _print_string
    call _print_press_any_key
    jmp _wait_key

_game_lose: 
    call _clear_screen
    mov DH, 10
    mov DL, 16
    mov BX, gameOver
    call _print_string
    call _print_press_any_key
    jmp _wait_key    

_wait_key:
    mov AH, 1h		;Set ah to 1
	int 16h		    ;Check keystroke interrupt
	
    jz  _wait_key	;Return if no keystroke

    mov AH, 0h		;Set ah to 0
	int 16h		    ;Get keystroke interrupt

    call _clear_screen

    jmp _main_menu

;
; Method used to display title on main menu
;
_print_menu_tittle:
    mov DH, 4
    mov DL, 12
    mov BX, title
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
    mov BX, lvl1   ;set text to print
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
    mov BX, lvl2   ;set text to print
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
    mov BX, lvl3   ;set text to print
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
    mov BX, exitGame   ;set text to print
    mov CL, 4      ;option number
    call _display

    ret    

;
;   Method used to print current level on game initialization
;
_print_game_level:
    mov BX, lvl3
    cmp byte [lvlSelect], 3
    je _print_game_level_aux

    mov BX, lvl2
    cmp byte [lvlSelect], 2
    je _print_game_level_aux

    mov BX, lvl1

_print_game_level_aux:
    mov DH, 4
    mov DL, 17
    call _print_string

    ret

;
; Print hotkeys on game initialization 
;
_print_hot_keys:

    mov BX, hotkeys
    mov DH, 9
    mov DL, 1
    call _print_string

    mov BX, hotkeys1
    mov DH, 11
    mov DL, 1
    call _print_string

    mov BX, hotkeys2
    mov DH, 12
    mov DL, 1
    call _print_string

    mov BX, hotkeys3
    mov DH, 13
    mov DL, 1
    call _print_string

    mov BX, hotkeys4
    mov DH, 14
    mov DL, 1
    call _print_string

    mov BX, hotkeys5
    mov DH, 15
    mov DL, 1
    call _print_string

    mov BX, hotkeys6
    mov DH, 16
    mov DL, 1
    call _print_string

    ret

;
; Method used to print press any key
;     
_print_press_any_key:

    mov BX, pressAnyKey
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
; Method used to print options on menu, 
; they blink if they are selected 
;  
;  Input:
;       CL = lvlSelect option number        
;       DH = row
;       DL = column
;       BX = address of string
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
    mov BX, blankText
    call _print_string
    ret    

;
; Print a string at the specified location
;
;  Input:
;       DH = row
;       DL = column
;       BX = address of string
;
_print_string:

    ; position cursor
    push BX
    mov  AH, 2
    xor  BH, BH ;set BH to 0
    int  10h
    
    ; output string
    mov AH, 9h
    pop DX ;now DX is BX prevoius value
    int 21h
    
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

    mov AX, 0A000h
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

section .data

    mainMenuDelay dw 5

    title db '--- TETRIS 86 ---$'
    lvl1 db 'LEVEL 1$'
    lvl2 db 'LEVEL 2$'
    lvl3 db 'LEVEL 3$'
    exitGame db 'EXIT GAME$'

    hotkeys  db 'HOTKEYS$'
    hotkeys1 db 'Left: ->$'
    hotkeys2 db 'Right: <-$'
    hotkeys3 db 'Down: v$'
    hotkeys4 db 'Rotate Left: Q$'
    hotkeys5 db 'Rotate Right: S$'
    hotkeys6 db 'Exit Game: Esc$'

    victory  db 'VICTORY$'
    gameOver db 'GAME_OVER$'

    pressAnyKey db 'Press Any Key$'

    blankText db '         $'

    screenWidth dw 320
    sceenHeight dw 200

    lvlSelect db 1
    blink db 1    