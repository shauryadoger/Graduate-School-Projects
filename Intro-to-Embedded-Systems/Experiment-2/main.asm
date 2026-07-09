;****************** main.s ***************
; ECE473, W 2015, Example
;*****************************************

		.import   PortF_Init
		.import	  PortF_Input
		.import   delay
		.import   blue_led_on
		.import   blue_led_off

		.import   PortD_Init
		.import   PortD_Pin0_On
		.import	  PortD_Pin0_Off

		.thumb
		.text
		.align  2

      .global main

GPIO_PORTF_DATA_R  .field 0x400253FC,32

RED       .equ 0x02
BLUE      .equ 0x04
GREEN     .equ 0x08
SW1       .equ 0x10                 ; on the left side of the Launchpad board
SW2       .equ 0x01                 ; on the right side of the Launchpad board

ONESEC             .field 5333333,32      ; approximately 1s delay at ~16 MHz clock
POINTONESEC        .field  533333,32      ; approximately 0.1s delay at ~16 MHz clock
QUARTERSEC         .field 1333333,32      ; approximately 0.25s delay at ~16 MHz clock
FIFTHSEC           .field 1066666,32      ; approximately 0.2s delay at ~16 MHz clock

main:  .asmfunc

Start
    BL  PortF_Init                  ; initialize input and output pins of Port F
    ;BL	PortF_Input
    BL  PortD_Init					; initialize input/output pins of Port D
    BL 	PortD_Pin0_On	;Test PortD function
	BL 	PortD_Pin0_Off

;Testloop

	;B Testloop
	;LDR R10, ONESEC

;TestLoop2
;	BL green_led_toggle
;	BL delay

	;We load value to register 10 because that is used as input to do count down
	;as to how much delay there should be between green LED toggles

;	LDR R10, POINTONESEC
;	BL timed_green_led_toggle
	;BL green_led_toggle
	;LDR R10, ONESEC
	;BL delay
	;SUBS R4, R4, #1

;	B TestLoop2


MainLoop
;Add your code using SW1 to control the GREEN LED flashing rate
;Your code should read SW1
;If SW1 is open(not pressed) R10 should be set to the count for a 1 sec delay
;Else R10 should set to the count for a 0.1 sec delay
;Use the If Then Else structure disccused in lecture
;The starter code only flashes the LED at one rate

	;BL green_led_toggle
	;BL green_led_toggle

	LDR R1, GPIO_PORTF_DATA_R ; R1 = &GPIO_PORTF_DATA_R
	LDR R0, [R1] ; R0 = [R1]!!! This line reads in value from SW1. If pressed, then 0x01. If not pressed, then 0x11.
	ANDS R0, R0, #0x10 ; R0 = R0&0x10!!! If SW1 pressed, R0 will contain a value of zero with this AND operation!!!
	BNE SW1_open	;This basically says if R0 contains a value of zero, it will not go to 'SW1_open'. Otherwise it will.
	LDR R10, POINTONESEC			; 0.1 sec delay
	B next

SW1_open
	LDR R10, ONESEC					; 1 sec delay
next
	BL timed_green_led_toggle

	B   MainLoop

	.endasmfunc

;---------timed_green_led_toggle---------
; Toggle the green LED based on the amount of delay time provided as an input to the function, and subsequently into 'delay' subroutine
; It calls the 'green_led_toggle' function from below!!!
; Input: R1, which takes in the current value at "GPIO_PORTF_DATA_R memory address" with 'green_led_toggle"
; Output: It writes "toggled R1" value to the "R0" memory address at 'green_led_toggle'!!!
; Modifies: R0, R1
timed_green_led_toggle: .asmfunc
	BL green_led_toggle
	;LDR R10, ONESEC
	BL delay
    B MainLoop
    ;BX LR
    .endasmfunc

;test: .asmfunc
;	BL green_led_toggle
;	B TestLoop2
 ;   .endasmfunc

;---------green_led_toggle---------
; Toggle the green LED where turns on if off, or off when currently on
; Input: R1, which takes in the current value at "GPIO_PORTF_DATA_R memory address"
; Output: It writes "toggled R1" value to the "R0" memory address!!!
; Modifies: R0, R1
green_led_toggle: .asmfunc
	LDR R0, GPIO_PORTF_DATA_R
	LDR R1, [R0]
	EOR R1, R1, #GREEN
	STR R1, [R0]

    BX LR
    .endasmfunc

	.end                       ; end of file.end

