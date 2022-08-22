`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

module pdu_gen_avlstrm (
    input logic Clk, 
    input logic Rst_n,

    output  flit_lite_t             pcie_rb_wr_data,
    output  logic [PDU_AWIDTH-1:0]  pcie_rb_wr_addr,
    output  logic                   pcie_rb_wr_en,
    input   logic [PDU_AWIDTH-1:0]  pcie_rb_wr_base_addr,
    input   logic                   pcie_rb_almost_full,
    output  logic                   pcie_rb_update_valid,
    output  logic [PDU_AWIDTH-1:0]  pcie_rb_update_size,
    input   logic                   disable_pcie,

    avl_stream_if.rx in,
    avl_stream_if.rx in_match,
    avl_stream_if.rx in_meta,
    avl_stream_if.rx emptylist,
    avl_stream_if.tx out,
    avl_stream_if.tx out_meta 
);
   pdu_gen pdu_gen_inst(
    .clk                    (Clk),
    .rst                    (~Rst_n),
    .in_sop                 (in.sop),
    .in_eop                 (in.eop),
    .in_data                (in.data),
    .in_empty               (in.empty),
    .in_valid               (in.valid),
    .in_ready               (in.ready),
    .in_match_sop           (in_match.sop),
    .in_match_eop           (in_match.eop),
    .in_match_data          (in_match.data),
    .in_match_empty         (in_match.empty),
    .in_match_valid         (in_match.valid),
    .in_match_ready         (in_match.ready),
    .in_meta_valid          (in_meta.valid),
    .in_meta_ready          (in_meta.ready),
    .in_meta_data           (in_meta.data),
    .pcie_rb_wr_data        (pcie_rb_wr_data),
    .pcie_rb_wr_addr        (pcie_rb_wr_addr),
    .pcie_rb_wr_en          (pcie_rb_wr_en),
    .pcie_rb_wr_base_addr   (pcie_rb_wr_base_addr),
    .pcie_rb_almost_full    (pcie_rb_almost_full),
    .pcie_rb_update_valid   (internal_rb_update_valid),
    .pcie_rb_update_size    (pcie_rb_update_size),
    .disable_pcie           (disable_pcie),
    .pdu_emptylist_out_data (emptylist.data),
    .pdu_emptylist_out_valid(emptylist.valid),
    .pdu_emptylist_out_ready(emptylist.ready),
    .pdu_gen_data           (out.data),
    .pdu_gen_sop            (out.sop),
    .pdu_gen_eop            (out.eop),
    .pdu_gen_empty          (out.empty),
    .pdu_gen_valid          (out.valid),
    .pdu_gen_ready          (out.ready),
    .pdu_gen_almost_full    (out.almost_full),
    .pdumeta_gen_data       (out_meta.data),
    .pdumeta_gen_valid      (out_meta.valid),
    .pdumeta_gen_ready      (out_meta.ready)
);

endmodule
