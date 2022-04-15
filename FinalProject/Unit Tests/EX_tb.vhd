LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY EX_tb IS
END EX_tb;

ARCHITECTURE EX_testbench OF EX_tb IS
    COMPONENT EX IS
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
    END COMPONENT;

    -- test signals
    -- clock, reset, stall
    SIGNAL clk : STD_LOGIC := '0';
    CONSTANT clk_period : TIME := 1 ns;
    SIGNAL ex_stall : STD_LOGIC := '0';
    -- Rs, Rt, immediate, operand, and data out
    SIGNAL EX_Rs_in : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL EX_Rt_in : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL EX_immediate_value : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL EX_operand_code : STD_LOGIC_VECTOR (5 DOWNTO 0);
    SIGNAL EX_data_out : STD_LOGIC_VECTOR (31 DOWNTO 0);
    -- forwarding data
    SIGNAL ex_forward_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL mem_forward_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
    -- signals that will be passed to next stage
    SIGNAL WB_enable_in : STD_LOGIC; --indicate the write back enable
    SIGNAL WB_enable_out : STD_LOGIC;
    SIGNAL store_enable_in : STD_LOGIC; -- indicate the store in mem
    SIGNAL store_enable_out : STD_LOGIC;
    SIGNAL load_enable_in : STD_LOGIC; -- indicate the load in mem
    SIGNAL load_enable_out : STD_LOGIC;
    SIGNAL Rd_in : STD_LOGIC_VECTOR (4 DOWNTO 0); --indicate the Rd
    SIGNAL Rd_out : STD_LOGIC_VECTOR (4 DOWNTO 0);
    -- mux select signal
    SIGNAL Rs_mux_select0 : STD_LOGIC;
    SIGNAL Rs_mux_select1 : STD_LOGIC;
    SIGNAL Rt_mux_select0 : STD_LOGIC;
    SIGNAL Rt_mux_select1 : STD_LOGIC;
    -- other signal
    SIGNAL mem_data_out : STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN

    EX_test : EX
    ---------Port Map of EX ---------
    PORT MAP(
        ex_clock => clk,
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

    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    test_process : PROCESS
    BEGIN
        --------------------------- add -------------------------------------
        WAIT FOR clk_period;

        EX_Rs_in <= x"00000001";
        EX_Rt_in <= x"00000002";
        EX_immediate_value <= x"00000003";
        EX_operand_code <= "000000";
        ex_forward_data <= x"00000004";
        mem_forward_data <= x"00000005";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00111";
        -- choose ex_forward_data and ex_forward_data
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '0';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '0';
        WAIT FOR clk_period;
        -- expect x"00000008" 2ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000008" REPORT "ADD FAILED" SEVERITY error;
    
        -- choose ex_forward_data and mem_forward_data
        WAIT FOR clk_period;
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '0';
        Rt_mux_select0 <= '1';
        Rt_mux_select1 <= '0';
        WAIT FOR clk_period;
        -- expect x"00000009" 4ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000009" REPORT "ADD FAILED" SEVERITY error;
    
        -- choose ex_forward_data and Rt
        WAIT FOR clk_period;
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '0';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect  x"00000006" 6ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000006" REPORT "ADD FAILED" SEVERITY error;
    
        -- choose mem_forward_data and ex_forward_data
        WAIT FOR clk_period;
        Rs_mux_select0 <= '1';
        Rs_mux_select1 <= '0';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '0';
        WAIT FOR clk_period;
        -- expect x"00000009" 8ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000009" REPORT "ADD FAILED" SEVERITY error;
    
        -- choose mem_forward_data and mem_forward_data
        WAIT FOR clk_period;
        Rs_mux_select0 <= '1';
        Rs_mux_select1 <= '0';
        Rt_mux_select0 <= '1';
        Rt_mux_select1 <= '0';
        WAIT FOR clk_period;
        -- expect x"0000000a" 10ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"0000000a" REPORT "ADD FAILED" SEVERITY error;
    
        -- choose mem_forward_data and temp_EX_Rt
        WAIT FOR clk_period;
        Rs_mux_select0 <= '1';
        Rs_mux_select1 <= '0';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000007" 12ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000007" REPORT "ADD FAILED" SEVERITY error;
    
        -- choose temp_EX_Rs and ex_forward_data
        WAIT FOR clk_period;
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '0';
        WAIT FOR clk_period;
        -- expect x"00000005" 14ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000005" REPORT "ADD FAILED" SEVERITY error;
    
        -- choose temp_EX_Rs and mem_forward_data
        WAIT FOR clk_period;
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '1';
        Rt_mux_select1 <= '0';
        WAIT FOR clk_period;
        -- expect x"00000006" 16ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000006" REPORT "ADD FAILED" SEVERITY error;
    
        -- choose temp_EX_Rs and temp_EX_Rt
        WAIT FOR clk_period;
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000003" 18ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000003" REPORT "ADD FAILED" SEVERITY error;
    
        -- choose 0 and ex_forward_data
        WAIT FOR clk_period;
        Rs_mux_select0 <= '1';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '0';
        WAIT FOR clk_period;
        -- expect x"00000004" 20ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000004" REPORT "ADD FAILED" SEVERITY error;
    
        -- choose 0 and mem_forward_data
        WAIT FOR clk_period;
        Rs_mux_select0 <= '1';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '1';
        Rt_mux_select1 <= '0';
        WAIT FOR clk_period;
        -- expect x"00000005" 22ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000005" REPORT "ADD FAILED" SEVERITY error;
    
        -- choose 0 and temp_EX_Rt
        WAIT FOR clk_period;
        Rs_mux_select0 <= '1';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000002" 24ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000002" REPORT "ADD FAILED" SEVERITY error;
    
        --------------------------- add -------------------------------------

        --------------------------- sub -------------------------------------
        WAIT FOR clk_period;

        EX_Rs_in <= x"00000005";
        EX_Rt_in <= x"00000004";
        EX_immediate_value <= x"00000003";
        EX_operand_code <= "000001";
        ex_forward_data <= x"00000002";
        mem_forward_data <= x"00000001";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00111";
        -- choose ex_forward_data and ex_forward_data
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '0';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '0';
        WAIT FOR clk_period;
        -- expect x"00000000" 26ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000000" REPORT "SUB FAILED" SEVERITY error;
    
        -- choose Rs and Rt
        WAIT FOR clk_period;
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000001" 28ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000001" REPORT "SUB FAILED" SEVERITY error;
    
        -- choose mem_forward_data and Rt
        WAIT FOR clk_period;
        Rs_mux_select0 <= '1';
        Rs_mux_select1 <= '0';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect -3, x"fffffffd" 30ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"fffffffd" REPORT "SUB FAILED" SEVERITY error;
    
        --------------------------- sub -------------------------------------

        --------------------------- mul -------------------------------------
        WAIT FOR clk_period;

        EX_Rs_in <= x"00000005";
        EX_Rt_in <= x"00000004";
        EX_immediate_value <= x"09999999";
        EX_operand_code <= "000011";
        ex_forward_data <= x"00000002";
        mem_forward_data <= x"08888888";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00000";

        -- mul 5*4
        -- choose Rs and Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000000" 32ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000000" REPORT "MUL FAILED" SEVERITY error; 		WAIT FOR clk_period;

        EX_operand_code <= "001110"; -- mfhi
        WAIT FOR clk_period;
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000000" REPORT "MUL FAILED" SEVERITY error;
        -- expect x"00000000" 34ns
        WAIT FOR clk_period;

        EX_operand_code <= "001111"; -- mflo
        WAIT FOR clk_period;
        -- expect x"00000014" 36ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000014" REPORT "MUL FAILED" SEVERITY error;
    
        WAIT FOR clk_period;
        -- mul 5*2
        EX_operand_code <= "000011";
        -- choose Rs and ex_forward_data
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '0';
        WAIT FOR clk_period;
        -- expect x"00000000" 38ns
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000000" REPORT "MUL FAILED" SEVERITY error;
        WAIT FOR clk_period;

        EX_operand_code <= "001110"; -- mfhi
        WAIT FOR clk_period;
        REPORT to_string(EX_data_out) SEVERITY note;
		ASSERT EX_data_out = x"00000000" REPORT "MUL FAILED" SEVERITY error;
        -- expect x"00000000" 40ns
        WAIT FOR clk_period;

        EX_operand_code <= "001111"; -- mflo
        WAIT FOR clk_period;
        -- expect x"0000000A" 42ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"0000000A" REPORT "MUL FAILED" SEVERITY error;
        WAIT FOR clk_period;
        
        -- mul 161061273 * 2290649224
        EX_operand_code <= "000011";
        -- choose mem_forward_data and immediate
        Rs_mux_select0 <= '1';
        Rs_mux_select1 <= '0';
        Rt_mux_select0 <= '1';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000000" 44ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000000" REPORT "MUL FAILED" SEVERITY error;
        WAIT FOR clk_period;

        EX_operand_code <= "001110"; -- mfhi
        WAIT FOR clk_period;
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"0051EB85" REPORT "MUL FAILED" SEVERITY error;
        -- expect "00000000010100011110101110000101" 46ns
        WAIT FOR clk_period;

        EX_operand_code <= "001111"; -- mflo
        WAIT FOR clk_period;
        -- expect "00010100011110101110000101001000" 48ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"147AE148" REPORT "MUL FAILED" SEVERITY error;

        --------------------------- mul -------------------------------------

        --------------------------- div -------------------------------------
        WAIT FOR clk_period;

        EX_Rs_in <= x"00000008";
        EX_Rt_in <= x"00000002";
        EX_immediate_value <= x"00000010";
        EX_operand_code <= "000100";
        ex_forward_data <= x"00000011";
        mem_forward_data <= x"00000020";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00000";

        -- div
        -- choose Rs and Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000000" 50ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000000" REPORT "DIV FAILED" SEVERITY error;
        WAIT FOR clk_period;

        EX_operand_code <= "001110"; -- mfhi
        WAIT FOR clk_period;
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000000" REPORT "DIV FAILED" SEVERITY error;
        -- expect x"00000000" 52ns
        WAIT FOR clk_period;

        EX_operand_code <= "001111"; -- mflo
        WAIT FOR clk_period;
        -- expect x"00000004" 54ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000004" REPORT "DIV FAILED" SEVERITY error;
        WAIT FOR clk_period;

        -- div 17/2
        EX_operand_code <= "000100";
        -- choose ex_forward_data and EX_Rt_in
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '0';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000000" 56ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000000" REPORT "DIV FAILED" SEVERITY error;
        WAIT FOR clk_period;

        EX_operand_code <= "001110"; -- mfhi
        WAIT FOR clk_period;
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000001" REPORT "DIV FAILED" SEVERITY error;
        -- expect x"00000001" 58ns
        WAIT FOR clk_period;

        EX_operand_code <= "001111"; -- mflo
        WAIT FOR clk_period;
        -- expect x"00000008" 60ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000008" REPORT "DIV FAILED" SEVERITY error;

        --------------------------- div -------------------------------------
        --------------------------- slt -------------------------------------
        WAIT FOR clk_period;

        EX_Rs_in <= x"00000008";
        EX_Rt_in <= x"00000002";
        EX_immediate_value <= x"00000010";
        EX_operand_code <= "000101";
        ex_forward_data <= x"00000011";
        mem_forward_data <= x"00000020";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00111";

        -- slt
        -- choose Rs and Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000000" 62ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000000" REPORT "SLT FAILED" SEVERITY error;
        WAIT FOR clk_period;

        -- slt
        -- choose Rs and mem_forward_data
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '1';
        Rt_mux_select1 <= '0';
        WAIT FOR clk_period;
        -- expect x"00000001" 64ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000001" REPORT "SLT FAILED" SEVERITY error;

        --------------------------- slt -------------------------------------
        --------------------------- and -------------------------------------
        WAIT FOR clk_period;

        EX_Rs_in <= x"00000007";
        EX_Rt_in <= x"00000002";
        EX_immediate_value <= x"00000010";
        EX_operand_code <= "000111";
        ex_forward_data <= x"00000011";
        mem_forward_data <= x"00000020";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00111";

        -- and
        -- choose Rs and Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000002" 66ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000002" REPORT "AND FAILED" SEVERITY error;

        --------------------------- and -------------------------------------

        --------------------------- or -------------------------------------
        WAIT FOR clk_period;

        EX_Rs_in <= x"00000007";
        EX_Rt_in <= x"00000042";
        EX_immediate_value <= x"00000010";
        EX_operand_code <= "001000";
        ex_forward_data <= x"00000011";
        mem_forward_data <= x"00000020";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00111";

        -- or
        -- choose Rs and Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000047" 68ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000047" REPORT "OR FAILED" SEVERITY error;

        --------------------------- or -------------------------------------

        --------------------------- nor -------------------------------------

        WAIT FOR clk_period;

        EX_Rs_in <= x"00000007";
        EX_Rt_in <= x"00000042";
        EX_immediate_value <= x"00000010";
        EX_operand_code <= "001001";
        ex_forward_data <= x"00000011";
        mem_forward_data <= x"00000020";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00111";

        -- nor
        -- choose Rs and Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"FFFFFFB8" 70ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"FFFFFFB8" REPORT "NOR FAILED" SEVERITY error;

        --------------------------- nor -------------------------------------

        --------------------------- xor -------------------------------------

        WAIT FOR clk_period;

        EX_Rs_in <= x"00000007";
        EX_Rt_in <= x"00000042";
        EX_immediate_value <= x"00000010";
        EX_operand_code <= "001010";
        ex_forward_data <= x"00000011";
        mem_forward_data <= x"00000020";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00111";

        -- xor
        -- choose Rs and Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect "00000000000000000000000001000101" 72ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000045" REPORT "XOR FAILED" SEVERITY error;

        --------------------------- xor -------------------------------------
        --------------------------- lui -------------------------------------

        WAIT FOR clk_period;

        EX_Rs_in <= x"00000007";
        EX_Rt_in <= x"00000042";
        EX_immediate_value <= x"00000007";
        EX_operand_code <= "010000";
        ex_forward_data <= x"00000011";
        mem_forward_data <= x"00000020";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00111";

        -- lui
        -- choose immediate 00000007
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '0';
        Rt_mux_select0 <= '1';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00070000" 74ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00070000" REPORT "LUI FAILED" SEVERITY error;
        WAIT FOR clk_period;

        -- lui
        EX_immediate_value <= x"07000019";
        -- choose immediate 07000019
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '0';
        Rt_mux_select0 <= '1';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00190000" 76ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00190000" REPORT "LUI FAILED" SEVERITY error;

        --------------------------- lui -------------------------------------

        --------------------------- sll -------------------------------------

        WAIT FOR clk_period;

        EX_Rs_in <= x"00000007";
        EX_Rt_in <= x"00000000";
        EX_immediate_value <= x"00000007";
        EX_operand_code <= "010001";
        ex_forward_data <= x"00000011";
        mem_forward_data <= x"00000020";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00111";

        -- sll
        -- choose Rs Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000007" 78ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000007" REPORT "SLL FAILED" SEVERITY error;
        WAIT FOR clk_period;

        -- sll
        EX_Rt_in <= x"00000004";
        -- choose Rs Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000070" 80ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000070" REPORT "SLL FAILED" SEVERITY error;

        --------------------------- sll -------------------------------------

        --------------------------- srl -------------------------------------

        WAIT FOR clk_period;

        EX_Rs_in <= x"00000567";
        EX_Rt_in <= x"00000000";
        EX_immediate_value <= x"00000007";
        EX_operand_code <= "010010";
        ex_forward_data <= x"00000011";
        mem_forward_data <= x"00000020";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00111";

        -- srl
        -- choose Rs Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00000567" 82ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000567" REPORT "SRL FAILED" SEVERITY error;
        WAIT FOR clk_period;

        -- srl
        EX_Rt_in <= x"00000005";
        -- choose Rs Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"0000002B" 84ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"0000002B" REPORT "SRL FAILED" SEVERITY error;

        --------------------------- srl -------------------------------------

        --------------------------- sra -------------------------------------

        WAIT FOR clk_period;

        EX_Rs_in <= x"00000567";
        EX_Rt_in <= x"00000000";
        EX_immediate_value <= x"00000007";
        EX_operand_code <= "010011";
        ex_forward_data <= x"00000011";
        mem_forward_data <= x"00000020";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00111";

        -- sra starts with 0 and shift by 0 bit
        -- choose Rs Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect "00000000000000000000010101100111" 86ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00000567" REPORT "SRA FAILED" SEVERITY error;
        WAIT FOR clk_period;

        -- sra starts with 0 and shift 5 bits
        EX_Rt_in <= x"00000005";
        -- choose Rs Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect "00000000000000000000000000101011" 88ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"0000002B" REPORT "SRA FAILED" SEVERITY error;
        WAIT FOR clk_period;

        -- sra starts with 1 and shift 0 bits
        EX_Rs_in <= x"f00000b5";
        EX_Rt_in <= x"00000000";
        -- choose Rs Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect "11110000000000000000000010110101" 90ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"F00000B5" REPORT "SRA FAILED" SEVERITY error;
        WAIT FOR clk_period;

        -- sra starts with 1 and shift 5 bits
        EX_Rt_in <= x"00000005";
        -- choose Rs Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect "11111111100000000000000000000101" 92ns
        ASSERT EX_data_out = x"FF800005" REPORT "SRA FAILED" SEVERITY error;
        REPORT to_string(EX_data_out) SEVERITY note;

        --------------------------- sra -------------------------------------

        --------------------------- lw -------------------------------------
        WAIT FOR clk_period;

        EX_Rs_in <= x"00000567";
        EX_Rt_in <= x"00001002";
        EX_immediate_value <= x"00000007";
        EX_operand_code <= "010100";
        ex_forward_data <= x"00000011";
        mem_forward_data <= x"00000020";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00111";

        -- load word
        -- choose Rs Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00001569" 94ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00001569" REPORT "LW FAILED" SEVERITY error;

        --------------------------- lw -------------------------------------

        --------------------------- sw -------------------------------------
        WAIT FOR clk_period;

        EX_Rs_in <= x"00000567";
        EX_Rt_in <= x"00002030";
        EX_immediate_value <= x"00000007";
        EX_operand_code <= "010101";
        ex_forward_data <= x"00000011";
        mem_forward_data <= x"00000020";
        WB_enable_in <= '0';
        store_enable_in <= '0';
        load_enable_in <= '0';
        Rd_in <= "00111";

        -- load word
        -- choose Rs Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- expect x"00002597" 96ns
        REPORT to_string(EX_data_out) SEVERITY note;
        ASSERT EX_data_out = x"00002597" REPORT "SW FAILED" SEVERITY error;

        --------------------------- sw -------------------------------------

        --------------------------- stall -------------------------------------

        WAIT FOR clk_period;

        EX_Rs_in <= x"00000567";
        EX_Rt_in <= x"00002030";
        EX_immediate_value <= x"00000007";
        EX_operand_code <= "010101";
        ex_forward_data <= x"00000011";
        mem_forward_data <= x"00000020";
        WB_enable_in <= '1';
        store_enable_in <= '0';
        load_enable_in <= '1';
        Rd_in <= "00111";

        ex_stall <= '1';

        -- load word
        -- choose Rs Rt
        Rs_mux_select0 <= '0';
        Rs_mux_select1 <= '1';
        Rt_mux_select0 <= '0';
        Rt_mux_select1 <= '1';
        WAIT FOR clk_period;
        -- 98ns
        REPORT to_string(EX_data_out) SEVERITY note;
        REPORT to_string(WB_enable_out) SEVERITY note;
        REPORT to_string(store_enable_out) SEVERITY note;
        REPORT to_string(load_enable_out) SEVERITY note;
        REPORT to_string(Rd_out) SEVERITY note;
        REPORT to_string(mem_data_out) SEVERITY note;

        ex_stall <= '0';
        WAIT FOR clk_period;
        -- 100ns
        REPORT to_string(EX_data_out) SEVERITY note;
        REPORT to_string(WB_enable_out) SEVERITY note;
        REPORT to_string(store_enable_out) SEVERITY note;
        REPORT to_string(load_enable_out) SEVERITY note;
        REPORT to_string(Rd_out) SEVERITY note;
        REPORT to_string(mem_data_out) SEVERITY note;
        --------------------------- stall -------------------------------------
	
    WAIT;
    END PROCESS;
END ARCHITECTURE;
