library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- a mux that has 4 inputs and 2 control signals
entity mux_4 is
	Port ( 
      mux_4_select_0 : in  STD_LOGIC; --select signal 0
      mux_4_select_1 : in  STD_LOGIC; --select signal 1
      mux_4_input_0   : in  STD_LOGIC_VECTOR (31 downto 0); -- input 0
      mux_4_input_1   : in  STD_LOGIC_VECTOR (31 downto 0); -- input 1
      mux_4_input_2   : in  STD_LOGIC_VECTOR (31 downto 0); -- input 2
      mux_4_input_3   : in  STD_LOGIC_VECTOR (31 downto 0); -- input 3
      mux_4_output   : out STD_LOGIC_VECTOR (31 downto 0)   -- output
    );
end mux_4;

architecture mux_4_architecture of mux_4 is
  	signal mux_4_control : std_logic_vector(1 downto 0) ;
begin
    mux_4_control <= mux_4_select_1 & mux_4_select_0;
    with mux_4_control select mux_4_output <= 
      mux_4_input_0 when "00",
      mux_4_input_1 when "01",
      mux_4_input_2 when "10",
      mux_4_input_3 when "11",
      (others => '0') when others;
end architecture ;
