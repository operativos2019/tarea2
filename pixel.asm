[BITS 16]
org 100h

jmp _main

_main: 
    call _enter13h
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
;main menu display loop 
;
_main_menu: 

    call _print_tittle
    call _print_lvl1
    call _print_lvl2
    call _print_lvl3
    call _print_exitGame
    mov CX, 05h
    call _sleep
    call _clear_screen

    jmp _main_menu    

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
    xor BH, BH ;set BH to 0
    int 10h
    
    ; output string
    mov AH, 9h
    pop DX ;nox DX is BX prevoius value
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
    mov DH, 9      ;set row
    mov DL, 17     ;set column
    mov BX, lvl1   ;set text to print
    mov CL, 1      ;option number
    call _display

    ret

_print_lvl2:
    mov DH, 12     ;set row
    mov DL, 17     ;set column
    mov BX, lvl2   ;set text to print
    mov CL, 2      ;option number
    call _display

    ret

_print_lvl3:
    mov DH, 15     ;set row
    mov DL, 17     ;set column
    mov BX, lvl3   ;set text to print
    mov CL, 3      ;option number
    call _display

    ret

_print_exitGame:
    mov DH, 19     ;set row
    mov DL, 16     ;set column
    mov BX, exitGame   ;set text to print
    mov CL, 4      ;option number
    call _display

    ret    


_display: 
    mov byte AH, [lvlSelect]
    cmp AH, CL
    je _blink ; if  current selected level is 1 verify blink
    call _print_string ;print lvl 1 on screen

    ret

_blink:
    mov byte AH, [blink]
    cmp AH, 0         
    je _no_blink ;if blink == 0 jmp _lvl1noprint

    mov byte [blink], 0 ;turn blink to 0
    call _print_string    ;print lvl 1 on screen
    
    ret 

_no_blink:
    mov byte [blink], 1 ; turn blink to 1

    ret

section .data

    title dw '--- TETRIS 86 ---$'
    lvl1 dw 'LEVEL 1$'
    lvl2 dw 'LEVEL 2$'
    lvl3 dw 'LEVEL 3$'
    exitGame dd 'EXIT GAME$'

    lvlSelect db 4
    blink db 0