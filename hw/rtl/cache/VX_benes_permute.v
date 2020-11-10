
// There is a problem here. Unfortunately, we can only
// generate the benes network for a power of two. This is because of a single
// reason: arbitrary size benes network need to calculate recursively
// the amount of control signals needed, and that is not possible
// with verilator, because it does not support recursive functions.

module VX_benes_permute #(
	parameter N = 8,
	parameter CONTROL = 20
) (
	input 	wire[N-1:0] 		in,
	input	wire[CONTROL-1:0] 	control,
	output	wire[N-1:0]			out
);

	genvar i;

	generate
		if (N == 1) begin
			assign out[0] = in[0];
		end

		else if (N == 2) begin
			assign out[0] = in[control[0]];
			assign out[1] = in[~control[0]];
		end

		else begin
			`define HALF_N (N/2)
			`define HALF_CONTROL ((CONTROL - N) / 2)
			`define CONTROL_START (CONTROL - N)

			wire[N-1:0] in_after_entry;
			wire[N-1:0] out_after_exit;
			wire[N-1:0] control_own;
			wire[`HALF_N-1:0] in_high_half;
			wire[`HALF_N-1:0] in_low_half;
			wire[`HALF_N-1:0] out_high_half;
			wire[`HALF_N-1:0] out_low_half;
			wire[`HALF_CONTROL-1:0] control_high_half;
			wire[`HALF_CONTROL-1:0] control_low_half;

			assign control_own[N-1:0] = control[CONTROL-1:`CONTROL_START];

			for (i = 0; i < N; i += 2) begin
				// Assume everything is even for now
				assign in_after_entry[i] = (control_own[i]) ? in[i+1] : in[i];
				assign in_after_entry[i+1] = (control_own[i]) ? in[i] : in[i+1];

				assign in_low_half[i/2] = in_after_entry[i];
				assign in_high_half[i/2] = in_after_entry[i+1];

				assign out_after_exit[i] = out_low_half[i/2];
				assign out_after_exit[i+1] = out_high_half[i/2];

				assign out[i] = (control_own[i+1]) ? out_after_exit[i+1] : out_after_exit[i];
				assign out[i+1] = (control_own[i+1]) ? out_after_exit[i] : out_after_exit[i+1];
			end

			assign in_high_half[`HALF_N-1:0] = in_after_entry[N-1:`HALF_N];
			assign in_low_half[`HALF_N-1:0] = in_after_entry[`HALF_N-1:0];

			assign out_after_exit[N-1:`HALF_N] = out_high_half[`HALF_N-1:0];
			assign out_after_exit[`HALF_N-1:0] = out_low_half[`HALF_N-1:0];
			assign control_high_half[`HALF_CONTROL-1:0] = control[(`CONTROL_START - 1):`HALF_CONTROL];
			assign control_low_half[`HALF_CONTROL-1:0] = control[`HALF_CONTROL-1:0];

		 	VX_benes_permute #(.N `HALF_N, .CONTROL `HALF_CONTROL)
			 benes_permute_high_half
			 (.in(in_high_half[`HALF_N-1:0]),
			  .control(control_high_half[`HALF_CONTROL-1:0]),
			  .out(out_high_half[`HALF_N-1:0])
			 );

			VX_benes_permute #(.N `HALF_N, .CONTROL `HALF_CONTROL)
			 benes_permute_low_half
			 (.in(in_low_half[`HALF_N-1:0]),
			  .control(control_low_half[`HALF_CONTROL-1:0]),
			  .out(out_low_half[`HALF_N-1:0])
			 );

		end

	endgenerate

endmodule