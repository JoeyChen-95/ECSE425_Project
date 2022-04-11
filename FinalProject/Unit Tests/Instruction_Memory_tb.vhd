library IEEE;
use IEEE.std_logic_1164.all;

ENTITY Ins_MEM_tb is
end Ins_MEM_tb;

ARCHITECTURE Ins_MEM_testbench OF Ins_MEM_tb is

	COMPONENT Instruction_Memory is
      PORT (
          clock 	: IN STD_LOGIC;
          reset 	: IN STD_LOGIC;
          address 	: IN INTEGER RANGE 0 TO 1024 - 1;
          memread 	: IN STD_LOGIC;
          readdata 	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
          waitrequest : OUT STD_LOGIC
      );
    END COMPONENT;
    
    -- test signals
    constant clk_period : time := 1 ns;
    signal clk 			: std_logic := '0';
    signal reset 		: STD_LOGIC;
    signal address 		: INTEGER RANGE 0 TO 1024 - 1;
    signal memread 		: STD_LOGIC;
    signal readdata 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal waitrequest 	: STD_LOGIC;
     
begin 
	
  Ins_MEM_test: Instruction_Memory 
  ---------Port Map of Instruction_Memory ---------
  port map(
      clock => clk,
      reset => reset,
      address => address,
      memread => memread,
      readdata => readdata,
      waitrequest => waitrequest
  );
  
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;
  
  
  test_process : process
  begin
	-- Reset
	wait for clk_period;
	reset <= '0';
	wait for clk_period;
	reset <= '1';
    memread <= '0';
	wait for clk_period;
    reset <= '0';
    
    --First Line
    wait for clk_period;
    address <= 0;
    memread <= '1';
    WAIT UNTIL rising_edge(waitrequest);
    ASSERT readdata = x"200A0004" REPORT "INS READ UNSUCESSFUL" SEVERITY error;
    
    wait for clk_period;
    memread <= '0';
    
    --Second Line
    wait for clk_period;
    address <= 1;
    memread <= '1';
    WAIT UNTIL rising_edge(waitrequest);
    ASSERT readdata = x"20010001" REPORT "INS READ UNSUCESSFUL" SEVERITY error;
    
    wait for clk_period;
    memread <= '0';
    
    --Nineth Line
    wait for clk_period;
    address <= 8;
    memread <= '1';
    WAIT UNTIL rising_edge(waitrequest);
    ASSERT readdata = x"14F0018" REPORT "INS READ UNSUCESSFUL" SEVERITY error;
    
    wait for clk_period;
    memread <= '0';

    --Last Line
    wait for clk_period;
    address <= 14;
    memread <= '1';
    WAIT UNTIL rising_edge(waitrequest);
    ASSERT readdata = x"116BFFFF" REPORT "INS READ UNSUCESSFUL" SEVERITY error;
    
    WAIT;
  end process;
end architecture;
  
  
