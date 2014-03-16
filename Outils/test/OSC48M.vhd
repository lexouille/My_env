--------------------------------------------------------------------------------
--
--   Copyright(c)STMicroelectronics, 2006-2010 All Rights Reserved.
--   Confidential and Proprietary information which is the
--   property of STMicroelectronics -
--
--------------------------------------------------------------------------------
--    CUSTOMER    : ST IMG
--    PROJECT     : MICKEY
--    PROVIDER    : IMG GNB 
--------------------------------------------------------------------------------
--    BLOCK     OSC48M
--    VHDL-AMS FILE: OSC48M.vhd
--    SPECIFICATIONS REFERENCE: <document name>
--    AUTHOR    Nicolas Delorme (Asygn)
--    MODEL MATURITY LEVEL: 0
--          0 - Under construction
--          1 - Prototype
--          2 - Validated against specifications
--          3 - Validated against transistor level
--          4 - Validated in top level simulation
--    SIMULATION DOMAIN : TIME ( and AC when necessary )
--
--    DESCRIPTION:
--                 
--
--    CREATION DATE: 17/04/2013
--    CHANGE HISTORY : <date> <reason>
--      10/12/2013   Added power calculations - N. DELORME
--
--------------------------------------------------------------------------------

LIBRARY ieee, disciplines;
USE disciplines.electromagnetic_system.ALL,
ieee.std_logic_1164.ALL,
ieee.std_logic_arith.ALL,
ieee.std_logic_unsigned.ALL,
ieee.math_real.ALL;
--LIBRARY ST_AMS_MODELS;

ENTITY OSC48M  IS
GENERIC (
g_avdd1v2_min : REAL := 1.1;
g_avdd1v2_max : REAL := 1.3;
g_IPVCO_min : REAL := 8.0e-6;
g_IPVCO_max : REAL := 22.0e-6;
g_freq : REAL_VECTOR (0 TO 15) := 		(32.54e6, 	34.76e6, 	37.18e6,		39.17e6,		41.39e6,		43.36e6,		45.5e6,		47.38e6,		49.36e6,		51.24e6,		53.22e6,		54.83e6,		56.74e6,		58.41e6,		60.07e6,		61.7e6);
g_i_for_freq : REAL_VECTOR (0 TO 15) := 		(8.38e-6, 	9.16e-6, 	10.06e-6, 	10.84e-6, 	11.73e-6, 	12.51e-6, 	13.41e-6, 	14.19e-6, 	15.09e-6, 	15.87e-6, 	16.76e-6, 	17.54e-6, 	18.44e-6, 	19.22e-6, 	20.12e-6, 	20.9e-6);
g_dc : REAL := 0.5;                                       
g_current_gnd_test : REAL := 1.0e-06; 
g_voltage_max_gnd_test : REAL := 0.1e-03; 
g_voltage_min_gnd_test : REAL := -0.1e-03;
g_pulldown_IPVCO : REAL := 1.0/10.0e-05
);

PORT(
TERMINAL AVDD1V2 : ELECTRICAL;
TERMINAL AGND : ELECTRICAL;
TERMINAL ASUB : ELECTRICAL;
TERMINAL IPVCO : ELECTRICAL;
SIGNAL CK48M_PD : IN STD_ULOGIC;
SIGNAL VCK48M : OUT STD_ULOGIC
);
END ENTITY OSC48M;

ARCHITECTURE FUNCTIONAL OF OSC48M IS

QUANTITY v_GND ACROSS i_GND THROUGH AGND;
QUANTITY v_AVDD1V2 ACROSS AVDD1V2 TO AGND;
SIGNAL s_test_GND, s_test_AVDD1V2, s_test_IPVCO : BOOLEAN := FALSE;
SIGNAL s_enable_fct, s_enable_power, s_enable_global : REAL := 0.0;
CONSTANT c_roff : REAL := 1.0e9;
SIGNAL s_rIPVCO : REAL := c_roff;
SIGNAL s_ipvco  : REAL := 1.0e-15;
QUANTITY v_IPVCO_GND ACROSS i_IPVCO_GND THROUGH IPVCO TO AGND;
SIGNAL s_FREQCTRL_ix : INTEGER := 0;
SIGNAL s_freq : REAL := 0.0;
SIGNAL s_clk_int : STD_ULOGIC := '0';
SIGNAL s_ton, s_toff : REAL := 0.0;  
signal s_total_power : REAL := 0.0;

BEGIN

-- current for ground tests and biasing check
i_GND == g_current_gnd_test;

s_rIPVCO <= g_pulldown_IPVCO WHEN s_enable_fct = 1.0 ELSE c_roff;
i_IPVCO_GND == v_IPVCO_GND / s_rIPVCO;
BREAK ON s_rIPVCO;

-- power checks
s_test_GND <= TRUE WHEN v_GND'ABOVE(g_voltage_min_gnd_test)
AND NOT v_GND'ABOVE(g_voltage_max_gnd_test) AND DOMAIN=TIME_DOMAIN
ELSE FALSE;

s_test_AVDD1V2 <= TRUE WHEN v_AVDD1V2'ABOVE(g_avdd1v2_min)
AND NOT v_AVDD1V2'ABOVE(g_avdd1v2_max) AND DOMAIN=TIME_DOMAIN
ELSE FALSE;

s_test_IPVCO <= TRUE WHEN i_IPVCO_GND'ABOVE(g_IPVCO_min)
AND NOT i_IPVCO_GND'ABOVE(g_IPVCO_max) AND DOMAIN=TIME_DOMAIN
ELSE FALSE;

-- reports in transcripts for power checks
ASSERT s_test_AVDD1V2 OR s_enable_fct = 0.0
REPORT "OSC48M: AVDD1V2 voltage: value out of bounds" SEVERITY WARNING;

ASSERT s_test_GND OR s_enable_fct = 0.0
REPORT "OSC48M: GND voltage: value out of bounds" SEVERITY WARNING;

ASSERT s_test_IPVCO OR s_enable_fct = 0.0
REPORT "OSC48M: IPVCO current: value out of bounds" SEVERITY WARNING;

-- cell enable signal
s_enable_fct <= 1.0 WHEN (CK48M_PD = '0' OR CK48M_PD = 'L')
ELSE 0.0;

s_FREQCTRL_ix <= 	1 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(1)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(2)) ELSE 
			2 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(2)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(3)) ELSE 
			3 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(3)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(4)) ELSE
			4 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(4)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(5)) ELSE
			5 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(5)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(6)) ELSE
			6 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(6)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(7)) ELSE
			7 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(7)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(8)) ELSE
			8 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(8)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(9)) ELSE
			9 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(9)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(10)) ELSE
			10 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(10)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(11)) ELSE
			11 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(11)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(12)) ELSE
			12 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(12)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(13)) ELSE
			13 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(13)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(14)) ELSE
			14 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(14)) AND NOT i_IPVCO_GND'ABOVE(g_i_for_freq(15)) ELSE
			15 WHEN i_IPVCO_GND'ABOVE(g_i_for_freq(15)) 
			ELSE 0;
s_freq <= g_freq(s_FREQCTRL_ix);
s_ton <= g_dc / s_freq WHEN s_freq /= 0.0 ELSE 0.5;
s_toff <= (1.0 - g_dc) / s_freq WHEN s_freq /= 0.0 ELSE 0.5;

internal_clk: PROCESS (s_clk_int, s_ton, s_toff)
BEGIN
IF s_clk_int = '1'
THEN s_clk_int <= '0' AFTER s_ton * 1 sec;
ELSE s_clk_int <= '1' AFTER s_toff * 1 sec;
END IF;
END PROCESS internal_clk;

-- power checks enable signal
s_enable_power <= 1.0 WHEN s_test_GND AND s_test_AVDD1V2 AND
s_test_IPVCO ELSE 0.0;

-- global cell enable signal (functionality + power)
s_enable_global <= 1.0 WHEN s_enable_fct = 1.0 AND s_enable_power = 1.0
ELSE 0.0;

-- output clock generation
VCK48M <= s_clk_int WHEN s_enable_global = 1.0 ELSE '0';

s_total_power <=  i_IPVCO_GND * s_enable_global * v_AVDD1V2;

END ARCHITECTURE FUNCTIONAL;
