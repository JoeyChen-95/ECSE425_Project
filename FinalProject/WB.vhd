library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory_arbiter_lib.all;

entity WB is
  port(
  clk : in std_logic; -- clock
  n_reset: in std_logic; --reset
  --Input
  mem_WB_enable : in std_logic;
  mem_WB_address: in std_logic_vector (4 downto 0); -- This 31 should be modified to reg_adrsize
  mem_WB_data: in std_logic_vector (31 downto 0);
  
  --Output
  WB_enable_out: out std_logic;
  WB_address_out: out std_logic_vector (4 downto 0); -- This 31 should be modified to reg_adrsize
  WB_data_out: out std_logic_vector (31 downto 0); 
  WB_forwarding_data: out std_logic_vector (31 downto 0);
  );
end entity;

architecture behavior of WB is
begin
	process(clk,n_reset)
    begin
    	if(rising_edge(clk)) then
        	WB_enable_out<=mem_WB_enable;
            WB_address_out<=mem_WB_address;
            WB_data_out<=mem_WB_data;
            WB_forwarding_data<=mem_WB_data;
         end if;
    end process;
end behavior;
