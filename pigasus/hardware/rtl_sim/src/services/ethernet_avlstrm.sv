`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

module ethernet_avlstrm (
    input logic Clk, 
    input logic Rst_n,

    output  logic           out_valid,
    input   logic           out_ready,
    output  logic [511: 0]  out_data,
    output  logic           out_sop,
    output  logic           out_eop,
    output  logic [5 : 0]   out_empty,
    input   logic           out_almost_full,

    input   logic           in_sop,
    input   logic           in_eop,
    input   logic [511:0]   in_data,
    input   logic [5:0]     in_empty,
    input   logic           in_valid,
    output  logic           in_ready,

    avl_stream_if.tx in,
    avl_stream_if.rx out
);

    assign out_valid = out.valid;
    assign out_data = out.data;
    assign out_sop = out.sop;
    assign out_eop = out.eop;
    assign out_empty = out.empty;
    assign out.ready = out_ready;
    assign out.almost_full = out_almost_full;
    
   assign in.empty=in_empty;
   assign in.eop=in_eop;
   assign in.sop=in_sop;
   assign in.data = in_data; 
   assign in.valid = in_valid; 
   assign in_ready  = in.ready;

endmodule
