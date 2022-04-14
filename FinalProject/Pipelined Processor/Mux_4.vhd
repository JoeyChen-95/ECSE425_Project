LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- a mux that has 4 inputs and 2 control signals
ENTITY mux_4 IS
  PORT (
    mux_4_select_0 : IN STD_LOGIC; --select signal 0
    mux_4_select_1 : IN STD_LOGIC; --select signal 1
    mux_4_input_0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- input 0
    mux_4_input_1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- input 1
    mux_4_input_2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- input 2
    mux_4_input_3 : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- input 3
    mux_4_output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0) -- output
  );
END mux_4;

ARCHITECTURE mux_4_architecture OF mux_4 IS
  SIGNAL mux_4_control : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
  mux_4_control <= mux_4_select_1 & mux_4_select_0;
  WITH mux_4_control SELECT mux_4_output <=
    mux_4_input_0 WHEN "00",
    mux_4_input_1 WHEN "01",
    mux_4_input_2 WHEN "10",
    mux_4_input_3 WHEN "11",
    (OTHERS => '0') WHEN OTHERS;
END ARCHITECTURE;