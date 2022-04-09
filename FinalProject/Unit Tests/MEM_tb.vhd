-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_tb is
end MEM_tb;

architecture behaviour of MEM_tb is
	component MEM is
    	port(
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
  				out_waitrequest: out std_logic;
       	 		);
	end component;
    
    --input
    constant clk_period : time := 1 ns;
    signal clk: std_logic;
    signal reset: std_logic;
    signal data_in_forward: std_logic_vector(31 downto 0);
    signal forward_select: std_logic;
    signal in_data: std_logic_vector(31 downto 0);
    signal in_address: std_logic_vector(31 downto 0);
    signal access_memory_write: std_logic;
    signal access_memory_load: std_logic;
    signal access_reg_address_add_in: std_logic_vector(4 downto 0);
    signal access_reg_address_in: std_logic;
    -- output
    signal out_data: std_logic_vector(31 downto 0):= (others=> 'Z');
    signal access_reg_out: std_logic;
    signal access_reg_add_out: std_logic_vector (4 downto 0);
    signal out_waitrequest: std_logic;
    
begin
dut: MEM
port map(
	clk=>clk,
    reset=>reset,
    data_in_forward=>data_in_forward,
    forward_select=>forward_select,
    in_data=>in_data,
    in_address=>in_address,
    access_memory_write=>access_memory_write,
    access_memory_load=>access_memory_load,
    access_reg_address_add_in=>access_reg_address_add_in,
    access_reg_address_in=>access_reg_address_in,
    out_data=>out_data,
    access_reg_out=>access_reg_out,
    access_reg_add_out=>access_reg_add_out,
    out_waitrequest=>out_waitrequest
);

---------Clock Setup---------
clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process: process
begin
	wait for clk_period;
	access_reg_address_add_in<="11111";
	access_reg_address_in<='1';
    wait for clk_period;
    assert access_reg_add_out = "11111" report "access_reg_add_out error!!!" severity error;
    assert access_reg_out = '1' report "access_reg_out error!!!" severity error;
    
    wait for clk_period;
    access_memory_load<='1';
    in_address<=x"00000100";
    forward_select<='1';
    data_in_forward<=x"0000000a";
    in_data<=x"0000000b";
  
    wait for clk_period;
	access_memory_load<='0';
    access_memory_write<='1';
    
    wait for clk_period;
--     access_memory_load<='1';
--     memory_write_data<=x"19181716";
	wait for clk_period;
end process;
end;
