library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY ALU_tb is
end ALU_tb;

ARCHITECTURE ALU_testbench OF ALU_tb is

	COMPONENT ALU is
    port (
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
    signal ALU_operand_code : std_logic_vector(5 downto 0);
    signal ALU_result_out: std_logic_vector(31 downto 0);
     
begin 
  ALU_test: ALU 
  ---------Port Map of ALU ---------
  port map(
      ALU_RS => ALU_RS,
      ALU_RT_or_immediate => ALU_RT_or_immediate,
      ALU_operand_code => ALU_operand_code,
      ALU_result_out => ALU_result_out
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
    ASSERT ALU_result_out = x"00000003" REPORT "ADD FAILED" SEVERITY error;
    
    -- test sub 4ns
  	wait for clk_period;
    ALU_RS <= x"00000003";
    ALU_RT_or_immediate <= x"00000002";
    ALU_operand_code <= "000001";
    wait for clk_period;
    ASSERT ALU_result_out = x"00000001" REPORT "SUB FAILED" SEVERITY error;

    -- test addi 6ns
  	wait for clk_period;
    ALU_RS <= x"00000001";
    ALU_RT_or_immediate <= x"00001111";
    ALU_operand_code <= "000010";
    wait for clk_period;
	ASSERT ALU_result_out = x"00001112" REPORT "ADDI FAILED" SEVERITY error;
    
    -- test mul 8ns
  	wait for clk_period;
    ALU_RS <= x"00000123"; --291
    ALU_RT_or_immediate <= x"00000234"; --564
    ALU_operand_code <= "000011";
    wait for clk_period;
    -- should be 164124, 101000000100011100
    ASSERT ALU_result_out = x"00000000" REPORT "MUL FAILED" SEVERITY error;   
    
    -- test div 10ns
  	wait for clk_period;
    ALU_RS <= x"0002811c";--164124
    ALU_RT_or_immediate <= x"00000123"; --291
    ALU_operand_code <= "000100";
    wait for clk_period;
    -- should be 564, 1000110100
	ASSERT ALU_result_out = x"00000000" REPORT "DIV FAILED" SEVERITY error; 
    
    -- test slt 1 Rs < Rt 12ns
  	wait for clk_period;
    ALU_RS <= x"00000001";
    ALU_RT_or_immediate <= x"00001111";
    ALU_operand_code <= "000101";
    wait for clk_period;
    --expect 1
    ASSERT ALU_result_out = x"00000001" REPORT "SLT FAILED" SEVERITY error;
    
    -- test slt 1 Rs > Rt 14ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "000101";
    wait for clk_period;
    -- expect 0
    ASSERT ALU_result_out = x"00000000" REPORT "SLT FAILED" SEVERITY error;
     
    -- test slti 1 Rs < Rt 16ns
  	wait for clk_period;
    ALU_RS <= x"00000001";
    ALU_RT_or_immediate <= x"00001111";
    ALU_operand_code <= "000110";
    wait for clk_period;
    --expect 1
    ASSERT ALU_result_out = x"00000001" REPORT "SLTI FAILED" SEVERITY error;
    
    -- test slti 1 Rs > Rt 18ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "000110";
    wait for clk_period;
    -- expect 0
    ASSERT ALU_result_out = x"00000000" REPORT "SLTI FAILED" SEVERITY error; 
    
    -- test and 20ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "000111";
    wait for clk_period;
    -- expect 0x00000001
    ASSERT ALU_result_out = x"00000001" REPORT "AND FAILED" SEVERITY error;
    
    -- test or 22ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001000";
    wait for clk_period;
    -- expect 0x00001111
	ASSERT ALU_result_out = x"00001111" REPORT "OR FAILED" SEVERITY error;
         
    -- test nor, 24ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001001";
    wait for clk_period;
    -- expect 11111111111111111110111011101110
	ASSERT ALU_result_out = x"FFFFEEEE" REPORT "NOR FAILED" SEVERITY error;
  
    -- test xor, 26ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001010";
    wait for clk_period;
    -- expect 0x00001110
    ASSERT ALU_result_out = x"00001110" REPORT "XOR FAILED" SEVERITY error;
  
    -- test andi 28ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001011";
    wait for clk_period;
    -- expect 0x00000001
    ASSERT ALU_result_out = x"00000001" REPORT "ANDI FAILED" SEVERITY error;
  
    -- test ori 30ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001100";
    wait for clk_period;
    -- expect 0x00001111
    ASSERT ALU_result_out = x"00001111" REPORT "ORI FAILED" SEVERITY error;
  
    -- test xori 32ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001101";
    wait for clk_period;
    -- expect 0x00001110
    ASSERT ALU_result_out = x"00001110" REPORT "XORI FAILED" SEVERITY error;
  
    -- test mfhi 34ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001110";
    wait for clk_period;
    -- expect 0x00000000, DIV HIGH
    ASSERT ALU_result_out = x"00000000" REPORT "MFHI FAILED" SEVERITY error;
  
    -- test mflo 36ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000001";
    ALU_operand_code <= "001111";
    wait for clk_period;
    -- expect 0x00000234, DIV LOW
    ASSERT ALU_result_out = x"00000234" REPORT "MFLO FAILED" SEVERITY error;
  
    -- test lui 38ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00001f12";
    ALU_operand_code <= "010000";
    wait for clk_period;
    -- expect 00011111000100100000000000000000
    ASSERT ALU_result_out = x"1F120000" REPORT "LUI FAILED" SEVERITY error;
  
    -- test sll 40ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010001";
    wait for clk_period;
    -- expect 0x00008888, 00000000000000001000100010001000
    ASSERT ALU_result_out = x"00008888" REPORT "SLL FAILED" SEVERITY error;
  
    -- test srl 42ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010010";
    wait for clk_period;
    -- expect 0x00000222, 00000000000000000000001000100010
    ASSERT ALU_result_out = x"00000222" REPORT "SRL FAILED" SEVERITY error;
  
    -- test sra, start with 0,  44ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010011";
    wait for clk_period;
    -- expect 0x00000222, 00000000000000000000001000100010
    ASSERT ALU_result_out = x"00000222" REPORT "SRA FAILED" SEVERITY error;
  
    -- test sra, start with 1,  46ns
  	wait for clk_period;
    ALU_RS <= x"90001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010011";
    wait for clk_period;
    -- expect 0xe0000222, 11110010000000000000001000100010 
    ASSERT ALU_result_out = x"F2000222" REPORT "SRA FAILED" SEVERITY error;
    
    -- test lw, 48ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010100";
    wait for clk_period;
    -- expect 0x00001114,  
    ASSERT ALU_result_out = x"00001114" REPORT "LW FAILED" SEVERITY error;
  
    -- test sw, 50ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010101";
    wait for clk_period;
    -- expect 0x00001114
    ASSERT ALU_result_out = x"00001114" REPORT "SW FAILED" SEVERITY error;
  
    -- test beq, 52ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010110";
    wait for clk_period;
    -- expect 0x00001114
    ASSERT ALU_result_out = x"00000000" REPORT "BEQ FAILED" SEVERITY error;
  
    -- test bne, 54ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "010111";
    wait for clk_period;
    -- expect 0x00001114
    ASSERT ALU_result_out = x"00000000" REPORT "BNE FAILED" SEVERITY error;
  
    -- test j, 56ns
  	wait for clk_period;
    ALU_RS <= x"00001111";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "011000";
    wait for clk_period;
    -- expect 0x00001111
    ASSERT ALU_result_out = x"00000000" REPORT "J FAILED" SEVERITY error;
  
    -- test jr, 58ns
  	wait for clk_period;
    ALU_RS <= x"00001112";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "011001";
    wait for clk_period;
    -- expect 0x00001112
    ASSERT ALU_result_out = x"00000000" REPORT "JR FAILED" SEVERITY error;
  
    -- test jal, 60ns
  	wait for clk_period;
    ALU_RS <= x"00001113";
    ALU_RT_or_immediate <= x"00000003";
    ALU_operand_code <= "011010";
    wait for clk_period;
    -- expect 0x00001113
    ASSERT ALU_result_out = x"00000000" REPORT "JAL FAILED" SEVERITY error;
    
   WAIT;
  end process;
end architecture;
