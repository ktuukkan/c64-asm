!cpu 6502
!to "hires.prg",cbm

;; Hires image addressing for bank 1 ($4000-$7FFF)
bitmap_address = $6000
bitmap_screen = $7f40
bitmap_border = $8328

;; screen mem location relative to bank 1
screen_mem = $4400

;; load image file (eg. Art Studio, .art), skip two-byte header
* = bitmap_address
    !bin "assets/hires.art",,$02

;; SYS 4096 ($1000)
* = $0801
    !byte $0c,$08,$0a,$00,$9e,$20,$34,$30,$39,$36,$00,$00,$00

* = $1000
    lda bitmap_border
    sta $d020
    ldx #$00
draw_image
    ;; copy bitmap screen data to screen mem
    lda bitmap_screen,x
    sta screen_mem,x
    lda bitmap_screen+256,x
    sta screen_mem+256,x
    lda bitmap_screen+512,x
    sta screen_mem+512,x
    lda bitmap_screen+768,x
    sta screen_mem+768,x
    inx
    bne draw_image
    ;; switch to video bank 1
    lda $dd00
    and #$fc
    ora #$02
    sta $dd00
    ;; enable bitmap graphics and hires mode ($d011=$3b, $d016=8)
    lda #$3b
    sta $d011
    lda #$08
    sta $d016
    ;; set screen ram and bitmap locations
    ;; 1 * $0400 = $0400 (screen), 8 * $0400 = $2000 (bitmap)
    lda #$18    ; #%00011000 / $10 (1) + $08 (8)
    sta $d018
holdit
    jmp holdit
