!cpu 6502
!to "waving.prg",cbm

* = $0801
    !byte $0d,$08,$dc,$07,$9e,$20,$34
    !byte $39,$31,$35,$32,$00,$00,$00

* = $c000
    counter = $fb
    lda #$00
    tay
    tax
    sta counter
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
    lda #<irq1
    ldx #>irq1
    sta $314
    stx $315
    lda #$87            ;; first irq at line 135
    sta $d012
    lda $d011
    and #$7f
    sta $d011
    cli
    rts

irq1
    asl $d019
    nop
    nop
    nop
    nop
    nop
    nop
    lda #$04            ;; text bg color
    sta $d020
    sta $d021
    lda #$8a            ;; wait for first pixel row on line 138..
    cmp $d012
    bne *-3
    lda #$92            ;; set next irq at line 146
    sta $d012
    lda #<irq2
    ldx #>irq2
    sta $314
    stx $315
    ldy #$00
wave
    ldx counter
    lda offset2,x
    ldx timing,y
    dex
    bne *-1
    sta $d016
    inc counter
    iny
    cpy #$08
    bne wave
    jmp $ea81

irq2
    asl $d019
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lda #$00            ;; reset colors
    sta $d020
    sta $d021
    lda #$87            ;; next irq at line 135 again
    sta $d012
    lda #<irq1
    ldx #>irq1
    sta $314
    stx $315
    lda $d016           ;; reset x-offset for rest of the screen
    and #%11111000
    sta $d016
    jmp $ea81

clear_screen
    ldx #$00
    stx $d020
    stx $d021
clear_loop
    lda #$20
    sta $0400,x
    sta $0400+$100,x
    sta $0400+$200,x
    sta $0400+$300,x
    lda #$00
    sta $d800,x
    sta $d800+$100,x
    sta $d800+$200,x
    sta $d800+$300,x
    inx
    bne clear_loop
    rts

write_text
    ldx #$00
write_loop
    lda text,x
    sta $0400+440,x
    lda #$01
    sta $d800+440,x
    inx
    cpx #$28
    bne write_loop
    rts

text
    !scr "       lorem ipsum dolor sit amet       "

timing
    !byte 1,8,8,8,8,8,8,8

offset
    !byte 0,0,0,0,0,0,0,0
    !byte 0,0,0,0,0,0,0,0
    !byte 2,1,0,0,0,0,0,0
    !byte 3,2,1,0,0,0,0,0
    !byte 4,3,2,1,0,0,0,0
    !byte 5,4,3,2,1,0,0,0
    !byte 6,5,4,3,2,1,0,0
    !byte 7,6,5,4,3,2,1,0
    !byte 7,7,6,5,4,3,2,1
    !byte 7,7,7,6,5,4,3,2
    !byte 7,7,7,7,6,5,4,3
    !byte 7,7,7,7,7,6,5,4
    !byte 7,7,7,7,7,7,6,5
    !byte 7,7,7,7,7,7,7,6
    !byte 7,7,7,7,7,7,7,7
    !byte 7,7,7,7,7,7,7,7
    !byte 7,7,7,7,7,7,7,7
    !byte 7,7,7,7,7,7,7,7
    !byte 6,7,7,7,7,7,7,7
    !byte 5,6,7,7,7,7,7,7
    !byte 4,5,6,7,7,7,7,7
    !byte 3,4,5,6,7,7,7,7
    !byte 2,3,4,5,6,7,7,7
    !byte 1,2,3,4,5,6,7,7
    !byte 0,1,2,3,4,5,6,7
    !byte 0,0,1,2,3,4,5,6
    !byte 0,0,0,1,3,3,4,5
    !byte 0,0,0,0,1,2,3,4
    !byte 0,0,0,0,0,1,2,3
    !byte 0,0,0,0,0,0,1,2
    !byte 0,0,0,0,0,0,0,1
    !byte 0,0,0,0,0,0,0,0
    !byte 0,0,0,0,0,0,0,0

offset2
    !byte 0,0,0,0,0,0,0,0
    !byte 0,0,0,0,0,0,0,0
    !byte 0,0,0,0,0,0,0,0
    !byte 0,0,0,0,0,0,0,0
    !byte 0,0,0,0,0,0,0,1
    !byte 1,1,1,1,1,1,1,1
    !byte 1,1,1,1,1,1,1,1
    !byte 2,2,2,2,2,2,2,2
    !byte 2,2,2,2,2,3,3,3
    !byte 3,3,3,3,3,3,3,3
    !byte 4,4,4,4,4,4,4,4
    !byte 4,4,4,4,5,5,5,5
    !byte 5,5,5,5,5,5,5,5
    !byte 5,6,6,6,6,6,6,6
    !byte 6,6,6,6,6,6,6,6
    !byte 6,6,7,7,7,7,7,7
    !byte 7,7,7,7,7,7,7,7
    !byte 7,7,7,7,7,7,7,7
    !byte 7,7,7,7,7,7,7,7
    !byte 7,7,7,7,7,7,7,7
    !byte 7,7,7,7,7,7,7,6
    !byte 6,6,6,6,6,6,6,6
    !byte 6,6,6,6,6,6,6,6
    !byte 5,5,5,5,5,5,5,5
    !byte 5,5,5,5,5,4,4,4
    !byte 4,4,4,4,4,4,4,4
    !byte 4,3,3,3,3,3,3,3
    !byte 3,3,3,3,2,2,2,2
    !byte 2,2,2,2,2,2,2,2
    !byte 2,1,1,1,1,1,1,1
    !byte 1,1,1,1,1,1,1,1
    !byte 1,1,0,0,0,0,0,0
