library IEEE;
use IEEE.std_logic_1164.all;
use work.memory_arbiter_lib.all;
use ieee.numeric_std.all;

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
  
  reset: in std_logic
  
  data_in_forward: in std_logic_vector (31 downto 0); -- 
  
  data_select: in std_logic; -- Original: data_in_selected
  
  --From EX
  in_data: in std_logic_vector (31 downto 0); -- connect ex_mem_data_out
  
  in_address: in std_logic_vector(31 downto 0); -- connect ex_ALU_result_out
  
  access_memory_write: in std_logic; -- connect register out
  
  access_memory_load: in std_logic; -- connect storeen out
  
  byte: in std_logic; -- reset n signal

  access_reg_address_add_in: in std_logic_vector(reg_adrsize-1 downto 0); -- connect with ex)dest_regadd_out 
  
  access_reg_address_in: in std_logic; -- connect ex_reg_en_out
  -- eight bits
  
  -- Output 
  
  -- TO WB
  out_data: out std_logic_vector(31 downto 0):= (others=> 'Z');
  access_reg_out: out std_logic;
  access_reg_add_out: out std_logic_vector (reg_adrsize-1 downto 0)
  );
end entity;

architecture behavior of MEM is

signal temp_address:std_logic_vector (31 downto 0);
signal temp_select_data:std_logic_vector (31 downto 0);
signal temp_data:std_logic_vector (31 downto 0);

begin
  memorydata: entity work.Data_Memory --? what is this; and can below value change?
  PORT MAP (
  byte=>byte,
  clk=>clk,
  n_rst=>reset,
  port_out=>temp_data,
  write_enable=>access_memory_write,
  write_in=>temp_select_data,
  write_adr=>temp_address(31 downto 0),
  port_adr=>temp_address(31 downto 0)
  );

process(clk,reset)
  
begin
  if(rising_edge(clk)) then --?
  access_reg_out<=access_reg_address_in;  
  access_reg_add_out<=access_reg_address_add_in;
  	if(access_memory_load='1') then
  		out_data<=temp_data;
    	else
    	outdata<=inaddress;
  	end if;
  end if;
end process; 

with data_select select temp_select_data <=
data_in_forward when '1',
in_data when others;

temp_address<=in_address when (access_memory_load='1') 
else (OTHERS => '0');

end behavior;
