!cpu 6502
!to "timer-irq.prg",cbm

; trigger interrupt once per frame
interval = $4cc7

* = $0801
    !byte $0c,$08,$0a,$00,$9e,$20,$34,$30,$39,$36,$00,$00,$00

; Non-maskable (NMI) interrupt using CIA timer(s)
* = $1000
    sei
    ; cancel queued interrupts
    lda $dc0d
    lda $dd0d
    ; set interrupt routine pointer
    lda #<interrupt
    ldx #>interrupt
    sta $0318
    stx $0319
    ; set timer A interval
    lda #<interval
    ldx #>interval
    sta $dd04
    stx $dd05
    ; enable timer A
    lda #$81
    sta $dd0d
    ; sync interrupt execution to below bottom border
    lda #$ff
-   cmp $d012
    bne -
    ; enable timer interrupts
    lda #$01
    sta $dd0e
    cli
    ; stay
    jmp *

interrupt
    ; acknowledge interrupt
    bit $dd0d
    dec $d020
    ; store registers to stack
    pha
    txa
    pha
    tya
    pha
    ; do the actual work
    jsr write
    ; restore registers from stack
    pla
    tay
    pla
    tax
    pla
    ; exit interrupt routine
    inc $d020
    rti

write
    ldx counter
    lda text,x
    sta $0400,x
    inc counter
    lda counter
    cmp #(text_end - text)
    bne +
    lda #0
    sta counter
+   rts

counter
    !byte 0
text
    !scr "     non-maskable interrupt example     "
    !scr "                                        "
    !scr "     non-maskable interrupt example     "
    !scr "                                        "
    !scr "     non-maskable interrupt example     "
    !scr "                                        "
text_end
