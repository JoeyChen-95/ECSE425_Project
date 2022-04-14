LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.ALL;

ENTITY MEM IS
  PORT (
    --From Controller
    dump : IN STD_LOGIC;
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    data_forward : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

    --From EX
    mem_in_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- connect ex_mem_data_out
    in_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- connect ex_ALU_result_out
    write_enable : IN STD_LOGIC; -- connect register out
    load_enable : IN STD_LOGIC;
    dest_reg : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- connect with ex)dest_regadd_out 
    enable_writeback : IN STD_LOGIC; -- connect ex_reg_en_out

    -- TO WB
    out_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    wb_enable : OUT STD_LOGIC;
    wb_dest_reg : OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
  );
END MEM;

ARCHITECTURE behavior OF MEM IS

  SIGNAL memory_out_data : STD_LOGIC_VECTOR (31 DOWNTO 0); -- the data which we read from data_memory

BEGIN
  DM : ENTITY work.Data_Memory
    PORT MAP(
      dump => dump,
      clock => clk,
      reset => reset,
      writedata => mem_in_data,
      address => to_integer(unsigned(in_address)),
      memwrite => write_enable,
      readdata => memory_out_data
    );

  out_data <= memory_out_data WHEN load_enable = '1' ELSE
    in_address;

  -- For forwarding.
  data_forward <= in_address;

  -- Copy and send to WB
  wb_enable <= enable_writeback; --just send to WB stage 
  wb_dest_reg <= dest_reg; -- just send to WB stage
END behavior;