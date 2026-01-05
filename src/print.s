.scope
.define current_file "print.s"

.include "mac.inc"
.include "math.inc"
.include "print.inc"

.segment "MAIN"

; Define exports for all public functions in this module
.export gotoxy
.export print
.export convert_16bit_to_decimal
.export convert_16bitptr_to_decimal

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables that do not require initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "BSS"

; Additional data definitions
DECIMAL_BUFFER: .res 6  ; Buffer for 5-digit decimal string

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables that DO require initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "MAIN"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main Program Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                

; Move the cursor to the position specified in X (column) and Y (row)
; usage:
;   ldx <column>
;   ldy <row>
;   jsr gotoxy
; Result:
;   The cursor is moved to the specified position.
; Destroyed:
;   None
.proc gotoxy : near
    clc
    jmp $fff0  ; C64 KERNAL SETCURSOR routine    
.endproc

; Print a null-terminated PETSCII string pointed to by the address in X and Y
; usage:
;   ldx <low byte of address>
;   ldy <high byte of address>
;   jsr print
; Result:
;   The string is printed to the screen.
; Destroyed:
;   PTR1, A, Y
.proc print: near
    stx PTR1
    sty PTR1+1
    ldy #$00
print_loop:
    lda (PTR1), y
    beq done_printing
    jsr KERNAL_CHROUT          ; C64 KERNAL CHROUT routine
    iny
    jmp print_loop
done_printing:
    rts
.endproc

; Convert a 16-bit number pointed to by the address in X and Y to decimal
; and print it using the print routine.
; usage:
;   ldx <low byte of address>
;   ldy <high byte of address>
;   jsr convert_16bitptr_to_decimal
; Result:
;   DECIMAL_BUFFER contains the resulting null-terminated PETSCII string
;   The string is also printed to the screen.
; Destroyed:
;   PTR1, TMP1, TMP1 + 1, TMP2, TMP2 + 1, TMP3, TMP3 + 1, A, X, Y
.proc convert_16bitptr_to_decimal : near
    stx PTR1
    sty PTR1 + 1
    ldy #$00
    lda (PTR1), y
    sta TMP1
    iny
    lda (PTR1), y
    sta TMP1 + 1
    jmp convert_16bit_to_decimal
.endproc

; Convert the 16-bit number in TMP1:TMP1 + 1 to a decimal string
; and print it using the print routine.  This will always return
; a string of 5 characters.  Numbers will be right justified with 
; leading spaces.
; usage:
;   TMP1:TMP1 + 1 = 16-bit number to convert
;   jsr convert_16bit_to_decimal
; Result:
;   DECIMAL_BUFFER contains the resulting null-terminated PETSCII string
;   The string is also printed to the screen.
; Destroyed:
;   TMP2, TMP2 + 1, TMP3, TMP3 + 1, A, X, Y   
.proc convert_16bit_to_decimal : near
    
    ; Zero out the buffer for the decimal string
    ldx #$00
clear_buffer:
    lda #$00
    sta DECIMAL_BUFFER, x
    inx
    cpx #6
    bne clear_buffer

    ; Load the 16-bit number into TMP2 (low) and TMP2 + 1 (high) for division
    lda TMP1
    sta TMP2
    lda TMP1 + 1
    sta TMP2 + 1

    ; Store the divisor (10) in TMP3
    lda #$0A          ; Divisor = 10
    sta TMP3

    ; Convert to decimal digits (PETSCII)
    ldx #4  ; Start at the least significant digit (buffer index 4)
convert_loop:
    ; Divide TMP2:TMP2 + 1 by TMP3 (10) to get the next digit.  Preserve X    
    txa
    pha
    jsr divide_16bit_by_8bit
    pla
    tax 

    ; Store the remainder (returned in A) as PETSCII in the buffer    
    lda TMP3 + 1
    clc
    adc #$30  ; Convert to PETSCII ('0'-'9')
    sta DECIMAL_BUFFER, x

    dex         ; Move to the next digit
    bpl convert_loop

    ; Check for leading zeros
    ldx #$00
remove_leading_zeros:
    lda DECIMAL_BUFFER, x
    cmp #$30  ; Compare with PETSCII '0'
    bne done_leading_zeros
    lda #$20
    sta DECIMAL_BUFFER, x
    inx
    cpx #4
    bne remove_leading_zeros
done_leading_zeros:

    ; Print the resulting string
    ldx #<DECIMAL_BUFFER
    ldy #>DECIMAL_BUFFER
    jsr print

    rts
.endproc

.endscope