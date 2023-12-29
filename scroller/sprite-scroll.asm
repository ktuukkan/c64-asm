!cpu 6502
!to "sprite-scroll.prg",cbm

spr_width   = 24
spr_x       = 80
spr_y       = 140

spr_loc     = $2000
spr_idx     = spr_loc / $40

chr_loc     = $3800
chr_mask    = chr_loc / $0800 * $02

chr_ptr     = $fb       ; zp pointer for charset data
text_ptr    = $fd       ; zp pointer for scroll text

* = $0801
    !byte $0d,$08,$dc,$07,$9e,$20,$34
    !byte $39,$31,$35,$32,$00,$00,$00

* = spr_loc
    !fill 8*8*8, $00    ; reserve/clear mem for 8 sprites

* = chr_loc
    !bin "../bitmap-txt/charset.chr"

* = $c000
    jsr init_pointers
    jsr init_sprites
    jsr init_irq
    jmp *

scroll_idx
    !byte 0

init_pointers
    ; scroll text pointer
    lda #<text
    sta text_ptr
    lda #>text
    sta text_ptr+1
    ; char data pointer
    lda #<chr_loc
    sta chr_ptr
    lda #>chr_loc
    sta chr_ptr+1
    rts

init_irq
    sei
    ldy #$7f
    sty $dc0d
    sty $dd0d
    lda $dc0d
    lda $dd0d
    lda #$01
    sta $d01a
    lda $d011
    and #$7f
    sta $d011
    lda #<irq
    ldx #>irq
    sta $314
    stx $315
    ldy #$1b
    sty $d011
    lda #$7f
    sta $dc0d
    lda #$01
    sta $d01a
    lda #200
    sta $d012
    cli
    rts

init_sprites
    ; sprite pointers, first mem location as sprite 7
    lda #spr_idx
    sta $07ff
    lda #spr_idx+1
    sta $07fe
    lda #spr_idx+2
    sta $07fd
    lda #spr_idx+3
    sta $07fc
    lda #spr_idx+4
    sta $07fb
    lda #spr_idx+5
    sta $07fa
    lda #spr_idx+6
    sta $07f9
    lda #spr_idx+7
    sta $07f8
    ; enable all
    lda #$ff
    sta $d015
    ; hires
    lda #$00
    sta $d01c
    ; main color
    lda #$01
    sta $d027
    sta $d028
    sta $d029
    sta $d02a
    sta $d02b
    sta $d02c
    sta $d02d
    sta $d02e
    ; x high bits
    lda #%00000000
    sta $d010
    ; x location
    ldx #spr_x+spr_width*7
    stx $d00e
    ldx #spr_x+spr_width*6
    stx $d00c
    ldx #spr_x+spr_width*5
    stx $d00a
    ldx #spr_x+spr_width*4
    stx $d008
    ldx #spr_x+spr_width*3
    stx $d006
    ldx #spr_x+spr_width*2
    stx $d004
    ldx #spr_x+spr_width
    stx $d002
    ldx #spr_x
    stx $d000
    ; y location
    ldy #spr_y
    sty $d001
    sty $d003
    sty $d005
    sty $d007
    sty $d009
    sty $d00b
    sty $d00d
    sty $d00f
    rts

irq
    asl $d019
    dec $d020
    lda scroll_idx
    cmp #8
    bne +
    jsr insert_char
    lda #0
    sta scroll_idx
+   jsr scroll_text
    inc $d020
    jmp $ea81

insert_char
    ; reset char pointer hi-byte (allows using the first 64 chars)
    lda #>chr_loc
    sta chr_ptr+1

    ; get character to insert
    ldy #0
    lda (text_ptr),y
    ; the end?
    cmp #0
    bne +
    ; reset text pointer to loop over
    lda #<text
    sta text_ptr
    lda #>text
    sta text_ptr+1
    lda (text_ptr),y

+   ; char code * 8 = char data offset relative to chr_loc
    clc
    rol
    rol
    rol
    ; set char data pointer
    sta chr_ptr
    bcc +
    inc chr_ptr+1

+   ; copy char data to sprite on right (starting at top right / third byte)
    ldy #0  ; char bytes counter
    ldx #2  ; sprite bytes counter (sprite "line" consists of 3 bytes)
-   lda (chr_ptr),y
    sta spr_loc,x
    inx
    inx
    inx
    iny
    cpy #8
    bne -

    ; increment pointer for next char
    inc text_ptr
    bne +
    inc text_ptr+1
+   rts

scroll_text
    ; shift sprite lines left on each sprite, carry will
    ; pass overflown bits to next sprite
    !for row, 0, 6 {
        clc
        !for sprite, 0, 7 {
            rol spr_loc + sprite * 64 + row * 3 + 2
            rol spr_loc + sprite * 64 + row * 3 + 1
            rol spr_loc + sprite * 64 + row * 3
        }
    }
    inc scroll_idx
    rts

text
    !scr "lorem ipsum dolor sit amet, "
    !scr "consectetur adipiscing elit, "
    !scr "sed do eiusmod tempor incididunt "
    !scr "ut labore et dolore magna aliqua."
    !scr "                    "
    !byte 0
