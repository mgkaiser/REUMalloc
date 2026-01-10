.if !.xmatch(current_file, "malloc.s")
    .import malloc_init: near
    .import malloc: near
    .import free: near    
    .import garbage_collect: near
    .import walk_blocks: near
.endif

MALLOC_HEAD = $000001   ; REU memory start address for malloc management

; Structure for REU memory block management
.struct reu_block
    size        .res 3          ; Size of the block in bytes (24-bit)    
    is_free     .byte           ; 1 if free, 0 if used
    next        .res 3          ; Pointer to the next block (24-bit)    
    padding     .byte           ; Padding to align to 8 bytes
.endstruct

.macro put_reu_block_imm ptr, reu_addr    
    lda ptr
    sta R0              ; Low byte of CPU memory address
    lda ptr + 1
    sta R0 + 1          ; High byte of CPU memory address    
    
    lda #<reu_addr
    sta R1              ; Low byte of REU memory address
    lda #>reu_addr
    sta R1 + 1          ; Mid byte of REU memory address
    lda #^reu_addr
    sta R1 + 2          ; High byte of REU memory address    
    
    lda #<(.sizeof(reu_block))        
    sta R3              ; Low byte of length
    lda #>(.sizeof(reu_block))        
    sta R3 + 1          ; High byte of length (1024 bytes)
    
    jsr reu_copy_from_cpu_to_reu
.endmacro

.macro put_reu_block_abs ptr, reu_addr    
    lda ptr
    sta R0              ; Low byte of CPU memory address
    lda ptr + 1
    sta R0 + 1          ; High byte of CPU memory address    
    
    lda reu_addr
    sta R1              ; Low byte of REU memory address
    lda reu_addr + 1
    sta R1 + 1          ; Mid byte of REU memory address
    lda reu_addr + 2    
    sta R1 + 2          ; High byte of REU memory address    
    
    lda #<(.sizeof(reu_block))        
    sta R3              ; Low byte of length
    lda #>(.sizeof(reu_block))        
    sta R3 + 1          ; High byte of length (1024 bytes)
    
    jsr reu_copy_from_cpu_to_reu
.endmacro

.macro get_reu_block_imm ptr, reu_addr    
    lda ptr
    sta R0              ; Low byte of CPU memory address
    lda ptr + 1
    sta R0 + 1          ; High byte of CPU memory address    

    lda #<reu_addr
    sta R1              ; Low byte of REU memory address
    lda #>reu_addr
    sta R1 + 1          ; Mid byte of REU memory address
    lda #^reu_addr
    sta R1 + 2          ; High byte of REU memory address    
    
    lda #<(.sizeof(reu_block))        
    sta R3              ; Low byte of length
    lda #>(.sizeof(reu_block))        
    sta R3 + 1          ; High byte of length (1024 bytes)
    
    jsr reu_copy_from_reu_to_cpu
.endmacro

.macro get_reu_block_abs ptr, reu_addr    
    lda ptr
    sta R0              ; Low byte of CPU memory address
    lda ptr + 1
    sta R0 + 1          ; High byte of CPU memory address    

    lda reu_addr
    sta R1              ; Low byte of REU memory address
    lda reu_addr + 1
    sta R1 + 1          ; Mid byte of REU memory address
    lda reu_addr + 2
    sta R1 + 2          ; High byte of REU memory address    

    lda #<(.sizeof(reu_block))        
    sta R3              ; Low byte of length
    lda #>(.sizeof(reu_block))        
    sta R3 + 1          ; High byte of length (1024 bytes)

    jsr reu_copy_from_reu_to_cpu
.endmacro

