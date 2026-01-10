.scope
.define current_file "reu.s"

.include "mac.inc"
.include "reu.inc"

; Define exports for all public functions in this module
.export reu_copy_from_cpu_to_reu
.export reu_copy_from_reu_to_cpu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables that do not require initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "BSS"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables that DO require initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "MAIN"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main Program Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                

; Copy data from CPU memory to REU memory
; usage:
;   R0      = source address in CPU memory (16-bit)
;   R1:R2L  = destination address in REU memory (24-bit)
;   R3      = length in bytes (16-bit)
;   jsr reu_copy_from_cpu_to_reu
; Result:
;   Data copied from CPU memory to REU memory
; Destroyed:
;   R0, R1, R2L, R3, A, X, Y
.proc reu_copy_from_cpu_to_reu : near
    
    ; Address in REU memory
    lda R1
    sta REU_FAR_ADDR_LO
    lda R1 + 1
    sta REU_FAR_ADDR_MED
    lda R1 + 2              ; R2L
    sta REU_FAR_ADDR_HI

    ; Address in CPU memory
    lda R0
    sta REU_NEAR_ADDR_LO
    lda R0 + 1
    sta REU_NEAR_ADDR_HI

    ; Length of block to transfer
    lda R3
    sta REU_BLOCK_LEN_LO
    lda R3 + 1
    sta REU_BLOCK_LEN_HI

    ; Start the transfer: command $80 = CPU to REU
    lda #%10010000
    sta REU_CMD
    
    rts
.endproc

; Copy data from REU memory to CPU memory
; usage:
;   R0      = destination address in CPU memory (16-bit)
;   R1:R2L  = source address in REU memory (24-bit)
;   R3      = length in bytes (16-bit)
;   jsr reu_copy_from_reu_to_cpu
; Result:
;   Data copied from REU memory to CPU memory
; Destroyed:
;   R0, R1, R2L, R3, A, X, Y
.proc reu_copy_from_reu_to_cpu : near

    ; Address in REU memory
    lda R1
    sta REU_FAR_ADDR_LO
    lda R1 + 1
    sta REU_FAR_ADDR_MED
    lda R1 + 2         ; R2L
    sta REU_FAR_ADDR_HI

    ; Address in CPU memory
    lda R0
    sta REU_NEAR_ADDR_LO
    lda R0 + 1
    sta REU_NEAR_ADDR_HI

    ; Length of block to transfer
    lda R3
    sta REU_BLOCK_LEN_LO
    lda R3 + 1
    sta REU_BLOCK_LEN_HI

    ; Start the transfer: command $81 = REU to CPU
    lda #%10010001
    sta REU_CMD    

    rts
.endproc

.endscope