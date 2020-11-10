module VX_benes_permute_6 #(
	parameter N = 6,
	parameter CONTROL = 12
) (
	input 	wire[N-1:0] 		in,
	input	wire[CONTROL-1:0] 	control,
	output	wire[N-1:0]			out
);
	`define UPPER_N 3
	`define LOWER_N 3
	`define UPPER_CONTROL 3
	`define LOWER_CONTROL 3
	`define OWN_CONTROL_START (`UPPER_CONTROL + `LOWER_CONTROL)

	genvar i;
	generate

		wire[N-1:0] in_after_entry;
		wire[N-1:0] out_after_exit;
		wire[N-1:0] control_own;
		wire[`UPPER_N-1:0] in_high_half;
		wire[`LOWER_N-1:0] in_low_half;
		wire[`UPPER_N-1:0] out_high_half;
		wire[`LOWER_N-1:0] out_low_half;
		wire[`UPPER_CONTROL-1:0] control_high_half;
		wire[`LOWER_CONTROL-1:0] control_low_half;

		assign control_own[N-1:0] = control[CONTROL-1:`OWN_CONTROL_START];

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

		assign in_high_half[`UPPER_N-1:0] = in_after_entry[N-1:`LOWER_N];
		assign in_low_half[`LOWER_N-1:0] = in_after_entry[`LOWER_N-1:0];
		assign out_after_exit[N-1:`LOWER_N] = out_high_half[`UPPER_N-1:0];
		assign out_after_exit[`LOWER_N-1:0] = out_low_half[`LOWER_N-1:0];
		assign control_high_half[`UPPER_CONTROL-1:0] = control[(`OWN_CONTROL_START - 1):`LOWER_CONTROL];
		assign control_low_half[`LOWER_CONTROL-1:0] = control[`UPPER_CONTROL-1:0];

		VX_benes_permute_3 #()
			benes_permute_high_half
			(.in(in_high_half[`UPPER_N-1:0]),
			.control(control_high_half[`UPPER_CONTROL-1:0]),
			.out(out_high_half[`UPPER_N-1:0])
			);

		VX_benes_permute_3 #()
			benes_permute_low_half
			(.in(in_low_half[`LOWER_N-1:0]),
			.control(control_low_half[`LOWER_CONTROL-1:0]),
			.out(out_low_half[`LOWER_N-1:0])
			);
	endgenerate
endmodule