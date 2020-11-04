module VX_prng #(
	// Certified random number :)
	parameter SEED = 168'hef4a66be741ca34e9143bfa4c10c4b14af2bb26021,

	// #randomness bits
	parameter NBITS = 168,

	// #output bits
	parameter NNUM = 16
) (
	input wire clk,
	input wire reset,

	output wire [NNUM-1:0] rnd
);

reg [NBITS-1:0] lsfr;
wire [NNUM-1:0][3:0] xnor_in;
wire [NNUM-1:0] xnor_out;

assign rnd = xnor_out;

for (genvar i = 0; i < NNUM; i++) begin
	assign xnor_in[i][0] = lsfr[NBITS - NNUM + i];
	assign xnor_in[i][1] = lsfr[NBITS - NNUM + i - 2];
	assign xnor_in[i][2] = lsfr[NBITS - NNUM + i - 15];
	assign xnor_in[i][3] = lsfr[NBITS - NNUM + i - 17];

	assign xnor_out[i] = ~(xnor_in[i][0] ^ xnor_in[i][1] ^ xnor_in[i][2] ^ xnor_in[i][3]);
end

always @(posedge clk) begin
	if (reset) lsfr <= SEED;
	else begin
		for (int i = NBITS-1; i >= NNUM; i--)
			lsfr[i] <= lsfr[i-1];
		for (int i = NNUM-1; i >= 0; i--)
			lsfr[i] <= xnor_out[i];
	end
end

endmodule