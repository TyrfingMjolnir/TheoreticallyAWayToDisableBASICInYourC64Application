DEC $0001 // Disable BASIC ROM to ENABLE RAM in the same memory space
/// Do Whatever you would like also in the space of 0xA000 through 0xBFFF
INC $0001 // Enable BASIC because my application is done running
RTS
