`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

module non_fast_pattern_avlstrm (
    input logic Clk, 
    input logic Rst_n,
    input logic Clk_high, 
    input logic Rst_high_n,

    //stats
    output logic [31:0]     stats_out_pkt,
    output logic [31:0]     stats_out_meta,
    output logic [31:0]     stats_out_rule,
    output  logic [31:0]    max_raw_pkt_fifo,
    output  logic [31:0]    max_pkt_fifo,
    output  logic [31:0]    max_rule_fifo,

    avl_stream_if.rx in_pkt,
    avl_stream_if.rx in_meta,
    avl_stream_if.rx in_usr,
    avl_stream_if.tx out_pkt,
    avl_stream_if.tx out_meta,
    avl_stream_if.tx out_usr
);

    non_fast_pattern_wrapper non_fast_pattern_inst(
        .clk                    (Clk),
        .rst                    (~Rst_n),
        .clk_high               (Clk_high),
        .rst_high               (~Rst_high_n),
        .in_pkt_sop             (in_pkt.sop),
        .in_pkt_eop             (in_pkt.eop),
        .in_pkt_data            (in_pkt.data),
        .in_pkt_empty           (in_pkt.empty),
        .in_pkt_valid           (in_pkt.valid),
        .in_pkt_ready           (in_pkt.ready),
        .in_pkt_almost_full     (),
        .in_meta_valid          (in_meta.valid),
        .in_meta_ready          (in_meta.ready),
        .in_meta_data           (in_meta.data),
        .in_meta_almost_full    (),
        .in_usr_sop             (in_usr.sop),
        .in_usr_eop             (in_usr.eop),
        .in_usr_data            (in_usr.data),
        .in_usr_empty           (in_usr.empty),
        .in_usr_valid           (in_usr.valid),
        .in_usr_ready           (in_usr.ready),
        .out_pkt_data           (out_pkt.data),
        .out_pkt_sop            (out_pkt.sop),
        .out_pkt_eop            (out_pkt.eop),
        .out_pkt_empty          (out_pkt.empty),
        .out_pkt_valid          (out_pkt.valid),
        .out_pkt_ready          (out_pkt.ready),
        .out_pkt_almost_full    (out_pkt.almost_full),
        .out_pkt_channel        (out_pkt.channel),
        .out_meta_data          (out_meta.data),
        .out_meta_valid         (out_meta.valid),
        .out_meta_ready         (out_meta.ready),
        .out_meta_almost_full   (out_meta.almost_full),
        .out_meta_channel       (),
        .out_usr_data           (out_usr.data),
        .out_usr_sop            (out_usr.sop),
        .out_usr_eop            (out_usr.eop),
        .out_usr_empty          (out_usr.empty),
        .out_usr_valid          (out_usr.valid),
        .out_usr_ready          (out_usr.ready),
        .out_usr_almost_full    (out_usr.almost_full),
        .out_usr_channel        (),
        .max_raw_pkt_fifo       (max_raw_pkt_fifo),
        .max_pkt_fifo           (max_pkt_fifo),
        .max_rule_fifo          (max_rule_fifo)
    );

    //stats
    stats_cnt out_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (out_meta.valid),
        .ready      (out_meta.ready),
        .stats_flit (stats_out_meta)
    );
    stats_cnt out_pkt_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (out_pkt.valid),
        .ready      (out_pkt.ready),
        .eop        (out_pkt.eop),
        .sop        (out_pkt.sop),
        .stats_pkt  (stats_out_pkt)
    );
    stats_cnt_rule out_rule_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (out_usr.valid),
        .ready      (out_usr.ready),
        .data       (out_usr.data),
        .eop        (out_usr.eop),
        .sop        (out_usr.sop),
        .stats_rule (stats_out_rule)
    );

endmodule
