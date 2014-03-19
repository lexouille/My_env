------------------------------------------------------------------------------------
--                             KALRAY-SA
--     Reproduction and Communication of this document is strictly prohibited 
--       unless specifically authorized in writing by KALRAY-SA.
-- 
------------------------------------------------------------------------------------
--  Ver     Modified By      Date      Changes
--  ---     -----------      ----      -------
--  1.0     R. Ayrignac     02/08/11    Initial version
------------------------------------------------------------------------------------
-- Comments :
--
------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library lib_common_package_vhdl;
use lib_common_package_vhdl.mppa_constant.all;

library lib_common_package_vhdl;
use lib_common_package_vhdl.mppa_io_package.all;

library lib_common_package_vhdl;
use lib_common_package_vhdl.mppa_io_socip_package.all;

library lib_common_unit_vhdl;
use lib_common_unit_vhdl.all;

library lib_mppa_debug_vhdl;
use lib_mppa_debug_vhdl.all;

library lib_mppa_testchip_tca_vhdl;
use lib_mppa_testchip_tca_vhdl.all;

entity mppa_tca_shell is
  port (
    TCA_RXP     : in    std_logic_vector(1 downto 0);
    TCA_RXN     : in    std_logic_vector(1 downto 0);
    TCA_DMONP   : out   std_logic;
    TCA_DMONN   : out   std_logic;
    --
    TCA_TXP     : out   std_logic_vector(1 downto 0);
    TCA_TXN     : out   std_logic_vector(1 downto 0);
    --
    TCA_RCKIP   : in    std_logic;
    TCA_RCKIN   : in    std_logic;
    TCA_HFCKP   : in    std_logic;
    TCA_HFCKN   : in    std_logic;
    TCA_RCKOUTP : out   std_logic;
    TCA_RCKOUTN : out   std_logic;
    --
    TCA_IREF    : inout std_logic;
    TCA_VREF    : inout std_logic;
    TCA_RCAL    : inout std_logic;
    TCA_AT_P    : out   std_logic;
    TCA_AT_N    : out   std_logic;
    --
    TCA_TCAP    : inout std_logic_vector(1 downto 0);
    TCA_TCAN    : inout std_logic_vector(1 downto 0);
    -- 
    THINN       : in    std_logic;
    THINP       : in    std_logic;
    THREFN      : in    std_logic;
    THREFP      : in    std_logic;
    THREXT      : inout std_logic;
    THCLK       : in    std_logic;
    TCA_TCA2    : inout std_logic;
    TCA_TCA3    : inout std_logic;
    TCA_TCA4    : inout std_logic;
    -- JTAG
    TCA_TRSTN   : in    std_logic;
    TCA_TMS     : in    std_logic;
    TCA_TCK     : in    std_logic;
    TCA_TDI     : in    std_logic;
    TCA_TDO     : out   std_logic;
    -- Test ports
    test_in     : in    std_logic_vector(TEST_PAT-1 downto 0);
    test_out    : out   std_logic_vector(TEST_PAT-1 downto 0);
    test_mode   : in    std_logic;
    test_gclken : in    std_logic
    );
end entity;

architecture rtl of mppa_tca_shell is

  -----------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------
  component mppa_resynchro
    generic (
      stage_nb       :     natural;
      reset_value    :     std_logic;
      reset_polarity :     std_logic;
      async_reset    :     boolean);
    port (
      clk            : in  std_logic;
      rst            : in  std_logic;
      din            : in  std_logic;
      dout           : out std_logic
      );
  end component;

  component CLK_GATING_NORST
    port (
      clk     : in  std_logic;
      test_en : in  std_logic;
      en      : in  std_logic;
      clk_out : out std_logic
      );
  end component;
  
  component GLITCH_FREE_MUX
    port (
      A0 : in  STD_LOGIC;
      A1 : in  STD_LOGIC;
      S  : in  STD_LOGIC;
      Z  : out STD_LOGIC
      );
  end component;
  
  component mppa_debug_tap_ctrl
    generic (
      nb_tap_gen         :     natural;
      ctrl_reg_sz_k      :     natural;
      status_reg_sz_k    :     natural
      );
    port (
      test_mode          : in  std_logic;
      idcode_k           : in  std_logic_vector(31 downto 0);
      trstn_i            : in  std_logic;
      tck_i              : in  std_logic;
      tms_i              : in  std_logic;
      tdi_i              : in  std_logic;
      tdo_o              : out std_logic;
      bs_capture_o       : out std_logic;
      bs_shift_o         : out std_logic;
      bs_update_o        : out std_logic;
      bs_extest_o        : out std_logic;
      bs_shin_i          : in  std_logic;
      message_shin_i     : in  std_logic_vector(nb_tap_gen - 1 downto 0);
      tap_exit2upd_o     : out std_logic;
      tap_shift_o        : out std_logic;
      tap_capt_o         : out std_logic;
      status_reg_i       : in  std_logic_vector(status_reg_sz_k - 1 downto 0);
      ctrl_reg_o         : out std_logic_vector(ctrl_reg_sz_k - 1 downto 0);
      ctrl_reg_req_o     : out std_logic;
      ctrl_reg_pending_i : in  std_logic;
      ctrl_reg_rst_val_i : in  std_logic_vector(ctrl_reg_sz_k - 1 downto 0)
      );
  end component;

  component mppa_debug_tap2gen
    generic (
      subreg_data_sz_k      :     natural;
      subreg_nb_k           :     natural
      );
    port (
      tap2gen_idx_k         : in  std_logic_vector(3 downto 0);
      trstn_i               : in  std_logic;
      tck_i                 : in  std_logic;
      tdi_i                 : in  std_logic;
      tap_exit2upd_i        : in  std_logic;
      tap_shift_i           : in  std_logic;
      tap_capt_i            : in  std_logic;
      status_i              : in  std_logic_vector((subreg_data_sz_k*subreg_nb_k) - 1 downto 0);
      serial_status_o       : out std_logic;
      control_reg_rst_val_i : in  std_logic_vector((subreg_data_sz_k*subreg_nb_k) - 1 downto 0);
      control_reg_o         : out std_logic_vector((subreg_data_sz_k*subreg_nb_k) - 1 downto 0)
      );
  end component;

  component mppa_tca_prbs
    port (
      rx_clk            : in  std_logic;
      rx_enable         : in  std_logic;
      rx_data_i         : in  std_logic_vector(39 downto 0);
      rx_check_i        : in  std_logic_vector(39 downto 0);
      rx_err_cnt_o      : out std_logic_vector(63 downto 0);
      rx_cnt_o          : out std_logic_vector(63 downto 0);
      tx_clk            : in  std_logic;
      tx_clk_sync       : out std_logic;
      tx_enable         : in  std_logic;
      tx_data_o         : out std_logic_vector(39 downto 0);
      tx_bypass         : in  std_logic;
      tx_bypass_neg     : in  std_logic;
      tx_data_i         : in  std_logic_vector(39 downto 0);
      tx_data_i_n         : in  std_logic_vector(39 downto 0);
      tck               : in  std_logic;
      trstn             : in  std_logic;
      tap_exit2upd_i    : in  std_logic;
      prbs_config_sta_o : out std_logic_vector(63 downto 0);
      prbs_config_ctl_i : in  std_logic_vector(63 downto 0)
      );
  end component;

  component tca_serdes_top
    port (
      -- Bumps
      va0p                  : out   std_logic;  -- TCA_TXP(0)
      va0n                  : out   std_logic;  -- TCA_TXN(0)
      va1p                  : out   std_logic;  -- TCA_TXP(1)
      va1n                  : out   std_logic;  -- TCA_TXN(1)
      vi0p                  : in    std_logic;  -- TCA_RXP(0)
      vi0n                  : in    std_logic;  -- TCA_RXN(0)
      vi1p                  : in    std_logic;  -- TCA_RXP(1)
      vi1n                  : in    std_logic;  -- TCA_RXN(1)
      ifs                   : inout std_logic;  -- TCA_IREF
      rf                    : inout std_logic;  -- TCA_RCAL
      vf                    : inout std_logic;  -- TCA_VREF
      hrinn                 : in    std_logic;  -- TCA_HFCKN
      hrinp                 : in    std_logic;  -- TCA_HFCKP
      rinn                  : in    std_logic;  -- TCA_RCKIN
      rinp                  : in    std_logic;  -- TCA_RCKIP
      routn                 : out   std_logic;  -- TCA_RCKOUTN
      routp                 : out   std_logic;  -- TCA_RCKOUTP
      tcap0                 : out   std_logic;
      tcan0                 : out   std_logic;
      tcap1                 : inout std_logic;
      tcan1                 : inout std_logic;
      dtp                   : out   std_logic;  -- TCA_DMONP
      dtn                   : out   std_logic;  -- TCA_DMONN
      atp                   : out   std_logic;  -- TCA_RXOUT(0)
      atn                   : out   std_logic;  -- TCA_RXOUT(1)
      thinn                 : in    std_logic;
      thinp                 : in    std_logic;
      threfn                : in    std_logic;
      threfp                : in    std_logic;
      thrext                : inout std_logic;
      thclk                 : in    std_logic;
      tca2                  : inout std_logic;  -- TCA bump noConn
      tca3                  : inout std_logic;  -- TCA bump noConn
      tca4                  : inout std_logic;  -- TCA bump noConn   
      -- PRBS
      rx_dataout            : out   std_logic_vector(39 downto 0);
      rx_clkout             : out   std_logic;
      TxClkSync             : in    std_logic;
      TxClkWordx2           : out   std_logic;
      TxDataParallel        : in    std_logic_vector(39 downto 0);
      -- Configuration
      -- Thermal Sensor control through JTAG (26 pins)
      th_data               : out   std_logic_vector(9 downto 0);
      th_dataready          : out   std_logic;
      th_enad               : in    std_logic;
      th_envref             : in    std_logic;
      th_enbgr              : in    std_logic;
      th_stn                : in    std_logic;
      th_tmod               : in    std_logic;
      th_itcl               : in    std_logic_vector(1 downto 0);
      th_spare              : in    std_logic_vector(7 downto 0);
      -- TX control through JTAG (50 pins)
      TxClkPolarity         : in    std_logic;
      TxCtrlMain            : in    std_logic_vector(3 downto 0);
      TxCtrlPre             : in    std_logic_vector(3 downto 0);
      TxCtrlTest            : in    std_logic_vector(3 downto 0);
      TxDataSelect          : in    std_logic;
      TxDciPup              : in    std_logic;
      TxPisoDivInit         : in    std_logic_vector(3 downto 0);
      TxPisoReset           : in    std_logic;
      TxPisoSelDiv          : in    std_logic;
      TxPreEmph             : in    std_logic;
      TxPup                 : in    std_logic;
      TxRtrim               : in    std_logic_vector(4 downto 0);
      TxRxLpbkSelect        : in    std_logic;
      TxTestLpbk            : in    std_logic;
      TxTestPcsEn           : in    std_logic;
      TxPisoSelTxSync       : in    std_logic;
      tx_spare              : in    std_logic_vector(15 downto 0);
      -- Common control through JTAG (24 pins)
      cmn_bias_on           : in    std_logic;
      cmn_dci_dc            : in    std_logic_vector(1 downto 0);
      cmn_dci_prog          : in    std_logic_vector(4 downto 0);
      cmn_spare             : in    std_logic_vector(15 downto 0);
      -- SX control through JTAG (85 pins)
      sx_DivN               : in    std_logic_vector(8 downto 3);
      sx_DpllAlpha          : in    std_logic_vector(2 downto 0);
      sx_DpllBeta           : in    std_logic_vector(2 downto 0);
      sx_DpllOpenLoop       : in    std_logic_vector(8 downto 0);
      sx_DpllReset          : in    std_logic;
      sx_Dpll_Fcw           : in    std_logic_vector(5 downto 0);
      sx_Dpll_FiltMux       : in    std_logic;
      sx_Dpll_VarDem        : in    std_logic;
      sx_FrefDciGnd         : in    std_logic;
      sx_FrefDciProg50      : in    std_logic_vector(4 downto 0);
      sx_FrefDciVdd         : in    std_logic;
      sx_FrefPup            : in    std_logic;
      sx_LoExtDciGnd        : in    std_logic;
      sx_LoExtDciProg50     : in    std_logic_vector(4 downto 0);
      sx_LoExtDciVdd        : in    std_logic;
      sx_LoExtPup           : in    std_logic;
      sx_LoSrcMux           : in    std_logic;
      sx_PupLoRx            : in    std_logic;
      sx_PupLoTx            : in    std_logic;
      sx_PupRefOut          : in    std_logic;
      sx_RxDiv              : in    std_logic_vector(2 downto 0);
      sx_TxDiv              : in    std_logic_vector(2 downto 0);
      sx_filter_size        : in    std_logic_vector(8 downto 0);
      sx_pll_typ            : in    std_logic;
      sx_spare              : in    std_logic_vector(15 downto 0);
      sx_vco_cc             : in    std_logic_vector(1 downto 0);
      sx_PupDco_Out         : in    std_logic;
      -- RX control through JTAG (131 pins)
      rx_bias_off           : in    std_logic_vector(2 downto 0);
      rx_cdr_en             : in    std_logic;
      rx_cdr_filt_openloop  : in    std_logic_vector(12 downto 0);
      rx_cdr_filta          : in    std_logic_vector(2 downto 0);
      rx_cdr_filtb          : in    std_logic_vector(2 downto 0);
      rx_cdr_filtc          : in    std_logic_vector(2 downto 0);
      rx_cdr_sel_data       : in    std_logic_vector(2 downto 0);
      rx_cdr_sel_clk        : in    std_logic_vector(2 downto 0);
      rx_cdr_rst            : in    std_logic;
      rx_cdr_sel_openloop   : in    std_logic;
      rx_cdr_var_dem        : in    std_logic;
      rx_clk_dela           : in    std_logic_vector(7 downto 0);
      rx_clk_delb           : in    std_logic_vector(7 downto 0);
      rx_clk_en             : in    std_logic;
      rx_clk_sel            : in    std_logic;
      rx_cmp_aux_en         : in    std_logic;
      rx_cmp_off            : in    std_logic;
      rx_cmp_thhigh         : in    std_logic_vector(4 downto 0);
      rx_cmp_thlow          : in    std_logic_vector(4 downto 0);
      rx_dfe_coef1          : in    std_logic_vector(4 downto 0);
      rx_dfe_coef2          : in    std_logic_vector(4 downto 0);
      rx_dfe_en             : in    std_logic;
      rx_ff_gain1           : in    std_logic_vector(1 downto 0);
      rx_ff_gain2           : in    std_logic_vector(1 downto 0);
      rx_ff_off             : in    std_logic_vector(2 downto 0);
      rx_ff_setresc         : in    std_logic_vector(2 downto 0);
      rx_ff_setresr         : in    std_logic_vector(2 downto 0);
      rx_in_dccouple        : in    std_logic;
      rx_in_load50          : in    std_logic_vector(4 downto 0);
      rx_in_load100k        : in    std_logic_vector(1 downto 0);
      rx_in_ref50           : in    std_logic_vector(1 downto 0);
      rx_loopback2_rx2tx_en : in    std_logic;
      rx_loopback2_tx2rx_en : in    std_logic;
      rx_sel_data           : in    std_logic;
      rx_sel_test           : in    std_logic_vector(4 downto 0);
      rx_sipo_aux_sel       : in    std_logic_vector(1 downto 0);
      rx_sipo_en            : in    std_logic;
      rx_sipo_invdata       : in    std_logic;
      rx_sipo_n             : in    std_logic_vector(3 downto 0);
      rx_sipo_rst           : in    std_logic;
      rx_sipo_seldiv        : in    std_logic;
      rx_cdr_filtout        : out   std_logic_vector(8 downto 0);  -- rx_cdr_filtout <= new register
      rx_spare              : in    std_logic_vector(15 downto 0);  -- rx_spare<0> <= rx_cdr_filtout_en
      rx_vref_bypass        : in    std_logic
      );
  end component;

  component mppa_gpio_pad
    port (
      PAD      : inout std_logic;       --      PAD 
      --
      Y        : out   std_logic;       --      Receiver output through JTAG 
      YH       : out   std_logic;       --      Schmitt Receiver output 
      YR       : out   std_logic;       --      Registered Output 
      A        : in    std_logic;       --      Data input from core 
      OE       : in    std_logic;
      --
      CFG      : in    gpio_cfg;
      --
      UPDATEDR : in    std_logic;       --      JTAG update signal 
      JTAG_SI  : in    std_logic;       --      JTAG scan input 
      SHIFTDR  : in    std_logic;       --      JTAG scan input select 
      JTAG_SO  : out   std_logic;       --      JTAG scan output 
      MODE_I   : in    std_logic;       --      JTAG MODE control for receiver, 1 => JTAG mode; 0 => bypass JTAG 
      MODE     : in    std_logic;       --      JTAG MODE control, 1 => JTAG mode; 0 => bypass JTAG 
      NANDO    : out   std_logic;       --      NAND output 
      CLOCKDR  : in    std_logic        --      JTAG scan  clock 
      );
  end component;

--   component mppa_isolation_cell
--     port (
--       ISEN : in  std_logic;
--       A    : in  std_logic;
--       Z    : out std_logic
--       );
--   end component;

  -----------------------------------------------------------------------------
  -- Controlled
  -----------------------------------------------------------------------------
  -- Added on Sept 08
  signal cmn_spare              : std_logic_vector(15 downto 0);
  signal sx_PupDco_Out          : std_logic;
  signal TxPisoSelTxSync        : std_logic;
  signal rx_sipo_seldiv         : std_logic;
  signal rx_cdr_sel_data        : std_logic_vector(2 downto 0);
  signal rx_cdr_sel_clk         : std_logic_vector(2 downto 0);
  signal th_enad                : std_logic;
  signal th_envref              : std_logic;
  signal th_enbgr               : std_logic;
  signal th_stn                 : std_logic;
  signal th_tmod                : std_logic;
  signal th_itcl                : std_logic_vector(1 downto 0);
  signal th_spare               : std_logic_vector(7 downto 0);
  -- TX control through JTAG (49 pins)
  signal TxClkPolarity          : std_logic;
  signal TxCtrlMain             : std_logic_vector(3 downto 0);
  signal TxCtrlPre              : std_logic_vector(3 downto 0);
  signal TxCtrlTest             : std_logic_vector(3 downto 0);
  signal TxDataSelect           : std_logic;
  signal TxDciPup               : std_logic;
  signal TxPisoDivInit          : std_logic_vector(3 downto 0);
  signal TxPisoReset            : std_logic;
  signal TxPisoSelDiv           : std_logic;
  signal TxPreEmph              : std_logic;
  signal TxPup                  : std_logic;
  signal TxRtrim                : std_logic_vector(4 downto 0);
  signal TxRxLpbkSelect         : std_logic;
  signal TxTestLpbk             : std_logic;
  signal TxTestPcsEn            : std_logic;
  signal tx_spare               : std_logic_vector(15 downto 0);
  signal TxClkSync_inv          : std_logic;
  -- Common control through JTAG (8 pins)
  signal cmn_bias_on            : std_logic;
  signal cmn_dci_dc             : std_logic_vector(1 downto 0);
  signal cmn_dci_prog           : std_logic_vector(4 downto 0);
  -- SX control through JTAG (84 pins)
  signal sx_DivN                : std_logic_vector(8 downto 3);
  signal sx_DpllAlpha           : std_logic_vector(2 downto 0);
  signal sx_DpllBeta            : std_logic_vector(2 downto 0);
  signal sx_DpllOpenLoop        : std_logic_vector(8 downto 0);
  signal sx_DpllReset           : std_logic;
  signal sx_Dpll_Fcw            : std_logic_vector(5 downto 0);
  signal sx_Dpll_FiltMux        : std_logic;
  signal sx_Dpll_VarDem         : std_logic;
  signal sx_FrefDciGnd          : std_logic;
  signal sx_FrefDciProg50       : std_logic_vector(4 downto 0);
  signal sx_FrefDciVdd          : std_logic;
  signal sx_FrefPup             : std_logic;
  signal sx_LoExtDciGnd         : std_logic;
  signal sx_LoExtDciProg50      : std_logic_vector(4 downto 0);
  signal sx_LoExtDciVdd         : std_logic;
  signal sx_LoExtPup            : std_logic;
  signal sx_LoSrcMux            : std_logic;
  signal sx_PupLoRx             : std_logic;
  signal sx_PupLoTx             : std_logic;
  signal sx_PupRefOut           : std_logic;
  signal sx_RxDiv               : std_logic_vector(2 downto 0);
  signal sx_TxDiv               : std_logic_vector(2 downto 0);
  signal sx_filter_size         : std_logic_vector(8 downto 0);
  signal sx_pll_typ             : std_logic;
  signal sx_spare               : std_logic_vector(15 downto 0);
  signal sx_vco_cc              : std_logic_vector(1 downto 0);
  -- RX control through JTAG (131 pins)
  signal rx_bias_off            : std_logic_vector(2 downto 0);
  signal rx_cdr_en              : std_logic;
  signal rx_cdr_filt_openloop   : std_logic_vector(12 downto 0);
  signal rx_cdr_filta           : std_logic_vector(2 downto 0);
  signal rx_cdr_filtb           : std_logic_vector(2 downto 0);
  signal rx_cdr_filtc           : std_logic_vector(2 downto 0);
  signal rx_cdr_rst             : std_logic;
  signal rx_cdr_sel_openloop    : std_logic;
  signal rx_cdr_var_dem         : std_logic;
  signal rx_clk_dela            : std_logic_vector(7 downto 0);
  signal rx_clk_delb            : std_logic_vector(7 downto 0);
  signal rx_clk_en              : std_logic;
  signal rx_clk_sel             : std_logic;
  signal rx_cmp_aux_en          : std_logic;
  signal rx_cmp_off             : std_logic;
  signal rx_cmp_thhigh          : std_logic_vector(4 downto 0);
  signal rx_cmp_thlow           : std_logic_vector(4 downto 0);
  signal rx_dfe_coef1           : std_logic_vector(4 downto 0);
  signal rx_dfe_coef2           : std_logic_vector(4 downto 0);
  signal rx_dfe_en              : std_logic;
  signal rx_ff_gain1            : std_logic_vector(1 downto 0);
  signal rx_ff_gain2            : std_logic_vector(1 downto 0);
  signal rx_ff_off              : std_logic_vector(2 downto 0);
  signal rx_ff_setresc          : std_logic_vector(2 downto 0);
  signal rx_ff_setresr          : std_logic_vector(2 downto 0);
  signal rx_in_dccouple         : std_logic;
  signal rx_in_load50           : std_logic_vector(4 downto 0);
  signal rx_in_load100k         : std_logic_vector(1 downto 0);
  signal rx_in_ref50            : std_logic_vector(1 downto 0);
--  signal rx_loopback1_en        : std_logic;
  signal rx_loopback2_rx2tx_en  : std_logic;
  signal rx_loopback2_tx2rx_en  : std_logic;
-- signal rxout0 : std_logic;
-- signal rxout1 : std_logic;
  signal rx_sel_data            : std_logic;
  signal rx_sel_test            : std_logic_vector(4 downto 0);
  signal rx_sipo_aux_sel        : std_logic_vector(1 downto 0);
  signal rx_sipo_en             : std_logic;
  signal rx_sipo_invdata        : std_logic;
  signal rx_sipo_n              : std_logic_vector(3 downto 0);
  signal rx_sipo_rst            : std_logic;
  signal rx_spare               : std_logic_vector(15 downto 0);
  signal rx_vref_bypass         : std_logic;
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal TxDataParallel_tstin   : std_logic_vector(39 downto 0);
  signal TxDataParallel_tstin_n : std_logic_vector(39 downto 0);
  signal TxDataParallel         : std_logic_vector(39 downto 0);
  signal rx_dataout             : std_logic_vector(39 downto 0);
  signal TxClkSync_prbs_n       : std_logic;
  signal TxClkSync_prbs         : std_logic;
  signal TxClkSync              : std_logic;
  signal TxClkWord              : std_logic;
  signal rx_clkout              : std_logic;
  signal rx_clkout_clk          : std_logic;
  signal th_data                : std_logic_vector(9 downto 0);
  signal th_dataready           : std_logic;
  -- JTAG
  signal message_shift_o        : std_logic;
  signal message_shift_i        : std_logic_vector(0 downto 0);
  signal tap_exit2upd           : std_logic;
  signal tap_shift              : std_logic;
  signal tap_capt               : std_logic;
  signal lback                  : std_logic_vector(1 downto 0);
  -- Control interface
  signal status_i               : std_logic_vector((7*64)-1 downto 0);
  signal control_reg_o          : std_logic_vector((7*64)-1 downto 0);
  signal control_rst_val        : std_logic_vector((7*64)-1 downto 0);

  -- Internal JTAG signals
  signal tck_s   : std_logic;
  signal tdi_s   : std_logic;
  signal tdo_s   : std_logic;
  signal tms_s   : std_logic;
  signal trstn_s : std_logic;

  signal tck_pad_s   : std_logic;
  signal tdi_pad_s   : std_logic;
  signal tdo_pad_s   : std_logic;
  signal tms_pad_s   : std_logic;
  signal trstn_pad_s : std_logic;


  signal isolation, isolation_n, local_test : std_logic;
  signal test_mode_s                        : std_logic;
  signal test_in_s                          : std_logic_vector(TEST_PAT-1 downto 0);
  signal sample_data_neg, sample_data_in_en : std_logic;
  signal test_in_bypass                     : std_logic;

begin

  local_test <= '1' when test_mode_s = '1' and test_in_s(63) = '0' and test_in_s(62 downto 59) = x"F" else '0';

  test_out <= EXT(th_dataready & th_data, TEST_PAT)         when local_test = '1' and test_in_s(58) = '1' else  -- Thermal sensor
              EXT(status_i((2*64)+8 downto 2*64), TEST_PAT) when local_test = '1' and test_in_s(57) = '1' else  -- CDR               
              EXT(rx_clkout & rx_dataout, TEST_PAT)         when local_test = '1' and test_in_s(56) = '1' else  -- rx_dataout             
              (others => '0');          -- Default

  -----------------------------------------------------------------------------
  -- Isolation managed directely by the synthesis tool
  -----------------------------------------------------------------------------
--   -- Isolation of the design
--   isolation <= not(isolation_n);

--   inst_iso_testmode : mppa_isolation_cell
--     port map (
--       ISEN => isolation,
--       A    => test_mode,
--       Z    => test_mode_s
--       );

--   gen_iso : for i in 0 to TEST_PAT-1 generate

--     inst_iso : mppa_isolation_cell
--       port map (
--         ISEN => isolation,
--         A    => test_in(i),
--         Z    => test_in_s(i)
--         );

--   end generate gen_iso;

  -- isolation control is done by pin inst_jtag_cfg/control_reg_o(0)
  test_mode_s <= test_mode;
  test_in_s   <= test_in;
  -----------------------------------------------------------------------------

  
  -----------------------------------------------------------------------------
  -- Test in
  -----------------------------------------------------------------------------
  test_in_bypass <= '1' when local_test = '1' and sample_data_in_en = '1' else
                    '0';

  -- Data update synchro
  i_mppa_resynchro_test_in : mppa_resynchro
    generic map (
      stage_nb       => 2,
      reset_value    => '0',
      reset_polarity => '1',
      async_reset    => false
      )
    port map (
      clk            => TxClkWord,
      rst            => '0',
      din            => test_in_s(40),
      dout           => sample_data_neg
      );

  -- Mode enable
  i_mppa_resynchro_test_in_en : mppa_resynchro
    generic map (
      stage_nb       => 2,
      reset_value    => '0',
      reset_polarity => '1',
      async_reset    => false
      )
    port map (
      clk            => TxClkWord,
      rst            => '0',
      din            => test_in_s(48),
      dout           => sample_data_in_en
      );

  test_in_proc_p : process (TxClkWord)
  begin
    if (TxClkWord'event and TxClkWord = '1') then
      if sample_data_in_en = '1' and sample_data_neg = '0' then
        TxDataParallel_tstin <= test_in_s(39 downto 0);
      end if;
    end if;
  end process;
  
  test_in_proc_n : process (TxClkWord)
  begin
    if (TxClkWord'event and TxClkWord = '0') then
      if sample_data_in_en = '1' and sample_data_neg = '1' then
        TxDataParallel_tstin_n <= test_in_s(39 downto 0);
      end if;
    end if;
  end process;
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Test out
  -----------------------------------------------------------------------------
  i_CLK_GATING_NORST_rx_clkout : CLK_GATING_NORST
    port map (
      clk     => rx_clkout,
      test_en => '1',
      en      => '1',
      clk_out => rx_clkout_clk
      );
  -----------------------------------------------------------------------------

  tck_pad_s   <= TCA_TCK;
  tdi_pad_s   <= TCA_TDI;
  TCA_TDO     <= tdo_pad_s;
  tms_pad_s   <= TCA_TMS;
  trstn_pad_s <= TCA_TRSTN;

  i_mppa_tck_pad : mppa_gpio_pad
    port map(
      Y        => tck_s,
      YH       => open,
      JTAG_SI  => '0',
      SHIFTDR  => '0',
      YR       => open,
      JTAG_SO  => open,
      MODE_I   => '0',
      MODE     => '0',
      A        => '0',
      OE       => '0',
      UPDATEDR => '0',
      CLOCKDR  => '0',
      PAD      => tck_pad_s,
      NANDO    => open,
      CFG      => gpio_cfg_cst
      );

  i_mppa_tdi_pad : mppa_gpio_pad
    port map(
      Y        => tdi_s,
      YH       => open,
      JTAG_SI  => '0',
      SHIFTDR  => '0',
      YR       => open,
      JTAG_SO  => open,
      MODE_I   => '0',
      MODE     => '0',
      A        => '0',
      OE       => '0',
      UPDATEDR => '0',
      CLOCKDR  => '0',
      PAD      => tdi_pad_s,
      NANDO    => open,
      CFG      => gpio_cfg_cst
      );

  i_mppa_tms_pad : mppa_gpio_pad
    port map(
      Y        => tms_s,
      YH       => open,
      JTAG_SI  => '0',
      SHIFTDR  => '0',
      YR       => open,
      JTAG_SO  => open,
      MODE_I   => '0',
      MODE     => '0',
      A        => '0',
      OE       => '0',
      UPDATEDR => '0',
      CLOCKDR  => '0',
      PAD      => tms_pad_s,
      NANDO    => open,
      CFG      => gpio_cfg_cst
      );

  i_mppa_trstn_pad : mppa_gpio_pad
    port map(
      Y        => trstn_s,
      YH       => open,
      JTAG_SI  => '0',
      SHIFTDR  => '0',
      YR       => open,
      JTAG_SO  => open,
      MODE_I   => '0',
      MODE     => '0',
      A        => '0',
      OE       => '0',
      UPDATEDR => '0',
      CLOCKDR  => '0',
      PAD      => trstn_pad_s,
      NANDO    => open,
      CFG      => gpio_cfg_cst
      );

  i_mppa_tdo_pad : mppa_gpio_pad
    port map(
      Y        => open,
      YH       => open,
      JTAG_SI  => '0',
      SHIFTDR  => '0',
      YR       => open,
      JTAG_SO  => open,
      MODE_I   => '0',
      MODE     => '0',
      A        => tdo_s,
      OE       => '1',
      UPDATEDR => '0',
      CLOCKDR  => '0',
      PAD      => tdo_pad_s,
      NANDO    => open,
      CFG      => gpio_cfg_cst
      );

  -----------------------------------------------------------------------------
  -- JTAGs
  -----------------------------------------------------------------------------
  message_shift_i(0) <= message_shift_o;

  inst_jtag_ctrl : mppa_debug_tap_ctrl
    generic map (
      nb_tap_gen         => 1,
      ctrl_reg_sz_k      => 2,
      status_reg_sz_k    => 2
      )
    port map (
      test_mode          => '0',
      idcode_k           => "01011010000101011010010101010101",  -- 5A1A5555
      trstn_i            => trstn_s,
      tck_i              => tck_s,
      tms_i              => tms_s,
      tdi_i              => tdi_s,
      tdo_o              => tdo_s,
      bs_capture_o       => open,
      bs_shift_o         => open,
      bs_update_o        => open,
      bs_extest_o        => open,
      bs_shin_i          => '0',
      message_shin_i     => message_shift_i,
      tap_exit2upd_o     => tap_exit2upd,
      tap_shift_o        => tap_shift,
      tap_capt_o         => tap_capt,
      status_reg_i       => lback,
      ctrl_reg_o         => lback,
      ctrl_reg_req_o     => open,
      ctrl_reg_pending_i => '0',
      ctrl_reg_rst_val_i => (others => '0')
      );

  inst_jtag_cfg : mppa_debug_tap2gen
    generic map (
      subreg_data_sz_k      => 64,
      subreg_nb_k           => 7
      )
    port map (
      tap2gen_idx_k         => "0001",
      trstn_i               => trstn_s,
      tck_i                 => tck_s,
      tdi_i                 => tdi_s,
      tap_exit2upd_i        => tap_exit2upd,
      tap_shift_i           => tap_shift,
      tap_capt_i            => tap_capt,
      status_i              => status_i,
      serial_status_o       => message_shift_o,
      control_reg_rst_val_i => control_rst_val,
      control_reg_o         => control_reg_o
      );

  -----------------------------------------------------------------------------
  -- Init value
  -----------------------------------------------------------------------------
  init_value_p : process
  begin
    control_rst_val                 <= (others => '0');  -- Default value
    ---------------------------------------------------------------------------
    control_rst_val(0)              <= '1';  -- !!!!!!! Isolation by default !!!!!!!
    ---------------------------------------------------------------------------
    control_rst_val(218 downto 214) <= "10000";  -- rx_in_load50          
    control_rst_val(222 downto 221) <= "10";  -- rx_in_ref50           
    control_rst_val(213)            <= '1';  -- rx_in_dccouple        
    control_rst_val(220 downto 219) <= "11";  -- rx_in_load100k        
    control_rst_val(201 downto 200) <= "10";  -- rx_ff_gain1           
    control_rst_val(203 downto 202) <= "01";  -- rx_ff_gain2           
    control_rst_val(209 downto 207) <= "011";  -- rx_ff_setresc         
    control_rst_val(212 downto 210) <= "011";  -- rx_ff_setresr         
    control_rst_val(174)            <= '1';  -- rx_clk_en             
    control_rst_val(241 downto 238) <= "1000";  -- rx_sipo_n             
    control_rst_val(244)            <= '1';  -- rx_sipo_seldiv        
    control_rst_val(144 downto 132) <= "0010111011100";  -- rx_cdr_filt_openloop  
    control_rst_val(147 downto 145) <= "010";  -- rx_cdr_filta          
    control_rst_val(151 downto 149) <= "011";  -- rx_cdr_filtb          
    control_rst_val(154 downto 152) <= "010";  -- rx_cdr_filtc          
    control_rst_val(112)            <= '1';  -- sx_PupLoTx            
    control_rst_val(110)            <= '1';  -- sx_LoSrcMux           
    control_rst_val(111)            <= '1';  -- sx_PupLoRx            
    control_rst_val(75 downto 73)   <= "010";  -- sx_DpllBeta           
    control_rst_val(126 downto 118) <= "111111111";  -- sx_filter_size        
    control_rst_val(91 downto 86)   <= "011001";  -- sx_Dpll_Fcw           
    control_rst_val(69 downto 64)   <= "000111";  -- sx_DivN               
    control_rst_val(107 downto 103) <= "10000";  -- sx_LoExtDciProg50     
    control_rst_val(108)            <= '1';  -- sx_LoExtDciVdd        
    control_rst_val(99 downto 95)   <= "10000";  -- sx_FrefDciProg50      
    control_rst_val(101)            <= '1';  -- sx_FrefPup            
    control_rst_val(100)            <= '1';  -- sx_FrefDciVdd         
    control_rst_val(127)            <= '1';  -- sx_pll_typ            
-- mike modif: control_rst_val(20 downto 17) 1111 => 1000  "erreur dans le fichier xls"
    control_rst_val(20 downto 17)   <= "1000";  -- TxPisoDivInit         
    control_rst_val(24)             <= '1';  -- TxPup                 
    control_rst_val(6 downto 3)     <= "1000";  -- TxCtrlMain            
    control_rst_val(10 downto 7)    <= "0001";  -- TxCtrlPre             
    control_rst_val(16)             <= '1';  -- TxDciPup              
    control_rst_val(29 downto 25)   <= "01111";  -- TxRtrim               
    control_rst_val(33)             <= '1';  -- cmn_bias_on           
    control_rst_val(35 downto 34)   <= "10";  -- cmn_dci_dc            
    control_rst_val(40 downto 36)   <= "10000";  -- cmn_dci_prog          
-- mike modif: ontrol_rst_val(42 downto 41) 00 => 01
    control_rst_val(42 downto 41)   <= "01";  -- sx_vco_cc
    control_rst_val(305)            <= '1';  -- th_envref             
    control_rst_val(306)            <= '1';  -- th_enbgr              
    control_rst_val(318 downto 311) <= "00001010";  -- th_spare
    -- cadence translate_off
    -- synopsys translate_off
    -- pragma translate_off
    wait;
    -- cadence translate_on
    -- synopsys translate_on
    -- pragma translate_on

  end process;

  -----------------------------------------------------------------------------
  -- Control with JTAG
  -----------------------------------------------------------------------------
  -- 1st reg
  isolation_n           <= control_reg_o(0);
  TxClkPolarity         <= control_reg_o(1);
  TxPisoSelTxSync       <= control_reg_o(2);
  TxCtrlMain            <= control_reg_o(6 downto 3);
  TxCtrlPre             <= control_reg_o(10 downto 7);
  TxCtrlTest            <= control_reg_o(14 downto 11);
  TxDataSelect          <= control_reg_o(15);
  TxDciPup              <= control_reg_o(16);
  TxPisoDivInit         <= control_reg_o(20 downto 17);
  TxPisoReset           <= control_reg_o(21);
  TxPisoSelDiv          <= control_reg_o(22);
  TxPreEmph             <= control_reg_o(23);
  TxPup                 <= control_reg_o(24);
  TxRtrim               <= control_reg_o(29 downto 25);
  TxRxLpbkSelect        <= control_reg_o(30);
  TxTestLpbk            <= control_reg_o(31);
  TxTestPcsEn           <= control_reg_o(32);
  cmn_bias_on           <= control_reg_o(33);
  cmn_dci_dc            <= control_reg_o(35 downto 34);
  cmn_dci_prog          <= control_reg_o(40 downto 36);
  sx_vco_cc             <= control_reg_o(42 downto 41);
  sx_PupDco_Out         <= control_reg_o(43);
  TxClkSync_inv         <= control_reg_o(44);
  cmn_spare             <= control_reg_o(63 downto 48);
  -- 2nd reg
  sx_DivN               <= control_reg_o(69 downto 64);
  sx_DpllAlpha          <= control_reg_o(72 downto 70);
  sx_DpllBeta           <= control_reg_o(75 downto 73);
  sx_DpllOpenLoop       <= control_reg_o(84 downto 76);
  sx_DpllReset          <= control_reg_o(85);
  sx_Dpll_Fcw           <= control_reg_o(91 downto 86);
  sx_Dpll_FiltMux       <= control_reg_o(92);
  sx_Dpll_VarDem        <= control_reg_o(93);
  sx_FrefDciGnd         <= control_reg_o(94);
  sx_FrefDciProg50      <= control_reg_o(99 downto 95);
  sx_FrefDciVdd         <= control_reg_o(100);
  sx_FrefPup            <= control_reg_o(101);
  sx_LoExtDciGnd        <= control_reg_o(102);
  sx_LoExtDciProg50     <= control_reg_o(107 downto 103);
  sx_LoExtDciVdd        <= control_reg_o(108);
  sx_LoExtPup           <= control_reg_o(109);
  sx_LoSrcMux           <= control_reg_o(110);
  sx_PupLoRx            <= control_reg_o(111);
  sx_PupLoTx            <= control_reg_o(112);
  sx_PupRefOut          <= control_reg_o(113);
  sx_RxDiv              <= control_reg_o(116 downto 114);
--  sx_TxDiv              <= control_reg_o(119 downto 117); " chevauchement de 2 registres "
  sx_TxDiv              <= control_reg_o(274 downto 272);
  sx_filter_size        <= control_reg_o(126 downto 118);
  sx_pll_typ            <= control_reg_o(127);
  -- 3rd and 4th regs
  rx_bias_off           <= control_reg_o(130 downto 128);
  rx_cdr_en             <= control_reg_o(131);
  rx_cdr_filt_openloop  <= control_reg_o(144 downto 132);
  rx_cdr_filta          <= control_reg_o(147 downto 145);
  -- 148 missing
  rx_cdr_filtb          <= control_reg_o(151 downto 149);
  rx_cdr_filtc          <= control_reg_o(154 downto 152);
  rx_cdr_rst            <= control_reg_o(155);
  rx_cdr_sel_openloop   <= control_reg_o(156);
  rx_cdr_var_dem        <= control_reg_o(157);
  rx_clk_dela           <= control_reg_o(165 downto 158);
  rx_clk_delb           <= control_reg_o(173 downto 166);
  rx_clk_en             <= control_reg_o(174);
  rx_clk_sel            <= control_reg_o(175);
  -- 176 missing
  rx_cmp_aux_en         <= control_reg_o(177);
  rx_cmp_off            <= control_reg_o(178);
  rx_cmp_thhigh         <= control_reg_o(183 downto 179);
  rx_cmp_thlow          <= control_reg_o(188 downto 184);
  rx_dfe_coef1          <= control_reg_o(193 downto 189);
  rx_dfe_coef2          <= control_reg_o(198 downto 194);
  rx_dfe_en             <= control_reg_o(199);
  rx_ff_gain1           <= control_reg_o(201 downto 200);
  rx_ff_gain2           <= control_reg_o(203 downto 202);
  rx_ff_off             <= control_reg_o(206 downto 204);
  rx_ff_setresc         <= control_reg_o(209 downto 207);
  rx_ff_setresr         <= control_reg_o(212 downto 210);
  rx_in_dccouple        <= control_reg_o(213);
  rx_in_load50          <= control_reg_o(218 downto 214);
  rx_in_load100k        <= control_reg_o(220 downto 219);
  rx_in_ref50           <= control_reg_o(222 downto 221);
--  rx_loopback1_en       <= control_reg_o(223);
  rx_loopback2_rx2tx_en <= control_reg_o(224);
  rx_loopback2_tx2rx_en <= control_reg_o(225);
-- rxout0 <= control_reg_o(226);
-- rxout1 <= control_reg_o(227);
  rx_sel_data           <= control_reg_o(228);
  rx_sel_test           <= control_reg_o(233 downto 229);
  rx_sipo_aux_sel       <= control_reg_o(235 downto 234);
  rx_sipo_en            <= control_reg_o(236);
  rx_sipo_invdata       <= control_reg_o(237);
  rx_sipo_n             <= control_reg_o(241 downto 238);
  rx_sipo_rst           <= control_reg_o(242);
  rx_vref_bypass        <= control_reg_o(243);
  rx_sipo_seldiv        <= control_reg_o(244);
  rx_cdr_sel_data       <= control_reg_o(247 downto 245);
  rx_cdr_sel_clk        <= control_reg_o(250 downto 248);
  -- 5th reg => spare bits and thermal sensor
  tx_spare              <= control_reg_o(271 downto 256);
  sx_spare              <= control_reg_o(287 downto 272);
  rx_spare              <= control_reg_o(303 downto 288);
  th_enad               <= control_reg_o(304);
  th_envref             <= control_reg_o(305);
  th_enbgr              <= control_reg_o(306);
  th_stn                <= control_reg_o(307);
  th_tmod               <= control_reg_o(308);
  th_itcl               <= control_reg_o(310 downto 309);
  th_spare              <= control_reg_o(318 downto 311);
  -- 6th and 7th regs => PRBS control

  status_i((2*64)+19 downto (2*64)+9) <= th_dataready & th_data;
  status_i((6*64)-1 downto (2*64)+20) <= (others => '0');

  -----------------------------------------------------------------------------
  -- Control with JTAG
  -----------------------------------------------------------------------------
  inst_prbs : mppa_tca_prbs
    port map (
      rx_clk            => rx_clkout_clk,
      rx_enable         => '1',
      rx_data_i         => rx_dataout,
      rx_check_i        => control_reg_o((6*64)+39 downto 6*64),
      rx_err_cnt_o      => status_i((1*64)-1 downto 0*64),
      rx_cnt_o          => status_i((2*64)-1 downto 1*64),
      tx_clk            => TxClkWord,
      tx_enable         => TxClkSync_prbs,
      tx_clk_sync       => TxClkSync_prbs,
      tx_data_o         => TxDataParallel,
      tx_bypass         => test_in_bypass,
      tx_bypass_neg     => sample_data_neg,
      tx_data_i         => TxDataParallel_tstin,
      tx_data_i_n       => TxDataParallel_tstin_n,
      tck               => tck_s,
      trstn             => trstn_s,
      tap_exit2upd_i    => tap_exit2upd,
      prbs_config_sta_o => status_i((7*64)-1 downto 6*64),
      prbs_config_ctl_i => control_reg_o((6*64)-1 downto 5*64)
      );

  TxClkSync_prbs_n <= not(TxClkSync_prbs);
  
  i_GLITCH_FREE_MUX : GLITCH_FREE_MUX
    port map (
        A0 => TxClkSync_prbs,
        A1 => TxClkSync_prbs_n,
        S  => TxClkSync_inv,
        Z  => TxClkSync
        );
  
  inst_tca_serdes_top : tca_serdes_top
    port map (
      -- New Thermal sensor bumps
      thinn                 => THINN,
      thinp                 => THINP,
      threfn                => THREFN,
      threfp                => THREFP,
      thrext                => THREXT,
      thclk                 => THCLK,
      -- New bumps
      tca2                  => TCA_TCA2,
      tca3                  => TCA_TCA3,
      tca4                  => TCA_TCA4,
      -- Bumps
      va0p                  => TCA_TXP(0),
      va0n                  => TCA_TXN(0),
      va1p                  => TCA_TXP(1),
      va1n                  => TCA_TXN(1),
      ifs                   => TCA_IREF,
      rf                    => TCA_RCAL,
      vf                    => TCA_VREF,
      hrinn                 => TCA_HFCKN,
      hrinp                 => TCA_HFCKP,
      rinn                  => TCA_RCKIN,
      rinp                  => TCA_RCKIP,
      routn                 => TCA_RCKOUTN,
      routp                 => TCA_RCKOUTP,
      tcap0                 => TCA_TCAP(0),
      tcan0                 => TCA_TCAN(0),
      tcap1                 => TCA_TCAP(1),
      tcan1                 => TCA_TCAN(1),
      vi0p                  => TCA_RXP(0),
      vi0n                  => TCA_RXN(0),
      vi1p                  => TCA_RXP(1),
      vi1n                  => TCA_RXN(1),
      dtp                   => TCA_DMONP,
      dtn                   => TCA_DMONN,
      atp                   => TCA_AT_P,
      atn                   => TCA_AT_N,
      -- PRBS
      rx_dataout            => rx_dataout,
      rx_clkout             => rx_clkout,
      TxClkWordx2           => TxClkWord,
      TxDataParallel        => TxDataParallel,
      TxClkSync             => TxClkSync,
      -- Thermal sensor
      th_data               => th_data,
      th_dataready          => th_dataready,
      -- Control
      cmn_spare             => cmn_spare,
      sx_PupDco_Out         => sx_PupDco_Out,
      TxPisoSelTxSync       => TxPisoSelTxSync,
      rx_sipo_seldiv        => rx_sipo_seldiv,
      rx_cdr_sel_data       => rx_cdr_sel_data,
      rx_cdr_sel_clk        => rx_cdr_sel_clk,
      th_enad               => th_enad,
      th_envref             => th_envref,
      th_enbgr              => th_enbgr,
      th_stn                => th_stn,
      th_tmod               => th_tmod,
      th_itcl               => th_itcl,
      th_spare              => th_spare,
      TxClkPolarity         => TxClkPolarity,
      TxCtrlMain            => TxCtrlMain,
      TxCtrlPre             => TxCtrlPre,
      TxCtrlTest            => TxCtrlTest,
      TxDataSelect          => TxDataSelect,
      TxDciPup              => TxDciPup,
      TxPisoDivInit         => TxPisoDivInit,
      TxPisoReset           => TxPisoReset,
      TxPisoSelDiv          => TxPisoSelDiv,
      TxPreEmph             => TxPreEmph,
      TxPup                 => TxPup,
      TxRtrim               => TxRtrim,
      TxRxLpbkSelect        => TxRxLpbkSelect,
      TxTestLpbk            => TxTestLpbk,
      TxTestPcsEn           => TxTestPcsEn,
      tx_spare              => tx_spare,
      cmn_bias_on           => cmn_bias_on,
      cmn_dci_dc            => cmn_dci_dc,
      cmn_dci_prog          => cmn_dci_prog,
      sx_DivN               => sx_DivN,
      sx_DpllAlpha          => sx_DpllAlpha,
      sx_DpllBeta           => sx_DpllBeta,
      sx_DpllOpenLoop       => sx_DpllOpenLoop,
      sx_DpllReset          => sx_DpllReset,
      sx_Dpll_Fcw           => sx_Dpll_Fcw,
      sx_Dpll_FiltMux       => sx_Dpll_FiltMux,
      sx_Dpll_VarDem        => sx_Dpll_VarDem,
      sx_FrefDciGnd         => sx_FrefDciGnd,
      sx_FrefDciProg50      => sx_FrefDciProg50,
      sx_FrefDciVdd         => sx_FrefDciVdd,
      sx_FrefPup            => sx_FrefPup,
      sx_LoExtDciGnd        => sx_LoExtDciGnd,
      sx_LoExtDciProg50     => sx_LoExtDciProg50,
      sx_LoExtDciVdd        => sx_LoExtDciVdd,
      sx_LoExtPup           => sx_LoExtPup,
      sx_LoSrcMux           => sx_LoSrcMux,
      sx_PupLoRx            => sx_PupLoRx,
      sx_PupLoTx            => sx_PupLoTx,
      sx_PupRefOut          => sx_PupRefOut,
      sx_RxDiv              => sx_RxDiv,
      sx_TxDiv              => sx_TxDiv,
      sx_filter_size        => sx_filter_size,
      sx_pll_typ            => sx_pll_typ,
      sx_spare              => sx_spare,
      sx_vco_cc             => sx_vco_cc,
      rx_bias_off           => rx_bias_off,
      rx_cdr_en             => rx_cdr_en,
      rx_cdr_filt_openloop  => rx_cdr_filt_openloop,
      rx_cdr_filta          => rx_cdr_filta,
      rx_cdr_filtb          => rx_cdr_filtb,
      rx_cdr_filtc          => rx_cdr_filtc,
      rx_cdr_rst            => rx_cdr_rst,
      rx_cdr_sel_openloop   => rx_cdr_sel_openloop,
      rx_cdr_var_dem        => rx_cdr_var_dem,
      rx_clk_dela           => rx_clk_dela,
      rx_clk_delb           => rx_clk_delb,
      rx_clk_en             => rx_clk_en,
      rx_clk_sel            => rx_clk_sel,
      rx_cmp_aux_en         => rx_cmp_aux_en,
      rx_cmp_off            => rx_cmp_off,
      rx_cmp_thhigh         => rx_cmp_thhigh,
      rx_cmp_thlow          => rx_cmp_thlow,
      rx_dfe_coef1          => rx_dfe_coef1,
      rx_dfe_coef2          => rx_dfe_coef2,
      rx_dfe_en             => rx_dfe_en,
      rx_ff_gain1           => rx_ff_gain1,
      rx_ff_gain2           => rx_ff_gain2,
      rx_ff_off             => rx_ff_off,
      rx_ff_setresc         => rx_ff_setresc,
      rx_ff_setresr         => rx_ff_setresr,
      rx_in_dccouple        => rx_in_dccouple,
      rx_in_load50          => rx_in_load50,
      rx_in_load100k        => rx_in_load100k,
      rx_in_ref50           => rx_in_ref50,
      rx_loopback2_rx2tx_en => rx_loopback2_rx2tx_en,
      rx_loopback2_tx2rx_en => rx_loopback2_tx2rx_en,
      rx_sel_data           => rx_sel_data,
      rx_sel_test           => rx_sel_test,
      rx_sipo_aux_sel       => rx_sipo_aux_sel,
      rx_sipo_en            => rx_sipo_en,
      rx_sipo_invdata       => rx_sipo_invdata,
      rx_sipo_n             => rx_sipo_n,
      rx_sipo_rst           => rx_sipo_rst,
      rx_cdr_filtout        => status_i((2*64)+8 downto 2*64),
      rx_spare              => rx_spare,
      rx_vref_bypass        => rx_vref_bypass
      );

end rtl;
