!cpu 6510
!to "rasterbars.prg",cbm

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
    lda $d011
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
    lda #$93           ;; irq at line 149
    sta $d012
    lda $d011
    and #$7f
    sta $d011
    cli
    jmp *

irq
    inc $d019
    ldx #$00
    lda #$96            ;; rasterbar at line 150
    sta RASTERLINE
draw_raster
    lda RASTERLINE      ;; wait for it..
    cmp $d012
    bne *-3
    lda colors,x        ;; pick a color
    sta $d020           ;; .. and paint a line
    inc RASTERLINE      ;; increment line & color counters
    inx
    cpx #$1d            ;; check if all colors painted
    nop
    nop                 ;; waste some cycles to stabilize
    nop
    bne draw_raster
exit
    lda #$00
    sta $d020
    lda #$96
    sta RASTERLINE
    jmp $ea81

colors
!byte DBLUE, BLACK, LBLUE, DBLUE, LBLUE, LBLUE, CYAN, LBLUE, CYAN, CYAN, WHITE, CYAN, WHITE, WHITE
!byte WHITE, WHITE, CYAN, WHITE, CYAN, CYAN, LBLUE, CYAN, LBLUE, LBLUE, DBLUE, LBLUE, BLACK, DBLUE
