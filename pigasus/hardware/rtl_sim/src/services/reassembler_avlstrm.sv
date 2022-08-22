`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"

module reassembler_avlstrm (
    input logic Clk, 
    input logic Rst_n,


    output  logic [PKTBUF_AWIDTH-1:0]   pkt_buffer_writeaddress,
    output  logic                       pkt_buffer_write,
    output  flit_t                      pkt_buffer_writedata,

    output  logic [PKTBUF_AWIDTH-1:0]   pkt_buffer_readaddress,
    output  logic                       pkt_buffer_read,
    input   logic                       pkt_buffer_readvalid,
    input   flit_t                      pkt_buffer_readdata,    

    output logic [31:0]                 parser_meta_csr_readdata,
    output logic [31:0]                 stats_incomp_out_meta,
    output logic [31:0]                 stats_parser_out_meta,
    output logic [31:0]                 stats_ft_in_meta,
    output logic [31:0]                 stats_ft_out_meta,
    output logic [31:0]                 stats_emptylist_in,
    output logic [31:0]                 stats_emptylist_out,
    output logic [31:0]                 stats_dm_in_meta,
    output logic [31:0]                 stats_dm_out_meta,
    output logic [31:0]                 stats_dm_in_forward_meta,
    output logic [31:0]                 stats_dm_in_drop_meta,
    output logic [31:0]                 stats_dm_in_check_meta,
    output logic [31:0]                 stats_dm_in_ooo_meta,
    output logic [31:0]                 stats_dm_in_forward_ooo_meta,
    output logic [31:0]                 stats_nopayload_pkt,
    output logic [31:0]                 stats_dm_check_pkt,

    avl_stream_if.rx eth, 
    avl_stream_if.tx nopayload,
    avl_stream_if.tx out_pkt,
    avl_stream_if.tx out_usr,
    avl_stream_if.tx out_meta
);

    avl_stream_if#(.WIDTH(512))               incomp_pkt();
    avl_stream_if#(.WIDTH($bits(metadata_t))) incomp_meta();
    avl_stream_if#(.WIDTH(PKT_AWIDTH))        emptylist();
    avl_stream_if#(.WIDTH(PKT_AWIDTH))        emptylist_i();
    avl_stream_if#(.WIDTH($bits(metadata_t))) parser_meta();
    avl_stream_if#(.WIDTH($bits(metadata_t))) parser_meta_fifo();
    avl_stream_if#(.WIDTH($bits(metadata_t))) ftw_out_meta();
    avl_stream_if#(.WIDTH($bits(metadata_t))) ftw_reorder_meta();
    avl_stream_if#(.WIDTH($bits(metadata_t))) ftw_nonforward_meta();
    avl_stream_if#(.WIDTH($bits(metadata_t))) ftw_forward_meta();
    avl_stream_if#(.WIDTH($bits(metadata_t))) dm_meta_in();
    avl_stream_if#(.WIDTH($bits(metadata_t))) dm_meta_out();

//assign eth.txFull = 1'b0;
   assign eth.ready = 1'b1;
   
   input_comp_avlstrm incomp (
    .Clk(Clk),
    .Rst_n(Rst_n),
    .stats_out_meta(stats_incomp_out_meta),

//    .eth_sop                (eth.txP.tx_msg.head.arg3[0]),
//    .eth_eop                (eth.txP.tx_msg.head.arg3[1]),
//    .eth_data               (eth.txP.tx_msg.data),
//    .eth_empty              (eth.txP.tx_msg.head.arg3[7:2]),
//    .eth_valid              (eth.txP.tx),
    .eth_sop                (eth.sop),
    .eth_eop                (eth.eop),
    .eth_data               (eth.data),
    .eth_empty              (eth.empty),
    .eth_valid              (eth.valid),

    .pkt_buffer_address     (pkt_buffer_writeaddress),
    .pkt_buffer_write       (pkt_buffer_write),
    .pkt_buffer_writedata   (pkt_buffer_writedata),
    
    .emptylist(emptylist),
    .pkt(incomp_pkt),
    .meta(incomp_meta)
);

parser_avlstrm my_parser (
    .Clk(Clk),
    .Rst_n(Rst_n),
    .stats_out_meta(stats_parser_out_meta),
    
    .in_meta(incomp_meta),
    .in_pkt(incomp_pkt),
    .out_meta(parser_meta)
);

unified_fifo_avlstrm  #(
    .FIFO_NAME        ("[top] parser_out_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (0),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (META_WIDTH),
    .FIFO_DEPTH       (PKT_NUM)
) parser_out_fifo (
    .Clk_i(Clk), 
    .Rst_n_i(Rst_n),
    .fill_level(parser_meta_csr_readdata),
    .in(parser_meta),
    .out(parser_meta_fifo)
);

//////////////////// Reassembly //////////////////////////////////
flow_table_avlstrm ftw_inst (
    .Clk                  (Clk),
    .Rst_n                (Rst_n),
    .stats_in_meta        (stats_ft_in_meta),
    .stats_out_meta       (stats_ft_out_meta),

    .in_meta              (parser_meta_fifo),
    .out_meta             (ftw_out_meta),
    .forward_meta         (ftw_forward_meta),
    .reorder_meta         (ftw_reorder_meta)
);

arb_2_af_avlstrm #(
    .DWIDTH(META_WIDTH),
    .DEPTH(512),
    .FULL_LEVEL(480)
)
arb_inorder_ooo(
    .Clk              (Clk),
    .Rst_n            (Rst_n),
    .in0   (ftw_out_meta),
    .in1   (ftw_reorder_meta),
    .out   (ftw_nonforward_meta)
);

arb_2_avlstrm #(
    .DWIDTH(META_WIDTH),
    .DEPTH(512)
)
arb_forward(
    .Clk        (Clk),
    .Rst_n      (Rst_n),
    .in0  (ftw_nonforward_meta),
    .in1  (ftw_forward_meta),
    .out  (dm_meta_in)
);

data_mover_avlstrm dm_inst (
    .Clk                       (Clk), 
    .Rst_n                     (Rst_n),
    .stats_in_meta             (stats_dm_in_meta),
    .stats_out_meta            (stats_dm_out_meta),
    .stats_in_forward_meta     (stats_dm_in_forward_meta),
    .stats_in_drop_meta        (stats_dm_in_drop_meta),
    .stats_in_check_meta       (stats_dm_in_check_meta),
    .stats_in_ooo_meta         (stats_dm_in_ooo_meta),
    .stats_in_forward_ooo_meta (stats_dm_in_forward_ooo_meta),
    .stats_nopayload_pkt       (stats_nopayload_pkt),
    .stats_check_pkt           (stats_dm_check_pkt),

    .pkt_buffer_address(pkt_buffer_readaddress),
    .pkt_buffer_read(pkt_buffer_read),
    .pkt_buffer_readvalid(pkt_buffer_readvalid),
    .pkt_buffer_readdata(pkt_buffer_readdata),

    .meta(dm_meta_in),
    .pkt(nopayload),
    .check_pkt(out_pkt),
    .check_meta(out_meta),
    .emptylist(emptylist_i)
);

//////////////////// PKT BUFFER's Emptylist //////////////////////////////////
unified_fifo_avlstrm  #(
    .FIFO_NAME        ("[top] pktbuf_emptylist_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (0),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (PKT_AWIDTH),
    .FIFO_DEPTH       (PKT_NUM)
)
pktbuf_emptylist (
    .Clk_i(Clk), 
    .Rst_n_i(Rst_n),
    .stats_in    (stats_emptylist_in),
    .stats_out   (stats_emptylist_out),

    .in(emptylist_i),
    .out(emptylist)
);


/// stats services ///
//incomp
//stats_single_avlstrm incomp_out_meta_inst(
//    .Clk        (Clk),
//    .Rst_n      (Rst_n),
//    .in_data    (incomp_meta),
//    .stats      (stats_incomp_out_meta)
//);
//parser
//stats_single_avlstrm parser_out_meta_inst(
//    .Clk        (Clk),
//    .Rst_n      (Rst_n),
//    .in_data    (parser_meta),
//    .stats      (stats_parser_out_meta)
//);
////Flow table
//stats_single_avlstrm ft_in_meta_inst(
//    .Clk        (Clk),
//    .Rst_n      (Rst_n),
//    .in_data    (parser_meta_fifo),
//    .stats      (stats_ft_in_meta)
//);
//
//stats_single_sum_avlstrm ft_out_meta_inst(
//    .Clk        (Clk),
//    .Rst_n      (Rst_n),
//    .in_data0   (ftw_out_meta),
//    .in_data1   (ftw_forward_meta),
//    .in_data2   (ftw_reorder_meta),
//    .stats      (stats_ft_out_meta)
//);
//
////Data mover
//stats_single_avlstrm dm_in_meta_inst(
//    .Clk        (Clk),
//    .Rst_n      (Rst_n),
//    .in_data       (dm_meta_in),
//    .stats (stats_dm_in_meta)
//);
//
//stats_dm_special_avlstrm dm_special_meta_inst(
//    .Clk                    (Clk),
//    .Rst_n                  (Rst_n),
//    .in_data                (dm_meta_in),
//    .stats_forward_meta     (stats_dm_in_forward_meta),
//    .stats_drop_meta        (stats_dm_in_drop_meta),
//    .stats_check_meta       (stats_dm_in_check_meta),
//    .stats_ooo_meta         (stats_dm_in_ooo_meta),
//    .stats_forward_ooo_meta (stats_dm_in_forward_ooo_meta)
//);
//
//stats_single_avlstrm dm_out_meta_inst(
//    .Clk        (Clk),
//    .Rst_n      (Rst_n),
//    .in_data    (out_meta),
//    .stats      (stats_dm_out_meta)
//);
//
//stats_pkt_avlstrm dm_check_pkt_inst(
//    .Clk            (Clk),
//    .Rst_n          (Rst_n),
//    .in_data         (nopayload),
//    .stats_flit     (),//not used for now
//    .stats_pkt      (stats_nopayload_pkt),
//    .stats_pkt_sop  ()//not used
//);
//
//stats_pkt_avlstrm nopayload_pkt_inst(
//    .Clk            (Clk),
//    .Rst_n          (Rst_n),
//    .in_data        (out_pkt),
//    .stats_flit     (),//not used for now
//    .stats_pkt      (stats_dm_check_pkt),
//    .stats_pkt_sop  ()//not used
//);
//
////Emptylist
//stats_single_avlstrm #(
//    .WIDTH(PKT_AWIDTH)   
//)emptylist_in_inst(
//    .Clk        (Clk),
//    .Rst_n      (Rst_n),
//    .in_data    (emptylist_i),
//    .stats      (stats_emptylist_in)
//);
//
//stats_single_avlstrm #(
//    .WIDTH(PKT_AWIDTH)   
//)emptylist_out_inst(
//    .Clk        (Clk),
//    .Rst_n      (Rst_n),
//    .in_data    (emptylist),
//    .stats      (stats_emptylist_out)
//);

endmodule
