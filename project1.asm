org 0H
;buttons
plus EQU P1.0
minus EQU P1.1
enter EQU P1.2
stop EQU P1.3
;lcd pins 
RS EQU P3.0
RW EQU P3.1
EN EQU P3.2
;motor enabler
relaysignal EQU P1.4
;water indicator
lowwaterlvl EQU P3.3
;water alert 
buzzer EQU P3.4 
;initialize inputs
setb plus 
setb minus
setb enter
setb stop
setb lowwaterlvl
;initialize outputs
clr relaysignal
clr buzzer

INIT_7SEG: mov P2, #0C0H ;display 0 at 7seg
INIT:
	mov DPTR, #INIT_LCD
	mov R4, #5
LCD: 	movc A, @A+DPTR 
	acall command
	inc DPTR
	clr A
	DJNZ R4, LCD

INIT_ENTRY:
	mov DPTR, #0
	mov DPTR, #ENTRYMSG
	mov R4, #13
	acall delay
DISPLAYENTRY:
	movc A, @A+DPTR
	acall display
	inc DPTR
	clr A
	DJNZ R4,DISPLAYENTRY
	clr A
START:
	jnb plus, GOTOADD  ; if add button is pressed, go to add_one
	jnb minus, GOTOSUB ; if sub button is pressed, go to sub_one
	jnb enter, STARTTIMER ; if enter button is pressed, go to starttimer
	jnb stop, CLEAR
	jnb lowwaterlvl, checkwl_lvl
	sjmp START  ; while loop
GOTOSUB: LJMP SUB_ONE
GOTOADD: LJMP ADD_ONE
CHECKWL_LVL:
	jnb lowwaterlvl, WATERLVL_LOW 
	SJMP INIT_ENTRY
WATERLVL_LOW: 
	mov A, #01
	acall command
	mov A, #80H
	acall command
	mov DPTR, #0H
	mov DPTR, #LOWLVL
	mov R5, #15
	clr A
DISPLAYWL:
	movc A, @A+DPTR
	acall display
	inc DPTR
	clr A
	DJNZ R5,DISPLAYWL
INIT_REFILL:
	mov A, #0C0H
	acall command
	mov DPTR, #0
	mov DPTR, #REFILL
	mov R4, #12
	clr A
DISPLAYREFILL:
	movc A, @A+DPTR
	acall display
	inc DPTR
	clr A
	DJNZ R4,DISPLAYREFILL
	setb buzzer 
	acall delayrelay
HERE: 	jnb lowwaterlvl, HERE
	clr buzzer
	acall delayrelay
	mov A, #01H 
	acall command 
	mov A, #80H
	acall command
	SJMP INIT_ENTRY

CLEAR: 	mov P2, #0C0H
	clr A
	mov R0, A
	mov R6, A
	sjmp start 
STARTTIMER: 
	mov A, #01
	acall command
	mov A, #80H
	acall command
INIT_TIMERMSG:
	mov DPTR, #0
	mov DPTR, #TIMERMSG
	mov R5, #16
	acall delay
DISPLAYTIMERMSG:
	movc A, @A+DPTR
	acall display
	inc DPTR
	clr A
	DJNZ R5,DISPLAYTIMERMSG
	mov A, R0 ; the input time is stored in R0 then passed to A
	mov R6, A ; the input time also stored in R6 for reload purposes
	LJMP COUNTDOWN ; go to countdown
ADD_ONE: 
	clr A 
	mov A, R0
	inc A
	mov R0, A
	acall delay
	ljmp CHECKVALUE
	ljmp start 
SUB_ONE: 
	clr A 
	clr c 
	mov A, R0
	dec A
	mov R0, A
	acall delay
	ljmp CHECKVALUE
	ljmp start 

CHECKVALUE:
	mov A, R0
	cjne A, #0, DISPLAY1
	;acall delay
	mov P2, #0C0H
	LJMP start 
DISPLAY1: 
	mov A, R0
	cjne A, #1, DISPLAY2
	;acall delay
	mov P2, #0F9H
	LJMP start 
DISPLAY2: 
	mov A, R0
	cjne A, #2, DISPLAY3
	;acall delay
	mov P2, #0A4H
	LJMP start 
DISPLAY3: 
	mov A, R0
	cjne A, #3, DISPLAY4
	;acall delay
	mov P2, #0B0H
	LJMP start 
DISPLAY4: 
	mov A, R0
	cjne A, #4, DISPLAY5
	;acall delay
	mov P2, #99H
	LJMP start 
DISPLAY5: 
	mov A, R0
	cjne A, #5, DISPLAY6
	;acall delay
	mov P2, #92H
	LJMP start 
DISPLAY6: 
	mov A, R0
	cjne A, #6, DISPLAY7
	;acall delay
	mov P2, #82H
	LJMP start 
DISPLAY7: 
	mov A, R0
	cjne A, #7, DISPLAY8
	;acall delay
	mov P2, #0F8H
	ljmp start 
DISPLAY8: 
	mov A, R0
	cjne A, #8, DISPLAY9
	;acall delay
	mov P2, #80H
	ljmp start 
DISPLAY9: 
	mov A, R0
	cjne A, #9, LOOP 
	;acall delay
	mov P2, #90H
	ljmp start 
LOOP: ;now A becomes 10
	mov A, R0
	clr c 
	clr A
	mov R0, A
	;setb enter
	ljmp checkvalue	

COUNTDOWN:
	jnb stop, STOP ; if stop button is pressed, go to STOP
	jnb lowwaterlvl, GOTOWL
	cjne A, #0, CONTINUE ; if A is not 0 go to CONTINUE else if A = 0 go to next line 
	acall RELAY ; if A=0 then water dispenser system is enable
	mov A, R6 ; since A and R0 is 0 now, store back input time to A from R6
	inc A ; so that the input time will be displayed and not the decremented by 1 first 
	mov R0, A ;pass it to R0
CONTINUE: ; continue a target to have a delay of 59 secs 
	jnb stop, STOP
	jnb lowwaterlvl, GOTOWL
	mov R3, #8
d1: 	mov R2, #255
d2:	mov R1, #255
d3: 	djnz R1, d3
    	djnz R2, d2
   	djnz R3, d1 ; end of delay 
   	dec R0 ; decrement the input time
   	mov A, R0 ; update R0 and pass input time to A
    	mov DPTR, #0 ; clr DPTR
    	mov DPTR, #NUMBERS ; point to numbers 
displayNum: 
	movc A, @A+DPTR ;to display numbers to 7seg
	mov P2, A  ; pass it to the port connected to the 7seg
	acall delay 
	mov A, R0 ; store the input time back to A for countdown purposes
	LJMP countdown 

GOTOWL: LJMP CHECKWL_LVL
stop: 
	clr A
	mov R0, A 
	mov P2, #0C0H
INIT_STOP:
	mov A, #01
	acall command 
	mov A, #80H
	acall command 
	mov DPTR, #0
	mov DPTR, #STOPMSG
	mov R4, #14
	acall delay
DISPLAYSTOP:
	movc A, @A+DPTR
	acall display
	inc DPTR
	clr A
	DJNZ R4,DISPLAYSTOP
	clr A
	LJMP INIT_LCD 

RELAY:
	setb relaysignal ; to turn on the motor
	acall delayrelay ; delay is designed to limit the water that will be dispensed
	clr relaysignal ; to turn off the motor
	ret 

NUMBERS: DB 0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H, 80H, 90H ; common anode 
;NUMBERS: DB 3FH,06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH
INIT_LCD: DB 38H, 0EH, 01H, 06H, 80H
ENTRYMSG: DB ' Enter time: '
TIMERMSG: DB ' Timer starting '
STOPMSG: DB ' Timer stopped'
LOWLVL: DB ' Water lvl: LOW' ;15 char
REFILL: DB ' Refill tank' ;12 char


delay: mov R3, #4 ; delay for displaying in the 7seg 
l1: mov R2, #250
l2: mov R1, #255
l3: djnz R1, l3
    djnz R2, L2
    djnz R3, l1
    ret

delayrelay: mov R3, #50 ; delay to control the amount of water being dispensed
lr1: mov R2, #250
lr2: mov R1, #255
lr3: djnz R1, lr3
    djnz R2, lr2
    djnz R3, lr1
    ret

delaydisplay: mov R3, #4 ; delay for displaying in the 7seg 
ld1: mov R2, #2
ld2: mov R1, #255
ld3: djnz R1, ld3
    djnz R2, ld2
    djnz R3, ld1
    ret


COMMAND:
	mov P0, A 
	clr RS
	clr RW
	setb EN
	acall delay
	clr EN
	ret
DISPLAY:
	mov P0, A
	setb RS
	clr RW
	setb EN
	acall delaydisplay
	clr EN
	ret
end

