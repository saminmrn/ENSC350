library ieee;
use ieee.std_logic_1164.all;

entity adder_tb is
end entity;

architecture rtl of adder_tb is
	component adder 
		port(
			SW	: in std_logic_vector(7 downto 0);
			LEDR	: out std_logic_vector(3 downto 0)
		);
	end component;
	signal SW : std_logic_vector(7 downto 0);
	signal LEDR : std_logic_vector(3 downto 0);
begin
	-- instantiate the design-under-test
	dut : adder port map(SW, LEDR);

	process
	begin
		-- reset the inputs to zero
		SW <= "0000" & "0000";
		wait for 10 ns;

		-- try 1 + 1
		SW <= "0001" & "0001";
		wait for 10 ns;

		-- try 2 + 2
		SW <= "0010" & "0010";
		wait for 10 ns;

		-- try 7 + 7
		SW <= "0111" & "0111";
		wait for 10 ns;	
	end process;

end rtl;
