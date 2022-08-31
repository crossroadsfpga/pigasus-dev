`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

// submodule not used?
module stream_mux_avlstrm (
    input logic Clk, 
    input logic Rst_n,

    avl_stream_if.rx in_pkt,
    avl_stream_if.rx in_meta,
    avl_stream_if.rx in_usr,
    avl_stream_if.tx out
);

stream_mux my_sm (
    // Clk & rst
    .clk(Clk),
    .rst(~Rst_n),

    // In Pkt data
    .in_pkt_data(in_pkt.data),
    .in_pkt_valid(in_pkt.valid),
    .in_pkt_sop(in_pkt.sop),
    .in_pkt_eop(in_pkt.eop),
    .in_pkt_empty(in_pkt.empty),
    .in_pkt_ready(in_pkt.ready),

    // In Meta data
    .in_meta_data(in_meta.data),
    .in_meta_valid(in_meta.valid),
    .in_meta_ready(in_meta.ready),

    // In User data
    .in_usr_data(in_usr.data),
    .in_usr_valid(in_usr.valid),
    .in_usr_sop(in_usr.sop),
    .in_usr_eop(in_usr.eop),
    .in_usr_empty(in_usr.empty),
    .in_usr_ready(in_usr.ready),

    // Out 
    .out_data(out.data),
    .out_valid(out.valid),
    .out_sop(out.sop),
    .out_eop(out.eop),
    .out_empty(out.empty),
    .out_ready(out.ready),
    .out_almost_full(out.almost_full)
);

endmodule
