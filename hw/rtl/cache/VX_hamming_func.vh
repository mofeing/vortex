`ifndef VX_HAMMING_FUNC_HEADER
   `define VX_HAMMING_FUNC_HEADER


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

`endif