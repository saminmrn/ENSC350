library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd is 
	port (CLOCK_50: in std_logic;
			KEY: in std_logic_vector(3 downto 0);
			SW: in std_logic_vector(17 downto 0);
			LCD_RS: out std_logic;
			LCD_ON: out std_logic;
			LCD_RW: out std_logic;
			LCD_EN: out std_logic;
			LCD_BLON: out std_logic;
			LCD_DATA: out std_logic_vector(7 downto 0));
end lcd; 


architecture behaviour of lcd is 

signal data_char :std_logic_vector ( 7 downto 0);
signal data_rs :std_logic :='1'; 
signal sigClock : std_logic:= '0'; 


component clk_divider is 
generic (dw : integer := 25);
	port (inCLOCK: in std_logic;
			outCLOCK: out std_logic); 
end component; 

component fsm is 
	port (clk: in std_logic;
			resetb: in std_logic;
			dir: in std_logic;
			rs: out std_logic;
			data: out std_logic_vector(7 downto 0));
end component; 

begin

	LCD_ON <= '1';
	LCD_BLON <= '1';
	LCD_RW <= '0';
	LCD_EN <=sigCLOCK; 
	LCD_DATA <= data_char;
	

obj1: clk_divider
port map ( inCLOCK => CLOCK_50, outCLOCK => sigClock);

obj2: fsm
port map (clk=> sigClock , resetb=>KEY(3) , dir=>SW(0), rs=>LCD_RS , data=> data_char); 


end behaviour; 
