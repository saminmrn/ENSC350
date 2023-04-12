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
	
	COMPONENT d_memory IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END component;
	
	
	COMPONENT en_memory IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END component;

	-- Enumerated type for the state variable.  You will likely be adding extra
	-- state names here as you complete your design

	type state_type is (state_init,
							  state_fill,
							  state_read_i,
							  state_read_j,
							  state_write_i,
							  state_write_j,
							  state_wait,
							  state_start,
							  state_read_i_task2b,
							  state_read_j_task2b,
							  state_read_f_task2b,
							  state_write_decryp_task2b,
							  state_done);
								
    -- These are signals that are used to connect to the memory S													 
	signal address_s : STD_LOGIC_VECTOR (7 DOWNTO 0);	 
	signal data_s : STD_LOGIC_VECTOR (7 DOWNTO 0);
	signal wren_s : STD_LOGIC;
	signal q_s : STD_LOGIC_VECTOR (7 DOWNTO 0);	

	 -- These are signals that are used to connect to the memory Decrypted 	
	signal address_d : STD_LOGIC_VECTOR (4 DOWNTO 0);	 
	signal data_d : STD_LOGIC_VECTOR (7 DOWNTO 0);
	signal wren_d : STD_LOGIC;
	signal q_d : STD_LOGIC_VECTOR (7 DOWNTO 0);

	 -- These are signals that are used to connect to the memory Encrypted ROM
	signal address_en : STD_LOGIC_VECTOR (4 DOWNTO 0);	 
	signal q_en : STD_LOGIC_VECTOR (7 DOWNTO 0);	

	signal clk: std_logic;
	signal state, next_state: state_type := state_init;
	type secretKeys is array(2 downto 0) of std_logic_vector(7 downto 0);
	signal secret_key : secretKeys;
	signal task_2b:std_logic; 
	
	begin
		-- Include the S memory structurally
		u0: s_memory port map (address_s, clk, data_s, wren_s, q_s);
		u1: d_memory port map (address_d, clk, data_d, wren_d, q_d);
		u2: en_memory port map (address_en, clk, q_en);
		
		clk <= CLOCK_50;
		
		secret_key(0) <= x"03";
		secret_key(1) <= x"5F";
		secret_key(2) <= x"3C";

		
		process(clk)
			variable i, j, temp, temp_si, temp_sj, temp_f, temp_enc_k: unsigned(7 downto 0);	
			variable k : unsigned (4 downto 0) ; -- 0 to 31
			variable index: integer;
		begin	
			if rising_edge(clk) then
				case state is
				
					when state_init =>
						i := (others => '0');
						wren_s <= '1';
						address_s <= std_logic_vector(i);
						data_s <= std_logic_vector(i);
						state <= state_fill;
					 
					when state_fill =>
						address_s <= std_logic_vector(i);
						data_s <= std_logic_vector(i);
						wren_s <= '1';
						
						if i < 255 then
							i := i + 1;
							state <= state_fill;
						else 
							wren_s <= '1';
							address_s <= std_logic_vector(i);
							data_s <= std_logic_vector(i);
							state<= state_start;
							
						end if;
						
					when state_start=> 
						i := (others => '0');
						j := (others => '0');
						task_2b <= '0'; 
						state<= state_read_i; 
		
					when state_read_i =>
	
						index := to_integer(i mod 3);
						temp := j + unsigned(secret_key(index));
						wren_s <= '0';    
						address_s <= std_logic_vector(i);
						state <= state_wait;
						next_state <= state_read_j;
					-- need an extra cycle after each read
					when state_wait =>
						state <= next_state;
						
					when state_read_j =>
						
						temp_si := unsigned(q_s);
						j := (temp + temp_si);
						wren_s <= '0';
						address_s <= std_logic_vector(j);
						state <= state_wait; 
						next_state <= state_write_i;


					when state_write_i =>
						
						temp_sj := unsigned(q_s);
					
						wren_s <= '1';
						address_s <= std_logic_vector(i);
						data_s <= std_logic_vector(temp_sj);
						state <= state_write_j;
							
					when state_write_j =>
					
						wren_s <= '1';
						address_s <= std_logic_vector(j);
						data_s <= std_logic_vector(temp_si);
						if task_2b = '0' then 
						
							if i < 255 then
								i := i + 1;
								state <= state_read_i;
							else 
								--wren_s <= '0';
								--state <= state_done;
								task_2b <='1'; 
								temp_si := (others => '0');
								temp_sj := (others => '0');
								temp_si := (others => '0');
								temp_f:=(others => '0');
								temp_enc_k :=(others => '0');
								i:= (others => '0'); 
								j:= (others => '0'); 
								k:= (others => '0');
								state <= state_read_i_task2b;
							end if;
						
						elsif task_2b ='1' then 
							state <= state_read_f_task2b; 
						else 
							state<= state_done; 
						end if; 
						
					when state_read_i_task2b=> 
						wren_d <='0'; 
						i:= i+1;
						wren_s <= '0'; 
						address_s<= std_logic_vector(i); 
						state<= state_wait; 
						next_state<= state_read_j_task2b;
						
					when state_read_j_task2b=> 
					
						temp_si:= unsigned(q_s); 
						j:= j+temp_si; 
						wren_s<= '0'; 
						address_s <= std_logic_vector(j); 
						state<= state_wait; 
						-- use the previous swap states for task 2b 
						next_state<= state_write_i;
						
					when state_read_f_task2b => 
						wren_s <= '0'; 
						address_s<= std_logic_vector(temp_si + temp_sj);
						address_en <=  std_logic_vector(k);
						state <= state_wait; 
						next_state<= state_write_decryp_task2b;
						
						
					when  state_write_decryp_task2b => 
						temp_f := unsigned(q_s);
						temp_enc_k := unsigned(q_en); 
						wren_d <='1'; 
						address_d <= std_logic_vector(k);
						data_d <= std_logic_vector(temp_f xor temp_enc_k );
						if (k < 31 ) then 
							k:= k+1; 
							state<=  state_read_i_task2b; 
						else 
							state <= state_done;
						end if; 	
						
					when state_done =>
						wren_s <='0'; 
						wren_d <= '0'; 
						state <= state_done;
				end case;	 
			end if;
		end process;


end RTL;