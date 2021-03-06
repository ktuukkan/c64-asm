!cpu 6502
!to "movement.prg",cbm


;; basic loader
* = $0801
    !byte $0d,$08,$dc,$07,$9e,$20,$34
    !byte $39,$31,$35,$32,$00,$00,$00

;; load a sprite (drawn with SpritePad and exported as bin)
* = $2000
    !bin "assets/smiley.bin"

* = $c000
    position_index = 255    ;; current sinus table index
    sei
    jsr init_sprite
    ldy #$7f
    sty $dc0d
    sty $dd0d
    lda $dc0d
    lda $dd0d
    lda #$01
    sta $d01a
    lda #<irq
    ldx #>irq
    sta $314
    stx $315
    lda #$00
    sta $d012
    lda $d011
    and #$7f
    sta $d011
    cli
    jmp *

irq
    dec $d019
    inc position_index
    ;; update sprite x/y from sinus tables    
    ldx position_index
    lda sinus_x,x
    sta $d000
    lda sinus_y,x
    sta $d001
    jmp $ea81

init_sprite
    ;; set sprite 0 pointer (128 * 64 = 8192 = $2000)
    lda #$80
    sta $07f8
    ;; display sprite 0
    lda #$01
    sta $d015
    ;; enable multicolor for sprite 0
    lda #$01
    sta $d01c
    ;; set sprite 0 main color yellow
    lda #$07
    sta $d027
    ;; set multicolor 0 to black
    lda #$00
    sta $d025
    ;; set initial location
    ldx sinus_x     ;; x = first pos in sinus_x table
    ldy sinus_y     ;; y = fist pos of sinus_y table
    stx $d000       
    sty $d001       
    rts

;; sprite position sinus tables
;; created with Sinus Creator (The Gang)
sinus_x
    !byte 165,162,159,156,154,151,148,146,143,141,138,136,134,131,129,127
    !byte 125,123,122,120,118,117,116,114,113,112,112,111,110,110,109,109
    !byte 109,109,110,110,110,111,112,113,114,115,116,117,119,120,122,124
    !byte 126,128,130,132,134,137,139,141,144,146,149,152,154,157,160,162
    !byte 165,168,171,173,176,179,181,184,186,189,191,194,196,198,200,202
    !byte 204,206,208,209,211,212,214,215,216,217,218,218,219,219,220,220
    !byte 220,220,219,219,218,218,217,216,215,214,213,211,210,208,206,205
    !byte 203,201,199,196,194,192,189,187,184,182,179,177,174,171,169,166
    !byte 163,160,158,155,152,150,147,145,142,140,137,135,133,130,128,126
    !byte 124,123,121,119,118,116,115,114,113,112,111,111,110,110,109,109
    !byte 109,109,110,110,111,111,112,113,114,115,117,118,120,121,123,125
    !byte 127,129,131,133,135,138,140,143,145,148,150,153,156,158,161,164
    !byte 167,169,172,175,177,180,183,185,188,190,192,195,197,199,201,203
    !byte 205,207,209,210,212,213,214,215,216,217,218,219,219,219,220,220
    !byte 220,220,219,219,218,217,217,216,215,213,212,211,209,207,206,204
    !byte 202,200,198,195,193,191,188,186,183,181,178,175,173,170,167,165

sinus_y
    !byte 155,154,153,152,152,151,150,150,149,148,148,147,147,146,146,146
    !byte 145,145,145,145,145,145,145,145,145,145,145,145,146,146,147,147
    !byte 147,148,149,149,150,151,151,152,153,153,154,155,156,156,157,158
    !byte 158,159,160,160,161,162,162,162,163,163,164,164,164,164,164,164
    !byte 164,164,164,164,164,164,163,163,163,162,162,161,161,160,159,159
    !byte 158,157,157,156,155,155,154,153,152,152,151,150,150,149,148,148
    !byte 147,147,146,146,146,145,145,145,145,145,145,145,145,145,145,145
    !byte 145,146,146,147,147,147,148,149,149,150,151,151,152,153,153,154
    !byte 155,156,156,157,158,158,159,160,160,161,162,162,162,163,163,164
    !byte 164,164,164,164,164,164,164,164,164,164,164,163,163,163,162,162
    !byte 161,161,160,159,159,158,157,157,156,155,155,154,153,152,152,151
    !byte 150,150,149,148,148,147,147,146,146,146,145,145,145,145,145,145
    !byte 145,145,145,145,145,145,146,146,147,147,147,148,149,149,150,151
    !byte 151,152,153,153,154,155,156,156,157,158,158,159,160,160,161,162
    !byte 162,162,163,163,164,164,164,164,164,164,164,164,164,164,164,164
    !byte 163,163,163,162,162,161,161,160,159,159,158,157,157,156,155,155
