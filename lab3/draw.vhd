-- this file contains the vga adapter component which draws the lines to the screen 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity draw is
	port( clk   			: in  std_logic;
			rst	 			: in 	std_logic;
			x     			: in  std_logic_vector(7 downto 0);
			y     			: in  std_logic_vector(6 downto 0);
			color 			: in  std_logic_vector(2 downto 0);
			enable			: in  std_logic; 
			clean				: in  std_logic;
			vga_r 			: out std_logic_vector(9 downto 0);
			vga_g 			: out std_logic_vector(9 downto 0); 
			vga_b 			: out std_logic_vector(9 downto 0); 
			vga_hs    		: out std_logic;
			vga_vs    		: out std_logic;
			vga_blank 		: out std_logic;
			vga_sync  		: out std_logic;
			vga_clk   		: out std_logic;
			done_check		: out std_logic);
end draw;

architecture behaviour of draw is
	--Component from the Verilog file: vga_adapter.v
	component vga_adapter
		generic(RESOLUTION : string);
		port (resetn,clock,plot                            : in  std_logic;
				colour                                       : in  std_logic_vector(2 downto 0);
				x                                            : in  std_logic_vector(7 downto 0);
				y                                            : in  std_logic_vector(6 downto 0);
				VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
				VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
	end component;

	--signals 
	signal x_sig, x_sig_next :std_logic_vector(7 downto 0); --std_logic_vector(7 downto 0);
	signal y_sig, y_sig_next :std_logic_vector(6 downto 0);--std_logic_vector(6 downto 0);
	signal color_sig : std_logic_vector(2 downto 0);
	signal plot_sig: std_logic;
	-- states
	type state_type is (start, plot_x, plot_y, done);
	signal state: state_type;

	begin 

	obj: vga_adapter
		generic map(RESOLUTION => "160x120") 
		port map(resetn    => rst,
					clock     => clk,
					colour    => color_sig,
					x         => x_sig,
					y         => y_sig,
					plot      => plot_sig,
					VGA_R     => vga_r,
					VGA_G     => vga_g,
					VGA_B     => vga_b,
					VGA_HS    => vga_hs,
					VGA_VS    => vga_vs,
					VGA_BLANK => vga_blank,
					VGA_SYNC  => vga_sync,
					VGA_CLK   => vga_clk);
		
	process (clk,rst)
	begin
		
		if rst ='0' then
			state <= start; 
			
		elsif rising_edge(clk) and clean ='1' then	
			color_sig <= "000";
			
			case state is 
				when start => 
					x_sig <= (others => '0');
					y_sig <=  (others => '0');
					state <= plot_x;
					plot_sig <= '0'; 
						
				when plot_x => 
					plot_sig <= '1'; 
					x_sig <= x_sig + 1; 
					state <= plot_y; 
					if x_sig = 159 then 
						state <= done; 
					end if; 

				when plot_y =>
					plot_sig <= '1'; 
					y_sig <= y_sig + 1;
					if (y_sig < 119) then
						state <= plot_y; 
					else 
						state <= plot_x;
						y_sig <= (others => '0');
					end if;
				
				when done =>
					state <= done; 
					done_check <= '1'; 
			end case; 
			
		elsif (rising_edge(clk)) then 
			  x_sig <= x; 
			  y_sig <= y;
			  color_sig <= color; 
			  plot_sig <= enable; 
			
		end if; 
	end process; 

end behaviour; 