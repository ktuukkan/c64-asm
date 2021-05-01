!cpu 6502
!to "raster-irq2.prg",cbm

* = $0801
    !byte $0d,$08,$dc,$07,$9e,$20,$34
    !byte $39,$31,$35,$32,$00,$00,$00

;; two raster beam interrupts to draw a color bar in borders
* = $c000
    ; the usual irq setup (see raster-irq1.asm)
    sei
    ldy #$7f
    sty $dc0d
    sty $dd0d
    lda $dc0d
    lda $dd0d
    lda #$01
    sta $d01a
    lda #<irq_routine1
    ldx #>irq_routine1
    sta $314
    stx $315
    ; trigger first interrupt at raster line 100
    lda #$64
    sta $d012
    lda $d011
    and #$7f
    sta $d011
    cli
    jmp *

irq_routine1
    asl $d019
    ; change border color
    inc $d020
    ; setup second interrupt handler
    lda #<irq_routine2
    ldx #>irq_routine2
    sta $314
    stx $315
    ; trigger second interrupt at line 110
    lda #$6e
    sta $d012
    ; done
    jmp $ea31

irq_routine2
    asl $d019
    ; restore border color
    dec $d020
    ; setup the first interrupt handler again
    lda #<irq_routine1
    ldx #>irq_routine1
    sta $314
    stx $315
    ; trigger at raster line 100
    lda #$64
    sta $d012
    ; done
    jmp $ea31
