`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

module fast_pm_avlstrm (
    input logic Clk, 
    input logic Rst_n,
    input logic Clk_front, 
    input logic Rst_front_n,
    input logic Clk_back, 
    input logic Rst_back_n,

    output logic [31:0]     stats_out_pkt,
    output logic [31:0]     stats_out_meta,
    output logic [31:0]     stats_out_rule,
    output logic [31:0]     stats_nocheck_pkt,
    output logic [31:0]     stats_check_pkt,
    output logic [31:0]     stats_check_pkt_s,
    output logic [31:0] sm_bypass_af,
    output logic [31:0] sm_cdc_af,

    avl_stream_if.rx in_pkt,
    avl_stream_if.rx in_meta,
    avl_stream_if.rx in_usr,
    avl_stream_if.tx fp_nocheck,
    avl_stream_if.tx out_pkt,
    avl_stream_if.tx out_meta,
    avl_stream_if.tx out_usr
);

    avl_stream_if#(.WIDTH(512))               sm_pkt_ifc();

    string_matcher_avlstrm sm_inst(
        .Clk(Clk), 
        .Rst_n(Rst_n),
        .Clk_front(Clk_front), 
        .Rst_front_n(Rst_front_n),
        .Clk_back(Clk_back), 
        .Rst_back_n(Rst_back_n),

        .stats_out_pkt (stats_out_pkt),
        .stats_out_meta(stats_out_meta),
        .stats_out_rule(stats_out_rule),  
        .sm_bypass_af(sm_bypass_af),
        .sm_cdc_af(sm_cdc_af),
    
        .in_pkt(in_pkt),
        .in_meta(in_meta),
        .out_pkt(sm_pkt_ifc),
        .out_meta(out_meta),
        .out_usr(out_usr)
    );
    
    fork_avlstrm sm_fork (
        .Clk(Clk_back), 
        .Rst_n(Rst_back_n),
    
        .stats_out_pkt0   (stats_nocheck_pkt),
        .stats_out_pkt1   (stats_check_pkt),
        .stats_out_pkt1_s (stats_check_pkt_s),

        .in(sm_pkt_ifc),
        .out0(fp_nocheck),
        .out1(out_pkt)
    );

endmodule
