;------------------------------------
;-  Generated Initialization File  --
;TABLE1是顺时针点亮数码管循环的表格
;TABLE3是数码管显示数字0-9的表格
;PSW.1默认为0逆时针
;R0用于显示数字
;R7存储显示数字的整数部分
;R6存储显示数字的小数部分
;R2 DELAY1MS的次数
;------------------------------------

$include (C8051F310.inc)
	  LED BIT P0.0
	  BEEP	BIT P3.1
	  KINT BIT P0.1
	  MN EQU 30H
	  COUNT EQU 31H
	  ORG 0000H
	  LJMP MAIN
	  ORG 0003H
	  LJMP INTT0 ;0300H
	  ORG 0100H
MAIN: ACALL Init_Device
      MOV SP,#1FH
      CLR BEEP
	  CLR F0
	  CLR PSW.1
LOOP: ACALL START
      ACALL ORIENT	  
      ACALL MOOD
	  ACALL BIGNEW
	  SJMP $
		  
;--------------------------------------------------------------------中断区域-----------------------------------------------
;-------中断0亮灯--------
      ORG 0300H
INTT0:
      CPL LED
      LCALL D0_5s
;      CPL BEEP
;	  LCALL D2s
;	  CPL BEEP
      CPL F0
	  SETB TR0
      RETI
;-------end---------
;---------------------------------------------------------------------中断结束---------------------------------------------------
;--------------------------------------------------------------------子程序区域--------------------------------------------------------------
;------------------------------------------------------------键盘扫描---------------------------------------------------------
KEYPRO:
      PUSH DPL
	  PUSH DPH
      ACALL KEXAM
      JC KEYPRO
	  ACALL D10ms
	  ACALL KEXAM
	  JC KEYPRO ;无按键按下时C=1
	  ACALL D10ms
	  ACALL KEXAM
	  JC KEYPRO
KEY1: 
      MOV R3, #0FFH  ;列值寄存器
	  MOV R4, #00H  ;行值寄存器
KEY2: 
      CLR P2.0
	  SETB P2.1
	  SETB P2.2
	  SETB P2.3
	  NOP
	  NOP
	  NOP
      MOV C, P2.4
	  ANL C, P2.5
	  ANL C, P2.6
	  ANL C, P2.7
	  JNC KEY3  ;有键按下，转求列值
	  MOV A, R4  ;无键按下，行值寄存器加一
	  ADD A, #01H
	  MOV R4, A
	  SETB P2.0
      CLR P2.1
	  SETB P2.2
	  SETB P2.3
	  NOP
	  NOP
	  NOP
      MOV C, P2.4
	  ANL C, P2.5
	  ANL C, P2.6
	  ANL C, P2.7
	  JNC KEY3  ;有键按下，转求列值
	  MOV A, R4  ;无键按下，行值寄存器加一
	  ADD A, #01H
	  MOV R4, A
	  SETB P2.0
	  SETB P2.1
      CLR P2.2
	  SETB P2.3
	  NOP
	  NOP
	  NOP
      MOV C, P2.4
	  ANL C, P2.5
	  ANL C, P2.6
	  ANL C, P2.7
	  JNC KEY3  ;有键按下，转求列值
	  MOV A, R4  ;无键按下，行值寄存器加一
	  ADD A, #01H
	  MOV R4, A	  
      CLR P2.3
	  NOP
	  NOP
	  NOP
      MOV C, P2.4
	  ANL C, P2.5
	  ANL C, P2.6
	  ANL C, P2.7
	  JNC KEY3  ;有键按下，转求列值
	  CLR A
	  AJMP KEYPRO ;若全部扫描完毕，等待下一次扫描
      
KEY3: MOV A, P2
KEY4: INC R3
	  RLC A
	  JC KEY4 ;C=1时跳转
KEY5: ACALL D10ms
      ACALL KEXAM
	  JNC KEY5   ;有键按下,转向KEY5,等待键释放
	  SETB P2.0
	  SETB P2.1
	  SETB P2.2
	  SETB P2.3
	  MOV A, #03H
	  CLR C
	  SUBB A, R3
	  MOV B, #04H
	  MUL AB
	  ADD A, R4
	  AJMP KEYADR
;--------检测键盘是否按下-------
KEXAM:CLR P2.0
      CLR P2.1
	  CLR P2.2
	  CLR P2.3
	  NOP
	  NOP
	  NOP
	  MOV C, P2.4
	  ANL C, P2.5
	  ANL C, P2.6
	  ANL C, P2.7
	  SETB P2.0
	  SETB P2.1
	  SETB P2.2
	  SETB P2.3
	  RET
;--------检测结束--------------
;	  AJMP KEYPRO
;	  RET
;---------功能键地址转移------
KEYADR:CJNE A, #09H, KYARD1
       AJMP DIGPRO          ;DIGPRO数字键处理
KYARD1:JC DIGPRO
KEYTBL:MOV DPTR, #JMPTBL
       CLR C
	   SUBB A, #10
	   RL A
	   JMP @A+DPTR
JMPTBL:AJMP FUNC1
       AJMP FUNC2
	   AJMP FUNC3
	   AJMP FUNC4
	   AJMP FUNC5
	   AJMP FUNC6
       RET
;----------结束------------
;-------功能按键程序-------
FUNC1:   
         SETB F0
         AJMP EXIT
FUNC2:   
         CPL PSW.1
		 MOV R1,#1
		 JB PSW.1, NEXT
		 MOV R1,#0
NEXT:    AJMP EXIT
FUNC3:   MOV A, R6
         INC A
		 CJNE A, #10,HERE
		 MOV A, R7
		 INC A
		 MOV R7, A
		 MOV A, #00H
HERE:    MOV R6,A
		 AJMP EXIT
FUNC4:   MOV A, R7
         INC A
		 MOV R7,A
		 AJMP EXIT
FUNC5:   CPL PSW.1
		 AJMP EXIT
FUNC6:   MOV A, R6
         DEC A
		 CJNE A, #0FFH, HERE1		 
		 MOV A, R7
		 DEC A
		 MOV R7,A
		 MOV A, #09H
HERE1:   MOV R6,A
         AJMP EXIT		
//      AJMP KEYPRO
;-------结束-------------
;-------数字按键处理---
DIGPRO:
       MOV DPTR, #JMPNUM
	   CLR C
	   RL A
	   JMP @A+DPTR
JMPNUM:AJMP NUM0
       AJMP NUM1
	   AJMP NUM2
	   AJMP NUM3
	   AJMP NUM4
	   AJMP NUM5
	   AJMP NUM6
	   AJMP NUM7
	   AJMP NUM8
	   AJMP NUM9
	   RET
;--------数字按键功能------
NUM0:  MOV R1,#0
	   AJMP EXIT
NUM1:  MOV R1,#1
       AJMP EXIT
NUM2:  MOV R1,#2
       AJMP EXIT
NUM3:  MOV R1,#3
       AJMP EXIT
NUM4:  MOV R1,#4
       AJMP EXIT
NUM5:  MOV R1,#5
       AJMP EXIT
NUM6:  MOV R1,#6
       AJMP EXIT
NUM7:  MOV R1,#7
       AJMP EXIT
NUM8:  MOV R1,#8
       AJMP EXIT
NUM9:  MOV R1,#9
       AJMP EXIT
EXIT:    POP DPH
         POP DPL
		 RET
;       CPL LED
;       AJMP KEYPRO
;-------------------------------键盘扫描结束------------------------------------------
START: MOV R0, #00H
       SETB P0.6
       SETB P0.7
       ACALL DISPLAY
       ACALL D2s
	   SETB BEEP
	   ACALL D0_5S
	   CLR BEEP
	   RET
;--------设置循环方向---------------
ORIENT:MOV R0, #0CH
       SETB P0.7
	   SETB P0.6
	   ACALL DISPLAY
	   CLR P0.7
	   SETB P0.6
	   MOV R0, #0BH
	   ACALL DISPLAY
	   ACALL D10ms
	   ACALL KEXAM
	   JC ORIENT
	   ACALL KEYPRO
	   MOV A, R1
	   MOV R5, A
ORI_LOP:MOV R0, #0CH
       SETB P0.7
	   SETB P0.6
	   ACALL DISPLAY
	   CLR P0.7
	   SETB P0.6
       MOV A, R5
	   MOV R0, A
	   ACALL DISPLAY
	   ACALL D10ms
	   ACALL KEXAM
	   JC ORI_LOP
	   ACALL KEYPRO
	   MOV A, R1
	   MOV R5, A
	   JNB F0, ORI_LOP
	   CLR F0
	   RET
;--------END-----------------------
;--------设置模式设置频率-----------
MOOD:  
FIRST:MOV R0, #0AH
      SETB P0.7    ;3
	  SETB P0.6
      ACALL DISPLAY
	  SETB P0.7    ;2
	  CLR  P0.6
	  MOV R0, #0BH
	  ACALL DISPLAY1
	  CLR P0.7     ;1
	  SETB P0.6
	  MOV R0, #0BH
	  ACALL DISPLAY
	  ACALL D10ms
STAY0:ACALL KEXAM
	  JC FIRST
	  ACALL KEYPRO
	  MOV A, R1
	  MOV R7, A         ;将整数部分存入R7中
STAY1:MOV R0, #0AH           ;显示整数部分
      SETB P0.7    ;3 显示M
	  SETB P0.6
      ACALL DISPLAY
	  SETB P0.7    ;2
	  CLR  P0.6
	  MOV A, R7
	  MOV R0, A
      ACALL DISPLAY1 ;显示输入的整数部分，小数部分暂时不显示
	  CLR P0.7
	  SETB P0.6
	  MOV R0, #0BH
	  ACALL DISPLAY
	  ACALL D10ms
	  ACALL KEXAM
	  JC STAY1
	  ACALL KEYPRO
	  MOV A, R1
	  MOV R7, A
	  JNB F0, STAY1
	  CLR F0            ;整数部分已经确定，接着判断小数部分
SECOND:MOV R0, #0AH      
      SETB P0.7    ;3 显示M
	  SETB P0.6
      ACALL DISPLAY
	  SETB P0.7    ;2
	  CLR  P0.6
	  MOV A, R7
	  MOV R0, A
      ACALL DISPLAY1
	  CLR P0.7
	  SETB P0.6
	  MOV R0, #0BH
	  ACALL DISPLAY
	  ACALL D10ms
	  ACALL KEXAM
	  JC SECOND
	  ACALL KEYPRO
	  MOV A, R1
	  MOV R6,A                 
STAY3:MOV R0, #0AH           ;显示整数部分
      SETB P0.7    ;3 显示M
	  SETB P0.6
      ACALL DISPLAY
	  SETB P0.7    ;2
	  CLR  P0.6
	  MOV A, R7
	  MOV R0, A
      ACALL DISPLAY1 ;显示输入的整数部分，小数部分暂时不显示
	  CLR P0.7
	  SETB P0.6
	  MOV A, R6
	  MOV R0, A
	  ACALL DISPLAY
	  ACALL D10ms
	  ACALL KEXAM
	  JC STAY3
	  ACALL KEYPRO
	  MOV A,R1
	  MOV R6, A
	  JNB F0, STAY3
	  CLR F0            ;小数部分已经确定
	  RET
;-----------END------------------------
;---------数码管显示-------
DISPLAY: PUSH ACC
         PUSH DPL
         PUSH DPH
         MOV A, R0
		 MOV DPTR,#TABLE3
		 MOVC A,@A+DPTR
		 MOV P1,A
		 ACALL D1ms
		 POP DPH
		 POP DPL
		 POP ACC
//		 DJNZ R0,DISPLAY
         RET
;--------结束---------------
;---------带小数点的数码管显示-------
DISPLAY1:PUSH ACC
         PUSH DPL
         PUSH DPH
         MOV A, R0
		 MOV DPTR,#TABLE4
		 MOVC A,@A+DPTR
		 MOV P1,A
		 ACALL D1ms
		 POP DPH
		 POP DPL
		 POP ACC
//		 DJNZ R0,DISPLAY
         RET
;--------结束---------------
;--------带小数部分的循环可控亮灯--------
BIGNEW: 
        
BIG_LOP0:
        MOV COUNT, #6
BIG_LOP:MOV DPTR, #TABLE1
		JB PSW.1 ,BIG       ;PSW.1=1时顺时针循环
        MOV DPTR, #TABLE2		;PSW.1=0时逆时针循环
BIG:    CLR A
        MOVC A, @A+DPTR
//		MOV R4, A             ;循环亮灯的数存放在R4中
		MOV MN, A
		ACALL DEFER
PAUSE1:	JB F0, BIG
		INC DPTR
		DJNZ COUNT, BIG
		AJMP BIGNEW
		RET
		
DEFER: PUSH DPL
       PUSH DPH
       MOV A, R7
       MOV B, #10
	   MUL AB
	   ADD A, R6
	   MOV R5, A  ;R5存放着这两位数
	   MOV A, #167
       MOV B, R5
	   DIV AB
	   MOV B, #1
	   MUL AB
	   MOV R2, A        
DEFER_LOP:                   ;一次循环大致是10MS
       SETB P0.6
	   SETB P0.7
	   MOV A, R7
	   MOV R0, A
	   ACALL DISPLAY1         ;一直传到这来了
       ACALL D1ms
	   ACALL D1ms
       SETB P0.7
	   CLR P0.6
	   MOV A, R6
	   MOV R0, A
	   ACALL DISPLAY
	   ACALL D1ms
	   ACALL D1ms
       CLR P0.6
	   CLR P0.7
	   MOV A, MN
	   MOV P1, A            ;循环亮灯赋值
	   ACALL D1ms
	   ACALL D1ms
	   ACALL D1ms
	   ACALL D1ms
	   ACALL KEXAM
	   JC DEF_L
	   ACALL KEYPRO
//PAUSE1: JB F0, PAUSE1 
DEF_L: DJNZ R2,DEFER_LOP
	   POP DPH
	   POP DPL
	   RET
;------------END----------------------
;-------DELAY 1MS-------
D1ms: MOV TMOD,#01H
      MOV TH0,#0FEH
	  MOV TL0,#01H
	  SETB TR0
	  JNB TF0,$
	  CLR TF0
	  CLR TR0
	  RET
;;-------delay 10ms-------
D10ms:MOV TMOD,#01H
      MOV TH0,#0ECH
	  MOV TL0,#0FH
	  SETB TR0
	  JNB TF0,$
	  CLR TF0
	  CLR TR0
	  RET
;--------end------------	
;-------delay 0.5s---------
D0_5S:MOV R3, #5
L_0_5:MOV TMOD,#01H
      MOV TH0,#38H
	  MOV TL0,#9EH
	  SETB TR0
	  JNB TF0,$
	  CLR TF0
	  DJNZ R3, L_0_5
	  CLR TR0
	  RET
;------end------
;-------delay 2s---------
D2s:  MOV R3, #20
L_2:  MOV TMOD,#01H
;      MOV TH0, #36H
;	  MOV TL0, #0D3H
      MOV TH0, #38H
	  MOV TL0, #91H
	  SETB TR0
	  JNB TF0,$
	  CLR TF0
	  DJNZ R3, L_2
	  CLR TR0
	  RET
;--------end-------

;--------------------------------------------------------------子程序结束-------------------------------------------------
;--------------表格----------------
TABLE1:DB 0C0H,60H,30H,18H,0CH,84H
TABLE2:DB 84H,0CH,18H,30H,60H,0C0H
TABLE3:DB 0FCH,60H,0DAH,0F2H,66H,0B6H,0BEH,0E0H,0FEH,0F6H,  0ECH,02H ,7CH
;                                                             A , B  , C
TABLE4:DB 0FDH,61H,0DBH,0F3H,67H,0B7H,0BFH,0E1H,0FFH,0F7H,  0EDH,03H
;------------表格结束---------------
; Peripheral specific initialization functions,
; Called from the Init_Device label
PCA_Init:
    anl  PCA0MD,    #0BFh
    mov  PCA0MD,    #000h
    ret

Timer_Init:
    mov  TMOD,      #001h
    mov  CKCON,     #002h
    ret

Port_IO_Init:
    ; P0.0  -  Unassigned,  Open-Drain, Digital
    ; P0.1  -  Unassigned,  Open-Drain, Digital
    ; P0.2  -  Unassigned,  Open-Drain, Digital
    ; P0.3  -  Unassigned,  Open-Drain, Digital
    ; P0.4  -  Unassigned,  Open-Drain, Digital
    ; P0.5  -  Unassigned,  Open-Drain, Digital
    ; P0.6  -  Unassigned,  Open-Drain, Digital
    ; P0.7  -  Unassigned,  Open-Drain, Digital

    ; P1.0  -  Unassigned,  Open-Drain, Digital
    ; P1.1  -  Unassigned,  Open-Drain, Digital
    ; P1.2  -  Unassigned,  Open-Drain, Digital
    ; P1.3  -  Unassigned,  Open-Drain, Digital
    ; P1.4  -  Unassigned,  Open-Drain, Digital
    ; P1.5  -  Unassigned,  Open-Drain, Digital
    ; P1.6  -  Unassigned,  Open-Drain, Digital
    ; P1.7  -  Unassigned,  Open-Drain, Digital
    ; P2.0  -  Unassigned,  Open-Drain, Digital
    ; P2.1  -  Unassigned,  Open-Drain, Digital
    ; P2.2  -  Unassigned,  Open-Drain, Digital
    ; P2.3  -  Unassigned,  Open-Drain, Digital

    mov  XBR1,      #040h
    ret

Oscillator_Init:
    mov  OSCICN,    #083h
    ret
	
Interrupts_Init:
    mov  IE,        #081h
    ret
; Initialization function for device,
; Call Init_Device from your main program
Init_Device:
    lcall PCA_Init
    lcall Timer_Init
    lcall Port_IO_Init
    lcall Oscillator_Init
	lcall Interrupts_Init
    ret

end