library IEEE;
use IEEE.std_logic_1164.all;

ENTITY PC_tb is
end PC_tb;

ARCHITECTURE PC_testbench OF PC_tb is

	COMPONENT PC is
    Port ( 
      	pc_clk    : in std_logic;
		pc_enable : in std_logic;
		pc_reset  : in std_logic;
		pc_in     : in std_logic_vector(31 downto 0);
		pc_out    : out std_logic_vector(31 downto 0)
    );     
    END COMPONENT;
    
    -- test signals
    constant clk_period : time := 1 ns;
    signal clk 		: std_logic := '0';
    signal enable_t 	: STD_LOGIC;
    signal reset_t   	: STD_LOGIC;
    signal pc_in_t   	: STD_LOGIC_VECTOR (31 downto 0);
    signal pc_out_t  	: STD_LOGIC_VECTOR (31 downto 0);
     
begin 
	
  PC_test: PC 
  ---------Port Map of mux_4 ---------
  port map(
      pc_clk => clk,
      pc_enable => enable_t,
      pc_reset => reset_t,
      pc_in => pc_in_t,
      pc_out => pc_out_t
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
  	
    pc_in_t <= "00000000000000000000000000010000";
    
    wait for clk_period;
    enable_t <= '0';
    reset_t <= '0';
    report to_string(pc_out_t) severity note;
    
    wait for clk_period;
    enable_t <= '1';
    reset_t <= '0';
    report to_string(pc_out_t) severity note;

    wait for clk_period;
    enable_t <= '0';
    reset_t <= '1';
    report to_string(pc_out_t) severity note;
    
    wait for clk_period;
    pc_in_t <= "00000000000000000000000000000001";
    
    wait for clk_period;
    enable_t <= '1';
    reset_t <= '1';
    report to_string(pc_out_t) severity note;    
    
    wait for clk_period;

  end process;

end architecture ;
  
  
