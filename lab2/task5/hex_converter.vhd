LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY hex_converter IS
    PORT ( num  : IN UNSIGNED(11 DOWNTO 0);
           s1, s2, s3, s4 : out UNSIGNED(3 DOWNTO 0));
END hex_converter;

ARCHITECTURE Behavioral OF hex_converter IS
    SIGNAL number : INTEGER;
BEGIN

    number <= TO_INTEGER(num);
    s1 <= TO_UNSIGNED(((number/1000) mod 10),4);-- 1000 multiple digit
    s2 <= TO_UNSIGNED(((number/100) mod 10),4);--100 multiple  digit
    s3 <= TO_UNSIGNED(((number/10) mod 10),4);--10 mutiple digit
    s4 <= TO_UNSIGNED(((number/1) mod 10),4);--1 multiple digit
	 
END Behavioral;