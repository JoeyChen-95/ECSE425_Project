LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.memory_arbiter_lib.ALL;

ENTITY WB IS
  PORT (
    clk : IN STD_LOGIC; -- clock
    n_reset : IN STD_LOGIC; --reset
    --Input
    mem_WB_enable : IN STD_LOGIC;
    mem_WB_address : IN STD_LOGIC_VECTOR (4 DOWNTO 0); -- This 31 should be modified to reg_adrsize
    mem_WB_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

    --Output
    WB_enable_out : OUT STD_LOGIC;
    WB_address_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0); -- This 31 should be modified to reg_adrsize
    WB_data_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    WB_forwarding_data : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
  );
END ENTITY;

ARCHITECTURE behavior OF WB IS
BEGIN
  PROCESS (clk, n_reset)
  BEGIN
    IF (rising_edge(clk)) THEN
      WB_enable_out <= mem_WB_enable;
      WB_address_out <= mem_WB_address;
      WB_data_out <= mem_WB_data;
      WB_forwarding_data <= mem_WB_data;
    END IF;
  END PROCESS;
END behavior;