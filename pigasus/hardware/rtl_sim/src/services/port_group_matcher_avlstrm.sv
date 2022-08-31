`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"
`include "./src/stats_reg.sv"

// top-level module
module port_group_matcher_avlstrm  (
    input logic Clk, 
    input logic Rst_n,

    output logic [31:0]     stats_out_pkt,
    output logic [31:0]     stats_out_meta,
    output logic [31:0]     stats_out_rule,
    output logic [31:0]     stats_nocheck_pkt,
    output logic [31:0]     stats_check_pkt,
    output logic [31:0]     stats_check_pkt_sop,
    
    output  logic [31:0]    stats_no_pg_rule_cnt,
    output  logic [31:0]    stats_pg_rule_cnt,

    // stats channel			    
    avl_stream_if.tx stats_out,

    avl_stream_if.rx in_pkt,
    avl_stream_if.rx in_meta,
    avl_stream_if.rx in_usr,
    avl_stream_if.tx pg_nocheck,
    avl_stream_if.tx out_pkt,
    avl_stream_if.tx out_meta,
    avl_stream_if.tx out_usr
);

   stats_t stats_out_pkt_s;
   stats_t stats_out_meta_s;
   stats_t stats_out_rule_s;
   stats_t stats_nocheck_pkt_s;
   stats_t stats_check_pkt_s;
   stats_t stats_check_pkt_sop_s;
   stats_t stats_no_pg_rule_cnt_s;
   stats_t stats_pg_rule_cnt_s;

   assign stats_out_pkt_s.addr = REG_PG_PKT;
   assign stats_out_meta_s.addr = REG_PG_META;
   assign stats_out_rule_s.addr = REG_PG_RULE;
   assign stats_nocheck_pkt_s.addr = REG_PG_NOCHECK_PKT;
   assign stats_check_pkt_s.addr = REG_PG_CHECK_PKT;
   assign stats_check_pkt_sop_s.addr = REG_PG_CHECK_PKT_SOP;
   assign stats_no_pg_rule_cnt_s.addr = REG_NOTUSED;
   assign stats_pg_rule_cnt_s.addr = REG_NOTUSED;
   
   assign stats_out_pkt_s.val = stats_out_pkt;
   assign stats_out_meta_s.val = stats_out_meta;
   assign stats_out_rule_s.val = stats_out_rule;
   assign stats_nocheck_pkt_s.val = stats_nocheck_pkt;
   assign stats_check_pkt_s.val = stats_check_pkt;
   assign stats_check_pkt_sop_s.val = stats_check_pkt_sop;
   assign stats_no_pg_rule_cnt_s.val = stats_no_pg_rule_cnt;
   assign stats_pg_rule_cnt_s.val = stats_pg_rule_cnt;

   stats_packer_avlstrm #(8) stats_pack 
   (
    .Clk(Clk), 
    .Rst_n(Rst_n),
    
    .stats({
	    stats_out_pkt_s,
	    stats_out_meta_s,
	    stats_out_rule_s,
	    stats_nocheck_pkt_s,
	    stats_check_pkt_s,
	    stats_check_pkt_sop_s,
	    stats_no_pg_rule_cnt_s,
	    stats_pg_rule_cnt_s
	    }),
    
    .stats_out(stats_out)
   );

   avl_stream_if#(.WIDTH(512))               pg_pkt_ifc();

    port_group_avlstrm port_group_inst (
        .Clk(Clk), 
        .Rst_n(Rst_n),
    
        .stats_out_pkt (stats_out_pkt),
        .stats_out_meta(stats_out_meta),
        .stats_out_rule(stats_out_rule),  
        .stats_no_pg_rule_cnt(stats_no_pg_rule_cnt),
        .stats_pg_rule_cnt(stats_pg_rule_cnt),
    
        .in_pkt(in_pkt),
        .in_meta(in_meta),
        .in_usr(in_usr),
        .out_pkt(pg_pkt_ifc),
        .out_meta(out_meta),
        .out_usr(out_usr)
    );
    
    fork_avlstrm pg_fork (
        .Clk(Clk), 
        .Rst_n(Rst_n),
    
        .stats_out_pkt0   (stats_nocheck_pkt),
        .stats_out_pkt1   (stats_check_pkt),
        .stats_out_pkt1_s (stats_check_pkt_sop),
        
        .in(pg_pkt_ifc),
        .out0(pg_nocheck),
        .out1(out_pkt)
    );


endmodule
