.scope
.define current_file "file.s"

.include "mac.inc"
.include "file.inc"

.segment "MAIN"

; Define exports for all public functions in this module
.export file_save
.export file_load

; Save data to disk
; Usage:
;   a = length of filename
;   x:y = pointer to filename string
;   PTR1 = start address of data to save
;   PTR2 = end address of data to save
; Returns:
;   None
; Results:
;   Data saved to file
; Destroys:
.proc file_save : near
    
    ; Set the file name 
    jsr KERNAL_SETNAM

    ; Open the file handle
    lda #$01
    ldx #$08
    ldy #$00
    jsr KERNAL_SETLFS

    ; Save the data to the file
    lda #PTR1
    ldx PTR2
    ldy PTR2+1
    jsr KERNAL_SAVE

    ; Close the file handle 
    jsr KERNAL_CLRCHN   
    lda #$01
    jsr KERNAL_CLOSE
        
    rts
.endproc

; Load data from disk
; Usage:
;   a = length of filename
;   x:y = pointer to filename string
;   PTR1 = start address of data to save
; Returns:
;   None
; Results:
;   Data loaded from file
; Destroys:
.proc file_load : near

    ; Set the file name 
    jsr KERNAL_SETNAM

    ; Open the file handle
    lda #$01
    ldx #$08
    ldy #$00
    jsr KERNAL_SETLFS

    ; Load the data from the file
    lda #00
    ldx PTR1
    ldy PTR1+1
    jsr KERNAL_LOAD

    ; Close the file handle 
    jsr KERNAL_CLRCHN   
    lda #$01
    jsr KERNAL_CLOSE

    rts
.endproc



.endscope