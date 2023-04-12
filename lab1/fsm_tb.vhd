LIBRARY ieee;
USE ieee.std_logic_1164.all;

--declare a testbench. Testbench Entity is always empty
ENTITY fsm_tb IS
END fsm_tb;

ARCHITECTURE test of fsm_tb IS
	COMPONENT fsm IS
		PORT(
			clk : IN STD_LOGIC;
			resetb : IN STD_LOGIC;
			dir : IN STD_LOGIC;
			data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			rs : OUT STD_LOGIC
		);
	END COMPONENT;
	
	--for clock generation
	constant clk_hz : integer := 16e8; --f = 166 Mhz clock
	constant clk_period : time := 1 sec / clk_hz; --1/f = T = 6 ns period

	--DUT signals required
	SIGNAL tb_clk : std_logic := '1'; --DUT's clock input. Assign the clock a starting value for Modelsim
	SIGNAL tb_resetb, tb_dir, out_rs : STD_LOGIC; 
	SIGNAL tb_data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	BEGIN
	
		DUT : fsm --declare the device under test (DUT) to be fsm
		PORT MAP(clk => tb_clk, resetb => tb_resetb, dir => tb_dir, rs => out_rs, data => tb_data_out); --map test signals to DUT
		
		--Simple assignment statement that inverts the clock ever clk_period/2 to create 
		--a constant clock signal for our simulations
		tb_clk <= NOT tb_clk after clk_period / 2;
	
	stimulus : process
	BEGIN
		
		tb_resetb <= '1';	-- reset off
		tb_dir <= '0';		-- direction normal
		wait for 20 ns;
		
		tb_resetb <= '0';	-- reset on
		wait for 20 ns;

		tb_resetb <= '1';	-- reset off
		tb_dir <= '1';		-- direction backwards
		wait for 20 ns;

		tb_dir <= '0';		-- direction normal
		wait for 20 ns;

		tb_dir <= '1';		-- direction backwards
		wait for 100 ns;
		
		assert false;
		report "simulation ended" severity failure; --brute force quit so simulation does not run forever
		
		--Note: we can also use "assert" statements to create intelligent testbenches. EX:
		--wait for 20 ns;
		--assert f = '1';  
		--report "f is incorrect. Expected 1 when in1 = 0, in2 = ..." severity failure; 

		--report statements will be output to the Modelsim terminal window during simulation, which can help you 
		--pinpoint the issue in your waveform and design

	END process;
END test;