// Calculates a hamming code for 128 bits of data
// It uses 9 check bits (8 for the Hamming(255,247) + 1 extra parity bit)
// It can correct a single bit error and detect double errors. Triple errors
// may be wrongfully corrected.

`include "VX_hamming_func.vh"

module VX_hamming_dec #(
	parameter DATA_BITS = 128,

	parameter HAMMING_BITS = calculate_hamming_bits(DATA_BITS),
	parameter ENCODED_BITS = DATA_BITS + HAMMING_BITS + 1
)(
	input 	wire[ENCODED_BITS-1:0] 	encoded,
	output 	wire[DATA_BITS-1:0]		data,
	output 	wire 					invalid,
	output  wire 					corrected
);

	function [HAMMING_BITS-1:0] calc_hamming;
		input [ENCODED_BITS-1:0] bits;
		integer c;
		integer p;
	begin
		calc_hamming = 0;

		for(p = 0; p < HAMMING_BITS; p++)
		begin
			// It's to encoded - 1 because the last bit is just parity
			for (c = 1; c <= ENCODED_BITS - 1; c++)
			begin
				if (|((2**p) & c))
					calc_hamming[p] = calc_hamming[p] ^ bits[c-1];
			end
		end
	end
	endfunction

	function [DATA_BITS-1:0] extract_data;
		input [ENCODED_BITS-1:0] bits;
		integer c;
		integer p;
	begin
		// Transfer data bits to encoded positions
		c = 0;
		p = 0;
		while (c < DATA_BITS)
		begin
			if (2**$clog2(p+1) != p+1)
			begin
				extract_data[c] = bits[p];
				c++;
			end
			p++;
		end
	end
	endfunction


	function [ENCODED_BITS-1:0] correct;
		input [ENCODED_BITS-1:0] bits;
		input [HAMMING_BITS-1:0] hamming_vec;
	begin
		// If there is nothing to correct, hamming vec will be zero and we will flip just
		// the first parity bit, which does not matter
		correct = bits;
		correct[hamming_vec - 1] = ~correct[hamming_vec - 1];
	end
	endfunction

	wire [HAMMING_BITS-1:0] hamming_vec;
	wire 					parity;

	assign hamming_vec = calc_hamming(encoded);
	assign parity = ^encoded;

	// If parity = 1 && hamming_vec != 0 -> Single error
	// If parity = 0 && hamming_vec != 0 -> Double Error
	// We just have to output whether the data is invalid or nothing

	assign corrected = parity & |hamming_vec;
	assign invalid = ~parity & |hamming_vec;

	assign data = extract_data(correct(encoded, hamming_vec));

endmodule