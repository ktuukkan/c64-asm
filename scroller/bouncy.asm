!cpu 6502
!to "bouncy.prg",cbm

basic_address   = $0801
program_address = $c000
screen_mem      = $0400
color_mem       = $d800
scroll_offset   = $07           ;; scroll offset at the beginning (far right)
scroll_step     = $01           ;; soft scroll amount per screen refresh (1px to the left)
scroll_line     = $0400+480     ;; address for first column of the scroll line
scroll_color    = $d800+480
raster_line1    = $8d           ;; 144
raster_line2    = $9e           ;; 154
y_counter       = $fe

* = basic_address
!byte $0d,$08,$dc,$07,$9e,$20,$34,$39,$31,$35,$32,$00,$00,$00

* = program_address
    sei
    lda #$00
    tax
    tay
    sta y_counter
    jsr init_screen
    jsr init_scroller
    ;; setup interrupts
    ldy #$7f
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
    ; trigger interrupt at line 168
    lda #raster_line1
    sta $d012
    cli
hold_it 
    jmp hold_it


interrupt1
    ; acknowledge IRQ
    asl $d019
    ; setup next interrupt below scroll line
    lda #raster_line2
    sta $d012
    lda #<interrupt2
    ldx #>interrupt2
    sta $314
    stx $315
    ;; enable 38 column mode (bit 3 of $d016 = 0)
    lda $d016
    and #$f7
    sta $d016
    jsr soft_scroll
    jmp $ea81

interrupt2
    ;; acknowledge IRQ
    asl $d019
    ;; setup next IRQ above scroll line
    lda #raster_line1
    sta $d012
    lda #<interrupt1
    ldx #>interrupt1
    sta $314
    stx $315
    ;; restore 40 column mode (bit 3 of $d016 = 1)
    lda $d016
    ora #$08
    sta $d016    
    jsr hard_scroll
    jsr bounce
    ;; reset soft scroll offset for other parts of the screen
    lda $d016
    and #$f8            ;; %11111000 (255 - 1 - 2 - 4 = 248 = $f8)
    sta $d016
    jmp $ea81

soft_scroll
    ;; slide chars left
    lda scroll_offset
    sec                 ;; set carry
    sbc #scroll_step    ;; decrease offset by one step (7, 6, 5 ... 0)
    and #$07            ;; mask with maximum offset (%00000111) to avoid changing other bits of $d016
    sta scroll_offset
    sta $d016
    rts

hard_scroll
    ;; check current soft scroll offset
    lda $d016
    and #$07
    bne skip    ;; skip hard scroll when offset > 0
    ;; reset x-scroll register to far right (offset 7px)
    lda $d016
    ora #$07
    sta $d016

    ;; move all chars left by one column
    ldx #$00
shift_chars
    lda scroll_line+1,x
    sta scroll_line,x
    lda #$01
    sta scroll_color,x
    inx
    cpx #$28
    bne shift_chars
    ;; insert new char in the last column (hidden)
    jsr read_text
skip
    rts

bounce
    inc y_counter
    ldx y_counter
    lda $d011
    and #%11111000
    ora sinus,x
    sta $d011
    rts

init_screen
    ldx #$00
clear
    lda #$20
    sta $0400,x
    sta $0400+256,x
    sta $0400+512,x
    sta $0400+768,x
    lda #$01
    sta $d800,x
    sta $d800+256,x
    sta $d800+512,x
    sta $d800+768,x
    inx
    bne clear
    lda #$00
    sta $d020
    sta $d021
    rts

read_text
    ;; read next char from "buffer"
    lda read_text+1
    cmp #$00            ;; is it the end marker? (byte 0)
    bne insert_char     ;; .. if not, put it on screen
    jsr init_scroller   ;; reset "buffer" to initial state
    jmp read_text       ;; restart reading
insert_char
    ;; insert the char at the column 39
    sta scroll_line+39
    ;; increment char pointer to next char
    inc read_text+1
    lda read_text+1
    cmp #$00            ;; zero?
    bne read_done       ;; .. nope, all good
    inc read_text+2     ;; .. yes, increment high byte as well
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
    !scr "lorem ipsum dolor sit amet, "
    !scr "consectetur adipiscing elit, "
    !scr "sed do eiusmod tempor incididunt "
    !scr "ut labore et dolore magna aliqua."
    !scr "                              "
    !byte 0


sinus
!byte 4,3,3,3,2,2,2,2,1,1,1,1,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
!byte 1,1,1,1,2,2,2,2,3,3,3,4,4,4,5,5
!byte 5,5,6,6,6,6,7,7,7,7,7,7,7,7,7,7
!byte 7,7,7,7,7,7,7,7,7,7,6,6,6,6,5,5
!byte 5,5,4,4,4,4,3,3,3,2,2,2,2,1,1,1
!byte 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3
!byte 4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,7
!byte 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,6
!byte 6,6,6,5,5,5,5,4,4,4,4,3,3,3,2,2
!byte 2,2,1,1,1,1,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,1,1,1,1,2,2
!byte 2,2,3,3,3,4,4,4,5,5,5,5,6,6,6,6
!byte 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
!byte 7,7,7,7,6,6,6,6,5,5,5,5,4,4,4,4
