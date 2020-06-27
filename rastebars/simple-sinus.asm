!cpu 6510
!to "swinging.prg",cbm

DBLUE = 6
LBLUE = 14
CYAN  = 3
BLACK = 0
WHITE = 1
RASTERLINE = $fe

* = $0801
    !byte $0C,$08,$0A,$00,$9E,$20,$34,$30,$39,$36,$00,$00,$00

* = $1000
    sei
    lda $00
    txa
    tya
    sta $d020
    sta $d021
    lda location
    sta RASTERLINE
    lda $d011           ;; disable screen
    and #%11101111
    sta $d011
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
    lda #$00            ;; irq at line 0
    sta $d012
    lda $d011
    and #$7f
    sta $d011
    cli
    jmp *

irq
    inc $d019
    ldx RASTERLINE
    lda location,x      ;; rasterbar at variable location
    cmp $d012
    bne *-3
    ldx #$00
draw_raster
    lda colors,x        ;; pick a color
    ldy timing,x        ;; pick timing value
    dey
    bne *-1             ;; wait for it..
    sta $d020           ;; ..and paint the line
    inx
    cpx #$1d            ;; check if all lines painted
    bne draw_raster
    inc RASTERLINE
    jmp $ea81
    
colors
!byte DBLUE, BLACK, LBLUE, DBLUE, LBLUE, LBLUE, CYAN, LBLUE, CYAN, CYAN, WHITE, CYAN, WHITE, WHITE
!byte WHITE, WHITE, CYAN, WHITE, CYAN, CYAN, LBLUE, CYAN, LBLUE, LBLUE, DBLUE, LBLUE, BLACK, DBLUE, BLACK

timing
!byte 9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9

location
!byte 70,70,70,70,71,71,72,73,74,76,77,79,81,82,84,86
!byte 89,91,93,96,99,101,104,107,110,113,116,119,122,125,129,132
!byte 135,138,141,144,148,151,154,157,160,163,166,168,171,174,176,179
!byte 181,183,185,187,189,191,192,194,195,196,197,198,198,199,199,199
!byte 199,199,199,199,198,197,196,195,194,193,191,190,188,186,184,182
!byte 180,177,175,172,170,167,164,161,158,155,152,149,146,143,140,137
!byte 133,130,127,124,121,117,114,111,108,106,103,100,97,95,92,90
!byte 88,85,83,81,80,78,76,75,74,73,72,71,70,70,70,70
!byte 70,70,70,70,71,72,73,74,75,76,78,80,81,83,85,88
!byte 90,92,95,97,100,103,106,108,111,114,117,121,124,127,130,133
!byte 137,140,143,146,149,152,155,158,161,164,167,170,172,175,177,180
!byte 182,184,186,188,190,191,193,194,195,196,197,198,199,199,199,199
!byte 199,199,199,198,198,197,196,195,194,192,191,189,187,185,183,181
!byte 179,176,174,171,168,166,163,160,157,154,151,148,144,141,138,135
!byte 132,129,125,122,119,116,113,110,107,104,101,99,96,93,91,89
!byte 86,84,82,81,79,77,76,74,73,72,71,71,70,70,70,70
