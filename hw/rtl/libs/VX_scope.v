`include "VX_platform.vh"

module VX_scope #(     
	parameter DATAW  = 64, 
	parameter BUSW   = 64, 
	parameter SIZE   = 16,
	parameter UPDW   = 1,
	parameter DELTAW = 16
) ( 
	input wire clk,
	input wire reset,
	input wire start,
	input wire stop,
	input wire changed,
	input wire [DATAW-1:0] data_in,
	input wire [BUSW-1:0]  bus_in,
	output wire [BUSW-1:0] bus_out,	
	input wire bus_write,
	input wire bus_read
);
	localparam DELTA_ENABLE  = (UPDW != 0);
	localparam MAX_DELTA     = (2 ** DELTAW) - 1;

	localparam CMD_GET_VALID = 3'd0;
	localparam CMD_GET_DATA  = 3'd1;
	localparam CMD_GET_WIDTH = 3'd2;
	localparam CMD_GET_COUNT = 3'd3;
	localparam CMD_SET_DELAY = 3'd4;
	localparam CMD_SET_STOP  = 3'd5;
	localparam CMD_RESERVED1 = 3'd6;
	localparam CMD_RESERVED2 = 3'd7;

	localparam GET_VALID = 2'd0;
	localparam GET_DATA  = 2'd1;
	localparam GET_WIDTH = 2'd2;
	localparam GET_COUNT = 2'd3;

	reg [DATAW-1:0] data_store [SIZE-1:0];
	reg [DELTAW-1:0] delta_store [SIZE-1:0];
	reg [UPDW-1:0] prev_trigger_id;
	reg [DELTAW-1:0] delta;
	reg [BUSW-1:0]  bus_out_r;	

	reg [`CLOG2(SIZE)-1:0] raddr, waddr, waddr_end;

	reg [`LOG2UP(DATAW)-1:0] read_offset;

	reg start_wait, recording, data_valid, read_delta, started, delta_flush;

	reg [BUSW-3:0] delay_val, delay_cntr;

	reg [1:0] out_cmd;

	wire [2:0] cmd_type;
	wire [BUSW-4:0] cmd_data;
	assign {cmd_data, cmd_type} = bus_in;

	wire [UPDW-1:0] trigger_id = data_in[UPDW-1:0];

	always @(posedge clk) begin
		if (reset) begin
			out_cmd     	<= $bits(out_cmd)'(CMD_GET_VALID);
			raddr      		<= 0;	
			waddr      		<= 0;	
			waddr_end   	<= $bits(waddr)'(SIZE-1);
			started     	<= 0;
			start_wait 		<= 0;
			recording   	<= 0;
			delay_val   	<= 0;
			delay_cntr 		<= 0;
			delta       	<= 0;
			delta_flush     <= 0;
			prev_trigger_id <= 0;
			read_offset		<= 0;
			read_delta  	<= 0;
			data_valid  	<= 0;
		end else begin
			if (bus_write) begin
				case (cmd_type)
					CMD_GET_VALID, 
					CMD_GET_DATA, 
					CMD_GET_WIDTH, 
				    CMD_GET_COUNT:   out_cmd <= $bits(out_cmd)'(cmd_type); 
					CMD_SET_DELAY: delay_val <= $bits(delay_val)'(cmd_data);
		            CMD_SET_STOP:  waddr_end <= $bits(waddr)'(cmd_data);
				    default:;
				endcase				
			end

			if (start && !started) begin		
				started     <= 1;
				delta_flush <= 1;	
				if (0 == delay_val) begin					
					start_wait  <= 0;
					recording   <= 1;
					delay_cntr  <= 0;					
				end else begin
					start_wait <= 1;
					recording  <= 0;
					delay_cntr <= delay_val;							
				end
			end

			if (start_wait) begin				
				delay_cntr <= delay_cntr - 1;
				if (1 == delay_cntr) begin				
					start_wait <= 0;
					recording  <= 1;
				end 
			end

			if (recording) begin
				if (DELTA_ENABLE) begin
					if (delta_flush
					 || changed
					 || (trigger_id != prev_trigger_id)) begin
						data_store[waddr]  <= data_in;
						delta_store[waddr] <= delta;
						waddr       <= waddr + 1;
						delta       <= 0;
						delta_flush <= 0;
					end else begin
						delta       <= delta + 1;
						delta_flush <= (delta == (MAX_DELTA-1));
					end
					prev_trigger_id <= trigger_id;
				end else begin
					data_store[waddr] <= data_in;
					waddr <= waddr + 1;
				end

				if (stop 
				 || (waddr >= waddr_end)) begin
					waddr      <= waddr;  // keep last address
					recording  <= 0;
					data_valid <= 1;
					read_delta <= DELTA_ENABLE;					
				end
			end

			if (bus_read 			 
			 && (out_cmd == GET_DATA)
			 && data_valid)  begin
				if (read_delta) begin
					read_delta <= 0; 
				end else begin
					if (DATAW > BUSW) begin
						if (read_offset < $bits(read_offset)'(DATAW-BUSW)) begin
							read_offset <= read_offset + $bits(read_offset)'(BUSW);
						end else begin
							raddr       <= raddr + 1;
							read_offset <= 0;							
							read_delta  <= DELTA_ENABLE; 
							if (raddr == waddr) begin
								data_valid <= 0;
							end
						end					
					end else begin
						raddr <= raddr + 1;					
						read_delta <= DELTA_ENABLE; 
						if (raddr == waddr) begin
							data_valid <= 0;
						end
					end
				end				
			end
		end		
	end

	always @(*) begin
		case (out_cmd)
			GET_VALID : bus_out_r = BUSW'(data_valid);
			GET_WIDTH : bus_out_r = BUSW'(DATAW);
			GET_COUNT : bus_out_r = BUSW'(waddr) + BUSW'(1);
			GET_DATA  : bus_out_r = read_delta ? BUSW'(delta_store[raddr]) : BUSW'(data_store[raddr] >> read_offset);
			default   : bus_out_r = 0;  
		endcase
	end

	assign bus_out = bus_out_r;

`ifdef DBG_PRINT_SCOPE
	always @(posedge clk) begin
		if (bus_read) begin
			$display("%t: scope-read: cmd=%0d, out=%0h, addr=%0d", $time, out_cmd, bus_out, raddr);
		end
		if (bus_write) begin
			$display("%t: scope-write: cmd=%0d, value=%0d", $time, cmd_type, cmd_data);
		end
	end
`endif

endmodule