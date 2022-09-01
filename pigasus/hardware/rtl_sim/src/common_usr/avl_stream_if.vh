//
// Interface and struct definitions
//

`ifndef AVL_STREAM_IF_VH
`define AVL_STREAM_IF_VH

interface avl_stream_if#(WIDTH=512,NUM=2) ();
   
   typedef logic [WIDTH-1:0]    t_data;
   typedef logic [$clog2(WIDTH/8)-1:0] t_empty;
   typedef logic [NUM-1:0] 	t_channel;
   
   t_data      data;
   logic 			valid;
   logic 			ready;
   logic 			sop;
   logic 			eop;
   t_empty     empty;
   logic 			almost_full;
   t_channel   channel;
   
   modport tx
     (
      output data,
      output valid,
      input  ready,
      output sop,
      output eop,
      output empty,
      input  almost_full,
      output channel
      );

   modport rx
     (
      input  data,
      input  valid,
      output ready,
      input  sop,
      input  eop,
      input  empty,
      output almost_full,
      input  channel
      );

endinterface

`endif
