--------------------------------------------------------------------------------
--
--	Compagny : ASYGN
--	Engineer : 
--
--	Creation Date : 2014-04-03T16:34+0200
--	Design name :
--	Module type : VHDL
--	Module name : osc
--	Project name :
--	Tool versions :
--	Description : 
--
--	Dependencies : 
--
--	Revision : 
--	Additionnal comments : 
--
--------------------------------------------------------------------------------


LIBRARY DISCIPLINES, IEEE, WORK;
USE DISCIPLINES.ELECTROMAGNETIC_SYSTEM.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.MATH_REAL.ALL;
--Insert here other libraires definition


ENTITY osc is 

--Generic variable definition
GENERIC (
	g_dvddgo1_min : real := 1.0 ; -- Generic for power tests
	g_dvddgo1_max : real := 2.0 ; -- Generic for power tests
	g_dvss_current_test : real := 1.0e-06 ; -- Generic for power tests
	g_dvss_min : real := -0.01 ; -- Generic for power tests
	g_dvss_max : real := 0.01  -- Generic for power tests
	--g_generic_name : real := generic_value ;
	--g_generic_name : realvector (0 TO XX) := (gen_val1, gen_val2, ..., gen_valXX) ;
);

--I/O Block definition
PORT(
	terminal dvddgo1 : ELECTRICAL ; -- Power port
	terminal dvss : ELECTRICAL ; -- Power port
	signal id_en : in std_ulogic ; 
	signal od_clk : out std_ulogic  
);

END ENTITY osc;

ARCHITECTURE FUNCTIONAL OF osc IS

--Quantity and signal definitions
	signal s_test_dvddgo1 : boolean := false ; -- Power test purpose
	quantity v_dvddgo1 across dvddgo1 to dvss ; --Specify ground name
	signal s_test_dvss : boolean := false ; -- Power test purpose
	quantity v_dvss across i_dvss through dvss ;
	--signal s_signalname : boolean/std_ulogic/integer/real/signed/unsigned := basevalue ;
  signal s_clk_int : std_ulogic := '0';
  signal s_enable_fct : std_ulogic := '1';
BEGIN

--Power tests
	s_test_dvddgo1 <= true when v_dvddgo1'above(g_dvddgo1_min)
	and not v_dvddgo1'above(g_dvddgo1_max) and domain=time_domain
	else false ;
-- current for ground tests
  i_dvss == g_dvss_current_test;
	s_test_dvss <= true when v_dvss'above(g_dvss_min)
	and not v_dvss'above(g_dvss_max) and domain=time_domain
	else false ;
--Repports in transcript for power tests
	assert s_test_dvddgo1 or s_enable_fct = '0' 
	report "osc : dvddgo1 powercheck failure ; voltage value out of bound" severity warning ;
	assert s_test_dvss or s_enable_fct = '0' 
	report "osc : dvss powercheck failure ; voltage value out of bound" severity warning ;

--------------------------------------------------------------------------------
-- Component section
--------------------------------------------------------------------------------

internal_clk: PROCESS (s_clk_int)
BEGIN
IF s_clk_int = '1'
THEN s_clk_int <= '0' AFTER 0.75e-9 * 1 sec;
ELSE s_clk_int <= '1' AFTER 0.75e-9 * 1 sec;
END IF;
END PROCESS internal_clk;

--Output clock generation
od_clk <= s_clk_int ;

END ARCHITECTURE FUNCTIONAL;

