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
    sta RASTERLINE
    sta $d020
    sta $d021
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
    lda #$00           ;; irq at line 0
    sta $d012
    lda $d011
    and #$7f
    sta $d011
    cli
    jmp *

irq
    inc $d019
    lda $d011
    and #%11101111
    sta $d011
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
    lda $d011
    ora #%00010000
    sta $d011
    lda #$00
    sta $d020
    sta $d021
    inc RASTERLINE
    jmp $ea81
    
colors
!byte DBLUE, BLACK, LBLUE, DBLUE, LBLUE, LBLUE, CYAN, LBLUE, CYAN, CYAN, WHITE, CYAN, WHITE, WHITE
!byte WHITE, WHITE, CYAN, WHITE, CYAN, CYAN, LBLUE, CYAN, LBLUE, LBLUE, DBLUE, LBLUE, BLACK, DBLUE, BLACK

timing
!byte 9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9

location
!byte 80,77,75,72,70,67,65,63,60,58,56,54,52,50,48,46
!byte 44,42,41,39,38,37,35,34,33,32,32,31,30,30,30,30
!byte 30,30,30,30,31,31,32,33,33,34,36,37,38,40,41,43
!byte 44,46,48,50,52,54,56,59,61,63,66,68,70,73,75,78
!byte 80,83,85,87,90,92,95,97,99,102,104,106,108,110,112,114
!byte 115,117,119,120,122,123,124,125,126,127,128,128,129,129,129,129
!byte 129,129,129,129,128,128,127,126,125,124,123,122,120,119,117,116
!byte 114,112,110,108,106,104,102,100,98,95,93,90,88,86,83,81
!byte 78,76,73,71,69,66,64,61,59,57,55,53,51,49,47,45
!byte 43,42,40,39,37,36,35,34,33,32,31,31,30,30,30,30
!byte 30,30,30,30,31,31,32,33,34,35,36,37,39,40,42,44
!byte 45,47,49,51,53,55,57,60,62,64,67,69,72,74,76,79
!byte 81,84,86,89,91,93,96,98,100,103,105,107,109,111,113,115
!byte 116,118,119,121,122,123,125,126,126,127,128,128,129,129,129,129
!byte 129,129,129,129,128,127,127,126,125,124,122,121,120,118,117,115
!byte 113,111,109,107,105,103,101,99,96,94,92,89,87,84,82,80
