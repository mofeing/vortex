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
	parameter DATA_BITS = 128,

	parameter HAMMING_BITS = calculate_hamming_bits(DATA_BITS),
	parameter ENCODED_BITS = DATA_BITS + HAMMING_BITS + 1
)(
	input 	wire[DATA_BITS-1:0]		data,
	output 	wire[ENCODED_BITS-1:0] 	encoded
);

	function [ENCODED_BITS-1:0] encode_hamming;
		input [DATA_BITS-1:0] bits;
	begin
		encode_hamming = 0;

		for(p = 0; p < HAMMING_BITS; p++)
		begin
			for (c = 1; c <= DATA_BITS; c++)
			begin
				if (|((2**p) & c))
					encode_hamming[2**p] = encode_hamming[2**p] ^ bits[c];
			end
		end
	end
	endfunction

	encode_hamming = 0;

	assign encoded = encoded_tmp;


	int p, c;

	for(p = 0; p < HAMMING_BITS; p++)
	begin
		for (c = 0; c < DATA_BITS; c++)
		begin
		end
	end

	assign encoded = encoded_tmp;
endmodule