;store the low byte of our screen address
define addyL $00	;store at Mem addy $00
LDA #$01	;load immediate value #$01 in $00
STA addyL

;store the high byte of our screen address
define addyH $01	;store at Mem addy $01
LDA #$03	;load immediate value #$03 at $01
STA addyH

;store the offset value for each row
define offset $05	;store at Mem addy $05
LDA #$20	;load immediate value #$20 at $05
STA offset

;store the number of lines to draw
define numLines $06	;store at Mem addy $06
LDA #$0a
STA numLines

;store the current number of lines drawn at Y
LDY #$00	;initialize Y register to track number of lines drawn

;go to the main subroutine to draw the box
JSR DRAW

BRK	

;draw subroutine to draw the Horiz lines numLines times
DRAW:
	;loop while value at $07 (lines drawn) is NE $06 (lines to be drawn)
	DRAWLOOP:
	;before we call drawhoriz, push Y to the stack to save how many rows we have draw
	TYA		
	PHA		;push A onto stack

	
	JSR DRAWHORIZ   ;call DRAWHORIZ to draw the line
	;add 20 to get to next row of screen addy @0000
	LDA addyL	;add 20 to low bit
	CLC		;clear carry flag before addition
	ADC offset 
	STA addyL
	
	LDA addyH	;add carry bit to upper byte of screen
	ADC #$00    ;add 0 to upper byte to account for carry
	STA addyH   ;store back in addyH

	PLA		;restore Y from stack to get lines drawn
	TAY		

	INY		;increment Y to count the drawn line
	TYA		
	CMP numLines 	;compare number of drawn lines with total lines
	BNE DRAWLOOP	;branch back if more lines need to be drawn
	
RTS	

;draw a horiz row of 10 pixels
DRAWHORIZ:
	LDY #$00	;reset X

	HORIZLOOP:	;loop for 10 pixels
	
    ;add x to screen mem addy at 00 01
	CLC		;clear carry flag before addition
	LDA addyL
	STA (addyL),Y	;store value at computed screen address
	ADC Y		;add current pixel index to A
	LDA addyH
	ADC #$00	;carry over addition to high byte if needed
	
	INY		;increment x
	;CMP with numLines
	CPY numLines	;compare Y with numLines to ensure 10 pixels are drawn
	BNE HORIZLOOP	;loop if more pixels need to be drawn
	
RTS	
