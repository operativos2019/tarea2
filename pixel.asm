[BITS 16]
org 100h

section .text

jmp start

;    
;enter graphical mode
;
_enter13h:
    mov AX, 13h 
    int 10h

    ret

start: 
    call _enter13h
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
    call _exit13h
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

_display: 
    cmp byte [lvlSelect], CL
    je _blink ; if  current selected level is 1 verify blink
    call _print_string ;print lvl 1 on screen

    ret

_blink:
    cmp byte [blink], 0         
    je _no_blink ;if blink == 0 jmp _lvl1noprint

    mov byte [blink], 0 ;turn blink to 0
    call _print_string    ;print lvl 1 on screen
    
    ret 

_no_blink:
    mov byte [blink], 1 ; turn blink to 1

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

;
;Method used to print lvl 2 on main menu, 
; verifies if lvl 2 is selected, if it is 
; it blinks the text
;
_print_lvl2:
    mov DH, 12     ;set row
    mov DL, 17     ;set column
    mov BX, lvl2   ;set text to print
    mov CL, 2      ;option number
    call _display

    ret

;
;Method used to print lvl 3 on main menu, 
; verifies if lvl 3 is selected, if it is 
; it blinks the text
;
_print_lvl3:
    mov DH, 15     ;set row
    mov DL, 17     ;set column
    mov BX, lvl3   ;set text to print
    mov CL, 3      ;option number
    call _display

    ret

;
;Method used to print exit game on main menu, 
; verifies if exit game is selected, if it is 
; it blinks the text
;
_print_exitGame:
    mov DH, 19     ;set row
    mov DL, 16     ;set column
    mov BX, exitGame   ;set text to print
    mov CL, 4      ;option number
    call _display

    ret    

select_option: 
    cmp byte [lvlSelect], 4
    je _end 

    jmp _main_menu
    ;call _exit13h
    ;jmp _end  
    ;jmp _main_menu  
    ;inc byte [lvlSelect]
    ;

move_up:
    cmp byte [lvlSelect], 1
    je _main_menu

    dec byte [lvlSelect]
    jmp _main_menu

move_down:   
    cmp byte [lvlSelect], 4
    je _main_menu

    inc byte [lvlSelect]
    jmp _main_menu

;
; Method used to verify the keys pressed
;
;_get_user_input:


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

   	mov AH, 1h		;Set ah to 1
	int 16h		;Check keystroke interrupt
	jz _main_menu	;Return if no keystroke

	mov AH, 0h		;Set ah to 0
	int 16h		;Get keystroke interrupt
    
    ;cmp AH, 01h    
    ;je escape_key

    cmp AH, 0x1C    
    je select_option
	
    cmp AH, 0x48	;Jump if up arrow pressed
	je move_up
	
    cmp AH, 0x50	;Jump if down arrow pressed
	je move_down

    jmp _main_menu


section .data

    title db '--- TETRIS 86 ---$'
    lvl1 db 'LEVEL 1$'
    lvl2 db 'LEVEL 2$'
    lvl3 db 'LEVEL 3$'
    exitGame db 'EXIT GAME$'

    lvlSelect db 1
    blink db 0