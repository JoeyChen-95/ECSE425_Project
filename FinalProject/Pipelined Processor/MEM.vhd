library IEEE;
use IEEE.std_logic_1164.all;
-- use work.memory_arbiter_lib.all;
use ieee.numeric_std.all;
library work;
use work.all;
-- register ports: listed below 
-- 2 address ports and 2 outputs port
-- 3 write ports: write in; write enable and write address
-- also clock and reset signals.
-- then outputs: destination; ALU; memory; register; storeen; loaden.

entity MEM is
  port(
  -- Input, connect outputs values
  -- oscillates between a high and a low state
  
  --From Controller
  clk: in std_logic;
  
  reset: in std_logic;
  
  data_in_forward: in std_logic_vector(31 downto 0); -- 
  
  forward_select: in std_logic; -- Original: data_in_selected
  
  --From EX
  in_data: in std_logic_vector(31 downto 0); -- connect ex_mem_data_out
  
  in_address: in std_logic_vector(31 downto 0); -- connect ex_ALU_result_out
  
  access_memory_write: in std_logic; -- connect register out
  
  access_memory_load: in std_logic; -- connect storeen out

  access_reg_address_add_in: in std_logic_vector(4 downto 0); -- connect with ex)dest_regadd_out 
  
  access_reg_address_in: in std_logic; -- connect ex_reg_en_out
  -- eight bits
  
  -- Output 
  
  -- TO WB
  out_data: out std_logic_vector(31 downto 0):= (others=> 'Z');
  access_reg_out: out std_logic;
  access_reg_add_out: out std_logic_vector (4 downto 0);
  );
end MEM;

architecture behavior of MEM is

signal memory_in_address: INTEGER RANGE 0 TO 8191; 
signal memory_write_data:std_logic_vector (31 downto 0); -- this is the input data of data_memory
signal memory_out_data:std_logic_vector (31 downto 0); -- this is the output data of data_memory
-- signal memory_waitrequest: std_logic;
signal null_signal: std_logic;

begin
  memorydata: entity data_memory 
  PORT MAP (
  clock=>clk,
  reset=>reset,
  writedata=>memory_write_data,
  address=>memory_in_address,
  memwrite=>access_memory_write,
  memread=>access_memory_load, -- useless signal
  readdata=>memory_out_data
  );
-- decide which data to write in
-- write 1.forwarding data or 2. normal in data
with forward_select select memory_write_data <=
data_in_forward when '1',
in_data when others;

--decide the write in address 
with access_memory_load select memory_in_address <=
to_integer(unsigned(in_address)) when '1',
0 when others;
-- memory_in_address <= to_integer(unsigned(in_address)) when (access_memory_load='1') 
-- else (OTHERS => 1);

process(clk,reset)
begin
  if(rising_edge(clk)) then
  report to_string(to_integer(unsigned(in_address)));
  access_reg_out<=access_reg_address_in; --just send to WB stage 
  access_reg_add_out<=access_reg_address_add_in; -- just send to WB stage
  	if(access_memory_load='1') then  
  		out_data<=memory_out_data;
    	else
    	out_data<=std_logic_vector(to_unsigned(0,32));
  	end if;
  end if;
end process; 



end behavior;
