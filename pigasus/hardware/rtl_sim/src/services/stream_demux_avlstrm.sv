`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

module stream_demux_avlstrm (
    input logic Clk, 
    input logic Rst_n,

    avl_stream_if.rx in,
    avl_stream_if.tx out_pkt,
    avl_stream_if.tx out_meta,
    avl_stream_if.tx out_usr
);

stream_demux my_sdm (
    // Clk & rst
    .clk(Clk),
    .rst(~Rst_n),

    // In 
    .in_data(in.data),
    .in_valid(in.valid),
    .in_sop(in.sop),
    .in_eop(in.eop),
    .in_empty(in.empty),
    .in_ready(in.ready),

    // out Pkt data
    .out_pkt_data(out_pkt.data),
    .out_pkt_valid(out_pkt.valid),
    .out_pkt_sop(out_pkt.sop),
    .out_pkt_eop(out_pkt.eop),
    .out_pkt_empty(out_pkt.empty),
    .out_pkt_ready(out_pkt.ready),
    .out_pkt_almost_full(out_pkt.almost_full),

    // Out Meta data
    .out_meta_data(out_meta.data),
    .out_meta_valid(out_meta.valid),
    .out_meta_ready(out_meta.ready),
    .out_meta_almost_full(out_meta.almost_full),

    // Out User data
    .out_usr_data(out_usr.data),
    .out_usr_valid(out_usr.valid),
    .out_usr_sop(out_usr.sop),
    .out_usr_eop(out_usr.eop),
    .out_usr_empty(out_usr.empty),
    .out_usr_ready(out_usr.ready),
    .out_usr_almost_full(out_usr.almost_full)
);

endmodule
