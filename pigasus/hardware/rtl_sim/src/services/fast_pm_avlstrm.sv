`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"
`include "./src/stats_reg.sv"

module fast_pm_avlstrm 
  (
    input logic 	Clk, 
    input logic 	Rst_n,
    input logic 	Clk_front, 
    input logic 	Rst_front_n,
    input logic 	Clk_back, 
    input logic 	Rst_back_n,

   // Clk_back domain
    output logic [31:0] stats_out_pkt,
    output logic [31:0] stats_out_meta,
    output logic [31:0] stats_out_rule,
    output logic [31:0] stats_nocheck_pkt,
    output logic [31:0] stats_check_pkt,
    output logic [31:0] stats_check_pkt_sop,
			
   // Clk domain
    output logic [31:0] sm_bypass_af,
    output logic [31:0] sm_cdc_af,
   
   avl_stream_if.tx stats_out,
   avl_stream_if.tx stats_out_back,
   
   avl_stream_if.rx in_pkt,
   avl_stream_if.rx in_meta,
   avl_stream_if.rx in_usr,
   avl_stream_if.tx fp_nocheck,
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
    stats_t sm_bypass_af_s;
    stats_t sm_cdc_af_s;

    assign stats_out_pkt_s.addr = REG_SM_PKT;
    assign stats_out_meta_s.addr = REG_SM_META;
    assign stats_out_rule_s.addr = REG_SM_RULE;
    assign stats_nocheck_pkt_s.addr = REG_SM_NOCHECK_PKT;
    assign stats_check_pkt_s.addr = REG_SM_CHECK_PKT;
    assign stats_check_pkt_sop_s.addr = REG_SM_CHECK_PKT_SOP;
    assign sm_bypass_af_s.addr = REG_SM_BYPASS_AF;
    assign sm_cdc_af_s.addr = REG_SM_CDC_AF;

    assign stats_out_pkt_s.val = stats_out_pkt;
    assign stats_out_meta_s.val = stats_out_meta;
    assign stats_out_rule_s.val = stats_out_rule;
    assign stats_nocheck_pkt_s.val = stats_nocheck_pkt;
    assign stats_check_pkt_s.val = stats_check_pkt;
    assign stats_check_pkt_sop_s.val = stats_check_pkt_sop;
    assign sm_bypass_af_s.val = sm_bypass_af;
    assign sm_cdc_af_s.val = sm_cdc_af;

   stats_packer_avlstrm #(2) stats_pack 
   (
    .Clk(Clk), 
    .Rst_n(Rst_n),
    
    .stats({
	     sm_bypass_af_s,
	     sm_cdc_af_s	    
	    }),
    
    .stats_out(stats_out)
    );
   

   stats_packer_avlstrm #(6) stats_pack_back 
   (
    .Clk(Clk_back), 
    .Rst_n(Rst_back_n),
    
    .stats({
	     stats_out_pkt_s,
	     stats_out_meta_s,
	     stats_out_rule_s,
	     stats_nocheck_pkt_s,
	     stats_check_pkt_s,
	     stats_check_pkt_sop_s
	    }),
    
    .stats_out(stats_out_back)
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
        .stats_out_pkt1_s (stats_check_pkt_sop),

        .in(sm_pkt_ifc),
        .out0(fp_nocheck),
        .out1(out_pkt)
    );

endmodule
