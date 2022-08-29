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
