!cpu 6502
!to "petscii.prg",cbm

bd_color    = screen_001
bg_color    = screen_001+1
char_data   = screen_001+2
color_data  = char_data+1000

* = $0801                             
    !byte $0d,$08,$dc,$07,$9e,$20,$34
    !byte $39,$31,$35,$32,$00,$00,$00        

* = $c000
    lda bd_color
    sta $d020  
    lda bg_color
    sta $d021
    ldx #$00
loop
    ;; copy chars to screen mem
    lda char_data,x
    sta $0400,x
    lda char_data+256,x
    sta $0400+256,x
    lda char_data+512,x
    sta $0400+512,x
    lda char_data+768,x
    sta $0400+768,x
    ;; copy colors to color mem
    lda color_data,x
    sta $d800,x
    lda color_data+256,x
    sta $d800+256,x
    lda color_data+512,x
    sta $d800+512,x
    lda color_data+768,x
    sta $d800+768,x
    inx
    bne loop
    jmp *

; include logo (exported as Acme asm)
!src "logo.asm"
