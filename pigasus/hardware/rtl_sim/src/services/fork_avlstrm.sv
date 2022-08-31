`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

// submodule multiple
module fork_avlstrm (
    input logic Clk, 
    input logic Rst_n,

    avl_stream_if.rx in,
    avl_stream_if.tx out0,
    avl_stream_if.tx out1,

    output logic [31:0]     stats_in_pkt,
    output logic [31:0]     stats_out_pkt0,
    output logic [31:0]     stats_out_pkt1,
    output logic [31:0]     stats_in_pkt_s,
    output logic [31:0]     stats_out_pkt0_s,
    output logic [31:0]     stats_out_pkt1_s
);

    fork_2 sm_fork (
        .clk                   (Clk),
        .rst                   (Rst_n),
        .in_pkt_data           (in.data),
        .in_pkt_valid          (in.valid),
        .in_pkt_ready          (in.ready),
        .in_pkt_sop            (in.sop),
        .in_pkt_eop            (in.eop),
        .in_pkt_empty          (in.empty),
        .in_pkt_almost_full    (in.almost_full),
        .in_pkt_channel        (in.channel),
        .out_pkt_0_data        (out0.data),
        .out_pkt_0_valid       (out0.valid),
        .out_pkt_0_ready       (out0.ready),
        .out_pkt_0_sop         (out0.sop),
        .out_pkt_0_eop         (out0.eop),
        .out_pkt_0_empty       (out0.empty),
        .out_pkt_0_almost_full (out0.almost_full),
        .out_pkt_1_data        (out1.data),
        .out_pkt_1_valid       (out1.valid),
        .out_pkt_1_ready       (out1.ready),
        .out_pkt_1_sop         (out1.sop),
        .out_pkt_1_eop         (out1.eop),
        .out_pkt_1_empty       (out1.empty),
        .out_pkt_1_almost_full (out1.almost_full)
    );

    stats_cnt in_pkt_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (in.valid),
        .ready      (in.ready),
        .eop        (in.eop),
        .sop        (in.sop),
        .stats_pkt  (stats_in_pkt),
        .stats_pkt_sop  (stats_in_pkt_s)
    );
    stats_cnt out_pkt0_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (out0.valid),
        .ready      (out0.ready),
        .eop        (out0.eop),
        .sop        (out0.sop),
        .stats_pkt  (stats_out_pkt0),
        .stats_pkt_sop  (stats_out_pkt0_s)
    );
    stats_cnt out_pkt1_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (out1.valid),
        .ready      (out1.ready),
        .eop        (out1.eop),
        .sop        (out1.sop),
        .stats_pkt  (stats_out_pkt1),
        .stats_pkt_sop  (stats_out_pkt1_s)
    );

endmodule
