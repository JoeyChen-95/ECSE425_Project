LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.ALL;

ENTITY Controller IS
    PORT (
        -- We only accept clk, reset, and dump signals
        -- from the testbench.
        clk, reset, dump, enable : IN STD_LOGIC;
    );

END ENTITY;

ARCHITECTURE behavior OF Controller IS

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- ++++++++++++++++++++++    IF    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- IF Input Signals
    SIGNAL pc_in_pc : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    -- IF Output Signals
    SIGNAL pc_out_instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_out_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- ++++++++++++++++++++++    ID    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- ID Input Signals
    SIGNAL id_in_instruction : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL id_in_pc : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL id_in_wb_write_enable : STD_LOGIC := '0';
    SIGNAL id_in_wb_write_address : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL id_in_wb_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    -- ID Output Signals
    SIGNAL id_out_rs_idx : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL id_out_rt_idx : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL id_out_branch_taken : STD_LOGIC;
    SIGNAL id_out_branch_address : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL id_out_rs : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL id_out_rt : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL id_out_imm : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL id_out_opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL id_out_wb_enable : STD_LOGIC;
    SIGNAL id_out_store_enable : STD_LOGIC;
    SIGNAL id_out_imm_enable : STD_LOGIC;
    SIGNAL id_out_load_enable : STD_LOGIC;
    SIGNAL id_out_rd : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL id_out_is_branch : STD_LOGIC;

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- ++++++++++++++++++++++    EX    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- EX Input Signals
    SIGNAL ex_in_opcode : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ex_in_rs : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ex_in_rt : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ex_in_imm : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ex_in_rd : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ex_in_ex_forward : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ex_in_mem_forward : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ex_in_store_enable : STD_LOGIC := '0';
    SIGNAL ex_in_load_enable : STD_LOGIC := '0';
    SIGNAL ex_in_imm_enable : STD_LOGIC := '0';
    SIGNAL ex_in_wb_enable : STD_LOGIC := '0';

    -- EX Output Signals
    SIGNAL ex_out_wb_enable : STD_LOGIC;
    SIGNAL ex_out_store_enable : STD_LOGIC;
    SIGNAL ex_out_load_enable : STD_LOGIC;
    SIGNAL ex_out_rd : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL ex_out_mem_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_out_alu_data : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- EX Control Signals
    SIGNAL ex_control_rs_select_forwarding : STD_LOGIC := '0';
    SIGNAL ex_control_rt_select_forwarding : STD_LOGIC := '0';
    SIGNAL ex_control_rs_select_forwarding_mem : STD_LOGIC := '0';
    SIGNAL ex_control_rt_select_forwarding_mem : STD_LOGIC := '0';

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- +++++++++++++++++++++    MEM    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- MEM Input Signals
    SIGNAL mem_in_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_in_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_in_write_enable : STD_LOGIC := '0';
    SIGNAL mem_in_load_enable : STD_LOGIC := '0';
    SIGNAL mem_in_rd : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_in_wb_enable : STD_LOGIC := '0';

    -- MEM Output Signals
    SIGNAL mem_data_forward : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_out_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_out_wb_enable : STD_LOGIC;
    SIGNAL mem_out_rd : STD_LOGIC_VECTOR (4 DOWNTO 0);

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- ++++++++++++++++++++++    WB    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- WB Input
    SIGNAL wb_in_wb_enable : STD_LOGIC := '0';
    SIGNAL wb_in_wb_rd : STD_LOGIC_VECTOR (4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wb_in_wb_data : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');

    -- WB Output
    SIGNAL wb_out_enable : STD_LOGIC;
    SIGNAL wb_out_rd : STD_LOGIC_VECTOR (4 DOWNTO 0);
    SIGNAL wb_out_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL wb_out_forwarding_data : STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- ++++++++++++++++++++++    IF    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    IF_Stage : ENTITY work.PC
        PORT MAP(
            pc_clk => clk,
            pc_reset => reset,
            pc_in => pc_in_pc,

            instruction => pc_out_instruction,
            pc_out => pc_out_pc
        );

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- ++++++++++++++++++++++    ID    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ID_Stage : ENTITY work.ID
        PORT MAP(
            clock => clk,
            reset => reset,
            dump => dump,
            instruction => id_in_instruction,
            pc_in => id_in_pc,
            wb_write_enable => id_in_wb_write_enable,
            wb_write_address => id_in_wb_write_address,
            wb_data => id_in_wb_data,

            rs_idx => id_out_rs_idx,
            rt_idx => id_out_rt_idx,
            is_branch => id_out_is_branch,
            branch_taken => id_out_branch_taken,
            branch_address => id_out_branch_address,
            ID_Rs_out => id_out_rs,
            ID_Rt_out => id_out_rt,
            ID_IM => id_out_imm,
            ID_Op_code => id_out_opcode,
            WB_enable => id_out_wb_enable,
            store_enable => id_out_store_enable,
            imm_enable => id_out_imm_enable,
            load_enable => id_out_load_enable,
            Rd_out => id_out_rd
        );

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- ++++++++++++++++++++++    EX    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    EX_Stage : ENTITY work.EX
        PORT MAP(
            ex_clock => clk,
            EX_Rs_in => ex_in_rs,
            EX_Rt_in => ex_in_rt,
            EX_immediate_value => ex_in_imm,
            EX_operand_code => ex_in_opcode,
            WB_enable_in => ex_in_wb_enable,
            store_enable_in => ex_in_store_enable,
            load_enable_in => ex_in_load_enable,
            imm_enable => ex_in_imm_enable,
            Rd_in => ex_in_rd,
            ex_forward_data => ex_in_ex_forward,
            mem_forward_data => ex_in_mem_forward,

            WB_enable_out => ex_out_wb_enable,
            store_enable_out => ex_out_store_enable,
            load_enable_out => ex_out_load_enable,
            Rd_out => ex_out_rd,

            rs_select_forwarding => ex_control_rs_select_forwarding,
            rs_select_forwarding_mem => ex_control_rs_select_forwarding_mem,
            rt_select_forwarding => ex_control_rt_select_forwarding,
            rt_select_forwarding_mem => ex_control_rt_select_forwarding_mem,

            mem_data_out => ex_out_mem_data,
            EX_data_out => ex_out_alu_data
        );

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- +++++++++++++++++++++++   MEM   +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    MEM_Stage : ENTITY work.MEM
        PORT MAP(
            dump => dump,
            clk => clk,
            reset => reset,
            mem_in_data => mem_in_data,
            in_address => mem_in_address,
            write_enable => mem_in_write_enable,
            load_enable => mem_in_load_enable,
            dest_reg => mem_in_rd,
            enable_writeback => mem_in_wb_enable,

            data_forward => mem_data_forward,
            out_data => mem_out_data,
            wb_enable => mem_out_wb_enable,
            wb_dest_reg => mem_out_rd
        );

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- ++++++++++++++++++++++++   WB   +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    WB_Stage : ENTITY work.WB
        PORT MAP(
            clk => clk,
            mem_WB_enable => wb_in_wb_enable,
            mem_WB_address => wb_in_wb_rd,
            mem_WB_data => wb_in_wb_data,

            WB_enable_out => wb_out_enable,
            WB_address_out => wb_out_rd,
            WB_data_out => wb_out_data,
            WB_forwarding_data => wb_out_forwarding_data
        );

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- +++++++++++++++++++++  PROCESS  +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- The forwarding data is
    -- always hard-wired to the
    -- EX stage.
    ex_in_ex_forward <= mem_data_forward;
    ex_in_mem_forward <= wb_out_forwarding_data;

    controller_process : PROCESS (clk, reset)

        -- These internal variables are used for
        -- hazard detection.
        VARIABLE id_reg1_internal : unsigned(4 DOWNTO 0);
        VARIABLE id_reg2_internal : unsigned(4 DOWNTO 0);
    BEGIN
        IF (rising_edge(reset)) THEN
            -- Set all input signal to 0.
            pc_in_pc <= (OTHERS => '0');

            id_in_instruction <= (5 => '1', OTHERS => '0');
            id_in_pc <= (OTHERS => '0');
            id_in_wb_write_enable <= '0';
            id_in_wb_write_address <= (OTHERS => '0');
            id_in_wb_data <= (OTHERS => '0');

            ex_in_imm <= (OTHERS => '0');
            ex_in_wb_enable <= '0';
            ex_in_store_enable <= '0';
            ex_in_load_enable <= '0';
            ex_in_imm_enable <= '0';
            ex_in_rd <= (OTHERS => '0');
            ex_in_rs <= (OTHERS => '0');
            ex_in_rt <= (OTHERS => '0');
            ex_control_rs_select_forwarding <= '0';
            ex_control_rs_select_forwarding_mem <= '0';
            ex_control_rt_select_forwarding <= '0';
            ex_control_rt_select_forwarding_mem <= '0';
            ex_in_opcode <= "000000";

            mem_in_data <= (OTHERS => '0');
            mem_in_address <= (OTHERS => '0');
            mem_in_write_enable <= '0';
            mem_in_load_enable <= '0';
            mem_in_rd <= (OTHERS => '0');
            mem_in_wb_enable <= '0';

            wb_in_wb_enable <= '0';
            wb_in_wb_rd <= (OTHERS => '0');
            wb_in_wb_data <= (OTHERS => '0');
        END IF;

        IF (falling_edge(clk) AND enable = '1') THEN
            -- The controller only works at
            -- the falling edge of the clock.

            id_reg1_internal := unsigned(id_out_rs_idx);
            id_reg2_internal := unsigned(id_out_rt_idx);

            -- Hazard detection.
            -- The only hazard we may encounter is
            -- RAW. Also, the only case that the
            -- RAW harzard cannot be resolved via
            -- forwarding is when either register
            -- at the ID stage matches the target
            -- register of the WB stage.
            IF (wb_out_enable = '1' AND (unsigned(wb_out_rd) = id_reg1_internal OR unsigned(wb_out_rd) = id_reg2_internal)) OR
                (id_out_is_branch = '1' AND ((id_reg1_internal /= "00000" AND (id_reg1_internal = unsigned(ex_out_rd) OR id_reg1_internal = unsigned(mem_out_rd))) OR (id_reg2_internal /= "00000" AND (id_reg2_internal = unsigned(ex_out_rd) OR id_reg2_internal = unsigned(mem_out_rd))))) THEN
                -- Stall the ID and FX stage,
                -- that is, we keep their current
                -- input. 
                -- 
                -- Furthermore, we must issue
                -- fake commands, i.e., add r0 r0 r0,
                -- to stall the ex stage.
                ex_in_opcode <= "000000";
                ex_in_rs <= (OTHERS => '0');
                ex_in_rt <= (OTHERS => '0');
                ex_in_imm <= (OTHERS => '0');
                ex_in_rd <= (OTHERS => '0');
                ex_in_store_enable <= '0';
                ex_in_load_enable <= '0';
                ex_in_imm_enable <= '0';
                ex_in_wb_enable <= '0';
                ex_control_rs_select_forwarding <= '0';
                ex_control_rs_select_forwarding_mem <= '0';
                ex_control_rt_select_forwarding <= '0';
                ex_control_rt_select_forwarding_mem <= '0';

                -- Move the EX output to the MEM
                mem_in_data <= ex_out_mem_data;
                mem_in_address <= ex_out_alu_data;
                mem_in_write_enable <= ex_out_store_enable;
                mem_in_load_enable <= ex_out_load_enable;
                mem_in_rd <= ex_out_rd;
                mem_in_wb_enable <= ex_out_wb_enable;

                -- Move the MEM output to the WB
                wb_in_wb_enable <= mem_out_wb_enable;
                wb_in_wb_rd <= mem_out_rd;
                wb_in_wb_data <= mem_out_data;

                -- Move the WB output to registers
                id_in_wb_write_enable <= wb_out_enable;
                id_in_wb_write_address <= wb_out_rd;
                id_in_wb_data <= wb_out_data;

            ELSE
                -- There is no harzard.

                IF (id_out_branch_taken = '1') THEN
                    -- The branch is taken, we must update
                    -- pc_in and issue a fake command to
                    -- ID.
                    pc_in_pc <= id_out_branch_address;
                    id_in_instruction <= (5 => '1', OTHERS => '0');
                    id_in_pc <= (OTHERS => '0');
                ELSE
                    -- Either there is no branch or the
                    -- branch is not taken. We proceed
                    -- as normal.
                    pc_in_pc <= pc_out_pc;
                    id_in_instruction <= pc_out_instruction;
                    id_in_pc <= pc_out_pc;
                END IF;

                -- No matter the branch is taken or not,
                -- the data from the WB stage always goes
                -- into the registers.
                id_in_wb_write_enable <= wb_out_enable;
                id_in_wb_write_address <= wb_out_rd;
                id_in_wb_data <= wb_out_data;

                -- The EX stage always accepts input signals
                -- from the ID stage if there is no data harzard.
                ex_in_opcode <= id_out_opcode;
                ex_in_rs <= id_out_rs;
                ex_in_rt <= id_out_rt;
                ex_in_imm <= id_out_imm;
                ex_in_rd <= id_out_rd;
                ex_in_store_enable <= id_out_store_enable;
                ex_in_load_enable <= id_out_load_enable;
                ex_in_imm_enable <= id_out_imm_enable;
                ex_in_wb_enable <= id_out_wb_enable;

                -- Next, we consider data fowarding.
                -- We begin by considering forwarding
                -- with Rt. 
                -- 
                -- Rt only needs forwarding from MEM or WB if
                -- the following criterias are met.
                -- 1. id_out_imm_enable = '0'
                -- 2. id_out_rt_idx /= '0'
                -- 3. id_out_rt_idx = ex_out_rd or id_out_rt_idx = mem_out_rd
                IF (
                    id_out_imm_enable = '0' AND
                    id_out_rt_idx /= "00000" AND
                    ((id_out_rt_idx = ex_out_rd) OR (id_out_rt_idx = mem_out_rd))
                    ) THEN
                    -- There is forwarding.
                    IF (id_out_rt_idx = ex_out_rd) THEN
                        -- Forwarding from EX.
                        ex_control_rt_select_forwarding <= '1';
                        ex_control_rt_select_forwarding_mem <= '0';
                    ELSIF (id_out_rt_idx = mem_out_rd) THEN
                        -- Forwarding from MEM.
                        ex_control_rt_select_forwarding <= '1';
                        ex_control_rt_select_forwarding_mem <= '1';
                    END IF;
                ELSE
                    -- There is no forwarding for Rt.
                    ex_control_rt_select_forwarding <= '0';
                    ex_control_rt_select_forwarding_mem <= '0';
                END IF;

                -- Rs only needs forwarding from MEM or WB if
                -- the following criterias are met.
                -- 1. id_out_rs_idx /= '0'
                -- 2. id_out_rs_idx = ex_out_rd or id_out_rs_idx = mem_out_rd
                IF (
                    id_out_rs_idx /= "00000" AND
                    ((id_out_rs_idx = ex_out_rd) OR (id_out_rs_idx = mem_out_rd))
                    ) THEN
                    -- There is forwarding.
                    IF (id_out_rs_idx = ex_out_rd) THEN
                        -- Forwarding from EX.
                        ex_control_rs_select_forwarding <= '1';
                        ex_control_rs_select_forwarding_mem <= '0';
                    ELSIF (id_out_rs_idx = mem_out_rd) THEN
                        -- Forwarding from MEM.
                        ex_control_rs_select_forwarding <= '1';
                        ex_control_rs_select_forwarding_mem <= '1';
                    END IF;
                ELSE
                    -- There is no forwarding for Rs.
                    ex_control_rs_select_forwarding <= '0';
                    ex_control_rs_select_forwarding_mem <= '0';
                END IF;

                -- EX to MEM
                mem_in_data <= ex_out_mem_data;
                mem_in_address <= ex_out_alu_data;
                mem_in_write_enable <= ex_out_store_enable;
                mem_in_load_enable <= ex_out_load_enable;
                mem_in_rd <= ex_out_rd;
                mem_in_wb_enable <= ex_out_wb_enable;

                -- MEM to WB
                wb_in_wb_enable <= mem_out_wb_enable;
                wb_in_wb_rd <= mem_out_rd;
                wb_in_wb_data <= mem_out_data;
            END IF;

        END IF;
    END PROCESS;

END behavior;