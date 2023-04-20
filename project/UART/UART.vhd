library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART is 
	    port(
				CLOCK_50 : in std_logic;
				SW: in std_logic_vector(17 downto 0); 
				KEY: in std_logic_vector(3 downto 0) ;
				HEX7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 7
				HEX6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 6
				HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 2
				HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 1
				HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);   -- digit 0
				LEDR: out std_logic_vector(17 downto 0); 
				LEDG: out std_logic_vector(7 downto 0);
				UART_TXD: out std_logic; 
				UART_RXD: in std_logic);
end UART; 

architecture behaviour of UART is

component TX is
		port(clk : in std_logic; 
				resetn : in std_logic; 
				tx_data_in : in std_logic_vector(7 downto 0); 
				tx_start :	in std_logic;
				tx_data_out : out std_logic; 
				tx_busy : out std_logic; 
				tx_done : out std_logic);
end component;

component RX is 
	    port(clk : in std_logic; 
				resetn : in std_logic; 
				rx_data_in: in std_logic; 
				rx_data_out: out std_logic_vector(8 downto 0); 
				rx_busy: out std_logic; 
				rx_done: out std_logic; 
				rx_err: out std_logic);
end component; 

component digit7seg is
		 port(digit: in  std_logic_vector(3 downto 0);  -- number 0 to 0xF
				seg7 : out std_logic_vector(6 downto 0)); -- one per segment	
end component;

component hex_converter IS
    port ( num  : in unsigned(7 DOWNTO 0);
           s0, s1, s2: out unsigned(3 DOWNTO 0));
end component;

-- transmitter signals
signal txD_in : std_logic_vector(7 downto 0);
signal start_tx, busy_tx, done_tx : std_logic := '0';
-- receiver signals
signal rxD_in, busy_rx, done_rx, err_rx :std_logic :='0'; 
signal rxD_out: std_logic_vector(8 downto 0); 
signal hex7_out, hex6_out, hex2_out, hex1_out, hex0_out : std_logic_vector (6 downto 0); 
signal s0, s1, s2 : unsigned (3 downto 0); 

begin
	-- turn off unused LEDG
	LEDG(7) <= '0';
	LEDG(5) <= '0';
	LEDG(4) <= '0';

-- Port Mapping Transmitter Component
    UART_TX : TX
        port map(CLOCK_50, KEY(3), txD_in, start_tx, UART_TXD, busy_tx, done_tx);
    
-- Port Mapping Receiver Component
    UART_RX : RX
        port map(CLOCK_50, KEY(3), UART_RXD, rxD_out, busy_rx, done_rx, err_rx); 
--Port Mapping the Transmitted Value on the HEX display 7 and 6 
	 HEX_7 : digit7seg
		  port map (txD_in( 7 downto 4), hex7_out); 
	 HEX_6 : digit7seg
		  port map (txD_in( 3 downto 0), hex6_out);
--Port Mapping the Recieved Data on the HEX display 2,1 and 0
	HEX_2 : digit7seg
		port map (std_logic_vector(s2), hex2_out);
	HEX_1 : digit7seg
		port map (std_logic_vector(s1), hex1_out);
	HEX_0 : digit7seg
		port map (std_logic_vector(s0), hex0_out);
	
	Decimal : hex_converter 
		port map (unsigned(rxD_out(7 downto 0)) , s0,s1, s2); 
	
process(CLOCK_50, busy_rx, KEY(3), busy_tx, done_tx, done_rx, err_rx, SW, hex6_out, hex7_out)
        begin
        LEDG(7 downto 0)<= (others => '0');
        txD_in <= (others => '0');
        start_tx <= '0';
        LEDR(15 downto 9) <= (others => '0');
        -- Asynchrnous Reset of Displays
        if (KEY(3) = '0') then
            LEDR(17 downto 0) <= (others => '0');
            LEDG(3 downto 0) <= (others => '0');
            -- Asynchrnous Reset of Displays
            HEX2 <= "1000000";
            HEX1 <= "1000000";
            HEX0 <= "1000000";
            HEX7 <= "1000000";
            HEX6 <= "1000000";
        else
            LEDR(16) <= busy_tx;
            LEDG(6) <= done_tx;
            LEDR(17)<= busy_rx; 
            LEDG(1) <= done_rx; 
            LEDG(0) <= err_rx; 
            -- Transmitter Output    
            if(KEY(0) = '0' and busy_tx = '0') then
                txD_in <= SW(15 downto 8);
                start_tx <= '1';
                HEX6<= hex6_out; 
                HEX7<= hex7_out; 
                LEDR(16) <= busy_tx;
                LEDR(17)<= busy_rx;   
            end if;
            -- Receiver Output
            if (falling_edge(busy_rx)) then
                LEDR(8 downto 0) <= rxD_out;
                HEX2 <= hex2_out; 
                HEX1 <= hex1_out; 
                HEX0 <= hex0_out; 
            end if;
        end if;
    end process;

		
end architecture;