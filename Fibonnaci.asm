;A program that starts with 0 and 1 then adds the two previous numbers recently stored to create the first 14 Fibonacci numbers

;Storing the address of the current screen location writing to
LDA #$01; Getting the value 01 into the accumulator
STA $00 ; Storing the value 01 at location 00
LDA #$03; Getting the value 03 into the accumulator
STA $01 ; Storing the value 03 at location 01

;Storing the address of the previous number that was used by storing the value of the previous pixel bit
LDA #$00; Getting the value 00 into the accumulator
STA $10 ; Storing the value 00 at location 10
LDA #$03; Getting the value 03 into the accumulator
STA $11 ; Storing the value 03 at location 11

LDY #$00; Loading the value of 00 into Y
TYA ;Transferring the value 00 to the accumulator

LDX #$01;Loading the value of 0 to X register and using X as the counter variable for the 14 Fibonacci numbers

LDA #$01; Loading the value of 1 to the value of the A register to start the sequence
STA ($00),Y ; Storing the value of 1 at the designated pixel location 0301

;Creating a loop that runs the Fibonacci function
FibonacciLoop:
ADC ($10),Y; Adding the value that is stored starting at register 0300 which is updated with the value of the previous number added keeping the value in the accumalator
STX $10; Storing the value of X to the littlest bit of the address
INX; Incrementing X
STX $00; Storing the new address bit of X to location 00 to hold the least significant byte as indicated by X
STA ($00),Y; Storing the accumalator to the designated location held starting at register 00

CPX #$0d; Comparing the value of X to the value of 13 to to make sure to calculate the first 14 numbers of the sequence not counting 0 at the start
BNE FibonacciLoop; Looping until we have gone through the 14 numbers of the sequence