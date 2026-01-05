
; Safe Zero Page locations for general use (https://www.c64-wiki.com/wiki/Zeropage)
; All are reserved as words (2 bytes each)
TMP1 = $f7
TMP2 = $f9
TMP3 = $a8
TMP4 = $aa
TMP5 = $b0

PTR1 = $fb
PTR2 = $fd
PTR3 = $9b
PTR4 = $9E
PTR5 = $b2

; X-16 Compatible Pseudo-registers
R0 = $02
R1 = $04
R2 = $06
R3 = $08
R4 = $0A
R5 = $0C
R6 = $0E
R7 = $10
R8 = $12
R9 = $14
R10= $16
R11= $18
R12= $1A
R13= $1C
R14= $1E
R15= $20

; X-16 Compatible Pseudo-registers as L/H
R0L = R0
R0H = R0 + 1
R1L = R1
R1H = R1 + 1
R2L = R2
R2H = R2 + 1
R3L = R3
R3H = R3 + 1
R4L = R4
R4H = R4 + 1
R5L = R5
R5H = R5 + 1
R6L = R6
R6H = R6 + 1
R7L = R7
R7H = R7 + 1
R8L = R8
R8H = R8 + 1
R9L = R9
R9H = R9 + 1
R10L= R10
R10H= R10 + 1
R11L= R11
R11H= R11 + 1
R12L= R12
R12H= R12 + 1
R13L= R13
R13H= R13 + 1
R14L= R14
R14H= R14 + 1
R15L= R15
R15H= R15 + 1

; Constant for KERNAL API
KERNAL_CHROUT   = $FFD2
KERNAL_GETIN    = $FFE4
KERNAL_SETLFS   = $FFBA
KERNAL_SETNAM   = $FFBD
KERNAL_OPEN     = $FFC0
KERNAL_CLOSE    = $FFC3
KERNAL_CLRCHN   = $FFCC
KERNAL_SAVE     = $FFD8
KERNAL_LOAD     = $FFD5

; Constants for VIC-II registers (https://codebase64.net/doku.php?id=vic)
VIC_BASE         = $d000
VIC_CTRL1        = VIC_BASE + $11
VIC_CTRL2        = VIC_BASE + $16
VIC_BORDER_COL   = VIC_BASE + $20
VIC_BG_COL       = VIC_BASE + $21
VIC_SPRITE_EN    = VIC_BASE + $15
VIC_SPRITE_PTR   = VIC_BASE + $3f
VIC_SPRITE_X     = VIC_BASE + $00
VIC_SPRITE_Y     = VIC_BASE + $01
VIC_SPRITE_COL1  = VIC_BASE + $25
VIC_SPRITE_COL2  = VIC_BASE + $26
VIC_SPRITE_COL3  = VIC_BASE + $27
VIC_SPRITE_COL4  = VIC_BASE + $28
VIC_SPRITE_COL5  = VIC_BASE + $29
VIC_SPRITE_COL6  = VIC_BASE + $2a
VIC_SPRITE_COL7  = VIC_BASE + $2b
VIC_SPRITE_COL8  = VIC_BASE + $2c

; Constants for SID registers (https://codebase64.net/doku.php?id=base:sid_programming)
SID1_BASE                = $d400
SID_REG_VOICE1_FREQ_LO   = SID1_BASE + $00
SID_REG_VOICE1_FREQ_HI   = SID1_BASE + $01
SID_REG_VOICE1_PULSE_LO  = SID1_BASE + $02
SID_REG_VOICE1_PULSE_HI  = SID1_BASE + $03
SID_REG_VOICE1_CTRL      = SID1_BASE + $04
SID_REG_VOICE1_ATK_DEC   = SID1_BASE + $05
SID_REG_VOICE1_SUS_REL   = SID1_BASE + $06
SID_REG_VOICE2_FREQ_LO   = SID1_BASE + $07
SID_REG_VOICE2_FREQ_HI   = SID1_BASE + $08
SID_REG_VOICE2_PULSE_LO  = SID1_BASE + $09
SID_REG_VOICE2_PULSE_HI  = SID1_BASE + $0a
SID_REG_VOICE2_CTRL      = SID1_BASE + $0b
SID_REG_VOICE2_ATK_DEC   = SID1_BASE + $0c
SID_REG_VOICE2_SUS_REL   = SID1_BASE + $0d
SID_REG_VOICE3_FREQ_LO   = SID1_BASE + $0e
SID_REG_VOICE3_FREQ_HI   = SID1_BASE + $0f
SID_REG_VOICE3_PULSE_LO  = SID1_BASE + $10
SID_REG_VOICE3_PULSE_HI  = SID1_BASE + $11
SID_REG_VOICE3_CTRL      = SID1_BASE + $12
SID_REG_VOICE3_ATK_DEC   = SID1_BASE + $13
SID_REG_VOICE3_SUS_REL   = SID1_BASE + $14
SID_REG_FILTER_CUTOFF_LO = SID1_BASE + $15
SID_REG_FILTER_CUTOFF_HI = SID1_BASE + $16
SID_REG_FILTER_RES_FBG   = SID1_BASE + $17
SID_REG_MODE_VOL         = SID1_BASE + $18
SID_REG_PADDLE_X         = SID1_BASE + $19
SID_REG_PADDLE_Y         = SID1_BASE + $1a
SID_REG_OSC3             = SID1_BASE + $1b
SID_REG_ENV3             = SID1_BASE + $1c

; Constants for REU registers (https://codebase64.net/doku.php?id=base:reu_registers)
REU_BASE            = $DF00
REU_STATUS          = REU_BASE + $00
REU_CMD             = REU_BASE + $01    ; $80 - Start REU command, $01 - REU -> CPU, $00 CPU -> REU
REU_NEAR_ADDR_LO    = REU_BASE + $02
REU_NEAR_ADDR_HI    = REU_BASE + $03
REU_FAR_ADDR_LO     = REU_BASE + $04
REU_FAR_ADDR_MED    = REU_BASE + $05
REU_FAR_ADDR_HI     = REU_BASE + $06
REU_BLOCK_LEN_LO    = REU_BASE + $07
REU_BLOCK_LEN_HI    = REU_BASE + $08
REU_INTERRUPT_MASK  = REU_BASE + $09    ; $80 - Enable interrupts, $40 - End of Block interrupt, $20 - Interrupt on Verify Error
REU_ADDR_CTRL       = REU_BASE + $0A    ; $80 - Don't increment near addr, $40 - Don't increment far addr

; REU Command Codes
REU_CMD_COPY_NEAR_TO_FAR = $80
REU_CMD_COPY_FAR_TO_NEAR = $81

; PETSCII Control Codes (From https://www.c64-wiki.com/wiki/PETSCII)
PETSCII_CLR_SCREEN  = $93
PETSCII_REVERSE_ON  = $12
PETSCII_REVERSE_OFF = $92
PETSCII_CURSOR_UP   = $91
PETSCII_CURSOR_DOWN = $11
PETSCII_CURSOR_LEFT = $9d
PETSCII_CURSOR_RIGHT= $1d  
PETSCII_F1          = $85
PETSCII_F3          = $86
PETSCII_F5          = $87
PETSCII_F7          = $88
PETSCII_F2          = $89
PETSCII_F4          = $8a
PETSCII_F6          = $8b
PETSCII_F8          = $8c

; PETSCII Control Codes for Colors
PETSCII_COL_BLACK       = $90
PETSCII_COL_WHITE       = $05
PETSCII_COL_RED         = $1C
PETSCII_COL_CYAN        = $9F
PETSCII_COL_PURPLE      = $9C
PETSCII_COL_GREEN       = $1E
PETSCII_COL_BLUE        = $1F
PETSCII_COL_YELLOW      = $9E
PETSCII_COL_ORANGE      = $81
PETSCII_COL_BROWN       = $95
PETSCII_COL_LIGHT_RED   = $96
PETSCII_COL_DARK_GRAY   = $97
PETSCII_COL_GRAY        = $98
PETSCII_COL_LIGHT_GREEN = $99
PETSCII_COL_LIGHT_BLUE  = $9a
PETSCII_COL_LIGHT_GRAY  = $9b

; VIC-II Color Codes
VIC_COL_BLACK       = $00
VIC_COL_WHITE       = $01
VIC_COL_RED         = $02
VIC_COL_CYAN        = $03
VIC_COL_PURPLE      = $04
VIC_COL_GREEN       = $05
VIC_COL_BLUE        = $06
VIC_COL_YELLOW      = $07
VIC_COL_ORANGE      = $08
VIC_COL_BROWN       = $09
VIC_COL_LIGHT_RED   = $0a
VIC_COL_DARK_GRAY   = $0b
VIC_COL_GRAY        = $0c
VIC_COL_LIGHT_GREEN = $0d
VIC_COL_LIGHT_BLUE  = $0e
VIC_COL_LIGHT_GRAY  = $0f

DEBUG_REG = $d7ff

.macro breakpoint
    pha
    lda #$00
    sta DEBUG_REG
:   lda DEBUG_REG
    beq :-  
    pla
.endmacro

.macro mov_abs_16 dest, src
    lda src
    sta dest
    lda src + 1
    sta dest + 1
.endmacro

.macro mov_abs_24 dest, src
    lda src
    sta dest
    lda src + 1
    sta dest + 1
    lda src + 2
    sta dest + 2
.endmacro
    
.macro sta_imm_16 value, addr
    lda #<value
    sta addr
    lda #>value
    sta addr + 1
.endmacro

.macro stxy_imm_16 addr    
    stx addr
    sty addr + 1
.endmacro

.macro ldxy_imm_16 value
    ldx #<value
    ldy #>value
.endmacro

.macro beql label
    bne :+
    jmp label
:
.endmacro

.macro bccl label
    bcs :+
    jmp label
:
.endmacro

