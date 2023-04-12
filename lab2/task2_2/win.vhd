LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

--------------------------------------------------------------
--
--  This is a skeleton you can use for the win subblock.  This block determines
--  whether each of the 3 bets is a winner.  As described in the lab
--  handout, the first bet is a "straight-up" bet, teh second bet is 
--  a colour bet, and the third bet is a "dozen" bet.
--
--  This should be a purely combinational block.  There is no clock.
--  Remember the rules associated with Pattern 1 in the lectures.
--
---------------------------------------------------------------

ENTITY win IS
	PORT(spin_result_latched : in unsigned(5 downto 0);  -- result of the spin (the winning number)
             bet1_value : in unsigned(5 downto 0); -- value for bet 1
             bet2_colour : in std_logic;  -- colour for bet 2
             bet3_dozen : in unsigned(1 downto 0);  -- dozen for bet 3
             bet1_wins : out std_logic;  -- whether bet 1 is a winner
             bet2_wins : out std_logic;  -- whether bet 2 is a winner
             bet3_wins : out std_logic); -- whether bet 3 is a winner
END win;


ARCHITECTURE behavioural OF win IS
--  Your code goes here


BEGIN

--bet1 is correct
process(bet1_value,spin_result_latched)
begin

	if (bet1_value= spin_result_latched) then 
		bet1_wins<='1'; 
	else 
		bet1_wins <= '0';
	end if; 
		
end process; 


process (bet2_colour,spin_result_latched) --1: red, 0 :black
begin

-- 1 to 10 odd is red or 20 to 28 odd is red
	if((spin_result_latched >= x"1" and spin_result_latched <= x"A")) or ((spin_result_latched >= x"13" and spin_result_latched <= x"1C")) then		
		if (spin_result_latched (0) = '0' and bet2_colour= '0' )then --even and black
			bet2_wins <= '1'; 
		elsif (spin_result_latched (0) = '1' and bet2_colour= '1' )then --odd and red
			bet2_wins <= '1'; 
		else 
			bet2_wins <= '0'; 
		end if; 
			
-- 11 to 19 even is red or 29 to 36 even is red
	elsif ((spin_result_latched >= x"B" and spin_result_latched <=x"12") or (spin_result_latched >= x"1D" and spin_result_latched <=x"24"))then 
			
		if (spin_result_latched (0) = '0' and bet2_colour= '1' )then --even and red
			bet2_wins <= '1'; 
		elsif (spin_result_latched (0) = '1' and bet2_colour= '0' )then --odd and black
			bet2_wins <= '1'; 
		else 
			bet2_wins <= '0'; 
		end if; 
		
	else 
		bet2_wins <= '0'; 

end if; 

end process; 


process(bet3_dozen,spin_result_latched )
begin 
	if (bet3_dozen= "00") then
		if ((spin_result_latched >= x"1") and (spin_result_latched <= x"B"))then --btw 1 to 12
			bet3_wins <= '1'; 
		else 
			bet3_wins <= '0'; 
		end if; 
		
	elsif (bet3_dozen= "01") then
	
		if ((spin_result_latched >= x"c") and (spin_result_latched <= x"18"))then --btw 13 to 24
			bet3_wins <= '1'; 
		else 
			bet3_wins <= '0'; 
		end if; 
	elsif (bet3_dozen= "10") then 
	
		if ((spin_result_latched >= x"19") and (spin_result_latched <= x"24"))then --btw 25 to 36
			bet3_wins <= '1'; 
		else 
			bet3_wins <= '0'; 
		end if;
		
	elsif (bet3_dozen= "11") then 
		bet3_wins <= '0';
	end if; 
	
	

end process; 

END;
