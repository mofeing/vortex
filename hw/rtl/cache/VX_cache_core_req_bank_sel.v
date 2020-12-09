`include "VX_cache_config.vh"
`define max2(v1, v2) ((v1) > (v2) ? (v1) : (v2))

module VX_cache_core_req_bank_sel #(
    // Size of line inside a bank in bytes
    parameter BANK_LINE_SIZE                = 0,
    // Size of a word in bytes
    parameter WORD_SIZE                     = 0,
    // Number of banks {1, 2, 4, 8,...}
    parameter NUM_BANKS                     = 0,
    // Number of Word requests per cycle {1, 2, 4, 8, ...}
    parameter NUM_REQUESTS                  = 0,
    // Cache-split capable
    parameter SPLIT_CAPABLE                 = 0
) (
    input  wire [NUM_REQUESTS-1:0]                       core_req_valid,
`IGNORE_WARNINGS_BEGIN
    input  wire [NUM_REQUESTS-1:0][`WORD_ADDR_WIDTH-1:0] core_req_addr,
`IGNORE_WARNINGS_END
    /* verilator lint_off UNUSED */
    input  wire                                          split_en,
    /* verilator lint_on UNUSED */
    input  wire [NUM_BANKS-1:0]                          per_bank_ready,
    output wire [NUM_BANKS-1:0][NUM_REQUESTS-1:0]        per_bank_valid,
    output wire                                          core_req_ready
);
    reg  [NUM_BANKS-1:0][NUM_REQUESTS-1:0] per_bank_valid_r;
`IGNORE_WARNINGS_BEGIN
	reg  [NUM_REQUESTS-1:0][`max2(`CLOG2(NUM_BANKS)-1, 0):0] bank;
`IGNORE_WARNINGS_END

    generate
        if (SPLIT_CAPABLE != 0) begin
            if (NUM_BANKS % NUM_REQUESTS != 0) $error("NUM_BANKS=%d must be multiple of NUM_REQUESTS=%d in order for cache splitting to work", NUM_BANKS, NUM_REQUESTS);
            if (!`ISPOW2(NUM_BANKS / NUM_REQUESTS)) $error("NUM_BANKS/NUM_REQUESTS=%d must be a power of 2", NUM_BANKS/NUM_REQUESTS);

            if (NUM_BANKS == NUM_REQUESTS) begin
                always @(*) begin
                    for (integer i = 0; i < NUM_REQUESTS; i++) begin
                        if (split_en) bank[i] = i[`CLOG2(NUM_BANKS)-1:0];
                        else bank[i] = core_req_addr[i][`BANK_SELECT_ADDR_RNG];
                    end
                end
            end else begin
                always @(*) begin
                    for (integer i = 0; i < NUM_REQUESTS; i++) begin
                        if (split_en) bank[i] = {i[`CLOG2(NUM_REQUESTS)-1:0], core_req_addr[i][`BANK_SELECT_ADDR_SPLIT]};
                        else bank[i] = core_req_addr[i][`BANK_SELECT_ADDR_RNG];
                    end
                end
            end
        end
    endgenerate

    if (NUM_BANKS == 1) begin
        always @(*) begin
            per_bank_valid_r = 0;
            for (integer i = 0; i < NUM_REQUESTS; i++) begin
                per_bank_valid_r[0][i] = core_req_valid[i];
            end
        end
        assign core_req_ready = per_bank_ready;
    end else if (SPLIT_CAPABLE != 0) begin
        reg [NUM_BANKS-1:0] per_bank_ready_sel;
        always @(*) begin
            per_bank_valid_r = 0;
            per_bank_ready_sel = {NUM_BANKS{1'b1}};
            for (integer i = 0; i < NUM_REQUESTS; i++) begin
                per_bank_valid_r[bank[i]][i] = core_req_valid[i];
                per_bank_ready_sel[bank[i]] = 0;
            end
        end
        assign core_req_ready = & (per_bank_ready | per_bank_ready_sel);
    end else begin
        reg [NUM_BANKS-1:0] per_bank_ready_sel;
        always @(*) begin
            per_bank_valid_r = 0;
            per_bank_ready_sel = {NUM_BANKS{1'b1}};
            for (integer i = 0; i < NUM_REQUESTS; i++) begin
                per_bank_valid_r[core_req_addr[i][`BANK_SELECT_ADDR_RNG]][i] = core_req_valid[i];
                per_bank_ready_sel[core_req_addr[i][`BANK_SELECT_ADDR_RNG]] = 0;
            end
        end
        assign core_req_ready = & (per_bank_ready | per_bank_ready_sel);
    end

    assign per_bank_valid = per_bank_valid_r;

endmodule