!cpu 6510
!to "rasterbars.prg",cbm

DBLUE = 6
LBLUE = 14
CYAN  = 3
BLACK = 0
WHITE = 1

* = $0801
    !byte $0C,$08,$0A,$00,$9E,$20,$34,$30,$39,$36,$00,$00,$00

* = $1000
    sei
    lda $00
    txa
    tya
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
    lda #$8f           ;; irq at line 143
    sta $d012
    lda $d011
    and #$7f
    sta $d011
    cli
    jmp *

irq
    inc $d019
    lda $d011           ;; disable screen
    and #%11101111
    sta $d011
    lda #$90            ;; wait for line 144
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
    lda $d011           ;; enable screen.. doesn't seem to work :(
    ora #%00010000
    sta $d011
    jmp $ea81
    
colors
!byte DBLUE, BLACK, LBLUE, DBLUE, LBLUE, LBLUE, CYAN, LBLUE, CYAN, CYAN, WHITE, CYAN, WHITE, WHITE
!byte WHITE, WHITE, CYAN, WHITE, CYAN, CYAN, LBLUE, CYAN, LBLUE, LBLUE, DBLUE, LBLUE, BLACK, DBLUE, BLACK

timing
!byte 9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
