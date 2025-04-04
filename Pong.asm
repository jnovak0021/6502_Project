;System variables for pong
define  sysRandom  $fe ; address of a random value
define  sysLastKey $ff ; address for the last key
 
;Defining the keys a and d to move the paddle left and right
define ASCII_a      $61
define ASCII_d      $64
 
define paddleL $00; Low Byte of the paddle location
define paddleH $01; High byte of the paddle location

; Both are low because the paddle pixel row is 05a0--05bf
define paddleBoundaryL $9f
define paddleBoundaryR $bb
define paddleLength    $05

define paddleDirection $02

;Defining the directions of the directions the paddle can move
define  movingLeft  $01
define  movingRight $02

define ballL        $10; Low byte of the ball location
define ballH        $11; High byte of the ball location
define ballPrevL    $12; Low byte of the previous ball location
define ballPrevH    $13; High byte of the previous ball location

define ballXVel     $14; can be 01, 02, or 03 for straight, left, and right
define ballYVel     $15; can be 01, 02, or 03 for straight, up, and down

define moveDownOneRow $0f ; to use for the up and down movement?

define scoreBarL $20 ; memory location for start of score bar
define scoreBarH $21
define scoreBarLength $22; memory location to hold how long the score bar is

define scoreBarRBoundary #$20 ; right end of score bar
define scoreBarColor $23; memory location to hold the score bar color

define ballMinRowH $02  ; Lowest visible screen row for the ball
define ballMinColL $02  ; Prevent left from going past column 0

;Calling the initialization and then the loop of the pong game
jsr init
jsr pongLoop

init:
jsr paddleInit
jsr ballInit
jsr scoreBarInit
rts

; Main Logic Loop
pongLoop:
jsr readKeys
jsr paddleUpdate; moving the paddle
jsr ballUpdate  ; moving the ball
jsr drawPaddle  ; drawing the paddle on the screen
jsr drawBall    ; drawing the ball on the screen
jsr drawScoreBar; drawing the score bar on the screen
jsr spinWheels ; Slowing it down
INC scoreBarLength
jmp pongLoop ; Restarting loop

;A subroutine that draws the score bar on the bottom of the screen
drawScoreBar:
  LDY scoreBarLength ; getting the score bar length
  CPY #$00 ;comparing the length to 0 if so skipping the
  BEQ skipBarDraw ;drawing of the bar
  CPY #$21  ;checking to see if the length is at the end
  BEQ changeColor ; of the screen if so changing the color and erasing he old bar
  BNE drawBarLoop ; if neither above cases are triggered just draw the bar like normal.
;Changing the color of the score bar by incrementing the scoreBarColor memory location and reset the score bar length to 0
changeColor:
  LDA #$00
  STA scoreBarLength ;reset the score bar length with 0
  INC scoreBarColor  ;changing the color of the score bar\
;Erasing the score bar pixel by pixel
eraseBarLoop:
  LDA #$00
  DEY
  STA (scoreBarL),Y
  CPY #$00
  BNE eraseBarLoop
  jmp skipBarDraw ; skipping the bar draw because length is 0 after erasing
;drawing the score bar based on length
drawBarLoop:
  LDA scoreBarColor
  DEY
  STA (scoreBarL),Y
  CPY #$00
  BNE drawBarLoop
skipBarDraw:
  RTS

;initalizing the score bar's memory address
scoreBarInit:
  LDA #$05
  STA scoreBarH;
  LDA #$e0
  STA scoreBarL;
  LDA #$00
  STA scoreBarLength
  LDA #$05
  STA scoreBarColor
  RTS

;Subroutine to update the ball location so that it moves as desired
ballUpdate:
  ;first store the current address of the ball in previous before we move it
  LDA ballL
  STA ballPrevL
  LDA ballH
  STA ballPrevH

  ;for now just start with test values
  ;ballXVel values: #01 = straight, #02 = left, #03 = right.
  LDA #$02
  STA ballYVel
  LDA #$02
  STA ballXVel
  ;ballYVel values: #01 = straight, #02 = up, #03 = down.
  


  ;horizontal movement
  
  LDA ballXVel  ;store value at ballXVel at A for comparison
  ;if ballXVel is #$01, it is just verticle so we dont need to do any adjustments

  CMP #$02  ;check if ballXVel is in the left direction
  BNE skipBallLeft   ; if A is not #02 (left), skip dont move ball left
  JSR BallLeft      ; subroutine to move ball left
  skipBallLeft:

  CMP #$03  ;check if ballXVel is in the right direction
  BNE skipBallRight   ; if A is not #03 (right), skip dont move ball right
  JSR BallRight      ; subroutine to move ball right
  skipBallRight:

  ;verticle update
  LDA ballYVel

  CMP #$02  ;check if ballYVel is in the UP direction
  BNE skipBallUp  ; if A is not #02 (up), skip dont move ball up
  JSR BallUp      ; subroutine to move ball up
  skipBallUp:

  CMP #$03  ;check if ballYVel is in the down direction
  BNE skipBallDown  ; if A is not #03 (down), skip dont move ball down
  JSR BallDown      ; subroutine to move ball down
  skipBallDown:
  
  ;do checks against edges

  RTS

;sub routine to minus 20 to the current ballAddress to simulate the ball moving Up
BallLeft:
  LDA ballL
  CMP #ballMinColL
  BEQ skipBallLeft ; If ball is already at far left, skip
  SEC              ; Set carry before SBC
  SBC #$01
  STA ballL

  LDA ballH
  SBC #$00
  STA ballH
skipBallLeft:
RTS

;sub routine to add 1 to the current ballAddress to simulate the ball moving right
BallRight:
  ;clear carry and add to 20 to the low byte
  CLC
  LDA ballL
  ADC #$01
  STA ballL
  ;account for carry bit by adding #$00 to the upper byte
  LDA ballH
  ADC #$00
  STA ballH
RTS

;sub routine to minus 20 to the current ballAddress to simulate the ball moving Up
BallUp:
  ; Check if we’re about to underflow vertically
  LDA ballH
  CMP #ballMinRowH
  BCC skipBallUp ; If ballH < min row, skip move

  SEC
  LDA ballL
  SBC #$20
  STA ballL

  LDA ballH
  SBC #$00
  STA ballH
skipBallUp:
  RTS


;sub routine to add 20 to the current ballAddress to simulate the ball moving down
BallDown:
  ;clear carry and add to 20 to the low byte
  CLC
  LDA ballL
  ADC #$20
  STA ballL
  ;account for carry bit by adding #$00 to the upper byte
  LDA ballH
  ADC #$00
  STA ballH
RTS

;Initalization of the ball and the different memory loactions to store it's information
ballInit:
  LDA sysRandom
  STA ballL
  ;load a new random number from 2 to 4 into ballH to make the ball start in a valid position
  LDA sysRandom ; Load the system random value
  AND #$03  ; masking out the two lowest bits
  CLC       ; Clear the carry flag before adding
  ADC #$02  ; Adding 2 to make the range to 02-04
  CMP #$05  ; Compare the value to 05
  BCC valid_number; If it's less than 05, it's valid
  SEC       ; Set the carry flag for subtraction
  SBC #$03  ; Subtract 3 to keep it from 02-04
valid_number:
  STA ballH ; storing the random value 02-04 in ballH
  RTS
 

; Subroutine to draw ball
drawBall:
   LDY #$00 ; storing 0 in the Y register to keep it blank
   LDA #$00 ; storing the color black in A as #$00
   ;Comment out following line once ballUpdate is finisheddd
   STA (ballPrevL),Y ; erasing the previous ball
   LDA #$01 ; storing the color white in A as 01
   STA (ballL),Y  ; drawing the ball in the new spot
   RTS

;Subroutine that initalizes the paddle by storing the correct location in the screen for it to start 05af in the paddleH and paddleL memory locations. It also starts the paddle off moving to the left.
paddleInit:
  LDA #$05
  STA paddleH
  LDA #$af
  STA paddleL
  LDA #movingLeft
  STA paddleDirection
  RTS

;A subroutine that updates the paddleL location based on the paddleDirection memory location. If either boundary Right or Left is hit the paddle will stop moving.
paddleUpdate:
   LDA paddleDirection ; getting the paddle direction
   CMP #movingLeft     ; checking to see if it is left
   BEQ movePaddleLeft  ; jumping to the move left location
   
   CMP #movingRight    ;checking to see if it is right
   BEQ movePaddleRight ;jumping to the move right location
   
   ; moving the paddle left by decrementing paddleL and checking to see if paddleL reached the paddleBoundaryL if so increment paddleL to not let it move past the boundary
movePaddleLeft:
   DEC paddleL; moving the paddle pixel start location left
   LDA #paddleBoundaryL
   CMP $00
   BNE notAtLBoundary
   INC paddleL
notAtLBoundary:
   LDX #$00 ;Making a branch to skip the move paddle right
   CPX #$00
   BEQ done
 
   ;incrementing paddleL and checking to see if it is greater than the paddleBoundaryR if it is then not letting it move
movePaddleRight:
   INC paddleL
   LDA #paddleBoundaryR
   CMP $00
   BCS notAtRBoundary
   dec paddleL
notAtRBoundary:
   LDX #$00
   CPX #$00
   BEQ done

   ;using done to skip move paddle right so that the paddle only moves one direction at a time
   done:
   rts
   
; Subroutine to draw paddle and erase the necessary pixel based on the way the paddle is traveling.
drawPaddle:
   ; erases the necessary pixel for the paddle based on the direction
   LDA paddleDirection ; Checking to see which direction the paddle is moving and moving to the corresponding section
   CMP #movingLeft
   BEQ deleteRightPixel
   CMP #movingRight
   BEQ deleteLeftPixel
   
deleteLeftPixel:
   LDY #$00
   DEC $00
   LDA #$00
   STA (paddleL),Y
   INC $00
   LDX #$00
   CPX #$00
   BEQ skipDeleteRightPixel
 
deleteRightPixel:
   LDY #paddleLength
   LDA #$00
   STA (paddleL),Y
   
skipDeleteRightPixel:

   ; Draws the 5 pixels of the paddle
   LDY #paddleLength
   drawLoop:
   LDA #01
   DEY
   STA (paddleL),Y
   CPY #$00
   BNE drawLoop
   RTS

;reading the keys from the system and performs the necessary action
readKeys:
  LDA sysLastKey
  CMP #ASCII_d
  BEQ rightKey
  CMP #ASCII_a
  BEQ leftKey
  RTS

;Changing the paddleDirection to right when D is pressed
rightKey:
  LDA #movingRight
  STA paddleDirection
  RTS

;Changing the paddleDirection to left when A is pressed
leftKey:
  LDA #movingLeft
  STA paddleDirection
  RTS ; Return


; Subroutine to "stall" clock
spinWheels:
  LDX #0
spinloop:
  NOP
  NOP ; No operations
  DEX
  CPX #$00
  BNE spinloop
  RTS ; Return
