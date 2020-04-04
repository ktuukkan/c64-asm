!cpu 6502
!to "multiplex.prg",cbm

;; basic loader
* = $0801
    !byte $0d,$08,$dc,$07,$9e,$20,$34
    !byte $39,$31,$35,$32,$00,$00,$00

;; load a sprite (drawn with SpritePad and exported as bin)
* = $2000
    !bin "assets/smiley.bin"

* = $c000
    top_row = 50
    irq_counter = $fb
    sei
    lda #$00
    tay
    tax
    sta irq_counter
    jsr init_sprites
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
    lda interrupts
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
    lda #$07        ;; set sprite main color yellow
    sta $d027,x
    inx
    cpx #$08
    bne setup
    lda #$ff-224    ;; set x locations (sprite size 24 x 21)
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

irq
    inc $d019
    jsr update_sprite_y
    ldx irq_counter
    lda interrupts,x
    sta $d012
    lda #<irq
    ldx #>irq
    sta $314
    stx $315
    inc irq_counter
    lda irq_counter
    cmp #$08
    bne done
    lda #$00
    sta irq_counter
done
    jmp $ea81

interrupts
!byte $30, $30+25, $30+50,$30+75, $30+100, $30+125, $30+150, $30+175
