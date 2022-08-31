`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"
`include "./src/stats_reg.sv"

// top-level module
module ethernet_multi_out_avlstrm 
  (
   input logic 	       Clk, 
   input logic 	       Rst_n,
		       
   output reg 	       out_valid,
   input 	       out_ready,
   output reg [511: 0] out_data,
   output reg 	       out_sop,
   output reg 	       out_eop,
   output reg [5 : 0]  out_empty,
   input 	       out_almostfull,

   input logic 	       in_sop,
   input logic 	       in_eop,
   input logic [511:0] in_data,
   input logic [5:0]   in_empty,
   input logic 	       in_valid,
   output logic        in_ready,

   //avl_stream_if.rx in;
   //avl_stream_if.rx out;
   
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
        if (in_eop & in_valid)begin
            in_pkt <= in_pkt + 1'b1;
            //DEBUG 
            if (in_pkt[5:0] == 6'b00_0000) begin
                $display("PKT %d", in_pkt);
            end
        end
        if (out_eop & out_valid & out_ready)begin
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

    avl_stream_if#(.WIDTH(512)) mux();
    avl_stream_if#(.WIDTH(512)) out();
    
    assign out_valid = out.valid;
    assign out_data = out.data;
    assign out_sop = out.sop;
    assign out_eop = out.eop;
    assign out_empty = out.empty;
    assign out.ready = out_ready;
    assign out.almost_full = out_almostfull;
    
   assign in.empty=in_empty;
   assign in.eop=in_eop;
   assign in.sop=in_sop;
   assign in.data = in_data; 
   assign in.valid = in_valid; 
   assign in_ready  = in.ready;
    
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
      .out(out)
    );

endmodule
