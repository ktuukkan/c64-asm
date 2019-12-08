!cpu 6502
!to "1x2char.prg",cbm

* = $0801
    !byte $0d,$08,$dc,$07,$9e,$20,$34
    !byte $39,$31,$35,$32,$00,$00,$00

;; http://kofler.dot.at/c64/font_06.html
* = $3800
    !bin "devils_collection_25_y.64c",,$02

* = $c000
    jsr clear_screen
    jsr write_text
    jmp *

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
    ;; enable custom charset
    lda $d018
    ora #$0e
    sta $d018
    ; loop counter
    ldx #$00
next
    ;; read one char and place it on screen (top part & line)
    lda text,x
    sta $0400+440,x
    ;; OR char value for bottom part and place it on next line
    ;; A = 1, A (rvs) = 65 --> diff is $40 (64 dec) chars 
    ora #$40
    sta $0400+480,x

    inx
    cpx #$28
    bne next
    rts

text
    !scr "       lorem ipsum dolor sit amet       "
