-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity EX is
  port(
    -- clock, reset, stall
    ex_clock   : in  std_logic;
    ex_reset: in std_logic;
    ex_stall: in std_logic;

    Rs_in  : in  STD_LOGIC_VECTOR (31 downto 0); --Rs
    Rt_in   : in  STD_LOGIC_VECTOR (31 downto 0); --Rt
    immediate_value   : in  STD_LOGIC_VECTOR (31 downto 0); --immediate value
    operand_code: in std_logic_vector(4 downto 0);
    ex_data_out   : out  STD_LOGIC_VECTOR (31 downto 0); -- result of ALU

    -- forwarding data
    alu_result_in: in STD_LOGIC_VECTOR (31 downto 0); --data from EX stage
    mem_forward_data: in std_logic_vector (31 downto 0); --data from memory stage

    -- pass the data that will be used in later stages forward
    WB_enable_in: in std_logic; --indicate the write back enable
    WB_enable_out: out std_logic;
    store_enable_in: in std_logic; -- indicate the store in mem
    store_enable_out: out std_logic; 
    load_enable_in: in std_logic; -- indicate the load in mem
    load_enable_out: out std_logic;
    Rd_in	: in STD_LOGIC_VECTOR (4 downto 0); --indicate the Rd
    Rd_out	: out STD_LOGIC_VECTOR (4 downto 0);
    byte_in:in std_logic; --what??
    byte_out:out std_logic;

    -- mux select signal
    Rs_mux_select0   : in  STD_LOGIC;
    Rs_mux_select1   : in  STD_LOGIC;
    Rt_mux_select0   : in  STD_LOGIC;
    Rt_mux_select0   : in  STD_LOGIC;

    -- other signal
    mem_data_out:out STD_LOGIC_VECTOR (31 downto 0);
  );

end EX;

