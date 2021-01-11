// Calculates a hamming code for 128 bits of data
// It uses 9 check bits (8 for the Hamming(255,247) + 1 extra parity bit)
// It can correct a single bit error and detect double errors. Triple errors
// may be wrongfully corrected.

`define DATA_BITS 128
`define ENCODED_BITS (`DATA_BITS + 9)

module VX_hamming_128_enc #(
)(

)