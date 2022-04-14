LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
LIBRARY work;
USE work.ALL;

ENTITY EX IS
  PORT (
    -- Clock
    ex_clock : IN STD_LOGIC;

    -- Data from the decode stage.
    EX_Rs_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- Rs
    EX_Rt_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- Rt
    EX_immediate_value : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- immediate value
    EX_operand_code : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    WB_enable_in : IN STD_LOGIC; -- indicate the write back enable
    store_enable_in : IN STD_LOGIC; -- indicate the store in mem
    load_enable_in : IN STD_LOGIC; -- indicate the load in mem
    imm_enable : IN STD_LOGIC; -- Toggle to use immediate values for Rt.
    Rd_in : IN STD_LOGIC_VECTOR (4 DOWNTO 0); --indicate the Rd

    -- Forwarding data from MEM and EX(previous cycle) stage.
    ex_forward_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- Data from EX stage.
    mem_forward_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- Data from memory stage.

    -- Control signals passed to later stages.
    WB_enable_out : OUT STD_LOGIC;
    store_enable_out : OUT STD_LOGIC;
    load_enable_out : OUT STD_LOGIC;
    Rd_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);

    -- Control signals.
    rs_select_forwarding : IN STD_LOGIC;
    rs_select_forwarding_mem : IN STD_LOGIC;
    rt_select_forwarding : IN STD_LOGIC;
    rt_select_forwarding_mem : IN STD_LOGIC;

    -- Other signals.
    mem_data_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    EX_data_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); -- result of ALU
  );

END EX;

ARCHITECTURE ex_architecture OF EX IS
  -- ALU component to calculate 
  COMPONENT ALU IS
    PORT (
      -- Rs,Rt,operand, output result
      ALU_RS : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      ALU_RT_or_immediate : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Rt or the immediate value
      ALU_operand_code : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      ALU_result_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT;

  -- mux component with 4 inputs and 2 select signals, use for choose the signal input to ALU
  COMPONENT mux_4 IS
    PORT (
      mux_4_select_0 : IN STD_LOGIC; --select signal 0
      mux_4_select_1 : IN STD_LOGIC; --select signal 1
      mux_4_input_0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- input 0
      mux_4_input_1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- input 1
      mux_4_input_2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- input 2
      mux_4_input_3 : IN STD_LOGIC_VECTOR (31 DOWNTO 0); -- input 3
      mux_4_output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0) -- output
    );
  END COMPONENT;

  SIGNAL preliminary_rt_or_immediate : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

  ALU1 : ALU
  ---------Port Map of ALU ---------
  PORT MAP(
    ALU_RS => ALU_RS,
    ALU_RT_or_immediate => ALU_RT_or_immediate,
    ALU_operand_code => EX_operand_code,
    ALU_result_out => EX_data_out
  );

  ---------Port Map of Mux_4 ---------
  Mux_4_Rs : mux_4
  PORT MAP(
    mux_4_select_0 => rs_select_forwarding,
    mux_4_select_1 => rs_select_forwarding_mem,
    mux_4_input_0 => EX_Rs_in,
    mux_4_input_1 => (OTHERS => '0'),
    mux_4_input_2 => ex_forward_data,
    mux_4_input_3 => mem_forward_data,
    mux_4_output => ALU_RS
  );

  Mux_4_Rt : mux_4
  PORT MAP(
    mux_4_select_0 => rt_select_forwarding,
    mux_4_select_1 => rt_select_forwarding_mem,
    mux_4_input_0 => preliminary_rt_or_immediate,
    mux_4_input_1 => (OTHERS => '0'),
    mux_4_input_2 => ex_forward_data,
    mux_4_input_3 => mem_forward_data,
    mux_4_output => ALU_RT_or_immediate
  );

  -- Set the preliminary Rt/imm values to
  -- go into the mux.
  preliminary_rt_or_immediate <= EX_Rt_in WHEN imm_enable = '1' ELSE
    EX_immediate_value;

  -- Pass these memory-related signals
  -- directly to the next stage.
  WB_enable_out <= WB_enable_in;
  load_enable_out <= load_enable_in;
  store_enable_out <= store_enable_in;
  mem_data_out <= EX_Rt_in;
  Rd_out <= Rd_in;

END ARCHITECTURE;