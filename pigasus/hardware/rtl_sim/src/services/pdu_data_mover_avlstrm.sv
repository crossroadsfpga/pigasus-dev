`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

// submodule not used?
module pdu_data_mover_avlstrm (
    input logic Clk, 
    input logic Rst_n,

    // DRAM
    output  ddr_wr_t                 ddr_wr_req_data,
    output  logic                    ddr_wr_req_valid,
    input   logic                    ddr_wr_req_almost_full,
    output  ddr_rd_t                 ddr_rd_req_data,
    output  logic                    ddr_rd_req_valid,
    input   logic                    ddr_rd_req_almost_full,
    input   logic [511:0]            ddr_rd_resp_data,
    input   logic                    ddr_rd_resp_valid,
    output  logic                    ddr_rd_resp_almost_full,

    avl_stream_if.rx pdu_meta_cpu,
    avl_stream_if.rx pdu_meta,
    avl_stream_if.rx pdu_pkt,
    avl_stream_if.tx emptylist,
    avl_stream_if.tx nomatch_pkt
);

unified_fifo  #(
    .FIFO_NAME        ("[top] ddr_resp_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (512),
    .FIFO_DEPTH       (512)) 
 ddr_resp_fifo (
    .in_clk            (Clk),
    .in_reset          (~Rst_n),
    .out_clk           (),//not used
    .out_reset         (),//not used
    .in_data           (ddr_rd_resp_data),
    .in_valid          (ddr_rd_resp_valid),
    .in_ready          (ddr_rd_resp_ready),
    .out_data          (ddr_rd_resp_out_data),
    .out_valid         (ddr_rd_resp_out_valid),
    .out_ready         (ddr_rd_resp_out_ready),
    .fill_level        (),
    .almost_full       (ddr_rd_resp_almost_full),
    .overflow          ()
);

pdu_data_mover pdu_data_mover_inst (
    .clk                    (Clk),
    .rst                    (~Rst_n),
    .pdu_emptylist_out_data (emptylist.data),
    .pdu_emptylist_out_valid(emptylist.valid),
    .pdu_emptylist_out_ready(emptylist.ready),
    .pdumeta_gen_data       (pdu_meta.data),
    .pdumeta_gen_valid      (pdu_meta.valid),
    .pdumeta_gen_ready      (pdu_meta.ready),
    .pdu_gen_data           (pdu_pkt.data),
    .pdu_gen_sop            (pdu_pkt.sop),
    .pdu_gen_eop            (pdu_pkt.eop),
    .pdu_gen_empty          (pdu_pkt.empty),
    .pdu_gen_valid          (pdu_pkt.valid),
    .pdu_gen_ready          (pdu_pkt.ready),
    .pdu_gen_almost_full    (pdu_pkt.almost_full),
    .pdumeta_cpu_data       (pdu_meta_cpu.data),
    .pdumeta_cpu_valid      (pdu_meta_cpu.valid),
    .pdumeta_cpu_ready      (pdu_meta_cpu






.ready),
    .nocheck_data           (),
    .nocheck_sop            (),
    .nocheck_eop            (),
    .nocheck_valid          (),
    .nocheck_empty          (),
    .nocheck_ready          (),                     // Not using ready signal,
    .nocheck_almost_full    (1'b0),  // Use almost_full signal
    .nomatch_data           (nomatch_pkt.data),
    .nomatch_sop            (nomatch_pkt.sop),
    .nomatch_eop            (nomatch_pkt.eop),
    .nomatch_valid          (nomatch_pkt.valid),
    .nomatch_empty          (nomatch_pkt.empty),
    .nomatch_ready          (),                     // Not using ready signal,
    .nomatch_almost_full    (nomatch_pkt.almost_full),  // Use almost_full signal
    .ddr_wr_req_data        (ddr_wr_req_data),
    .ddr_wr_req_valid       (ddr_wr_req_valid),
    .ddr_wr_req_almost_full (ddr_wr_req_almost_full),
    .ddr_rd_req_data        (ddr_rd_req_data),
    .ddr_rd_req_valid       (ddr_rd_req_valid),
    .ddr_rd_req_almost_full (ddr_rd_req_almost_full),
    .ddr_rd_resp_data       (ddr_rd_resp_out_data),
    .ddr_rd_resp_valid      (ddr_rd_resp_out_valid),
    .ddr_rd_resp_ready      (ddr_rd_resp_out_ready)
);

endmodule
