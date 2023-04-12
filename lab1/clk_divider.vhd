LIBRARY ieee;
USE ieee.numeric_std.all; 
USE ieee.std_logic_1164.all;

entity clk_divider is 
generic (dw : integer := 25);

	port (inCLOCK: in std_logic;
			outCLOCK: out std_logic); 
end clk_divider; 


Architecture behaviour of clk_divider is 

signal temp: unsigned (dw-1 downto 0):= (others=> '0'); 

Begin 
process (inCLOCK)

	BEGIN
		if (rising_edge(inCLOCK)) THEN
			temp <= temp+1;

		end if;
	end process;
	
outCLOCK <= temp(dw-1);
end behaviour; 