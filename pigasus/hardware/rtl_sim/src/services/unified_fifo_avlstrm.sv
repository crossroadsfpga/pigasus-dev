`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

// ra submodule
module unified_fifo_avlstrm #(
    //new parameters
    parameter FIFO_NAME = "FIFO",
    parameter MEM_TYPE = "M20K",
    parameter DUAL_CLOCK = 0,
    parameter USE_ALMOST_FULL = 0,
    parameter FULL_LEVEL = 450,//does not matter is USE_ALMOST_FULL is 0
    //parameters used for generated IP
    parameter SYMBOLS_PER_BEAT    = 64,
    parameter BITS_PER_SYMBOL     = 8,
    parameter FIFO_DEPTH          = 512
) (
    input logic Clk_i, 
    input logic Rst_n_i,
    input logic Clk_o, 
    input logic Rst_n_o,

    avl_stream_if.rx in,
    avl_stream_if.tx out,

    output logic [31:0] fill_level,
    output logic [31:0] overflow,
    output logic [31:0] stats_in,
    output logic [31:0] stats_out
);

    unified_fifo  #(
        .FIFO_NAME        (FIFO_NAME),
        .MEM_TYPE         (MEM_TYPE),
        .DUAL_CLOCK       (DUAL_CLOCK),
        .USE_ALMOST_FULL  (USE_ALMOST_FULL),
        .FULL_LEVEL       (FULL_LEVEL),
        .SYMBOLS_PER_BEAT (SYMBOLS_PER_BEAT),
        .BITS_PER_SYMBOL  (BITS_PER_SYMBOL),
        .FIFO_DEPTH       (FIFO_DEPTH)
    )
    my_FIFO (
        .in_clk            (Clk_i),
        .in_reset          (~Rst_n_i),
        .out_clk           (Clk_o),//not used
        .out_reset         (~Rst_n_o),
        .in_data           (in.data),
        .in_valid          (in.valid),
        .in_ready          (in.ready),
        .out_data          (out.data),
        .out_valid         (out.valid),
        .out_ready         (out.ready),
        .fill_level        (fill_level),
        .almost_full       (in.almost_full),//not used
        .overflow          (overflow)
    );

    stats_cnt in_inst(
        .Clk        (Clk_i),
        .Rst_n      (Rst_n_i),
        .valid      (in.valid),
        .ready      (in.ready),
        .stats_flit (stats_in)
    );
    
    generate
    if (DUAL_CLOCK==1) begin
        stats_cnt out_inst(
            .Clk        (Clk_o),
            .Rst_n      (Rst_n_o),
            .valid      (out.valid),
            .ready      (out.ready),
            .stats_flit (stats_out)
        );
    end else begin
        stats_cnt out_inst(
            .Clk        (Clk_i),
            .Rst_n      (Rst_n_i),
            .valid      (out.valid),
            .ready      (out.ready),
            .stats_flit (stats_out)
        );
    
    end
    endgenerate


endmodule
