.scope
.define current_file "main.s"

.include "mac.inc"
.include "main.inc"
.include "print.inc"
.include "file.inc"
.include "reu.inc"
.include "malloc.inc"
.include "basicstub.inc"    ; ONLY include this in main.s.  MUST be last include

.segment "MAIN"

; Define exports for all public functions in this module

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables that do not require initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "BSS"
p_malloc_1:    .res 3     ; Pointer to first allocated block
p_malloc_2:    .res 3     ; Pointer to second allocated block
p_malloc_3:    .res 3     ; Pointer to third allocated block

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables that DO require initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "MAIN"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main Program Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                

; Main program entry point
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Main program loop executed
; Destroys:
;   All registers
.proc main: near

    ; Make the background black and the text light green
    lda #VIC_COL_BLACK              ; Color value 
    sta VIC_BORDER_COL              ; Border color
    sta VIC_BG_COL                  ; Background color
    lda #PETSCII_COL_LIGHT_GREEN    ; Text color
    jsr KERNAL_CHROUT
    
    ; Clear the screen
    scnclr    

    ; Initilialize the malloc system
    jsr malloc_init

    ; Allocate 128 bytes in REU and store pointer in p_malloc_1
    mov_imm_16 R0, $0080
    jsr malloc
    mov_abs_24 p_malloc_1, R0    

    ; Allocate 128 bytes in REU and store pointer in p_malloc_2
    mov_imm_16 R0, $0080
    jsr malloc
    mov_abs_24 p_malloc_2, R0    
    
    ; Allocate 128 bytes in REU and store pointer in p_malloc_3
    mov_imm_16 R0, $0080
    jsr malloc
    mov_abs_24 p_malloc_3, R0    

exit_program:        
    rts

.endproc

.endscope