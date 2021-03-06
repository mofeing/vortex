`include "VX_define.vh"

module VX_mem_unit # (
    parameter CORE_ID = 0
) (
    `SCOPE_SIGNALS_CACHE_IO

    input wire              clk,
    input wire              reset,
	input wire 				reseed,

    // Core <-> Dcache
    VX_cache_core_req_if    core_dcache_req_if,
    VX_cache_core_rsp_if    core_dcache_rsp_if,

    // Dram <-> Dcache
    VX_cache_dram_req_if    dcache_dram_req_if,
    VX_cache_dram_rsp_if    dcache_dram_rsp_if,
    VX_cache_snp_req_if     dcache_snp_req_if,
    VX_cache_snp_rsp_if     dcache_snp_rsp_if,

    // Core <-> Icache
    VX_cache_core_req_if    core_icache_req_if,
    VX_cache_core_rsp_if    core_icache_rsp_if,

    // Dram <-> Icache
    VX_cache_dram_req_if    icache_dram_req_if,
    VX_cache_dram_rsp_if    icache_dram_rsp_if
);
    VX_cache_core_req_if #(
        .NUM_REQUESTS       (`DNUM_REQUESTS),
        .WORD_SIZE          (`DWORD_SIZE),
        .CORE_TAG_WIDTH     (`DCORE_TAG_WIDTH),
        .CORE_TAG_ID_BITS   (`DCORE_TAG_ID_BITS)
    ) core_dcache_req_qual_if(), core_smem_req_if();

    VX_cache_core_rsp_if #(
        .NUM_REQUESTS       (`DNUM_REQUESTS),
        .WORD_SIZE          (`DWORD_SIZE),
        .CORE_TAG_WIDTH     (`DCORE_TAG_WIDTH),
        .CORE_TAG_ID_BITS   (`DCORE_TAG_ID_BITS)
    ) core_dcache_rsp_qual_if(), core_smem_rsp_if();

    // select shared memory bus
    wire is_smem_addr    = (({core_dcache_req_if.addr[0], 2'b0} - `SHARED_MEM_BASE_ADDR) <= `SCACHE_SIZE);
    wire smem_req_select = (| core_dcache_req_if.valid) ? is_smem_addr : 0;
    wire smem_rsp_select = (| core_smem_rsp_if.valid);

    VX_dcache_arb dcache_smem_arb (
        .core_req_in_if   (core_dcache_req_if),
        .core_req_out0_if (core_dcache_req_qual_if),
        .core_req_out1_if (core_smem_req_if),
        .core_rsp_in0_if  (core_dcache_rsp_qual_if),
        .core_rsp_in1_if  (core_smem_rsp_if),
        .core_rsp_out_if  (core_dcache_rsp_if),
        .select_req       (smem_req_select),
        .select_rsp       (smem_rsp_select)
    );

    VX_cache #(
        .CACHE_ID               (`SCACHE_ID),
        .CACHE_SIZE             (`SCACHE_SIZE),
        .BANK_LINE_SIZE         (`SBANK_LINE_SIZE),
        .NUM_BANKS              (`SNUM_BANKS),
        .WORD_SIZE              (`SWORD_SIZE),
        .NUM_REQUESTS           (`SNUM_REQUESTS),
        .SPLIT_CAPABLE          (0),
        .CREQ_SIZE              (`SCREQ_SIZE),
        .MRVQ_SIZE              (8),
        .DFPQ_SIZE              (1),
        .SNRQ_SIZE              (1),
        .CWBQ_SIZE              (`SCWBQ_SIZE),
        .DWBQ_SIZE              (1),
        .DFQQ_SIZE              (1),
        .SNOOP_FORWARDING       (0),
        .DRAM_ENABLE            (0),
        .WRITE_ENABLE           (1),
        .CORE_TAG_WIDTH         (`DCORE_TAG_WIDTH),
        .CORE_TAG_ID_BITS       (`DCORE_TAG_ID_BITS),
        .DRAM_TAG_WIDTH         (`SDRAM_TAG_WIDTH),
		.IS_RANDOM_PLACED		(0)
    ) smem (
        `SCOPE_SIGNALS_CACHE_UNBIND

        .clk                (clk),
        .reset              (reset),
		.reseed				(0),

        // Core request
        .core_req_valid     (core_smem_req_if.valid),
        .core_req_rw        (core_smem_req_if.rw),
        .core_req_byteen    (core_smem_req_if.byteen),
        .core_req_addr      (core_smem_req_if.addr),
        .core_req_data      (core_smem_req_if.data),
        .core_req_tag       (core_smem_req_if.tag),
        .core_req_ready     (core_smem_req_if.ready),

        // Core response
        .core_rsp_valid     (core_smem_rsp_if.valid),
        .core_rsp_data      (core_smem_rsp_if.data),
        .core_rsp_tag       (core_smem_rsp_if.tag),
        .core_rsp_ready     (core_smem_rsp_if.ready),

        // Split signal
        `UNUSED_PIN (split_en),

        // DRAM request
        `UNUSED_PIN (dram_req_valid),
        `UNUSED_PIN (dram_req_rw),
        `UNUSED_PIN (dram_req_byteen),
        `UNUSED_PIN (dram_req_addr),
        `UNUSED_PIN (dram_req_data),
        `UNUSED_PIN (dram_req_tag),
        .dram_req_ready     (0),

        // DRAM response
        .dram_rsp_valid     (0),
        .dram_rsp_data      (0),
        .dram_rsp_tag       (0),
        `UNUSED_PIN (dram_rsp_ready),

        // Snoop request
        .snp_req_valid      (0),
        .snp_req_addr       (0),
        .snp_req_invalidate (0),
        .snp_req_tag        (0),
        `UNUSED_PIN (snp_req_ready),

        // Snoop response
        `UNUSED_PIN (snp_rsp_valid),
        `UNUSED_PIN (snp_rsp_tag),
        .snp_rsp_ready      (0),

        // Snoop forward out
        `UNUSED_PIN (snp_fwdout_valid),
        `UNUSED_PIN (snp_fwdout_addr),
        `UNUSED_PIN (snp_fwdout_invalidate),
        `UNUSED_PIN (snp_fwdout_tag),
        .snp_fwdout_ready   (0),

         // Snoop forward in
        .snp_fwdin_valid    (0),
        .snp_fwdin_tag      (0),
        `UNUSED_PIN (snp_fwdin_ready)
    );

    VX_cache #(
        .CACHE_ID               (`DCACHE_ID),
        .CACHE_SIZE             (`DCACHE_SIZE),
        .BANK_LINE_SIZE         (`DBANK_LINE_SIZE),
        .NUM_BANKS              (`DNUM_BANKS),
        .WORD_SIZE              (`DWORD_SIZE),
        .NUM_REQUESTS           (`DNUM_REQUESTS),
        .SPLIT_CAPABLE          (0),
        .CREQ_SIZE              (`DCREQ_SIZE),
        .MRVQ_SIZE              (`DMRVQ_SIZE),
        .DFPQ_SIZE              (`DDFPQ_SIZE),
        .SNRQ_SIZE              (`DSNRQ_SIZE),
        .CWBQ_SIZE              (`DCWBQ_SIZE),
        .DWBQ_SIZE              (`DDWBQ_SIZE),
        .DFQQ_SIZE              (`DDFQQ_SIZE),
        .SNOOP_FORWARDING       (0),
        .DRAM_ENABLE            (1),
        .WRITE_ENABLE           (1),
        .CORE_TAG_WIDTH         (`DCORE_TAG_WIDTH),
        .CORE_TAG_ID_BITS       (`DCORE_TAG_ID_BITS),
        .DRAM_TAG_WIDTH         (`DDRAM_TAG_WIDTH),
        .SNP_REQ_TAG_WIDTH      (`DSNP_TAG_WIDTH),
		.IS_RANDOM_PLACED		(0)
    ) dcache (
        `SCOPE_SIGNALS_CACHE_BIND

        .clk                (clk),
        .reset              (reset),
		.reseed				(reseed),

        // Core req
        .core_req_valid     (core_dcache_req_qual_if.valid),
        .core_req_rw        (core_dcache_req_qual_if.rw),
        .core_req_byteen    (core_dcache_req_qual_if.byteen),
        .core_req_addr      (core_dcache_req_qual_if.addr),
        .core_req_data      (core_dcache_req_qual_if.data),
        .core_req_tag       (core_dcache_req_qual_if.tag),
        .core_req_ready     (core_dcache_req_qual_if.ready),

        // Core response
        .core_rsp_valid     (core_dcache_rsp_qual_if.valid),
        .core_rsp_data      (core_dcache_rsp_qual_if.data),
        .core_rsp_tag       (core_dcache_rsp_qual_if.tag),
        .core_rsp_ready     (core_dcache_rsp_qual_if.ready),

        // Split signal
        `UNUSED_PIN (split_en),

        // DRAM request
        .dram_req_valid     (dcache_dram_req_if.valid),
        .dram_req_rw        (dcache_dram_req_if.rw),
        .dram_req_byteen    (dcache_dram_req_if.byteen),
        .dram_req_addr      (dcache_dram_req_if.addr),
        .dram_req_data      (dcache_dram_req_if.data),
        .dram_req_tag       (dcache_dram_req_if.tag),
        .dram_req_ready     (dcache_dram_req_if.ready),

        // DRAM response
        .dram_rsp_valid     (dcache_dram_rsp_if.valid),
        .dram_rsp_data      (dcache_dram_rsp_if.data),
        .dram_rsp_tag       (dcache_dram_rsp_if.tag),
        .dram_rsp_ready     (dcache_dram_rsp_if.ready),

        // Snoop request
        .snp_req_valid      (dcache_snp_req_if.valid),
        .snp_req_addr       (dcache_snp_req_if.addr),
        .snp_req_invalidate (dcache_snp_req_if.invalidate),
        .snp_req_tag        (dcache_snp_req_if.tag),
        .snp_req_ready      (dcache_snp_req_if.ready),

        // Snoop response
        .snp_rsp_valid      (dcache_snp_rsp_if.valid),
        .snp_rsp_tag        (dcache_snp_rsp_if.tag),
        .snp_rsp_ready      (dcache_snp_rsp_if.ready),

        // Snoop forward out
        `UNUSED_PIN (snp_fwdout_valid),
        `UNUSED_PIN (snp_fwdout_addr),
        `UNUSED_PIN (snp_fwdout_invalidate),
        `UNUSED_PIN (snp_fwdout_tag),
        .snp_fwdout_ready   (0),

         // Snoop forward in
        .snp_fwdin_valid    (0),
        .snp_fwdin_tag      (0),
        `UNUSED_PIN (snp_fwdin_ready)
    );

    VX_cache #(
        .CACHE_ID               (`ICACHE_ID),
        .CACHE_SIZE             (`ICACHE_SIZE),
        .BANK_LINE_SIZE         (`IBANK_LINE_SIZE),
        .NUM_BANKS              (`INUM_BANKS),
        .WORD_SIZE              (`IWORD_SIZE),
        .NUM_REQUESTS           (`INUM_REQUESTS),
        .SPLIT_CAPABLE          (0),
        .CREQ_SIZE              (`ICREQ_SIZE),
        .MRVQ_SIZE              (`IMRVQ_SIZE),
        .DFPQ_SIZE              (`IDFPQ_SIZE),
        .SNRQ_SIZE              (1),
        .CWBQ_SIZE              (`ICWBQ_SIZE),
        .DWBQ_SIZE              (`IDWBQ_SIZE),
        .DFQQ_SIZE              (`IDFQQ_SIZE),
        .SNOOP_FORWARDING       (0),
        .DRAM_ENABLE            (1),
        .WRITE_ENABLE           (0),
        .CORE_TAG_WIDTH         (`ICORE_TAG_WIDTH),
        .CORE_TAG_ID_BITS       (`ICORE_TAG_ID_BITS),
        .DRAM_TAG_WIDTH         (`IDRAM_TAG_WIDTH),
		.IS_RANDOM_PLACED		(0)
    ) icache (
        `SCOPE_SIGNALS_CACHE_UNBIND

        .clk                   (clk),
        .reset                 (reset),
		.reseed				   (0),

        // Core request
        .core_req_valid        (core_icache_req_if.valid),
        .core_req_rw           (core_icache_req_if.rw),
        .core_req_byteen       (core_icache_req_if.byteen),
        .core_req_addr         (core_icache_req_if.addr),
        .core_req_data         (core_icache_req_if.data),
        .core_req_tag          (core_icache_req_if.tag),
        .core_req_ready        (core_icache_req_if.ready),

        // Core response
        .core_rsp_valid        (core_icache_rsp_if.valid),
        .core_rsp_data         (core_icache_rsp_if.data),
        .core_rsp_tag          (core_icache_rsp_if.tag),
        .core_rsp_ready        (core_icache_rsp_if.ready),

        // Split signal
        `UNUSED_PIN (split_en),

        // DRAM Req
        .dram_req_valid        (icache_dram_req_if.valid),
        .dram_req_rw           (icache_dram_req_if.rw),
        .dram_req_byteen       (icache_dram_req_if.byteen),
        .dram_req_addr         (icache_dram_req_if.addr),
        .dram_req_data         (icache_dram_req_if.data),
        .dram_req_tag          (icache_dram_req_if.tag),
        .dram_req_ready        (icache_dram_req_if.ready),

        // DRAM response
        .dram_rsp_valid        (icache_dram_rsp_if.valid),
        .dram_rsp_data         (icache_dram_rsp_if.data),
        .dram_rsp_tag          (icache_dram_rsp_if.tag),
        .dram_rsp_ready        (icache_dram_rsp_if.ready),

        // Snoop request
        .snp_req_valid         (0),
        .snp_req_addr          (0),
        .snp_req_invalidate    (0),
        .snp_req_tag           (0),
        `UNUSED_PIN (snp_req_ready),

        // Snoop response
        `UNUSED_PIN (snp_rsp_valid),
        `UNUSED_PIN (snp_rsp_tag),
        .snp_rsp_ready         (0),

        // Snoop forward out
        `UNUSED_PIN (snp_fwdout_valid),
        `UNUSED_PIN (snp_fwdout_addr),
        `UNUSED_PIN (snp_fwdout_invalidate),
        `UNUSED_PIN (snp_fwdout_tag),
        .snp_fwdout_ready      (0),

         // Snoop forward in
        .snp_fwdin_valid       (0),
        .snp_fwdin_tag         (0),
        `UNUSED_PIN (snp_fwdin_ready)
    );

endmodule
