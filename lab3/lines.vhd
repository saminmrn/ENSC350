-- this is the entity that uses the Bresenham algorithm to draw the line
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity lines is
	port( clk,rst       	: in  std_logic;
			x0, y0	      : in  signed(8 downto 0);
			x1, y1        	: in  signed(8 downto 0);
			start				: in  std_logic;
			x					: out std_logic_vector(7 downto 0);
			y					: out std_logic_vector(6 downto 0);
			done, plot    	: out std_logic);
end lines;

architecture behaviour of lines is
	-- signals for moving across screen
	signal x_diff, y_diff, dx, dy : signed(8 downto 0); 
	signal move_down, move_right : std_logic; 
	signal plotting : std_logic;
	-- signals for error calculations
	signal err, err_y, err_yx, err2, err_next : signed(9 downto 0); 
	signal x_sig, y_sig, x_new, y_new, x_next, y_next, ddx, ddy : signed(8 downto 0);
	-- states for fsm
	type   states is (idle, plot_state, done_state); 
	signal state : states;
	
begin
	-- datapath: moving right & down and dx & dy
	y_diff <= y1 - y0;
	x_diff <= x1 - x0; 
	move_down <= not y_diff(8);
	move_right <= not x_diff(8); 
	-- -dy when y1 > y0
	dy <= -y_diff when move_down = '1' else y_diff;
	-- -dx when x1 < x0
	dx <= x_diff when move_right = '1' else -x_diff;
	
	-- datapath: y
	ddy <= to_signed(-1, ddy'length) when move_down = '0' else to_signed(1, ddy'length);
	y_new <= (y_sig + ddy) when err2 < dx else y_sig;
	-- local new y signal while in loop
	y_next <= y0 when plotting = '0' else y_new;
	
	-- datapath: X
	ddx <= to_signed(-1, ddx'length) when move_right = '0' else to_signed(1, ddx'length);
	x_new <= (x_sig + ddx) when err2 > dy else x_sig;
	-- local new y signal while in loop
	x_next <= x0 when plotting = '0' else x_new; 

	-- datapath: error
	err_y <= (err + dy) when err2 > dy else err;
	err_yx <= (err_y + dx) when err2 < dx else err_y;
	-- err = dy + dx initially
	err_next <= ("0" & dx) + ("0" & dy) when plotting = '0' else err_yx;
	-- err2 = 2 * err
	err2 <= err(8 downto 0) & "0";
	
	-- fsm
	FSM : process (clk,rst) 
	begin 
		-- asynchronous reset
		if rst = '0' then 
			state <= idle;

		elsif rising_edge(clk) then 
			y_sig <= y_next;
			x_sig <= x_next; 
			err <= err_next; 	
		
			case state is 
				when idle => 
					if start = '1' then 
						state <= plot_state; 
					end if; 
					plotting <= '0'; 
					done <= '0'; 
				
				when plot_state => 
					if (x_sig = x1 and y_sig = y1) then 
						state <= done_state;
					end if;
					-- loop 1 only in plot state
					plotting <= '1'; 
					done <= '0'; 
				
				when done_state => 
					if start = '1' then 
						state <= plot_state;  
					end if; 
					plotting <= '0';
					 -- done 1 only in done state
					done <= '1';
			end case; 
		end if; 
	end process;
	
	-- Output
	plot <= plotting;
	y <= std_logic_vector(y_sig(6 downto 0));
	x <= std_logic_vector(x_sig(7 downto 0));

end behaviour; 