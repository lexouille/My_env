-------------------------------------------------------------------------------
-- Title      : internal_bus_mux.vhd
-- Project    : 
-------------------------------------------------------------------------------
-- File	      : internal_bus_mux.vhd
-- Author     : Mickael Barre  <mbarre@sanfrancisco.lin.asygn.com>
-- Company    : 
-- Created    : 2012-11-14
-- Last update: 2013-05-06
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: add multiplexer on internal bus miso to avoid multiple driver
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2012-11-14  1.0	mbarre	Created
-------------------------------------------------------------------------------
library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.internal_bus.all;

-------------------------------------------------------------------------------
--! @file 
--! @brief Internal bus multiplexer
-------------------------------------------------------------------------------
--! @details
--! This component is used to connect output buses of all components to UART. \n
--! It is acting as bus arbiter to avoid multiple write access on the UART TX input (mag9_bus_MISO).\n
--!\n
--! It works as a simple multiplexer. To select which component has to be connected with the UART,\n
--! it is decoding addr_MSB from the PC command (read or write).\n
--!\n
--! When Streaming mode is selected, multiplexer is forced to connect Streaming\n
--! component to UART for data output streaming. This functionnality disables ability to read registers during\n
--! streaming transmissions.\n
--! \n
--! Internal bus mux schematic : \n
--! \image html "/nfs/work-crypt/board/mbarre/workspace/mag9_hw/doc/diagrams/internal_bus_mux/internal_bus_mux.png"
--! @author M.BARRE



entity internal_bus_mux is
  port (
    internal_bus_mosi		  : in	mag9_bus_MOSI;	--! internal bus from UART
    internal_bus_miso_uart	  : out mag9_bus_MISO;	--! internal bus to UART
    --
    internal_bus_miso_config	  : in	mag9_bus_MISO;	--! internal bus from configuration component
    internal_bus_miso_top_ma	  : in	mag9_bus_MISO;	--! internal bus from top_ma component
    internal_bus_miso_gyro	  : in	mag9_bus_MISO;	--! internal bus from gyrometer component
    internal_bus_miso_streaming	  : in	mag9_bus_MISO;	--! internal bus from streaming component
    internal_bus_miso_temperature : in	mag9_bus_MISO;	--! internal bus from temperature component
    -- from streaming
    streaming_in_run		  : in	std_logic  --! Streaming enable flag

    );
end internal_bus_mux;

architecture rtl of internal_bus_mux is
  
  signal rstb  : std_logic;
  signal clock : std_logic;

begin  -- rtl

  clock <= internal_bus_mosi.clk;
  rstb	<= internal_bus_mosi.resetb;

  adress_decode_p : process (rstb, clock, internal_bus_miso_streaming)
  begin
    if rstb = '0' then
      internal_bus_miso_uart <= internal_bus_miso_streaming;
      
    elsif clock'event and clock = '1' then

      if streaming_in_run = '0' then
	case internal_bus_mosi.addr_MSB is
	  when ADDR_MAP_CONFIG_OFFSET		  => internal_bus_miso_uart <= internal_bus_miso_config;
	  when ADDR_MAP_MA_OFFSET		  => internal_bus_miso_uart <= internal_bus_miso_top_ma;
	  when ADDR_MAP_GYRO_OFFSET		  => internal_bus_miso_uart <= internal_bus_miso_gyro;
	  when ADDR_MAP_STREAMING_OFFSET	  => internal_bus_miso_uart <= internal_bus_miso_streaming;
	  when ADDR_MAP_TEMPERATURE_SENSOR_OFFSET => internal_bus_miso_uart <= internal_bus_miso_temperature;
	  when others				  => internal_bus_miso_uart <= internal_bus_miso_streaming;
	end case;

      else
	internal_bus_miso_uart <= internal_bus_miso_streaming;

      end if;
      
    end if;
  end process;

end rtl;
