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

    call _print_tittle   
    call _print_lvl1
    call _print_lvl2
    call _print_lvl3
    call _print_exitGame

    mov BX, word [mainMenuDelay]
    call _sleep

 	mov AH, 1h		;Set ah to 1
	int 16h		;Check keystroke interrupt
	jz  _main_menu	;Return if no keystroke

	mov AH, 0h		;Set ah to 0
	int 16h		;Get keystroke interrupt

    cmp AH, 0x01    
    je _menu_escape

    cmp AH, 0x1C    
    je _menu_enter
    cmp AH, 0x48	;Jump if up arrow pressed

	je _menu_up
    cmp AH, 0x50	;Jump if down arrow pressed

	je _menu_down
    jmp _main_menu        


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
    jmp _main_menu

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
; Method used to display title on main menu
;
_print_tittle:
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
_print_lvl1:
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
_print_lvl2:
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
_print_lvl3:
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
_print_exitGame:
    mov DH, 19     ;set row
    mov DL, 16     ;set column
    mov BX, exitGame   ;set text to print
    mov CL, 4      ;option number
    call _display

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
_print_pixel:

    push AX
    push ES

    mov AX, 0A000h
    mov ES, AX
    mov byte [ES:DI], DL
    
    pop ES
    pop AX
    
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
    blankText db '         $'

    screenWidth dw 320
    sceenHeight dw 200

    lvlSelect db 1
    blink db 1    