`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

// top-level module
module channel_fifo_avlstrm #(
    parameter DUAL_CLOCK = 0
   ) (
    input logic Clk_i, 
    input logic Rst_n_i,
    input logic Clk_o, 
    input logic Rst_n_o,

    avl_stream_if.rx in_pkt,
    avl_stream_if.rx in_meta,
    avl_stream_if.rx in_usr,
    avl_stream_if.tx out_pkt,
    avl_stream_if.tx out_meta,
    avl_stream_if.tx out_usr,

    // stats channel			    
    avl_stream_if.tx stats_out,

  //// below the line ///////////////////////////////////////////////////////
    output logic [31:0] stats_in_pkt,
    output logic [31:0] stats_in_pkt_sop,
    output logic [31:0] stats_in_meta,
    output logic [31:0] stats_in_rule,
    output logic [31:0] in_pkt_fill_level,

    input logic [31:0] stats_in_pkt_addr,
    input logic [31:0] stats_in_pkt_sop_addr,
    input logic [31:0] stats_in_meta_addr,
    input logic [31:0] stats_in_rule_addr,
    input logic [31:0] stats_in_pkt_max_fill_level_addr
);

   reg [31:0] 	       stats_in_pkt_max_fill_level_r;
   always@(posedge Clk_i) begin
      if (!Rst_n_i) begin
	 stats_in_pkt_max_fill_level_r<=0;
      end else begin
	 if (stats_in_pkt_max_fill_level_r<in_pkt_fill_level) begin
	    stats_in_pkt_max_fill_level_r<=in_pkt_fill_level;
	 end
      end
   end
   
    stats_t stats_in_pkt_s;
    stats_t stats_in_pkt_sop_s;
    stats_t stats_in_meta_s;
    stats_t stats_in_rule_s;
    stats_t stats_in_pkt_max_fill_level_s;

    assign stats_in_pkt_s.addr = stats_in_pkt_addr;
    assign stats_in_pkt_sop_s.addr = stats_in_pkt_sop_addr;
    assign stats_in_meta_s.addr = stats_in_meta_addr;
    assign stats_in_rule_s.addr = stats_in_rule_addr;
    assign stats_in_pkt_max_fill_level_s.addr = stats_in_pkt_max_fill_level_addr;

    assign stats_in_pkt_s.val = stats_in_pkt;
    assign stats_in_pkt_sop_s.val = stats_in_pkt_sop;
    assign stats_in_meta_s.val = stats_in_meta;
    assign stats_in_rule_s.val = stats_in_rule;
    assign stats_in_pkt_max_fill_level_s.val = stats_in_pkt_max_fill_level_r;

   stats_packer_avlstrm #(5) stats_pack 
   (
    .Clk(Clk_i), 
    .Rst_n(Rst_n_i),
    
    .stats({
	    stats_in_pkt_s,
	    stats_in_pkt_sop_s,
	    stats_in_meta_s,
	    stats_in_rule_s,
	    stats_in_pkt_max_fill_level_s
	    }),
    
    .stats_out(stats_out)
   );

channel_fifo#(
    .DUAL_CLOCK(DUAL_CLOCK)
   ) FIFO(
    .in_clk                 (Clk_i),
    .in_rst                 (~Rst_n_i),
    .out_clk                 (Clk_o),
    .out_rst                 (~Rst_n_o),
    .in_pkt_sop             (in_pkt.sop),
    .in_pkt_eop             (in_pkt.eop),
    .in_pkt_data            (in_pkt.data),
    .in_pkt_empty           (in_pkt.empty),
    .in_pkt_valid           (in_pkt.valid),
    .in_pkt_ready           (in_pkt.ready),
    .in_pkt_almost_full     (in_pkt.almost_full),
    .in_meta_valid          (in_meta.valid),
    .in_meta_data           (in_meta.data),
    .in_meta_ready          (in_meta.ready),
    .in_meta_almost_full    (in_meta.almost_full),
    .in_usr_sop             (in_usr.sop),
    .in_usr_eop             (in_usr.eop),
    .in_usr_data            (in_usr.data),
    .in_usr_empty           (in_usr.empty),
    .in_usr_valid           (in_usr.valid),
    .in_usr_ready           (in_usr.ready),
    .in_usr_almost_full     (in_usr.almost_full),
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
    .out_meta_almost_full   (out_meta.almost_full),
    .out_meta_channel       (out_meta.channel),
    .out_usr_sop            (out_usr.sop),
    .out_usr_eop            (out_usr.eop),
    .out_usr_data           (out_usr.data),
    .out_usr_empty          (out_usr.empty),
    .out_usr_valid          (out_usr.valid),
    .out_usr_ready          (out_usr.ready),
    .out_usr_almost_full    (out_usr.almost_full),
    .out_usr_channel        (out_usr.channel),
    .in_pkt_fill_level      (in_pkt_fill_level)
);

    stats_cnt in_meta_inst(
        .Clk        (Clk_i),
        .Rst_n      (Rst_n_i),
        .valid      (in_meta.valid),
        .ready      (in_meta.ready),
        .stats_flit (stats_in_meta)
    );

    stats_cnt in_pkt_inst(
        .Clk        (Clk_i),
        .Rst_n      (Rst_n_i),
        .valid      (in_pkt.valid),
        .ready      (in_pkt.ready),
        .eop        (in_pkt.eop),
        .sop        (in_pkt.sop),
        .stats_pkt  (stats_in_pkt),
        .stats_pkt_sop  (stats_in_pkt_sop)
    );

    stats_cnt_rule in_rule_inst(
        .Clk        (Clk_i),
        .Rst_n      (Rst_n_i),
        .valid      (in_usr.valid),
        .ready      (in_usr.ready),
        .data       (in_usr.data),
        .eop        (in_usr.eop),
        .sop        (in_usr.sop),
        .stats_rule (stats_in_rule)
    );

endmodule
