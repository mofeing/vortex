// Calculates a hamming code for 128 bits of data
// It uses 9 check bits (8 for the Hamming(255,247) + 1 extra parity bit)
// It can correct a single bit error and detect double errors. Triple errors
// may be wrongfully corrected.

function integer calculate_hamming_bits;
  input integer databits;
  integer hamming;
begin
  hamming = 1;
  while (2**hamming < hamming + databits + 1)
  	hamming++;

  calculate_hamming_bits = hamming;
end
endfunction

module VX_hamming_enc #(
	parameter DATA_BITS = 15,

	parameter HAMMING_BITS = calculate_hamming_bits(DATA_BITS),
	parameter ENCODED_BITS = DATA_BITS + HAMMING_BITS + 1
)(
	input 	wire[DATA_BITS-1:0]		data,
	output 	wire[ENCODED_BITS-1:0] 	encoded
);

	function [ENCODED_BITS-1:0] encode_hamming;
		input [DATA_BITS-1:0] bits;
		logic [HAMMING_BITS-1:0] hamming_code;
		integer c;
		integer p;

	begin

		encode_hamming = 0;
		hamming_code = 0;

		// Transfer data bits to encoded positions
		c = 0;
		p = 0;
		while (c < DATA_BITS)
		begin
			if (2**$clog2(p+1) != p+1)
			begin
				encode_hamming[p] = bits[c];
				c++;
			end
			p++;
		end

		// All the hamming positions are zero and thus not counted
		for(p = 0; p < HAMMING_BITS; p++)
		begin
			// It's to encoded - 1 because the last bit is just parity
			for (c = 1; c <= ENCODED_BITS - 1; c++)
			begin
				if (|((2**p) & c))
					hamming_code[p] = hamming_code[p] ^ encode_hamming[c];
			end
		end

		// Place hamming bits
		for(p = 0; p < HAMMING_BITS; p++)
		begin
			encode_hamming[2**p - 1] = hamming_code[p];
		end

		// Finally, add the parity bit at the end
		encode_hamming[ENCODED_BITS-1] = ^encode_hamming;
	end
	endfunction

	assign encoded = encode_hamming(data);

endmodule