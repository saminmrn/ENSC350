LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

----------------------------------------------------------------------
--
--  This is the top level template for Lab 2.  Use the schematic on Page 4
--  of the lab handout to guide you in creating this structural description.
--  The combinational blocks have already been designed in previous tasks,
--  and the spinwheel block is given to you.  Your task is to combine these
--  blocks, as well as add the various registers shown on the schemetic, and
--  wire them up properly.  The result will be a roulette game you can play
--  on your DE2.
--
-----------------------------------------------------------------------

ENTITY roulette IS
	PORT(   CLOCK_50 : IN STD_LOGIC; -- the fast clock for spinning wheel
		KEY : IN STD_LOGIC_VECTOR(3 downto 0);  -- includes slow_clock and reset
		SW : IN STD_LOGIC_VECTOR(17 downto 0);
		LEDG : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);  -- ledg
		HEX7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 7
		HEX6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 6
		HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 5
		HEX4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 4
		HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 3
		HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 2
		HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 1
		HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)   -- digit 0
	);
END roulette;


ARCHITECTURE structural OF roulette IS
 --- Your code goes here
 
 --signals here
 signal spin_result_sig, spin_result_latched_sig, bet1_value_sig  : UNSIGNED(5 downto 0);
 signal bet3_dozen_sig: UNSIGNED(1 downto 0);
 signal bet1_amount, bet2_amount, bet3_amount: UNSIGNED(2 downto 0);
 signal money_sig,new_money_sig: UNSIGNED(11 downto 0);
 signal binary2: UNSIGNED(15 downto 0);
 signal bet1_wins_sig, bet2_wins_sig, bet3_wins_sig, slow_clk, bet2_colour_sig: STD_LOGIC;
 signal s1,s2,s3,s4: UNSIGNED(3 downto 0);
 signal binary1 : UNSIGNED(7 downto 0);
 
 component digit7seg is
	PORT(	digit : IN  UNSIGNED(3 DOWNTO 0);  -- number 0 to 0xF
         seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));  -- one per segment
 end component; 
 
 
 component new_balance IS
	PORT(money : in unsigned(11 downto 0);  -- Current balance before this spin
        value1 : in unsigned(2 downto 0);  -- Value of bet 1
        value2 : in unsigned(2 downto 0);  -- Value of bet 2
        value3 : in unsigned(2 downto 0);  -- Value of bet 3
        bet1_wins : in std_logic;  -- True if bet 1 is a winner
        bet2_wins : in std_logic;  -- True if bet 2 is a winner
        bet3_wins : in std_logic;  -- True if bet 3 is a winner
        new_money : out unsigned(11 downto 0));  -- balance after adding winning                                                -- bets and subtracting losing bets
 END component;
 
 component win IS
	PORT(spin_result_latched : in unsigned(5 downto 0);  -- result of the spin (the winning number)
        bet1_value : in unsigned(5 downto 0); -- value for bet 1
        bet2_colour : in std_logic;  -- colour for bet 2
        bet3_dozen : in unsigned(1 downto 0);  -- dozen for bet 3
        bet1_wins : out std_logic;  -- whether bet 1 is a winner
        bet2_wins : out std_logic;  -- whether bet 2 is a winner
        bet3_wins : out std_logic); -- whether bet 3 is a winner
 END component;
 
 
 component spinwheel IS
	PORT(fast_clock : IN  STD_LOGIC;  -- This will be a 27 Mhz Clock
		  resetb : IN  STD_LOGIC;      -- asynchronous reset
		  spin_result  : OUT UNSIGNED(5 downto 0));  -- current value of the wheel
 END component;
 
 component register_general IS 
	PORT(d   : IN unsigned(11 DOWNTO 0);
		  rst : IN STD_LOGIC;
        clk : IN STD_LOGIC; 
        q   : OUT unsigned(11 DOWNTO 0));
 END component;
 
 component register_12 IS 
	PORT(d   : IN unsigned(11 DOWNTO 0);
     rst : IN STD_LOGIC;
     clk : IN STD_LOGIC; 
     q   : OUT unsigned(11 DOWNTO 0));
 END component;
 
 component debounce is
  generic (timeout_cycles : integer :=20);
  port (clk : in std_logic;
		  button : in std_logic;
		  button_debounced : out std_logic);
 end component;
 
 component hex_converter IS
    port (num  : IN UNSIGNED(11 DOWNTO 0);
          s1, s2, s3, s4 : out UNSIGNED(3 DOWNTO 0));
 end component;
	
begin 

 LEDG(0)<= bet1_wins_sig ; 
 LEDG(1)<= bet2_wins_sig ; 
 LEDG(2)<= bet3_wins_sig ; 
 
 HEX5 <= "1111111";
 HEX4 <= "1111111";

obj1: spinwheel
		port map(fast_clock => CLOCK_50,
		resetb=> KEY(1) ,
		spin_result=> spin_result_sig ); 
		
obj2: debounce
		port map (clk=> CLOCK_50 , 
		button =>NOT KEY(0) , 
		button_debounced =>slow_clk );
		
six_bit_reg1: register_general
		port map (d(5 downto 0) =>spin_result_sig ,
		rst=>KEY(1), 
		clk=>slow_clk, 
		q(5 downto 0)=> spin_result_latched_sig ); 
		
six_bit_reg2: register_general
		port map (d(5 downto 0) =>unsigned(SW(8 downto 3)) ,
		rst=>KEY(1),
		clk=>slow_clk,
		q(5 downto 0)=> bet1_value_sig );
	
one_bit_DFF :register_general
		port map (d(0) =>SW(12), 
		rst=>KEY(1), 
		clk=>slow_clk, 
		q(0)=> bet2_colour_sig );	

two_bit_reg :register_general
		port map (d(1 downto 0) =>unsigned(SW(17 downto 16)) , 
		rst=>KEY(1), 
		clk=>slow_clk, 
		q(1 downto 0)=> bet3_dozen_sig );
		
three_bit_reg1 :register_general
		port map (d(2 downto 0) =>unsigned(SW(2 downto 0)) , 
		rst=>KEY(1), 
		clk=>slow_clk, 
		q(2 downto 0)=> bet1_amount );

three_bit_reg2 :register_general
		port map (d(2 downto 0) =>unsigned(SW(11 downto 9)) , 
		rst=>KEY(1), 
		clk=>slow_clk, 
		q(2 downto 0)=> bet2_amount );

three_bit_reg3 :register_general
		port map (d(2 downto 0) =>unsigned(SW(15 downto 13)) , 
		rst=>KEY(1), 
		clk=>slow_clk, 
		q(2 downto 0)=> bet3_amount );

twelve_bit_reg :register_12
		port map (d =>new_money_sig , 
		rst=>KEY(1), 
		clk=>slow_clk, 
		q=> money_sig );
	
win_block: win 
		port map(spin_result_latched=>spin_result_latched_sig , 
		bet1_value=>bet1_value_sig,  
		bet2_colour=>bet2_colour_sig , 
		bet3_dozen=>bet3_dozen_sig, 
		bet1_wins=>bet1_wins_sig , 
		bet2_wins=>bet2_wins_sig, 
		bet3_wins=> bet3_wins_sig);

new_balance_block:new_balance	
		port map (money => money_sig, 
		value1 =>bet1_amount ,
		value2 =>bet2_amount,
		value3 =>bet3_amount, 
		bet1_wins => bet1_wins_sig ,
		bet2_wins => bet2_wins_sig,
		bet3_wins => bet3_wins_sig,
		new_money => new_money_sig);
		
HEX_3: digit7seg
		port map(digit =>s1 , seg7=>HEX3 );

HEX_2: digit7seg
		port map(digit =>s2 , seg7=>HEX2 );
		
HEX_1: digit7seg
		port map(digit =>s3, seg7=>HEX1 );

HEX_0: digit7seg
		port map(digit =>s4, seg7=>HEX0 );

-- second digit of the rolled number 0-9
HEX_6: digit7seg
		port map(digit =>binary1(3 downto 0) , seg7=>HEX6 );
-- first digit of the rolled number 0-3
HEX_7: digit7seg
		port map(digit =>(binary1(7 downto 4)) , seg7=>HEX7 );
		
BCD1: hex_converter
		port map(num(5 downto 0)=> spin_result_latched_sig, s3=>binary1(7 downto 4) , s4=>binary1(3 downto 0));

--four digit number (		
BCD2: hex_converter
		port map(num=> new_money_sig, s1=>s1, s2=>s2, s3=>s3, s4=>s4);

		

END;
