LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY WORK;
USE WORK.ALL;


ENTITY div_tb IS
  -- no inputs or outputs
END div_tb;

-- The architecture part decribes the behaviour of the test bench

ARCHITECTURE behavioural OF div_tb IS

    constant clk_hz : integer := 100e6;
    constant clk_period : time := 1 sec / clk_hz;

   -- We will use an array of records to hold a list of test vectors and expected outputs.
   -- This simplifies adding more tests; we just have to add another line in the array.
   -- Each element of the array is a record that corresponds to one test vector.
   
   -- Define the record that describes one test vector
   
   TYPE test_case_record IS RECORD
	  dvnd:      unsigned(3 downto 0);
	  dvsr:      unsigned(3 downto 0); 
	  exp_quotient:  unsigned(3 downto 0);
	  exp_remainder: unsigned(3 downto 0);
   END RECORD;

   -- Define a type that is an array of the record.

   TYPE test_case_array_type IS ARRAY (0 to 20) OF test_case_record;
     
   -- Define the array itself.  We will initialize it, one line per test vector.
   -- If we want to add more tests, or change the tests, we can do it here.
   -- Note that each line of the array is one record, and the 8 numbers in each
   -- line correspond to the 8 entries in the record.  Seven of these entries 
   -- represent inputs to apply, and one represents the expected output.
    
   signal test_case_array : test_case_array_type := (
      ("0000", "0001", to_unsigned(0,4 ), to_unsigned(0,4 )),
      ("0001", "0010", to_unsigned(0,4 ), to_unsigned(1,4 )),
      ("0010", "0011", to_unsigned(0,4 ), to_unsigned(2,4 )),
      ("0011", "0010", to_unsigned(1,4 ), to_unsigned(1,4 )),
      ("0100", "0001", to_unsigned(4,4 ), to_unsigned(0,4 )),
      ("0101", "0010", to_unsigned(2,4 ), to_unsigned(1,4 )),                   
      ("0110", "0010", to_unsigned(3,4 ), to_unsigned(0,4 )),
      ("0111", "0010", to_unsigned(3,4 ), to_unsigned(1,4 )),
      ("1000", "0100", to_unsigned(2,4 ), to_unsigned(0,4 )),
		("1001", "0011", to_unsigned(3,4 ), to_unsigned(0,4 )),
		("1010", "1010", to_unsigned(1,4 ), to_unsigned(0,4 )),
		("1011", "0100", to_unsigned(2,4 ), to_unsigned(3,4 )),
		("1100", "0111", to_unsigned(1,4 ), to_unsigned(5,4 )),
		("1101", "0011", to_unsigned(4,4 ), to_unsigned(1,4 )),
		("1110", "0110", to_unsigned(2,4 ), to_unsigned(2,4 )),
		("1111", "0100", to_unsigned(3,4 ), to_unsigned(3,4 )),
      ("0001", "0100", to_unsigned(0,4 ), to_unsigned(1,4 )),
      ("0010", "0001", to_unsigned(2,4 ), to_unsigned(0,4 )),
      ("0011", "1000", to_unsigned(0,4 ), to_unsigned(3,4 )),
      ("0100", "0010", to_unsigned(2,4 ), to_unsigned(0,4 )),
      ("0101", "0010", to_unsigned(2,4 ), to_unsigned(1,4 ))); 
		  
  -- Define the div subblock, which is the component we are testing

component div is
  port(clk, reset: in std_logic;
  start: in std_logic;
  dvsr, dvnd: in unsigned(3 downto 0);
  done_check: out std_logic;
  quotient, remainder: out unsigned(3 downto 0));
end component;
   -- local signals we will use in the testbench 

	 signal clk:       std_logic := '1'; --in
	 signal reset:     std_logic := '0'; --in
	 signal start:     std_logic := '1'; --in
	 signal done_check: std_logic := '0'; --out
	 signal dvsr:      unsigned(3 downto 0) := "0000" ; --in
	 signal dvnd:      unsigned(3 downto 0) := "0000" ; --in
	 signal quotient:  unsigned(3 downto 0); --out
	 signal remainder: unsigned(3 downto 0); --out

begin

   -- instantiate the design-under-test
	clk <= not clk after clk_period / 2;

   dut : div PORT MAP(
          clk => clk,
          reset => reset,
          start => start,
          dvsr => dvsr,
          dvnd => dvnd,
          done_check => done_check,
          quotient=> quotient,
			 remainder=> remainder);


   -- Code to drive inputs and check outputs.  This is written by one process.
   -- Note there is nothing in the sensitivity list here; this means the process is
   -- executed at time 0.  It would also be restarted immediately after the process
   -- finishes, however, in this case, the process will never finish (because there is
   -- a wait statement at the end of the process).

   process
   begin   
       
      -- Loop through each element in our test case array.  Each element represents
      -- one test case (along with expected outputs).
      
      for i in test_case_array'low to test_case_array'high loop
        
        -- Print information about the testcase to the transcript window (make sure when
        -- you run this, your transcript window is large enough to see what is happening)
        
        report "-------------------------------------------";
        report "Test case " & integer'image(i) & ":" &
                 " divisor = " & integer'image(to_integer(unsigned(test_case_array(i).dvsr))) &
                 " dividend = " & integer'image(to_integer(unsigned(test_case_array(i).dvnd))); 
  
                

        -- assign the values to the inputs of the DUT (design under test)

        dvsr <= test_case_array(i).dvsr; 
        dvnd <= test_case_array(i).dvnd;
 

          
        -- wait for some time, to give the DUT circuit time to respond (1ns is arbitrary)                
         wait until done_check='1'; 
        -- now print the results along with the expected results
        
        report "Expected result for remainder = " &  
                    integer'image(to_integer(unsigned(test_case_array(i).exp_remainder))) &
               "  Actual result for remainder= " &  
                    integer'image(to_integer(unsigned(remainder)));
						  
		  report "Expected result for quotient= " &  
                    integer'image(to_integer(unsigned(test_case_array(i).exp_quotient))) &
               "  Actual result for quotient= " &  
                    integer'image(to_integer(unsigned(quotient)));

        -- This assert statement causes a fatal error if there is a mismatch
                                                                    
        assert (test_case_array(i).exp_quotient = quotient )
            report "MISMATCH.  THERE IS A PROBLEM IN YOUR DESIGN THAT YOU NEED TO FIX"
            severity failure;
				
			assert (test_case_array(i).exp_remainder =remainder )
            report "MISMATCH.  THERE IS A PROBLEM IN YOUR DESIGN THAT YOU NEED TO FIX"
            severity failure;

      
      end loop;
                                           
      report "================== ALL TESTS PASSED =============================";
                                                                              
      wait; --- we are done.  Wait for ever
    end process;
end behavioural;