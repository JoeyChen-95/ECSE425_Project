library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is 
  port (
  	-- clock, reset, stall
    ALU_clock: in std_logic;
    ALU_reset: in std_logic;
    ALU_stall: in std_logic;
    
    -- Rs,Rt,operand, output result
    ALU_RS: in std_logic_vector(31 downto 0);
    ALU_RT: in std_logic_vector(31 downto 0);
    ALU_operand_code: in std_logic_vector(4 downto 0);
    ALU_result_out: out std_logic_vector(31 downto 0) ;
    Equal_Boolean: out std_logic --need?
  );

end entity ALU;