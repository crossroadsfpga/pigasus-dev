`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

// sm submodule
module string_matcher_avlstrm (
    input logic Clk, 
    input logic Rst_n,
    input logic Clk_front, 
    input logic Rst_front_n,
    input logic Clk_back, 
    input logic Rst_back_n,

    avl_stream_if.rx in_pkt,
    avl_stream_if.rx in_meta,
    avl_stream_if.tx out_pkt,
    avl_stream_if.tx out_meta,
    avl_stream_if.tx out_usr,

    //stats
    output logic [31:0]     stats_out_pkt,
    output logic [31:0]     stats_out_meta,
    output logic [31:0]     stats_out_rule,

    output logic [31:0]     sm_bypass_af,
    output logic [31:0]     sm_cdc_af
);
    string_matcher_wrapper sm_inst(
        .clk                    (Clk),
        .rst                    (~Rst_n),
        .front_clk              (Clk_front),
        .front_rst              (~Rst_front_n),
        .back_clk               (Clk_back),
        .back_rst               (~Rst_back_n),
        //.in_pkt_hdr             (dm_check_pkt_hdr),
        .in_pkt_sop             (in_pkt.sop),
        .in_pkt_eop             (in_pkt.eop),
        .in_pkt_data            (in_pkt.data),
        .in_pkt_empty           (in_pkt.empty),
        .in_pkt_valid           (in_pkt.valid),
        .in_pkt_ready           (in_pkt.ready),
        .in_pkt_almost_full     (),
        .in_meta_valid          (in_meta.valid),
        .in_meta_data           (in_meta.data),
        .in_meta_ready          (in_meta.ready),
        .in_meta_almost_full    (),
        //no usr input
        .in_usr_sop             (1'b0),
        .in_usr_eop             (1'b0),
        .in_usr_data            (512'b0),
        .in_usr_empty           (6'b0),
        .in_usr_valid           (1'b0),
        .in_usr_ready           (),
        .out_pkt_sop            (out_pkt.sop),
        .out_pkt_eop            (out_pkt.eop),
        .out_pkt_data           (out_pkt.data),
        .out_pkt_empty          (out_pkt.empty),
        .out_pkt_valid          (out_pkt.valid),
        .out_pkt_ready          (out_pkt.ready),
        .out_pkt_almost_full    (out_pkt.almost_full),
        .out_pkt_channel        (out_pkt.channel),
        .out_meta_valid         (out_meta.valid),
        .out_meta_data          (out_meta.data),
        .out_meta_ready         (out_meta.ready),
        .out_meta_almost_full   (1'b0),
        .out_meta_channel       (),
        .out_usr_sop            (out_usr.sop),
        .out_usr_eop            (out_usr.eop),
        .out_usr_data           (out_usr.data),
        .out_usr_empty          (out_usr.empty),
        .out_usr_valid          (out_usr.valid),
        .out_usr_ready          (out_usr.ready),
        .out_usr_almost_full    (out_usr.almost_full),
        .out_usr_channel        (),
        .sm_bypass_af           (sm_bypass_af),
        .sm_cdc_af              (sm_cdc_af)
    );

    //stats
    stats_cnt out_meta_inst(
        .Clk        (Clk_back),
        .Rst_n      (Rst_back_n),
        .valid      (out_meta.valid),
        .ready      (out_meta.ready),
        .stats_flit (stats_out_meta)
    );
    stats_cnt out_pkt_inst(
        .Clk        (Clk_back),
        .Rst_n      (Rst_back_n),
        .valid      (out_pkt.valid),
        .ready      (out_pkt.ready),
        .eop        (out_pkt.eop),
        .sop        (out_pkt.sop),
        .stats_pkt  (stats_out_pkt)
    );
    stats_cnt_rule out_rule_inst(
        .Clk        (Clk_back),
        .Rst_n      (Rst_back_n),
        .valid      (out_usr.valid),
        .ready      (out_usr.ready),
        .data       (out_usr.data),
        .eop        (out_usr.eop),
        .sop        (out_usr.sop),
        .stats_rule (stats_out_rule)
    );

endmodule
