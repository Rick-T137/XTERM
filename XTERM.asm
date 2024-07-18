INIT:
        LDX $38                 ; load TOM pointer into XR
        DEX                     ; move pointer down 1 page (256 bytes)
        DEX                     ; move pointer down another page
        STX $38                 ; update pointer
        LDA #$05                ; load 05 into AC (logical)
        LDX #$02                ; load 02 into XR (physical)
        LDY #$00                ; load 00 into YR (command)
        JSR $FFBA               ; call SETLFS
        LDA @PARAMS(LEN)        ; load length of PARAMS into AC
        LDX @PARAMS(LO)         ; load lo byte of PARAMS into XR
        LDY @PARAMS(HI)         ; load hi byte of PARAMS into YR
        JSR $FFBD               ; call SETNAM
        JSR $FFC0               ; call OPEN
        LDX #$05                ; load 05 into XR (RS232)
        JSR $FFC6               ; call CHKIN
        JSR $FFE4               ; call GETIN - toss a null
        JSR $FFCC               ; call CLRCHN - reset to defaults
        LDA #$93                ; load 147 into AC (CLR HOME)
        JSR $FFD2               ; call CHROUT
        LDX #$0A                ; load 10 into XR (8 = black on red)
        STX $900F               ; store XR into 36879
        LDA #$05                ; load 5 into AC (WHITE)
        JSR $FFD2               ; call CHROUT
        LDA #$0E                ; load 14 into AC (LOWER CASE)
        JSR $FFD2               ; call CHROUT
        LDX @BANNER(LO)         ; load BANNER lo byte into XR
        STX $FC                 ; store XR into 252 (zero page)
        LDX @BANNER(HI)         ; load BANNER hi byte into XR
        STX $FD                 ; store XR into 253 (zero page)
        LDX @BANNER(LEN)        ; load BANNER length into XR
        STX $FE                 ; store XR into 254 (zero page)
        JSR %PRINT              ; call PRINT
READY:
        LDX @PROMPT(LO)         ; load PROMPT lo byte into XR
        STX $FC                 ; store XR into 252 (zero page)
        LDX @PROMPT(HI)         ; load PROMPT hi byte into XR
        STX $FD                 ; store XR into 253 (zero page)
        LDX @PROMPT(LEN)        ; load PROMPT length into XR
        STX $FE                 ; store XR into 254 (zero page)
        JSR %PRINT              ; call PRINT
XREMOTE:
        JSR $FFCC               ; call CLRCHN
        JSR %CURSORON           ; call CUSORON
        LDX #$05                ; load 5 into AC (RS232)
        JSR $FFC6               ; call CHKIN
        JSR $FFE4               ; call GETIN
        CMP #$00                ; compare AC to zero (NULL)
        BEQ %XLOCAL             ; if NULL, branch to XLOCAL
        PHA                     ; push AC onto stack
        JSR $FFCC               ; call CLRCHN - reset to defaults
        JSR %CURSOROFF          ; call CURSOROFF
        PLA                     ; pull AC off of stack
        JSR $FFD2               ; call CHROUT
        JSR %CHECKQUOTE         ; call CHECKQUOTE
        JMP %XREMOTE            ; jump back to XREMOTE for next char in buffer
XLOCAL:
        JSR $FFCC               ; call CLRCHN - reset to defaults
        JSR %CURSORON           ; call CURSORON
        JSR $FFE4               ; call GETIN
        CMP #$00                ; compare AC to zero (NULL)
        BEQ %XREMOTE            ; branch back to XREMOTE
        CMP #$88                ; compare AC to 136 (F7 key)
        BEQ %EXIT               ; if F1 then branch to EXIT
        PHA                     ; push AC onto stack
        LDX #$05                ; load 5 into XR (RS232)
        JSR $FFC9               ; call CHKOUT
        PLA                     ; pull AC off of stack
        JSR $FFD2               ; call CHROUT
        JMP %XREMOTE            ; jump to back to XREMOTE
EXIT:
        LDA #$05                ; load 5 into AC (RS232)
        JSR $FFC3               ; call CLOSE
        JSR $FFE7               ; call CLOSEALL
        LDX $38                 ; load TOM pointer into XR
        INX                     ; move pointer up 1 page (256 bytes)
        INX                     ; move pointer up another page
        STX $38                 ; update pointer
        JSR $FFCC               ; call CLRCHN - reset to defaults
        JSR %CURSOROFF          ; call CURSOROFF
        RTS                     ; return from subroutine
CHECKQUOTE:
        CMP #$22                ; compare char with 34 (quote char)
        BNE %CQEXIT             ; if not, then just exit
        LDX #$00                ; otherwise, load zero into XR
        STX $D4                 ; store XR into 212 - disable quote mode
CQEXIT:
        RTS                     ; return from subroutine
GETCURPOS:
        LDA $D1                 ; load cursor position lo byte from 209 into AC
        STA $FC                 ; store AC into 252 (zero page)
        LDA $D2                 ; load cursor position hi byte from 210 into AC
        STA $FD                 ; store AC into 253 (zero page)
        CLC                     ; clear carry flag
        LDA $FC                 ; load lo byte into AC
        ADC $D3                 ; add cursor column to position from 211 into AC
        STA $FC                 ; update lo byte from AC
        LDA $FD                 ; load hi byte into AC
        ADC #$00                ; add zero into AC (to force any roll over from above)
        STA $FD                 ; update hi byte from AC
        RTS                     ; return from subroutine
CURSORON:
        LDX @CURSOR             ; load value of CURSOR into XR
        CPX #$01                ; compare with 1 = ON,
        BEQ %CNEXIT             ; if cursor already on, then exit
        JSR %GETCURPOS          ; call GETCURPOS
        LDY #$00                ; load zero into YR
        LDA ($FC),Y             ; load screen code under cursor into AC
        ORA #$80                ; OR value with 128 = turn cursor ON
        STA ($FC),Y             ; update screen code
        LDX #$01                ; load one into XR
        STX @CURSOR             ; update cursor tracker to ON
CNEXIT:
        RTS                     ; return from subroutine
CURSOROFF:
        LDX @CURSOR             ; load value of CURSOR into XR
        CPX #$00                ; compare with 0 = OFF
        BEQ %CFEXIT             ; if cursor already off, then exit
        LDY #$00                ; load zero into YR
        LDA ($FC),Y             ; load screen code under cursor into AC
        AND #$7F                ; AND value with 127 = turn cursor OFF
        STA ($FC),Y             ; update screen code
        LDX #$00                ; load zero into XR
        STX @CURSOR             ; update cursor tracker to OFF
CFEXIT:
        RTS                     ; return from subroutine
PRINT:
        LDY #$00                ; load zero into YR (counter)
PRINTNC:
        LDA ($FC),Y             ; load next char into AC
        JSR $FFD2               ; call CHROUT
        INY                     ; increment Y by 1
        CPY $FE                 ; compare Y with LEN in 254
        BNE %PRINTNC            ; if not equal, branch back to PRINTNC
        RTS                     ; otherwise, return from subroutine

VARIABLES:
        CURSOR (1 byte)         ; 0 = OFF, 1 = ON
        BANNER (24 bytes)       ; \12    xmodem term v1    \92
        PROMPT (10 bytes)       ; \05\0d\0dready.\0d
        PARAMS (2 bytes)        ; \08\00, comm params, 08 = 1200 baud, 06 = 300 baud
