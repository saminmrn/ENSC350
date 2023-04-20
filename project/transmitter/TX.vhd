library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** --
-- 	Author: Rose Epstein																	--
-- 																								--
-- 	This file contains the transmitter code for the UART communication	-- 
-- 	Modification from Initial Design													--
--			1. Parity Check ODD 																--
-- 				ODD ones in binary: 		parity_bit = 0								--
-- 				EVEN ones in binary: 	partiy_bit = 1								--
-- 																								--
-- ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** --

-- Transmitter Entity
entity TX is 
	-- Constants
	generic(
		baud_rate	: integer := 41667					   -- Baud Rate = 50 MHz / 9600 Baud Rate
		);
	-- Ports
	port(
		clk 			: 	in std_logic; 
		resetn 		: 	in std_logic; 							-- Reset 		[ASYNCHRONOUS]
		tx_data_in 	: 	in std_logic_vector(7 downto 0); -- 8-bit Data IN
		tx_start 	:	in std_logic;							-- Start Input for Transmission
		tx_data_out : 	out std_logic; 						-- Serial Data OUT
		tx_busy 		: 	out std_logic; 						-- Busy Signal [HANDSHAKING]
		tx_done 		: 	out std_logic							-- Done Signal [HANDSHAKING]
	);
end TX;

-- Transmitter Architecture
architecture behaviour of TX is
	-- Definition: FSM States
   type state_type is (idle_state, start_state, busy_state, parity_state, stop_state);
   signal current_state : state_type := idle_state;
    
   -- Definition: FSM Signal
   signal temp_data : std_logic_vector(7 downto 0) := (others => '0');	-- Temporary 8-bit Databus 				  [Initialized to 0]
   signal baud_count : integer range 0 to (baud_rate - 1) := 0;			-- Baud Rate = 50 MHz / 9600 Baud Rate   [Initialized to 0]
   signal index : integer range 0 to 7 := 0;										-- Count for Transmitting bits Serially  [Initialized to 0]
   signal parity : std_logic := '0'; 												-- Parity Check: ODD [low] EVEN [high]   [Initialized to 0]
   signal parity_vector : std_logic_vector(5 downto 0); 						-- Parity Checking Opertation Vector
	
begin

	-- 1. Parity Check Operation ODD [Combinational]
	--		ODD Parity
	--		ODD ones in binary: 		parity_bit = 0
	-- 	EVEN ones in binary: 	partiy_bit = 1	
	parity_vector(0) <= tx_data_in(0) xor tx_data_in(1);
	parity_vector(1) <= parity_vector(0) xor tx_data_in(2);
	parity_vector(2) <= parity_vector(1) xor tx_data_in(3);
	parity_vector(3) <= parity_vector(2) xor tx_data_in(4);
	parity_vector(4) <= parity_vector(3) xor tx_data_in(5);
	parity_vector(5) <= parity_vector(4) xor tx_data_in(6);
	parity <= NOT(parity_vector(5) xor tx_data_in(7));
    
	-- 2. Transmittion FSM Process
	Uart_TX_FSM: process(clk, resetn)
		begin
		-- A. Asynchronous Reset
		if (resetn = '0') then
			-- Reset Transmitter Signals & Inactivate Transmission:
			baud_count <= 0;
			index <= 0;
			tx_busy <= '0';
			tx_done <= '0';
			tx_data_out <= '1';	-- Inactivating Transmission
			temp_data <= (others => '0');
			-- Move to Idle State:
			current_state <= idle_state;
			
		-- B. Synchronous FSM
		elsif (rising_edge(clk)) then
		-- FSM State: Idle, Start, Busy, Parity, Stop
			case current_state is
			-- i. Idle Sate
				when idle_state =>
				-- 1. Output Logic
				-- 	Re-Initialize FSM Signals & Inactivate Transmission:
					baud_count <= 0;
					index <= 0;
					tx_busy <= '0';
					tx_done <= '0';
					tx_data_out <= '1';	-- Inactivating Transmission
					temp_data <= (others => '0');
					
				-- 2. Next State Logic
					if (tx_start = '1') then
						-- Begin Transmission
						temp_data <= tx_data_in; -- input data
						current_state <= start_state;
					else
						-- Remain in Idle
						current_state <= idle_state;
					end if;
					
			-- ii. Start State
				when start_state =>
				-- 1. Output Logic
					tx_data_out <= '0'; 	-- start bit
					tx_busy <= '1';		-- activate busy signal [HANDSHAKING]
				
				-- 2. Next State Logic
					if (baud_count < baud_rate - 1) then
						-- Remain in Start
						baud_count <= baud_count + 1;
						current_state <= start_state;
					else
						-- Send Data Serially
						baud_count <= 0;
						current_state <= busy_state;
					end if;
					
			-- iii. Busy State
				when busy_state =>
				-- 1. Output Logic
					tx_data_out <= temp_data(index); -- Send Data Serially

				-- 2. Next State Logic
					if (baud_count < baud_rate - 1) then
						-- Send Parity Bit
						baud_count <= baud_count + 1;
						current_state <= busy_state;
					else
						-- Send Remaining Serial Data, then Send Parity Bit
						baud_count <= 0;
						if (index < 7) then
							-- Send Remaining Serial Data
							index <= index + 1;
							current_state <= busy_state;
						else
							-- Send Parity Bit
							index <= 0;
							current_state <= parity_state;
						end if;
					end if;
					
			-- iv. Parity State
			when parity_state =>
			-- 1. Output Logic
				tx_data_out <= parity;
			--2. Next State Logic
				if (baud_count < baud_rate - 1) then
					-- Remain in Parity
					baud_count <= baud_count + 1;
					current_state <= parity_state;
				else
					-- Stop Transmission
					baud_count <= 0;
					current_state <= stop_state;
				end if;
				
			-- v. Stop State
				when stop_state =>
				-- 1. Output Logic
					tx_data_out <= '1';	-- Transmission Done
					
				-- 2. Next State Logic
				if (baud_count < baud_rate - 1) then
					-- Remain in Stop
					baud_count <= baud_count + 1;
					current_state <= stop_state;
				else
					-- Return to Idle and Finish Transmission
					tx_busy <= '0';
					tx_done <= '1';
					current_state <= idle_state;
				end if;
		
		-- vi. Others (Error)
			when others =>
				current_state <= idle_state;
			
			end case;
		end if;
	end process;

	end behaviour;