library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY ALU_tb is
end ALU_tb;

ARCHITECTURE ALU_testbench OF ALU_tb is

	COMPONENT ALU is
    port (
      ALU_clock: in std_logic;
--       ALU_reset: in std_logic;
--       ALU_stall: in std_logic;
      ALU_RS: in std_logic_vector(31 downto 0);
      ALU_RT_or_immediate: in std_logic_vector(31 downto 0);
      ALU_operand_code: in std_logic_vector(5 downto 0);
      ALU_result_out: out std_logic_vector(31 downto 0) 
  	);    
    END COMPONENT;
    
    -- test signals
    signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
	signal ALU_RS: std_logic_vector(31 downto 0);
    signal ALU_RT_or_immediate: std_logic_vector(31 downto 0);
    signal ALU_result_out: std_logic_vector(31 downto 0);
    signal ALU_operand_code : std_logic_vector(5 downto 0);
     
begin 
	
  ALU_test: ALU 
  ---------Port Map of ALU ---------
  port map(
      ALU_clock => clk,
      ALU_RS => ALU_RS,
      ALU_RT_or_immediate => ALU_RT_or_immediate,
      ALU_result_out => ALU_result_out,
      ALU_operand_code => ALU_operand_code
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
	
    -- test add
  	wait for clk_period;
    ALU_RS <= x"00000001";
    ALU_RT_or_immediate <= x"00000002";
    ALU_operand_code <= "000000";
    wait for clk_period;
    report to_string(ALU_result_out) severity note;
    
    -- test sub
  	wait for clk_period;
    ALU_RS <= x"00000003";
    ALU_RT_or_immediate <= x"00000002";
    ALU_operand_code <= "000001";
    wait for clk_period;
    report to_string(ALU_result_out) severity note;
    
    -- test addi
  	wait for clk_period;
    ALU_RS <= x"00000001";
    ALU_RT_or_immediate <= x"00001111";
    ALU_operand_code <= "000010";
    wait for clk_period;
    report to_string(ALU_result_out) severity note;    
    
    -- test mul
  	wait for clk_period;
    ALU_RS <= x"00000123"; --291
    ALU_RT_or_immediate <= x"00000234"; --564
    ALU_operand_code <= "000011";
    wait for clk_period;
    -- should be 164124, 101000000100011100
    report to_string(ALU_result_out) severity note;   
    
    -- test div
  	wait for clk_period;
    ALU_RS <= x"0002811c";--164124
    ALU_RT_or_immediate <= x"00000123"; --291
    ALU_operand_code <= "000100";
    wait for clk_period;
    -- should be 564, 1000110100
    report to_string(ALU_result_out) severity note;
    
    -- test slt
  	wait for clk_period;
    ALU_RS <= x"00000001";
    ALU_RT_or_immediate <= x"00001111";
    ALU_operand_code <= "000010";
    wait for clk_period;
    report to_string(ALU_result_out) severity note; 
    
    -- test slt
  	wait for clk_period;
    ALU_RS <= x"00000001";
    ALU_RT_or_immediate <= x"00001111";
    ALU_operand_code <= "000010";
    wait for clk_period;
    report to_string(ALU_result_out) severity note; 
    

  end process;

end architecture ;