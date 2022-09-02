`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

// ra submodule
module flow_table_avlstrm (
    input logic Clk, 
    input logic Rst_n,

    avl_stream_if.rx in_meta,
    avl_stream_if.tx out_meta,
    avl_stream_if.tx forward_meta,
    avl_stream_if.tx reorder_meta,

    //stats
    output logic [31:0] stats_in_meta,
    output logic [31:0] stats_out_meta
);

    //Stats
    logic [31:0] out_meta_cnt;
    logic [31:0] forward_meta_cnt;
    logic [31:0] reorder_meta_cnt;
    
    always @ (posedge Clk) begin
        if (~Rst_n) begin
            stats_out_meta <= 0;
        end else begin
            stats_out_meta <= out_meta_cnt + forward_meta_cnt + reorder_meta_cnt;
        end
    end

    flow_table_wrapper ftw_inst (
        .clk                       (Clk),
        .rst                       (~Rst_n),
        .in_meta_data              (in_meta.data),
        .in_meta_valid             (in_meta.valid),
        .in_meta_ready             (in_meta.ready),
        .out_meta_data             (out_meta.data),
        .out_meta_valid            (out_meta.valid),
        .out_meta_ready            (out_meta.ready),
        .out_meta_almost_full      (out_meta.almost_full),
        .forward_meta_data         (forward_meta.data),
        .forward_meta_valid        (forward_meta.valid),
        .forward_meta_ready        (forward_meta.ready),
        .reorder_meta_data         (reorder_meta.data),
        .reorder_meta_valid        (reorder_meta.valid),
        .reorder_meta_ready        (reorder_meta.ready),
        .reorder_meta_almost_full  (reorder_meta.almost_full)
    );

    //stats
    stats_cnt in_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
       .valid      (in_meta.valid),
        .ready      (in_meta.ready),
        .stats_flit (stats_in_meta)
    );
    stats_cnt out_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (out_meta.valid),
        .ready      (out_meta.ready),
        .stats_flit (out_meta_cnt)
    );
    stats_cnt forward_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (forward_meta.valid),
        .ready      (forward_meta.ready),
        .stats_flit (forward_meta_cnt)
    );
    stats_cnt reorder_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (reorder_meta.valid),
        .ready      (reorder_meta.ready),
        .stats_flit (reorder_meta_cnt)
    );

endmodule
