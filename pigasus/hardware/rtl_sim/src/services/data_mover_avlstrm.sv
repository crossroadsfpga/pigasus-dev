`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

// ra submodule
module data_mover_avlstrm (
    input logic Clk, 
    input logic Rst_n,

    output  logic [PKTBUF_AWIDTH-1:0]   pkt_buffer_address,
    output  logic                    pkt_buffer_read,
    input   logic                    pkt_buffer_readvalid,
    input   flit_t                   pkt_buffer_readdata,

    avl_stream_if.rx meta,
    avl_stream_if.tx pkt,
    avl_stream_if.tx check_pkt,
    avl_stream_if.tx check_meta,
    avl_stream_if.tx emptylist,

    output logic [31:0]                 stats_in_meta,
    output logic [31:0]                 stats_out_meta,
    output logic [31:0]                 stats_in_forward_meta,
    output logic [31:0]                 stats_in_drop_meta,
    output logic [31:0]                 stats_in_check_meta,
    output logic [31:0]                 stats_in_ooo_meta,
    output logic [31:0]                 stats_in_forward_ooo_meta,
    output logic [31:0]                 stats_nopayload_pkt,
    output logic [31:0]                 stats_check_pkt
);

    data_mover data_mover_inst (
        .clk                    (Clk),
        .rst                    (~Rst_n),
        .pkt_buffer_address     (pkt_buffer_address), 
        .pkt_buffer_read        (pkt_buffer_read),
        .pkt_buffer_readvalid   (pkt_buffer_readvalid),
        .pkt_buffer_readdata    (pkt_buffer_readdata),
        .emptylist_in_data      (emptylist.data),
        .emptylist_in_valid     (emptylist.valid),
        .emptylist_in_ready     (emptylist.ready),
        .pkt_sop                (pkt.sop),
        .pkt_eop                (pkt.eop),
        .pkt_valid              (pkt.valid),
        .pkt_data               (pkt.data),
        .pkt_empty              (pkt.empty),
        .pkt_ready              (pkt.ready),
        .pkt_almost_full        (pkt.almost_full),
        .check_pkt_sop          (check_pkt.sop),
        .check_pkt_eop          (check_pkt.eop),
        .check_pkt_valid        (check_pkt.valid),
        .check_pkt_data         (check_pkt.data),
        .check_pkt_empty        (check_pkt.empty),
        .check_pkt_ready        (check_pkt.ready),
        .check_pkt_almost_full  (check_pkt.almost_full),
        //.check_pkt_hdr          (dm_check_pkt_hdr),
        .check_meta_valid       (check_meta.valid),
        .check_meta_data        (check_meta.data),
        .check_meta_ready       (check_meta.ready),//not used
        .meta_valid             (meta.valid),
        .meta_data              (meta.data),
        .meta_ready             (meta.ready)
    );

    //stats
    metadata_t tmp_meta;
    assign tmp_meta = meta.data;
    
    always @ (posedge Clk) begin
        if (~Rst_n) begin
            stats_in_forward_meta <= 0;
            stats_in_drop_meta <= 0;
            stats_in_check_meta <= 0;
            stats_in_ooo_meta <= 0;
            stats_in_forward_ooo_meta <= 0;
        end else begin
    
            if (meta.ready & meta.valid) begin
                case (tmp_meta.pkt_flags)
                    PKT_FORWARD:     stats_in_forward_meta     <= stats_in_forward_meta + 1;
                    PKT_DROP:        stats_in_drop_meta        <= stats_in_drop_meta + 1;
                    PKT_CHECK:       stats_in_check_meta       <= stats_in_check_meta + 1;
                    PKT_OOO:         stats_in_ooo_meta         <= stats_in_ooo_meta + 1;
                    PKT_FORWARD_OOO: stats_in_forward_ooo_meta <= stats_in_forward_ooo_meta + 1;
                endcase
            end
        end
    end
  
    stats_cnt in_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (meta.valid),
        .ready      (meta.ready),
        .stats_flit (stats_in_meta)
    );
    stats_cnt out_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (check_meta.valid),
        .ready      (check_meta.ready),
        .stats_flit (stats_out_meta)
    );

    stats_cnt nopayload_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (pkt.valid),
        .ready      (pkt.ready),
        .eop        (pkt.eop),
        .stats_pkt  (stats_nopayload_pkt)
    );

    stats_cnt check_pkt_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (check_pkt.valid),
        .ready      (check_pkt.ready),
        .eop        (check_pkt.eop),
        .stats_pkt  (stats_check_pkt)
    );
    
endmodule
