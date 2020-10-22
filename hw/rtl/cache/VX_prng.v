module VX_prng #(
	parameter SEED = 0,

	// #randomness bits
	parameter NBITS = 168,

	// #output bits
	parameter NNUM = 2,
)(
	input wire clk,
	input wire reset,

	output wire rnd[NNUM-1:0];
);

reg [NBITS-1:0] lsfr;
wire [NNUM-1:0][3:0] xnor_in;
wire [NNUM-1:0] xnor_out;

assign xnor_out = rnd;

for (i = 0; i < NNUM; i++) begin
	assign xnor_in[i][0] = lsfr[NBITS - NNUM + i];
	assign xnor_in[i][1] = lsfr[NBITS - NNUM + i - 2];
	assign xnor_in[i][2] = lsfr[NBITS - NNUM + i - 15];
	assign xnor_in[i][3] = lsfr[NBITS - NNUM + i - 17];

	assign xnor_out[i] = xnor(xnor_in[i][3:0]);
end

always @(posedge clk) begin
	if (reset) lsfr = SEED;
	else begin
		for (i = NBITS-1; i >= NNUM; i--)
			lsfr[i] = lsfr[i-1];
		for (i = NNUM-1; i >= 0; i--)
			lsfr[i] = xnor_out[i];
	end
end

endmodule