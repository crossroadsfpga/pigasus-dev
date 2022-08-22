`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

module ethernet_mux_avlstrm (
    input logic Clk, 
    input logic Rst_n,

    output reg              out_valid,
    input                   out_ready,
    output reg    [511: 0]  out_data,
    output reg              out_startofpacket,
    output reg              out_endofpacket,
    output reg    [5 : 0]   out_empty,

    avl_stream_if.rx in0,
    avl_stream_if.rx in1,
    avl_stream_if.rx in2,
    avl_stream_if.rx in3,
    avl_stream_if.rx in4
);
  server#(.DATA_BITS(512)) mux();
  server#(.DATA_BITS(512)) out();

  assign out_valid = out.txP.tx;
  assign out_data = out.txP.tx_msg.data;
  assign out_startofpacket = out.txP.tx_msg.head.arg3[0];
  assign out_endofpacket = out.txP.tx_msg.head.arg3[1];
  assign out_empty = out.txP.tx_msg.head.arg3[7:2];
  assign out.txFull = ~out_ready;

  pkt_mux_avlstrm_3 mux_hi (
    .Clk(Clk), 
    .Rst_n(Rst_n),

    .in0(in0),
    .in1(in1),
    .in2(in2),
    .out(mux)
  );

  pkt_mux_avlstrm_3 mux_lo (
    .Clk(Clk), 
    .Rst_n(Rst_n),

    .in0(mux),
    .in1(in3),
    .in2(in4),
    .out(out)
  );

endmodule

module pkt_mux_avlstrm (
    input logic Clk, 
    input logic Rst_n,

    avl_stream_if.rx in0,
    avl_stream_if.rx in1,
    avl_stream_if.tx out
);

st_multiplexer_pkt multiplexer_nf (
    .clk               (Clk),
    .reset_n           (Rst_n),
    .out_data          (out.data),
    .out_valid         (out.valid),
    .out_ready         (out.ready),
    .out_startofpacket (out.sop),
    .out_endofpacket   (out.eop),
    .out_empty         (out.empty),
    .out_channel       (),
    .in0_data          (in0.data),
    .in0_valid         (in0.valid),
    .in0_ready         (in0.ready),
    .in0_startofpacket (in0.sop),
    .in0_endofpacket   (in0.eop),
    .in0_empty         (in0.empty),
    .in1_data          (in1.data),
    .in1_valid         (in1.valid),
    .in1_ready         (in1.ready),
    .in1_startofpacket (in1.sop),
    .in1_endofpacket   (in1.eop),
    .in1_empty         (in1.empty)
);

endmodule

module pkt_mux_avlstrm_3 (
    input logic Clk, 
    input logic Rst_n,

    avl_stream_if.rx in0,
    avl_stream_if.rx in1,
    avl_stream_if.rx in2,
    avl_stream_if.tx out
);

st_multiplexer_pkt_3 multiplexer_pkt1 (
    .clk               (Clk),
    .reset_n           (Rst_n),
    .out_data          (out.data),
    .out_valid         (out.valid),
    .out_ready         (out.ready),
    .out_startofpacket (out.sop),
    .out_endofpacket   (out.eop),
    .out_empty         (out.empty),
    .out_channel       (),
    .in0_data          (in0.data),
    .in0_valid         (in0.valid),
    .in0_ready         (in0.ready),
    .in0_startofpacket (in0.sop),
    .in0_endofpacket   (in0.eop),
    .in0_empty         (in0.empty),
    .in1_data          (in1.data),
    .in1_valid         (in1.valid),
    .in1_ready         (in1.ready),
    .in1_startofpacket (in1.sop),
    .in1_endofpacket   (in1.eop),
    .in1_empty         (in1.empty),
    .in2_data          (in2.data),
    .in2_valid         (in2.valid),
    .in2_ready         (in2.ready),
    .in2_startofpacket (in2.sop),
    .in2_endofpacket   (in2.eop),
    .in2_empty         (in2.empty)
);

endmodule