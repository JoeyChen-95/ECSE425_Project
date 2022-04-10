LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
LIBRARY work;
USE work.ALL;

ENTITY EX IS
  PORT (
    -- clock, reset, stall
    ex_clock : IN STD_LOGIC;
    ex_stall : IN STD_LOGIC;

    EX_Rs_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0); --Rs
    EX_Rt_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0); --Rt
    EX_immediate_value : IN STD_LOGIC_VECTOR (31 DOWNTO 0); --immediate value
    EX_operand_code : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    EX_data_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); -- result of ALU

    -- forwarding data
    ex_forward_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0); --data from EX stage
    mem_forward_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0); --data from memory stage

    -- pass the data that will be used in later stages forward
    WB_enable_in : IN STD_LOGIC; --indicate the write back enable
    WB_enable_out : OUT STD_LOGIC;
    store_enable_in : IN STD_LOGIC; -- indicate the store in mem
    store_enable_out : OUT STD_LOGIC;
    load_enable_in : IN STD_LOGIC; -- indicate the load in mem
    load_enable_out : OUT STD_LOGIC;
    Rd_in : IN STD_LOGIC_VECTOR (4 DOWNTO 0); --indicate the Rd
    Rd_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);

    -- mux select signal
    Rs_mux_select0 : IN STD_LOGIC;
    Rs_mux_select1 : IN STD_LOGIC;
    Rt_mux_select0 : IN STD_LOGIC;
    Rt_mux_select1 : IN STD_LOGIC;

    -- other signal
    mem_data_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
  );

END EX;

ARCHITECTURE ex_architecture OF EX IS
  -- ALU component to calculate 
  COMPONENT ALU IS
    PORT (
      -- clock, reset, stall
      ALU_clock : IN STD_LOGIC;

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

  -- ALU component signals
  SIGNAL ALU_clock : STD_LOGIC;
  SIGNAL ALU_RS : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL ALU_RT_or_immediate : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL ALU_operand_code : STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL ALU_result_out : STD_LOGIC_VECTOR(31 DOWNTO 0);

  -- mux_4 component signals 
  -- for Rs mux select
  SIGNAL mux_4_Rs_select_0 : STD_LOGIC;
  SIGNAL mux_4_Rs_select_1 : STD_LOGIC;
  SIGNAL mux_4_Rs_input_0 : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL mux_4_Rs_input_1 : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL mux_4_Rs_input_2 : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL mux_4_Rs_input_3 : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL mux_4_Rs_output : STD_LOGIC_VECTOR (31 DOWNTO 0);
  -- for Rt mux select
  SIGNAL mux_4_Rt_select_0 : STD_LOGIC;
  SIGNAL mux_4_Rt_select_1 : STD_LOGIC;
  SIGNAL mux_4_Rt_input_0 : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL mux_4_Rt_input_1 : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL mux_4_Rt_input_2 : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL mux_4_Rt_input_3 : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL mux_4_Rt_output : STD_LOGIC_VECTOR (31 DOWNTO 0);

  -- temp signals
  -- temp Rs and Rt signals, dynamically being 0 or the input Rs/Rt value
  SIGNAL temp_EX_Rs : STD_LOGIC_VECTOR (31 DOWNTO 0);
  SIGNAL temp_EX_Rt : STD_LOGIC_VECTOR (31 DOWNTO 0);
  -- temp mux select signals, dynamically being 0 or the input select signal value
  SIGNAL temp_Rs_mux_select0 : STD_LOGIC;
  SIGNAL temp_Rs_mux_select1 : STD_LOGIC;
  SIGNAL temp_Rt_mux_select0 : STD_LOGIC;
  SIGNAL temp_Rt_mux_select1 : STD_LOGIC;

BEGIN

  ALU1 : ALU
  ---------Port Map of ALU ---------
  PORT MAP(
    ALU_clock => ALU_clock,
    ALU_RS => ALU_RS,
    ALU_RT_or_immediate => ALU_RT_or_immediate,
    ALU_operand_code => ALU_operand_code,
    ALU_result_out => ALU_result_out
  );

  ---------Port Map of Mux_4 ---------
  Mux_4_Rs : mux_4
  PORT MAP(
    mux_4_select_0 => mux_4_Rs_select_0,
    mux_4_select_1 => mux_4_Rs_select_1,
    mux_4_input_0 => mux_4_Rs_input_0,
    mux_4_input_1 => mux_4_Rs_input_1,
    mux_4_input_2 => mux_4_Rs_input_2,
    mux_4_input_3 => mux_4_Rs_input_3,
    mux_4_output => mux_4_Rs_output
  );

  Mux_4_Rt : mux_4
  PORT MAP(
    mux_4_select_0 => mux_4_Rt_select_0,
    mux_4_select_1 => mux_4_Rt_select_1,
    mux_4_input_0 => mux_4_Rt_input_0,
    mux_4_input_1 => mux_4_Rt_input_1,
    mux_4_input_2 => mux_4_Rt_input_2,
    mux_4_input_3 => mux_4_Rt_input_3,
    mux_4_output => mux_4_Rt_output
  );

  PROCESS (ex_clock, ex_stall)

  BEGIN

    -- When stall
    IF ex_stall'event AND ex_stall = '1' THEN
      -- add $r0, $r0, $r0

      --set the operand code to be add, 000000
      ALU_operand_code <= "000000";

      -- Rs = 0, Rt = 0
      temp_EX_Rs <= (OTHERS => '0');
      temp_EX_Rt <= (OTHERS => '0');

      -- set mux signals
      -- since we put the wire that choosing Rs/Rt at position 2, so the control signal should be 10
      temp_Rs_mux_select0 <= '0';
      temp_Rs_mux_select1 <= '1';
      temp_Rt_mux_select0 <= '0';
      temp_Rt_mux_select1 <= '1';

      -- set the signals that will be directly passed to later stages to be 0
      mem_data_out <= (OTHERS => '0');
      WB_enable_out <= '0';
      load_enable_out <= '0';
      store_enable_out <= '0';
      Rd_out <= "00000";

    ELSIF ex_clock'event AND ex_clock = '1' AND ex_stall = '0' THEN
      --  run normally

      -- pass the Rs and Rt value to the temp signals, later temp signals will be sent to  mux
      temp_EX_Rs <= EX_Rs_in;
      temp_EX_Rt <= EX_Rt_in;

      -- pass the mux select signals to temp signals, later temp signals will be sent to control mux
      temp_Rs_mux_select0 <= Rs_mux_select0;
      temp_Rs_mux_select1 <= Rs_mux_select1;
      temp_Rt_mux_select0 <= Rt_mux_select0;
      temp_Rt_mux_select1 <= Rt_mux_select1;

      -- set ALU clock and pass the operand code to ALU
      ALU_clock <= ex_clock;
      ALU_operand_code <= EX_operand_code;

      mem_data_out <= EX_Rt_in;

      -- pass the signals that will be used in later stages forward
      WB_enable_out <= WB_enable_in;
      load_enable_out <= load_enable_in;
      store_enable_out <= store_enable_in;
      Rd_out <= Rd_in;
    END IF;

  END PROCESS;

  -- mux input signals map
  -- Rs mux signals
  mux_4_Rs_input_0 <= ex_forward_data;
  mux_4_Rs_input_1 <= mem_forward_data;
  mux_4_Rs_input_2 <= temp_EX_Rs;
  mux_4_Rs_input_3 <= (OTHERS => '0');
  -- Rt mux signals
  mux_4_Rt_input_0 <= ex_forward_data;
  mux_4_Rt_input_1 <= mem_forward_data;
  mux_4_Rt_input_2 <= temp_EX_Rt;
  mux_4_Rt_input_3 <= EX_immediate_value;

  -- mux select signals map
  mux_4_Rs_select_0 <= temp_Rs_mux_select0;
  mux_4_Rs_select_1 <= temp_Rs_mux_select1;
  mux_4_Rt_select_0 <= temp_Rt_mux_select0;
  mux_4_Rt_select_1 <= temp_Rt_mux_select1;

  -- link the output of the mux after selecting to the ALU
  ALU_RS <= mux_4_Rs_output;
  ALU_RT_or_immediate <= mux_4_Rt_output;

  -- output the signal
  EX_data_out <= ALU_result_out;

END ARCHITECTURE;