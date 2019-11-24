!cpu 6502
!to "bitmap.prg",cbm

;; default video bank ($0000-$3fff), e.g. Timanthes defaults
;bitmap_address = $2000
;bitmap_data = $3f40
;bitmap_color = $4328
;bitmap_bgcolor = $4710
;screen_mem = $0400

;; bank 2 ($4000-$7FFF) addressing for Koala
bitmap_address = $6000
bitmap_data = $7f40
bitmap_color = $8328
bitmap_bgcolor = $8710
screen_mem = $4400

;; color mem is always $d800
color_mem = $d800

;; load image file, remember to skip two-byte header
* = bitmap_address
!bin "dog_koala.kla",,$02
;!bin "dog_custom.prg",,$02

* = $0801
!byte $0C,$08,$0A,$00,$9E,$20,$34,$30,$39,$36,$00,$00,$00 ; SYS 4096 ($1000)

* = $1000
        lda bitmap_bgcolor
        sta $d020
        sta $d021
        ldx #$00

draw_image
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
        ;; set screen ram and bitmap locations, relative to bank's base address
        ;; 1 * $0400 = $0400 (screen ram), 8 * 0400 = $2000 (bitmap data) --> #$18
        lda #$18
        sta $d018

holdit
        jmp holdit
