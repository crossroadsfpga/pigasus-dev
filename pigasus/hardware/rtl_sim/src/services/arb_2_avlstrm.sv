`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

// ra submodule
module arb_2_avlstrm#(
    parameter DWIDTH=8,
    parameter DEPTH=1024
   ) (
    input logic Clk, 
    input logic Rst_n,

    avl_stream_if.rx in0,
    avl_stream_if.rx in1,
    avl_stream_if.tx out
);

arb_2_wrapper #(
    .DWIDTH(DWIDTH),
    .DEPTH(DEPTH)
)
arb_forward(
    .clk        (Clk),
    .rst        (~Rst_n),
    .clk_out    (Clk),
    .rst_out    (~Rst_n),
    .in_data_0  (in0.data),
    .in_valid_0 (in0.valid),
    .in_ready_0 (in0.ready),
    .in_data_1  (in1.data),
    .in_valid_1 (in1.valid),
    .in_ready_1 (in1.ready),
    .out_data   (out.data),
    .out_valid  (out.valid),
    .out_ready  (out.ready)
);

endmodule
