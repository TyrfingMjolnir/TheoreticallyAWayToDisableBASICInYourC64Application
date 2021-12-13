# C64 Disable BASIC ROM to make the space available as RAM

Discussion

According to this: https://sta.c64.org/cbm64mem.html as mentioned in the comments here: https://youtu.be/NKOucB0o4YQ

And will you still be able to use system SEQ files for reading and writing? Such as https://codebase64.org/doku.php?id=base:reading_a_file_byte-by-byte

Assembler code:
====== Reading from a file byte-by-byte ======
```
load_address = $2000  ; just an example

        LDA #fname_end-fname
        LDX #<fname
        LDY #>fname
        JSR $FFBD     ; call SETNAM

        LDA #$02      ; file number 2
        LDX $BA       ; last used device number
        BNE .skip
        LDX #$08      ; default to device 8
.skip   LDY #$02      ; secondary address 2
        JSR $FFBA     ; call SETLFS

        JSR $FFC0     ; call OPEN
        BCS .error    ; if carry set, the file could not be opened

        ; check drive error channel here to test for
        ; FILE NOT FOUND error etc.

        LDX #$02      ; filenumber 2
        JSR $FFC6     ; call CHKIN (file 2 now used as input)

        LDA #<load_address
        STA $AE
        LDA #>load_address
        STA $AF

        LDY #$00
.loop   JSR $FFB7     ; call READST (read status byte)
        BNE .eof      ; either EOF or read error
        JSR $FFCF     ; call CHRIN (get a byte from file)
        STA ($AE),Y   ; write byte to memory
        INC $AE
        BNE .skip2
        INC $AF
.skip2  JMP .loop     ; next byte

.eof
        AND #$40      ; end of file?
        BEQ .readerror
.close
        LDA #$02      ; filenumber 2
        JSR $FFC3     ; call CLOSE

        JSR $FFCC     ; call CLRCHN
        RTS
.error
        ; Akkumulator contains BASIC error code

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)

        ;... error handling for open errors ...
        JMP .close    ; even if OPEN failed, the file has to be closed
.readerror
        ; for further information, the drive error channel has to be read

        ;... error handling for read errors ...
        JMP .close

fname:  
!tx "JUST A FILENAME"
fname_end:
```
You may open more than one file if you use different file numbers and secondary addresses for them. File numbers and secondary addresses should be in the range of 2 to 14. It's usually a good idea to use the same number for both to keep confusion low.
