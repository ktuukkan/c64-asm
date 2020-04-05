;; Opens the top and bottom borders. The idea is to trick VIC-II 
;; to skip enabling the borders by switching between 24 and 25 row
;; modes so that the border drawing is never triggered.
!cpu 6502
!to "top-bottom.prg",cbm

* = $0801
    !byte $0d,$08,$dc,$07,$9e,$20,$34
    !byte $39,$31,$35,$32,$00,$00,$00

* = $c000
    sei
    lda #$00       ;; clear $3fff "ghostbyte"
    sta $3fff
    ldy #$7f       ;; setup raster beam interrupt
    sty $dc0d
    sty $dd0d      
    lda $dc0d
    lda $dd0d
    lda #$01
    sta $d01a
    lda #<irq
    ldx #>irq
    sta $314
    stx $315
    lda #$f9        ;; irq at line 249, just before border in 25 row mode
    sta $d012
    lda $d011
    and #$7f
    sta $d011
    cli
    jmp *

irq
    inc $d019       ;; ack irq
    lda $d011       ;; switch to 24 row mode ($d011 bit 3 = 0)
    and #$f7        ;; %11110111
    sta $d011
    lda #$fd        ;; wait for line 253..
    cmp $d012       ;; just below border in 25 row mode
    bne *-3
    lda $d011       ;; switch back to 25 row mode ($d011 bit 3 = 1)
    ora #$08        ;; %00001000
    sta $d011
    jmp $ea31
