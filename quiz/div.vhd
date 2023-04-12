library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity div is
port(clk, reset: in std_logic;
	  start: in std_logic;
	  dvsr, dvnd: in unsigned(3 downto 0);
	  done_check: out std_logic;
	  quotient, remainder: out unsigned(3 downto 0));
end div;


architecture arch of div is

type state_type is (first,calc,last,finish);
signal current_state, next_state: state_type;

signal dvnd_1_sig, dvnd_1_next: unsigned(7 downto 0);
signal dvnd_2_sig, dvnd_2_next: unsigned(7 downto 0);
signal dvnd_1_tmp: unsigned(7 downto 0);
signal dvsr_sig, dvsr_next: unsigned(7 downto 0);
signal counter_sig, counter_next: integer range 0 to 8;
signal q_bit: std_logic;

begin

process(clk,reset) --next state register 
begin 

	if reset='1' then
		current_state <= first;
		dvnd_1_sig <= (others=>'0');
		dvnd_2_sig <= (others=>'0');
		dvsr_sig <= (others=>'0');
		counter_sig <= 0;
		
	elsif rising_edge(clk) then	
		current_state <= next_state;
		dvnd_1_sig <= dvnd_1_next;
		dvnd_2_sig <= dvnd_2_next;
		dvsr_sig <= dvsr_next;
		counter_sig <= counter_next;
	end if;
end process;


process(dvnd_1_sig, dvsr_sig) --compare the signal and subtract 
begin
	if (dvnd_1_sig < dvsr_sig) then
		dvnd_1_tmp <= dvnd_1_sig;
		q_bit <= '0';
	else
		dvnd_1_tmp <= dvnd_1_sig - dvsr_sig;
		q_bit <= '1';
	end if;
end process;

process(start,dvsr,current_state,counter_sig,counter_next,dvnd_1_sig,dvnd_2_sig,dvsr_sig,dvnd,q_bit,dvnd_1_tmp)
begin
	done_check <= '0';
	counter_next <= counter_sig;
	next_state <= current_state;
	dvsr_next <= dvsr_sig;
	dvnd_1_next <= dvnd_1_sig;
	dvnd_2_next <= dvnd_2_sig;
	
case current_state is

	when first =>
		if start='1' then
			dvnd_1_next <= (others=>'0');
			dvnd_2_next <= "0000" & dvnd; -- dividend with added 0s in front
			dvsr_next <= "0000"& dvsr; -- divisor with added 0s in front
			counter_next <= 8; -- index
			next_state <= calc;
		end if;
		
	when calc =>
		--decrease counter to find the last iteration 
		counter_next <= counter_sig- 1;
		if (counter_next=0) then
			next_state <= last;
		end if;
		-- shift dvnd_1 and dvnd_2 to the left
		dvnd_2_next <= dvnd_2_sig(6 downto 0) & q_bit;
		dvnd_1_next <= dvnd_1_tmp(6 downto 0) & dvnd_2_sig(7);

		
	when last => -- last iteration, no shifting for the dvnd
		dvnd_2_next <= dvnd_2_sig(6 downto 0) & q_bit;
		dvnd_1_next <= dvnd_1_tmp;
		next_state <= finish;
		
	when finish =>
		next_state <= first;
		done_check <= '1';
end case;
end process;


-- output the quitient and remainder in 4 bits
quotient <= dvnd_2_sig (3 downto 0);
remainder <= dvnd_1_sig(3 downto 0);
end arch;