library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity ksa is
  port(CLOCK_50 : in  std_logic;  -- Clock pin
       KEY : in  std_logic_vector(3 downto 0);  -- push button switches
       SW : in  std_logic_vector(17 downto 0);  -- slider switches
		 LEDG : out std_logic_vector(7 downto 0);  -- green lights
		 LEDR : out std_logic_vector(17 downto 0));  -- red lights
end ksa;

-- Architecture part of the description

architecture rtl of ksa is

   -- Declare the component for the ram.  This should match the entity description 
	-- in the entity created by the megawizard. If you followed the instructions in the 
	-- handout exactly, it should match.  If not, look at s_memory.vhd and make the
	-- changes to the component below
	
   COMPONENT s_memory IS
	   PORT (
		   address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   clock		: IN STD_LOGIC  := '1';
		   data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   wren		: IN STD_LOGIC ;
		   q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
   END component;

	-- Enumerated type for the state variable.  You will likely be adding extra
	-- state names here as you complete your design

	type state_type is (state_init,
							  state_fill,
							  state_read_i,
							  state_read_j,
							  state_write_i,
							  state_write_j,
							  state_wait1,
							  state_wait2,
							  state_wait3,
							  state_done);
								
    -- These are signals that are used to connect to the memory													 
	signal address : STD_LOGIC_VECTOR (7 DOWNTO 0);	 
	signal data : STD_LOGIC_VECTOR (7 DOWNTO 0);
	signal wren : STD_LOGIC;
	signal q : STD_LOGIC_VECTOR (7 DOWNTO 0);	


	signal clk: std_logic;
	signal state: state_type := state_init;
	type secretKeys is array(2 downto 0) of std_logic_vector(7 downto 0);
	signal secret_key : secretKeys;
	
	begin
		-- Include the S memory structurally
		u0: s_memory port map (address, clk, data, wren, q);
		
		clk <= CLOCK_50;
		
		secret_key(0) <= x"03";
		secret_key(1) <= x"5F";
		secret_key(2) <= x"3C";

		
		process(clk)
			variable i, j, temp, temp_si, temp_sj: unsigned(7 downto 0);	
			variable index: integer;
		begin	
			if rising_edge(clk) then
				case state is
				
					when state_init =>
						i := (others => '0');
						wren <= '1';
						address <= std_logic_vector(i);
						data <= std_logic_vector(i);
						state <= state_fill;
					 
					when state_fill =>
						address <= std_logic_vector(i);
						data <= std_logic_vector(i);
						wren <= '1';
						
						if i < 255 then
							i := i + 1;
							state <= state_fill;
						else 
							wren <= '1';
							address <= std_logic_vector(i);
							data <= std_logic_vector(i);
							state <= state_wait1;
						end if;
						
					when state_wait1=>
							
							i := (others => '0');
							j := (others => '0');
							state <= state_read_i;
		
					when state_read_i =>
	
						index := to_integer(i mod 3);
						temp := j + unsigned(secret_key(index));
						wren <= '0';    
						address <= std_logic_vector(i);
						state <= state_wait2;

					when state_wait2 =>
						state <= state_read_j;
						
					when state_read_j =>
						
						temp_si := unsigned(q);
						j := (temp + temp_si);
						wren <= '0';
						address <= std_logic_vector(j);
						state <= state_wait3;
						
					when state_wait3 =>
						state <= state_write_i;

					when state_write_i =>
						
						temp_sj := unsigned(q);
					
						wren <= '1';
						address <= std_logic_vector(i);
						data <= std_logic_vector(temp_sj);
						state <= state_write_j;
							
					when state_write_j =>
					
						wren <= '1';
						address <= std_logic_vector(j);
						data <= std_logic_vector(temp_si);
						
						if i < 255 then
							i := i + 1;
							state <= state_read_i;
						else 
							wren <= '0';
							state <= state_done;
						end if;
						
					when state_done =>
						state <= state_done;
				end case;	 
			end if;
		end process;


end RTL;