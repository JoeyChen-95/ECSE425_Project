library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY EX_tb is
end EX_tb;

architecture EX_testbench OF EX_tb is

	COMPONENT EX is
    port(
    -- clock, reset, stall
    ex_clock: in std_logic;
    ex_reset: in std_logic;
    ex_stall: in std_logic;

    EX_Rs_in  : in  STD_LOGIC_VECTOR (31 downto 0); --Rs
    EX_Rt_in   : in  STD_LOGIC_VECTOR (31 downto 0); --Rt
    EX_immediate_value   : in  STD_LOGIC_VECTOR (31 downto 0); --immediate value
    EX_operand_code: in std_logic_vector(4 downto 0);
    EX_data_out   : out  STD_LOGIC_VECTOR (31 downto 0); -- result of ALU

    -- forwarding data
    ex_forward_data: in STD_LOGIC_VECTOR (31 downto 0); --data from EX stage
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
    mem_data_out:out STD_LOGIC_VECTOR (31 downto 0)
    );    
    END COMPONENT;
    
    -- test signals
    signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;

     
begin 

  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;
  
  test_process : process
  begin
  
  end process;

end architecture;
