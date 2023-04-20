library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

use std.textio.all;
use std.env.finish;

-- ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** --
-- 	Author: Rose Epstein																	--
-- 																								--
-- 	This file contains the transmitter testbench code							-- 
-- 	There are 8 test cases																--
-- 																								--
-- ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** --

entity  tx_tb is
end entity  tx_tb;

architecture sim of  tx_tb  is
	-- Delcaring the Transmitter Component
	component TX is 
		port(
			clk : in std_logic; 
			resetn : in std_logic; 
			tx_data_in: in std_logic_vector(7 downto 0); 
			tx_start :	in std_logic;
			tx_data_out: out std_logic; 
			tx_busy: out std_logic; 
			tx_done: out std_logic);
	end component; 
	-- Constants for Clock Generation
	constant clk_hz : integer := 100e6;
	constant HALF_PERIOD : time := 10 ns;
	constant clk_period : time := HALF_PERIOD;
	-- Input Signals
	signal clk: std_logic := '1';
	signal resetn: std_logic := '1';
	signal tx_data_in: std_logic_vector(7 downto 0) := (others => '0');
	signal tx_start : std_logic := '1';
	-- Output Signals
	signal tx_data_out: std_logic;
	signal tx_busy, tx_done : std_logic;

	begin
		-- Generating the Clock
		clk <= not clk after HALF_PERIOD;
		-- Port Mapping the Transmitter Component Under Test
		DUT : tx
		port map (
			clk => clk,
			resetn => resetn,
			tx_data_in =>  tx_data_in,
			tx_start => tx_start,
			tx_data_out =>  tx_data_out,
			tx_busy => tx_busy,
			tx_done => tx_done
		);	
		-- Begin Simulation
		SEQUENCER_PROC : process
			begin
			report "===========================Begin tests===========================";
			-- Activate Transmission
			tx_start <= '1';
		
		-- Test 1
			report "=========================== Begin Test 1 ===========================";
			report "Test 1: data in = 01101101 parity check = odd (bit = 0)";
			tx_data_in <= "01101101"; -- data in
			wait for 104000 ns ;--start bit
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--1 (LSB)
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--2
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--3
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--4
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--5
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns;--6
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--7 
			assert ( tx_data_out = '1')
			report "data does not match expected" 
			severity failure;    
			wait for 104000 ns;--8 (MSB)
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--parity
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--stop bit
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			report "=========================== Test 1 Passed ===========================";
		
		-- Test 2
			report "=========================== Begin Test 2 ===========================";
			report "Test 2: data in = 00101101 parity check = even (bit = 1)";
			tx_data_in <= "00101101"; -- data in
			wait for 104000 ns ;--start bit
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--1 (LSB)
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--2
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--3
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--4
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--5
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns;--6
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--7 
			assert ( tx_data_out = '0')
			report "data does not match expected" 
			severity failure;    
			wait for 104000 ns;--8 (MSB)
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--parity
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--stop bit
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;			
			report "=========================== Test 2 Passed ===========================";
		
		-- Test 3
			report "=========================== Begin Test 3 ===========================";
			report "Test 3: data in = 11111111, parity check = even (bit = 1)";
			tx_data_in <= "11111111"; -- data in
			wait for 104000 ns ;--start bit
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--1 (LSB)
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--2
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--3
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--4
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--5
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns;--6
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--7 
			assert ( tx_data_out = '1')
			report "data does not match expected" 
			severity failure;    
			wait for 104000 ns;--8 (MSB)
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--parity
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--stop bit
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			report "=========================== Test 3 Passed ===========================";
		
		-- Test 4
			report "=========================== Begin Test 4 ===========================";
			report "Test 4: data in = 00000000, parity check = even (bit = 1)";
			tx_data_in <= "00000000"; -- data in
			wait for 104000 ns ;--start bit
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--1 (LSB)
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--2
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--3
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--4
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--5
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns;--6
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--7 
			assert ( tx_data_out = '0')
			report "data does not match expected" 
			severity failure;    
			wait for 104000 ns;--8 (MSB)
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--parity
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--stop bit
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			report "=========================== Test 4 Passed ===========================";
		
		-- Test 5
			report "=========================== Begin Test 5 ===========================";
			report "Test 5: data in = 11001100, parity check = even (bit = 1)";
			tx_data_in <= "11001100"; -- data in
			wait for 104000 ns ;--start bit
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--1 (LSB)
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--2
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--3
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--4
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--5
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns;--6
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--7 
			assert ( tx_data_out = '1')
			report "data does not match expected" 
			severity failure;    
			wait for 104000 ns;--8 (MSB)
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--parity
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--stop bit
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			report "=========================== Test 5 Passed ===========================";

		-- Test 6
			report "=========================== Begin Test 6 ===========================";
			report "Test 6: data in = 00110011, parity check = even (bit = 1)";
			tx_data_in <= "00110011"; -- data in
			wait for 104000 ns ;--start bit
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--1 (LSB)
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--2
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--3
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--4
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--5
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns;--6
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--7 
			assert ( tx_data_out = '0')
			report "data does not match expected" 
			severity failure;    
			wait for 104000 ns;--8 (MSB)
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--parity
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--stop bit
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			report "=========================== Test 6 Passed ===========================";
		
		-- Test 7
			report "=========================== Begin Test 7 ===========================";
			report "Test 7: data in = 11100011, parity check = odd (bit = 0)";
			tx_data_in <= "11100011"; -- data in
			wait for 104000 ns ;--start bit
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--1 (LSB)
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--2
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--3
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--4
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--5
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns;--6
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--7 
			assert ( tx_data_out = '1')
			report "data does not match expected" 
			severity failure;    
			wait for 104000 ns;--8 (MSB)
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--parity
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--stop bit
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			report "=========================== Test 7 Passed ===========================";

		-- Test 8
			report "=========================== Begin Test 8 ===========================";
			report "Test 8: data in = 01010100, parity check = odd (bit = 0)";
			tx_data_in <= "01010100"; -- data in
			wait for 104000 ns ;--start bit
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--1 (LSB)
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--2
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--3
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--4
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--5
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns;--6
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--7 
			assert ( tx_data_out = '1')
			report "data does not match expected" 
			severity failure;    
			wait for 104000 ns;--8 (MSB)
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--parity
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--stop bit
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			report "=========================== Test 8 Passed ===========================";
			
		-- Test 9
			report "=========================== Begin Test 9 ===========================";
			report "Test 9: data in = 10001110, parity check = even (bit = 1)";
			tx_data_in <= "10001110"; -- data in
			wait for 104000 ns ;--start bit
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--1 (LSB)
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--2
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--3
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--4
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--5
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns;--6
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--7 
			assert ( tx_data_out = '0')
			report "data does not match expected" 
			severity failure;    
			wait for 104000 ns;--8 (MSB)
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--parity
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--stop bit
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			report "=========================== Test 9 Passed ===========================";
			
		-- Test 10
			report "=========================== Begin Test 10 ===========================";
			report "Test 10: data in = 11110000, parity check = even (bit = 1)";
			tx_data_in <= "11110000"; -- data in
			wait for 104000 ns ;--start bit
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--1 (LSB)
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--2
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--3
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--4
			assert ( tx_data_out = '0')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--5
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns;--6
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure; 
			wait for 104000 ns ;--7 
			assert ( tx_data_out = '1')
			report "data does not match expected" 
			severity failure;    
			wait for 104000 ns;--8 (MSB)
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--parity
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;--stop bit
			assert ( tx_data_out = '1')
			report "data does not match expected"
			severity failure;
			wait for 104000 ns;
			report "=========================== Test 10 Passed ===========================";


			report "========================== ALL TESTS PASSED ==========================";

		finish;
	end process;

end architecture;