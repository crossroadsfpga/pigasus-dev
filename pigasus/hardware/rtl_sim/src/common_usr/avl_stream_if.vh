//
// Interface and struct definitions
//

// The use of avlon stream if in Pigasus is currently undisciplined
// because the project started out as a point-to-point design where
// modules were individually wired up directly, explicitly.  Each
// Avlon stream is just a local object.
//
// To move to a disaggregated design, we need to be much more careful with
// optional signals and the assumptions about them.  Suggestions:
//    = require optional sop/eop/almost_full to be driven, default to
//      1 if unused (safe value)
//    = managed channel assignment (currently a localized usage)
//    = empty can be left to usage
//

`ifndef AVL_STREAM_IF_VH
`define AVL_STREAM_IF_VH

parameter CH_MIN=4;  // needed by 3-way mux we use
  
interface avl_stream_if#(WIDTH=512,MAX_CH=CH_MIN) ();
   
   typedef logic [WIDTH-1:0]    t_data;
   typedef logic [$clog2(WIDTH/8)-1:0] t_empty;
   typedef logic [$clog2(MAX_CH)-1:0]  t_channel;
   
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

//
// A HACK
//

// use this by default, if you don't use sop/eop or almost full.
// if you do, there will be a conflict during compile, and
// you have to explicitly choose the option.
`define AVL_STREAM_IF(AVWIDTH,AVNAME) \
     avl_stream_if#(.WIDTH(AVWIDTH)) AVNAME(); \
     assign AVNAME.almost_full = 1'b1; \
     assign AVNAME.sop = 1'b1; \
     assign AVNAME.eop = 1'b1;


`define AVL_STREAM_PKT_IF(AVWIDTH,AVNAME) \
     avl_stream_if#(.WIDTH(AVWIDTH)) AVNAME(); \
     assign AVNAME.almost_full = 1'b1; 

`define AVL_STREAM_AF_IF(AVWIDTH,AVNAME) \
     avl_stream_if#(.WIDTH(AVWIDTH)) AVNAME(); \
     assign AVNAME.sop = 1'b1; \
     assign AVNAME.eop = 1'b1;

`define AVL_STREAM_AF_PKT_IF(AVWIDTH,AVNAME) \
     avl_stream_if#(.WIDTH(AVWIDTH)) AVNAME(); 

`endif
