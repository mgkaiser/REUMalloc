.if !.xmatch(current_file, "main.s")
    .import display_template: near    
.endif

; Jump to a target if the accumulator matches a character
; Usage:
;   char:   Character to compare against
;   target: Target label to jump to if match
; Returns:
;   Nothing
; Results:
;   JMP to target if match
; Destroys:
;   Nothing
.macro goto_if_char char, target 
    cmp #char
    beq target
.endmacro

; Call a subroutine if the accumulator matches a character
; Usage:
;   char:   Character to compare against
;   target: Target subroutine to call if match
; Returns:
;   Nothing
; Results:
;   JSR to target if match
.macro gosub_if_char char, target, endlabel 
    cmp #char
    bne :+
    jsr target
    jmp endlabel
:    
.endmacro

.macro gosub_if_char_between lowchar, highchar, target, endlabel
    cmp #lowchar
    bcc :+
    cmp #highchar + 1
    bcs :+
    jsr target
    jmp endlabel
:
.endmacro   

; Add a constant to a 16-bit value in a structure
; Usage:
;   ptr:   Pointer to structure
;   ofs:   Offset within structure
;   value: Constant to add
;   mask:  Mask to apply after addition
; Results:
;   16-bit value at structure offset incremented by constant and masked
; Destroys:
;   A, Y
.macro add_const_to_struct_16 ptr, ofs, value, mask
    clc
    ldy #ofs
    lda (ptr), y
    adc #.lobyte(value)
    and #.lobyte(mask)
    sta (ptr), y
    ldy #ofs+1
    lda (ptr), y
    adc #.hibyte(value)    
    and #.hibyte(mask)
    sta (ptr), y
.endmacro

; Add a constant to an 8-bit value in a structure
; Usage:
;   ptr:   Pointer to structure
;   ofs:   Offset within structure
;   value: Constant to add
;   mask:  Mask to apply after addition
; Results:
;   8-bit value at structure offset incremented by constant and masked
; Destroys:
;   A, Y
.macro add_const_to_struct_8 ptr, ofs, value, mask
    clc
    ldy #ofs
    lda (ptr), y
    adc #.lobyte(value)
    and #.lobyte(mask)
    sta (ptr), y    
.endmacro

; Subtract a constant from a 16-bit value in a structure
; Usage:
;   ptr:   Pointer to structure
;   ofs:   Offset within structure
;   value: Constant to subtract
;   mask:  Mask to apply after subtraction
; Results:
;   16-bit value at structure offset decremented by constant and masked
; Destroys:
;   A, Y
.macro sub_const_from_struct_16 ptr, ofs, value, mask
    sec
    ldy #ofs
    lda (ptr), y
    sbc #.lobyte(value)
    and #.lobyte(mask)
    sta (ptr), y
    ldy #ofs+1
    lda (ptr), y
    sbc #.hibyte(value)    
    and #.hibyte(mask)
    sta (ptr), y
.endmacro

; Subtract a constant from an 8-bit value in a structure
; Usage:
;   ptr:   Pointer to structure
;   ofs:   Offset within structure
;   value: Constant to subtract
;   mask:  Mask to apply after subtraction
; Results:
;   8-bit value at structure offset decremented by constant and masked
; Destroys:
;   A, Y
.macro sub_const_from_struct_8 ptr, ofs, value, mask
    sec
    ldy #ofs
    lda (ptr), y
    sbc #.lobyte(value)
    and #.lobyte(mask)
    sta (ptr), y    
.endmacro
