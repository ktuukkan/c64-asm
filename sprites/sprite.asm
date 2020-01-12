!cpu 6502
!to "sprite.prg",cbm

;; basic loader
* = $0801
    !byte $0d,$08,$dc,$07,$9e,$20,$34
    !byte $39,$31,$35,$32,$00,$00,$00

;; load a sprite (drawn with SpritePad and exported as bin)
* = $2000
    !bin "face.bin"

* = $c000
    
    ;; The last 8 bytes of screen mem ($07f8-$07ff) are pointers to sprite
    ;; shape data, given in multiples of sprite size (64 bytes).
    ;; set location of sprite 0 to $2000 (128 * 64 = 8192 = $2000)
    lda #$80        ;; 128 in hex
    sta $07f8

    ;; each bit in $d015 controls the displaying of corresponding sprite (0-7).
    ;; display sprite 0
    lda #$01        ;; %00000001
    sta $d015

    ;; each bit in $d01c controls the color mode of corresponding sprite (0-7)
    ;; enable multicolor for sprite 0
    lda #$01        ;; %00000001
    sta $d01c

    ;; set location of sprite 0
    ;; sprite locations starting at $d000 in x/y pairs (0-255)
    ;; the x/y ce that each sprite has size 24 x 21 pixels
    lda #$99
    sta $d000       ;; x = $99
    sta $d001       ;; y = $99 .. $d002 is the x of sprite 1 etc.

    ;; registers $d027-$d02e control the main color of each sprite (multicolor & hires)
    ;; set sprite 0 main color to yellow
    lda #$07
    sta $d027

    ;; registers $d025 and $d026 are for colors in multicolor mode
    ;; set multicolor 0 to black
    lda #$00
    sta $d025
    ;; set multicolor 1 to light gray
    lda #$0f
    sta $d026

    jmp *
    