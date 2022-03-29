!cpu 6502
!to "multicolor.prg",cbm

;; Multicolor image addressing for bank 1 ($4000-$7FFF)
bitmap_address = $6000
bitmap_screen = $7f40
bitmap_color = $8328
bitmap_bgcolor = $8710

;; screen mem location relative to bank 1
screen_mem = $4400

;; color mem always at $d800 (bitmap_color)
color_mem = $d800       

;; load image file (eg. Koala, .kla), skip two-byte header
* = bitmap_address
    !bin "assets/multicolor.kla",,$02

;; SYS 4096 ($1000)
* = $0801
    !byte $0c,$08,$0a,$00,$9e,$20,$34,$30,$39,$36,$00,$00,$00

* = $1000
    lda bitmap_bgcolor
    sta $d020
    sta $d021
    ldx #$00
draw_image
    ;; screen mem
    lda bitmap_screen,x
    sta screen_mem,x
    lda bitmap_screen+256,x
    sta screen_mem+256,x
    lda bitmap_screen+512,x
    sta screen_mem+512,x
    lda bitmap_screen+768,x
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
    bne draw_image
    ;; switch to video bank 2 for Koala
    lda $dd00
    and #$fc
    ora #$02
    sta $dd00
    ;; turn on bitmap graphics
    lda #$b3
    sta $d011
    ;; turn on multicolor graphics
    lda #$18
    sta $d016
    ;; set screen ram and bitmap locations
    ;; 1 * $0400 = $0400 (screen), 8 * $0400 = $2000 (bitmap)
    lda #$18    ; #%00011000 / $10 (1) + $08 (8)
    sta $d018
holdit
    jmp holdit
