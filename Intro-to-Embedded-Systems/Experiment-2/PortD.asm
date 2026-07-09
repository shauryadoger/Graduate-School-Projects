;****************** LED.asm ***************
; ECE505, Winter 2021  Lab 1
;*******************************************

		.thumb
		.text
		.align  2

		.export PortD_Init
		.export PortD_Pin0_On
		.export PortD_Pin0_Off

LEDS               .field 0x4000703C,32   ; access PD3-PD0
GPIO_PORTD_DATA_R  .field 0x400073FC,32
GPIO_PORTD_DIR_R   .field 0x40007400,32
GPIO_PORTD_AFSEL_R .field 0x40007420,32
GPIO_PORTD_DR8R_R  .field 0x40007508,32
GPIO_PORTD_DEN_R   .field 0x4000751C,32
GPIO_PORTD_AMSEL_R .field 0x40007528,32
GPIO_PORTD_PCTL_R  .field 0x4000752C,32
SYSCTL_RCGCGPIO_R  .field 0x400FE608,32
SYSCTL_RCGC2_GPIOD .field 0x00000008,32   ; port D Clock Gating Control


PortD_Init: .asmfunc
    ; 1) activate clock for Port D
    LDR R1, SYSCTL_RCGCGPIO_R       ; R1 = &SYSCTL_RCGCGPIO_R
    LDR R0, [R1]                    ; R0 = [R1]
    LDR R2, SYSCTL_RCGC2_GPIOD      ; R2 = SYSCTL_RCGC2_GPIOD
    ORR R0, R0, R2                  ; R0 = R0|R2 --- R0 = R0|SYSCTL_RCGC2_GPIOD
    STR R0, [R1]                    ; [R1] = R0
    NOP
    NOP                             ; allow time to finish activating

    ; 2) no need to unlock PD3-0

    ; 3) disable analog functionality
    LDR R1, GPIO_PORTD_AMSEL_R      ; R1 = &GPIO_PORTD_AMSEL_R
    LDR R0, [R1]                    ; R0 = [R1]
    BIC R0, R0, #0x0F               ; R0 = R0&~0x0F (disable analog functionality on PD3-0)
    STR R0, [R1]                    ; [R1] = R0

    ; 4) configure as GPIO
    LDR R1, GPIO_PORTD_PCTL_R       ; R1 = &GPIO_PORTD_PCTL_R
    LDR R0, [R1]                    ; R0 = [R1]
    MOV R2, #0x0000FFFF             ; R2 = 0x0000FFFF
    BIC R0, R0, R2                  ; R0 = R0&~0x0000FFFF (clear port control field for PD3-0)
    STR R0, [R1]                    ; [R1] = R0

    ; 5) set direction register
    LDR R1, GPIO_PORTD_DIR_R       ; R1 = &GPIO_PORTD_DIR_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #0x0F               ; R0 = R0|0x0F (make PD3-0 output)
    STR R0, [R1]                    ; [R1] = R0

    ; 6) regular port function
    LDR R1, GPIO_PORTD_AFSEL_R      ; R1 = &GPIO_PORTD_AFSEL_R
    LDR R0, [R1]                    ; R0 = [R1]
    BIC R0, R0, #0x0F               ; R0 = R0&~0x0F (disable alt funct on PD3-0)
    STR R0, [R1]                    ; [R1] = R0

    ; enable 8mA drive (only necessary for bright LEDs)
    LDR R1, GPIO_PORTD_DR8R_R       ; R1 = &GPIO_PORTD_DR8R_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #0x0F               ; R0 = R0|0x0F (enable 8mA drive on PD3-0)
    STR R0, [R1]                    ; [R1] = R0

    ; 7) enable digital port
    LDR R1, GPIO_PORTD_DEN_R        ; R1 = &GPIO_PORTD_DEN_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #0x0F               ; R0 = R0|0x0F (enable digital I/O on PD3-0)
    STR R0, [R1]                    ; [R1] = R0

    BX  LR
    .endasmfunc

;---------PortD_Pin0_On---------
; Turn the Port D Pin0 on
; Input: R0, which takes in the current value at "R1 memory address"
; Output: none
; Modifies: R0, R1
PortD_Pin0_On: .asmfunc
    LDR R1, GPIO_PORTD_DATA_R       ; R1 = &GPIO_PORTD_DATA_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #0x01               ; R0 = R0|0x01 friendly set pin_0 to 1
    STR R0, [R1]                    ; [R1] = R0

    BX LR
    .endasmfunc

;---------PortD_Pin0_Off---------
; Turn the Port D Pin0 off
; Input: R0, which takes in the current value at "R1 memory address"
; Output: none
; Modifies: R0, R1
PortD_Pin0_Off: .asmfunc
	LDR R1, GPIO_PORTD_DATA_R       ; R1 = &GPIO_PORTD_DATA_R
    LDR R0, [R1]                    ; R0 = [R1]
    AND R0, R0, #0xFE               ; R0 = R0|0x00 friendly set pin_0 to 0, with other bits set to 1 (AND) to not
    STR R0, [R1]                    ; [R1] = R0

    BX LR
    .endasmfunc

    .align                         ; make sure the end of this section is aligned


    .end                       ; end of file

