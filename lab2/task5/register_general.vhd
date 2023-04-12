LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

ENTITY register_general IS 
PORT(d   : IN unsigned(11 DOWNTO 0);
     rst : IN STD_LOGIC;
     clk : IN STD_LOGIC; 
     q   : OUT unsigned(11 DOWNTO 0));
END register_general;

ARCHITECTURE behavior OF register_general IS

BEGIN
    process(clk, rst)
    begin
        if rst = '0' then
            q <= x"000";
        elsif rising_edge(clk) then
            q <= d;
        end if;
    end process;
END behavior;