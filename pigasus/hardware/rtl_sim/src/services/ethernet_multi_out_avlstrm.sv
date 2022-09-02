`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"
`include "./src/stats_reg.sv"

// top-level module
module ethernet_multi_out_avlstrm 
  (
   input logic 	       Clk, 
   input logic 	       Rst_n,
		       
   avl_stream_if.rx eth_in,
   avl_stream_if.tx eth_out,
   
   avl_stream_if.tx in,
   avl_stream_if.rx out0,
   avl_stream_if.rx out1,
   avl_stream_if.rx out2,
   avl_stream_if.rx out3,
   avl_stream_if.rx out4,

   // stats channel			    
   avl_stream_if.tx stats_out
);
   logic [31:0]    in_pkt;
   logic [31:0]    out_pkt;

//System clock domain
always @ (posedge Clk) begin
    if (!Rst_n) begin
        in_pkt <= 0;
        out_pkt <= 0;
    end else begin
        if (eth_in.eop & eth_in.valid)begin
            in_pkt <= in_pkt + 1'b1;
            //DEBUG 
            if (in_pkt[5:0] == 6'b00_0000) begin
                $display("PKT %d", in_pkt);
            end
        end
        if (eth_out.eop & eth_out.valid & eth_out.ready)begin
            out_pkt <= out_pkt + 1'b1;
        end
    end
end

   stats_t in_pkt_s;
   stats_t out_pkt_s;
   
   assign in_pkt_s.addr = REG_IN_PKT;
   assign out_pkt_s.addr = REG_OUT_PKT;
   
   assign in_pkt_s.val = in_pkt;
   assign out_pkt_s.val = out_pkt;

   stats_packer_avlstrm #(2) stats_pack 
   (
    .Clk(Clk), 
    .Rst_n(Rst_n),
    
    .stats({
	    in_pkt_s,
	    out_pkt_s
	    }),
    
    .stats_out(stats_out)
   );

   `AVL_STREAM_PKT_IF((512), mux);
    
   assign in.empty=eth_in.empty;
   assign in.eop=eth_in.eop;
   assign in.sop=eth_in.sop;
   assign in.data = eth_in.data; 
   assign in.valid = eth_in.valid; 
   assign eth_in.ready  = in.ready;
    
    pkt_mux_avlstrm_3 mux_hi (
      .Clk(Clk), 
      .Rst_n(Rst_n),
    
      .in0(out0),
      .in1(out1),
      .in2(out2),
      .out(mux)
    );
    
    pkt_mux_avlstrm_3 mux_lo (
      .Clk(Clk), 
      .Rst_n(Rst_n),
    
      .in0(mux),
      .in1(out3),
      .in2(out4),
      .out(eth_out)
    );

endmodule
