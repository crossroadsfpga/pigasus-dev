`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"
`include "./src/stats_reg.sv"

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
    output logic [31:0]     stats_check_pkt_sop,
    output logic [31:0]     stats_bypass_pkt,
    output logic [31:0]     stats_bypass_pkt_sop,
    output logic [31:0]     stats_bypass_meta,
    output logic [31:0]     stats_bypass_rule,
    output logic [31:0] bypass_fill_level,
    output logic [31:0] bypass2nf_fill_level,
    output logic [31:0] nf2bypass_fill_level,
    output logic [31:0] nf_max_raw_pkt_fifo,
    output logic [31:0] nf_max_pkt_fifo,
    output logic [31:0] nf_max_rule_fifo,

    // stats channel			    
    avl_stream_if.tx stats_out,
			    
    avl_stream_if.rx in_pkt,
    avl_stream_if.rx in_meta,
    avl_stream_if.rx in_usr,
    avl_stream_if.tx nfp_nocheck,
    avl_stream_if.tx out_pkt,
    avl_stream_if.tx out_meta,
    avl_stream_if.tx out_usr
);

   reg [31:0] stats_bypass_max_fill_level_r;
   reg [31:0] stats_bypass2nf_max_fill_level_r;
   reg [31:0] stats_nf2bypass_max_fill_level_r;
   
   always@(posedge Clk) begin
      if (!Rst_n) begin
  	 stats_bypass_max_fill_level_r<=0;
 	 stats_bypass2nf_max_fill_level_r<=0;
 	 stats_nf2bypass_max_fill_level_r<=0;
      end else begin
	 if (stats_bypass_max_fill_level_r<bypass_fill_level) begin
	    stats_bypass_max_fill_level_r<=bypass_fill_level;
	 end
	 if (stats_bypass2nf_max_fill_level_r<bypass2nf_fill_level) begin
	    stats_bypass2nf_max_fill_level_r<=bypass2nf_fill_level;
	 end
	 if (stats_nf2bypass_max_fill_level_r<nf2bypass_fill_level) begin
	    stats_nf2bypass_max_fill_level_r<=nf2bypass_fill_level;
	 end
      end
   end

   stats_t stats_out_pkt_s;
   stats_t stats_out_meta_s;
   stats_t stats_out_rule_s;
   stats_t stats_nocheck_pkt_s;
   stats_t stats_check_pkt_s;
   stats_t stats_check_pkt_sop_s;
   stats_t stats_bypass_pkt_s;
   stats_t stats_bypass_pkt_sop_s;
   stats_t stats_bypass_meta_s;
   stats_t stats_bypass_rule_s;
   stats_t stats_bypass_max_fill_level_s;
   stats_t stats_bypass2nf_max_fill_level_s;
   stats_t stats_nf2bypass_max_fill_level_s;
   stats_t stats_nf_max_raw_pkt_fifo_s;
   stats_t stats_nf_max_pkt_fifo_s;
   stats_t stats_nf_max_rule_fifo_s;

   assign stats_out_pkt_s.addr = REG_NF_PKT;
   assign stats_out_meta_s.addr = REG_NF_META;
   assign stats_out_rule_s.addr = REG_NF_RULE;
   assign stats_nocheck_pkt_s.addr = REG_NF_NOCHECK_PKT;
   assign stats_check_pkt_s.addr = REG_NF_CHECK_PKT;
   assign stats_check_pkt_sop_s.addr = REG_NF_CHECK_PKT_SOP;
   assign stats_bypass_pkt_s.addr = REG_BYPASS_PKT;
   assign stats_bypass_pkt_sop_s.addr = REG_BYPASS_PKT_SOP;
   assign stats_bypass_meta_s.addr = REG_BYPASS_META;
   assign stats_bypass_rule_s.addr = REG_BYPASS_RULE;
   assign stats_bypass_max_fill_level_s.addr = REG_NOTUSED;
   assign stats_bypass2nf_max_fill_level_s.addr = REG_MAX_BYPASS2NF;
   assign stats_nf2bypass_max_fill_level_s.addr = REG_NOTUSED;
   assign stats_nf_max_raw_pkt_fifo_s.addr = REG_NOTUSED;
   assign stats_nf_max_pkt_fifo_s.addr = REG_NOTUSED;
   assign stats_nf_max_rule_fifo_s.addr = REG_NOTUSED;
   
   assign stats_out_pkt_s.val = stats_out_pkt;
   assign stats_out_meta_s.val = stats_out_meta;
   assign stats_out_rule_s.val = stats_out_rule;
   assign stats_nocheck_pkt_s.val = stats_nocheck_pkt;
   assign stats_check_pkt_s.val = stats_check_pkt;
   assign stats_check_pkt_sop_s.val = stats_check_pkt_sop;
   assign stats_bypass_pkt_s.val = stats_bypass_pkt;
   assign stats_bypass_pkt_sop_s.val = stats_bypass_pkt_sop;
   assign stats_bypass_meta_s.val = stats_bypass_meta;
   assign stats_bypass_rule_s.val = stats_bypass_rule;
   assign stats_bypass_max_fill_level_s.val = stats_bypass_max_fill_level_r;
   assign stats_bypass2nf_max_fill_level_s.val = stats_bypass2nf_max_fill_level_r;
   assign stats_nf2bypass_max_fill_level_s.val = stats_nf2bypass_max_fill_level_r;
   assign stats_nf_max_raw_pkt_fifo_s.val = nf_max_raw_pkt_fifo;
   assign stats_nf_max_pkt_fifo_s.val = nf_max_pkt_fifo;
   assign stats_nf_max_rule_fifo_s.val = nf_max_rule_fifo;

   stats_packer_avlstrm #(16) stats_pack 
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
	    stats_bypass_pkt_s,
	    stats_bypass_pkt_sop_s,
	    stats_bypass_meta_s,
	    stats_bypass_rule_s,
	    stats_bypass_max_fill_level_s,
	    stats_bypass2nf_max_fill_level_s,
	    stats_nf2bypass_max_fill_level_s,
	    stats_nf_max_raw_pkt_fifo_s, 
	    stats_nf_max_pkt_fifo_s,
	    stats_nf_max_rule_fifo_s
	    }),
    
    .stats_out(stats_out)
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
    .stats_in_pkt_sop(stats_bypass_pkt_sop),
    .stats_in_meta(stats_bypass_meta),
    .stats_in_rule(stats_bypass_rule),
    .in_pkt_fill_level(bypass_fill_level),

    .stats_out(stub[0]),
		
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
    .max_raw_pkt_fifo(nf_max_raw_pkt_fifo), // not connected
    .max_pkt_fifo(nf_max_pkt_fifo), // not connected
    .max_rule_fifo(nf_max_rule_fifo), // not connected

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
    .stats_out_pkt1_s (stats_check_pkt_sop),

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
