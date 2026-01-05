.if !.xmatch(current_file, "print.s")
    .import gotoxy: near
    .import print: near   
    .import convert_16bit_to_decimal: near     
    .import convert_16bitptr_to_decimal: near
.endif

.macro getkey
:   jsr KERNAL_GETIN         ; C64 KERNAL GETIN routine
    beq :-
.endmacro

.macro printat col_pos, row_pos, str_addr
    ldx row_pos
    ldy col_pos
    jsr gotoxy
    ldx #<str_addr
    ldy #>str_addr
    jsr print
.endmacro

.macro print_decimal_at_16 col_pos, row_pos, value_ptr, value_ofs
    ldx row_pos
    ldy col_pos
    jsr gotoxy
    ldy #value_ofs
    lda (value_ptr),y
    sta TMP1
    iny
    lda (value_ptr),y
    sta TMP1+1    
    jsr convert_16bit_to_decimal
.endmacro

.macro print_decimal_at_8 col_pos, row_pos, value_ptr, value_ofs
    ldx row_pos
    ldy col_pos
    jsr gotoxy
    ldy #value_ofs
    lda (value_ptr),y
    sta TMP1
    lda #$00    
    sta TMP1+1    
    jsr convert_16bit_to_decimal
.endmacro

.macro scnclr
    lda #PETSCII_CLR_SCREEN   ; Clear screen code
    jsr KERNAL_CHROUT         ; C64 KERNAL CHROUT routine   
.endmacro
