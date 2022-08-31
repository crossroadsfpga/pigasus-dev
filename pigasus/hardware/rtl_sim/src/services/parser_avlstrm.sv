`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

// ra submodule
module parser_avlstrm (
    input   logic                       Clk,
    input   logic                       Rst_n,
    output  logic [31:0]                stats_out_meta,
 
    avl_stream_if.rx in_meta,
    avl_stream_if.rx in_pkt,
    avl_stream_if.tx out_meta
);
    avl_stream_if#(.WIDTH(512)) port(); 
    avl_stream_if#(.WIDTH($bits(metadata_t))) port_meta[2](); 

    parser parser_inst (
        .clk            (Clk),
        .rst            (~Rst_n),
        .in_pkt_data    (in_pkt.data),
        .in_pkt_valid   (in_pkt.valid),
        .in_pkt_ready   (in_pkt.ready),
        .in_pkt_sop     (in_pkt.sop),
        .in_pkt_eop     (in_pkt.eop),
        .in_pkt_empty   (in_pkt.empty),
        .out_pkt_data   (),
        .out_pkt_valid  (),
        .out_pkt_ready  (),
        .out_pkt_sop    (),
        .out_pkt_eop    (),
        .out_pkt_empty  (),
        .in_meta_data   (in_meta.data),
        .in_meta_valid  (in_meta.valid),
        .in_meta_ready  (in_meta.ready),
        .out_meta_data  (out_meta.data),
        .out_meta_valid (out_meta.valid),
        .out_meta_ready (out_meta.ready)
    );

    //stats
    stats_cnt out_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (out_meta.valid),
        .ready      (out_meta.ready),
        .stats_flit (stats_out_meta)
    );

endmodule
