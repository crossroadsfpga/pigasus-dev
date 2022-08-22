`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

module input_comp_avlstrm (
    input   logic                       Clk,
    input   logic                       Rst_n,
    output  logic [31:0]                stats_out_meta,

    input   logic                       eth_sop,
    input   logic                       eth_eop,
    input   logic [511:0]               eth_data,
    input   logic [5:0]                 eth_empty,
    input   logic                       eth_valid,
    output  logic [PKTBUF_AWIDTH-1:0]   pkt_buffer_address,
    output  logic                       pkt_buffer_write,
    output  flit_t                      pkt_buffer_writedata,
    
    avl_stream_if.rx emptylist,
    avl_stream_if.tx pkt,
    avl_stream_if.tx meta
);

    input_comp input_comp_inst (
        .clk                    (Clk),
        .rst                    (~Rst_n),
        .eth_sop                (eth_sop),
        .eth_eop                (eth_eop),
        .eth_data               (eth_data),
        .eth_empty              (eth_empty),
        .eth_valid              (eth_valid),
        .pkt_buffer_address     (pkt_buffer_address),
        .pkt_buffer_write       (pkt_buffer_write),
        .pkt_buffer_writedata   (pkt_buffer_writedata),
        .emptylist_out_data     (emptylist.data),
        .emptylist_out_valid    (emptylist.valid),
        .emptylist_out_ready    (emptylist.ready),
        .pkt_sop                (pkt.sop),
        .pkt_eop                (pkt.eop),
        .pkt_valid              (pkt.valid),
        .pkt_data               (pkt.data),
        .pkt_empty              (pkt.empty),
        .pkt_ready              (pkt.ready),
        .meta_valid             (meta.valid),
        .meta_data              (meta.data),
        .meta_ready             (meta.ready)
    );

    //stats
    stats_cnt out_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (meta.valid),
        .ready      (meta.ready),
        .stats_flit (stats_out_meta)
    );


endmodule
