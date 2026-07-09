 ;****************** LED.asm ***************
; ECE505, Winter 2021  Lab 1
;*******************************************

		.thumb
		.text
		.align  2

		.export PortF_Init
		.export   delay
		.export   blue_led_on
		.export   blue_led_off
		.export   red_led_on
		.export   red_led_off
		.export   green_led_on
		.export   green_led_off
		.export	  PortF_Input


GPIO_PORTF_DATA_R  .field 0x400253FC,32
GPIO_PORTF_DIR_R   .field 0x40025400,32
GPIO_PORTF_AFSEL_R .field 0x40025420,32
GPIO_PORTF_PUR_R   .field 0x40025510,32
GPIO_PORTF_DEN_R   .field 0x4002551C,32
GPIO_PORTF_LOCK_R  .field 0x40025520,32
GPIO_PORTF_CR_R    .field 0x40025524,32
GPIO_PORTF_AMSEL_R .field 0x40025528,32
GPIO_PORTF_PCTL_R  .field 0x4002552C,32
GPIO_LOCK_KEY      .field 0x4C4F434B,32  ; Unlocks the GPIO_CR register

PF1				   .field 0x40025008,32
PF2				   .field 0x40025010,32
PF3				   .field 0x40025020,32

RED       .equ 0x02
BLUE      .equ 0x04
GREEN     .equ 0x08
SW1       .equ 0x10                 ; on the left side of the Launchpad board
SW2       .equ 0x01                 ; on the right side of the Launchpad board
SYSCTL_RCGCGPIO_R  .field   0x400FE608,32


PortF_Init:  .asmfunc
    LDR R1, SYSCTL_RCGCGPIO_R       ; 1) activate clock for Port F
    LDR R0, [R1]
    ORR R0, R0, #0x20               ; set bit 5 to turn on clock
    STR R0, [R1]
    NOP
    NOP                             ; allow time for clock to finish
    LDR R1, GPIO_PORTF_LOCK_R       ; 2) unlock the lock register
    LDR R0, GPIO_LOCK_KEY             ; unlock GPIO Port F Commit Register
    STR R0, [R1]
    LDR R1, GPIO_PORTF_CR_R         ; enable commit for Port F
    MOV R0, #0xFF                   ; 1 means allow access
    STR R0, [R1]
    LDR R1, GPIO_PORTF_AMSEL_R      ; 3) disable analog functionality
    MOV R0, #0                      ; 0 means analog is off
    STR R0, [R1]
    LDR R1, GPIO_PORTF_PCTL_R       ; 4) configure as GPIO
    MOV R0, #0x00000000             ; 0 means configure Port F as GPIO
    STR R0, [R1]
    LDR R1, GPIO_PORTF_DIR_R        ; 5) set direction register
    MOV R0,#0x0E                    ; PF0 and PF7-4 input, PF3-1 output
    STR R0, [R1]
    LDR R1, GPIO_PORTF_AFSEL_R      ; 6) regular port function
    MOV R0, #0                      ; 0 means disable alternate function
    STR R0, [R1]
    LDR R1, GPIO_PORTF_PUR_R        ; pull-up resistors for PF4,PF0
    MOV R0, #0x11                   ; enable weak pull-up on PF0 and PF4
    STR R0, [R1]
    LDR R1, GPIO_PORTF_DEN_R        ; 7) enable Port F digital port
    MOV R0, #0xFF                   ; 1 means enable digital I/O
    STR R0, [R1]
    BX  LR
    .endasmfunc

    ;------------delay------------
; Delay function for testing, which delays about 3*count cycles.
; Input: R0 count
; Output: none
ONESEC             .field 5333333,32      ; approximately 1s delay at ~16 MHz clock
QUARTERSEC         .field 1333333,32      ; approximately 0.25s delay at ~16 MHz clock
FIFTHSEC           .field 1066666,32      ; approximately 0.2s delay at ~16 MHz clock
delay: .asmfunc
	LDR R0, ONESEC
delay_loop
    SUBS R0, R0, #1                 ; R0 = R0 - 1 (count = count - 1)
    BNE delay_loop                       ; if count (R0) != 0, skip to 'delay'
    BX  LR                          ; return
    .endasmfunc

;------------PortF_Input-------
;Test the button press results
PortF_Input: .asmfunc
    LDR R1, GPIO_PORTF_DATA_R 		; pointer to Port F data
    LDR R0, [R1]               		; write to PF3-1
    BX  LR
    .endasmfunc

;------------PortF_Output------
; Set the output state of PF3-1.
; Input: R0  new state of PF
; Output: none
; Modifies: R1
PortF_Output: .asmfunc
    LDR R1, GPIO_PORTF_DATA_R 		; pointer to Port F data
    STR R0, [R1]               		; write to PF3-1
    BX  LR
    .endasmfunc

;------------blue_led_on------
; Turn the blue LED on
; Input: none
; Output: none
blue_led_on: .asmfunc
	LDR R1, PF2
	MOV R0, #BLUE                   ; R0 = BLUE (blue LED on)
    STR R0, [R1]                    ; turn the blue LED on
    BX  LR
    .endasmfunc

;------------blue_led_off-----
; Turn the blue LED off
; Input: none
; Output: none
blue_led_off: .asmfunc
	LDR R1, PF2
	MOV R0, #0                      ; R0 = 0
    STR R0, [R1]                    ; turn the blue LED OFF
    BX  LR
    .endasmfunc

;------------red_led_on-------
; Turn the red LED on
; Input: none
; Output: none
red_led_on: .asmfunc
	LDR R1, PF1
	MOV R0, #RED                    ; R0 = RED (red LED on)
    STR R0, [R1]                    ; turn the red LED on
    BX  LR
    .endasmfunc

;------------red_led_off------
; Turn the red LED off
; Input: none
; Output: none
red_led_off: .asmfunc
	LDR R1, PF1
	MOV R0, #0                      ; R0 = 0
    STR R0, [R1]                    ; turn the red LED OFF
    BX  LR
    .endasmfunc

;------------green_led_on------
; Turn the green LED on
; Input: none
; Output: none
green_led_on: .asmfunc
	LDR R1, PF3
	MOV R0, #GREEN                  ; R0 = GREEN (green LED on)
    STR R0, [R1]                    ; turn the green LED on
    BX  LR
    .endasmfunc

;------------green_led_off-----
; Turn the green LED off
; Input: none
; Output: none
green_led_off: .asmfunc
	LDR R1, PF3
	MOV R0, #0                      ; R0 = 0
    STR R0, [R1]                    ; turn the green LED OFF
    BX  LR
    .endasmfunc

    .align                         ; make sure the end of this section is aligned


    .end                       ; end of file

