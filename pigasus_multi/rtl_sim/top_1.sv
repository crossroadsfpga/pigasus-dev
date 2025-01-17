`include "./src/struct_s.sv"
`include "./src/stats_reg.sv"



module top_1 (
    input logic [0:0] clk,
    input logic [0:0] rst,
    input logic [0:0] clk_high,
    input logic [0:0] rst_high,
    input logic [0:0] clk_pcie,
    input logic [0:0] rst_pcie,
    input logic [0:0] in_sop,
    input logic [0:0] in_eop,
    input logic [511:0] in_data,
    input logic [5:0] in_empty,
    input logic [0:0] in_valid,
    output logic [0:0] in_ready,
    output logic [511:0] out_data,
    output logic [0:0] out_valid,
    output logic [0:0] out_sop,
    output logic [0:0] out_eop,
    output logic [5:0] out_empty,
    input logic [0:0] out_ready,
    output logic [511:0] out_1_data,
    output logic [0:0] out_1_valid,
    output logic [0:0] out_1_sop,
    output logic [0:0] out_1_eop,
    output logic [5:0] out_1_empty,
    input logic [0:0] out_1_ready,
    output logic [0:0] pkt_buf_wren,
    output logic [PKTBUF_AWIDTH-1:0] pkt_buf_wraddress,
    output logic [PKTBUF_AWIDTH-1:0] pkt_buf_rdaddress,
    output logic [519:0] pkt_buf_wrdata,
    output logic [0:0] pkt_buf_rden,
    input logic [0:0] pkt_buf_rd_valid,
    input logic [519:0] pkt_buf_rddata,
    output logic [513:0] pcie_rb_wr_data,
    output logic [11:0] pcie_rb_wr_addr,
    output logic [0:0] pcie_rb_wr_en,
    input logic [11:0] pcie_rb_wr_base_addr,
    input logic [0:0] pcie_rb_almost_full,
    output logic [0:0] pcie_rb_update_valid,
    output logic [11:0] pcie_rb_update_size,
    input logic [0:0] disable_pcie,
    input logic [27:0] pdumeta_cpu_data,
    input logic [0:0] pdumeta_cpu_valid,
    output logic [9:0] pdumeta_cnt,
    output logic [540:0] ddr_wr_req_data,
    output logic [0:0] ddr_wr_req_valid,
    input logic [0:0] ddr_wr_req_almost_full,
    output logic [28:0] ddr_rd_req_data,
    output logic [0:0] ddr_rd_req_valid,
    input logic [0:0] ddr_rd_req_almost_full,
    input logic [511:0] ddr_rd_resp_data,
    input logic [0:0] ddr_rd_resp_valid,
    output logic [0:0] ddr_rd_resp_almost_full,
    input logic [0:0] clk_status,
    input logic [29:0] status_addr,
    input logic [0:0] status_read,
    input logic [0:0] status_write,
    input logic [31:0] status_writedata,
    output logic [31:0] status_readdata,
    output logic [0:0] status_readdata_valid
);
    // begin copy-paste
    logic rst_n_high, rst_n, rst_n_pcie;
    assign rst_n_high = ~rst_high;
    assign rst_n = ~rst;
    assign rst_n_pcie = ~rst_pcie;

    logic clk_back, rst_back;
    assign clk_back = clk_pcie;
    assign rst_back = rst_pcie;

//generated controls
logic [31:0] parser_meta_csr_readdata_r;
    logic [31:0] stats_incomp_out_meta_r;
    logic [31:0] stats_parser_out_meta_r;
    logic [31:0] stats_ft_in_meta_r;
    logic [31:0] stats_ft_out_meta_r;
    logic [31:0] stats_emptylist_in_r;
    logic [31:0] stats_emptylist_out_r;
    logic [31:0] stats_dm_in_meta_r;
    logic [31:0] stats_dm_out_meta_r;
    logic [31:0] stats_dm_in_forward_meta_r;
    logic [31:0] stats_dm_in_drop_meta_r;
    logic [31:0] stats_dm_in_check_meta_r;
    logic [31:0] stats_dm_in_ooo_meta_r;
    logic [31:0] stats_dm_in_forward_ooo_meta_r;
    logic [31:0] stats_nopayload_pkt_r;
    logic [31:0] stats_dm_check_pkt_r;
    logic [31:0] in_pkt_fill_level_dm2sm;
    logic [31:0] stats_in_pkt_dm2sm;
    logic [31:0] stats_in_pkt_sop_dm2sm;
    logic [31:0] stats_in_meta_dm2sm;
    logic [31:0] stats_in_rule_dm2sm;
    logic [31:0] sm_bypass_af_fpm;
    logic [31:0] sm_cdc_af_fpm;
    logic [31:0] stats_out_pkt_fpm;
    logic [31:0] stats_out_meta_fpm;
    logic [31:0] stats_out_rule_fpm;
    logic [31:0] stats_nocheck_pkt_fpm;
    logic [31:0] stats_check_pkt_fpm;
    logic [31:0] stats_check_pkt_s_fpm;
    logic [31:0] in_pkt_fill_level_sm2pg;
    logic [31:0] stats_in_pkt_sm2pg;
    logic [31:0] stats_in_pkt_sop_sm2pg;
    logic [31:0] stats_in_meta_sm2pg;
    logic [31:0] stats_in_rule_sm2pg;
    logic [31:0] stats_out_pkt_pg;
    logic [31:0] stats_out_meta_pg;
    logic [31:0] stats_out_rule_pg;
    logic [31:0] stats_nocheck_pkt_pg;
    logic [31:0] stats_check_pkt_pg;
    logic [31:0] stats_check_pkt_s_pg;
    logic [31:0] pg_no_pg_rule_cnt_pg;
    logic [31:0] pg_int_rule_cnt_pg;
    logic [31:0] in_pkt_fill_level_pg2nf;
    logic [31:0] stats_in_pkt_pg2nf;
    logic [31:0] stats_in_pkt_sop_pg2nf;
    logic [31:0] stats_in_meta_pg2nf;
    logic [31:0] stats_in_rule_pg2nf;
    logic [31:0] stats_out_pkt_nf;
    logic [31:0] stats_out_meta_nf;
    logic [31:0] stats_out_rule_nf;
    logic [31:0] stats_nocheck_pkt_nf;
    logic [31:0] stats_check_pkt_nf;
    logic [31:0] stats_check_pkt_s_nf;
    logic [31:0] stats_bypass_pkt_nf;
    logic [31:0] stats_bypass_pkt_s_nf;
    logic [31:0] stats_bypass_meta_nf;
    logic [31:0] stats_bypass_rule_nf;
    logic [31:0] bypass_fill_level_nf;
    logic [31:0] bypass2nf_fill_level_nf;
    logic [31:0] nf2bypass_fill_level_nf;
    logic [31:0] nf_max_raw_pkt_fifo_nf;
    logic [31:0] nf_max_pkt_fifo_nf;
    logic [31:0] nf_max_rule_fifo_nf;
    logic [31:0] in_pkt_fill_level_by2pd;
    logic [31:0] stats_in_pkt_by2pd;
    logic [31:0] stats_in_pkt_sop_by2pd;
    logic [31:0] stats_in_meta_by2pd;
    logic [31:0] stats_in_rule_by2pd;
// Counters
logic [31:0]    in_pkt_status;
logic [31:0]    out_pkt_status;
logic [31:0]    incomp_out_meta_status;
logic [31:0]    parser_out_meta_status;
logic [31:0]    ft_in_meta_status;
logic [31:0]    ft_out_meta_status;
logic [31:0]    emptylist_in_status;
logic [31:0]    emptylist_out_status;
logic [31:0]    dm_in_meta_status;
logic [31:0]    dm_out_meta_status;
logic [31:0]    dm_in_forward_meta_status;
logic [31:0]    dm_in_drop_meta_status;
logic [31:0]    dm_in_check_meta_status;
logic [31:0]    dm_in_ooo_meta_status;
logic [31:0]    dm_in_forward_ooo_meta_status;
logic [31:0]    nopayload_pkt_status;
logic [31:0]    dm_check_pkt_status;
logic [31:0]    sm_pkt_status;
logic [31:0]    sm_meta_status;
logic [31:0]    sm_rule_status;
logic [31:0]    sm_nocheck_pkt_status;
logic [31:0]    sm_check_pkt_status;
logic [31:0]    sm_check_pkt_s_status;
logic [31:0]    pg_pkt_status;
logic [31:0]    pg_meta_status;
logic [31:0]    pg_rule_status;
logic [31:0]    pg_nocheck_pkt_status;
logic [31:0]    pg_check_pkt_status;
logic [31:0]    pg_check_pkt_s_status;
logic [31:0]    bypass_pkt_status;
logic [31:0]    bypass_pkt_s_status;
logic [31:0]    bypass_meta_status;
logic [31:0]    bypass_rule_status;
logic [31:0]    nf_pkt_status;
logic [31:0]    nf_meta_status;
logic [31:0]    nf_rule_status;
logic [31:0]    nf_nocheck_pkt_status;
logic [31:0]    nf_check_pkt_status;
logic [31:0]    nf_check_pkt_s_status;
logic [31:0]    merge_pkt_status;
logic [31:0]    merge_pkt_s_status;
logic [31:0]    merge_meta_status;
logic [31:0]    merge_rule_status;
logic [31:0]    dma_pkt_status;
logic [31:0]    cpu_nomatch_pkt_status;
logic [31:0]    cpu_match_pkt_status;
logic [31:0]    ctrl_status;
logic [31:0]    max_dm2sm_status;
logic [31:0]    max_sm2pg_status;
logic [31:0]    max_pg2nf_status;
logic [31:0]    max_bypass2nf_status;
logic [31:0]    max_nf2pdu_status;
logic [31:0]    sm_bypass_af_status;
logic [31:0]    sm_cdc_af_status;

logic [31:0]    dm2sm_fill_level;
logic [31:0]    sm2pg_fill_level;
logic [31:0]    pg2nf_fill_level;
logic [31:0]    bypass_fill_level;
logic [31:0]    bypass2nf_fill_level;
logic [31:0]    nf2bypass_fill_level;
logic [31:0]    nf2pdu_fill_level;

assign dm2sm_fill_level = in_pkt_fill_level_dm2sm;
assign sm2pg_fill_level = in_pkt_fill_level_sm2pg;
assign pg2nf_fill_level = in_pkt_fill_level_pg2nf;
assign bypass_fill_level = bypass_fill_level_nf;
assign bypass2nf_fill_level = bypass2nf_fill_level_nf;
assign nf2bypass_fill_level = nf2bypass_fill_level_nf;
assign nf2pdu_fill_level = in_pkt_fill_level_by2pd;

//Stats
logic [7:0]             status_addr_r;
logic [STAT_AWIDTH-1:0] status_addr_sel_r;
logic                   status_write_r;
logic                   status_read_r;
logic [31:0]            status_writedata_r;

//cross clock domain
logic [31:0]    in_pkt_r1;
logic [31:0]    out_pkt_r1;
logic [31:0]    incomp_out_meta_r1;
logic [31:0]    parser_out_meta_r1;
logic [31:0]    ft_in_meta_r1;
logic [31:0]    ft_out_meta_r1;
logic [31:0]    emptylist_in_r1;
logic [31:0]    emptylist_out_r1;
logic [31:0]    dm_in_meta_r1;
logic [31:0]    dm_out_meta_r1;
logic [31:0]    dm_in_forward_meta_r1;
logic [31:0]    dm_in_drop_meta_r1;
logic [31:0]    dm_in_check_meta_r1;
logic [31:0]    dm_in_ooo_meta_r1;
logic [31:0]    dm_in_forward_ooo_meta_r1;
logic [31:0]    nopayload_pkt_r1;
logic [31:0]    dm_check_pkt_r1;
logic [31:0]    sm_pkt_r1;
logic [31:0]    sm_meta_r1;
logic [31:0]    sm_rule_r1;
logic [31:0]    sm_nocheck_pkt_r1;
logic [31:0]    sm_check_pkt_r1;
logic [31:0]    sm_check_pkt_s_r1;
logic [31:0]    pg_pkt_r1;
logic [31:0]    pg_meta_r1;
logic [31:0]    pg_rule_r1;
logic [31:0]    pg_nocheck_pkt_r1;
logic [31:0]    pg_check_pkt_r1;
logic [31:0]    pg_check_pkt_s_r1;
logic [31:0]    bypass_pkt_r1;
logic [31:0]    bypass_pkt_s_r1;
logic [31:0]    bypass_meta_r1;
logic [31:0]    bypass_rule_r1;
logic [31:0]    nf_pkt_r1;
logic [31:0]    nf_meta_r1;
logic [31:0]    nf_rule_r1;
logic [31:0]    nf_nocheck_pkt_r1;
logic [31:0]    nf_check_pkt_r1;
logic [31:0]    nf_check_pkt_s_r1;
logic [31:0]    merge_pkt_r1;
logic [31:0]    merge_pkt_s_r1;
logic [31:0]    merge_meta_r1;
logic [31:0]    merge_rule_r1;
logic [31:0]    dma_pkt_r1;
logic [31:0]    cpu_nomatch_pkt_r1;
logic [31:0]    cpu_match_pkt_r1;
logic [31:0]    ctrl_r1;
logic [31:0]    max_dm2sm_r1;
logic [31:0]    max_sm2pg_r1;
logic [31:0]    max_bypass2nf_r1;
logic [31:0]    max_pg2nf_r1;
logic [31:0]    max_nf2pdu_r1;
logic [31:0]    sm_bp_cnt_r1;
logic [31:0]    sm_bypass_af_r1;
logic [31:0]    sm_cdc_af_r1;

logic [31:0]    in_pkt;
logic [31:0]    out_pkt;

logic [31:0]    incomp_out_meta;
logic [31:0]    parser_out_meta;
logic [31:0]    ft_in_meta;
logic [31:0]    ft_out_meta;
logic [31:0]    emptylist_in;
logic [31:0]    emptylist_out;
logic [31:0]    dm_in_meta;
logic [31:0]    dm_out_meta;
logic [31:0]    dm_in_forward_meta;
logic [31:0]    dm_in_drop_meta;
logic [31:0]    dm_in_check_meta;
logic [31:0]    dm_in_ooo_meta;
logic [31:0]    dm_in_forward_ooo_meta;
logic [31:0]    nopayload_pkt;
logic [31:0]    dm_check_pkt;


logic [31:0]    sm_pkt;
logic [31:0]    sm_meta;
logic [31:0]    sm_rule;
logic [31:0]    sm_nocheck_pkt;
logic [31:0]    sm_check_pkt;
logic [31:0]    sm_check_pkt_s;
logic [31:0]    sm_bypass_af;
logic [31:0]    sm_cdc_af;


logic [31:0]    pg_pkt;
logic [31:0]    pg_meta;
logic [31:0]    pg_rule;
logic [31:0]    pg_nocheck_pkt;
logic [31:0]    pg_check_pkt;
logic [31:0]    pg_check_pkt_s;
logic [31:0]    bypass_pkt;
logic [31:0]    bypass_pkt_s;
logic [31:0]    bypass_meta;
logic [31:0]    bypass_rule;
logic [31:0]    nf_pkt;
logic [31:0]    nf_meta;
logic [31:0]    nf_rule;
logic [31:0]    nf_nocheck_pkt;
logic [31:0]    nf_check_pkt;
logic [31:0]    nf_check_pkt_s;
logic [31:0]    merge_pkt;
logic [31:0]    merge_pkt_s;
logic [31:0]    merge_meta;
logic [31:0]    merge_rule;
logic [31:0]    dma_pkt;
logic [31:0]    cpu_nomatch_pkt;
logic [31:0]    cpu_match_pkt;
logic [31:0]    ctrl;
logic [31:0]    max_dm2sm;
logic [31:0]    max_sm2pg;
logic [31:0]    max_pg2nf;
logic [31:0]    max_bypass2nf;
logic [31:0]    max_nf2pdu;

assign incomp_out_meta = stats_incomp_out_meta_r;
assign parser_out_meta = stats_parser_out_meta_r;
assign ft_in_meta = stats_ft_in_meta_r;
assign ft_out_meta = stats_ft_out_meta_r;
assign emptylist_in = stats_emptylist_in_r;
assign emptylist_out = stats_emptylist_out_r;
assign dm_in_meta = stats_dm_in_meta_r;
assign dm_out_meta = stats_dm_out_meta_r;
assign dm_in_forward_meta = stats_dm_in_forward_meta_r;
assign dm_in_drop_meta = stats_dm_in_drop_meta_r;
assign dm_in_ooo_meta = stats_dm_in_ooo_meta_r;
assign dm_in_forward_ooo_meta = stats_dm_in_forward_ooo_meta_r;
assign nopayload_pkt = stats_nopayload_pkt_r;
assign dm_check_pkt = stats_dm_check_pkt_r;

assign sm_pkt = stats_out_pkt_fpm;
assign sm_meta = stats_out_meta_fpm;
assign sm_rule = stats_out_rule_fpm;
assign sm_nocheck_pkt = stats_nocheck_pkt_fpm;
assign sm_check_pkt = stats_check_pkt_fpm;
assign sm_check_pkt_s = stats_check_pkt_s_fpm;
assign sm_bypass_af = sm_bypass_af_fpm;
assign sm_cdc_af = sm_cdc_af_fpm;

assign pg_pkt = stats_out_pkt_pg;
assign pg_meta = stats_out_meta_pg;
assign pg_rule = stats_out_rule_pg;
assign pg_nocheck_pkt = stats_nocheck_pkt_pg;
assign pg_check_pkt = stats_check_pkt_pg;
assign pg_check_pkt_s = stats_check_pkt_s_pg;

assign bypass_pkt = stats_bypass_pkt_nf;
assign bypass_pkt_s = stats_bypass_pkt_s_nf;
assign bypass_meta = stats_bypass_meta_nf;
assign bypass_rule = stats_bypass_rule_nf;
assign nf_pkt = stats_out_pkt_nf;
assign nf_meta = stats_out_meta_nf;
assign nf_rule = stats_out_rule_nf;
assign nf_nocheck_pkt = stats_nocheck_pkt_nf;
assign nf_check_pkt = stats_check_pkt_nf;
assign nf_check_pkt_s = stats_check_pkt_s_nf;

assign merge_pkt = stats_in_pkt_by2pd;
assign merge_pkt_s = stats_in_pkt_sop_by2pd;
assign merge_meta = stats_in_meta_by2pd;
assign merge_rule = stats_in_rule_by2pd;

logic internal_rb_update_valid;
pdu_metadata_t tmp_pdumeta_cpu_data;
logic [31:0] pdumeta_cpu_csr_readdata;
logic pdumeta_cpu_ready;


//////////////////////////////
// Read and Write registers //
//////////////////////////////

//System clock domain
always @ (posedge clk) begin
    if (rst) begin
        in_pkt <= 0;
        out_pkt <= 0;
        max_dm2sm <= 0;
    end else begin
        if (in_eop & in_valid)begin
            in_pkt <= in_pkt + 1'b1;
            //DEBUG 
            if (in_pkt[5:0] == 6'b00_0000) begin
                $display("PKT %d", in_pkt);
            end
        end
        if (out_eop & out_valid & out_ready)begin
            out_pkt <= out_pkt + 1'b1;
        end

        if (max_dm2sm < dm2sm_fill_level)begin
            max_dm2sm <= dm2sm_fill_level;
        end
    end
end

//clk_back clock domain
always @(posedge clk_back) begin
    if (rst_back) begin
        max_sm2pg <= 0;
    end else begin

        if (max_sm2pg < sm2pg_fill_level)begin
            max_sm2pg <= sm2pg_fill_level;
        end
    end
end

//PCIe clock domain
assign tmp_pdumeta_cpu_data = pdumeta_cpu_data;
always @(posedge clk_pcie) begin
    if (rst_pcie) begin
        dma_pkt <= 0;
        cpu_nomatch_pkt <= 0;
        cpu_match_pkt <= 0;
        max_pg2nf <= 0;
        max_bypass2nf <= 0;
        max_nf2pdu <= 0;
    end else begin
        if (internal_rb_update_valid) begin
            dma_pkt <= dma_pkt + 1;
        end
        if (pdumeta_cpu_valid & pdumeta_cpu_ready & (tmp_pdumeta_cpu_data.action == ACTION_NOMATCH)) begin
            cpu_nomatch_pkt <= cpu_nomatch_pkt + 1;
        end
        if (pdumeta_cpu_valid & pdumeta_cpu_ready & (tmp_pdumeta_cpu_data.action == ACTION_MATCH)) begin
            cpu_match_pkt <= cpu_match_pkt + 1;
        end
        if (max_pg2nf < pg2nf_fill_level)begin
            max_pg2nf <= pg2nf_fill_level;
        end
        if (max_bypass2nf < bypass2nf_fill_level)begin
            max_bypass2nf <= bypass2nf_fill_level;
        end
        if (max_nf2pdu < nf2pdu_fill_level)begin
            max_nf2pdu <= nf2pdu_fill_level;
        end
    end
end

// Sync
always @(posedge clk_status) begin
    in_pkt_r1                     <= in_pkt;
    in_pkt_status                 <= in_pkt_r1;
    out_pkt_r1                    <= out_pkt;
    out_pkt_status                <= out_pkt_r1;
    incomp_out_meta_r1            <= incomp_out_meta;
    incomp_out_meta_status        <= incomp_out_meta_r1;
    parser_out_meta_r1            <= parser_out_meta;
    parser_out_meta_status        <= parser_out_meta_r1;
    ft_in_meta_r1                 <= ft_in_meta;
    ft_in_meta_status             <= ft_in_meta_r1;
    ft_out_meta_r1                <= ft_out_meta;
    ft_out_meta_status            <= ft_out_meta_r1;
    emptylist_in_r1               <= emptylist_in;
    emptylist_in_status           <= emptylist_in_r1;
    emptylist_out_r1              <= emptylist_out;
    emptylist_out_status          <= emptylist_out_r1;
    dm_in_meta_r1                 <= dm_in_meta;
    dm_in_meta_status             <= dm_in_meta_r1;
    dm_out_meta_r1                <= dm_out_meta;
    dm_out_meta_status            <= dm_out_meta_r1;
    dm_in_forward_meta_r1         <= dm_in_forward_meta;
    dm_in_forward_meta_status     <= dm_in_forward_meta_r1;
    dm_in_drop_meta_r1            <= dm_in_drop_meta;
    dm_in_drop_meta_status        <= dm_in_drop_meta_r1;
    dm_in_check_meta_r1           <= dm_in_check_meta;
    dm_in_check_meta_status       <= dm_in_check_meta_r1;
    dm_in_ooo_meta_r1             <= dm_in_ooo_meta;
    dm_in_ooo_meta_status         <= dm_in_ooo_meta_r1;
    dm_in_forward_ooo_meta_r1     <= dm_in_forward_ooo_meta;
    dm_in_forward_ooo_meta_status <= dm_in_forward_ooo_meta_r1;
    nopayload_pkt_r1              <= nopayload_pkt;
    nopayload_pkt_status          <= nopayload_pkt_r1;
    dm_check_pkt_r1               <= dm_check_pkt;
    dm_check_pkt_status           <= dm_check_pkt_r1;
    sm_pkt_r1                     <= sm_pkt;
    sm_pkt_status                 <= sm_pkt_r1;
    sm_meta_r1                    <= sm_meta;
    sm_meta_status                <= sm_meta_r1;
    sm_rule_r1                    <= sm_rule;
    sm_rule_status                <= sm_rule_r1;
    sm_nocheck_pkt_r1             <= sm_nocheck_pkt;
    sm_nocheck_pkt_status         <= sm_nocheck_pkt_r1;
    sm_check_pkt_r1               <= sm_check_pkt;
    sm_check_pkt_status           <= sm_check_pkt_r1;
    sm_check_pkt_s_r1             <= sm_check_pkt_s;
    sm_check_pkt_s_status         <= sm_check_pkt_s_r1;
    pg_pkt_r1                     <= pg_pkt;
    pg_pkt_status                 <= pg_pkt_r1;
    pg_meta_r1                    <= pg_meta;
    pg_meta_status                <= pg_meta_r1;
    pg_rule_r1                    <= pg_rule;
    pg_rule_status                <= pg_rule_r1;
    pg_nocheck_pkt_r1             <= pg_nocheck_pkt;
    pg_nocheck_pkt_status         <= pg_nocheck_pkt_r1;
    pg_check_pkt_r1               <= pg_check_pkt;
    pg_check_pkt_status           <= pg_check_pkt_r1;
    pg_check_pkt_s_r1             <= pg_check_pkt_s;
    pg_check_pkt_s_status         <= pg_check_pkt_s_r1;
    bypass_pkt_r1                 <= bypass_pkt;
    bypass_pkt_status             <= bypass_pkt_r1;
    bypass_pkt_s_r1               <= bypass_pkt_s;
    bypass_pkt_s_status           <= bypass_pkt_s_r1;
    bypass_meta_r1                <= bypass_meta;
    bypass_meta_status            <= bypass_meta_r1;
    bypass_rule_r1                <= bypass_rule;
    bypass_rule_status            <= bypass_rule_r1;
    nf_pkt_r1                     <= nf_pkt;
    nf_pkt_status                 <= nf_pkt_r1;
    nf_meta_r1                    <= nf_meta;
    nf_meta_status                <= nf_meta_r1;
    nf_rule_r1                    <= nf_rule;
    nf_rule_status                <= nf_rule_r1;
    nf_nocheck_pkt_r1             <= nf_nocheck_pkt;
    nf_nocheck_pkt_status         <= nf_nocheck_pkt_r1;
    nf_check_pkt_r1               <= nf_check_pkt;
    nf_check_pkt_status           <= nf_check_pkt_r1;
    nf_check_pkt_s_r1             <= nf_check_pkt_s;
    nf_check_pkt_s_status         <= nf_check_pkt_s_r1;
    merge_pkt_r1                  <= merge_pkt;
    merge_pkt_status              <= merge_pkt_r1;
    merge_pkt_s_r1                <= merge_pkt_s;
    merge_pkt_s_status            <= merge_pkt_s_r1;
    merge_meta_r1                 <= merge_meta;
    merge_meta_status             <= merge_meta_r1;
    merge_rule_r1                 <= merge_rule;
    merge_rule_status             <= merge_rule_r1;
    dma_pkt_r1                    <= dma_pkt;
    dma_pkt_status                <= dma_pkt_r1;
    cpu_nomatch_pkt_r1            <= cpu_nomatch_pkt;
    cpu_nomatch_pkt_status        <= cpu_nomatch_pkt_r1;
    cpu_match_pkt_r1              <= cpu_match_pkt;
    cpu_match_pkt_status          <= cpu_match_pkt_r1;
    max_dm2sm_r1                  <= max_dm2sm;
    max_dm2sm_status              <= max_dm2sm_r1;
    max_sm2pg_r1                  <= max_sm2pg;
    max_sm2pg_status              <= max_sm2pg_r1;
    max_pg2nf_r1                  <= max_pg2nf;
    max_pg2nf_status              <= max_pg2nf_r1;
    max_bypass2nf_r1              <= max_bypass2nf;
    max_bypass2nf_status          <= max_bypass2nf_r1;
    max_nf2pdu_r1                 <= max_nf2pdu;
    max_nf2pdu_status             <= max_nf2pdu_r1;
    sm_bypass_af_r1               <= sm_bypass_af;
    sm_bypass_af_status           <= sm_bypass_af_r1;
    sm_cdc_af_r1                  <= sm_cdc_af;
    sm_cdc_af_status              <= sm_cdc_af_r1;
end
//registers
always @(posedge clk_status) begin
    status_addr_r           <= status_addr[7:0];
    status_addr_sel_r       <= status_addr[29:30-STAT_AWIDTH];

    status_read_r           <= status_read;
    status_write_r          <= status_write;
    status_writedata_r      <= status_writedata;
    status_readdata_valid <= 1'b0;

    if (status_read_r) begin
        if (status_addr_sel_r == TOP_REG) begin
            status_readdata_valid <= 1'b1;
            case (status_addr_r)
                REG_IN_PKT                : status_readdata <= in_pkt_status;
                REG_OUT_PKT               : status_readdata <= out_pkt_status;
                REG_INCOMP_OUT_META       : status_readdata <= incomp_out_meta_status;
                REG_PARSER_OUT_META       : status_readdata <= parser_out_meta_status;
                REG_FT_IN_META            : status_readdata <= ft_in_meta_status;
                REG_FT_OUT_META           : status_readdata <= ft_out_meta_status;
                REG_EMPTYLIST_IN          : status_readdata <= emptylist_in_status;
                REG_EMPTYLIST_OUT         : status_readdata <= emptylist_out_status;
                REG_DM_IN_META            : status_readdata <= dm_in_meta_status;
                REG_DM_OUT_META           : status_readdata <= dm_out_meta_status;
                REG_DM_IN_FORWARD_META    : status_readdata <= dm_in_forward_meta_status;
                REG_DM_IN_DROP_META       : status_readdata <= dm_in_drop_meta_status;
                REG_DM_IN_CHECK_META      : status_readdata <= dm_in_check_meta_status;
                REG_DM_IN_OOO_META        : status_readdata <= dm_in_ooo_meta_status;
                REG_DM_IN_FORWARD_OOO_META: status_readdata <= dm_in_forward_ooo_meta_status;
                REG_NOPAYLOAD_PKT         : status_readdata <= nopayload_pkt_status;
                REG_DM_CHECK_PKT          : status_readdata <= dm_check_pkt_status; 
                REG_SM_PKT                : status_readdata <= sm_pkt_status;
                REG_SM_META               : status_readdata <= sm_meta_status;
                REG_SM_RULE               : status_readdata <= sm_rule_status;
                REG_SM_CHECK_PKT          : status_readdata <= sm_check_pkt_status;
                REG_SM_CHECK_PKT_SOP      : status_readdata <= sm_check_pkt_s_status;
                REG_SM_NOCHECK_PKT        : status_readdata <= sm_nocheck_pkt_status;
                REG_PG_PKT                : status_readdata <= pg_pkt_status;
                REG_PG_META               : status_readdata <= pg_meta_status;
                REG_PG_RULE               : status_readdata <= pg_rule_status;
                REG_PG_CHECK_PKT          : status_readdata <= pg_check_pkt_status;
                REG_PG_CHECK_PKT_SOP      : status_readdata <= pg_check_pkt_s_status;
                REG_PG_NOCHECK_PKT        : status_readdata <= pg_nocheck_pkt_status;
                REG_BYPASS_PKT            : status_readdata <= bypass_pkt_status;
                REG_BYPASS_PKT_SOP        : status_readdata <= bypass_pkt_s_status;
                REG_BYPASS_META           : status_readdata <= bypass_meta_status;
                REG_BYPASS_RULE           : status_readdata <= bypass_rule_status;
                REG_NF_PKT                : status_readdata <= nf_pkt_status;
                REG_NF_RULE               : status_readdata <= nf_rule_status;
                REG_NF_META               : status_readdata <= nf_meta_status;
                REG_NF_CHECK_PKT          : status_readdata <= nf_check_pkt_status;
                REG_NF_CHECK_PKT_SOP      : status_readdata <= nf_check_pkt_s_status;
                REG_NF_NOCHECK_PKT        : status_readdata <= nf_nocheck_pkt_status;
                REG_MERGE_PKT             : status_readdata <= merge_pkt_status;
                REG_MERGE_PKT_SOP         : status_readdata <= merge_pkt_s_status;
                REG_MERGE_META            : status_readdata <= merge_meta_status;
                REG_MERGE_RULE            : status_readdata <= merge_rule_status;
                REG_DMA_PKT               : status_readdata <= dma_pkt_status;
                REG_CPU_NOMATCH_PKT       : status_readdata <= cpu_nomatch_pkt_status;
                REG_CPU_MATCH_PKT         : status_readdata <= cpu_match_pkt_status;
                REG_CTRL                  : status_readdata <= ctrl_status;
                REG_MAX_DM2SM             : status_readdata <= max_dm2sm_status;
                REG_MAX_SM2PG             : status_readdata <= max_sm2pg_status;
                REG_MAX_PG2NF             : status_readdata <= max_pg2nf_status;
                REG_MAX_BYPASS2NF         : status_readdata <= max_bypass2nf_status;
                REG_MAX_NF2PDU            : status_readdata <= max_nf2pdu_status;
                REG_SM_BYPASS_AF          : status_readdata <= sm_bypass_af_status;
                REG_SM_CDC_AF             : status_readdata <= sm_cdc_af_status;
                default                   : status_readdata <= 32'hDEADBEEF;
            endcase
        end
    end
    //Disable write
    if (status_addr_sel_r == TOP_REG & status_write_r) begin
        case (status_addr_r)
            REG_CTRL: begin
                ctrl_status   <= status_writedata_r;
            end
            default: ctrl_status <= 32'b0;
        endcase
    end
end

//assign nf_forward_th = ctrl_status[15:0];
// Stats End

assign pcie_rb_update_valid = disable_pcie ? 1'b0 : internal_rb_update_valid;

// PDU meta occupancy cnt
assign pdumeta_cnt = pdumeta_cpu_csr_readdata[9:0];
    avl_stream_if#(.WIDTH(512)) ethernet_out0_direct();
    avl_stream_if#(.WIDTH(512)) ethernet_out3_direct();
    avl_stream_if#(.WIDTH(512)) fifo2_in_direct();
    avl_stream_if#(.WIDTH(512)) ethernet_out1_direct();
    avl_stream_if#(.WIDTH(512)) ethernet_out2_direct();
    avl_stream_if#(.WIDTH(512)) ethernet_out4_direct();
    avl_stream_if#(.WIDTH(512)) fifo3_in_direct();
    avl_stream_if#(.WIDTH(512)) fifo4_in_direct();
    avl_stream_if#(.WIDTH(512)) cross_FPGA_demux_in_direct();
    avl_stream_if#(.WIDTH(512)) sm2pg_in_pkt_direct();
    avl_stream_if#(.WIDTH($bits(metadata_t))) sm2pg_in_meta_direct();
    avl_stream_if#(.WIDTH(512)) sm2pg_in_usr_direct();
    avl_stream_if#(.WIDTH(512)) pg_in_pkt_direct();
    avl_stream_if#(.WIDTH($bits(metadata_t))) pg_in_meta_direct();
    avl_stream_if#(.WIDTH(512)) pg_in_usr_direct();
    avl_stream_if#(.WIDTH(512)) pg2nf_in_pkt_direct();
    avl_stream_if#(.WIDTH($bits(metadata_t))) pg2nf_in_meta_direct();
    avl_stream_if#(.WIDTH(512)) pg2nf_in_usr_direct();
    avl_stream_if#(.WIDTH(512)) nf_in_pkt_direct();
    avl_stream_if#(.WIDTH($bits(metadata_t))) nf_in_meta_direct();
    avl_stream_if#(.WIDTH(512)) nf_in_usr_direct();
    avl_stream_if#(.WIDTH(512)) by2pd_in_pkt_direct();
    avl_stream_if#(.WIDTH($bits(metadata_t))) by2pd_in_meta_direct();
    avl_stream_if#(.WIDTH(512)) by2pd_in_usr_direct();
    avl_stream_if#(.WIDTH(512)) dma_in_pkt_direct();
    avl_stream_if#(.WIDTH($bits(metadata_t))) dma_in_meta_direct();
    avl_stream_if#(.WIDTH(512)) dma_in_usr_direct();
    unified_pkt_fifo_avlstrm#(.FIFO_NAME("[top] fifo2"), .MEM_TYPE("M20K"), .DUAL_CLOCK(1), .USE_ALMOST_FULL(1), .FULL_LEVEL(450), .SYMBOLS_PER_BEAT(64), .BITS_PER_SYMBOL(8), .FIFO_DEPTH(512)) my_fifo2 (
        .Clk_i(clk_pcie),
        .Rst_n_i(rst_n_pcie),
        .Clk_o(clk),
        .Rst_n_o(rst_n),
        .fill_level(pg_nocheck_pkt_csr_readdata),
        .in(fifo2_in_direct),
        .out(ethernet_out4_direct)
    );
    ethernet_multi_out_avlstrm my_ethernet (
        .Clk(clk),
        .Rst_n(rst_n),
        .out_data(out_data),
        .out_valid(out_valid),
        .out_ready(out_ready),
        .out_sop(out_sop),
        .out_eop(out_eop),
        .out_empty(out_empty),
        .in_sop(in_sop),
        .in_eop(in_eop),
        .in_data(in_data),
        .in_empty(in_empty),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .out0(ethernet_out0_direct),
        .out1(ethernet_out1_direct),
        .out2(ethernet_out2_direct),
        .out3(ethernet_out3_direct),
        .out4(ethernet_out4_direct),
        .in(cross_FPGA_demux_in_direct)
    );
    unified_pkt_fifo_avlstrm#(.FIFO_NAME("[top] fifo3"), .MEM_TYPE("M20K"), .DUAL_CLOCK(1), .USE_ALMOST_FULL(1), .FULL_LEVEL(450), .SYMBOLS_PER_BEAT(64), .BITS_PER_SYMBOL(8), .FIFO_DEPTH(512)) my_fifo3 (
        .Clk_i(clk_pcie),
        .Rst_n_i(rst_n_pcie),
        .Clk_o(clk),
        .Rst_n_o(rst_n),
        .fill_level(nf_nocheck_pkt_csr_readdata),
        .in(fifo3_in_direct),
        .out(ethernet_out1_direct)
    );
    unified_pkt_fifo_avlstrm#(.FIFO_NAME("[top] fifo4"), .MEM_TYPE("M20K"), .DUAL_CLOCK(1), .USE_ALMOST_FULL(1), .FULL_LEVEL(450), .SYMBOLS_PER_BEAT(64), .BITS_PER_SYMBOL(8), .FIFO_DEPTH(512)) my_fifo4 (
        .Clk_i(clk_pcie),
        .Rst_n_i(rst_n_pcie),
        .Clk_o(clk),
        .Rst_n_o(rst_n),
        .fill_level(nomatch_pkt_csr_readdata),
        .in(fifo4_in_direct),
        .out(ethernet_out2_direct)
    );
    stream_demux_avlstrm my_cross_FPGA_demux (
        .Clk(clk),
        .Rst_n(rst_n),
        .in(cross_FPGA_demux_in_direct),
        .out_pkt(sm2pg_in_pkt_direct),
        .out_meta(sm2pg_in_meta_direct),
        .out_usr(sm2pg_in_usr_direct)
    );
    channel_fifo_avlstrm#(.DUAL_CLOCK(1)) my_sm2pg (
        .Clk_i(clk),
        .Rst_n_i(rst_n),
        .Clk_o(clk_pcie),
        .Rst_n_o(rst_n_pcie),
        .in_pkt_fill_level(in_pkt_fill_level_sm2pg),
        .stats_in_pkt(stats_in_pkt_sm2pg),
        .stats_in_pkt_sop(stats_in_pkt_sop_sm2pg),
        .stats_in_meta(stats_in_meta_sm2pg),
        .stats_in_rule(stats_in_rule_sm2pg),
        .in_pkt(sm2pg_in_pkt_direct),
        .in_meta(sm2pg_in_meta_direct),
        .in_usr(sm2pg_in_usr_direct),
        .out_pkt(pg_in_pkt_direct),
        .out_meta(pg_in_meta_direct),
        .out_usr(pg_in_usr_direct)
    );
    port_group_matcher_avlstrm my_pg (
        .Clk(clk_pcie),
        .Rst_n(rst_n_pcie),
        .stats_out_pkt(stats_out_pkt_pg),
        .stats_out_meta(stats_out_meta_pg),
        .stats_out_rule(stats_out_rule_pg),
        .stats_nocheck_pkt(stats_nocheck_pkt_pg),
        .stats_check_pkt(stats_check_pkt_pg),
        .stats_check_pkt_s(stats_check_pkt_s_pg),
        .pg_no_pg_rule_cnt(pg_no_pg_rule_cnt_pg),
        .pg_int_rule_cnt(pg_int_rule_cnt_pg),
        .in_pkt(pg_in_pkt_direct),
        .in_meta(pg_in_meta_direct),
        .in_usr(pg_in_usr_direct),
        .pg_nocheck(fifo2_in_direct),
        .out_pkt(pg2nf_in_pkt_direct),
        .out_meta(pg2nf_in_meta_direct),
        .out_usr(pg2nf_in_usr_direct)
    );
    channel_fifo_avlstrm#(.DUAL_CLOCK(1)) my_pg2nf (
        .Clk_i(clk_pcie),
        .Rst_n_i(rst_n_pcie),
        .Clk_o(clk_pcie),
        .Rst_n_o(rst_n_pcie),
        .in_pkt_fill_level(in_pkt_fill_level_pg2nf),
        .stats_in_pkt(stats_in_pkt_pg2nf),
        .stats_in_pkt_sop(stats_in_pkt_sop_pg2nf),
        .stats_in_meta(stats_in_meta_pg2nf),
        .stats_in_rule(stats_in_rule_pg2nf),
        .in_pkt(pg2nf_in_pkt_direct),
        .in_meta(pg2nf_in_meta_direct),
        .in_usr(pg2nf_in_usr_direct),
        .out_pkt(nf_in_pkt_direct),
        .out_meta(nf_in_meta_direct),
        .out_usr(nf_in_usr_direct)
    );
    non_fast_pm_avlstrm my_nf (
        .Clk(clk_pcie),
        .Rst_n(rst_n_pcie),
        .Clk_high(clk_high),
        .Rst_high_n(rst_n_high),
        .stats_out_pkt(stats_out_pkt_nf),
        .stats_out_meta(stats_out_meta_nf),
        .stats_out_rule(stats_out_rule_nf),
        .stats_nocheck_pkt(stats_nocheck_pkt_nf),
        .stats_check_pkt(stats_check_pkt_nf),
        .stats_check_pkt_s(stats_check_pkt_s_nf),
        .stats_bypass_pkt(stats_bypass_pkt_nf),
        .stats_bypass_pkt_s(stats_bypass_pkt_s_nf),
        .stats_bypass_meta(stats_bypass_meta_nf),
        .stats_bypass_rule(stats_bypass_rule_nf),
        .bypass_fill_level(bypass_fill_level_nf),
        .bypass2nf_fill_level(bypass2nf_fill_level_nf),
        .nf2bypass_fill_level(nf2bypass_fill_level_nf),
        .nf_max_raw_pkt_fifo(nf_max_raw_pkt_fifo_nf),
        .nf_max_pkt_fifo(nf_max_pkt_fifo_nf),
        .nf_max_rule_fifo(nf_max_rule_fifo_nf),
        .in_pkt(nf_in_pkt_direct),
        .in_meta(nf_in_meta_direct),
        .in_usr(nf_in_usr_direct),
        .nfp_nocheck(fifo3_in_direct),
        .out_pkt(by2pd_in_pkt_direct),
        .out_meta(by2pd_in_meta_direct),
        .out_usr(by2pd_in_usr_direct)
    );
    channel_fifo_avlstrm#(.DUAL_CLOCK(1)) my_by2pd (
        .Clk_i(clk_pcie),
        .Rst_n_i(rst_n_pcie),
        .Clk_o(clk_pcie),
        .Rst_n_o(rst_n_pcie),
        .in_pkt_fill_level(in_pkt_fill_level_by2pd),
        .stats_in_pkt(stats_in_pkt_by2pd),
        .stats_in_pkt_sop(stats_in_pkt_sop_by2pd),
        .stats_in_meta(stats_in_meta_by2pd),
        .stats_in_rule(stats_in_rule_by2pd),
        .in_pkt(by2pd_in_pkt_direct),
        .in_meta(by2pd_in_meta_direct),
        .in_usr(by2pd_in_usr_direct),
        .out_pkt(dma_in_pkt_direct),
        .out_meta(dma_in_meta_direct),
        .out_usr(dma_in_usr_direct)
    );
    dma_avlstrm my_dma (
        .Clk(clk_pcie),
        .Rst_n(rst_n_pcie),
        .pcie_rb_wr_data(pcie_rb_wr_data),
        .pcie_rb_wr_addr(pcie_rb_wr_addr),
        .pcie_rb_wr_en(pcie_rb_wr_en),
        .pcie_rb_wr_base_addr(pcie_rb_wr_base_addr),
        .pcie_rb_almost_full(pcie_rb_almost_full),
        .pcie_rb_update_valid(internal_rb_update_valid),
        .pcie_rb_update_size(pcie_rb_update_size),
        .disable_pcie(disable_pcie),
        .pdumeta_cpu_data(pdumeta_cpu_data),
        .pdumeta_cpu_valid(pdumeta_cpu_valid),
        .pdumeta_cpu_ready(pdumeta_cpu_ready),
        .pdumeta_cpu_csr_readdata(pdumeta_cpu_csr_readdata),
        .ddr_wr_req_data(ddr_wr_req_data),
        .ddr_wr_req_valid(ddr_wr_req_valid),
        .ddr_wr_req_almost_full(ddr_wr_req_almost_full),
        .ddr_rd_req_data(ddr_rd_req_data),
        .ddr_rd_req_valid(ddr_rd_req_valid),
        .ddr_rd_req_almost_full(ddr_rd_req_almost_full),
        .ddr_rd_resp_data(ddr_rd_resp_out_data),
        .ddr_rd_resp_valid(ddr_rd_resp_out_valid),
        .ddr_rd_resp_almost_full(ddr_rd_resp_out_ready),
        .in_pkt(dma_in_pkt_direct),
        .in_meta(dma_in_meta_direct),
        .in_usr(dma_in_usr_direct),
        .nomatch_pkt(fifo4_in_direct)
    );
endmodule: top_1
