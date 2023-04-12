-- top level entity for the lab 3 task 4 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab3;

architecture behaviour of lab3 is

	component draw is
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
	end component;

  
	component lines is
		port( clk,rst       	: in  std_logic;
				x0, y0	      : in  signed(8 downto 0);
				x1, y1        	: in  signed(8 downto 0);
				start				: in  std_logic;
				x					: out std_logic_vector(7 downto 0);
				y					: out std_logic_vector(6 downto 0);
				done, plot    	: out std_logic);
	end component;

	component gray is
		port( i 		: in unsigned (3 downto 0); 
				color : out unsigned(2 downto 0));
	end component;
	
	component clk_divider is 
		generic (dw 		: integer := 25);
		port ( inCLOCK		: in std_logic;
				 outCLOCK	: out std_logic); 
	end component; 

	-- signals
	signal x      : std_logic_vector(7 downto 0);
	signal y      : std_logic_vector(6 downto 0);
	signal y0, y1, x0, x1     : std_logic_vector(8 downto 0);
	signal colour : std_logic_vector(2 downto 0);
	signal gray_color: unsigned(2 downto 0); 
	signal clean, clear,plot_sig, rst_sig, done_sig,clk, enable_sig, done_line, plot_start  : std_logic;
	signal i : unsigned(3 downto 0) := to_unsigned(1, 4);
	signal i8: signed(8 downto 0);
	-- states
	type states is (start, drawing, waiting_color, waiting_black, erasing, finished); 
	signal state : states := start;

	begin
	
	-- port mapping
	draw_obj: draw
	port map(clk   	  =>  CLOCK_50,
				rst	 	  => rst_sig,
				x    		  =>x,
				y     	  =>y,
				color  	  =>colour,
				clean 	  => clean, 
				enable 	  => enable_sig,
				vga_r      =>VGA_R,
				vga_g 	  =>VGA_G,
				vga_b  	  =>VGA_B,  -- The outs go to VGA controller
				vga_hs     =>VGA_HS,
				vga_vs     =>VGA_VS,
				vga_blank  =>VGA_BLANK,
				vga_sync   =>VGA_SYNC,
				vga_clk    =>VGA_CLK,
				done_check =>done_sig);

  -- rest of your code goes here, as well as possibly additional files

	line_obj: lines
	port map(clk 	=> CLOCK_50, 
				rst	=> rst_sig, 
				x		=> x, -- 0 to 160 
				y		=> y,  -- 0 to 120
				x0		=> signed(x0),
				y0		=> signed(y0), 
				x1		=> signed(x1), 
				y1		=> signed(y1), 
				start	=> plot_start,
				plot	=> enable_sig,
				done	=> done_line); 
				 
	gray_obj:gray
	port map(i => (i mod 8), 
				color => gray_color);

	clk_obj : clk_divider
	generic map (dw => 27)
	port map(inCLOCK  => CLOCK_50,
				outCLOCK =>clk); 
			
	rst_sig <= KEY(3);
	
	colour <= std_logic_vector(gray_color) when (clear='0') else "000";
	i8 <= "00" & signed(i) & "000"; -- i * 8
	
	x0 <= std_logic_vector(to_signed(0, 9));
	x1 <= std_logic_vector(to_signed(159,9));
	y0 <= std_logic_vector(i8);
	y1 <= std_logic_vector(to_signed(120, y1'length) - i8);
		
		
FSM: process (clk, rst_sig, state, done_line,plot_start, i, clean)
	begin
	if rst_sig = '0' then
			i <= to_unsigned(1,4);
			state <= start;
			clean <= '1'; 
			
	elsif rising_edge(clk) then
			if done_sig='1' then 
				state <= start;
				clean <= '0'; 
			end if; 

			case state is
				when start =>
					state <= drawing;
					clear <='0'; 
	
				when drawing =>
					state <= waiting_color;
					plot_start <= '1';
					
				when waiting_color =>
					plot_start <= '0';
					if done_line = '1'  then
						state <= erasing;
						plot_start <= '1';
					else
						state <= waiting_color;
					end if;
				
				when erasing =>
					clear <= '1'; 
					state <= waiting_black;
					if done_line = '1' then
						clear <='0'; 
						if i = to_unsigned(12, 4) then
							state <= finished;
						end if; 
					end if;
				
				when waiting_black => 
					plot_start <= '0';
					if done_line = '1' then
						clear <='0'; 
						state <= drawing;
						i <= i + 1;
						plot_start <= '1';
					else
						state <= waiting_black;
					end if; 

				when finished =>
					if plot_start = '1' then
						i <= to_unsigned(1, 4);
						state <= drawing;
					else
						state <= start;
					end if;		
			end case;
		end if;
	end process;
	
end behaviour;


