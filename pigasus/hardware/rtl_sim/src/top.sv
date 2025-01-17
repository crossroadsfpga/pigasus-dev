`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"
`include "./src/stats_reg.sv"

module top 
  (
   input logic [0:0] 		    clk,
   input logic [0:0] 		    rst,
   input logic [0:0] 		    clk_high,
   input logic [0:0] 		    rst_high,
   input logic [0:0] 		    clk_pcie,
   input logic [0:0] 		    rst_pcie,

   input logic [0:0] 		    in_sop,
   input logic [0:0] 		    in_eop,
   input logic [511:0] 		    in_data,
   input logic [5:0] 		    in_empty,
   input logic [0:0] 		    in_valid,

   output logic [511:0] 	    out_data,
   output logic [0:0] 		    out_valid,
   output logic [0:0] 		    out_sop,
   output logic [0:0] 		    out_eop,
   output logic [5:0] 		    out_empty,
   input logic [0:0] 		    out_ready,

   output logic [0:0] 		    pkt_buf_wren,
   output logic [PKTBUF_AWIDTH-1:0] pkt_buf_wraddress,
   output logic [PKTBUF_AWIDTH-1:0] pkt_buf_rdaddress,
   output logic [519:0] 	    pkt_buf_wrdata,
   output logic [0:0] 		    pkt_buf_rden,
   input logic [0:0] 		    pkt_buf_rd_valid,
   input logic [519:0] 		    pkt_buf_rddata,

   output logic [513:0] 	    pcie_rb_wr_data,
   output logic [11:0] 		    pcie_rb_wr_addr,
   output logic [0:0] 		    pcie_rb_wr_en,
   input logic [11:0] 		    pcie_rb_wr_base_addr,
   input logic [0:0] 		    pcie_rb_almost_full,
   output logic [0:0] 		    pcie_rb_update_valid,
   output logic [11:0] 		    pcie_rb_update_size,
   input logic [0:0] 		    disable_pcie,

   input logic [27:0] 		    pdumeta_cpu_data,
   input logic [0:0] 		    pdumeta_cpu_valid,
   output logic [9:0] 		    pdumeta_cnt,

   output logic [540:0] 	    ddr_wr_req_data,
   output logic [0:0] 		    ddr_wr_req_valid,
   input logic [0:0] 		    ddr_wr_req_almost_full,
   output logic [28:0] 		    ddr_rd_req_data,
   output logic [0:0] 		    ddr_rd_req_valid,
   input logic [0:0] 		    ddr_rd_req_almost_full,
   input logic [511:0] 		    ddr_rd_resp_data,
   input logic [0:0] 		    ddr_rd_resp_valid,
   output logic [0:0] 		    ddr_rd_resp_almost_full,
   
   input logic [0:0] 		    clk_status,
   input logic [29:0] 		    status_addr,
   input logic [0:0] 		    status_read,
   input logic [0:0] 		    status_write,
   input logic [31:0] 		    status_writedata,
   output logic [31:0] 		    status_readdata,
   output logic [0:0] 		    status_readdata_valid
   );
   // begin copy-paste
   logic 			    rst_n_high, rst_n, rst_n_pcie;
   assign rst_n_high = ~rst_high;
   assign rst_n = ~rst;
   assign rst_n_pcie = ~rst_pcie;

   logic 			    clk_back, rst_back;
   assign clk_back = clk_pcie;
   assign rst_back = rst_pcie;

   //
   // begin I/O channels section
   //
   // ready not checked, need fixing if pushing over noc
   `AVL_STREAM_IF((PDU_META_WIDTH), pdumeta_cpu_nb);
   assign pdumeta_cpu_nb.data=pdumeta_cpu_data;
   assign pdumeta_cpu_nb.valid=pdumeta_cpu_valid;

   // proper stream with back pressure
   `AVL_STREAM_PKT_IF(512, eth_out); // uses sop and eop
   assign out_data=eth_out.data;
   assign out_valid=eth_out.valid;
   assign eth_out.ready=out_ready;
   assign out_sop=eth_out.sop;
   assign out_eop=eth_out.eop;
   assign out_empty=eth_out.empty;

   integer 			    timer;
   integer 			    ticker;
   always@(posedge clk) begin
      if(rst) begin
	 timer<=0;
	 ticker<=0;
      end else begin
	 timer=timer+1;
	 if(out_valid&&out_eop) begin
	    ticker<=ticker+1;
	    //$display("sending pkt(%d) at time %d\n",ticker,timer);
	 end
      end
   end // always@ (posedge clk)

   // in bound from ethernet, ready not checked
   // receiving fifo will drop packet when full
   `AVL_STREAM_PKT_IF(512, eth_in_nb); // uses sop and eop
   assign eth_in_nb.sop=in_sop;
   assign eth_in_nb.eop=in_eop;
   assign eth_in_nb.data=in_data;
   assign eth_in_nb.empty=in_empty;
   assign eth_in_nb.valid=in_valid;

   // no back pressure, need fixing if over noc
   // this wouldn't be hard to fix
   `AVL_STREAM_NB_IF(30, status_rd_req_nb);
   `AVL_STREAM_NB_IF(62, status_wr_req_nb);
   `AVL_STREAM_NB_IF(32, status_rd_resp_nb);

   assign status_rd_req_nb.data=status_addr;
   assign status_rd_req_nb.valid=status_read;
   
   assign status_wr_req_nb.data = {status_addr, status_writedata};
   assign status_wr_req_nb.valid = status_write;

   assign status_readdata = status_rd_resp_nb.data;
   assign status_readdata_valid = status_rd_resp_nb.valid;

   // proper stream with almost full back pressure
   `AVL_STREAM_AF_IF(29, ddr_rd_req);
   `AVL_STREAM_AF_IF(541, ddr_wr_req);
   `AVL_STREAM_AF_IF(512, ddr_rd_resp);

   assign ddr_wr_req_data=ddr_wr_req.data;
   assign ddr_wr_req_valid=ddr_wr_req.valid;
   assign ddr_wr_req.almost_full=ddr_wr_req_almost_full;

// not connected for reading
//   assign ddr_rd_req_data=ddr_rd_req.data;
//   assign ddr_rd_req_valid=ddr_rd_req.valid;
//   assign ddr_rd_req.almost_full=ddr_rd_req_almost_full;
   
//   assign ddr_rd_resp.data=ddr_rd_resp_data;
//   assign ddr_rd_resp.valid=ddr_rd_resp_valid;
//   assign ddr_rd_resp_almost_full=ddr_rd_resp.almost_full;

   // no back pressure, this is a latency sensitive interface 
   `AVL_STREAM_NB_IF(PKTBUF_AWIDTH, pkt_buf_rd_req_ls);
   `AVL_STREAM_NB_IF(PKTBUF_AWIDTH+520, pkt_buf_wr_req_ls);
   `AVL_STREAM_NB_IF(520, pkt_buf_rd_resp_ls);

   assign pkt_buf_wraddress=pkt_buf_wr_req_ls.data[(PKTBUF_AWIDTH-1+520):520];
   assign pkt_buf_wrdata=pkt_buf_wr_req_ls.data[519:0];
   assign pkt_buf_wren=pkt_buf_wr_req_ls.valid;

   assign pkt_buf_rdaddress=pkt_buf_rd_req_ls.data;
   assign pkt_buf_rden=pkt_buf_rd_req_ls.valid;
   
   assign pkt_buf_rd_resp_ls.data=pkt_buf_rddata;
   assign pkt_buf_rd_resp_ls.valid=pkt_buf_rd_valid;
   //
   // end I/O channels section
   //

   //
   // begin stats section
   //
   `AVL_STREAM_PKT_IF(($bits(stats_t)), eth_stats__clk); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), r_stats__clk); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), dm2sm_stats__clk); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), fpm_stats__clk); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), fpm_stats__pcie); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), sm2pg_stats__pcie); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), pg_stats__pcie); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), pg2nf_stats__pcie); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), nf_stats__pcie); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), by2pd_stats__pcie); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), dma_stats__pcie); // uses sop and eop
   
   `AVL_STREAM_PKT_IF(($bits(stats_t)), mux1__clk); // uses sop and eop
   `AVL_STREAM_AF_PKT_IF(($bits(stats_t)), mux__clk); // uses almost full // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), mux11__pcie); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), mux1__pcie); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), mux2__pcie); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), stats__clk2pcie); // uses sop and eop
   `AVL_STREAM_PKT_IF(($bits(stats_t)), all_stats__pcie); // uses sop and eop

   // I think Intel has wider mux IPs
   pkt_mux_avlstrm_3 r_eth_fpm_mux
     (
      .Clk(clk), .Rst_n(rst_n),
      .in0(r_stats__clk), .in1(eth_stats__clk), .in2(fpm_stats__clk),
      .out(mux1__clk)
      );
   pkt_mux_avlstrm dm2sm_mux1_mux
     (
      .Clk(clk), .Rst_n(rst_n),
      .in0(dm2sm_stats__clk), .in1(mux1__clk),
      .out(mux__clk)
      );
   
   unified_pkt_fifo_avlstrm#(.DUAL_CLOCK(1), .MEM_TYPE("Auto"), .FIFO_DEPTH(16)) stats_slowing 
     ( 
       .Clk_i(clk), .Rst_n_i(rst_n),
       .Clk_o(clk_pcie), .Rst_n_o(rst_n_pcie),
       .in(mux__clk), .out(stats__clk2pcie)
       );
   
   pkt_mux_avlstrm sm2pg_dma_mux11
     (
      .Clk(clk_pcie), .Rst_n(rst_n_pcie),
      .in0(sm2pg_stats__pcie), .in1(dma_stats__pcie),
      .out(mux11__pcie)
      );
   
   pkt_mux_avlstrm_3 mux1_pg2nf_by2pd_mux1
     (
      .Clk(clk_pcie), .Rst_n(rst_n_pcie),
      .in0(mux11__pcie), .in1(pg2nf_stats__pcie), .in2(by2pd_stats__pcie),
      .out(mux1__pcie)
      );
   
   pkt_mux_avlstrm_3 pg_nf_mux2
     (
      .Clk(clk_pcie), .Rst_n(rst_n_pcie),
      .in0(pg_stats__pcie), .in1(nf_stats__pcie), .in2(fpm_stats__pcie),
      .out(mux2__pcie)
      );
   
   pkt_mux_avlstrm_3 stats_mux
     (
      .Clk(clk_pcie), .Rst_n(rst_n_pcie),
      .in0(mux1__pcie), .in1(mux2__pcie), .in2(stats__clk2pcie),
      .out(all_stats__pcie)
      );
   
   stats_avlstrm stats_reg
     (
      .Clk_status(clk_status), 
      .Clk_pcie(clk_pcie),
      
      .stats_update(all_stats__pcie),
      .stats_wr_req(status_wr_req_nb),
      .stats_rd_req(status_rd_req_nb),
      .stats_rd_resp(status_rd_resp_nb)
      );

   
   //
   // end stats section
   //

   //
   // begin datapath section
   //
   
   logic internal_rb_update_valid;

   assign pcie_rb_update_valid = disable_pcie ? 1'b0 : internal_rb_update_valid;

   `AVL_STREAM_PKT_IF(512, ethernet_out0_direct); // uses sop and eop
   `AVL_STREAM_PKT_IF(512, ethernet_out1_direct); // uses sop and eop
   `AVL_STREAM_PKT_IF(512, ethernet_out2_direct); // uses sop and eop
   `AVL_STREAM_PKT_IF(512, ethernet_out3_direct); // uses sop and eop 
   `AVL_STREAM_PKT_IF(512, ethernet_out4_direct); // uses sop and eop

   `AVL_STREAM_PKT_IF(512, r_eth_direct); // uses sop and eop
   
   `AVL_STREAM_AF_PKT_IF(512, fifo0_in_direct); // uses almost full // uses sop and eop
   `AVL_STREAM_AF_PKT_IF(512, fifo3_in_direct); // uses almost full // uses sop and eop
   `AVL_STREAM_AF_PKT_IF(512, fifo4_in_direct); // uses almost full // uses sop and eop
   `AVL_STREAM_AF_PKT_IF(512, fifo1_in_direct); // uses almost full  // uses sop and eop
   `AVL_STREAM_AF_PKT_IF(512, fifo2_in_direct); // uses almost full  // uses sop and eop

   `AVL_STREAM_AF_PKT_IF(512, dm2sm_in_pkt_direct); // uses almost full  // uses sop and eop
   `AVL_STREAM_AF_IF(($bits(metadata_t)), dm2sm_in_meta_direct); // uses almost full
   `AVL_STREAM_AF_PKT_IF(512, dm2sm_in_usr_direct); // uses almost full // uses sop and eop

   `AVL_STREAM_PKT_IF(512, fpm_in_pkt_direct);  // uses sop and eop
   `AVL_STREAM_IF(($bits(metadata_t)), fpm_in_meta_direct);
   `AVL_STREAM_PKT_IF(512, fpm_in_usr_direct); // uses sop and eop
   
   `AVL_STREAM_AF_PKT_IF(512, sm2pg_in_pkt_direct); // uses almost full  // uses sop and eop
   `AVL_STREAM_AF_IF(($bits(metadata_t)), sm2pg_in_meta_direct); // uses almost full
   `AVL_STREAM_AF_PKT_IF(512, sm2pg_in_usr_direct); // uses almost full  // uses sop and eop

   `AVL_STREAM_PKT_IF(512, pg_in_pkt_direct);  // uses sop and eop
   `AVL_STREAM_IF(($bits(metadata_t)), pg_in_meta_direct);
   `AVL_STREAM_PKT_IF(512, pg_in_usr_direct); // uses sop and eop
   
   `AVL_STREAM_AF_PKT_IF(512, pg2nf_in_pkt_direct); // uses almost full  // uses sop and eop
   `AVL_STREAM_AF_IF(($bits(metadata_t)), pg2nf_in_meta_direct); // uses almost full
   `AVL_STREAM_AF_PKT_IF(512, pg2nf_in_usr_direct); // uses almost full  // uses sop and eop

   `AVL_STREAM_PKT_IF(512, nf_in_pkt_direct);  // uses sop and eop
   `AVL_STREAM_IF(($bits(metadata_t)), nf_in_meta_direct);
   `AVL_STREAM_PKT_IF(512, nf_in_usr_direct); // uses sop and eop
   
   `AVL_STREAM_AF_PKT_IF(512, by2pd_in_pkt_direct); // uses almost full  // uses sop and eop
   `AVL_STREAM_AF_IF(($bits(metadata_t)), by2pd_in_meta_direct); // uses almost full
   `AVL_STREAM_AF_PKT_IF(512, by2pd_in_usr_direct); // uses almost full  // uses sop and eop
   
   `AVL_STREAM_PKT_IF(512, dma_in_pkt_direct); // uses sop and eop
   `AVL_STREAM_IF(($bits(metadata_t)), dma_in_meta_direct);
   `AVL_STREAM_PKT_IF(512, dma_in_usr_direct); // uses sop and eop

   ethernet_multi_out_avlstrm my_ethernet 
     (
      .Clk(clk),
      .Rst_n(rst_n),
      
      .eth_out(eth_out),
      .eth_in(eth_in_nb),
      .out0(ethernet_out0_direct),
      .out1(ethernet_out1_direct),
      .out2(ethernet_out2_direct),
      .out3(ethernet_out3_direct),
      .out4(ethernet_out4_direct),
      .in(r_eth_direct),
      
      .stats_out(eth_stats__clk)	
      );
   reassembler_avlstrm my_r 
     (
      .Clk(clk),
      .Rst_n(rst_n),

      .pkt_buf_wr_req(pkt_buf_wr_req_ls),
      .pkt_buf_rd_req(pkt_buf_rd_req_ls),
      .pkt_buf_rd_resp(pkt_buf_rd_resp_ls),

      .eth(r_eth_direct),
      .nopayload(fifo0_in_direct),
      .out_pkt(dm2sm_in_pkt_direct),
      .out_meta(dm2sm_in_meta_direct),
      .out_usr(dm2sm_in_usr_direct),

      .stats_out(r_stats__clk)
      );
   unified_pkt_fifo_avlstrm#(.FIFO_NAME("[top] fifo0"), .MEM_TYPE("M20K"), .DUAL_CLOCK(0), .USE_ALMOST_FULL(1), .FULL_LEVEL(450), .SYMBOLS_PER_BEAT(64), .BITS_PER_SYMBOL(8), .FIFO_DEPTH(512)) my_fifo0 
     (
      .Clk_i(clk),
      .Rst_n_i(rst_n),
      .in(fifo0_in_direct),
      .out(ethernet_out0_direct)
      );
   unified_pkt_fifo_avlstrm#(.FIFO_NAME("[top] fifo3"), .MEM_TYPE("M20K"), .DUAL_CLOCK(1), .USE_ALMOST_FULL(1), .FULL_LEVEL(450), .SYMBOLS_PER_BEAT(64), .BITS_PER_SYMBOL(8), .FIFO_DEPTH(512)) my_fifo3 
     (
      .Clk_i(clk_pcie),
      .Rst_n_i(rst_n_pcie),
      .Clk_o(clk),
      .Rst_n_o(rst_n),
      .in(fifo3_in_direct),
      .out(ethernet_out1_direct)
      );
   unified_pkt_fifo_avlstrm#(.FIFO_NAME("[top] fifo4"), .MEM_TYPE("M20K"), .DUAL_CLOCK(1), .USE_ALMOST_FULL(1), .FULL_LEVEL(450), .SYMBOLS_PER_BEAT(64), .BITS_PER_SYMBOL(8), .FIFO_DEPTH(512)) my_fifo4 
     (
      .Clk_i(clk_pcie),
      .Rst_n_i(rst_n_pcie),
      .Clk_o(clk),
      .Rst_n_o(rst_n),
      .in(fifo4_in_direct),
      .out(ethernet_out2_direct)
      );
   unified_pkt_fifo_avlstrm#(.FIFO_NAME("[top] fifo1"), .MEM_TYPE("M20K"), .DUAL_CLOCK(1), .USE_ALMOST_FULL(1), .FULL_LEVEL(450), .SYMBOLS_PER_BEAT(64), .BITS_PER_SYMBOL(8), .FIFO_DEPTH(512)) my_fifo1 
     (
      .Clk_i(clk_pcie),
      .Rst_n_i(rst_n_pcie),
      .Clk_o(clk),
      .Rst_n_o(rst_n),
      .in(fifo1_in_direct),
      .out(ethernet_out3_direct)
      );
   unified_pkt_fifo_avlstrm#(.FIFO_NAME("[top] fifo2"), .MEM_TYPE("M20K"), .DUAL_CLOCK(1), .USE_ALMOST_FULL(1), .FULL_LEVEL(450), .SYMBOLS_PER_BEAT(64), .BITS_PER_SYMBOL(8), .FIFO_DEPTH(512)) my_fifo2 

     (
      .Clk_i(clk_pcie),
      .Rst_n_i(rst_n_pcie),
      .Clk_o(clk),
      .Rst_n_o(rst_n),
      .in(fifo2_in_direct),
      .out(ethernet_out4_direct)
      );
   channel_fifo_avlstrm#(.DUAL_CLOCK(0)) my_dm2sm
     (
      .Clk_i(clk),
      .Rst_n_i(rst_n),

      .in_pkt(dm2sm_in_pkt_direct),
      .in_meta(dm2sm_in_meta_direct),
      .in_usr(dm2sm_in_usr_direct),
      .out_pkt(fpm_in_pkt_direct),
      .out_meta(fpm_in_meta_direct),
      .out_usr(fpm_in_usr_direct),

      .stats_out(dm2sm_stats__clk),						    
      .stats_in_pkt_max_fill_level_addr(REG_MAX_DM2SM),
      .stats_in_pkt_addr(REG_NOTUSED),
      .stats_in_pkt_sop_addr(REG_NOTUSED),
      .stats_in_meta_addr(REG_NOTUSED),
      .stats_in_rule_addr(REG_NOTUSED)
      );
   fast_pm_avlstrm my_fpm
     (
      .Clk(clk),
      .Rst_n(rst_n),
      .Clk_front(clk_high),
      .Rst_front_n(rst_n),
      .Clk_back(clk_pcie),
      .Rst_back_n(rst_n_pcie),

      .in_pkt(fpm_in_pkt_direct),
      .in_meta(fpm_in_meta_direct),
      .in_usr(fpm_in_usr_direct),
      .fp_nocheck(fifo1_in_direct),
      .out_pkt(sm2pg_in_pkt_direct),
      .out_meta(sm2pg_in_meta_direct),
      .out_usr(sm2pg_in_usr_direct),

      .stats_out(fpm_stats__clk),						    
      .stats_out_back(fpm_stats__pcie)						    
      );
   channel_fifo_avlstrm#(.DUAL_CLOCK(1)) my_sm2pg
     (
      .Clk_i(clk_pcie),
      .Rst_n_i(rst_n_pcie),
      .Clk_o(clk_pcie),
      .Rst_n_o(rst_n_pcie),

      .in_pkt(sm2pg_in_pkt_direct),
      .in_meta(sm2pg_in_meta_direct),
      .in_usr(sm2pg_in_usr_direct),
      .out_pkt(pg_in_pkt_direct),
      .out_meta(pg_in_meta_direct),
      .out_usr(pg_in_usr_direct),

      .stats_out(sm2pg_stats__pcie),						    
      .stats_in_pkt_max_fill_level_addr(REG_MAX_SM2PG),
      .stats_in_pkt_addr(REG_NOTUSED),
      .stats_in_pkt_sop_addr(REG_NOTUSED),
      .stats_in_meta_addr(REG_NOTUSED),
      .stats_in_rule_addr(REG_NOTUSED)
      );
   port_group_matcher_avlstrm my_pg
     (
      .Clk(clk_pcie),
      .Rst_n(rst_n_pcie),

      .in_pkt(pg_in_pkt_direct),
      .in_meta(pg_in_meta_direct),
      .in_usr(pg_in_usr_direct),
      .pg_nocheck(fifo2_in_direct),
      .out_pkt(pg2nf_in_pkt_direct),
      .out_meta(pg2nf_in_meta_direct),
      .out_usr(pg2nf_in_usr_direct),

      .stats_out(pg_stats__pcie)
      );
   channel_fifo_avlstrm#(.DUAL_CLOCK(0)) my_pg2nf
     (
      .Clk_i(clk_pcie),
      .Rst_n_i(rst_n_pcie),

      .in_pkt(pg2nf_in_pkt_direct),
      .in_meta(pg2nf_in_meta_direct),
      .in_usr(pg2nf_in_usr_direct),
      .out_pkt(nf_in_pkt_direct),
      .out_meta(nf_in_meta_direct),
      .out_usr(nf_in_usr_direct),

      .stats_out(pg2nf_stats__pcie),						    
      .stats_in_pkt_max_fill_level_addr(REG_MAX_PG2NF),
      .stats_in_pkt_addr(REG_NOTUSED),
      .stats_in_pkt_sop_addr(REG_NOTUSED),
      .stats_in_meta_addr(REG_NOTUSED),
      .stats_in_rule_addr(REG_NOTUSED)
      );
   non_fast_pm_avlstrm my_nf
     (
      .Clk(clk_pcie),
      .Rst_n(rst_n_pcie),
      .Clk_high(clk_high),
      .Rst_high_n(rst_n_high),

      .in_pkt(nf_in_pkt_direct),
      .in_meta(nf_in_meta_direct),
      .in_usr(nf_in_usr_direct),
      .nfp_nocheck(fifo3_in_direct),
      .out_pkt(by2pd_in_pkt_direct),
      .out_meta(by2pd_in_meta_direct),
      .out_usr(by2pd_in_usr_direct),

      .stats_out(nf_stats__pcie)
      );
   channel_fifo_avlstrm#(.DUAL_CLOCK(0)) my_by2pd
     (
      .Clk_i(clk_pcie),
      .Rst_n_i(rst_n_pcie),

      .in_pkt(by2pd_in_pkt_direct),
      .in_meta(by2pd_in_meta_direct),
      .in_usr(by2pd_in_usr_direct),

      .out_pkt(dma_in_pkt_direct),
      .out_meta(dma_in_meta_direct),
      .out_usr(dma_in_usr_direct),

      .stats_out(by2pd_stats__pcie),						    
      .stats_in_pkt_max_fill_level_addr(REG_MAX_NF2PDU),
      .stats_in_pkt_addr(REG_MERGE_PKT),
      .stats_in_pkt_sop_addr(REG_MERGE_PKT_SOP),
      .stats_in_meta_addr(REG_MERGE_META),
      .stats_in_rule_addr(REG_MERGE_RULE)
      );
   dma_avlstrm my_dma
     (
      .Clk(clk_pcie),
      .Rst_n(rst_n_pcie),
      .pcie_rb_wr_data(pcie_rb_wr_data),
      .pcie_rb_wr_addr(pcie_rb_wr_addr),
      .pcie_rb_wr_en(pcie_rb_wr_en),
      .pcie_rb_wr_base_addr(pcie_rb_wr_base_addr),
      .pcie_rb_almost_full(pcie_rb_almost_full),
      .pcie_rb_update_valid(internal_rb_update_valid),
      .pcie_rb_update_size(pcie_rb_update_size),
      .disable_pcie(disable_pcie),

      .ddr_wr_req(ddr_wr_req),
      .ddr_rd_req(ddr_rd_req), // not used
      .ddr_rd_resp(ddr_rd_resp), // not used

      .pdumeta_cpu(pdumeta_cpu_nb),
      .in_pkt(dma_in_pkt_direct),
      .in_meta(dma_in_meta_direct),
      .in_usr(dma_in_usr_direct),
      .nomatch_pkt(fifo4_in_direct),
      
      .stats_out(dma_stats__pcie)	
      );
endmodule: top

