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
      EX_operand_code: in std_logic_vector(5 downto 0);
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

      -- mux select signal
      Rs_mux_select0   : in  STD_LOGIC;
      Rs_mux_select1   : in  STD_LOGIC;
      Rt_mux_select0   : in  STD_LOGIC;
      Rt_mux_select1   : in  STD_LOGIC;

      -- other signal
      mem_data_out:out STD_LOGIC_VECTOR (31 downto 0)
    );    
    END COMPONENT;
    
    -- test signals
    -- clock, reset, stall
    signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
    signal ex_reset: std_logic;
    signal ex_stall: std_logic;    
    -- Rs, Rt, immediate, operand, and data out
	signal  EX_Rs_in: STD_LOGIC_VECTOR (31 downto 0); 
    signal  EX_Rt_in: STD_LOGIC_VECTOR (31 downto 0);
    signal  EX_immediate_value: STD_LOGIC_VECTOR (31 downto 0);
    signal  EX_operand_code: STD_LOGIC_VECTOR (5 downto 0);
	signal  EX_data_out: STD_LOGIC_VECTOR (31 downto 0); 
    -- forwarding data
    signal  ex_forward_data: STD_LOGIC_VECTOR (31 downto 0);
    signal  mem_forward_data: STD_LOGIC_VECTOR (31 downto 0);
    -- signals that will be passed to next stage
    signal WB_enable_in: std_logic; --indicate the write back enable
    signal WB_enable_out: std_logic;
    signal store_enable_in: std_logic; -- indicate the store in mem
    signal store_enable_out: std_logic; 
    signal load_enable_in: std_logic; -- indicate the load in mem
    signal load_enable_out: std_logic;
    signal Rd_in	: STD_LOGIC_VECTOR (4 downto 0); --indicate the Rd
    signal Rd_out	: STD_LOGIC_VECTOR (4 downto 0);
    -- mux select signal
    signal Rs_mux_select0   :  STD_LOGIC;
    signal Rs_mux_select1   :  STD_LOGIC;
    signal Rt_mux_select0   :  STD_LOGIC;
    signal Rt_mux_select1   :  STD_LOGIC;  
    -- other signal
    signal mem_data_out: STD_LOGIC_VECTOR (31 downto 0);
     
begin 

  EX_test: EX 
  ---------Port Map of EX ---------
  port map(
      ex_clock => clk,
      ex_reset => ex_reset,
      ex_stall => ex_stall,
      EX_Rs_in => EX_Rs_in, 
      EX_Rt_in => EX_Rt_in,
      EX_immediate_value => EX_immediate_value,
      EX_operand_code => EX_operand_code,
      EX_data_out => EX_data_out,      
      ex_forward_data => ex_forward_data,
      mem_forward_data => mem_forward_data,
      WB_enable_in => WB_enable_in,
      WB_enable_out => WB_enable_out, 
      store_enable_in => store_enable_in,
      store_enable_out => store_enable_out,
      load_enable_in => load_enable_in,
      load_enable_out => load_enable_out, 
      Rd_in => Rd_in,
      Rd_out => Rd_out, 
      Rs_mux_select0 => Rs_mux_select0,
      Rs_mux_select1 => Rs_mux_select1,
      Rt_mux_select0 => Rt_mux_select0,
      Rt_mux_select1 => Rt_mux_select1,
      mem_data_out => mem_data_out
  );

  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;
  
  test_process : process
  begin
  	
    -- add
    wait for clk_period;
    ex_reset <= '1';
    wait for clk_period;
    
    EX_Rs_in <= x"00000001";
    EX_Rt_in <= x"00000002";
    EX_immediate_value <= x"00000003";
    EX_operand_code <= "000000";
    ex_forward_data <= x"00000004";
    mem_forward_data <= x"00000005";
    WB_enable_in <='0';
    store_enable_in <='0';
    load_enable_in <='0';
    Rd_in <= "00111";
    -- choose ex_forward_data and ex_forward_data
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '0';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '0';
    wait for clk_period;
    -- expect 
    report to_string(EX_data_out) severity note;
    
    
    -- choose ex_forward_data and mem_forward_data
    wait for clk_period;
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '0';
    Rt_mux_select0 <= '1';
    Rt_mux_select1 <= '0';
    wait for clk_period;
    -- expect 
    report to_string(EX_data_out) severity note;
    
    -- choose ex_forward_data and Rt
    wait for clk_period;
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '0';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect 
    report to_string(EX_data_out) severity note;
    
    -- choose ex_forward_data and immediate value
    wait for clk_period;
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '0';
    Rt_mux_select0 <= '1';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect 
    report to_string(EX_data_out) severity note;
    
    
    
    
    
    
  
  
  end process;

end architecture;
