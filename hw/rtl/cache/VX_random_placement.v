module VX_random_placement #(
	parameter INDEXBITS = 6,
	parameter ADDRESSBITS = 24,
	parameter CONTROLBITS = 12
) (
    input wire                          clk,
    input wire                          reset,
	input wire 							reseed,

/* verilator lint_off UNUSED */
	input wire[ADDRESSBITS-1:0]			raddress,
	input wire[ADDRESSBITS-1:0]			waddress,
/* verilator lint_on UNUSED */
	output wire[INDEXBITS-1:0]			rindex,
	output wire[INDEXBITS-1:0]			windex
);
	// Wire with the output from the PRNG
	wire[CONTROLBITS-1:0] seed_out;

	// Register holding the current seed
	reg[CONTROLBITS-1:0] seed;

	wire[CONTROLBITS-1:0] benes_control_r;
	wire[CONTROLBITS-1:0] benes_control_w;

	// PRNG module
	VX_prng #(.NNUM (CONTROLBITS))
	prng(
		.clk(clk),
		.reset(reset),
		.rnd(seed_out)
	);

	assign benes_control_r[CONTROLBITS-1:0] = raddress[INDEXBITS + CONTROLBITS - 1 : INDEXBITS] ^ seed;
	assign benes_control_w[CONTROLBITS-1:0] = waddress[INDEXBITS + CONTROLBITS - 1 : INDEXBITS] ^ seed;

	VX_benes_permute_6 #() benes_permute_write(
		.in(waddress[INDEXBITS-1:0]),
		.control(benes_control_w),
		.out(windex[INDEXBITS-1:0])
	);

	VX_benes_permute_6 #() benes_permute_read(
		.in(raddress[INDEXBITS-1:0]),
		.control(benes_control_r),
		.out(rindex[INDEXBITS-1:0])
	);

	// Reset and reseed mechanism
	always @(posedge clk) begin
		if (reset)
			seed[CONTROLBITS-1:0] <= {CONTROLBITS{1'b0}};
		else if(reseed)
			seed[CONTROLBITS-1:0] <= seed_out[CONTROLBITS-1:0];
	end
endmodule