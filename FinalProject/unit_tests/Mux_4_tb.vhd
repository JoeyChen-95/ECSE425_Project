library IEEE;
use IEEE.std_logic_1164.all;

ENTITY Mux_4_tb is
end Mux_4_tb;

ARCHITECTURE mux_4_testbench OF Mux_4_tb is

	COMPONENT mux_4 is
    Port ( 
      mux_4_select_0 : in  STD_LOGIC; --select signal 0
      mux_4_select_1 : in  STD_LOGIC; --select signal 1
      mux_4_input_0   : in  STD_LOGIC_VECTOR (31 downto 0); -- input 0
      mux_4_input_1   : in  STD_LOGIC_VECTOR (31 downto 0); -- input 1
      mux_4_input_2   : in  STD_LOGIC_VECTOR (31 downto 0); -- input 2
      mux_4_input_3   : in  STD_LOGIC_VECTOR (31 downto 0); -- input 3
      mux_4_output   : out STD_LOGIC_VECTOR (31 downto 0)   -- output
    );     
    END COMPONENT;
    
    -- test signals
    signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
    signal mux_4_select_0 : STD_LOGIC;
    signal mux_4_select_1 : STD_LOGIC;
    signal mux_4_input_0   : STD_LOGIC_VECTOR (31 downto 0);
    signal mux_4_input_1   : STD_LOGIC_VECTOR (31 downto 0);
    signal mux_4_input_2   : STD_LOGIC_VECTOR (31 downto 0);
    signal mux_4_input_3   : STD_LOGIC_VECTOR (31 downto 0);
    signal mux_4_output : STD_LOGIC_VECTOR (31 downto 0);
     
begin 
	
  Mux_4_test: mux_4 
  ---------Port Map of mux_4 ---------
  port map(
      mux_4_select_0 => mux_4_select_0,
      mux_4_select_1 => mux_4_select_1,
      mux_4_input_0 => mux_4_input_0,
      mux_4_input_1 => mux_4_input_1,
      mux_4_input_2 => mux_4_input_2,
      mux_4_input_3 => mux_4_input_3,
      mux_4_output => mux_4_output
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
  	
    mux_4_input_0 <= x"00000000";
    mux_4_input_1 <= x"00000001";
    mux_4_input_2 <= x"00000002";
    mux_4_input_3 <= x"00000003";
    
    wait for clk_period;
    mux_4_select_0 <= '0';
    mux_4_select_1 <= '0';
    report to_string(mux_4_output) severity note;
    
    wait for clk_period;
    mux_4_select_0 <= '1';
    mux_4_select_1 <= '0';
    report to_string(mux_4_output) severity note;

    wait for clk_period;
    mux_4_select_0 <= '0';
    mux_4_select_1 <= '1';
    report to_string(mux_4_output) severity note;
    
    wait for clk_period;
    mux_4_select_0 <= '1';
    mux_4_select_1 <= '1';
    report to_string(mux_4_output) severity note;
    
    wait for clk_period;

  end process;

end architecture ;
  
  
