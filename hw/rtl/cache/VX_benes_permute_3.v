module VX_benes_permute_3 #(
	parameter N = 3,
	parameter CONTROL = 3
)  (
	input 	wire[N-1:0] 		in,
	input	wire[CONTROL-1:0] 	control,
	output	wire[N-1:0]			out
);

	wire [1:0] input_high;
	wire [1:0] input_lowleft;
	wire [1:0] input_lowright;

	wire [1:0] output_high;
	wire [1:0] output_lowleft;
	wire [1:0] output_lowright;

	// This is essentially 3 benes of 2x2 (basic) interconnected in a certain way.

	assign input_high[1] 		= in[2];
	assign input_high[0] 		= output_lowleft[1];
	assign input_lowleft[1]		= in[1];
	assign input_lowleft[0] 	= in[0];
	assign input_lowright[1] 	= output_high[0];
	assign input_lowright[0] 	= output_lowleft[0];

	assign out[0] = output_lowright[0];
	assign out[1] = output_lowright[1];
	assign out[2] = output_high[1];

	VX_benes_permute #(.N (2), .CONTROL (1))
		benes_permute_high
		(.in(input_high[1:0]),
		.control(control[2]),
		.out(output_high[1:0])
		);

	VX_benes_permute #(.N (2), .CONTROL (1))
		benes_permute_low_left
		(.in(input_lowleft[1:0]),
		.control(control[1]),
		.out(output_lowleft[1:0])
		);

	VX_benes_permute #(.N (2), .CONTROL (1))
		benes_permute_low_right
		(.in(input_lowright[1:0]),
		.control(control[0]),
		.out(output_lowright[1:0])
		);

endmodule
