LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY hex_converter IS
    PORT ( num  : IN UNSIGNED(7 DOWNTO 0);
           s0, s1, s2: out UNSIGNED(3 DOWNTO 0));
END hex_converter;

ARCHITECTURE Behavioral OF hex_converter IS
    SIGNAL number : INTEGER;
BEGIN

    number <= TO_INTEGER(num);
    s2 <= TO_UNSIGNED(((number/100) mod 10),4);--100 multiple  digit
    s1 <= TO_UNSIGNED(((number/10) mod 10),4);--10 mutiple digit
    s0 <= TO_UNSIGNED(((number/1) mod 10),4);--1 multiple digit
	 
END Behavioral;