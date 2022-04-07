-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity EX is
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

end EX;

architecture ex_architecture of EX is 
  -- ALU component to calculate 
  component ALU is
    port (
      -- clock, reset, stall
      ALU_clock: in std_logic;
      ALU_reset: in std_logic;
      ALU_stall: in std_logic;
      -- Rs,Rt,operand, output result
      ALU_RS: in std_logic_vector(31 downto 0);
      ALU_RT_or_immediate: in std_logic_vector(31 downto 0); -- Rt or the immediate value
      ALU_operand_code: in std_logic_vector(5 downto 0);
      ALU_result_out: out std_logic_vector(31 downto 0) 
    );
  end component;

  -- mux component with 4 inputs and 2 select signals, use for choose the signal input to ALU
  component mux_4 is
    Port ( 
      mux_4_select_0 : in  STD_LOGIC; --select signal 0
      mux_4_select_1 : in  STD_LOGIC; --select signal 1
      mux_4_input_0   : in  STD_LOGIC_VECTOR (31 downto 0); -- input 0
      mux_4_input_1   : in  STD_LOGIC_VECTOR (31 downto 0); -- input 1
      mux_4_input_2   : in  STD_LOGIC_VECTOR (31 downto 0); -- input 2
      mux_4_input_3   : in  STD_LOGIC_VECTOR (31 downto 0); -- input 3
      mux_4_output   : out STD_LOGIC_VECTOR (31 downto 0)   -- output
    );
  end component;
  
  -- ALU component signals
  ALU_clock: in std_logic;
  ALU_reset: in std_logic;
  ALU_stall: in std_logic;
  ALU_RS: in std_logic_vector(31 downto 0);
  ALU_RT_or_immediate: in std_logic_vector(31 downto 0);
  ALU_operand_code: in std_logic_vector(5 downto 0);
  ALU_result_out: out std_logic_vector(31 downto 0) ;
  
  -- mux_4 component signals 
  -- for Rs mux select
  mux_4_Rs_select_0 : in  STD_LOGIC; 
  mux_4_Rs_select_1 : in  STD_LOGIC; 
  mux_4_Rs_input_0 : in  STD_LOGIC_VECTOR (31 downto 0); 
  mux_4_Rs_input_1 : in  STD_LOGIC_VECTOR (31 downto 0); 
  mux_4_Rs_input_2 : in  STD_LOGIC_VECTOR (31 downto 0); 
  mux_4_Rs_input_3 : in  STD_LOGIC_VECTOR (31 downto 0); 
  mux_4_Rs_output : out STD_LOGIC_VECTOR (31 downto 0);
  -- for Rt mux select
  mux_4_Rt_select_0 : in  STD_LOGIC; 
  mux_4_Rt_select_1 : in  STD_LOGIC; 
  mux_4_Rt_input_0 : in  STD_LOGIC_VECTOR (31 downto 0); 
  mux_4_Rt_input_1 : in  STD_LOGIC_VECTOR (31 downto 0); 
  mux_4_Rt_input_2 : in  STD_LOGIC_VECTOR (31 downto 0); 
  mux_4_Rt_input_3 : in  STD_LOGIC_VECTOR (31 downto 0); 
  mux_4_Rt_output : out STD_LOGIC_VECTOR (31 downto 0);
  
  -- temp signals
  signal mux_4_Rs_select : std_logic_vector(1 downto 0) ;
  signal mux_4_Rt_select : std_logic_vector(1 downto 0) ;

begin

  ALU1: ALU 
  ---------Port Map of ALU ---------
  port map(
      ALU_clock => ALU_clock,
      ALU_reset => ALU_reset,
      ALU_stall => ALU_stall,
      ALU_RS => ALU_RS,
      ALU_RT_or_immediate => ALU_RT_or_immediate,
      ALU_operand_code => ALU_operand_code,
      ALU_result_out => ALU_result_out,
  );
  
  ---------Port Map of Mux_4 ---------
  Mux_4_Rs : mux_4
  port map (
      mux_4_select_0 => mux_4_Rs_select_0,
      mux_4_select_1 => mux_4_Rs_select_1,
      mux_4_input_0 => mux_4_Rs_input_0,
      mux_4_input_1 => mux_4_Rs_input_1,
      mux_4_input_2 => mux_4_Rs_input_2,
      mux_4_input_3 => mux_4_Rs_input_3,
      mux_4_output => mux_4_Rs_output
  );
  
  Mux_4_Rt : mux_4
  port map (
      mux_4_select_0 => mux_4_Rt_select_0,
      mux_4_select_1 => mux_4_Rt_select_1,
      mux_4_input_0 => mux_4_Rt_input_0,
      mux_4_input_1 => mux_4_Rt_input_1,
      mux_4_input_2 => mux_4_Rt_input_2,
      mux_4_input_3 => mux_4_Rt_input_3,
      mux_4_output => mux_4_Rt_output
  );
  
  -- mux_Rs and mux_Rt control signals
  mux_4_Rs_select <= mux_4_Rs_select_1 & mux_4_Rs_select_0;
  mux_4_Rt_select <= mux_4_Rt_select_1 & mux_4_Rt_select_0;
  
  process (ex_clock, ex_reset, ex_stall)
  
  begin
  
	-- When reset
  	if reset'event and ex_reset='1' then
  		-- make all signal "0"
	
    -- When stall
  	elsif ex_stall'event and ex_stall='1' then
  		-- ??
    
    elsif ex_clock'event and ex_clock='1' then
    	--  run normally
        
        -- mux_Rs
        if(mux_4_Rs_select = "00") then
          ALU_in1 <= ex_forward_data;
        elsif(mux_4_Rs_select = "01") then
          ALU_in1 <= mem_forward_data;
        elsif(mux_4_Rs_select = "10") then
          ALU_in1 <= EX_Rs_in;
        else
          ALU_in1 <= (others => '0');
        end if;
          
        -- mux_Rt
        if(mux_4_Rt_select = "00") then
          ALU_in1 <= ex_forward_data;
        elsif(mux_4_Rt_select = "01") then
          ALU_in1 <= mem_forward_data;
        elsif(mux_4_Rt_select = "10") then
          ALU_in1 <= EX_Rt_in;
        else
          ALU_in1 <= EX_immediate_value;
        end if;
        
        -- pass the signals that will be used in later stages forward
        WB_enable_in  =>  WB_enable_out: out std_logic;
        store_enable_in =>  store_enable_out: out std_logic; 
        load_enable_in => load_enable_out: out std_logic;
        Rd_in => Rd_out	: out STD_LOGIC_VECTOR (4 downto 0);
        byte_in =>  byte_out:out std_logic;
    
    end if;
    
  end process;


end architecture;

