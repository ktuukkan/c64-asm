!cpu 6502
!to "colorwash.prg",cbm

* = $0801
    !byte $0d,$08,$dc,$07,$9e,$20,$34
    !byte $39,$31,$35,$32,$00,$00,$00

;; http://kofler.dot.at/c64/font_06.html
* = $3800
    !bin "../1x2-charset/devils_collection_25_y.64c",,$02

* = $c000
    jsr clear_screen
    jsr write_text
    jsr irq_setup
    jmp *

irq_setup
    sei
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
    rts

irq
    dec $d019
    jsr colorwash
    jmp $ea81

clear_screen
    ldx #$00
    stx $d020
    stx $d021
clear_loop
    lda #$20
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $06e8,x
    lda #$01
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $dae8,x
    inx
    bne clear_loop
    rts

write_text
    lda $d018
    ora #$0e
    sta $d018
    ldx #$00
write_loop
    lda text,x
    sta $0400+440,x
    ora #$40
    sta $0400+480,x
    lda #$01
    sta $d800+440,x
    sta $d800+480,x
    inx
    cpx #$28
    bne write_loop
    rts

colorwash
    ldx #$00
    lda colors
color_loop
    ldy colors,x
    sta colors,x
    sta $d800+440,x
    sta $d800+480,x
    tya
    inx
    cpx #$27
    bne color_loop
    sta colors
    sta $d800+440
    sta $d800+480
    rts

text
    !scr "       lorem ipsum dolor sit amet       "

colors
    !byte $01,$01,$01,$01,$07,$07,$07,$07
    !byte $0d,$0d,$0d,$0d,$03,$03,$03,$03
    !byte $0e,$0e,$0e,$0e,$06,$06,$06,$06
    !byte $0e,$0e,$0e,$0e,$03,$03,$03,$03
    !byte $0d,$0d,$0d,$0d,$07,$07,$07,$07
