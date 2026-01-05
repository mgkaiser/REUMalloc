.segment "LOADADDR"
    .word $0801             ; Load address for BASIC stub

.segment "STARTUP"
    .byte $0C, $08          ; Link to next BASIC line (at $080C)
    .byte $0A, $00          ; Line number 10 (little endian)
    .byte $9E               ; Token for the BASIC command SYS
    .byte $20               ; Space character
    .byte $32, $30, $36, $34; ASCII representation of the address "2068"
    .byte $00               ; End of BASIC line marker
    .byte $00, $00          ; End of BASIC program marker

.IMPORT __STACK_START__,  __STACK_SIZE__

.segment "MAIN"

; Do the basic startup code here then call "main" the first "formal" function.
startup:

    ; Page out BASIC ROM for C64    
    lda #$36
    sta $01   

    ; Indicate that we are already running.  DEBUG_REG is $FF when running and $00 when stopped.
    lda #$FF
    sta DEBUG_REG  
                
    ; Call main procedure
    jsr main

    ; Page BASIC ROM back in
    lda #$37    
    sta $01

rts    