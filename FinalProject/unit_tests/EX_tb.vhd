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
  	
--------------------------- add -------------------------------------
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
    -- expect x"00000008" 3ns
    report to_string(EX_data_out) severity note;    
    
    -- choose ex_forward_data and mem_forward_data
    wait for clk_period;
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '0';
    Rt_mux_select0 <= '1';
    Rt_mux_select1 <= '0';
    wait for clk_period;
    -- expect x"00000009" 5ns
    report to_string(EX_data_out) severity note;
    
    -- choose ex_forward_data and Rt
    wait for clk_period;
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '0';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect  x"00000006" 7ns
    report to_string(EX_data_out) severity note;
    
    -- choose mem_forward_data and ex_forward_data
    wait for clk_period;
    Rs_mux_select0 <= '1';
    Rs_mux_select1 <= '0';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '0';
    wait for clk_period;
    -- expect x"00000009" 9ns
    report to_string(EX_data_out) severity note;

    -- choose mem_forward_data and mem_forward_data
    wait for clk_period;
    Rs_mux_select0 <= '1';
    Rs_mux_select1 <= '0';
    Rt_mux_select0 <= '1';
    Rt_mux_select1 <= '0';
    wait for clk_period;
    -- expect x"0000000a" 11ns
    report to_string(EX_data_out) severity note;
    
    -- choose mem_forward_data and temp_EX_Rt
    wait for clk_period;
    Rs_mux_select0 <= '1';
    Rs_mux_select1 <= '0';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect x"00000007" 13ns
    report to_string(EX_data_out) severity note;        
    
    -- choose temp_EX_Rs and ex_forward_data
    wait for clk_period;
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '0';
    wait for clk_period;
    -- expect x"00000005" 15ns
    report to_string(EX_data_out) severity note;    

    -- choose temp_EX_Rs and mem_forward_data
    wait for clk_period;
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '1';
    Rt_mux_select1 <= '0';
    wait for clk_period;
    -- expect x"00000006" 17ns
    report to_string(EX_data_out) severity note;  
    
    -- choose temp_EX_Rs and temp_EX_Rt
    wait for clk_period;
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect x"00000003" 19ns
    report to_string(EX_data_out) severity note;   
    
    -- choose 0 and ex_forward_data
    wait for clk_period;
    Rs_mux_select0 <= '1';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '0';
    wait for clk_period;
    -- expect x"00000004" 21ns
    report to_string(EX_data_out) severity note;    

    -- choose 0 and mem_forward_data
    wait for clk_period;
    Rs_mux_select0 <= '1';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '1';
    Rt_mux_select1 <= '0';
    wait for clk_period;
    -- expect x"00000005" 23ns
    report to_string(EX_data_out) severity note;  
    
    -- choose 0 and temp_EX_Rt
    wait for clk_period;
    Rs_mux_select0 <= '1';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect x"00000002" 25ns
    report to_string(EX_data_out) severity note;     
    
--------------------------- add -------------------------------------

--------------------------- sub -------------------------------------
    wait for clk_period;
    ex_reset <= '1';
    wait for clk_period;
    
    EX_Rs_in <= x"00000005";
    EX_Rt_in <= x"00000004";
    EX_immediate_value <= x"00000003";
    EX_operand_code <= "000001";
    ex_forward_data <= x"00000002";
    mem_forward_data <= x"00000001";
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
    -- expect x"00000000" 28ns
    report to_string(EX_data_out) severity note;

    -- choose Rs and Rt
    wait for clk_period;
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect x"00000001" 30ns
    report to_string(EX_data_out) severity note; 
    
    -- choose mem_forward_data and Rt
    wait for clk_period;
    Rs_mux_select0 <= '1';
    Rs_mux_select1 <= '0';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect -3, x"fffffffd" 32ns
    report to_string(EX_data_out) severity note;   
    
--------------------------- sub -------------------------------------

--------------------------- mul -------------------------------------
    wait for clk_period;
    ex_reset <= '1';
    wait for clk_period;
    
    EX_Rs_in <= x"00000005";
    EX_Rt_in <= x"00000004";
    EX_immediate_value <= x"09999999";
    EX_operand_code <= "000011";
    ex_forward_data <= x"00000002";
    mem_forward_data <= x"08888888";
    WB_enable_in <='0';
    store_enable_in <='0';
    load_enable_in <='0';
    Rd_in <= "00111";
    
    -- mul 5*4
    -- choose Rs and Rt
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect x"00000000" 35ns
    report to_string(EX_data_out) severity note;
    wait for clk_period;
    
    EX_operand_code <= "001110"; -- mfhi
    wait for clk_period;
    report to_string(EX_data_out) severity note;
    -- expect x"00000000" 37ns
    wait for clk_period;
    
    EX_operand_code <= "001111"; -- mflo
    wait for clk_period;
    -- expect x"00010100" 39ns
    report to_string(EX_data_out) severity note;
    wait for clk_period;    
	
    
    -- mul 5*2
    EX_operand_code <= "000011";  
    -- choose Rs and ex_forward_data
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '0';
    wait for clk_period;
    -- expect x"00000000" 41ns
    report to_string(EX_data_out) severity note;	
    wait for clk_period;
    
    EX_operand_code <= "001110"; -- mfhi
    wait for clk_period;
    report to_string(EX_data_out) severity note;
    -- expect x"00000000" 43ns
    wait for clk_period;
    
    EX_operand_code <= "001111"; -- mflo
    wait for clk_period;
    -- expect x"00001010" 45ns
    report to_string(EX_data_out) severity note;
    wait for clk_period;  
    
    
    -- mul 161061273 * 2290649224
    EX_operand_code <= "000011";  
    -- choose mem_forward_data and immediate
    Rs_mux_select0 <= '1';
    Rs_mux_select1 <= '0';
    Rt_mux_select0 <= '1';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect x"00000000" 47ns
    report to_string(EX_data_out) severity note;	
    wait for clk_period;
    
    EX_operand_code <= "001110"; -- mfhi
    wait for clk_period;
    report to_string(EX_data_out) severity note;
    -- expect "00000000010100011110101110000101" 49ns
    wait for clk_period;
    
    EX_operand_code <= "001111"; -- mflo
    wait for clk_period;
    -- expect "00010100011110101110000101001000" 51ns
    report to_string(EX_data_out) severity note;
    
--------------------------- mul -------------------------------------

--------------------------- div -------------------------------------
    wait for clk_period;
    ex_reset <= '1';
    wait for clk_period;
    
    EX_Rs_in <= x"00000008";
    EX_Rt_in <= x"00000002";
    EX_immediate_value <= x"00000010";
    EX_operand_code <= "000100";
    ex_forward_data <= x"00000011";
    mem_forward_data <= x"00000020";
    WB_enable_in <='0';
    store_enable_in <='0';
    load_enable_in <='0';
    Rd_in <= "00111";
    
    -- div
    -- choose Rs and Rt
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect x"00000000" 54ns
    report to_string(EX_data_out) severity note;
    wait for clk_period;
    
    EX_operand_code <= "001110"; -- mfhi
    wait for clk_period;
    report to_string(EX_data_out) severity note;
    -- expect x"00000000" 56ns
    wait for clk_period;
    
    EX_operand_code <= "001111"; -- mflo
    wait for clk_period;
    -- expect x"00000100" 58ns
    report to_string(EX_data_out) severity note;
    wait for clk_period;       
    
    -- div 17/2
    EX_operand_code <= "000100";  
    -- choose ex_forward_data and EX_Rt_in
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '0';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect x"00000000" 60ns
    report to_string(EX_data_out) severity note;	
    wait for clk_period;
    
    EX_operand_code <= "001110"; -- mfhi
    wait for clk_period;
    report to_string(EX_data_out) severity note;
    -- expect x"00000001" 62ns
    wait for clk_period;
    
    EX_operand_code <= "001111"; -- mflo
    wait for clk_period;
    -- expect x"00001000" 64ns
    report to_string(EX_data_out) severity note;     

--------------------------- div -------------------------------------
  
  
--------------------------- slt -------------------------------------
    wait for clk_period;
    ex_reset <= '1';
    wait for clk_period;
    
    EX_Rs_in <= x"00000008";
    EX_Rt_in <= x"00000002";
    EX_immediate_value <= x"00000010";
    EX_operand_code <= "000101";
    ex_forward_data <= x"00000011";
    mem_forward_data <= x"00000020";
    WB_enable_in <='0';
    store_enable_in <='0';
    load_enable_in <='0';
    Rd_in <= "00111";
    
    -- slt
    -- choose Rs and Rt
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect x"00000000" 67ns
    report to_string(EX_data_out) severity note;
    wait for clk_period;    
    
    -- slt
    -- choose Rs and mem_forward_data
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '1';
    Rt_mux_select1 <= '0';
    wait for clk_period;
    -- expect x"00000001" 69ns
    report to_string(EX_data_out) severity note;

--------------------------- slt -------------------------------------
  
  
--------------------------- and -------------------------------------
    wait for clk_period;
    ex_reset <= '1';
    wait for clk_period;
    
    EX_Rs_in <= x"00000007";
    EX_Rt_in <= x"00000002";
    EX_immediate_value <= x"00000010";
    EX_operand_code <= "000111";
    ex_forward_data <= x"00000011";
    mem_forward_data <= x"00000020";
    WB_enable_in <='0';
    store_enable_in <='0';
    load_enable_in <='0';
    Rd_in <= "00111";
    
    -- and
    -- choose Rs and Rt
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect x"00000002" 72ns
    report to_string(EX_data_out) severity note;    
  
--------------------------- and -------------------------------------
  
--------------------------- or -------------------------------------
    wait for clk_period;
    ex_reset <= '1';
    wait for clk_period;
    
    EX_Rs_in <= x"00000007";
    EX_Rt_in <= x"00000042";
    EX_immediate_value <= x"00000010";
    EX_operand_code <= "001000";
    ex_forward_data <= x"00000011";
    mem_forward_data <= x"00000020";
    WB_enable_in <='0';
    store_enable_in <='0';
    load_enable_in <='0';
    Rd_in <= "00111";
    
    -- or
    -- choose Rs and Rt
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect x"00000047" 75ns
    report to_string(EX_data_out) severity note;

--------------------------- or -------------------------------------

--------------------------- nor -------------------------------------

    wait for clk_period;
    ex_reset <= '1';
    wait for clk_period;
    
    EX_Rs_in <= x"00000007";
    EX_Rt_in <= x"00000042";
    EX_immediate_value <= x"00000010";
    EX_operand_code <= "001001";
    ex_forward_data <= x"00000011";
    mem_forward_data <= x"00000020";
    WB_enable_in <='0';
    store_enable_in <='0';
    load_enable_in <='0';
    Rd_in <= "00111";
    
    -- nor
    -- choose Rs and Rt
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect x"fffffff8" 78ns
    report to_string(EX_data_out) severity note;

--------------------------- nor -------------------------------------

--------------------------- xor -------------------------------------

    wait for clk_period;
    ex_reset <= '1';
    wait for clk_period;
    
    EX_Rs_in <= x"00000007";
    EX_Rt_in <= x"00000042";
    EX_immediate_value <= x"00000010";
    EX_operand_code <= "001010";
    ex_forward_data <= x"00000011";
    mem_forward_data <= x"00000020";
    WB_enable_in <='0';
    store_enable_in <='0';
    load_enable_in <='0';
    Rd_in <= "00111";
    
    -- xor
    -- choose Rs and Rt
    Rs_mux_select0 <= '0';
    Rs_mux_select1 <= '1';
    Rt_mux_select0 <= '0';
    Rt_mux_select1 <= '1';
    wait for clk_period;
    -- expect "00000000000000000000000001000101" 81ns
    report to_string(EX_data_out) severity note;

--------------------------- xor -------------------------------------


--------------------------- lui -------------------------------------




--------------------------- lui -------------------------------------





  end process;

end architecture;
