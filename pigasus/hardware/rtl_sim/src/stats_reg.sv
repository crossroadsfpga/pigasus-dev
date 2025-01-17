`ifndef STATS_REG
`define STATS_REG

parameter STATS_INTERVAL = (1<<1);
//parameter STATS_INTERVAL = (1<<7);

parameter REG_IN_PKT                  = 0;
parameter REG_OUT_PKT                 = 1;
parameter REG_INCOMP_OUT_META         = 2;
parameter REG_PARSER_OUT_META         = 3;
parameter REG_FT_IN_META              = 4;
parameter REG_FT_OUT_META             = 5;
parameter REG_EMPTYLIST_IN            = 6;
parameter REG_EMPTYLIST_OUT           = 7;
parameter REG_DM_IN_META              = 8;
parameter REG_DM_OUT_META             = 9;
parameter REG_DM_IN_FORWARD_META      = 10; 
parameter REG_DM_IN_DROP_META         = 11;
parameter REG_DM_IN_CHECK_META        = 12;
parameter REG_DM_IN_OOO_META          = 13;
parameter REG_DM_IN_FORWARD_OOO_META  = 14;
parameter REG_NOPAYLOAD_PKT           = 15;
parameter REG_DM_CHECK_PKT            = 16;
parameter REG_SM_PKT                  = 17;
parameter REG_SM_META                 = 18;
parameter REG_SM_RULE                 = 19;
parameter REG_SM_CHECK_PKT            = 20; 
parameter REG_SM_CHECK_PKT_SOP        = 21; 
parameter REG_SM_NOCHECK_PKT          = 22;
parameter REG_PG_PKT                  = 23;
parameter REG_PG_META                 = 24;
parameter REG_PG_RULE                 = 25;
parameter REG_PG_CHECK_PKT            = 26;
parameter REG_PG_CHECK_PKT_SOP        = 27;
parameter REG_PG_NOCHECK_PKT          = 28;
parameter REG_BYPASS_PKT              = 29;
parameter REG_BYPASS_PKT_SOP          = 30;
parameter REG_BYPASS_META             = 31;
parameter REG_BYPASS_RULE             = 32;
parameter REG_NF_PKT                  = 33;
parameter REG_NF_META                 = 34;
parameter REG_NF_RULE                 = 35;
parameter REG_NF_CHECK_PKT            = 36;
parameter REG_NF_CHECK_PKT_SOP        = 37;
parameter REG_NF_NOCHECK_PKT          = 38;
parameter REG_MERGE_PKT               = 39;
parameter REG_MERGE_PKT_SOP           = 40;
parameter REG_MERGE_META              = 41;
parameter REG_MERGE_RULE              = 42;
parameter REG_DMA_PKT                 = 43;
parameter REG_CPU_NOMATCH_PKT         = 44;
parameter REG_CPU_MATCH_PKT           = 45;
parameter REG_CTRL                    = 46;
parameter REG_MAX_DM2SM               = 47;
parameter REG_MAX_SM2PG               = 48;
parameter REG_MAX_PG2NF               = 49;
parameter REG_MAX_BYPASS2NF           = 50;
parameter REG_MAX_NF2PDU              = 51;
parameter REG_SM_BYPASS_AF            = 52;
parameter REG_SM_CDC_AF               = 53;

parameter NUM_REG = 54;
parameter REG_NOTUSED = NUM_REG;

`endif
