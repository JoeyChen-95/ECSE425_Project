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

end EX;

architecture ex_architecture of EX is 
  -- ALU component to calculate 
  component ALU is
    port (
      -- clock, reset, stall
      ALU_clock: in std_logic;
--       ALU_reset: in std_logic;
--       ALU_stall: in std_logic;
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
  signal ALU_clock: std_logic;
  signal ALU_RS: std_logic_vector(31 downto 0);
  signal ALU_RT_or_immediate: std_logic_vector(31 downto 0);
  signal ALU_operand_code: std_logic_vector(5 downto 0);
  signal ALU_result_out: std_logic_vector(31 downto 0) ;
  
  -- mux_4 component signals 
  -- for Rs mux select
  signal mux_4_Rs_select_0 : STD_LOGIC; 
  signal mux_4_Rs_select_1 : STD_LOGIC; 
  signal mux_4_Rs_input_0 : STD_LOGIC_VECTOR (31 downto 0); 
  signal mux_4_Rs_input_1 : STD_LOGIC_VECTOR (31 downto 0); 
  signal mux_4_Rs_input_2 : STD_LOGIC_VECTOR (31 downto 0); 
  signal mux_4_Rs_input_3 : STD_LOGIC_VECTOR (31 downto 0); 
  signal mux_4_Rs_output : STD_LOGIC_VECTOR (31 downto 0);
  -- for Rt mux select
  signal mux_4_Rt_select_0 : STD_LOGIC; 
  signal mux_4_Rt_select_1 : STD_LOGIC; 
  signal mux_4_Rt_input_0 : STD_LOGIC_VECTOR (31 downto 0); 
  signal mux_4_Rt_input_1 : STD_LOGIC_VECTOR (31 downto 0); 
  signal mux_4_Rt_input_2 : STD_LOGIC_VECTOR (31 downto 0); 
  signal mux_4_Rt_input_3 : STD_LOGIC_VECTOR (31 downto 0); 
  signal mux_4_Rt_output : STD_LOGIC_VECTOR (31 downto 0);
  
  -- temp signals
  -- temp Rs and Rt signals, dynamically being 0 or the input Rs/Rt value
  signal temp_EX_Rs  : STD_LOGIC_VECTOR (31 downto 0); 
  signal temp_EX_Rt  : STD_LOGIC_VECTOR (31 downto 0);
  -- temp mux select signals, dynamically being 0 or the input select signal value
  signal temp_Rs_mux_select0  : STD_LOGIC;
  signal temp_Rs_mux_select1  : STD_LOGIC;
  signal temp_Rt_mux_select0  : STD_LOGIC;
  signal temp_Rt_mux_select1  : STD_LOGIC;

begin

  ALU1: ALU 
  ---------Port Map of ALU ---------
  port map(
      ALU_clock => ALU_clock,
      ALU_RS => ALU_RS,
      ALU_RT_or_immediate => ALU_RT_or_immediate,
      ALU_operand_code => ALU_operand_code,
      ALU_result_out => ALU_result_out
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
  
  process (ex_clock, ex_reset, ex_stall)
  
  begin
  
	-- When reset
  	if ex_reset'event and ex_reset='1' then
  		-- make all signal to be 0
	
    -- When stall
  	elsif ex_stall'event and ex_stall='1' then
  		-- add $r0, $r0, $r0
        
        --set the operand code to be add, 000000
        ALU_operand_code <="000000";
        
        -- Rs = 0, Rt = 0
        temp_EX_Rs <= (others => '0');
        temp_EX_Rt <= (others => '0');
        
        -- set mux signals
        -- since we put the wire that choosing Rs/Rt at position 2, so the control signal should be 10
        temp_Rs_mux_select0 <='0';
        temp_Rs_mux_select1 <='1';
        temp_Rt_mux_select0 <='0';
        temp_Rt_mux_select1 <='1';
    
    elsif ex_clock'event and ex_clock='1' then
    	--  run normally
        
        -- pass the Rs and Rt value to the temp signals, later temp signals will be sent to  mux
        temp_EX_Rs <= EX_Rs_in;
        temp_EX_Rt <= EX_Rt_in;
        
        -- pass the mux select signals to temp signals, later temp signals will be sent to control mux
        temp_Rs_mux_select0 <=Rs_mux_select0;
        temp_Rs_mux_select1 <=Rs_mux_select1;
        temp_Rt_mux_select0 <=Rt_mux_select0;
        temp_Rt_mux_select1 <=Rt_mux_select1;
        
        -- set ALU clock and pass the operand code to ALU
        ALU_clock<= ex_clock;
        ALU_operand_code<= EX_operand_code;
        
        mem_data_out <= EX_Rt_in;
        
        -- pass the signals that will be used in later stages forward
        WB_enable_out <= WB_enable_in;
        load_enable_out <= load_enable_in;
        store_enable_out <= store_enable_in;
    	Rd_out<= Rd_in;
    end if;
    
  end process;
  
  -- mux input signals map
  -- Rs mux signals
  mux_4_Rs_input_0 <=ex_forward_data;
  mux_4_Rs_input_1 <=mem_forward_data;
  mux_4_Rs_input_2 <=temp_EX_Rs;
  mux_4_Rs_input_3 <=(others => '0');
  -- Rt mux signals
  mux_4_Rt_input_0 <=ex_forward_data;
  mux_4_Rt_input_1 <=mem_forward_data;
  mux_4_Rt_input_2 <=temp_EX_Rt;
  mux_4_Rt_input_3 <=EX_immediate_value;  
  
  -- mux select signals map
  mux_4_Rs_select_0 <= temp_Rs_mux_select0 ;
  mux_4_Rs_select_1 <= temp_Rs_mux_select1 ;
  mux_4_Rt_select_0 <= temp_Rt_mux_select0 ;
  mux_4_Rt_select_1 <= temp_Rt_mux_select1 ;

  -- link the output of the mux after selecting to the ALU
  ALU_RS <= mux_4_Rs_output;
  ALU_RT_or_immediate <= mux_4_Rt_output;
  
  -- output the signal
  EX_data_out<=ALU_result_out;
  
end architecture;

