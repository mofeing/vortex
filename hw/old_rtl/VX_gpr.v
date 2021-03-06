
`include "VX_define.v"

module VX_gpr (
	input wire                  clk,
	input wire                  reset,
	input wire                  valid_write_request,
	VX_gpr_read_inter           VX_gpr_read,
	VX_wb_inter                 VX_writeback_inter,

	output reg[`NT_M1:0][31:0] out_a_reg_data,
	output reg[`NT_M1:0][31:0] out_b_reg_data
);



	wire write_enable;

	
	`ifndef ASIC
		assign write_enable = valid_write_request && ((VX_writeback_inter.wb != 0)) && (VX_writeback_inter.rd != 0);

		byte_enabled_simple_dual_port_ram first_ram(
			.we    (write_enable),
			.clk   (clk),
			.reset (reset),
			.waddr (VX_writeback_inter.rd),
			.raddr1(VX_gpr_read.rs1),
			.raddr2(VX_gpr_read.rs2),
			.be    (VX_writeback_inter.wb_valid),
			.wdata (VX_writeback_inter.write_data),
			.q1    (out_a_reg_data),
			.q2    (out_b_reg_data)
		);

	`else 

		assign write_enable = valid_write_request && ((VX_writeback_inter.wb != 0));


		wire going_to_write = write_enable & (|VX_writeback_inter.wb_valid);


		wire[`NT_M1:0][31:0] write_bit_mask;

		genvar curr_t;
		for (curr_t = 0; curr_t < `NT; curr_t=curr_t+1) begin
			wire local_write = write_enable & VX_writeback_inter.wb_valid[curr_t];
			assign write_bit_mask[curr_t] = {32{~local_write}};
		end



		// wire cenb    = !going_to_write;
		wire cenb    = 0;

		// wire cena_1  = (VX_gpr_read.rs1 == 0);
		// wire cena_2  = (VX_gpr_read.rs2 == 0);
		wire cena_1  = 0;
		wire cena_2  = 0;

		wire[`NT_M1:0][31:0] temp_a;
		wire[`NT_M1:0][31:0] temp_b;


		`ifndef SYN
			genvar thread;
			genvar curr_bit;
			for (thread = 0; thread < `NT; thread = thread + 1)
			begin
				for (curr_bit = 0; curr_bit < 32; curr_bit=curr_bit+1)
				begin
					assign out_a_reg_data[thread][curr_bit] = ((temp_a[thread][curr_bit] === 1'dx) || cena_1 )? 1'b0 : temp_a[thread][curr_bit];
					assign out_b_reg_data[thread][curr_bit] = ((temp_b[thread][curr_bit] === 1'dx) || cena_2) ? 1'b0 : temp_b[thread][curr_bit];
				end
			end

		`else

		assign out_a_reg_data = temp_a;
		assign out_b_reg_data = temp_b;

		`endif 


		wire[`NT_M1:0][31:0] to_write = (VX_writeback_inter.rd != 0) ? VX_writeback_inter.write_data : 0;

		genvar curr_base_thread;
		for (curr_base_thread = 0; curr_base_thread < 'NT; curr_base_thread=curr_base_thread+4)
		begin
			/* verilator lint_off PINCONNECTEMPTY */
		   rf2_32x128_wm1 first_ram (
		         .CENYA(),
		         .AYA(),
		         .CENYB(),
		         .WENYB(),
		         .AYB(),
		         .QA(temp_a[(curr_base_thread+3):(curr_base_thread)]),
		         .SOA(),
		         .SOB(),
		         .CLKA(clk),
		         .CENA(cena_1),
		         .AA(VX_gpr_read.rs1[(curr_base_thread+3):(curr_base_thread)]),
		         .CLKB(clk),
		         .CENB(cenb),
		         .WENB(write_bit_mask[(curr_base_thread+3):(curr_base_thread)]),
		         .AB(VX_writeback_inter.rd[(curr_base_thread+3):(curr_base_thread)]),
		         .DB(to_write[(curr_base_thread+3):(curr_base_thread)]),
		         .EMAA(3'b011),
		         .EMASA(1'b0),
		         .EMAB(3'b011),
		         .TENA(1'b1),
		         .TCENA(1'b0),
		         .TAA(5'b0),
		         .TENB(1'b1),
		         .TCENB(1'b0),
		         .TWENB(128'b0),
		         .TAB(5'b0),
		         .TDB(128'b0),
		         .RET1N(1'b1),
		         .SIA(2'b0),
		         .SEA(1'b0),
		         .DFTRAMBYP(1'b0),
		         .SIB(2'b0),
		         .SEB(1'b0),
		         .COLLDISN(1'b1)
		   );
		   /* verilator lint_on PINCONNECTEMPTY */

		   /* verilator lint_off PINCONNECTEMPTY */
		   rf2_32x128_wm1 second_ram (
		         .CENYA(),
		         .AYA(),
		         .CENYB(),
		         .WENYB(),
		         .AYB(),
		         .QA(temp_b[(curr_base_thread+3):(curr_base_thread)]),
		         .SOA(),
		         .SOB(),
		         .CLKA(clk),
		         .CENA(cena_2),
		         .AA(VX_gpr_read.rs2[(curr_base_thread+3):(curr_base_thread)]),
		         .CLKB(clk),
		         .CENB(cenb),
		         .WENB(write_bit_mask[(curr_base_thread+3):(curr_base_thread)]),
		         .AB(VX_writeback_inter.rd[(curr_base_thread+3):(curr_base_thread)]),
		         .DB(to_write[(curr_base_thread+3):(curr_base_thread)]),
		         .EMAA(3'b011),
		         .EMASA(1'b0),
		         .EMAB(3'b011),
		         .TENA(1'b1),
		         .TCENA(1'b0),
		         .TAA(5'b0),
		         .TENB(1'b1),
		         .TCENB(1'b0),
		         .TWENB(128'b0),
		         .TAB(5'b0),
		         .TDB(128'b0),
		         .RET1N(1'b1),
		         .SIA(2'b0),
		         .SEA(1'b0),
		         .DFTRAMBYP(1'b0),
		         .SIB(2'b0),
		         .SEB(1'b0),
		         .COLLDISN(1'b1)
		   );
		   /* verilator lint_on PINCONNECTEMPTY */
		end

	`endif

endmodule
