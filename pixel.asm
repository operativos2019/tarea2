[BITS 16]
org 100h

jmp _main

_main: 
    call _enter13h
    ;call _enhance_input
    call _main_menu
    ;call _exit13h
    jmp _end

;    
;enter graphical mode
;
_enter13h:
    mov AX, 13h 
    int 10h

    ret
;
;set keyboard parameters to be most responsive
;
_enhance_input:
    mov ax, 0305h
    xor bx, bx
    int 16h

    ret
;
;exit graphical mode
;
_exit13h:   
    mov AX, 3
    int 10h

    ret
;
;exit execution, return to DOS
;
_end: 
    int 21h         	; DOS interruption

    ret

;
; Print a string at the specified location
;
; Input:
;         DH = row
;         DL = column
;         BX = address of string
;
_print_string:

    ; position cursor
    push BX
    mov AH, 2
    xor BH, BH
    int 10h
    
    ; output string
    mov AH, 9h
    pop DX
    int 21h
    
    ret

; 
; Method used to delete all elementes in screen
;

_clear_screen: 
    mov AX, 13h 
    int 10h
    ret

;
;Method used to sleep the procesor
; Input:
;         CX = sleep time in miliseconds
;
_sleep:
	mov DX, 86a0h
	mov AH, 86h
	int 15h
    ret

;
;cicle to display main menu 
;
_main_menu: 

    call _print_tittle
    call _print_lvl1
    call _print_lvl2
    call _print_lvl3
    call _print_exit_game
    mov CX, 05h    ;100 milisegundos
    call _sleep
    call _clear_screen
    ;jmp _get_user_input

    jmp _main_menu

;
;Method used to display title on main menu
;
_print_tittle:
    mov DH, 4
    mov DL, 12
    mov BX, title
    call _print_string
    ret

;
;Method used to print lvl 1 on main menu, 
; verifies if lvl 1 is selected, if it is 
; it blinks the text
;
_print_lvl1: 
    mov byte AL, [lvlSelect]
    cmp AL, 1
    je _lvl1blink ; if  current selected level is 1 verify blink

_print_lvl1_blink:
    mov DH, 9      ;set row
    mov DL, 17     ;set column
    mov BX, lvl1   ;set text to print
    call _print_string   

    ret

_lvl1blink:
    mov byte AL, [blink]
    cmp AL, 0
    je _no_print_lvl1_blink ;if blink == 0 jmp _lvl1noprint

    mov byte [blink], 0 ;turn blink to 0
    jmp _print_lvl1_blink ;jump toprint lvl 1 

_no_print_lvl1_blink:
    mov byte [blink], 1 ; turn blink to 1

    ret

_print_lvl2:
    mov byte AL, [lvlSelect]
    cmp AL, 2
    je _lvl2blink ; if  current selected level is 2 verify blink

_print_lvl2_blink:
    mov DH, 12     ;set row
    mov DL, 17     ;set column
    mov BX, lvl2   ;set text to print
    call _print_string   

    ret

_lvl2blink:
    mov byte AL, [blink]
    cmp AL, 0
    je _no_print_lvl2_blink ;if blink == 0 jmp _lvl2noprint

    mov byte [blink], 0 ;turn blink to 0
    jmp _print_lvl2_blink ;jump toprint lvl 2 

_no_print_lvl2_blink:
    mov byte [blink], 1 ; turn blink to 1

    ret

_print_lvl3:
    mov byte AL, [lvlSelect]
    cmp AL, 3
    je _lvl3blink ; if  current selected level is 3 verify blink

_print_lvl3_blink:
    mov DH, 15     ;set row
    mov DL, 17     ;set column
    mov BX, lvl3   ;set text to print
    call _print_string   

    ret

_lvl3blink:
    mov byte AL, [blink]
    cmp AL, 0
    je _no_print_lvl3_blink ;if blink == 0 jmp _lvl3noprint

    mov byte [blink], 0 ;turn blink to 0
    jmp _print_lvl3_blink ;jump to print lvl 3 

_no_print_lvl3_blink:
    mov byte [blink], 1 ; turn blink to 1

    ret

_print_exit_game:
    mov DH, 19
    mov DL, 16
    mov BX, exitGame
    call _print_string
    ret

_get_user_input:
	mov ah, 0x1		;Set ah to 1
	int 0x16		;Check keystroke interrupt
	jz _main_menu	;Return if no keystroke
	mov ah, 0x0		;Set ah to 1
	int 0x16		;Get keystroke interrupt
	cmp ah, 0x48	;Jump if up arrow pressed
	je _menu_up
	cmp ah, 0x50	;Jump if down arrow pressed
	je _menu_down
	jmp _main_menu    

_menu_up:
    mov byte AL, [lvlSelect] ;get lvlSellectValue
    cmp AL, 1 ;if lvlSelect == 1, set it to 4, else lvlSelect-- 
    je _sub_lvl_select
    mov byte [lvlSelect], 4
    jmp _main_menu

_sub_lvl_select:
    sub AL, 1
    mov byte [lvlSelect], AL
    jmp _main_menu

_menu_down:
    mov byte AL, [lvlSelect] ;get lvlSellectValue
    cmp AL, 4 ;if lvlSelect == 4, set it to 1, else lvlSelect-- 
    je _add_lvl_select
    mov byte [lvlSelect], 1
    jmp _main_menu

_add_lvl_select:
    add AL, 1
    mov byte [lvlSelect], AL
    jmp _main_menu

section .data

    title dw '--- TETRIS 86 ---$'
    lvl1 dw 'LEVEL 1$'
    lvl2 dw 'LEVEL 2$'
    lvl3 dw 'LEVEL 3$'
    exitGame dw 'EXIT GAME$'

    lvlSelect db 3
    blink db 0
