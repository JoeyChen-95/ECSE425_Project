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
	
    -- test add 2ns
  	wait for clk_period;
    ALU_RS <= x"00000001";
    ALU_RT_or_immediate <= x"00000002";
    ALU_operand_code <= "000000";
    wait for clk_period;
    report to_string(ALU_result_out) severity note;
    
    -- test sub 4ns
  	wait for clk_period;
    ALU_RS <= x"00000003";
    ALU_RT_or_immediate <= x"00000002";
    ALU_operand_code <= "000001";
    wait for clk_period;
    report to_string(ALU_result_out) severity note;
    
    -- test addi 6ns
  	wait for clk_period;
    ALU_RS <= x"00000001";
    ALU_RT_or_immediate <= x"00001111";
    ALU_operand_code <= "000010";
    wait for clk_period;
    report to_string(ALU_result_out) severity note;    
    
    -- test mul 8ns
  	wait for clk_period;
    ALU_RS <= x"00000123"; --291
    ALU_RT_or_immediate <= x"00000234"; --564
    ALU_operand_code <= "000011";
    wait for clk_period;
    -- should be 164124, 101000000100011100
    report to_string(ALU_result_out) severity note;   
    
    -- test div 10ns
  	wait for clk_period;
    ALU_RS <= x"0002811c";--164124
    ALU_RT_or_immediate <= x"00000123"; --291
    ALU_operand_code <= "000100";
    wait for clk_period;
    -- should be 564, 1000110100
    report to_string(ALU_result_out) severity note;
    
    -- test slt 1 Rs < Rt 12ns
  	wait for clk_period;
    ALU_RS <= x"00000001";
    ALU_RT_or_immediate <= x"00001111";
    ALU_operand_code <= "000101";
    wait for clk_period;
    --expect 1
    report to_string(ALU_result_out) severity note; 
    
    -- test slt 1 Rs > Rt 14ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "000101";
    wait for clk_period;
    -- expect 0
    report to_string(ALU_result_out) severity note; 
    
    -- test slti 1 Rs < Rt 16ns
  	wait for clk_period;
    ALU_RS <= x"00000001";
    ALU_RT_or_immediate <= x"00001111";
    ALU_operand_code <= "000110";
    wait for clk_period;
    --expect 1
    report to_string(ALU_result_out) severity note; 
    
    -- test slti 1 Rs > Rt 18ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "000110";
    wait for clk_period;
    -- expect 0
    report to_string(ALU_result_out) severity note; 
    
    -- test and 20ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "000111";
    wait for clk_period;
    -- expect 0x00000001
    report to_string(ALU_result_out) severity note; 
    
    -- test or 22ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001000";
    wait for clk_period;
    -- expect 0x00001111
    report to_string(ALU_result_out) severity note; 
    
    -- test nor, 24ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001001";
    wait for clk_period;
    -- expect 11111111111111111110111011101110
    report to_string(ALU_result_out) severity note;
    
    -- test xor, 26ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001010";
    wait for clk_period;
    -- expect 0x00001110
    report to_string(ALU_result_out) severity note;
    
    -- test andi 28ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001011";
    wait for clk_period;
    -- expect 0x00000001
    report to_string(ALU_result_out) severity note; 
    
    -- test ori 30ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001100";
    wait for clk_period;
    -- expect 0x00001111
    report to_string(ALU_result_out) severity note;   
    
    -- test xori 32ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001101";
    wait for clk_period;
    -- expect 0x00001110
    report to_string(ALU_result_out) severity note;  
    
    -- test mfhi 34ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001110";
    wait for clk_period;
    -- expect ??
    report to_string(ALU_result_out) severity note;

    -- test mflo 36ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001111";
    wait for clk_period;
    -- expect ??
    report to_string(ALU_result_out) severity note;
    
    -- test lui 38ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00001f12";
    ALU_operand_code <= "010000";
    wait for clk_period;
    -- expect 00011111000100100000000000000000
    report to_string(ALU_result_out) severity note;    

    -- test sll 40ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010001";
    wait for clk_period;
    -- expect 0x00008888, 00000000000000001000100010001000
    report to_string(ALU_result_out) severity note;
	
    -- test srl 42ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010010";
    wait for clk_period;
    -- expect 0x00000222, 00000000000000000000001000100010
    report to_string(ALU_result_out) severity note;

    -- test sra, start with 0,  44ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010011";
    wait for clk_period;
    -- expect 0x00000222, 00000000000000000000001000100010
    report to_string(ALU_result_out) severity note;
    
    -- test sra, start with 1,  46ns
  	wait for clk_period;
    ALU_RS <= x"90001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010011";
    wait for clk_period;
    -- expect 0xe0000222, 11100000000000000000001000100010 
    report to_string(ALU_result_out) severity note;
    
    -- test lw, 48ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010100";
    wait for clk_period;
    -- expect 0x00001114,  
    report to_string(ALU_result_out) severity note;   
    
    -- test sw, 50ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010101";
    wait for clk_period;
    -- expect 0x00001114
    report to_string(ALU_result_out) severity note;
    
    -- test beq, 52ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010110";
    wait for clk_period;
    -- expect 0x00001114
    report to_string(ALU_result_out) severity note;

    -- test bne, 54ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010111";
    wait for clk_period;
    -- expect 0x00001114
    report to_string(ALU_result_out) severity note;
    
    -- test j, 56ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "011000";
    wait for clk_period;
    -- expect 0x00001111
    report to_string(ALU_result_out) severity note;
    
    -- test jr, 58ns
  	wait for clk_period;
    ALU_RS <= x"00001112";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "011001";
    wait for clk_period;
    -- expect 0x00001112
    report to_string(ALU_result_out) severity note;    

    -- test jal, 60ns
  	wait for clk_period;
    ALU_RS <= x"00001113";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "011010";
    wait for clk_period;
    -- expect 0x00001113
    report to_string(ALU_result_out) severity note;
    

  end process;

end architecture ;