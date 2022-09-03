//
// Interface and struct definitions
//

// The use of avlon stream if in Pigasus is currently a little
// undisciplined because the project started out as a point-to-point
// design with tx/rx modules wired up directly, explicitly.  Each
// Avlon stream is just an local object understood by the tx and rx
// pair.
//
// In a disaggregated form, the stream could be passed through
// arbitrary intermediary (i.e., a noc).  We need to be much more
// careful with optional signals and the assumptions about them.
// Optional sop/eop/almost_full should be driven to their default safe
// values (1'b1) if not controlled/consumed by the design.  We should
// think about how to manage channel assignment (currently a localized
// usage only).  "empty" and "error" doesn't affect intermediary so
// can be left to end point interpretation.
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
// A HACK: this keeps us safe for now, but it seems there must be a
// better way to enforce the discipline.
//
// By default, use the `AVL_STREAM_IF macro to start, which assumes tx
// does not set almost_full and rx does not use almost_full.  sop/eop
// are always set (so each beat is treated as its own packet).  If the
// signal producer violates the assumptions, compiler will generate
// a conflict.
//
// If something else is desired, you have to opt in by using one of
// the other options.
//

`define AVL_STREAM_IF(AVWIDTH,AVNAME) \
     avl_stream_if#(.WIDTH(AVWIDTH)) AVNAME(); \
     assign AVNAME.almost_full = 1'b1; \
     assign AVNAME.sop = 1'b1; \
     assign AVNAME.eop = 1'b1;


//
// _PKT_ means sop and eop are generated by the tx module to form
// multi-beat packets.
//
// _AF_ means almost_full is controlled by the rx module and can be
// relied on meaningfully by the tx module.
//

`define AVL_STREAM_PKT_IF(AVWIDTH,AVNAME) \
     avl_stream_if#(.WIDTH(AVWIDTH)) AVNAME(); \
     assign AVNAME.almost_full = 1'b1; 

`define AVL_STREAM_AF_IF(AVWIDTH,AVNAME) \
     avl_stream_if#(.WIDTH(AVWIDTH)) AVNAME(); \
     assign AVNAME.sop = 1'b1; \
     assign AVNAME.eop = 1'b1;

`define AVL_STREAM_AF_PKT_IF(AVWIDTH,AVNAME) \
     avl_stream_if#(.WIDTH(AVWIDTH)) AVNAME(); 

//
// The _NB_ option is not a proper avlon stream.
//
// The top-level module (top.sv) i/o has interfaces that look like
// streams but do not follow "ready" backpressure.  We still bundle
// them to simplify the code, but they are not directly compatible
// with stream semantics and cannot be funnel through intermediaries
// directly without fixing something..
//
// For example, the stats request streams could be fixed by
// establishing a credit system so the requestor self throttles by
// allowing only so many outstanding requests.  A shim with the
// worst-case buffering can translate from credit to backpressure.
//
// The following 2 cases are more special yet.
// 
//   pkt_buf is sensitive and must be left as wires.
//
//   eth_in is connect to a fifo that does control ready and almost
//   full, but inbound ethernet IP cannot be backpressured.  The fifo
//   simply drops packet if it can't keep up.  You probably do not
//   want to run eth_in over NoC, at least not without specail care to
//   ensure there is sufficient bW and consumption capacity on the way
//   and downstream.
//
// In _NB_, ready is set to 0 to make sure rx does not look at it and
// tx does not set it.  These are not proper avlon streams. Be very
// careful.
//

`define AVL_STREAM_NB_IF(AVWIDTH,AVNAME) \
     avl_stream_if#(.WIDTH(AVWIDTH)) AVNAME(); \
     assign AVNAME.almost_full = 1'b1; \
     assign AVNAME.ready = 1'b0; \
     assign AVNAME.sop = 1'b1; \
     assign AVNAME.eop = 1'b1;


`endif
