--this file writes the gray code algorithm for the colors
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gray is

port( i : in unsigned (3 downto 0);
		color : out unsigned(2 downto 0));
end gray;

architecture behaviour of gray is 
begin 

with i select 
	color <= "000" when "0000",
				"001" when "0001",
				"011" when "0010",
				"010" when "0011",
				"110" when "0100",
				"111" when "0101",
				"101" when "0110",
				"100" when "0111",
				"---" when others;		

end behaviour; 