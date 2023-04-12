library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is 
	port (clk: in std_logic;
			resetb: in std_logic;
			dir: in std_logic;
			rs: out std_logic;
			data: out std_logic_vector(7 downto 0));
end fsm; 

architecture behaviour of fsm is


Type state_type is (r1,r2,r3,r4,r5,r6,S, A, M, I, N);
signal next_state, current_state : state_type;
signal count :integer range 0 to 22; 
begin
process(current_state, dir)
begin
	case current_state is 
	when r1 => 
		next_state <=r2;
		data <=X"38";
		rs<= '0';
	when r2 =>
		next_state <=r3;
		data <= X"38";
		rs<= '0';
	when r3 => 
		next_state <=r4;
		data <= X"0C";
		rs<= '0';
	when r4 =>
		next_state <=r5;
		data <=  X"01";
		rs<= '0';
	when r5 =>
		next_state <=r6;
		data<= X"06";
		rs<= '0';
	when r6 =>
		next_state <=S;
		data<= X"80";
		rs<= '0';
	when S=>
	data <=X"53";
	rs<= '1';
		if dir='0' then
			next_state <=A;
		else 
			next_state <=N;
		end if; 
	when A=>
	data<=X"41";
	rs<= '1';
		if dir='0' then
			next_state <=M;
		else 
			next_state <=S;
		end if; 
	when M=>
	data <=X"4D";
	rs<= '1';
		if dir='0' then
			next_state <=I;
		else 
			next_state <=A;
		end if; 
	when I=>
	data <= X"49";
	rs<= '1';
		if dir='0' then
			next_state <=N;
		else 
			next_state <=M;
		end if; 
	when N=>
	data <= X"4E";
	rs<= '1';
		if dir='0' then
			next_state <=S;
		else 
			next_state <=I;
		end if; 
	end case; 
		
end process; 

process (clk, resetb)
	begin
	if resetb ='0' then 
		count<=0;
		current_state <= r1; 
	elsif(rising_edge(clk) ) then 
		count <= count +1; 
		if count <=22 then 
			current_state <= next_state;
		elsif count > 22 then
			current_state <= r1;
			count <= 0; 	
		end if; 
			
	end if;
	
end process;



end behaviour; 