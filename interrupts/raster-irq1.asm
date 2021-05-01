!cpu 6502
!to "raster-irq1.prg",cbm

* = $0801
    !byte $0d,$08,$dc,$07,$9e,$20,$34
    !byte $39,$31,$35,$32,$00,$00,$00

;; single raster beam interrupt to flash border in sync with screen refresh
* = $c000
    ; disable interrupts
    sei
    ; disable CIA timer interrupts ($7f = %01111111)
    ldy #$7f
    sty $dc0d
    sty $dd0d
    ; cancel all queued IRQs
    lda $dc0d
    lda $dd0d
    ; enable IRQs by raster beam
    lda #$01
    sta $d01a
    ; insert custom routine to IRQ vector
    lda #<irq_routine
    ldx #>irq_routine
    sta $314
    stx $315
    ; trigger interrupts at line 0
    lda #$00
    sta $d012
    ; reset 9th bit of $d012 at $d011 ()
    lda $d011
    and #$7f
    sta $d011
    ; enable IRQs
    cli
    ; infinite loop
    jmp *

irq_routine
    ; acknowledge IRQ
    asl $d019
    ; flash border color in sync with screen refresh
    inc $d020
    ; Jump to Kernal's standard interrupt routine
    ; to handle keyboard scan, cursor display etc.
    ; To skip system routines, jump to $ea81 (faster).
    jmp $ea31
