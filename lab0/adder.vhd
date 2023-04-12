library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity adder is
	port(
		SW	: in std_logic_vector(7 downto 0);
		LEDR	: out std_logic_vector(3 downto 0)
	);
end entity;

architecture rtl of adder is
begin
	LEDR <= SW(3 downto 0) + SW(7 downto 4);
end rtl;