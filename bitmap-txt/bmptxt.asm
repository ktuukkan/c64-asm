!cpu 6502
!to "bmptxt.prg",cbm

basic_address   = $0801
sid_address     = $1000
sid_play        = $1003
sid_init        = $1D70
char_address    = $3800
screen_mem      = $4400 ; bank 2
bitmap_address  = $6000 ; Koala
bitmap_data     = $7f40
bitmap_color    = $8328
bitmap_bgcolor  = $8710
program_address = $c000
color_mem       = $d800

;; drawn with Multipaint
* = bitmap_address
    !bin "logo.kla",,$02

;; https://csdb.dk/sid/?id=6987
* = sid_address
    !bin "nightshift.sid",,$7c+2

;; standard charset modified with C64 Studio
* = char_address
    !bin "charset.chr"

* = basic_address
    !byte $0d,$08,$dc,$07,$9e,$20,$34,$39,$31,$35,$32,$00,$00,$00

* = program_address
    sei
    ;; init
    lda #$00
    tax
    tay
    jsr sid_init
    jsr clear_screen
    jsr load_bitmap
    jsr init_text
    ;; setup interrupts
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
    lda #<interrupt1
    ldx #>interrupt1
    sta $314
    stx $315
    ldy #$1b
    sty $d011
    lda #$7f
    sta $dc0d
    lda #$01
    sta $d01a
    ; trigger first interrupt at line 0
    lda #$00
    sta $d012
    cli
    ;; stay a while, stay forever!
    jmp *

interrupt1
    inc $d019
    ; trigger next interrupt at line 153
    lda #$99
    sta $d012
    lda #<interrupt2
    ldx #>interrupt2
    sta $314
    stx $315
    ; debug color
    ;ldx #$00
    ;stx $d020
    ;stx $d021
    ; routines to execute
    jsr bitmap_mode
    jmp $ea81

interrupt2
    ; acknowledge IRQ
    inc $d019
    ; trigger next IRQ at line 0 (again)
    lda #$00
    sta $d012
    lda #<interrupt1
    ldx #>interrupt1
    sta $314
    stx $315
    ; debug color
    ;ldx #$0b
    ;stx $d020
    ;stx $d021
    jsr text_mode
    jsr sid_play
    jmp $ea81

bitmap_mode
    ;; turn on bitmap graphics
    ;; hires      = $d011=$3b, $d016=$08
    ;; multicolor = $d011=$3b, $d016=$18
    lda #$3b
    sta $d011
    lda #$18
    sta $d016
    ;; switch to video bank 2 ($4000-$7FFF)
    lda $dd00
    and #$fc
    ora #$02
    sta $dd00
    ;; set video mem pointer (bank + $0400 and $2000)
    lda #$18
    sta $d018
    rts

text_mode
    ;; set text mode
    ;; hires      = $d011=$1b, $d016=$08 (default)
    ;; multicolor = $d011=$1b, $d016=$18
    ;; extended   = $d011=$5b, $d016=$08 (only 64 chars)
    lda #$1b
    sta $d011
    lda #$08
    sta $d016
    ;; switch to video bank 1 ($0000-$3FFF)
    lda $dd00
    and #$fc
    ora #$03
    sta $dd00
    ;; set charset location
    ;; 7 * 2048 = $3800, set in bits 1-3 of $d018
    lda $d018
    ora #$0e
    sta $d018
    rts

load_bitmap
    lda bitmap_bgcolor
    sta $d020
    sta $d021
    ldx #$00
copy_bmp
    ;; screen mem
    lda bitmap_data,x
    sta screen_mem,x
    lda bitmap_data+256,x
    sta screen_mem+256,x
    lda bitmap_data+512,x
    sta screen_mem+512,x
    lda bitmap_data+768,x
    sta screen_mem+768,x
    ;; color mem
    lda bitmap_color,x
    sta color_mem,x
    lda bitmap_color+256,x
    sta color_mem+256,x
    lda bitmap_color+512,x
    sta color_mem+512,x
    lda bitmap_color+768,x
    sta color_mem+768,x
    inx
    bne copy_bmp
    rts

init_text
    ldx #$00
copy_txt
    lda text1,x
    sta $0400+520,x
    lda text2,x
    sta $0400+640,x
    lda #$06
    sta color_mem+520,x
    lda #$0e
    sta color_mem+640,x
    inx
    cpx #$28
    bne copy_txt
    rts

clear_screen
    ldx #$00
clear_loop
    lda #$20      ; space
    sta $0400,x   ; screen mem x4
    sta $0400+256,x
    sta $0400+512,x
    sta $0400+768,x
    lda #$00      ; black
    sta $d800,x   ; screen color x4
    sta $d800+256,x
    sta $d800+512,x
    sta $d800+768,x
    sta screen_mem,x
    sta screen_mem+256,x
    sta screen_mem+512,x
    sta screen_mem+768,x
    inx
    bne clear_loop
    rts

text1
    !scr  "           split screen with            "
text2
    !scr  "         bitmap, tune and text          "
