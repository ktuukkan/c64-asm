!cpu 6502
!to "multiplex.prg",cbm

;; basic loader
* = $0801
    !byte $0d,$08,$dc,$07,$9e,$20,$34
    !byte $39,$31,$35,$32,$00,$00,$00

;; load a sprite (drawn with SpritePad and exported as bin)
* = $2000
    !bin "face.bin"

* = $c000
    sei
    jsr init_sprites
    ldy #$7f
    sty $dc0d
    sty $dd0d
    lda $dc0d
    lda $dd0d
    lda #$01
    sta $d01a
    lda #<irq1
    ldx #>irq1
    sta $314
    stx $315
    lda #$30
    sta $d012
    lda $d011
    and #$7f
    sta $d011
    cli
    jmp *

init_sprites
    ldx #$00
setup
    lda #$80        ;; set sprite pointers (128 * 64 = 8192 = $2000)
    sta $07f8,x

    lda #$ff-224    ;; set static x locations (sprite size 24 x 21)
    sta $d000
    lda #$ff-192
    sta $d002
    lda #$ff-160
    sta $d004
    lda #$ff-128
    sta $d006
    lda #$ff-96
    sta $d008
    lda #$ff-64
    sta $d00a
    lda #$ff-32
    sta $d00c
    lda #$ff
    sta $d00e

    lda #$07        ;; set sprite 0 main color to yellow
    sta $d027,x

    inx
    cpx #$08
    bne setup

    lda #$00        ;; set multicolor 0 to black
    sta $d025
    lda #$0f        ;; set multicolor 1 to light gray
    sta $d026
    lda #$ff        ;; enable multicolor for all sprites
    sta $d01c
    lda #$ff        ;; display all sprites
    sta $d015
    rts

update_sprite_y
    ldx $d012
    inx
    inx
    inx
    stx $d001
    stx $d003
    stx $d005
    stx $d007
    stx $d009
    stx $d00b
    stx $d00d
    stx $d00f
    rts

irq1
    inc $d019
    jsr update_sprite_y
    lda #$30+25
    sta $d012
    lda #<irq2
    ldx #>irq2
    sta $314
    stx $315
    jmp $ea81

irq2
    inc $d019
    jsr update_sprite_y
    lda #$30+50
    sta $d012
    lda #<irq3
    ldx #>irq3
    sta $314
    stx $315
    jmp $ea81

irq3
    inc $d019
    jsr update_sprite_y
    lda #$30+75
    sta $d012
    lda #<irq4
    ldx #>irq4
    sta $314
    stx $315
    jmp $ea81

irq4
    inc $d019
    jsr update_sprite_y
    lda #$30+100
    sta $d012
    lda #<irq5
    ldx #>irq5
    sta $314
    stx $315
    jmp $ea81

irq5
    inc $d019
    jsr update_sprite_y
    lda #$30+125
    sta $d012
    lda #<irq6
    ldx #>irq6
    sta $314
    stx $315
    jmp $ea81

irq6
    inc $d019
    jsr update_sprite_y
    lda #$30+150
    sta $d012
    lda #<irq7
    ldx #>irq7
    sta $314
    stx $315
    jmp $ea81

irq7
    inc $d019
    jsr update_sprite_y
    lda #$30+175
    sta $d012
    lda #<irq8
    ldx #>irq8
    sta $314
    stx $315
    jmp $ea81

irq8
    inc $d019
    jsr update_sprite_y
    lda #$30
    sta $d012
    lda #<irq1
    ldx #>irq1
    sta $314
    stx $315
    jmp $ea81
