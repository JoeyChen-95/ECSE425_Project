LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY Comparator_tb is
end Comparator_tb;

ARCHITECTURE Comparator_testbench OF Comparator_tb is

	COMPONENT Comparator is
    Port ( 
        branch_ctl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        reg1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_taken : OUT STD_LOGIC
    );     
    END COMPONENT;
    
    -- test signals
    constant clk_period : time := 1 ns;
    SIGNAL clk		  : STD_LOGIC;
    SIGNAL branch_ctl : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL reg1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL branch_taken : STD_LOGIC;
        
begin 
	
  Comparator_test: Comparator 
  ---------Port Map of Comparator ---------
  port map(
    branch_ctl => branch_ctl,
    reg1 => reg1,
    reg2 => reg2,
    branch_taken => branch_taken
  );
  
  -- Clock process setup
  clk_process : PROCESS
    BEGIN
      	clk <= '1';
    	WAIT FOR clk_period/2;
    	clk <= '0';
  		WAIT FOR clk_period/2;
    END PROCESS;
  
  test_process : process
  begin
	reg1 <= x"00000001";
    reg2 <= x"00000001";
    wait for clk_period;
    
    branch_ctl <= "000";
    wait for clk_period;
	ASSERT branch_taken = '1' REPORT "UNSUCCESSFUL" SEVERITY error;
    
	branch_ctl <= "001";
    wait for clk_period;
	ASSERT branch_taken = '0' REPORT "UNSUCCESSFUL" SEVERITY error;
    
	branch_ctl <= "010";
    wait for clk_period;
	ASSERT branch_taken = '1' REPORT "UNSUCCESSFUL" SEVERITY error;

	branch_ctl <= "011";
    wait for clk_period;
	ASSERT branch_taken = '1' REPORT "UNSUCCESSFUL" SEVERITY error;
        
	branch_ctl <= "100";
    wait for clk_period;
	ASSERT branch_taken = '1' REPORT "UNSUCCESSFUL" SEVERITY error;
        
	branch_ctl <= "101";
    wait for clk_period;
	ASSERT branch_taken = '0' REPORT "UNSUCCESSFUL" SEVERITY error;
        
    reg1 <= x"00000001";
    reg2 <= x"00000002";
    wait for clk_period;
    
    branch_ctl <= "000";
    wait for clk_period;
	ASSERT branch_taken = '0' REPORT "UNSUCCESSFUL" SEVERITY error;
        
	branch_ctl <= "001";
    wait for clk_period;
	ASSERT branch_taken = '1' REPORT "UNSUCCESSFUL" SEVERITY error;
        
	branch_ctl <= "010";
    wait for clk_period;
	ASSERT branch_taken = '1' REPORT "UNSUCCESSFUL" SEVERITY error;
    
	branch_ctl <= "011";
    wait for clk_period;
	ASSERT branch_taken = '1' REPORT "UNSUCCESSFUL" SEVERITY error;
        
	branch_ctl <= "100";
    wait for clk_period;
	ASSERT branch_taken = '1' REPORT "UNSUCCESSFUL" SEVERITY error;
        
	branch_ctl <= "101";
    wait for clk_period;
	ASSERT branch_taken = '0' REPORT "UNSUCCESSFUL" SEVERITY error;
    
    WAIT;
  end process;
end architecture ;
  
  
