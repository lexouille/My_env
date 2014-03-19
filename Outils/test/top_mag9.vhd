----------------------------------------------------------------------------------
-- Company:		Asygn
-- Engineer:		CLB
-- 
-- Create Date:		08/16/2012 
-- Design Name: 
-- Module Name:		top_mag9 - rtl 
-- Project Name:	mag9
-- Tool versions:	ise 12.4
-- Description:		mag9 top module
--
-- Dependencies: 
--
-- Revision:
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.internal_bus.all;

-------------------------------------------------------------------------------
-- main page comments !
-------------------------------------------------------------------------------
--!\mainpage MAG9 project
--! \image html DSC_4249_rescale_2.jpg 
--! \n
--!  The following link points to the MAG9 top module description : <a href="classtop__mag9.html" style="font-size:20pt">Go to top module</a>
--! @author C.LE BLANC / M.BARRE, ASYGN to TRONICS.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- top_mag9 comments
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--! @file 
--! @brief Top_mag9 architecture
-------------------------------------------------------------------------------
--! @details
--! This component is used to instanciate all functions of mag9 project. \n
--! It is including all physical component's drivers and logical part. \n 
--! \image html "/nfs/work-crypt/board/mbarre/workspace/mag9_hw/doc/diagrams/top_MA/top_mag9.png" \n
--! MAG9 digital processing is split in several sub-functions :
--!	- UART : this component is used to connect the board and a PC.
--!	- CONTROLLER : this component is specifically designed to drive
--!	the internal bus. Internal bus connects UART and all other components requiring read/write access.
--!	- GLOBAL SETTING : this component is used to generate software reset
--!	for all the code. It is also containing the intial settings of the UART and the firmware
--!	version.
--! 	- STREAMING : this component provides data frame to be sent to the UART at
--!	user defined sampling interval, from 1S/s to 10 kS/s. Several types of data can be sent.
--!	- TOP_GYRO : this component is including all gyro's digital signal processing and component's drivers and interfaces.
--!	- TOP_MA : this component is including all digital signal processing for magnetometer and accelerometer
--!	sensors and component's drivers and interfaces.
--! \n \n
--! Global clock is divided by two for all components to reduce timings constraints on the FPGA firmware.\n
--! \n
--! @author M.BARRE



entity top_mag9 is
  generic(
    UART_BAUDRATE : integer := 230400;	--! default BAUDRATE : 230400
    GYRO_ENABLE	  : boolean := true;  --! enable gyrometer building, debug only
    MA_ENABLE	  : boolean := true   --! enable gyrometer building, debug only
    );
  port (

    -- configuration
    clk		    : in    std_logic;	--! FGPA Clock : 125 MHz
    led		    : out   std_logic;	--! FGPA board led
    leds	    : out   std_logic_vector(3 downto 0);  --! MAG9 breadbord leds (D4 / D5 / D6 / D7)
    -- supply enable
    AVDD3V3_EN	    : out   std_logic;	--! FPGA pin, enable 3.3 V supply (U4)
    AVDD2V5_EN	    : out   std_logic;	--! FPGA pin, enable 2.5 V supply (U1)
    VREFDAC_EN	    : out   std_logic;	--! FPGA pin, enable VrefDAC supply (U8)
    VREF_EN	    : out   std_logic;	--! FPGA pin, enable Vref supply (U8)
    S10V0_en	    : out   std_logic;	--! FPGA pin, enable S10V0 supply (Selftest and gyormeter boost) (U2 & U3)
    -- self test
    AM_STN_EN	    : out   std_logic;	--! FPGA pin, ADG1419 (U25) enable selftest pin STN
    AM_STP_EN	    : out   std_logic;	--! FPGA pin, ADG1419 (U24) enable selftest pin STP
    vh_prb	    : out   std_logic;	--! FPGA pin, AD5260 (U5) active low preset to midlescale (not used)
    vh_csb	    : out   std_logic;	--! FPGA pin, AD5260 (U5) active low Chip select
    vh_en	    : out   std_logic;	--! FPGA pin, AD5260 (U5) active low shutdown
    vh_clk	    : out   std_logic;	--! FPGA pin, AD5260 (U5) SPI clock
    vh_sdi	    : out   std_logic;	--! FPGA pin, AD5260 (U5) SPI data in
    vh_vl	    : out   std_logic;	--! FPGA pin, AD5260 (U5) logical voltage reference
    -- J7 connector
    HEADER0	    : in    std_logic;	--! External board connector, Header0 (J7) UART Rx pin
    HEADER1	    : out   std_logic;	--! External connector, Header1 (J7) UART Tx pin
    -- acceleromter and magnetometer driving
    amr_adc_sck	    : out   std_logic;	--! FPGA pin, AD7982 (U17) MA adc spi clock
    amr_adc_cnv	    : out   std_logic;	--! FPGA pin, AD7982 (U17) MA adc enable conversion pin
    amr_adc_sdi	    : out   std_logic;	--! FPGA pin, AD7982 (U17) MA adc spi data in (not used)
    amr_adc_sdo	    : in    std_logic;	--! FPGA pin, AD7982 (U17) MA adc spi data out
    amr_f_bypass    : out   std_logic;	--! FPGA pin, ADG621 (U19) enable analog filter bypass
    amr_ampd_en	    : out   std_logic;	--! FPGA pin, ADA4940 (U23) enable differential amplifier
    amr_gain_a0	    : out   std_logic;	--! FPGA pin, ADG709 (U21 & U22) LSB address 
    amr_gain_a1	    : out   std_logic;	--! FPGA pin, ADG709 (U21 & U22) MSB address 
    amr_ina_en	    : out   std_logic;	--! FPGA pin, ADA4897 (18) dual linear amplifier
    amr_mux_a0	    : out   std_logic;	--! FPGA pin, ADG707 (U20) LSB address
    amr_mux_a1	    : out   std_logic;	--! FPGA pin, ADG707 (U20) middle address
    amr_mux_a2	    : out   std_logic;	--! FPGA pin, ADG707 (U20) MSB address
    ambias_mux_sck  : out   std_logic;	--! FPGA pin, ADG714 (U10 / U13) common SPI clock
    ambias_mux_synb : out   std_logic;	--! FPGA pin, ADG714 (U10 / U13) common SPI chip select
    ambias_mux_rstb : out   std_logic;	--! FPGA pin, ADG714 (U10 / U13) common active low reset
    ambias_mux_din1 : out   std_logic;	--! FPGA pin, ADG714 (U10) SPI SDI
    ambias_mux_din2 : out   std_logic;	--! FPGA pin, ADG714 (U13) SPI SDI 
    ambias_buf_en   : out   std_logic;	--! FPGA pin, ADA4897 (U12) active high enable
    ambias_dac_sck  : out   std_logic;	--! FPGA pin, AD5541 (U11) SPI clock
    ambias_dac_csb  : out   std_logic;	--! FPGA pin, AD5541 (U11) SPI chip select
    ambias_dac_din  : out   std_logic;	--! FPGA pin, AD5541 (U11) SPI SDI
    ambias_dac_ldb  : out   std_logic;	--! FPGA pin, AD5541 (U11) active low output update signal
    -- temperature sensor
    temp_DQ	    : inout std_logic;	--! FPGA pin, DS18S20 (U39) temperature sensor
    -- gyrometer part
    --readout
    gr_mux_a0	    : out   std_logic;	--! FPGA pin, ADG709 (U34) LSB address
    gr_mux_a1	    : out   std_logic;	--! FPGA pin, ADG709 (U34) MSB address
    gr_ina_en	    : out   std_logic;	--! FPGA pin, ADA4897 (U31) active high enable
    gr_gain_a0	    : out   std_logic;	--! FPGA pin, ADG709 (U35 / U36) LSB address
    gr_gain_a1	    : out   std_logic;	--! FPGA pin, ADG709 (U35 / U36) MSB address 
    gr_ampd_en	    : out   std_logic;	--! FPGA pin, ADA4940 (U37) active high enable
    gr_f_bypass	    : out   std_logic;	--! FPGA pin, ADG621 (U33) enable analog filter bypass
    gr_adc_sdi	    : out   std_logic;	--! FPGA pin, AD7982 (U32) SPI SDI
    gr_adc_sck	    : out   std_logic;	--! FPGA pin, AD7982 (U32) SPI clock
    gr_adc_sdo	    : in    std_logic;	--! FPGA pin, AD7982 (U32) SPI SDO
    gr_adc_cnv	    : out   std_logic;	--! FPGA pin, AD7982 (U32) conversion signal
    gdr_mux_a0	    : out   std_logic;	--! FPGA pin, ADG804 (U29) LSB address
    gdr_mux_a1	    : out   std_logic;	--! FPGA pin, ADG804 (U29) MSB address
    gdr_ampd_en	    : out   std_logic;	--! FPGA pin, ADA4940 (U30) enable differential amplifier
    gdr_f_bypass    : out   std_logic;	--! FPGA pin, ADG621 (U28) enable analog filter bypass
    gdr_adc_sdi	    : out   std_logic;	--! FPGA pin, AD7982 (U27) SPI SDI
    gdr_adc_sck	    : out   std_logic;	--! FPGA pin, AD7982 (U27) SPI clock 
    gdr_adc_sdo	    : in    std_logic;	--! FPGA pin, AD7982 (U27) SPI SDO
    gdr_adc_cnv	    : out   std_logic;	--! FPGA pin, AD7982 (U27) conversion signal
    gd_dac_sck	    : out   std_logic;	--! FPGA pin, AD5541 (U42 / U45 / U48) common SPI clock
    gdx_dac_ldb	    : out   std_logic;	--! FPGA pin, AD5541 (U42) active low output update signal
    gdx_dac_csb	    : out   std_logic;	--! FPGA pin, AD5541 (U42) SPI chip select
    gdx_dac_din	    : out   std_logic;	--! FPGA pin, AD5541 (U42) SPI SDI
    gdx_buf_enb	    : out   std_logic;	--! FPGA pin, ADA4941 (U41) active high enable
    gdx_mux_a0	    : out   std_logic;	--! FPGA pin, ADG1604 (U40) LSB address
    gdx_mux_a1	    : out   std_logic;	--! FPGA pin, ADG1604 (U40) MSB address
    gdy_dac_ldb	    : out   std_logic;	--! FPGA pin, AD5541 (U45) active low output update signal
    gdy_dac_csb	    : out   std_logic;	--! FPGA pin, AD5541 (U45) SPI chip select
    gdy_dac_din	    : out   std_logic;	--! FPGA pin, AD5541 (U45) SPI SDI
    gdy_buf_enb	    : out   std_logic;	--! FPGA pin, ADA4941 (U44) active high enable 
    gdy_mux_a0	    : out   std_logic;	--! FPGA pin, ADG1604 (U43) LSB address
    gdy_mux_a1	    : out   std_logic;	--! FPGA pin, ADG1604 (U43) MSB address 
    gdz_dac_ldb	    : out   std_logic;	--! FPGA pin, AD5541 (U48) active low output update signal
    gdz_dac_csb	    : out   std_logic;	--! FPGA pin, AD5541 (U48) SPI chip select
    gdz_dac_din	    : out   std_logic;	--! FPGA pin, AD5541 (U48) SPI SDI
    gdz_buf_enb	    : out   std_logic;	--! FPGA pin, ADA4941 (U47) active high enable
    gdz_mux_a0	    : out   std_logic;	--! FPGA pin, ADG1604 (U46) LSB address
    gdz_mux_a1	    : out   std_logic;	--! FPGA pin, ADG1604 (U46) MSB address
    -- amp C2V
    gdrx_amp_en	    : out   std_logic;	--! FPGA pin, AD8655 (U49) active high enable, no longer used
    gdry_amp_en	    : out   std_logic;	--! FPGA pin, AD8655 (U50) active high enable, no longer used
    gdrz_amp_en	    : out   std_logic;	--! FPGA pin, AD8655 (U51) active high enable, no longer used
    -- bias switch
    gbias_mux_sck   : out   std_logic;	--! FPGA pin, ADG714 (U15) common SPI clock
    gbias_mux_synb  : out   std_logic;	--! FPGA pin, ADG714 (U15) common SPI chip select
    gbias_mux_rstb  : out   std_logic;	--! FPGA pin, ADG714 (U15) common active low reset
    gbias_mux_din   : out   std_logic;	--! FPGA pin, ADG714 (U15) SPI SDI
    -- bias amp en
    gbias_buf_en    : out   std_logic;	--! FPGA pin, ADA4897 (U16) active high enable
    -- bias dac
    gbias_dac_csb   : out   std_logic;	--! FPGA pin, AD5541 (U14) SPI chip select
    gbias_dac_ldb   : out   std_logic;	--! FPGA pin, AD5541 (U14) active low output update signal
    gbias_dac_din   : out   std_logic;	--! FPGA pin, AD5541 (U14) SPI SDI
    gbias_dac_sck   : out   std_logic;	--! FPGA pin, AD5541 (U14) SPI clock
    -- pot
    gdr_pot_rsb	    : out   std_logic;	--! FPGA pin, AD8403 (U26) active low reset
    gdr_pot_clk	    : out   std_logic;	--! FPGA pin, AD8403 (U26) SPI clock
    gdr_pot_csb	    : out   std_logic;	--! FPGA pin, AD8403 (U26) SPI active low chip select
    gdr_pot_sdi	    : out   std_logic	--! FPGA pin, AD8403 (U26) SPI SDI
    );
end top_mag9;

architecture rtl of top_mag9 is

  signal INTERNAL_BUS_MOSI	       : mag9_bus_MOSI;
  signal INTERNAL_BUS_MISO_UART	       : mag9_bus_MISO;
  signal INTERNAL_BUS_MISO_CONFIG      : mag9_bus_MISO;
  signal INTERNAL_BUS_MISO_TOP_MA      : mag9_bus_MISO;
  signal INTERNAL_BUS_MISO_GYRO	       : mag9_bus_MISO;
  signal INTERNAL_BUS_MISO_STREAMING   : mag9_bus_MISO;
  signal INTERNAL_BUS_MISO_TEMPERATURE : mag9_bus_MISO;
  signal accx_16b		       : signed(15 downto 0);
  signal accy_16b		       : signed(15 downto 0);
  signal accz_16b		       : signed(15 downto 0);
  signal magx_16b		       : signed(15 downto 0);
  signal magy_16b		       : signed(15 downto 0);
  signal magz_16b		       : signed(15 downto 0);
  signal gyrox_16b		       : signed(15 downto 0);
  signal gyroy_16b		       : signed(15 downto 0);
  signal gyroz_16b		       : signed(15 downto 0);
  signal gyro_status		       : std_logic_vector(6 downto 0);
  signal temperature_9b		       : std_logic_vector(8 downto 0);
  -- signal   temperature_16b		 : signed(15 downto 0);
  signal reset_from_configuration      : std_logic;
  signal clockDivider_u		       : unsigned (15 downto 0);
  signal timeout_u		       : unsigned(15 downto 0);
  signal global_clock		       : std_logic := '0';
  signal streaming_status	       : std_logic_vector(1 downto 0);
  signal output_fifo_read_flag	       : std_logic;
  -- debug
  signal self_test_en		       : std_logic;
  signal reset_MA_only		       : std_logic;
  signal gyro_single_channel_en	       : std_logic;
  
begin

-- component

  -----------------------------------------------------------------------------
  -- Internal bus control
  -----------------------------------------------------------------------------
  -- BUS MUX
  internal_bus_mux : entity work.internal_bus_mux(rtl) port map (
    internal_bus_mosi		  => INTERNAL_BUS_MOSI,
    internal_bus_miso_uart	  => INTERNAL_BUS_MISO_UART ,
    internal_bus_miso_config	  => INTERNAL_BUS_MISO_CONFIG ,
    internal_bus_miso_top_ma	  => INTERNAL_BUS_MISO_TOP_MA ,
    internal_bus_miso_gyro	  => INTERNAL_BUS_MISO_GYRO ,
    internal_bus_miso_streaming	  => INTERNAL_BUS_MISO_STREAMING,
    internal_bus_miso_temperature => INTERNAL_BUS_MISO_TEMPERATURE,
    streaming_in_run		  => streaming_status(1)
    );

  -- top config
  top_config : entity work.top_configuration(rtl)
    generic map (
      UART_BAUDRATE => UART_BAUDRATE)
    port map (
      internal_bus_mosi	  => INTERNAL_BUS_MOSI,
      internal_bus_miso	  => INTERNAL_BUS_MISO_CONFIG,
      reset_configuration => reset_from_configuration,
      reset_MA_only	  => reset_MA_only,
      clockDivider_u	  => clockDivider_u ,
      timeout_u		  => timeout_u
      );
  -----------------------------------------------------------------------------
  -- UART / streaming
  -----------------------------------------------------------------------------
  -- UART
  UART : entity work.UART(Behavioral) port map (
    clk_uart		  => global_clock,
    resetb		  => reset_from_configuration,
    Rx			  => HEADER0,
    Tx			  => HEADER1,
    INTERNAL_BUS_MOSI	  => INTERNAL_BUS_MOSI,
    INTERNAL_BUS_MISO	  => INTERNAL_BUS_MISO_UART,
    clockDivider_u	  => clockDivider_u ,
    timeout_u		  => timeout_u,
    output_fifo_read_flag => output_fifo_read_flag
    );

  ------ STREAMING
  streaming : entity work.top_streaming(rtl) port map (
    internal_bus_mosi => INTERNAL_BUS_MOSI,
    internal_bus_miso => INTERNAL_BUS_MISO_STREAMING,
    accx_16b	      => accx_16b,
    accy_16b	      => accy_16b,
    accz_16b	      => accz_16b,
    magx_16b	      => magx_16b,
    magy_16b	      => magy_16b,
    magz_16b	      => magz_16b,
    gyrox_16b	      => gyrox_16b,
    gyroy_16b	      => gyroy_16b,
    gyroz_16b	      => gyroz_16b,
    gyro_status	      => gyro_status,
    temperature_9b    => temperature_9b,
    streaming_status  => streaming_status
    );

  -----------------------------------------------------------------------------
  -- Magneto / Accelero Top
  -----------------------------------------------------------------------------

  ma_inst : if MA_ENABLE = true generate
    ---- TOP_MA, allow driving of accelerometer and gyrometer sensors
    TOP_MA : entity work.top_ma(rtl) port map (
      rstb_MA_only	     => reset_MA_only,
      internal_bus_mosi	     => INTERNAL_BUS_MOSI,
      internal_bus_miso	     => INTERNAL_BUS_MISO_TOP_MA,
      streaming_en	     => streaming_status(1),
      amr_adc_sck	     => amr_adc_sck ,
      amr_adc_cnv	     => amr_adc_cnv ,
      amr_adc_sdi	     => amr_adc_sdi ,
      amr_adc_sdo	     => amr_adc_sdo ,
      amr_f_bypass	     => amr_f_bypass ,
      amr_ampd_en	     => amr_ampd_en ,
      amr_gain_a0	     => amr_gain_a0 ,
      amr_gain_a1	     => amr_gain_a1 ,
      amr_ina_en	     => amr_ina_en ,
      amr_mux_a0	     => amr_mux_a0 ,
      amr_mux_a1	     => amr_mux_a1 ,
      amr_mux_a2	     => amr_mux_a2 ,
      ambias_mux_sck	     => ambias_mux_sck ,
      ambias_mux_synb	     => ambias_mux_synb,
      ambias_mux_rstb	     => ambias_mux_rstb ,
      ambias_mux_din1	     => ambias_mux_din1 ,
      ambias_mux_din2	     => ambias_mux_din2 ,
      ambias_buf_en	     => ambias_buf_en ,
      ambias_dac_sck	     => ambias_dac_sck ,
      ambias_dac_csb	     => ambias_dac_csb ,
      ambias_dac_din	     => ambias_dac_din ,
      ambias_dac_ldb	     => ambias_dac_ldb ,
      -- selftest
      S10V0_en		     => S10V0_en,
      AM_STN_EN		     => AM_STN_EN,
      AM_STP_EN		     => AM_STP_EN,
      vh_prb		     => vh_prb ,
      vh_csb		     => vh_csb ,
      vh_en		     => vh_en ,
      vh_clk		     => vh_clk ,
      vh_sdi		     => vh_sdi ,
      vh_vl		     => vh_vl ,
      -- output
      acc_filtered_x_16b_out => accx_16b,
      acc_filtered_y_16b_out => accy_16b,
      acc_filtered_z_16b_out => accz_16b,
      mag_filtered_x_16b_out => magx_16b,
      mag_filtered_y_16b_out => magy_16b,
      mag_filtered_z_16b_out => magz_16b,
      self_test_en	     => self_test_en
      --   uart_output_fifo_read_flag => output_fifo_read_flag
      );
  end generate ma_inst;


  gyro_only_inst : if MA_ENABLE = false generate
    -- this section is used to disable MA part to allow fast
    -- building of gyrometer part. Debug only !
    INTERNAL_BUS_MISO_TOP_MA <= (x"0000", '0');
    amr_adc_sck		     <= '0';
    amr_adc_cnv		     <= '0';
    amr_adc_sdi		     <= '0';
    amr_f_bypass	     <= '0';
    amr_ampd_en		     <= '0';
    amr_gain_a0		     <= '0';
    amr_gain_a1		     <= '0';
    amr_ina_en		     <= '0';
    amr_mux_a0		     <= '0';
    amr_mux_a1		     <= '0';
    amr_mux_a2		     <= '0';
    ambias_mux_sck	     <= '0';
    ambias_mux_synb	     <= '0';
    ambias_mux_rstb	     <= '0';
    ambias_mux_din1	     <= '0';
    ambias_mux_din2	     <= '0';
    ambias_buf_en	     <= '0';
    ambias_dac_sck	     <= '0';
    ambias_dac_csb	     <= '0';
    ambias_dac_din	     <= '0';
    ambias_dac_ldb	     <= '0';
    S10V0_en		     <= '0';
    AM_STN_EN		     <= '0';
    AM_STP_EN		     <= '0';
    vh_prb		     <= '0';
    vh_csb		     <= '0';
    vh_en		     <= '0';
    vh_clk		     <= '0';
    vh_sdi		     <= '0';
    vh_vl		     <= '0';
    accx_16b		     <= x"0000";
    accy_16b		     <= x"0000";
    accz_16b		     <= x"0000";
    magx_16b		     <= x"0000";
    magy_16b		     <= x"0000";
    magz_16b		     <= x"0000";
    self_test_en	     <= '0';

  end generate gyro_only_inst;

  -----------------------------------------------------------------------------
  -- Gyro top instanciation
  -----------------------------------------------------------------------------


  g_inst : if GYRO_ENABLE = true generate
    TOP_GYRO_inst : entity work.top_gyro(rtl)
      port map (
	internal_bus_mosi	   => INTERNAL_BUS_MOSI,
	internal_bus_miso	   => INTERNAL_BUS_MISO_GYRO ,
	gr_mux_a0		   => gr_mux_a0 ,
	gr_mux_a1		   => gr_mux_a1 ,
	gr_ina_en		   => gr_ina_en ,
	gr_gain_a0		   => gr_gain_a0 ,
	gr_gain_a1		   => gr_gain_a1 ,
	gr_ampd_en		   => gr_ampd_en ,
	gr_f_bypass		   => gr_f_bypass ,
	gr_adc_sdi		   => gr_adc_sdi ,
	gr_adc_sck		   => gr_adc_sck ,
	gr_adc_sdo		   => gr_adc_sdo ,
	gr_adc_cnv		   => gr_adc_cnv ,
	gdr_mux_a0		   => gdr_mux_a0 ,
	gdr_mux_a1		   => gdr_mux_a1 ,
	gdr_ampd_en		   => gdr_ampd_en ,
	gdr_f_bypass		   => gdr_f_bypass ,
	gdr_adc_sdi		   => gdr_adc_sdi ,
	gdr_adc_sck		   => gdr_adc_sck ,
	gdr_adc_sdo		   => gdr_adc_sdo ,
	gdr_adc_cnv		   => gdr_adc_cnv ,
	gd_dac_sck		   => gd_dac_sck ,
	gdx_dac_ldb		   => gdx_dac_ldb ,
	gdx_dac_csb		   => gdx_dac_csb ,
	gdx_dac_din		   => gdx_dac_din ,
	gdx_buf_enb		   => gdx_buf_enb ,
	gdx_mux_a0		   => gdx_mux_a0 ,
	gdx_mux_a1		   => gdx_mux_a1 ,
	gdy_dac_ldb		   => gdy_dac_ldb ,
	gdy_dac_csb		   => gdy_dac_csb ,
	gdy_dac_din		   => gdy_dac_din ,
	gdy_buf_enb		   => gdy_buf_enb ,
	gdy_mux_a0		   => gdy_mux_a0 ,
	gdy_mux_a1		   => gdy_mux_a1 ,
	gdz_dac_ldb		   => gdz_dac_ldb ,
	gdz_dac_csb		   => gdz_dac_csb ,
	gdz_dac_din		   => gdz_dac_din ,
	gdz_buf_enb		   => gdz_buf_enb ,
	gdz_mux_a0		   => gdz_mux_a0 ,
	gdz_mux_a1		   => gdz_mux_a1 ,
	gdrx_amp_en		   => gdrx_amp_en ,
	gdry_amp_en		   => gdry_amp_en ,
	gdrz_amp_en		   => gdrz_amp_en ,
	gbias_mux_sck		   => gbias_mux_sck ,
	gbias_mux_synb		   => gbias_mux_synb ,
	gbias_mux_rstb		   => gbias_mux_rstb ,
	gbias_mux_din		   => gbias_mux_din ,
	gbias_buf_en		   => gbias_buf_en ,
	gbias_dac_csb		   => gbias_dac_csb ,
	gbias_dac_ldb		   => gbias_dac_ldb ,
	gbias_dac_din		   => gbias_dac_din ,
	gbias_dac_sck		   => gbias_dac_sck ,
	gdr_pot_rsb		   => gdr_pot_rsb ,
	gdr_pot_clk		   => gdr_pot_clk ,
	gdr_pot_csb		   => gdr_pot_csb ,
	gdr_pot_sdi		   => gdr_pot_sdi ,
	-- fifo
	uart_output_fifo_read_flag => output_fifo_read_flag,
	-- outputs
	gyro_status		   => gyro_status,
	gyrox_16b		   => gyrox_16b,
	gyroy_16b		   => gyroy_16b,
	gyroz_16b		   => gyroz_16b,
	gyro_single_channel_en	   => gyro_single_channel_en,
	gyro_en			   => streaming_status(1)
	);
  end generate g_inst;


-- when gyrometer is not instantiated, following part permit to generate
-- programming file without gyrometer component.

  g_ma_only_inst : if GYRO_ENABLE = false generate
    
    INTERNAL_BUS_MISO_GYRO <= (x"0000", '0');
    gr_mux_a0		   <= '0';
    gr_mux_a1		   <= '0';
    gr_ina_en		   <= '0';
    gr_gain_a0		   <= '0';
    gr_gain_a1		   <= '0';
    gr_ampd_en		   <= '0';
    gr_f_bypass		   <= '0';
    gr_adc_sdi		   <= '0';
    gr_adc_sck		   <= '0';
    --	gr_adc_sdo		     <= open;
    gr_adc_cnv		   <= '0';
    gdr_mux_a0		   <= '0';
    gdr_mux_a1		   <= '0';
    gdr_ampd_en		   <= '0';
    gdr_f_bypass	   <= '0';
    gdr_adc_sdi		   <= '0';
    gdr_adc_sck		   <= '0';
    -- gdr_adc_sdo		     <= '0';
    gdr_adc_cnv		   <= '0';
    gd_dac_sck		   <= '0';
    gdx_dac_ldb		   <= '0';
    gdx_dac_csb		   <= '0';
    gdx_dac_din		   <= '0';
    gdx_buf_enb		   <= '0';
    gdx_mux_a0		   <= '0';
    gdx_mux_a1		   <= '0';
    gdy_dac_ldb		   <= '0';
    gdy_dac_csb		   <= '0';
    gdy_dac_din		   <= '0';
    gdy_buf_enb		   <= '0';
    gdy_mux_a0		   <= '0';
    gdy_mux_a1		   <= '0';
    gdz_dac_ldb		   <= '0';
    gdz_dac_csb		   <= '0';
    gdz_dac_din		   <= '0';
    gdz_buf_enb		   <= '0';
    gdz_mux_a0		   <= '0';
    gdz_mux_a1		   <= '0';
    gdrx_amp_en		   <= '0';
    gdry_amp_en		   <= '0';
    gdrz_amp_en		   <= '0';
    gbias_mux_sck	   <= '0';
    gbias_mux_synb	   <= '0';
    gbias_mux_rstb	   <= '0';
    gbias_mux_din	   <= '0';
    gbias_buf_en	   <= '0';
    gbias_dac_csb	   <= '0';
    gbias_dac_ldb	   <= '0';
    gbias_dac_din	   <= '0';
    gbias_dac_sck	   <= '0';
    gdr_pot_rsb		   <= '0';
    gdr_pot_clk		   <= '0';
    gdr_pot_csb		   <= '0';
    gdr_pot_sdi		   <= '0';
    -- debug
    gyrox_16b		   <= x"0000";
    gyroy_16b		   <= x"0000";
    gyroz_16b		   <= x"0000";
    
  end generate g_ma_only_inst;



-------------------------------------------------------------------------------
-- temperature sensors component
-------------------------------------------------------------------------------

  top_temperature_sensor_1 : entity work.top_temperature_sensor(rtl)
    port map (
      internal_bus_mosi => INTERNAL_BUS_MOSI,
      internal_bus_miso => INTERNAL_BUS_MISO_TEMPERATURE,
      DQ		=> temp_DQ,	-- port inout 
      temperature_9b	=> temperature_9b
      );

-------------------------------------------------------------------------------
-- enable supply and global clock for all components
-------------------------------------------------------------------------------

  -- mag9 supply configuration
  AVDD3V3_EN <= '1';
  AVDD2V5_EN <= '1';
  VREFDAC_EN <= '1';
  VREF_EN    <= '1';
  -- leds signals
  leds(0)    <= not gyro_single_channel_en;
  leds(1)    <= not self_test_en;
  leds(2)    <= not streaming_status(0);
  leds(3)    <= not streaming_status(1);
  led	     <= '0';			-- turn on led on mother board



-- clock divider for internal_bus_pack clock, from 125MHz to 62.5 MHz
  clock_divider_p : process(clk)
  begin
    if rising_edge(clk) then
      global_clock <= not(global_clock);
    end if;
  end process;

  
end rtl;

