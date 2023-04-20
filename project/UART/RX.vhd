library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** --
-- 	Author: Samin Moradkhan 															--
-- 																								--
-- 	This file contains the reciever code for the UART communication		-- 
-- 	Modification from Initial Design													--
--			1. Parity Check ODD 																--
-- 				ODD ones in binary: 		parity_bit = 0								--
-- 				EVEN ones in binary: 	partiy_bit = 1								--
-- 																								--
-- ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** --

-- Receiver  Entity
entity RX is 
	-- Constants
	generic(
		baud_rate	: integer := 41667						   -- Baud Rate = 50 MHz / 9600 Baud Rate
	);
	-- Ports
	port(
		clk 			: in std_logic; 
		resetn 		: in std_logic; 							-- Reset 		[ASYNCHRONOUS]
		rx_data_in	: in std_logic; 							-- Serial Data IN
		rx_data_out	: out std_logic_vector(8 downto 0); -- 8-bit Data OUT
		rx_busy 		: out std_logic; 							-- Busy Signal [HANDSHAKING]
		rx_done 		: out std_logic;							-- Done Signal [HANDSHAKING]
		rx_err		: out std_logic);							-- Error Signal [Error Detection]			
end RX; 

-- Receiver Architecture
architecture behaviour of RX is 
	-- Definition: FSM States
	type state_type is (idle_state, start_state, busy_state,parity_state, stop_state); 
	signal current_state: state_type := idle_state; 
	-- Definition: FSM Signal
	signal temp_data: std_logic_vector(8  downto 0):= (others=>'0');	-- Temporary 9-bit Databus 				  [Initialized to 0]
	signal baud_count : integer range 0 to 41666 :=0;						-- Baud Rate = 50 MHz / 9600 Baud Rate   [Initialized to 0]
	signal index: integer range 0 to 8 :=0; 									-- Count for Receiving bits Serially  	  [Initialized to 0]
	signal parity_count:unsigned (3 downto 0) :="0000";					-- Parity Checking Opertation Vector

	
begin

	-- 1. Receiver FSM Process
	UART_RX_FSM : process(clk, resetn)
		begin
		-- A. Asynchronous Reset
		if (resetn ='0') then 
			-- Reset Transmitter Signals:
			rx_busy <= '0';
			rx_done <= '0';
			index <= 0; 
			baud_count <= 0; 
			parity_count <= (others => '0');
			temp_data<= (others =>'0'); 	
			-- Move to Idle State:
			current_state <= idle_state;
		
		-- B. Synchronous FSM
		elsif rising_edge(clk) then
		-- FSM State: Idle, Start, Busy, Parity, Stop
			case current_state is 
			-- i. Idle Sate
				when idle_state => 
				-- 1. Output Logic
				-- 	Re-Initialize FSM Signals:
					index <= 0; 
					baud_count <= 0; 
					rx_done <= '0';
					rx_busy <= '0';
					rx_err <= '0'; 
					parity_count <= (others => '0'); 
				-- 2. Next State Logic
					if (rx_data_in ='0') then 
						-- Start Receiving
						current_state<= start_state;
					else 
						-- Stay in Idle
						current_state <= idle_state; 
					end if; 

			-- ii. Start State
				when start_state => 
				-- 1. Next State Logic
					if (baud_count = ((baud_rate - 1) / 2)) then 	-- reached the half of the baud rate 
						-- Waiting for Start Signal to Begin Receiving
						if (rx_data_in = '0') then 
							-- Receive Data Serially
							baud_count <= 0; 
							current_state <= busy_state; 
						else 
							-- Return to Idle
							current_state <= idle_state; 
							end if; 
					else 
						-- Remain in Start
						baud_count <= baud_count + 1; 			-- increment till reached the half of the baud rate 
						current_state <= start_state; 
					end if; 

			-- iii. Busy State
				when busy_state => 
				-- 1. Output Logic
					rx_busy <= '1'; 
					
				-- 2. Next State Logic
					if (baud_count < (baud_rate - 1)) then
						-- Wait for Data Serially
						baud_count <= baud_count + 1;
						current_state <= busy_state; 
					else 
						-- Receive Serial Data
						baud_count <= 0;
						temp_data(index)<= rx_data_in; 
						
						-- Parity Check Operation
						if (rx_data_in = '1' and index < 7)  then 
							parity_count <= parity_count + 1; 
						end if; 

						if (index <= 7) then 
							-- Receive Next Data bit
							index <= index + 1; 
							current_state <= busy_state; 
						else 
							-- Assign Parity Bit
							index <= 0;
							current_state <= parity_state; 
						end if; 
					end if; 
		
			-- -- iv. Parity State
				when parity_state => 
				-- 1. Next State Logic
					current_state <= stop_state;
					
				-- 2. Output Logic
					if (parity_count mod 2 = 1 and temp_data(8)='0') or (parity_count mod 2 = 0 and temp_data(8) = '1') then
					-- tempdata(8) stores the parity bit
					-- Parities match
						rx_err <= '0'; 
					else 
					-- Parities don't match -> error
						rx_err<= '1'; 
					end if;
					
				 
					
			-- v. Stop State
				when stop_state => 
				-- Output Logic & Next STate Logic
					if (baud_count < (baud_rate - 1)) then
						-- Remain in Stop
						baud_count <= baud_count + 1;
						current_state <= stop_state; 
					else 
						if (rx_data_in ='1') then 
						-- Stop bit Received: move ot Idle and Finish Reception
							baud_count <= 0;
							rx_done <= '1'; 
							rx_busy <='0' ; 
							current_state <= idle_state; 
						end if; 
					end if; 
			
			-- iv. Others (Error)
				when others => 
					current_state <= idle_state;
			
			end case;
		end if; 
	end process; 

	-- 2. Assign Output Receiver Data
	rx_data_out <= temp_data(8 downto 0); 

end behaviour; 
