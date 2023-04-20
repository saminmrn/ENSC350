library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

-- ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** --
-- 	Author: Samin Moradkhan																--
-- 																								--
-- 	This file contains the receiver testbench code								-- 
-- 	There are 10 test cases																--
-- 																								--
-- ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** --

entity  rx_tb is
end entity  rx_tb;


architecture sim of  rx_tb  is
	-- Delcaring the Receiver Component
	component rx is 
		port(
		 clk : in std_logic;
		 resetn : in std_logic; 
		 rx_data_in: in std_logic; 
		 rx_data_out: out std_logic_vector(8 downto 0); 
		 rx_busy: out std_logic; 
		 rx_done: out std_logic; 
		 rx_err: out std_logic);
	end component; 
	-- Constants for Clock Generation
	constant clk_hz : integer := 100e6;
	constant HALF_PERIOD : time := 10 ns;
	constant clk_period : time := HALF_PERIOD;
	-- Input Signals
	signal clk: std_logic := '1';
	signal resetn: std_logic := '1';
	signal  rx_data_in: std_logic := '0';
	-- Output Signals
	signal  rx_data_out: std_logic_vector(8 downto 0);
	signal rx_busy, rx_done, rx_err: std_logic;

	begin
		-- Generating the Clock
		clk <= not clk after HALF_PERIOD;
		-- Port Mapping the Receiver Component Under Test
		DUT : rx
		port map (
			clk => clk,
			resetn => resetn,
			rx_data_in =>  rx_data_in,
			rx_data_out =>  rx_data_out,
			rx_busy => rx_busy,
			rx_done => rx_done,
			rx_err =>  rx_err
		);
		-- Begin Simulation
		SEQUENCER_PROC : process
			begin
			report "===========================Begin tests===========================";
		-- Test 1
			report "=========================== Begin Test 1 ===========================";
			report "Test 1: data in = 01101101 parity check = odd (bit = 0)";
			rx_data_in <= '0'; --start
			wait for 104000 ns ;--1
			rx_data_in <= '1';
			wait for 104000 ns ;--2
			rx_data_in <= '0';
			wait for 104000 ns ;--3
			rx_data_in <= '1';
			wait for 104000 ns ;--4
			rx_data_in <= '1';
			wait for 104000 ns ;--5
			rx_data_in <= '0';
			wait for 104000 ns;--6
			rx_data_in <= '1';
			wait for 104000 ns ;--7
			rx_data_in <= '1';       
			wait for 104000 ns;--8
			rx_data_in <= '0';
			wait for 104000 ns;--odd parity
			rx_data_in <= '0';
			wait for 104000 ns ; --stop 
			rx_data_in <= '1';

			wait for 104000*2 ns ;
			assert ( rx_data_out = "001101101")
				report "data does not match expected"
				severity failure; 

			report "=========================== Test 1 Passed ===========================";
		
		-- Test 2
			report "=========================== Begin Test 2 ===========================";
			report "Test 2: data in = 00111010 parity check = even (bit = 1)";

			rx_data_in <= '0'; --start
			wait for 104000 ns ;--1
			rx_data_in <= '0';
			wait for 104000 ns ;--2
			rx_data_in <= '1';
			wait for 104000 ns ;--3
			rx_data_in <= '0';
			wait for 104000 ns ;--4
			rx_data_in <= '1';
			wait for 104000 ns ;--5
			rx_data_in <= '1';
			wait for 104000 ns;--6
			rx_data_in <= '1';
			wait for 104000 ns ;--7
			rx_data_in <= '0';       
			wait for 104000 ns;--8
			rx_data_in <= '0';
			wait for 104000 ns;-- even parity
			rx_data_in <= '1';
			wait for 104000 ns ; --stop 
			rx_data_in <= '1';
			wait for 104000*2 ns ;
			assert ( rx_data_out = "100111010")
			report "data does not match expected"
			severity failure; 
			report "=========================== Test 2 Passed ===========================";
		
		-- Test 3
			report "=========================== Begin Test 3 ===========================";
			report "Test 3: data in = 11101101, parity check = even (bit = 1)";

			rx_data_in <= '0'; --start
			wait for 104000 ns ;--1
			rx_data_in <= '1';
			wait for 104000 ns ;--2
			rx_data_in <= '0';
			wait for 104000 ns ;--3
			rx_data_in <= '1';
			wait for 104000 ns ;--4
			rx_data_in <= '1';
			wait for 104000 ns ;--5
			rx_data_in <= '0';
			wait for 104000 ns;--6
			rx_data_in <= '1';
			wait for 104000 ns ;--7
			rx_data_in <= '1';       
			wait for 104000 ns;--8
			rx_data_in <= '1';
			wait for 104000 ns;--even parity
			rx_data_in <= '1';
			wait for 104000 ns ;--stop 
			rx_data_in <= '1';
			wait for 104000*2 ns ;
			assert ( rx_data_out = "111101101")
			report "data does not match expected"
			severity failure; 
			report "=========================== Test 3 Passed ===========================";
		
		-- Test 4
			report "=========================== Begin Test 4 ===========================";
			report "Test 4: data in = 00000000, parity check = even (bit = 1)";
			rx_data_in <= '0'; --start
			wait for 104000 ns ;--1
			rx_data_in <= '0';
			wait for 104000 ns ;--2
			rx_data_in <= '0';
			wait for 104000 ns ;--3
			rx_data_in <= '0';
			wait for 104000 ns ;--4
			rx_data_in <= '0';
			wait for 104000 ns ;--5
			rx_data_in <= '0';
			wait for 104000 ns;--6
			rx_data_in <= '0';
			wait for 104000 ns ;--7
			rx_data_in <= '0';       
			wait for 104000 ns;--8
			rx_data_in <= '0';
			wait for 104000 ns;--even parity
			rx_data_in <= '1';
			wait for 104000 ns ; --stop 
			rx_data_in <= '1';
			wait for 104000*2 ns ;
			assert ( rx_data_out = "100000000")
			report "data does not match expected"
			severity failure; 
			report "=========================== Test 4 Passed ===========================";
		
		-- Test 5
			report "=========================== Begin Test 5 ===========================";
			report "Test 5: data in = 11111111, parity check = even (bit = 1)";
			rx_data_in <= '0'; --start
			wait for 104000 ns ;--1
			rx_data_in <= '1';
			wait for 104000 ns ;--2
			rx_data_in <= '1';
			wait for 104000 ns ;--3
			rx_data_in <= '1';
			wait for 104000 ns ;--4
			rx_data_in <= '1';
			wait for 104000 ns ;--5
			rx_data_in <= '1';
			wait for 104000 ns;--6
			rx_data_in <= '1';
			wait for 104000 ns ;--7
			rx_data_in <= '1';       
			wait for 104000 ns;--8
			rx_data_in <= '1';
			wait for 104000 ns;--even parity
			rx_data_in <= '1';
			wait for 104000 ns ; --stop 
			rx_data_in <= '1';
			wait for 104000*2 ns ;
			assert ( rx_data_out = "111111111")
			report "data does not match expected"
			severity failure; 
			report "=========================== Test 5 Passed ===========================";

		-- Test 6
			report "=========================== Begin Test 6 ===========================";
			report "Test 6: data in = 00100110, parity check = odd (bit = 0)";
			rx_data_in <= '0'; --start
			wait for 104000 ns ;--1
			rx_data_in <= '0';
			wait for 104000 ns ;--2
			rx_data_in <= '1';
			wait for 104000 ns ;--3
			rx_data_in <= '1';
			wait for 104000 ns ;--4
			rx_data_in <= '0';
			wait for 104000 ns ;--5
			rx_data_in <= '0';
			wait for 104000 ns;--6
			rx_data_in <= '1';
			wait for 104000 ns ;--7
			rx_data_in <= '0';       
			wait for 104000 ns;--8
			rx_data_in <= '0';
			wait for 104000 ns;--odd parity
			rx_data_in <= '0';
			wait for 104000 ns ; --stop 
			rx_data_in <= '1';
			wait for 104000*2 ns ;
			assert ( rx_data_out = "000100110")
			report "data does not match expected"
			severity failure; 
			report "=========================== Test 6 Passed ===========================";
		
		-- Test 7
			report "=========================== Begin Test 7 ===========================";
			report "Test 7: data in = 00000111, parity check = odd (bit = 0)";
			rx_data_in <= '0'; --start
			wait for 104000 ns ;--1
			rx_data_in <= '1';
			wait for 104000 ns ;--2
			rx_data_in <= '1';
			wait for 104000 ns ;--3
			rx_data_in <= '1';
			wait for 104000 ns ;--4
			rx_data_in <= '0';
			wait for 104000 ns ;--5
			rx_data_in <= '0';
			wait for 104000 ns;--6
			rx_data_in <= '0';
			wait for 104000 ns ;--7
			rx_data_in <= '0';       
			wait for 104000 ns;--8
			rx_data_in <= '0';
			wait for 104000 ns;--odd parity
			rx_data_in <= '0';
			wait for 104000 ns ; --stop 
			rx_data_in <= '1';
			wait for 104000*2 ns ;
			assert ( rx_data_out = "000000111")
			report "data does not match expected"
			severity failure; 
			report "=========================== Test 7 Passed ===========================";

		-- Test 8
			report "=========================== Begin Test 8 ===========================";
			report "Test 8: data in = 10101010, parity check = even (bit = 1)";
			rx_data_in <= '0'; --start
			wait for 104000 ns ;--1
			rx_data_in <= '0';
			wait for 104000 ns ;--2
			rx_data_in <= '1';
			wait for 104000 ns ;--3
			rx_data_in <= '0';
			wait for 104000 ns ;--4
			rx_data_in <= '1';
			wait for 104000 ns ;--5
			rx_data_in <= '0';
			wait for 104000 ns;--6
			rx_data_in <= '1';
			wait for 104000 ns ;--7
			rx_data_in <= '0';       
			wait for 104000 ns;--8
			rx_data_in <= '1';
			wait for 104000 ns;--even parity
			rx_data_in <= '1';
			wait for 104000 ns ; --stop 
			rx_data_in <= '1';
			wait for 104000*2 ns ;
			assert ( rx_data_out = "110101010")
			report "data does not match expected"
			severity failure; 
			report "=========================== Test 8 Passed ===========================";
			
		-- Test 9
			report "=========================== Begin Test 9 ===========================";
			report "Test 9: data in = 11110000, parity check = even (bit = 1)";
			rx_data_in <= '0'; --start
			wait for 104000 ns ;--1
			rx_data_in <= '0';
			wait for 104000 ns ;--2
			rx_data_in <= '0';
			wait for 104000 ns ;--3
			rx_data_in <= '0';
			wait for 104000 ns ;--4
			rx_data_in <= '0';
			wait for 104000 ns ;--5
			rx_data_in <= '1';
			wait for 104000 ns;--6
			rx_data_in <= '1';
			wait for 104000 ns ;--7
			rx_data_in <= '1';       
			wait for 104000 ns;--8
			rx_data_in <= '1';
			wait for 104000 ns;--even parity
			rx_data_in <= '1';
			wait for 104000 ns ; --stop 
			rx_data_in <= '1';
			wait for 104000*2 ns ;
			assert ( rx_data_out = "111110000")
			report "data does not match expected"
			severity failure; 
			report "=========================== Test 9 Passed ===========================";
			
		-- Test 10
			report "=========================== Begin Test 10 ===========================";
			report "Test 10: data in = 01011100, parity check = odd (bit = 0)";
			rx_data_in <= '0'; --start
			wait for 104000 ns ;--1
			rx_data_in <= '0';
			wait for 104000 ns ;--2
			rx_data_in <= '0';
			wait for 104000 ns ;--3
			rx_data_in <= '1';
			wait for 104000 ns ;--4
			rx_data_in <= '1';
			wait for 104000 ns ;--5
			rx_data_in <= '1';
			wait for 104000 ns;--6
			rx_data_in <= '0';
			wait for 104000 ns ;--7
			rx_data_in <= '1';       
			wait for 104000 ns;--8
			rx_data_in <= '0';
			wait for 104000 ns;--odd parity
			rx_data_in <= '0';
			wait for 104000 ns ; --stop 
			rx_data_in <= '1';
			wait for 104000*2 ns ;
			assert ( rx_data_out = "001011100")
			report "data does not match expected"
			severity failure; 
			report "=========================== Test 10 Passed ===========================";


			report "========================== ALL TESTS PASSED ==========================";


		finish;
	end process;

end architecture;