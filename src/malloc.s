.scope
.define current_file "malloc.s"

.include "mac.inc"
.include "reu.inc"
.include "malloc.inc"

; Define exports for all public functions in this module
.export malloc_init
.export malloc  
.export free
.export garbage_collect
.export walk_blocks

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables that do not require initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "BSS"

; Reserve space for the REU block management structure
block_buffer_1:  .res .sizeof(reu_block)        ; First buffer in near memory to hold REU block management structure
block_buffer_2:  .res .sizeof(reu_block)        ; Second buffer in near memory to hold REU block management structure
l_size:          .res 2                         ; Local variable to hold size during malloc
p_current:       .res 3                         ; Pointer to current block during malloc     
p_new:           .res 3                         ; Pointer to new block during malloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables that DO require initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.segment "MAIN"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main Program Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                

; Initialize the malloc system
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Malloc system initialized
; Destroys:
;   All registers, PTR1, PTR2    
.proc malloc_init : near

    ; PTR1 = &block_buffer_1
    lda #<block_buffer_1
    sta PTR1
    lda #>block_buffer_1
    sta PTR1+1    
    
    ; PTR1->size = $1000000 - .sizeof(reu_block)
    ldy #reu_block::size
    lda #<($1000000 - .sizeof(reu_block))
    sta (PTR1),y
    iny
    lda #>($1000000 - .sizeof(reu_block)) 
    sta (PTR1),y
    iny
    lda #^($1000000 - .sizeof(reu_block)) 
    sta (PTR1),y

    ; PTR1->is_free = 1
    ldy #reu_block::is_free
    lda #$01
    sta (PTR1),y

    ; PTR1->next = 0    
    ldy #reu_block::next
    lda #$00
    sta (PTR1),y
    iny
    sta (PTR1),y
    iny
    sta (PTR1),y

    ; Store the block management structure in the REU
    put_reu_block_imm PTR1, MALLOC_HEAD    
    
    rts

.endproc


; Allocate memory from the REU
; Usage:
;   R0 = Size (up to 64K)
; Returns:
;   R0:R1L = Pointer to allocated memory in REU (24-bit address)
; Results:
;   Memory block of requested size allocated in REU
; Destroys:
;   All registers, PTR1, PTR2, PTR3
.proc malloc : near

    ; PTR1 = &block_buffer_1
    mov_imm_16 PTR1, block_buffer_1    
    
    ; PTR2 = &block_buffer_2
    mov_imm_16 PTR2, block_buffer_2
    
    ; l_size = R0 (requested size)
    mov_abs_16 l_size, R0    

    ; Set p_current = MALLOC_HEAD
    mov_imm_24 p_current, MALLOC_HEAD        
    
check_block_loop:

        ; Get the first block pointer    
        get_reu_block_abs PTR1, p_current           
        
        ; Check if block is free
        ldy #reu_block::is_free
        lda (PTR1),y
        beql check_next_block   ; If not free, check next block

        ; Check if block size >= l_size (16-bit compare)
        ldy #reu_block::size + 1
        lda (PTR1),y
        cmp l_size + 1
        bccl check_next_block   ; If block size < l_size, check next block
        bne :+
        dey
        lda (PTR1),y
        cmp l_size
        bccl check_next_block   ; If block size < l_size, check next block    
    :
        
        ; Found a suitable block  
        ; Is the block size > l_size + .sizeof(reu_block) ?
        ldy #reu_block::size + 1
        lda (PTR1),y    
        cmp l_size + 1
        bccl malloc_done      ; If not, allocate entire block
        bne :+
        dey
        lda (PTR1),y    
        cmp l_size
        bccl malloc_done      ; If not, allocate entire block    
    :    
        
            ; Split the block
            ;p_new = p_current + .sizeof(reu_block) + l_size
            clc
            lda p_current
            adc #<(.sizeof(reu_block))
            adc l_size
            sta p_new
            lda p_current + 1
            adc #>.sizeof(reu_block)
            adc l_size + 1
            sta p_new + 1
            lda p_current + 2
            adc #^.sizeof(reu_block)
            sta p_new + 2
            
            ; Set p_new->size = original_size - l_size - .sizeof(reu_block)
            sec
            ldy #reu_block::size    
            lda (PTR1),y        
            sbc l_size    
            sbc #<(.sizeof(reu_block))
            sta (PTR2),y    
            iny    
            lda (PTR1),y    
            sbc l_size + 1
            sbc #>.sizeof(reu_block)
            sta (PTR2),y    
            iny
            lda (PTR1),y    
            sbc #^.sizeof(reu_block)
            sta (PTR2),y

            ; p_new->is_free = 1
            ldy #reu_block::is_free
            lda #$01
            sta (PTR2),y

            ; p_new->next = p_current->next
            ldy #reu_block::next
            lda (PTR1),y
            sta (PTR2),y
            iny
            lda (PTR1),y
            sta (PTR2),y
            iny
            lda (PTR1),y
            sta (PTR2),y    

            ; Store p_new back to REU
            put_reu_block_abs PTR2, p_new

            ; Update p_current->size = l_size
            ldy #reu_block::size
            lda l_size
            sta (PTR1),y
            iny
            lda l_size + 1
            sta (PTR1),y
            iny
            lda #$00
            sta (PTR1),y
            
            ; p_current->next = p_new
            ldy #reu_block::next
            lda p_new
            sta (PTR1),y
            iny
            lda p_new + 1
            sta (PTR1),y
            iny
            lda p_new + 2
            sta (PTR1),y
            
        jmp malloc_done

    check_next_block:

        ; p_current = PTR1->next
        ldy #reu_block::next
        lda (PTR1),y
        sta p_current
        iny
        lda (PTR1),y
        sta p_current + 1
        iny
        lda (PTR1),y
        sta p_current + 2

        ; Check if p_current == 0
        lda p_current
        ora p_current + 1
        ora p_current + 2
        beq malloc_done       ; If zero, no more blocks to check

    ; Loop back to check the next block
    jmp check_block_loop

malloc_done:

    ; if p_current == 0, return NULL
    lda p_current
    ora p_current + 1
    ora p_current + 2
    beq malloc_return_null

    ; p_current->is_free = 0
    ldy #reu_block::is_free
    lda #$00
    sta (PTR1),y

    ; Store p_current back to REU
    put_reu_block_abs PTR1, p_current    
    
    ; R0 = p_current + .sizeof(reu_block)
    clc
    lda p_current    
    adc #<.sizeof(reu_block)    ; Adjust for block header
    sta R0
    lda p_current + 1
    adc #>.sizeof(reu_block)
    sta R0 + 1
    lda p_current + 2
    adc #^.sizeof(reu_block)    
    sta R0 + 2    
    
    rts

malloc_return_null:    
    ; Return NULL (0)
    lda #$00
    sta R0
    sta R0 + 1
    sta R0 + 2

    rts
    
.endproc

; Free allocated memory in the REU
; Usage:
;   R0:R1L = Pointer to allocated memory in REU (24-bit address)
; Returns:
;   Nothing
; Results:
;   Memory block freed
; Destroys:
;   All registers, PTR1
.proc free : near

    ; PTR1 = &block_buffer_1
    lda #<block_buffer_1
    sta PTR1
    lda #>block_buffer_1
    sta PTR1+1        

    ; p_current = R0:R1L - .sizeof(reu_block)
    sec
    lda R0
    sbc #<.sizeof(reu_block)
    sta p_current
    lda R0 + 1
    sbc #>.sizeof(reu_block)
    sta p_current + 1
    lda R0 + 2
    sbc #^.sizeof(reu_block)
    sta p_current + 2    

    ; Get the block from REU
    get_reu_block_abs PTR1, p_current    

    ; Set is_free = 1
    ldy #reu_block::is_free
    lda #$01
    sta (PTR1),y
    
    ; Store the block back to REU
    put_reu_block_abs PTR1, p_current

    rts
.endproc

; Perform garbage collection on REU memory
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Free memory blocks coalesced
; Destroys:
;   All registers, PTR1, PTR2
.proc garbage_collect : near
    ; PTR1 = &block_buffer_1
    mov_imm_16 PTR1, block_buffer_1    
    
    ; PTR2 = &block_buffer_2
    mov_imm_16 PTR2, block_buffer_2    

    ; p_current = MALLOC_HEAD
    mov_imm_24 p_current, MALLOC_HEAD    

garbage_collect_outer_loop:

        ; Get current block
        get_reu_block_abs PTR1, p_current
        
        ; Get next block
        ldy #reu_block::next
        lda (PTR1),y
        sta p_new
        iny
        lda (PTR1),y
        sta p_new + 1
        iny
        lda (PTR1),y
        sta p_new + 2

        ; If next block is NULL, done
        lda p_new
        ora p_new + 1
        ora p_new + 2
        beql garbage_collect_done

        ; Get next block into PTR2
        get_reu_block_abs PTR2, p_new
        
        ; Check if both current and next blocks are free
        ldy #reu_block::is_free        
        lda (PTR1),y
        beql garbage_collect_next   ; Current block not free
        lda (PTR2),y
        beql garbage_collect_next   ; Next block not free

        breakpoint VIC_COL_LIGHT_RED

        ; Coalesce blocks
        ; PTR1->size += .sizeof(reu_block) + PTR2->size
        clc
        ldy #reu_block::size
        lda (PTR1),y    
        adc #<.sizeof(reu_block)
        adc (PTR2),y
        sta (PTR1),y
        iny
        lda (PTR1),y
        adc #>.sizeof(reu_block)
        adc (PTR2),y
        sta (PTR1),y
        iny
        lda (PTR1),y
        adc #^.sizeof(reu_block)
        adc (PTR2),y
        sta (PTR1),y

        ; PTR1->next = PTR2->next
        ldy #reu_block::next
        lda (PTR2),y
        sta (PTR1),y
        iny
        lda (PTR2),y
        sta (PTR1),y
        iny
        lda (PTR2),y
        sta (PTR1),y

        breakpoint VIC_COL_WHITE

        ; Store updated PTR1 back to REU
        put_reu_block_abs PTR1, p_current

    ; Loop back to check again from current block
    jmp garbage_collect_outer_loop

garbage_collect_next:

    breakpoint VIC_COL_GREEN
    
    ; Move to next block
    mov_abs_24 p_current, p_new    
    jmp garbage_collect_outer_loop    
    
garbage_collect_done:

    rts
.endproc

.proc walk_blocks : near

    ; PTR1 = &block_buffer_1
    mov_imm_16 PTR1, block_buffer_1    
    
    ; p_current = MALLOC_HEAD
    mov_imm_24 p_current, MALLOC_HEAD   

walk_blocks_loop:

        ; Get current block
        get_reu_block_abs PTR1, p_current

        breakpoint VIC_COL_BLUE

        ; Get next block
        ldy #reu_block::next
        lda (PTR1),y
        sta p_current
        iny
        lda (PTR1),y
        sta p_current + 1
        iny
        lda (PTR1),y
        sta p_current + 2

        ; If next block is NULL, done
        lda p_current
        ora p_current + 1
        ora p_current + 2
        beql walk_blocks_done       
    ; Loop back to check the next block
    jmp walk_blocks_loop
walk_blocks_done:
    
    rts
.endproc
    
.endscope