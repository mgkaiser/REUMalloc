.scope
.define current_file "math.s"

.include "mac.inc"
.include "math.inc"

.segment "MAIN"

; Define exports for all public functions in this module
.export divide_16bit_by_8bit

; Divide a 16-bit number in TMP2:TMP2 + 1 by an 8-bit TMP3 in TMP3
; Result: TMP2:TMP2 + 1 = quotient, TMP3 + 1 = remainder
; usage:
;   TMP2:TMP2 + 1 = dividend (16-bit)
;   TMP3 = divisor (8-bit)
;   jsr divide_16bit_by_8bit
; Result: 
;   TMP2:TMP2 + 1 = quotient, TMP3 + 1 = remainder
; Destroyed:
;   TMP2, TMP2 + 1, TMP3+1, A, X    
.proc divide_16bit_by_8bit : near    
    ldx #16
    lda #0
    divloop:
    asl TMP2
    rol TMP2+1
    rol a
    cmp TMP3
    bcc no_sub
    sbc TMP3
    inc TMP2
    no_sub:
    dex
    bne divloop

    ; Store remainder
    sta TMP3 + 1
    
    rts
.endproc

.endscope