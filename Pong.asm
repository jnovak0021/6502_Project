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
define paddleLength $05

define ballL   $10; Low byte of the ball location
define ballH   $11; High byte of the ball location
define paddleDirection $02

;Defining the directions of the directions the paddle can move
define  movingLeft  $01
define  movingRight $02

;Calling the initialization and then the loop of the pong game
jsr init
jsr pongLoop

init:
jsr paddleInit
rts

; Main Logic Loop
pongLoop:
jsr readKeys
jsr drawPaddle  ; drawing the paddle on the screen
jsr paddleUpdate;
jsr spinWheels ; Slowing it down
jmp pongLoop ; Restarting loop

;Subroutine that initalizes the paddle by storing the correct location in the screen for it to start 05af in the paddleH and paddleL memory locations. It also starts the paddle off moving to the left.
paddleInit:
  LDA #$05
  STA paddleH
  LDA #$af
  STA paddleL
  LDA #movingLeft
  STA paddleDirection
  rts

;A subroutine that updates the paddleL location based on the paddleDirection memory location. If either boundary Right or Left is hit the paddle will stop moving.
paddleUpdate:
   LDA paddleDirection ; getting the paddle direction
   CMP #movingLeft     ; checking to see if it is left
   BEQ movePaddleLeft  ; jumping to the move left location
   
   CMP #movingRight    ;checking to see if it is right
   BEQ movePaddleRight ;jumping to the move right location
   
   ; moving the paddle left by decrementing paddleL and checking to see if paddleL reached the paddleBoundaryL if so increment paddleL to not let it move past the boundary
   movePaddleLeft:
   dec paddleL; moving the paddle pixel start location left
   LDA #paddleBoundaryL
   CMP $00
   BNE notAtLBoundary
   inc paddleL
   notAtLBoundary:
   LDX #$00 ;Making a branch to skip the move paddle right
   CPX #$00
   BEQ done
 
   ;incrementing paddleL and checking to see if it is greater than the paddleBoundaryR if it is then not letting it move
   movePaddleRight:
   inc paddleL
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


; Subroutine to draw ball
drawBall:
   RTS

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

