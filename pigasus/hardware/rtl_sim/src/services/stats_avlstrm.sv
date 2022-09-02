`include "./src/common_usr/avl_stream_if.vh"
`include "./src/struct_s.sv"
`include "./src/stats_reg.sv"

module stats_packer_avlstrm 
  #(
    parameter NUM_STATS = 1, ID =0
    ) (
   input logic Clk, 
   input logic Rst_n,
			      
   input       stats_t stats[NUM_STATS],
   
   avl_stream_if.tx stats_out
   );

   reg [$clog2(STATS_INTERVAL)-1:0] counter;
   reg [$clog2(NUM_STATS):0] 	    tick;
   
   always@(*) begin
      stats_out.valid=0;
      stats_out.eop=0;
      stats_out.sop=0;

      if ((counter==0) && (tick!=0) && (stats[tick-1].addr!=REG_NOTUSED)) begin
	 stats_out.valid=1;
	 stats_out.sop=1;
	 stats_out.eop=1;
	 stats_out.data=stats[tick-1];
      end
   end
   
   always@(posedge Clk) begin
      if (!Rst_n) begin
	 counter<=0;
	 tick<=0;
      end else begin
	 if ((counter==0) && (tick==0)) begin
	    tick<=NUM_STATS;
	 end else if ((counter==0) && (tick!=0)) begin
	    if (stats_out.ready) begin
	       //$display("STAT PUSH: %d %d\n", stats[tick-1].addr, stats[tick-1].val);
	       tick<=tick-1;
	       if (tick==1) begin
		  counter<=1;
	       end
	    end
	 end else begin
	    counter<=counter+1;
	 end
      end
   end

endmodule

module stats_unpacker_avlstrm (
   input logic Clk, 

   input logic [7:0] readaddr,
   output logic [31:0] readdata,
   
   avl_stream_if.rx stats_in
   );

   reg [31:0] 	       rfile[NUM_REG];
   
   stats_t stats;
   assign stats = stats_in.data;
   
   assign stats_in.ready=1;

   always@(posedge Clk) begin
      if (stats_in.valid && (stats.addr<NUM_REG)) begin
	 //$display("STAT POPH: %d %d\n", stats.addr, stats.val);
	 rfile[stats.addr]<=stats.val;
      end
   end

   always@(*) begin
      readdata=rfile[readaddr];
   end

endmodule


module stats_avlstrm
  (
   input logic Clk_status, 
   input logic Clk_pcie,

   avl_stream_if.rx stats_update,
   avl_stream_if.rx stats_wreq,
   avl_stream_if.rx stats_rreq,
   avl_stream_if.tx stats_rresp
   );

   logic [31:0] stats_unpackdata;
   logic [31:0] ctrl_status;
   
   logic [29:0] status_raddr;
   logic [29:0] status_waddr;
   logic [0:0] 	status_read;
   logic [0:0] 	status_write;
   logic [31:0] status_writedata;
   logic [31:0] status_readdata;
   logic [0:0] 	status_readdata_valid;

   logic [7:0] 	status_raddr_r;
   logic [7:0] 	status_waddr_r;
   logic [STAT_AWIDTH-1:0] status_raddr_sel_r;
   logic [STAT_AWIDTH-1:0] status_waddr_sel_r;
   logic 		   status_write_r;
   logic 		   status_read_r;
   logic [31:0] 	   status_writedata_r;
   
   stats_unpacker_avlstrm stats_unpacker 
     (
      .Clk(Clk_pcie),
      .stats_in(stats_update),
      
      // combinational read from pci_status domain
      .readaddr(status_raddr_r),
      .readdata(stats_unpackdata)  
      );
   
   assign status_raddr=status_rreq.data;
   assign status_read=status_rreq.valid;
   
   assign status_waddr=status_wreq.data[61:32];
   assign status_writedata=status_wreq.data[31:0];
   assign status_write=status_wreq.valid;
  
   assign status_rresp.data=status_readdata;
   assign status_rresp.valid=status_readdata_valid;
 
   always @(posedge Clk_status) begin
      status_raddr_r           <= status_raddr[7:0];
      status_waddr_r           <= status_waddr[7:0];
      status_raddr_sel_r       <= status_raddr[29:30-STAT_AWIDTH];
      status_waddr_sel_r       <= status_waddr[29:30-STAT_AWIDTH];
      
      status_read_r           <= status_read;
      status_write_r          <= status_write;
      status_writedata_r      <= status_writedata;
      status_readdata_valid <= 1'b0;
      
      if (status_read_r) begin
         if (status_raddr_sel_r == TOP_REG) begin
            status_readdata_valid <= 1'b1;
            if (status_raddr_r==REG_CTRL) begin
               status_readdata <= ctrl_status;
	    end else begin
               status_readdata <= stats_unpackdata;
	    end
         end
      end
      //Disable write
      if (status_waddr_sel_r == TOP_REG & status_write_r) begin
         case (status_waddr_r)
           REG_CTRL: begin
              ctrl_status   <= status_writedata_r;
           end
           default: ctrl_status <= 32'b0;
         endcase
      end
   end
endmodule
		     
