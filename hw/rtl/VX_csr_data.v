`include "VX_define.vh"

module VX_csr_data #(
    parameter CORE_ID = 0
) (
    input wire clk,
    input wire reset,

    VX_cmt_to_csr_if                cmt_to_csr_if,
    VX_csr_to_issue_if              csr_to_issue_if,  

    input wire                      read_enable,
    input wire[`CSR_ADDR_BITS-1:0]  read_addr,
    input wire[`NW_BITS-1:0]        read_wid,
    output wire[31:0]               read_data,

    input wire                      write_enable, 
    input wire[`CSR_ADDR_BITS-1:0]  write_addr,
    input wire[`NW_BITS-1:0]        write_wid,
    input wire[`CSR_WIDTH-1:0]      write_data
);
    reg [`CSR_WIDTH-1:0] csr_satp;
    reg [`CSR_WIDTH-1:0] csr_mstatus;
    reg [`CSR_WIDTH-1:0] csr_medeleg;
    reg [`CSR_WIDTH-1:0] csr_mideleg;
    reg [`CSR_WIDTH-1:0] csr_mie;
    reg [`CSR_WIDTH-1:0] csr_mtvec;
    reg [`CSR_WIDTH-1:0] csr_mepc;    
    reg [`CSR_WIDTH-1:0] csr_pmpcfg [0:0];
    reg [`CSR_WIDTH-1:0] csr_pmpaddr [0:0];
    reg [63:0] csr_cycle;
    reg [63:0] csr_instret;
    
    reg [`FFG_BITS-1:0]           csr_fflags [`NUM_WARPS-1:0];
	reg [`FRM_BITS-1:0]           csr_frm [`NUM_WARPS-1:0];
	reg [`FRM_BITS+`FFG_BITS-1:0] csr_fcsr [`NUM_WARPS-1:0];  // fflags + frm

    reg [31:0] read_data_r;

    always @(posedge clk) begin
        if (cmt_to_csr_if.has_fflags) begin
            csr_fflags[cmt_to_csr_if.wid]               <= cmt_to_csr_if.fflags;
            csr_fcsr[cmt_to_csr_if.wid][`FFG_BITS-1:0]  <= cmt_to_csr_if.fflags;
        end

        if (write_enable) begin
            case (write_addr)
                `CSR_FFLAGS: begin
                    csr_fcsr[write_wid][`FFG_BITS-1:0]  <= write_data[`FFG_BITS-1:0];
                    csr_fflags[write_wid]               <= write_data[`FFG_BITS-1:0];
                end

                `CSR_FRM: begin
                    csr_fcsr[write_wid][`FFG_BITS+`FRM_BITS-1:`FFG_BITS] <= write_data[`FRM_BITS-1:0];
                    csr_frm[write_wid]                                   <= write_data[`FRM_BITS-1:0];
                end

                `CSR_FCSR: begin
                    csr_fcsr[write_wid]   <= write_data[`FFG_BITS+`FRM_BITS-1:0];
                    csr_frm[write_wid]    <= write_data[`FFG_BITS+`FRM_BITS-1:`FFG_BITS];
                    csr_fflags[write_wid] <= write_data[`FFG_BITS-1:0];
                end

                `CSR_SATP:     csr_satp   <= write_data;
                
                `CSR_MSTATUS:  csr_mstatus <= write_data;
                `CSR_MEDELEG:  csr_medeleg <= write_data;
                `CSR_MIDELEG:  csr_mideleg <= write_data;
                `CSR_MIE:      csr_mie     <= write_data;
                `CSR_MTVEC:    csr_mtvec   <= write_data;

                `CSR_MEPC:     csr_mepc    <= write_data;

                `CSR_PMPCFG0:  csr_pmpcfg[0]  <= write_data;
                `CSR_PMPADDR0: csr_pmpaddr[0] <= write_data;

                default: begin           
                    assert(~write_enable) else $error("%t: invalid CSR write address: %0h", $time, write_addr);
                end
            endcase                
        end
    end

    always @(posedge clk) begin
       if (reset) begin
            csr_cycle   <= 0;
            csr_instret <= 0;
        end else begin
            csr_cycle <= csr_cycle + 1;
            if (cmt_to_csr_if.valid) begin
                csr_instret <= csr_instret + 64'(cmt_to_csr_if.num_commits);
            end
        end
    end

    always @(*) begin
        read_data_r = 'x;
        case (read_addr)
            `CSR_FFLAGS  : read_data_r = 32'(csr_fflags[read_wid]);
            `CSR_FRM     : read_data_r = 32'(csr_frm[read_wid]);
            `CSR_FCSR    : read_data_r = 32'(csr_fcsr[read_wid]);

            `CSR_LWID    : read_data_r = 32'(read_wid);
            `CSR_LTID    ,
            `CSR_GTID    ,
            `CSR_MHARTID ,
            `CSR_GWID    : read_data_r = CORE_ID * `NUM_WARPS + 32'(read_wid);
            `CSR_GCID    : read_data_r = CORE_ID;
            `CSR_NT      : read_data_r = `NUM_THREADS;
            `CSR_NW      : read_data_r = `NUM_WARPS;
            `CSR_NC      : read_data_r = `NUM_CORES * `NUM_CLUSTERS;
            
            `CSR_SATP    : read_data_r = 32'(csr_satp);
            
            `CSR_MSTATUS : read_data_r = 32'(csr_mstatus);
            `CSR_MISA    : read_data_r = `ISA_CODE;
            `CSR_MEDELEG : read_data_r = 32'(csr_medeleg);
            `CSR_MIDELEG : read_data_r = 32'(csr_mideleg);
            `CSR_MIE     : read_data_r = 32'(csr_mie);
            `CSR_MTVEC   : read_data_r = 32'(csr_mtvec);

            `CSR_MEPC    : read_data_r = 32'(csr_mepc);

            `CSR_PMPCFG0 : read_data_r = 32'(csr_pmpcfg[0]);
            `CSR_PMPADDR0: read_data_r = 32'(csr_pmpaddr[0]);
            
            `CSR_CYCLE   : read_data_r = csr_cycle[31:0];
            `CSR_CYCLE_H : read_data_r = csr_cycle[63:32];
            `CSR_INSTRET : read_data_r = csr_instret[31:0];
            `CSR_INSTRET_H:read_data_r = csr_instret[63:32];
            
            `CSR_MVENDORID:read_data_r = `VENDOR_ID;
            `CSR_MARCHID : read_data_r = `ARCHITECTURE_ID;
            `CSR_MIMPID  : read_data_r = `IMPLEMENTATION_ID;

            default: begin                      
                assert(~read_enable) else $error("%t: invalid CSR read address: %0h", $time, read_addr);
            end
        endcase
    end 

    assign read_data = read_data_r;
    assign csr_to_issue_if.frm = csr_frm[csr_to_issue_if.wid]; 

endmodule