`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"
`include "./src/stats_reg.sv"

// top-level module
module dma_avlstrm 
  (
   input logic 			    Clk, 
   input logic 			    Rst_n,
   
   // PCIe
   output 			    flit_lite_t pcie_rb_wr_data,
   output logic [PDU_AWIDTH-1:0]    pcie_rb_wr_addr,
   output logic 		    pcie_rb_wr_en,
   input logic [PDU_AWIDTH-1:0]     pcie_rb_wr_base_addr,
   input logic 			    pcie_rb_almost_full,
   output logic 		    pcie_rb_update_valid,
   output logic [PDU_AWIDTH-1:0]    pcie_rb_update_size,
   input logic 			    disable_pcie,
   
   // DRAM
   output 			    ddr_wr_t ddr_wr_req_data,
   output logic 		    ddr_wr_req_valid,
   input logic 			    ddr_wr_req_almost_full,
   output 			    ddr_rd_t ddr_rd_req_data,
   output logic 		    ddr_rd_req_valid,
   input logic 			    ddr_rd_req_almost_full,
   input logic [511:0] 		    ddr_rd_resp_data,
   input logic 			    ddr_rd_resp_valid,
   output logic 		    ddr_rd_resp_almost_full,
				    
   avl_stream_if.rx pdumeta_cpu,
   avl_stream_if.rx in_pkt,
   avl_stream_if.rx in_meta,
   avl_stream_if.rx in_usr,
   avl_stream_if.tx nomatch_pkt,
   
   // stats channel			    
   avl_stream_if.tx stats_out
);

   assign in_pkt.almost_full=0;
   assign in_meta.almost_full=0;
   assign in_usr.almost_full=0;
 
   logic [31:0] 		    dma_pkt;
   logic [31:0] 		    cpu_nomatch_pkt;
   logic [31:0] 		    cpu_match_pkt;

   //PCIe clock domain
   pdu_metadata_t tmp_pdumeta_cpu_data;
   logic [PDU_META_WIDTH-1:0] 	    pdumeta_cpu_data;
   logic 			    pdumeta_cpu_valid;
   logic 			    pdumeta_cpu_ready;

   assign pdumeta_cpu_data = pdumeta_cpu.data;
   assign pdumeta_cpu_valid = pdumeta_cpu.valid;
   assign pdumeta_cpu.ready = pdumeta_cpu_ready;

   assign tmp_pdumeta_cpu_data = pdumeta_cpu_data;
   always @(posedge Clk) begin
      if (!Rst_n) begin
         dma_pkt <= 0;
         cpu_nomatch_pkt <= 0;
         cpu_match_pkt <= 0;
      end else begin
         if (pcie_rb_update_valid) begin
            dma_pkt <= dma_pkt + 1;
         end
         if (pdumeta_cpu_valid & pdumeta_cpu_ready & (tmp_pdumeta_cpu_data.action == ACTION_NOMATCH)) begin
            cpu_nomatch_pkt <= cpu_nomatch_pkt + 1;
         end
         if (pdumeta_cpu_valid & pdumeta_cpu_ready & (tmp_pdumeta_cpu_data.action == ACTION_MATCH)) begin
            cpu_match_pkt <= cpu_match_pkt + 1;
         end
      end
   end
   
   stats_t dma_pkt_s;
   stats_t cpu_nomatch_pkt_s;
   stats_t cpu_match_pkt_s;

   assign dma_pkt_s.addr = REG_DMA_PKT;
   assign cpu_nomatch_pkt_s.addr = REG_CPU_NOMATCH_PKT;
   assign cpu_match_pkt_s.addr = REG_CPU_MATCH_PKT;

   assign dma_pkt_s.val = dma_pkt;
   assign cpu_nomatch_pkt_s.val = cpu_nomatch_pkt;
   assign cpu_match_pkt_s.val = cpu_match_pkt;

   stats_packer_avlstrm #(3) stats_pack 
   (
    .Clk(Clk), 
    .Rst_n(Rst_n),
    
    .stats({
	     dma_pkt_s,
	     cpu_nomatch_pkt_s,
	     cpu_match_pkt_s
	    }),
    
    .stats_out(stats_out)
   );

   logic [511:0]  pdu_gen_data;
   logic          pdu_gen_sop;
   logic          pdu_gen_eop;
   logic [5:0] 	  pdu_gen_empty;
   logic          pdu_gen_valid;
   logic          pdu_gen_ready;
   logic 	  pdu_gen_almost_full;
   pdu_metadata_t pdumeta_gen_data;
   logic 	  pdumeta_gen_valid;
   logic 	   pdumeta_gen_ready;
   logic [PDUID_WIDTH-1:0] pdu_emptylist_out_data;
   logic                   pdu_emptylist_out_valid;
   logic                   pdu_emptylist_out_ready;
   
   pdu_metadata_t pdumeta_cpu_fifo_data;
   logic 		   pdumeta_cpu_fifo_valid;
   logic 		   pdumeta_cpu_fifo_ready;
   logic [31:0] 	   pdumeta_cpu_csr_readdata;
   
   
   logic [511:0] 	   ddr_rd_resp_fifo_data;
   logic 		   ddr_rd_resp_fifo_valid;
   logic 		   ddr_rd_resp_fifo_ready;
   logic [31:0] 	   ddr_rd_resp_csr_readdata;

pdu_gen pdu_gen_inst(
    .clk                    (Clk),
    .rst                    (~Rst_n),
    .in_sop                 (in_pkt.sop),
    .in_eop                 (in_pkt.eop),
    .in_data                (in_pkt.data),
    .in_empty               (in_pkt.empty),
    .in_valid               (in_pkt.valid),
    .in_ready               (in_pkt.ready),
    .in_match_sop           (in_usr.sop),
    .in_match_eop           (in_usr.eop),
    .in_match_data          (in_usr.data),
    .in_match_empty         (in_usr.empty),
    .in_match_valid         (in_usr.valid),
    .in_match_ready         (in_usr.ready),
    .in_meta_valid          (in_meta.valid),
    .in_meta_ready          (in_meta.ready),
    .in_meta_data           (in_meta.data),
    .pcie_rb_wr_data        (pcie_rb_wr_data),
    .pcie_rb_wr_addr        (pcie_rb_wr_addr),
    .pcie_rb_wr_en          (pcie_rb_wr_en),
    .pcie_rb_wr_base_addr   (pcie_rb_wr_base_addr),
    .pcie_rb_almost_full    (pcie_rb_almost_full),
    .pcie_rb_update_valid   (pcie_rb_update_valid),
    .pcie_rb_update_size    (pcie_rb_update_size),
    .disable_pcie           (disable_pcie),
    .pdu_emptylist_out_data (pdu_emptylist_out_data),
    .pdu_emptylist_out_valid(pdu_emptylist_out_valid),
    .pdu_emptylist_out_ready(pdu_emptylist_out_ready),
    .pdu_gen_data           (pdu_gen_data),
    .pdu_gen_sop            (pdu_gen_sop),
    .pdu_gen_eop            (pdu_gen_eop),
    .pdu_gen_empty          (pdu_gen_empty),
    .pdu_gen_valid          (pdu_gen_valid),
    .pdu_gen_ready          (pdu_gen_ready),
    .pdu_gen_almost_full    (pdu_gen_almost_full),
    .pdumeta_gen_data       (pdumeta_gen_data),
    .pdumeta_gen_valid      (pdumeta_gen_valid),
    .pdumeta_gen_ready      (pdumeta_gen_ready)
);
//////////////////// PDU DATAMOVER //////////////////////////////////
unified_fifo  #(
    .FIFO_NAME        ("[top] pdumeta_cpu_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (0),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (PDU_META_WIDTH),
    .FIFO_DEPTH       (512)
) pdumeta_cpu_fifo (
    .in_clk            (Clk),
    .in_reset          (~Rst_n),
    .out_clk           (),//not used
    .out_reset         (),//not used
    .in_data           (pdumeta_cpu_data),
    .in_valid          (pdumeta_cpu_valid),
    .in_ready          (pdumeta_cpu_ready),
    .out_data          (pdumeta_cpu_fifo_data),
    .out_valid         (pdumeta_cpu_fifo_valid),
    .out_ready         (pdumeta_cpu_fifo_ready),
    .fill_level        (pdumeta_cpu_csr_readdata),
    .almost_full       (),
    .overflow          ()
);

unified_fifo  #(
    .FIFO_NAME        ("[top] ddr_resp_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (512),
    .FIFO_DEPTH       (512)
) ddr_resp_fifo (
    .in_clk            (Clk),
    .in_reset          (~Rst_n),
    .out_clk           (),//not used
    .out_reset         (),//not used
    .in_data           (ddr_rd_resp_data),
    .in_valid          (ddr_rd_resp_valid),
    .in_ready          (ddr_rd_resp_ready),
    .out_data          (ddr_rd_resp_out_data),
    .out_valid         (ddr_rd_resp_out_valid),
    .out_ready         (ddr_rd_resp_out_ready),
    .fill_level        (ddr_rd_resp_csr_readdata),
    .almost_full       (ddr_rd_resp_almost_full),
    .overflow          ()
);

pdu_data_mover pdu_data_mover_inst (
    .clk                    (Clk),
    .rst                    (~Rst_n),
    .pdu_emptylist_out_data (pdu_emptylist_out_data),
    .pdu_emptylist_out_valid(pdu_emptylist_out_valid),
    .pdu_emptylist_out_ready(pdu_emptylist_out_ready),
    .pdumeta_gen_data       (pdumeta_gen_data),
    .pdumeta_gen_valid      (pdumeta_gen_valid),
    .pdumeta_gen_ready      (pdumeta_gen_ready),
    .pdu_gen_data           (pdu_gen_data),
    .pdu_gen_sop            (pdu_gen_sop),
    .pdu_gen_eop            (pdu_gen_eop),
    .pdu_gen_empty          (pdu_gen_empty),
    .pdu_gen_valid          (pdu_gen_valid),
    .pdu_gen_ready          (pdu_gen_ready),
    .pdu_gen_almost_full    (pdu_gen_almost_full),
    .pdumeta_cpu_data       (pdumeta_cpu_fifo_data),
    .pdumeta_cpu_valid      (pdumeta_cpu_fifo_valid),
    .pdumeta_cpu_ready      (pdumeta_cpu_fifo_ready),
    .nocheck_data           (),
    .nocheck_sop            (),
    .nocheck_eop            (),
    .nocheck_valid          (),
    .nocheck_empty          (),
    .nocheck_ready          (),                     // Not using ready signal,
    .nocheck_almost_full    (1'b0),  // Use almost_full signal
    .nomatch_data           (nomatch_pkt.data),
    .nomatch_sop            (nomatch_pkt.sop),
    .nomatch_eop            (nomatch_pkt.eop),
    .nomatch_valid          (nomatch_pkt.valid),
    .nomatch_empty          (nomatch_pkt.empty),
    .nomatch_ready          (),                     // Not using ready signal,
    .nomatch_almost_full    (nomatch_pkt.almost_full),  // Use almost_full signal
    .ddr_wr_req_data        (ddr_wr_req_data),
    .ddr_wr_req_valid       (ddr_wr_req_valid),
    .ddr_wr_req_almost_full (ddr_wr_req_almost_full),
    .ddr_rd_req_data        (ddr_rd_req_data),
    .ddr_rd_req_valid       (ddr_rd_req_valid),
    .ddr_rd_req_almost_full (ddr_rd_req_almost_full),
    .ddr_rd_resp_data       (ddr_rd_resp_out_data),
    .ddr_rd_resp_valid      (ddr_rd_resp_out_valid),
    .ddr_rd_resp_ready      (ddr_rd_resp_out_ready)
);

endmodule
