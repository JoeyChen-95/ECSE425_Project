library IEEE;
use IEEE.std_logic_1164.all;
USE ieee.numeric_std.ALL;

ENTITY FETCH_tb is
end FETCH_tb;

ARCHITECTURE PC_testbench OF FETCH_tb is

	COMPONENT FETCH is
    Port ( 
      	pc_clk    : in std_logic;
		pc_reset  : in std_logic;
		pc_in     : in std_logic_vector(31 downto 0);
		pc_out    : out std_logic_vector(31 downto 0);
        instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    );     
    END COMPONENT;
    
    -- test signals
    constant clk_period : time := 1 ns;
    signal clk 		: std_logic := '0';
    signal reset_t   	: STD_LOGIC;
    signal pc_in_t   	: STD_LOGIC_VECTOR (31 downto 0);
    signal pc_out_t  	: STD_LOGIC_VECTOR (31 downto 0);
    signal instruction : STD_LOGIC_VECTOR (31 downto 0);
     
begin 
	
  PC_test: FETCH 
  ---------Port Map of PC ---------
  port map(
      pc_clk => clk,
      pc_reset => reset_t,
      pc_in => pc_in_t,
      pc_out => pc_out_t,
      instruction => instruction
  );
  
  
  clk_process : process
  begin
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
  end process;
  
  
  test_process : process
  begin	
    reset_t <= '0';
    wait for clk_period;
    
    reset_t <= '1';
    wait for clk_period;
    
    reset_t <= '0';
    wait for clk_period;
  
    pc_in_t <= "00000000000000000000000000001110";
    wait for clk_period;
    report to_string(pc_out_t) severity note;
    
    pc_in_t <= "00000000000000000000000000010000";
    wait for clk_period;
    report to_string(pc_out_t) severity note;
    
    wait for clk_period;
    pc_in_t <= "00000000000000000000000000000001";
    
    wait for clk_period;
    report to_string(pc_out_t) severity note;
    
    wait for clk_period;

  end process;

end architecture ;
  
  
