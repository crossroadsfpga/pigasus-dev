`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

module ethernet_multi_out_avlstrm (
    input logic Clk, 
    input logic Rst_n,

    output reg              out_valid,
    input                   out_ready,
    output reg    [511: 0]  out_data,
    output reg              out_sop,
    output reg              out_eop,
    output reg    [5 : 0]   out_empty,
    input                   out_almostfull,

    input   logic           in_sop,
    input   logic           in_eop,
    input   logic [511:0]   in_data,
    input   logic [5:0]     in_empty,
    input   logic           in_valid,
    output  logic           in_ready,

    avl_stream_if.tx in,
    avl_stream_if.rx out0,
    avl_stream_if.rx out1,
    avl_stream_if.rx out2,
    avl_stream_if.rx out3,
    avl_stream_if.rx out4
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
