!cpu 6502
!to "1x2scroller.prg",cbm

basic_address   = $0801
program_address = $c000
screen_mem      = $0400
color_mem       = $d800
scroll_line1    = screen_mem+480    ;; address of first scroll line
scroll_line2    = screen_mem+520    ;; address of second scroll line
scroll_color1   = color_mem+480     ;; address of first scroll line color
scroll_color2   = color_mem+520     ;; address of second scroll line color
raster_line1    = $90               ;; above scroll
raster_line2    = $a4               ;; below scroll
scroll_offset   = $07               ;; initial scroll offset at far right

* = basic_address
    !byte $0d,$08,$dc,$07,$9e,$20,$34,$39,$31,$35,$32,$00,$00,$00

;; http://kofler.dot.at/c64/font_06.html
* = $3800
    !bin "../1x2-charset/devils_collection_25_y.64c",,$02

* = program_address
    sei
    lda #$00
    tax
    tay
    jsr init_screen
    jsr init_scroller
    ldy #$7f                ;; setup raster interrupts
    sty $dc0d
    sty $dd0d
    lda $dc0d
    lda $dd0d
    lda #$01
    sta $d01a
    lda $d011
    and #$7f
    sta $d011
    lda #<interrupt1
    ldx #>interrupt1
    sta $314
    stx $315
    ldy #$1b
    sty $d011
    lda #$7f
    sta $dc0d
    lda #$01
    sta $d01a
    lda #raster_line1
    sta $d012
    cli
    jmp *

interrupt1
    asl $d019               ;; acknowledge IRQ
    jsr soft_scroll
    lda #raster_line2       ;; setup next interrupt below scroll line
    sta $d012
    lda #<interrupt2
    ldx #>interrupt2
    sta $314
    stx $315
    lda $d016               ;; enable 38 column mode (bit 3 of $d016 = 0)
    and #$f7
    sta $d016
    jmp $ea81

interrupt2
    asl $d019               ;; acknowledge IRQ
    lda $d016               ;; restore 40 column mode (bit 3 of $d016 = 1)
    ora #$08
    sta $d016    
    jsr hard_scroll
    lda $d016               ;; reset soft scroll offset for rest of the screen
    and #$f8                ;; %11111000 (255 - 1 - 2 - 4 = 248 = $f8)
    sta $d016
    lda #raster_line1       ;; setup next IRQ above scroll line
    sta $d012
    lda #<interrupt1
    ldx #>interrupt1
    sta $314
    stx $315
    jmp $ea31

soft_scroll
    lda $d016               ;; slide chars left by 1px
    ora scroll_offset
    sta $d016
    dec scroll_offset
    rts

hard_scroll
    lda $d016               ;; check current soft scroll offset
    and #$07
    bne skip                ;; skip hard scroll when offset > 0
    lda #$07
    sta scroll_offset
    ldx #$00
shift_chars     
    lda scroll_line1+1,x     ;; move all chars left by one column
    sta scroll_line1,x
    lda scroll_line2+1,x
    sta scroll_line2,x
    inx
    cpx #$28
    bne shift_chars
    jsr read_text           ;; insert new char in the last column (hidden)
skip
    rts

init_screen
    ldx #$00
    stx $d020
    sta $d021
clear
    lda #$20
    sta $0400,x
    sta $0400+256,x
    sta $0400+512,x
    sta $0400+768,x
    lda #13
    sta scroll_color1,x
    sta scroll_color2,x
    inx
    bne clear
    lda $d018               ;; set charset pointer to $3800
    ora #$0e
    sta $d018
    rts

read_text
    lda read_text+1         ;; read next char from "buffer"
    cmp #$00                ;; is it the end marker? (byte 0)
    bne insert_char         ;; .. if not, put it on screen
    jsr init_scroller       ;; reset "buffer" to initial state
    jmp read_text           ;; restart reading
insert_char
    sta scroll_line1+39     ;; insert the char at the column 39
    ora #$40                ;; offset bottom half by 64 chars
    sta scroll_line1+79     ;; insert bottom half of char at next line
    inc read_text+1         ;; increment char pointer to next char
    lda read_text+1
    cmp #$00                ;; zero?
    bne read_done           ;; .. nope, all good
    inc read_text+2         ;; .. yes, increment high byte as well
read_done
    rts

init_scroller
    lda #<scroll_text
    ldy #>scroll_text
    sta read_text+1
    sty read_text+2
    rts

scroll_text
    !scr "          "
    !scr "lorem ipsum dolor sit amet, consectetur adipiscing elit, "
    !scr "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    !scr "                              "
    !byte 0
