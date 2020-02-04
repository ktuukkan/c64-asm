!cpu 6502
!to "sprite-anim.prg",cbm

;; basic loader
* = $0801
    !byte $0d,$08,$dc,$07,$9e,$20,$34
    !byte $39,$31,$35,$32,$00,$00,$00

;; load a sprites, exported from SpritePad as raw bin
* = $2000
    !bin "pulsar.bin"

* = $c000
    delay = $fb     ;; unused zero-page registers: $0002, $00fb - $00fe
    frame = $fc     ;; these can be freely used for counters etc.
    sei
    jsr init_sprite
    ldy #$7f        ;; set up interrupt on raster line 0
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
    lda #$00
    sta $d012
    lda $d011
    and #$7f
    sta $d011
    cli
    jmp *

irq
    dec $d019
    jsr animate_sprite
    jmp $ea81

animate_sprite
    lda delay       ;; check delay byte
    cmp #$01        ;; advance animation when $01
    bne skip
    
    ldx $07f8       ;; check current frame
    cpx #$89        ;; 140 dec (we have 10 sprites from 128 to 138)
    bne next_frame  ;; advance next frame if not frame 6 yet
    
    ldx #$80        ;; last sprite reached, reset counter
    stx $07f8

next_frame
    inc $07f8       ;; advance animation by incrementing sprite pointer
skip    
    lda delay       ;; flip the delay byte between 0 and 1
    eor #$01
    sta delay
done
    rts

init_sprite
    
    lda #$00        ;; blackout
    sta $d020
    sta $d021
    sta frame
    sta delay
    
    lda #$80        ;; set sprite location (128 * 64 = 8192 = $2000)
    sta $07f8
    
    lda #$01        ;; display sprite 0
    sta $d015
    
    lda #$01        ;; enable multicolor for sprite 0
    sta $d01c
    
    lda #$01        ;; set sprite 0 main color yellow
    sta $d027
    
    lda #$0f        ;; set multicolor 0 to black
    sta $d025
    
    lda #$0b        ;; set multicolor 0 to black
    sta $d026
    
    ldx #160        ;; set sprite location
    stx $d000       
    stx $d001
    rts
