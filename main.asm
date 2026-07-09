;****************** main.s ***************
; ECE473, W 2015, Example
;*****************************************

		.import   PortF_Init
		.import   delay
		.import   blue_led_on
		.import   blue_led_off
		.import	  PortF_Input

		.thumb
		.text
		.align  2

;*******************************************
; No need to worry about anything above
;*******************************************
; PF1: Red
; PF2: Blue
; PF3: Green
; User functions:
; 	PortF_init:   to initialize port F
; 	blue_led_on:  to turn blue LED on
;	blue_led_off: to turn blue LED off
; 	delay:        delay fixed amount of time (3 * 0.25 = 0.75s)

; By manipulating the sequence of funtion calls, the user can generate different light patterns.
; This lab is used to demonstrate the development tools and debugging features.

      .global main

main:  .asmfunc
Start
    BL  PortF_Init                  ; initialize input and output pins of Port F
    BL	PortF_Input

Myloop
	MOV  R5,#0x1234
	PUSH {R5}
	POP  {R6}


	MOV R4, #3

LoopBlue
	BL  blue_led_on
    BL  delay
	BL  blue_led_off
    BL  delay



	SUBS R4, R4, #1
	BNE LoopBlue




	B   Myloop

	.endasmfunc

	.end                       ; end of file.end

