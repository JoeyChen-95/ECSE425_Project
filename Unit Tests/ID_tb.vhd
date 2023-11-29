LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;


ENTITY ID_tb is
end ID_tb;

ARCHITECTURE ID_testbench OF ID_tb is

 COMPONENT ID is
    Port ( 
        -- Clock, reset
        clock, reset, dump : IN STD_LOGIC;

        -- Signals from the fetch stage.
        instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_in   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Signals from the WB stage.
        wb_write_enable  : IN STD_LOGIC;
        wb_write_address : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        wb_data    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Signals passed to the fetch stage due to branching.
        branch_taken  : OUT STD_LOGIC;
        branch_address  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Signals passed on to later stages.
        ID_Rs_out   : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --Rs
        ID_Rt_out   : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --Rt
        ID_IM    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --immediate value
        ID_Op_code   : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        WB_enable   : OUT STD_LOGIC; --indicate the write back enable
        store_enable : OUT STD_LOGIC; -- indicate the store in mem
        imm_enable   : OUT STD_LOGIC;
        load_enable  : OUT STD_LOGIC; -- indicate the load in mem
        Rd_out    : OUT STD_LOGIC_VECTOR (4 DOWNTO 0) --indicate the Rd
    );     
    END COMPONENT;
    
    -- test signals
    constant clk_period : time := 1 ns;
    signal clock, reset, dump : STD_LOGIC;
        
    -- Signals from the fetch stage.
    signal instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal pc_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');

    -- Signals from the WB stage.
    signal wb_write_enable : STD_LOGIC := '0';
    signal wb_write_address : STD_LOGIC_VECTOR(4 DOWNTO 0) := (others => '0');
    signal wb_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');

    -- Signals passed to the fetch stage due to branching.
    signal branch_taken : STD_LOGIC;
    signal branch_address : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Signals passed on to later stages.
    signal ID_Rs_out : STD_LOGIC_VECTOR (31 DOWNTO 0); --Rs
    signal ID_Rt_out : STD_LOGIC_VECTOR (31 DOWNTO 0); --Rt
    signal ID_IM : STD_LOGIC_VECTOR (31 DOWNTO 0); --immediate value
    signal ID_Op_code : STD_LOGIC_VECTOR(5 DOWNTO 0);
    signal WB_enable : STD_LOGIC; --indicate the write back enable
    signal store_enable : STD_LOGIC; -- indicate the store in mem
    signal imm_enable : STD_LOGIC;
    signal load_enable :  STD_LOGIC; -- indicate the load in mem
    signal Rd_out : STD_LOGIC_VECTOR (4 DOWNTO 0); --indicate the Rd
    
    -- Internal
    SIGNAL mem_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
begin 
 
  ID_test: ID 
  ---------Port Map of ID ---------
  port map(
    clock => clock,
    reset => reset,
    dump => dump,
    instruction => instruction,
    pc_in => pc_in,
    wb_write_enable => wb_write_enable,
    wb_write_address => wb_write_address,
    wb_data => wb_data,
    branch_taken => branch_taken,
    branch_address => branch_address,
    ID_Rs_out => ID_Rs_out,
    ID_Rt_out => ID_Rt_out,
    ID_IM => ID_IM,
    ID_Op_code => ID_Op_code,
    WB_enable => WB_enable,
    store_enable => store_enable,
    imm_enable => imm_enable,
    load_enable => load_enable,
    Rd_out => Rd_out
  );
  
  
  clk_process : process
  begin
    clock <= '1';
    wait for clk_period/2;
    clock <= '0';
    wait for clk_period/2;
  end process;
  
  
  test_process : process
    FILE file_ptr   : text;
    VARIABLE file_line  : line;
    VARIABLE line_content : STRING(1 TO 32);
    VARIABLE char   : CHARACTER := '0';
    VARIABLE mem_out : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
  
  begin
    -- Reset
    wait for clk_period;
    dump <= '0';
 reset <= '0';

 wait for clk_period;
   reset <= '1';
 wait for clk_period;
    pc_in <= x"00000010";

 -- Check ADD
    instruction <= "00000000001000100001100000100000";
    wait for clk_period;
    ASSERT ID_Op_code = "000000" REPORT "ADD FAILED" SEVERITY error;
    ASSERT WB_enable = '1' REPORT "ADD FAILED" SEVERITY error;
    ASSERT imm_enable = '0' REPORT "ADD FAILED" SEVERITY error;
    ASSERT store_enable = '0' REPORT "ADD FAILED" SEVERITY error;
    ASSERT load_enable = '0' REPORT "ADD FAILED" SEVERITY error;
    
    -- j, beq, jal
    -- jump
    instruction <= "00001000000000000000000000001100";
    wait for clk_period;
    ASSERT ID_Op_code = "000000" REPORT "JUMP FAILED" SEVERITY error;
    ASSERT WB_enable = '0' REPORT "JUMP FAILED" SEVERITY error;
    ASSERT imm_enable = '0' REPORT "JUMP FAILED" SEVERITY error;
    ASSERT store_enable = '0' REPORT "JUMP FAILED" SEVERITY error;
    ASSERT load_enable = '0' REPORT "JUMP FAILED" SEVERITY error;
    
    -- beq
     instruction <= "00010000000000000000000000001100";
    wait for clk_period;
    ASSERT ID_Op_code = "000000" REPORT "BEQ FAILED" SEVERITY error;
    ASSERT WB_enable = '0' REPORT "BEQ FAILED" SEVERITY error;
    ASSERT imm_enable = '1' REPORT "BEQ FAILED" SEVERITY error;
    ASSERT store_enable = '0' REPORT "BEQ FAILED" SEVERITY error;
    ASSERT load_enable = '0' REPORT "BEQ FAILED" SEVERITY error;
    
    --jal
    instruction <= "00001100000000000000000000001100";
    wait for clk_period;
    ASSERT ID_Op_code = "000000" REPORT "JAL FAILED" SEVERITY error;
    ASSERT WB_enable = '0' REPORT "JAL FAILED" SEVERITY error;
    ASSERT imm_enable = '0' REPORT "JAL FAILED" SEVERITY error;
    ASSERT store_enable = '0' REPORT "JAL FAILED" SEVERITY error;
    ASSERT load_enable = '0' REPORT "JAL FAILED" SEVERITY error;
    WAIT;

    
  end process;
end architecture;
