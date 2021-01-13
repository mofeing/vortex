`include "VX_cache_config.vh"

function integer calculate_encoded_bits;
  input integer databits;
  integer hamming;
begin
  hamming = 1;
  while (2**hamming < hamming + databits + 1)
  	hamming++;

  calculate_encoded_bits = hamming + databits + 1;
end
endfunction

module VX_tag_data_store #(
    // Size of cache in bytes
    parameter CACHE_SIZE                    = 0,
    // Size of line inside a bank in bytes
    parameter BANK_LINE_SIZE                = 0,
    // Number of banks {1, 2, 4, 8,...}
    parameter NUM_BANKS                     = 0,
    // Size of a word in bytes
    parameter WORD_SIZE                     = 0,
	// Total bits of a line with hamming
	parameter TOTAL_LINE_WIDTH 				= calculate_encoded_bits(`BANK_LINE_WIDTH)
) (
    input  wire                             clk,
    input  wire                             reset,
    input  wire                             stall_bank_pipe,

    input  wire[`LINE_SELECT_BITS-1:0]      read_addr,
    output wire                             read_valid,
    output wire                             read_dirty,
    output wire[`BANK_LINE_WORDS-1:0][WORD_SIZE-1:0] read_dirtyb,
    output wire[`TAG_SELECT_BITS-1:0]       read_tag,
    output wire[`BANK_LINE_WIDTH-1:0]       read_data,

    input  wire                             invalidate,
    input  wire[`BANK_LINE_WORDS-1:0][WORD_SIZE-1:0] write_enable,
    input  wire                             write_fill,
    input  wire[`LINE_SELECT_BITS-1:0]      write_addr,
    input  wire[`TAG_SELECT_BITS-1:0]       tag_index,
    input  wire[`BANK_LINE_WIDTH-1:0]       write_data,
    input  wire                             fill_sent
);

    reg [TOTAL_LINE_WIDTH-1:0]                     data [`BANK_LINE_COUNT-1:0];
    reg [`TAG_SELECT_BITS-1:0]                      tag [`BANK_LINE_COUNT-1:0];
    reg [`BANK_LINE_WORDS-1:0][WORD_SIZE-1:0]     dirtyb[`BANK_LINE_COUNT-1:0];
    reg [`BANK_LINE_COUNT-1:0]                     dirty;
    reg [`BANK_LINE_COUNT-1:0]                     valid;

	// Data to write to
	wire [`BANK_LINE_WORDS-1:0][WORD_SIZE-1:0][7:0] write_port_decoded;
	wire [`BANK_LINE_WORDS-1:0][WORD_SIZE-1:0][7:0] data_to_write;
	wire [TOTAL_LINE_WIDTH-1:0] data_to_write_encoded;
	wire read_data_doublefault;
	wire read_data_valid;

	/* verilator lint_off UNUSED */
	wire read_data_corrected;
	wire write_data_corrected, write_data_doublefault;
	/* verilator lint_on UNUSED */

    assign read_dirty  = dirty  [read_addr];
    assign read_dirtyb = dirtyb [read_addr];
    assign read_tag    = tag    [read_addr];
	assign read_data_valid = valid[read_addr];

	// Decoder for reads
	VX_hamming_dec #(
        .DATA_BITS(`BANK_LINE_WIDTH)
	) hamming_dec_read (
        .encoded (data[read_addr]),
		.data(read_data),
		.invalid(read_data_doublefault),
		.corrected(read_data_corrected)
    );

	// Invalidate the line if we detect a double fault
	assign read_valid  = read_data_valid & ~read_data_doublefault;

	// Decoder for writes
	VX_hamming_dec #(
        .DATA_BITS(`BANK_LINE_WIDTH)
	) hamming_dec_write (
        .encoded (data[write_addr]),
		.data(write_port_decoded),
		.invalid(write_data_doublefault),
		.corrected(write_data_corrected)
    );

	for (genvar j = 0; j < `BANK_LINE_WORDS; j++) begin
		for (genvar i = 0; i < WORD_SIZE; i++) begin
			assign data_to_write[j][i] = write_enable[j][i] ? write_data[j * `WORD_WIDTH + i * 8 +: 8] : write_port_decoded[j][i];
		end
	end

	// Encoder for writes
	VX_hamming_enc #(
        .DATA_BITS(`BANK_LINE_WIDTH)
	) hamming_enc (
		.data(data_to_write),
        .encoded (data_to_write_encoded)
    );

    wire do_write = (| write_enable);

    always @(posedge clk) begin
        if (reset) begin
            for (integer i = 0; i < `BANK_LINE_COUNT; i++) begin
                valid[i] <= 0;
                dirty[i] <= 0;
            end
        end else if (!stall_bank_pipe) begin
            if (do_write) begin
                valid[write_addr] <= 1;
                tag  [write_addr] <= tag_index;
                if (write_fill) begin
                    dirty[write_addr]  <= 0;
                    dirtyb[write_addr] <= 0;
                end else begin
                    dirty[write_addr]  <= 1;
                    dirtyb[write_addr] <= dirtyb[write_addr] | write_enable;
                end
				data[write_addr] <= data_to_write_encoded;
            end else if (fill_sent) begin
                dirty[write_addr]  <= 0;
                dirtyb[write_addr] <= 0;
            end

            if (invalidate) begin
                valid[write_addr] <= 0;
            end

        end
    end

endmodule