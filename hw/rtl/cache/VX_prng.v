module VX_prng #(
	parameter SEED = 0,
	parameter NBITS = 8,
	parameter NNUM = 16,
)(
	input wire clk,
	input wire reset,

	output wire num[NNUM-1:0];
	// output wire other[NBITS-1:NNUM];
);

reg [NNUM-1:0] counter;

always @(posedge clk) begin
	if (reset) begin
		counter = SEED;
	end
end

always @(posedge clk) begin
	counter <= counter + 1;
end

// 53831 is just a prime number
num = (53831 * counter) % (2**NBITS);

endmodule