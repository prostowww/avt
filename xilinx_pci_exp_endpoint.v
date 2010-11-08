//------------------------------------------------------------------------------
//--
//-- This file is owned and controlled by Xilinx and must be used solely
//-- for design, simulation, implementation and creation of design files
//-- limited to Xilinx devices or technologies. Use with non-Xilinx
//-- devices or technologies is expressly prohibited and immediately
//-- terminates your license.
//--
//-- Xilinx products are not intended for use in life support
//-- appliances, devices, or systems. Use in such applications is
//-- expressly prohibited.
//--
//--            **************************************
//--            ** Copyright (C) 2005, Xilinx, Inc. **
//--            ** All Rights Reserved.             **
//--            **************************************
//--
//------------------------------------------------------------------------------
//-- Filename: XILINX_PCI_EXP_EP.v
//--
//-- Description:  PCI Express Endpoint Core example design top level wrapper.
//--               
//--
//------------------------------------------------------------------------------


module     `XILINX_PCI_EXP_EP (

                        // PCI Express Fabric Interface

                        pci_exp_txp,
                        pci_exp_txn,
                        pci_exp_rxp,
                        pci_exp_rxn,

`ifdef IMPL_TEST

                        prsnt1,
                        prsnt2x1,
                        prsnt2x4,

                        S_CLK,
                        S_LOAD,
                        S_DATA,
                        MR_84321,
                        MR_87354,

                        led_0,
                        led_1,
                        led_2,
                        led_3,
                        led_4,
                        led_5,
                        led_6,
                        led_7,
                        led_8,
                        led_9,
                        

`else // IMPL_TEST
                        // Transaction (TRN) Interface

                        trn_clk,
                        trn_reset_n,
                        trn_lnk_up_n,

                        // Tx
                        trn_td,
`ifdef PCI_EXP_64B_EP
                        trn_trem_n,
`endif // PCI_EXP_64B_EP
                        trn_tsof_n,
                        trn_teof_n,
                        trn_tsrc_rdy_n,
                        trn_tdst_rdy_n,
                        trn_tsrc_dsc_n,
                        trn_terrfwd_n,
                        trn_tdst_dsc_n,
                        trn_tbuf_av,
                        
                        // Rx
                        trn_rd,
`ifdef PCI_EXP_64B_EP
                        trn_rrem_n,
`endif // PCI_EXP_64B_EP
                        trn_rsof_n,
                        trn_reof_n,
                        trn_rsrc_rdy_n,
                        trn_rsrc_dsc_n,
                        trn_rdst_rdy_n,
                        trn_rerrfwd_n,
                        trn_rnp_ok_n,
                        trn_rbar_hit_n,
                        trn_rfc_nph_av,
                        trn_rfc_npd_av,
                        trn_rfc_ph_av,
                        trn_rfc_pd_av,
                        trn_rfc_cplh_av,
                        trn_rfc_cpld_av,

                        // Host (CFG) Interface

                        cfg_do,
                        cfg_rd_wr_done_n,
                        cfg_di,
                        cfg_byte_en_n,
                        cfg_dwaddr,
                        cfg_wr_en_n,
                        cfg_rd_en_n,
                        cfg_err_cor_n,
                        cfg_err_ur_n,
                        cfg_err_ecrc_n,
                        cfg_err_cpl_timeout_n,
                        cfg_err_cpl_abort_n,
                        cfg_err_cpl_unexpect_n,
                        cfg_err_posted_n,
                        cfg_err_tlp_cpl_header,
                        cfg_interrupt_n,
                        cfg_interrupt_rdy_n,
                        cfg_turnoff_ok_n,
                        cfg_to_turnoff_n,
                        cfg_pcie_link_state_n,
                        cfg_trn_pending_n,
                        cfg_pm_wake_n,
                        cfg_bus_number,
                        cfg_device_number,
                        cfg_function_number,
                        cfg_status,
                        cfg_command,
                        cfg_dstatus,
                        cfg_dcommand,
                        cfg_lstatus,
                        cfg_lcommand,

`endif // IMPL_TEST

                        // System (SYS) Interface

                        sys_clk_p,
                        sys_clk_n,
                        sys_reset_n

                        ); // synthesis syn_noclockbuf=1

    //-------------------------------------------------------
    // 1. PCI Express Fabric Interface
    //-------------------------------------------------------

    // Tx
    output    [(`PCI_EXP_LINK_WIDTH - 1):0]           pci_exp_txp;
    output    [(`PCI_EXP_LINK_WIDTH - 1):0]           pci_exp_txn;

    // Rx
    input     [(`PCI_EXP_LINK_WIDTH - 1):0]           pci_exp_rxp;
    input     [(`PCI_EXP_LINK_WIDTH - 1):0]           pci_exp_rxn;

`ifdef IMPL_TEST

    /*
     * Core IOs not pulled to IOBs for implementation demonstration
     */

     input                                            prsnt1;
     output                                           prsnt2x1;
     output                                           prsnt2x4;
     
     output                                           S_CLK;
     output                                           S_LOAD;
     output                                           S_DATA;
     output                                           MR_84321;
     output                                           MR_87354;

     output                                           led_0;
     output                                           led_1;
     output                                           led_2;
     output                                           led_3;
     output                                           led_4;
     output                                           led_5;
     output                                           led_6;
     output                                           led_7;
     output                                           led_8;
     output                                           led_9;

`else // IMPL_TEST

    /*
     * Core IOs pulled to IOB for simulation demonstration
     */

    //-------------------------------------------------------
    // 2. Transaction (TRN) Interface
    //-------------------------------------------------------

    //
    // Common
    //

    output                                            trn_clk;
    output                                            trn_reset_n;
    output                                            trn_lnk_up_n;

    //
    // Tx
    //

    input     [(`PCI_EXP_TRN_DATA_WIDTH - 1):0]       trn_td;
`ifdef PCI_EXP_64B_EP
    input     [(`PCI_EXP_TRN_REM_WIDTH - 1):0]        trn_trem_n;
`endif // PCI_EXP_64B_EP
    input                                             trn_tsof_n;
    input                                             trn_teof_n;
    input                                             trn_tsrc_rdy_n;
    output                                            trn_tdst_rdy_n;
    input                                             trn_tsrc_dsc_n;
    input                                             trn_terrfwd_n;
    output                                            trn_tdst_dsc_n;
    output    [(`PCI_EXP_TRN_BUF_AV_WIDTH - 1):0]     trn_tbuf_av;    

    //
    // Rx
    //

    output    [(`PCI_EXP_TRN_DATA_WIDTH - 1):0]       trn_rd;
`ifdef PCI_EXP_64B_EP
    output    [(`PCI_EXP_TRN_REM_WIDTH - 1):0]        trn_rrem_n;
`endif // PCI_EXP_64B_EP
    output                                            trn_rsof_n;
    output                                            trn_reof_n;
    output                                            trn_rsrc_rdy_n;
    output                                            trn_rsrc_dsc_n;
    input                                             trn_rdst_rdy_n;
    output                                            trn_rerrfwd_n;
    input                                             trn_rnp_ok_n;

    output    [(`PCI_EXP_TRN_BAR_HIT_WIDTH - 1):0]    trn_rbar_hit_n;
    output    [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]     trn_rfc_nph_av;
    output    [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]    trn_rfc_npd_av;
    output    [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]     trn_rfc_ph_av;
    output    [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]    trn_rfc_pd_av;
    output    [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]     trn_rfc_cplh_av;
    output    [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]    trn_rfc_cpld_av;

    //-------------------------------------------------------
    // 3. Host (CFG) Interface
    //-------------------------------------------------------

    output   [(`PCI_EXP_CFG_DATA_WIDTH - 1):0]        cfg_do;
    input    [(`PCI_EXP_CFG_DATA_WIDTH - 1):0]        cfg_di;
    input    [(`PCI_EXP_CFG_DATA_WIDTH/8 - 1):0]      cfg_byte_en_n;
    input    [(`PCI_EXP_CFG_ADDR_WIDTH - 1):0]        cfg_dwaddr;
    output                                            cfg_rd_wr_done_n;
    input                                             cfg_wr_en_n;
    input                                             cfg_rd_en_n;
    input                                             cfg_err_cor_n;
    input                                             cfg_err_ur_n;
    input                                             cfg_err_ecrc_n;
    input                                             cfg_err_cpl_timeout_n;
    input                                             cfg_err_cpl_abort_n;
    input                                             cfg_err_cpl_unexpect_n;
    input                                             cfg_err_posted_n;    
    input                                             cfg_interrupt_n;
    output                                            cfg_interrupt_rdy_n;
    input                                             cfg_turnoff_ok_n;
    output                                            cfg_to_turnoff_n;
    input                                             cfg_pm_wake_n;
    output    [(`PCI_EXP_LNK_STATE_WIDTH - 1):0]      cfg_pcie_link_state_n;
    input                                             cfg_trn_pending_n;
    input     [(`PCI_EXP_CFG_CPLHDR_WIDTH - 1):0]     cfg_err_tlp_cpl_header;

    output    [(`PCI_EXP_CFG_BUSNUM_WIDTH - 1):0]     cfg_bus_number;
    output    [(`PCI_EXP_CFG_DEVNUM_WIDTH - 1):0]     cfg_device_number;
    output    [(`PCI_EXP_CFG_FUNNUM_WIDTH - 1):0]     cfg_function_number;
    output    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]        cfg_status;
    output    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]        cfg_command;
    output    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]        cfg_dstatus;
    output    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]        cfg_dcommand;
    output    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]        cfg_lstatus;
    output    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]        cfg_lcommand;

`endif // IMPL_TEST

    //-------------------------------------------------------
    // 4. System (SYS) Interface
    //-------------------------------------------------------

    input                                             sys_clk_p;
    input                                             sys_clk_n;
    input                                             sys_reset_n;

    //-------------------------------------------------------
    // Local Wires
    //-------------------------------------------------------

    genvar                                            i;

    wire                                              sys_clk_c;
    wire                                              sys_reset_n_c;
    wire                                              trn_clk_c;
    wire                                              trn_reset_n_c;
    wire                                              trn_lnk_up_n_c;
    wire                                              cfg_trn_pending_n_c;
    wire                                              trn_tsof_n_c;
    wire                                              trn_teof_n_c;
    wire                                              trn_tsrc_rdy_n_c;
    wire                                              trn_tdst_rdy_n_c;
    wire                                              trn_tsrc_dsc_n_c;
    wire                                              trn_terrfwd_n_c;
    wire                                              trn_tdst_dsc_n_c;
    wire    [(`PCI_EXP_TRN_DATA_WIDTH - 1):0]         trn_td_c;
    wire    [(`PCI_EXP_TRN_REM_WIDTH - 1):0]          trn_trem_n_c;

    wire    [(`PCI_EXP_TRN_BUF_AV_WIDTH - 1):0]       trn_tbuf_av_c;

    wire                                              trn_rsof_n_c;
    wire                                              trn_reof_n_c;
    wire                                              trn_rsrc_rdy_n_c;
    wire                                              trn_rsrc_dsc_n_c;
    wire                                              trn_rdst_rdy_n_c;
    wire                                              trn_rerrfwd_n_c;
    wire                                              trn_rnp_ok_n_c;
    wire    [(`PCI_EXP_TRN_DATA_WIDTH - 1):0]         trn_rd_c;
    wire    [(`PCI_EXP_TRN_REM_WIDTH - 1):0]          trn_rrem_n_c;

    wire    [(`PCI_EXP_TRN_BAR_HIT_WIDTH - 1):0]      trn_rbar_hit_n_c;
    wire    [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]       trn_rfc_nph_av_c;
    wire    [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]      trn_rfc_npd_av_c;
    wire    [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]       trn_rfc_ph_av_c;
    wire    [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]      trn_rfc_pd_av_c;
    wire    [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]       trn_rfc_cplh_av_c;
    wire    [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]      trn_rfc_cpld_av_c;

    wire    [(`PCI_EXP_CFG_DATA_WIDTH - 1):0]         cfg_do_c;
    wire    [(`PCI_EXP_CFG_DATA_WIDTH - 1):0]         cfg_di_c;
    wire    [(`PCI_EXP_CFG_ADDR_WIDTH - 1):0]         cfg_dwaddr_c;
    wire    [(`PCI_EXP_CFG_DATA_WIDTH/8 - 1):0]       cfg_byte_en_n_c;
    wire    [(`PCI_EXP_CFG_CPLHDR_WIDTH - 1):0]       cfg_err_tlp_cpl_header_c;
    wire                                              cfg_wr_en_n_c;
    wire                                              cfg_rd_en_n_c;
    wire                                              cfg_rd_wr_done_n_c;
    wire                                              cfg_err_cor_n_c;
    wire                                              cfg_err_ur_n_c;
    wire                                              cfg_err_ecrc_n_c;
    wire                                              cfg_err_cpl_timeout_n_c;
    wire                                              cfg_err_cpl_abort_n_c;
    wire                                              cfg_err_cpl_unexpect_n_c;
    wire                                              cfg_err_posted_n_c;    
    wire                                              cfg_interrupt_n_c;
    wire                                              cfg_interrupt_rdy_n_c;
    wire                                              cfg_turnoff_ok_n_c;
    wire                                              cfg_to_turnoff_n;
    wire                                              cfg_pm_wake_n_c;
    wire    [(`PCI_EXP_LNK_STATE_WIDTH - 1):0]        cfg_pcie_link_state_n_c;
    wire    [(`PCI_EXP_CFG_BUSNUM_WIDTH - 1):0]       cfg_bus_number_c;
    wire    [(`PCI_EXP_CFG_DEVNUM_WIDTH - 1):0]       cfg_device_number_c;
    wire    [(`PCI_EXP_CFG_FUNNUM_WIDTH - 1):0]       cfg_function_number_c;
    wire    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]          cfg_status_c;
    wire    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]          cfg_command_c;
    wire    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]          cfg_dstatus_c;
    wire    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]          cfg_dcommand_c;
    wire    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]          cfg_lstatus_c;
    wire    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]          cfg_lcommand_c;

    wire    [(`PCI_EXP_CFG_CFG_WIDTH - 1):0]          cfg_cfg;

    // synthesis attribute max_fanout of trn_clk_c is "10000";

`ifdef VIRTEX2PRO

  //-------------------------------------------------------
  // Virtex 2 Pro Clock Pad Instance
  //-------------------------------------------------------

  IBUFDS sys_clk_ibuf (.O(sys_clk_c), .I(sys_clk_p), .IB(sys_clk_n));

`endif // VIRTEX2PRO

`ifdef VIRTEX4FX

  //-------------------------------------------------------
  // Virtex 4 FX Dedicated GT Clock Pad Instance
  //-------------------------------------------------------

  GT11CLK_MGT sys_clk_mgt (   

      .SYNCLK1OUT(sys_clk_c),
      .SYNCLK2OUT(),
      .MGTCLKP(sys_clk_p),
      .MGTCLKN(sys_clk_n)

      );

  defparam sys_clk_mgt.SYNCLK1OUTEN = "ENABLE";
  defparam sys_clk_mgt.SYNCLK2OUTEN = "DISABLE";

`endif // VIRTEX4FX

  //-------------------------------------------------------
  // System Reset Input Pad Instance
  //-------------------------------------------------------

  IBUF sys_reset_n_ibuf (.O(sys_reset_n_c), .I(sys_reset_n));

  //-------------------------------------------------------
  // PCI Express Core Instance
  //-------------------------------------------------------

  `PCI_EXP_EP    `PCI_EXP_EP_INST  (

      //
      // PCI Express Fabric Interface
      //

      .pci_exp_txp( pci_exp_txp ),             // O [7/3/0:0]
      .pci_exp_txn( pci_exp_txn ),             // O [7/3/0:0]
      .pci_exp_rxp( pci_exp_rxp ),             // O [7/3/0:0]
      .pci_exp_rxn( pci_exp_rxn ),             // O [7/3/0:0]

      //
      // Transaction ( TRN ) Interface
      //

      .trn_clk( trn_clk_c ),                   // O
      .trn_reset_n( trn_reset_n_c ),           // O
      .trn_lnk_up_n( trn_lnk_up_n_c ),         // O

      // Tx Local-Link

      .trn_td( trn_td_c ),                     // I [63:0]
`ifdef PCI_EXP_64B_EP
      .trn_trem_n( trn_trem_n_c ),             // I [7:0]
`endif // PCI_EXP_64B_EP
      .trn_tsof_n( trn_tsof_n_c ),             // I
      .trn_teof_n( trn_teof_n_c ),             // I
      .trn_tsrc_rdy_n( trn_tsrc_rdy_n_c ),     // I
      .trn_tsrc_dsc_n( trn_tsrc_dsc_n_c ),     // I
      .trn_tdst_rdy_n( trn_tdst_rdy_n_c ),     // O
      .trn_tdst_dsc_n( trn_tdst_dsc_n_c ),     // O
      .trn_terrfwd_n( trn_terrfwd_n_c ),       // I
      .trn_tbuf_av( trn_tbuf_av_c ),           // O [4:0]

      // Rx Local-Link

      .trn_rd( trn_rd_c ),                     // O [63:0]
`ifdef PCI_EXP_64B_EP
      .trn_rrem_n( trn_rrem_n_c ),             // O [7:0]
`endif // PCI_EXP_64B_EP
      .trn_rsof_n( trn_rsof_n_c ),             // O
      .trn_reof_n( trn_reof_n_c ),             // O
      .trn_rsrc_rdy_n( trn_rsrc_rdy_n_c ),     // O
      .trn_rsrc_dsc_n( trn_rsrc_dsc_n_c ),     // O
      .trn_rdst_rdy_n( trn_rdst_rdy_n_c ),     // I
      .trn_rerrfwd_n( trn_rerrfwd_n_c ),       // O
      .trn_rnp_ok_n( trn_rnp_ok_n_c ),         // I
      .trn_rbar_hit_n( trn_rbar_hit_n_c ),     // O [6:0]
      .trn_rfc_nph_av( trn_rfc_nph_av_c ),     // O [11:0]
      .trn_rfc_npd_av( trn_rfc_npd_av_c ),     // O [7:0]
      .trn_rfc_ph_av( trn_rfc_ph_av_c ),       // O [11:0]
      .trn_rfc_pd_av( trn_rfc_pd_av_c ),       // O [7:0]
      .trn_rfc_cplh_av( trn_rfc_cplh_av_c ),   // O [11:0]
      .trn_rfc_cpld_av( trn_rfc_cpld_av_c ),   // O [7:0]

      //
      // Host ( CFG ) Interface
      //

      .cfg_do( cfg_do_c ),                                    // O [31:0]
      .cfg_rd_wr_done_n( cfg_rd_wr_done_n_c ),                // O
      .cfg_di( cfg_di_c ),                                    // I [31:0]
      .cfg_byte_en_n( cfg_byte_en_n_c ),                      // I [3:0]
      .cfg_dwaddr( cfg_dwaddr_c ),                            // I [9:0]
      .cfg_wr_en_n( cfg_wr_en_n_c ),                          // I
      .cfg_rd_en_n( cfg_rd_en_n_c ),                          // I

      .cfg_err_cor_n( cfg_err_cor_n_c ),                      // I
      .cfg_err_ur_n( cfg_err_ur_n_c ),                        // I
      .cfg_err_ecrc_n( cfg_err_ecrc_n_c ),                    // I
      .cfg_err_cpl_timeout_n( cfg_err_cpl_timeout_n_c ),      // I
      .cfg_err_cpl_abort_n( cfg_err_cpl_abort_n_c ),          // I
      .cfg_err_cpl_unexpect_n( cfg_err_cpl_unexpect_n_c ),    // I
      .cfg_err_posted_n( cfg_err_posted_n_c ),                // I
      .cfg_err_tlp_cpl_header( cfg_err_tlp_cpl_header_c ),    // I [47:0]
      .cfg_interrupt_n( cfg_interrupt_n_c ),                  // I
      .cfg_interrupt_rdy_n( cfg_interrupt_rdy_n_c ),          // O
      .cfg_pm_wake_n( cfg_pm_wake_n_c ),                      // I
      .cfg_pcie_link_state_n( cfg_pcie_link_state_n_c ),      // O [2:0]
      .cfg_turnoff_ok_n( cfg_turnoff_ok_n_c ),                // I
      .cfg_to_turnoff_n( cfg_to_turnoff_n_c ),                // O
      .cfg_trn_pending_n( cfg_trn_pending_n_c ),              // I

      .cfg_bus_number( cfg_bus_number_c ),                    // O [7:0]
      .cfg_device_number( cfg_device_number_c ),              // O [4:0]
      .cfg_function_number( cfg_function_number_c ),          // O [2:0]
      .cfg_status( cfg_status_c ),                            // O [15:0]
      .cfg_command( cfg_command_c ),                          // O [15:0]
      .cfg_dstatus( cfg_dstatus_c ),                          // O [15:0]
      .cfg_dcommand( cfg_dcommand_c ),                        // O [15:0]
      .cfg_lstatus( cfg_lstatus_c ),                          // O [15:0]
      .cfg_lcommand( cfg_lcommand_c ),                        // O [15:0]

      .cfg_cfg( cfg_cfg ),                                    // I [1023:0]
        
      //
      // System ( SYS ) Interface
      //

      .sys_clk( sys_clk_c ),                                  // I
      .sys_reset_n( sys_reset_n_c )                           // I

      );

  //-------------------------------------------------------
  // PCI Express Core Configuration Module
  //-------------------------------------------------------

  `PCI_EXP_CFG    `PCI_EXP_CFG_INST    ( 

      .cfg( cfg_cfg )                                        // O [1023:0]

      );         

`ifdef IMPL_TEST

  //-------------------------------------------------------
  // Endpoint Application
  //-------------------------------------------------------

  `PCI_EXP_APP app (    

      //
      // Transaction ( TRN ) Interface
      //

      .trn_clk( trn_clk_c ),                   // I
      .trn_reset_n( trn_reset_n_c ),           // I
      .trn_lnk_up_n( trn_lnk_up_n_c ),         // I

      // Tx Local-Link

      .trn_td( trn_td_c ),                     // O [63:0]
`ifdef PCI_EXP_64B_EP
      .trn_trem( trn_trem_n_c ),               // O [7:0]
`endif // PCI_EXP_64B_EP
      .trn_tsof_n( trn_tsof_n_c ),             // O
      .trn_teof_n( trn_teof_n_c ),             // O
      .trn_tsrc_rdy_n( trn_tsrc_rdy_n_c ),     // O
      .trn_tsrc_dsc_n( trn_tsrc_dsc_n_c ),     // O
      .trn_tdst_rdy_n( trn_tdst_rdy_n_c ),     // I
      .trn_tdst_dsc_n( trn_tdst_dsc_n_c ),     // I
      .trn_terrfwd_n( trn_terrfwd_n_c ),       // O
      .trn_tbuf_av( trn_tbuf_av_c ),           // I [4:0]

      // Rx Local-Link

      .trn_rd( trn_rd_c ),                     // I [63:0]
`ifdef PCI_EXP_64B_EP
      .trn_rrem( trn_rrem_n_c ),               // I [7:0]
`endif // PCI_EXP_64B_EP
      .trn_rsof_n( trn_rsof_n_c ),             // I
      .trn_reof_n( trn_reof_n_c ),             // I
      .trn_rsrc_rdy_n( trn_rsrc_rdy_n_c ),     // I
      .trn_rsrc_dsc_n( trn_rsrc_dsc_n_c ),     // I
      .trn_rdst_rdy_n( trn_rdst_rdy_n_c ),     // O
      .trn_rerrfwd_n( trn_rerrfwd_n_c ),       // I
      .trn_rnp_ok_n( trn_rnp_ok_n_c ),         // O
      .trn_rbar_hit_n( trn_rbar_hit_n_c ),     // I [6:0]
      .trn_rfc_npd_av( trn_rfc_npd_av_c ),     // I [11:0]
      .trn_rfc_nph_av( trn_rfc_nph_av_c ),     // I [7:0]
      .trn_rfc_pd_av( trn_rfc_pd_av_c ),       // I [11:0]
      .trn_rfc_ph_av( trn_rfc_ph_av_c ),       // I [7:0]
      .trn_rfc_cpld_av( trn_rfc_cpld_av_c ),   // I [11:0]
      .trn_rfc_cplh_av( trn_rfc_cplh_av_c ),   // I [7:0]

      //
      // Host ( CFG ) Interface
      //

      .cfg_do( cfg_do_c ),                                   // I [31:0]
      .cfg_rd_wr_done_n( cfg_rd_wr_done_n_c ),               // I
      .cfg_di( cfg_di_c ),                                   // O [31:0]
      .cfg_byte_en_n( cfg_byte_en_n_c ),                     // O
      .cfg_dwaddr( cfg_dwaddr_c ),                           // O
      .cfg_wr_en_n( cfg_wr_en_n_c ),                         // O
      .cfg_rd_en_n( cfg_rd_en_n_c ),                         // O
      .cfg_err_cor_n( cfg_err_cor_n_c ),                     // O
      .cfg_err_ur_n( cfg_err_ur_n_c ),                       // O
      .cfg_err_ecrc_n( cfg_err_ecrc_n_c ),                   // O
      .cfg_err_cpl_timeout_n( cfg_err_cpl_timeout_n_c ),     // O
      .cfg_err_cpl_abort_n( cfg_err_cpl_abort_n_c ),         // O
      .cfg_err_cpl_unexpect_n( cfg_err_cpl_unexpect_n_c ),   // O
      .cfg_err_posted_n( cfg_err_posted_n_c ),               // O
      .cfg_err_tlp_cpl_header( cfg_err_tlp_cpl_header_c ),   // O [47:0]
      .cfg_interrupt_n( cfg_interrupt_n_c ),                 // O
      .cfg_interrupt_rdy_n( cfg_interrupt_rdy_n_c ),         // I
      .cfg_turnoff_ok_n( cfg_turnoff_ok_n_c ),               // O
      .cfg_to_turnoff_n( cfg_to_turnoff_n_c ),               // I
      .cfg_pm_wake_n( cfg_pm_wake_n_c ),                     // O
      .cfg_pcie_link_state_n( cfg_pcie_link_state_n_c ),     // I [2:0]
      .cfg_trn_pending_n( cfg_trn_pending_n_c ),             // O

      .cfg_bus_number( cfg_bus_number_c ),                   // I [7:0]
      .cfg_device_number( cfg_device_number_c ),             // I [4:0]
      .cfg_function_number( cfg_function_number_c ),         // I [2:0]
      .cfg_status( cfg_status_c ),                           // I [15:0]
      .cfg_command( cfg_command_c ),                         // I [15:0]
      .cfg_dstatus( cfg_dstatus_c ),                         // I [15:0]
      .cfg_dcommand( cfg_dcommand_c ),                       // I [15:0]
      .cfg_lstatus( cfg_lstatus_c ),                         // I [15:0]
      .cfg_lcommand( cfg_lcommand_c )                        // I [15:0]

      );

  //-------------------------------------------------------
  // Misc. board level stuff
  //-------------------------------------------------------

  reg     toggle_rsof, toggle_reof, toggle_tsof, toggle_teof;
  wire    prsnt2x4_c;
  wire    prsnt2x1_c;
  wire    prsnt1_c;

  
  always @(posedge trn_clk_c or negedge trn_reset_n_c) begin

    if (!trn_reset_n_c) begin

      toggle_rsof <= 0;
      toggle_reof <= 0;
      toggle_tsof <= 0;
      toggle_teof <= 0;

    end else if (!trn_tsof_n_c && !trn_tsrc_rdy_n_c && !trn_tdst_rdy_n_c ) begin

      toggle_tsof <= !toggle_tsof;
  
    end else if (!trn_teof_n_c && !trn_tsrc_rdy_n_c && !trn_tdst_rdy_n_c ) begin
  
      toggle_teof <= !toggle_teof;

    end else if (!trn_rsof_n_c && !trn_rsrc_rdy_n_c && !trn_rdst_rdy_n_c ) begin
  
      toggle_rsof <= !toggle_rsof;

    end else if (!trn_reof_n_c && !trn_rsrc_rdy_n_c && !trn_rdst_rdy_n_c ) begin

      toggle_reof <= !toggle_reof;

    end
     
  end

  OBUF led_0_obuf ( .O(led_0), .I(sys_reset_n_c) );
  OBUF led_1_obuf ( .O(led_1), .I(trn_reset_n_c) );
  OBUF led_2_obuf ( .O(led_2), .I(trn_lnk_up_n_c) );
  OBUF led_3_obuf ( .O(led_3), .I(toggle_tsof) );
  OBUF led_4_obuf ( .O(led_4), .I(toggle_teof) );
  OBUF led_5_obuf ( .O(led_5), .I(toggle_rsof) );
  OBUF led_6_obuf ( .O(led_6), .I(toggle_reof) );
  OBUF led_7_obuf ( .O(led_7), .I(cfg_lstatus_c[4]) );  // x1
  OBUF led_8_obuf ( .O(led_8), .I(cfg_lstatus_c[6]) );  // x4
  OBUF led_9_obuf ( .O(led_9), .I(cfg_lstatus_c[7]) );  // x8

  assign prsnt2x1_c = prsnt1_c;
  assign prsnt2x4_c = prsnt1_c;

  IBUF prsnt1_ibuf ( .O(prsnt1_c), .I(prsnt1) );
  OBUF prsnt2x1_obuf ( .O(prsnt2x1), .I(prsnt2x1_c) );
  OBUF prsnt2x4_obuf ( .O(prsnt2x4), .I(prsnt2x4_c) );

  OBUF iS_CLK (.O(S_CLK), .I(1'b0));
  OBUF iS_LOAD (.O(S_LOAD), .I(1'b0));
  OBUF iS_DATA (.O(S_DATA), .I(1'b0));
  OBUF iMR_84321 (.O(MR_84321), .I(1'b0));
  OBUF iMR_87354 (.O(MR_87354), .I(1'b0));

`else // SIMULATION

  generate

    for (i = 0; i < (`PCI_EXP_CFG_CAP_WIDTH); i = i + 1) begin : l_cfg_regs

      OBUF icfg_lcommand (.O(cfg_lcommand[i]), .I(cfg_lcommand_c[i]));
      OBUF icfg_lstatus  (.O(cfg_lstatus[i]), .I(cfg_lstatus_c[i]));
      OBUF icfg_dcommand (.O(cfg_dcommand[i]), .I(cfg_dcommand_c[i]));
      OBUF icfg_dstatus  (.O(cfg_dstatus[i]), .I(cfg_dstatus_c[i]));
      OBUF icfg_command  (.O(cfg_command[i]), .I(cfg_command_c[i]));
      OBUF icfg_status   (.O(cfg_status[i]), .I(cfg_status_c[i]));

    end

  endgenerate

  OBUF icfg_function_number_obuf_2  (.O(cfg_function_number[2]), .I(cfg_function_number_c[2]));
  OBUF icfg_function_number_obuf_1  (.O(cfg_function_number[1]), .I(cfg_function_number_c[1]));
  OBUF icfg_function_number_obuf_0  (.O(cfg_function_number[0]), .I(cfg_function_number_c[0]));
  OBUF icfg_device_number_obuf_4  (.O(cfg_device_number[4]), .I(cfg_device_number_c[4]));
  OBUF icfg_device_number_obuf_3  (.O(cfg_device_number[3]), .I(cfg_device_number_c[3]));
  OBUF icfg_device_number_obuf_2  (.O(cfg_device_number[2]), .I(cfg_device_number_c[2]));
  OBUF icfg_device_number_obuf_1  (.O(cfg_device_number[1]), .I(cfg_device_number_c[1]));
  OBUF icfg_device_number_obuf_0  (.O(cfg_device_number[0]), .I(cfg_device_number_c[0]));

  OBUF icfg_bus_number_obuf_7  (.O(cfg_bus_number[7]), .I(cfg_bus_number_c[7]));
  OBUF icfg_bus_number_obuf_6  (.O(cfg_bus_number[6]), .I(cfg_bus_number_c[6]));
  OBUF icfg_bus_number_obuf_5  (.O(cfg_bus_number[5]), .I(cfg_bus_number_c[5]));
  OBUF icfg_bus_number_obuf_4  (.O(cfg_bus_number[4]), .I(cfg_bus_number_c[4]));
  OBUF icfg_bus_number_obuf_3  (.O(cfg_bus_number[3]), .I(cfg_bus_number_c[3]));
  OBUF icfg_bus_number_obuf_2  (.O(cfg_bus_number[2]), .I(cfg_bus_number_c[2]));
  OBUF icfg_bus_number_obuf_1  (.O(cfg_bus_number[1]), .I(cfg_bus_number_c[1]));
  OBUF icfg_bus_number_obuf_0  (.O(cfg_bus_number[0]), .I(cfg_bus_number_c[0]));

    
  IBUF icfg_turnoff_ok_n_ibuf (.O(cfg_turnoff_ok_n_c), .I(cfg_turnoff_ok_n));
  OBUF icfg_to_turnoff_n_obuf (.O(cfg_to_turnoff_n), .I(cfg_to_turnoff_n_c));

  IBUF icfg_pm_wake_n (.O(cfg_pm_wake_n_c), .I(cfg_pm_wake_n));

  OBUF icfg_pcie_link_state_n_2 (.O(cfg_pcie_link_state_n[2]), .I(cfg_pcie_link_state_n_c[2]));
  OBUF icfg_pcie_link_state_n_1 (.O(cfg_pcie_link_state_n[1]), .I(cfg_pcie_link_state_n_c[1]));
  OBUF icfg_pcie_link_state_n_0 (.O(cfg_pcie_link_state_n[0]), .I(cfg_pcie_link_state_n_c[0]));

  IBUF icfg_interrupt_n_ibuf (.O(cfg_interrupt_n_c), .I(cfg_interrupt_n));
  OBUF icfg_interrupt_rdy_n_obuf (.O(cfg_interrupt_rdy_n), .I(cfg_interrupt_rdy_n_c));

  generate

    for (i = 0; i < (`PCI_EXP_CFG_CPLHDR_WIDTH); i = i + 1) begin : l_cfg_err_tlp_cpl
      IBUF icfg_err_tlp_cpl_header  (.O(cfg_err_tlp_cpl_header_c[i]), .I(cfg_err_tlp_cpl_header[i]));
    end

  endgenerate

  IBUF icfg_err_posted_n_ibuf (.O(cfg_err_posted_n_c), .I(cfg_err_posted_n));
  IBUF icfg_err_cpl_unexpect_n_ibuf (.O(cfg_err_cpl_unexpect_n_c), .I(cfg_err_cpl_unexpect_n));
  IBUF icfg_err_cpl_abort_n_ibuf (.O(cfg_err_cpl_abort_n_c), .I(cfg_err_cpl_abort_n));
  IBUF icfg_err_cpl_timeout_n_ibuf (.O(cfg_err_cpl_timeout_n_c), .I(cfg_err_cpl_timeout_n));

  IBUF icfg_err_cor_n_ibuf (.O(cfg_err_cor_n_c), .I(cfg_err_cor_n));
  IBUF icfg_err_ur_n_ibuf (.O(cfg_err_ur_n_c), .I(cfg_err_ur_n));
  IBUF icfg_err_ecrc_n_ibuf (.O(cfg_err_ecrc_n_c), .I(cfg_err_ecrc_n));
  IBUF icfg_wr_en_n_ibuf (.O(cfg_wr_en_n_c), .I(cfg_wr_en_n));

  IBUF icfg_rd_en_n_ibuf (.O(cfg_rd_en_n_c), .I(cfg_rd_en_n));
    
  generate

    for (i = 0; i < (`PCI_EXP_CFG_ADDR_WIDTH); i = i + 1) begin : l_cfg_dwaddress

      IBUF icfg_dwaddr  (.O(cfg_dwaddr_c[i]), .I(cfg_dwaddr[i]));

    end

  endgenerate
    
  IBUF icfg_byte_en_ibuf_3  (.O(cfg_byte_en_n_c[3]), .I(cfg_byte_en_n[3]));
  IBUF icfg_byte_en_ibuf_2  (.O(cfg_byte_en_n_c[2]), .I(cfg_byte_en_n[2]));
  IBUF icfg_byte_en_ibuf_1  (.O(cfg_byte_en_n_c[1]), .I(cfg_byte_en_n[1]));
  IBUF icfg_byte_en_ibuf_0  (.O(cfg_byte_en_n_c[0]), .I(cfg_byte_en_n[0]));

  generate

    for (i = 0; i < (`PCI_EXP_CFG_DATA_WIDTH); i = i + 1) begin : l_cfg_data

      IBUF icfg_di  (.O(cfg_di_c[i]), .I(cfg_di[i]));
      OBUF icfg_do  (.O(cfg_do[i]), .I(cfg_do_c[i]));

    end

  endgenerate

  OBUF icfg_rd_wr_done_n_obuf (.O(cfg_rd_wr_done_n), .I(cfg_rd_wr_done_n_c));

  OBUF itrn_rerrfwd_n_obuf (.O(trn_rerrfwd_n), .I(trn_rerrfwd_n_c));
  IBUF itrn_rdst_rdy_n_ibuf (.O(trn_rdst_rdy_n_c), .I(trn_rdst_rdy_n));
  OBUF itrn_rsrc_dsc_n_obuf (.O(trn_rsrc_dsc_n), .I(trn_rsrc_dsc_n_c));
  OBUF itrn_rsrc_rdy_n_obuf (.O(trn_rsrc_rdy_n), .I(trn_rsrc_rdy_n_c));
  OBUF itrn_reof_n_obuf (.O(trn_reof_n), .I(trn_reof_n_c));
  OBUF itrn_rsof_n_obuf (.O(trn_rsof_n), .I(trn_rsof_n_c));

  IBUF itrn_rnp_ok_n_ibuf (.O(trn_rnp_ok_n_c), .I(trn_rnp_ok_n));

  generate

    for (i = 0; i < (`PCI_EXP_TRN_BAR_HIT_WIDTH); i = i + 1) begin : l_trn_rbar_hit

      OBUF itrn_rbar_hit_n (.O(trn_rbar_hit_n[i]), .I(trn_rbar_hit_n_c[i]));

    end

    for (i = 0; i < (`PCI_EXP_TRN_FC_HDR_WIDTH); i = i + 1) begin : l_trn_rfc_hdr

      OBUF itrn_rfc_nph_av (.O(trn_rfc_nph_av[i]), .I(trn_rfc_nph_av_c[i]));
      OBUF itrn_rfc_ph_av (.O(trn_rfc_ph_av[i]), .I(trn_rfc_ph_av_c[i]));
      OBUF itrn_rfc_cplh_av (.O(trn_rfc_cplh_av[i]), .I(trn_rfc_cplh_av_c[i]));

    end

    for (i = 0; i < (`PCI_EXP_TRN_FC_DATA_WIDTH); i = i + 1) begin : l_trn_rfc_data

      OBUF itrn_rfc_cpld_av (.O(trn_rfc_cpld_av[i]), .I(trn_rfc_cpld_av_c[i]));
      OBUF itrn_rfc_pd_av (.O(trn_rfc_pd_av[i]), .I(trn_rfc_pd_av_c[i]));
      OBUF itrn_fcr_npd_av (.O(trn_rfc_npd_av[i]), .I(trn_rfc_npd_av_c[i]));

    end

    for (i = 0; i < (`PCI_EXP_TRN_DATA_WIDTH); i = i + 1) begin : l_trn_rdata

      OBUF itrn_rd (.O(trn_rd[i]), .I(trn_rd_c[i])); 

    end


`ifdef PCI_EXP_64B_EP
    for (i = 0; i < (`PCI_EXP_TRN_REM_WIDTH); i = i + 1) begin : l_trn_rrem_n

      OBUF itrn_rrem_n (.O(trn_rrem_n[i]), .I(trn_rrem_n_c[i])); 

    end
`endif // PCI_EXP_64B_EP


  endgenerate

  IBUF itrn_teof_n_ibuf (.O(trn_teof_n_c), .I(trn_teof_n));
  IBUF itrn_tsof_n_ibuf (.O(trn_tsof_n_c), .I(trn_tsof_n));
  OBUF itrn_tdst_rdy_n_obuf (.O(trn_tdst_rdy_n), .I(trn_tdst_rdy_n_c));
  IBUF itrn_tsrc_rdy_n_ibuf (.O(trn_tsrc_rdy_n_c), .I(trn_tsrc_rdy_n));
  IBUF itrn_terrfwd_n_ibuf (.O(trn_terrfwd_n_c), .I(trn_terrfwd_n));
  IBUF itrn_tsrc_dsc_n_ibuf (.O(trn_tsrc_dsc_n_c), .I(trn_tsrc_dsc_n));
  OBUF itrn_tdst_dsc_n_obuf (.O(trn_tdst_dsc_n), .I(trn_tdst_dsc_n_c));

  generate

    for (i = 0; i < (`PCI_EXP_TRN_BUF_AV_WIDTH); i = i + 1) begin : l_trn_tbuf_avail

      OBUF itrn_tbuf_av (.O(trn_tbuf_av[i]), .I(trn_tbuf_av_c[i]));

    end

    for (i = 0; i < (`PCI_EXP_TRN_DATA_WIDTH); i = i + 1) begin : l_trn_tdata

      IBUF itrn_td  (.O(trn_td_c[i]), .I(trn_td[i]));

    end


`ifdef PCI_EXP_64B_EP
    for (i = 0; i < (`PCI_EXP_TRN_REM_WIDTH); i = i + 1) begin : l_trn_trem_n

      IBUF itrn_trem_n  (.O(trn_trem_n_c[i]), .I(trn_trem_n[i]));

    end
`endif // PCI_EXP_64B_EP


  endgenerate

  IBUF icfg_trn_pending_n_ibuf (.O(cfg_trn_pending_n_c), .I(cfg_trn_pending_n));
  OBUF itrn_lnk_up_n_obuf (.O(trn_lnk_up_n), .I(trn_lnk_up_n_c));
  OBUF itrn_reset_n_obuf (.O(trn_reset_n), .I(trn_reset_n_c));
  OBUF itrn_clk_obuf (.O(trn_clk), .I(trn_clk_c));

`endif // IMPL_TEST


endmodule // XILINX_PCI_EXP_EP
