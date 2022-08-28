`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

module non_fast_pm_avlstrm (
    input logic Clk, 
    input logic Rst_n,
    input logic Clk_high, 
    input logic Rst_high_n,
    
    //stats
    output logic [31:0]     stats_out_pkt,
    output logic [31:0]     stats_out_meta,
    output logic [31:0]     stats_out_rule,
    output logic [31:0]     stats_nocheck_pkt,
    output logic [31:0]     stats_check_pkt,
    output logic [31:0]     stats_check_pkt_s,
    output logic [31:0]     stats_bypass_pkt,
    output logic [31:0]     stats_bypass_pkt_s,
    output logic [31:0]     stats_bypass_meta,
    output logic [31:0]     stats_bypass_rule,
    output logic [31:0] bypass_fill_level,
    output logic [31:0] bypass2nf_fill_level,
    output logic [31:0] nf2bypass_fill_level,
    output logic [31:0] nf_max_raw_pkt_fifo,
    output logic [31:0] nf_max_pkt_fifo,
    output logic [31:0] nf_max_rule_fifo,

    avl_stream_if.rx in_pkt,
    avl_stream_if.rx in_meta,
    avl_stream_if.rx in_usr,
    avl_stream_if.tx nfp_nocheck,
    avl_stream_if.tx out_pkt,
    avl_stream_if.tx out_meta,
    avl_stream_if.tx out_usr
);

    avl_stream_if#(.WIDTH(512))               nf_in_pkt_ifc();
    avl_stream_if#(.WIDTH($bits(metadata_t))) nf_in_meta_ifc();
    avl_stream_if#(.WIDTH(512))               nf_in_rule_ifc();
    avl_stream_if#(.WIDTH(512))               bypass_pkt_ifc();
    avl_stream_if#(.WIDTH($bits(metadata_t))) bypass_meta_ifc();
    avl_stream_if#(.WIDTH(512))               bypass_rule_ifc();
    avl_stream_if#(.WIDTH(512))               nf_in_pkt_fifo_ifc();
    avl_stream_if#(.WIDTH($bits(metadata_t))) nf_in_meta_fifo_ifc();
    avl_stream_if#(.WIDTH(512))               nf_in_rule_fifo_ifc();
    avl_stream_if#(.WIDTH(512))               bypass_pkt_fifo_ifc();
    avl_stream_if#(.WIDTH($bits(metadata_t))) bypass_meta_fifo_ifc();
    avl_stream_if#(.WIDTH(512))               bypass_rule_fifo_ifc();
    avl_stream_if#(.WIDTH(512))               nf_pkt_ifc();
    avl_stream_if#(.WIDTH($bits(metadata_t))) nf_meta_ifc();
    avl_stream_if#(.WIDTH(512))               nf_rule_ifc();
    avl_stream_if#(.WIDTH(512))               nf_check_pkt_ifc();
    avl_stream_if#(.WIDTH(512))               nf_check_pkt_fifo_ifc();
    avl_stream_if#(.WIDTH($bits(metadata_t))) nf_meta_fifo_ifc();
    avl_stream_if#(.WIDTH(512))               nf_rule_fifo_ifc();

////////////////////// Bypass Front//////////////////////////////////
bypass_front_avlstrm bypass_nf_front_inst(
    .Clk(Clk), 
    .Rst_n(Rst_n),

    .in_pkt(in_pkt),
    .in_meta(in_meta),
    .in_usr(in_usr),
    .out_pkt(nf_in_pkt_ifc),
    .out_meta(nf_in_meta_ifc),
    .out_usr(nf_in_rule_ifc),
    .bypass_pkt(bypass_pkt_ifc),
    .bypass_meta(bypass_meta_ifc),
    .bypass_usr(bypass_rule_ifc)
);

////////////////////// Bypass channel //////////////////////////////////
avl_stream_if#(.WIDTH($bits(stats_t)))stub[3]();
assign stub[0].tx.ready=0;
assign stub[1].tx.ready=0;
assign stub[2].tx.ready=0;
   

channel_fifo_avlstrm #(
    .DUAL_CLOCK (0)
) bypass_FIFO(
    .Clk_i(Clk), 
    .Rst_n_i(Rst_n),

    .stats_in_pkt(stats_bypass_pkt),
    .stats_in_pkt_sop(stats_bypass_pkt_s),
    .stats_in_meta(stats_bypass_meta),
    .stats_in_rule(stats_bypass_rule),
    .in_pkt_fill_level(bypass_fill_level),

    .stats_out(stub[0]),
        .stats_in_pkt_max_fill_level_addr(3),
        .stats_in_pkt_addr(4),
        .stats_in_pkt_sop_addr(5),
        .stats_in_meta_addr(6),
        .stats_in_rule_addr(7),
		
    .in_pkt(bypass_pkt_ifc),
    .in_meta(bypass_meta_ifc),
    .in_usr(bypass_rule_ifc),
    .out_pkt(bypass_pkt_fifo_ifc),
    .out_meta(bypass_meta_fifo_ifc),
    .out_usr(bypass_rule_fifo_ifc)
);

////////////////////// Bypass to Non-fast pattern channel //////////////////////////////////
channel_fifo_avlstrm #(
    .DUAL_CLOCK (0)
) bypassfront2nf_FIFO(
    .Clk_i(Clk), 
    .Rst_n_i(Rst_n),

    .in_pkt_fill_level(bypass2nf_fill_level),

    .stats_out(stub[1]),

        .stats_in_pkt_max_fill_level_addr(8),
        .stats_in_pkt_addr(9),
        .stats_in_pkt_sop_addr(10),
        .stats_in_meta_addr(11),
        .stats_in_rule_addr(12),

    .in_pkt  (nf_in_pkt_ifc),
    .in_meta (nf_in_meta_ifc),
    .in_usr  (nf_in_rule_ifc),
    .out_pkt (nf_in_pkt_fifo_ifc),
    .out_meta(nf_in_meta_fifo_ifc),
    .out_usr (nf_in_rule_fifo_ifc)
);

////////////////////// Non Fast Pattern //////////////////////////////////
non_fast_pattern_avlstrm non_fast_pattern_inst(
    .Clk(Clk), 
    .Rst_n(Rst_n),
    .Clk_high(Clk_high), 
    .Rst_high_n(Rst_high_n),

    .stats_out_pkt (stats_out_pkt),
    .stats_out_meta(stats_out_meta),
    .stats_out_rule(stats_out_rule),  
    .max_raw_pkt_fifo(nf_max_raw_pkt_fifo),
    .max_pkt_fifo(nf_max_pkt_fifo),
    .max_rule_fifo(nf_max_rule_fifo),

    .in_pkt(nf_in_pkt_fifo_ifc),
    .in_meta(nf_in_meta_fifo_ifc),
    .in_usr(nf_in_rule_fifo_ifc),
    .out_pkt(nf_pkt_ifc),
    .out_meta(nf_meta_ifc),
    .out_usr(nf_rule_ifc)
);

fork_avlstrm nf_fork (
    .Clk(Clk), 
    .Rst_n(Rst_n),

    .stats_out_pkt0   (stats_nocheck_pkt),
    .stats_out_pkt1   (stats_check_pkt),
    .stats_out_pkt1_s (stats_check_pkt_s),

    .in(nf_pkt_ifc),
    .out0(nfp_nocheck),
    .out1(nf_check_pkt_ifc)
);

channel_fifo_avlstrm #(
    .DUAL_CLOCK (0)
) nf2bypassback_FIFO(
    .Clk_i(Clk), 
    .Rst_n_i(Rst_n),

    .in_pkt_fill_level(nf2bypass_fill_level),

    .stats_out(stub[2]),

        .stats_in_pkt_max_fill_level_addr(13),
        .stats_in_pkt_addr(14),
        .stats_in_pkt_sop_addr(15),
        .stats_in_meta_addr(16),
        .stats_in_rule_addr(17),

    .in_pkt(nf_check_pkt_ifc),
    .in_meta(nf_meta_ifc),
    .in_usr(nf_rule_ifc),
    .out_pkt(nf_check_pkt_fifo_ifc),
    .out_meta(nf_meta_fifo_ifc),
    .out_usr(nf_rule_fifo_ifc)
);

////////////////////// Bypass Back//////////////////////////////////
bypass_back_avlstrm bypass_nf_back_inst (
    .Clk(Clk), 
    .Rst_n(Rst_n),

    .in_pkt(nf_check_pkt_fifo_ifc),
    .in_meta(nf_meta_fifo_ifc),
    .in_usr(nf_rule_fifo_ifc),
    .bypass_pkt(bypass_pkt_fifo_ifc),
    .bypass_meta(bypass_meta_fifo_ifc),
    .bypass_usr(bypass_rule_fifo_ifc),
    .out_pkt(out_pkt),
    .out_meta(out_meta),
    .out_usr(out_usr)
);


endmodule
