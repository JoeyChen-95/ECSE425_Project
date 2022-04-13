-- Code your design here
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY ID IS
    PORT (
        -- Clock, reset, stall
        clock, reset, stall, dump : IN STD_LOGIC;

        -- Signals from the fetch stage.
        instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Signals from the WB stage.
        wb_write_enable : IN STD_LOGIC;
        wb_write_address : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        wb_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Signals passed to the fetch stage due to branching.
        branch_taken : OUT STD_LOGIC;
        branch_address : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Signals passed on to later stages.
        ID_Rs_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --Rs
        ID_Rt_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --Rt
        ID_IM : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); --immediate value
        ID_Op_code : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        WB_enable : OUT STD_LOGIC; --indicate the write back enable
        store_enable : OUT STD_LOGIC; -- indicate the store in mem
        imm_enable : OUT STD_LOGIC;
        load_enable : OUT STD_LOGIC; -- indicate the load in mem
        Rd : OUT STD_LOGIC_VECTOR (4 DOWNTO 0); --indicate the Rd
    );

END ID;

ARCHITECTURE arch OF ID IS

    SIGNAL r1 : STD_LOGIC_VECTOR(4 DOWNTO 0); -- Rs from the instruction.
    SIGNAL r2 : STD_LOGIC_VECTOR(4 DOWNTO 0); -- Rt from the instruction.
    SIGNAL branch_ctl : STD_LOGIC_VECTOR (2 DOWNTO 0); -- Branch control from the instruction.

    SIGNAL rs_out_internal : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Rs used internally.
    SIGNAL rt_out_internal : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Rt used internally.

    SIGNAL imm_output_internal : STD_LOGIC_VECTOR(31 DOWNTO 0); -- The immediate value.

    SIGNAL branch_address_internal : STD_LOGIC_VECTOR(31 DOWNTO 0); -- The calculated branch address.
    SIGNAL branch_ri_control : STD_LOGIC; -- Used to toggle between rs and imm for branch address.
    SIGNAL link_enable : STD_LOGIC -- Enable the register to store link address.
    SIGNAL link_val : STD_LOGIC_VECTOR(31 DOWNTO 0) -- The link address.

BEGIN

    registers : ENTITY.work.Registers
        PORT MAP(
            dump => dump;
            clock => clock;
            reset => reset;
            r1 => r1;
            r2 => r2;
            wb_write_enable => wb_write_enable;
            wb_write_address => wb_write_address;
            wb_write_data => wb_data;
            reg1_out => rs_out_internal;
            reg2_out => rt_out_internal;
            link_enable => link_enable;
            link_val => link_val;
        );

    comparator : ENTITY.work.Comparator
        PORT MAP(
            branch_ctl => branch_ctl;
            reg1 => rs_out_internal;
            reg2 => rt_out_internal;
            branch_taken => branch_taken;
        );

    -- The branch prediction, and branch control.
    branch_address_internal <= rs_out_internal WHEN branch_ri_control = '1' ELSE
        imm_output_internal;
    branch_address <= branch_address_internal WHEN branch_taken = '1' ELSE
        pc_in;

    -- Wire output to internal signals (registers, immediate values)
    ID_Rs_out <= rs_out_internal;
    ID_Rt_out <= rt_out_internal;
    ID_IM <= imm_output_internal;

    decode_process : PROCESS (clock)

        -- Parts of the instruction to be decoded.
        -- Notice that we only need to accomadate for
        -- R, I, and J instructions in this project.
        VARIABLE opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
        VARIABLE rs : STD_LOGIC_VECTOR(4 DOWNTO 0); -- For R instructions only.
        VARIABLE rt : STD_LOGIC_VECTOR(4 DOWNTO 0); -- For R instructions only.
        VARIABLE rd : STD_LOGIC_VECTOR(4 DOWNTO 0); -- For R instructions only.
        VARIABLE shamt : STD_LOGIC_VECTOR(4 DOWNTO 0); -- For R instructions only.
        VARIABLE funct : STD_LOGIC_VECTOR(5 DOWNTO 0); -- For R instructions only.
        VARIABLE imm : STD_LOGIC_VECTOR(15 DOWNTO 0); -- For I instructions only.
        VARIABLE addr : STD_LOGIC_VECTOR(25 DOWNTO 0); -- For J instructions only.

    BEGIN

        IF (rising_edge(clock)) THEN

            IF (stall = '1') THEN

            ELSE
                -- If not stall.
                -- We shall first extract relevant information
                -- from the incoming instruction.
                opcode := instruction(31 DOWNTO 26);
                rs := instruction(25 DOWNTO 21);
                rt := instruction(20 DOWNTO 16);
                rd := instruction(15 DOWNTO 11);
                shamt := instruction(10 DOWNTO 6);
                funct := instruction(5 DOWNTO 0);
                imm := instruction(15 DOWNTO 0);
                addr := instruction(25 DOWNTO 0);

                IF (opcode = "000000") THEN
                    -- For R-type instructions,
                    -- fetch r1 and r2.
                    r1 <= rs;
                    r2 <= rt;
                    Rd <= rd;
                    link_enable <= '0';
                    link_val <= (OTHERS => '0');

                    -- For each of the instruction
                    -- below, we only need to
                    -- assign ID_Op_code and WB_enable.
                    IF (funct = "100000") THEN
                        -- ADD
                        ID_Op_code <= "000000";
                        imm_output_internal <= (OTHERS >= '0');
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals.
                        WB_enable <= '1';
                        imm_enable <= '0';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "100010") THEN
                        -- SUB
                        ID_Op_code <= "000001";
                        imm_output_internal <= (OTHERS >= '0');
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals.
                        WB_enable <= '1';
                        imm_enable <= '0';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "011000") THEN
                        -- MULT
                        ID_Op_code <= "000011";
                        imm_output_internal <= (OTHERS >= '0');
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals.
                        WB_enable <= '0';
                        imm_enable <= '0';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "011010") THEN
                        -- DIV
                        ID_Op_code <= "000100";
                        imm_output_internal <= (OTHERS >= '0');
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals.
                        WB_enable <= '0';
                        imm_enable <= '0';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "101010") THEN
                        -- SLT
                        ID_Op_code <= "000101";
                        imm_output_internal <= (OTHERS >= '0');
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals.
                        WB_enable <= '1';
                        imm_enable <= '0';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "100100") THEN
                        -- AND
                        ID_Op_code <= "000111";
                        imm_output_internal <= (OTHERS >= '0');
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals.
                        WB_enable <= '1';
                        imm_enable <= '0';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "100101") THEN
                        -- OR
                        ID_Op_code <= "001000";
                        imm_output_internal <= (OTHERS >= '0');
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals.
                        WB_enable <= '1';
                        imm_enable <= '0';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "100111") THEN
                        -- NOR
                        ID_Op_code <= "001001";
                        imm_output_internal <= (OTHERS >= '0');
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals.
                        WB_enable <= '1';
                        imm_enable <= '0';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "100110") THEN
                        --XOR
                        ID_Op_code <= "001010";
                        imm_output_internal <= (OTHERS >= '0');
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals.
                        WB_enable <= '1';
                        imm_enable <= '0';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "010000") THEN
                        -- MFHI
                        ID_Op_code <= "001110";
                        imm_output_internal <= (OTHERS >= '0');
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals.
                        WB_enable <= '1';
                        imm_enable <= '0';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "010010") THEN
                        -- MFLO
                        ID_Op_code <= "001111";
                        imm_output_internal <= (OTHERS >= '0');
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals.
                        WB_enable <= '1';
                        imm_enable <= '0';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "000000") THEN
                        -- SLL
                        imm_output_internal <= STD_LOGIC_VECTOR(resize(signed(shamt), immediate_out_internal'length));
                        ID_Op_code <= "010001";
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals
                        WB_enable <= '1';
                        imm_enable <= '1';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "000010") THEN
                        -- SRL
                        imm_output_internal <= STD_LOGIC_VECTOR(resize(signed(shamt), immediate_out_internal'length));
                        ID_Op_code <= "010010";
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals.
                        WB_enable <= '1';
                        imm_enable <= '1';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "000011") THEN
                        -- SRA
                        imm_output_internal <= STD_LOGIC_VECTOR(resize(signed(shamt), immediate_out_internal'length));
                        ID_Op_code <= "010011";
                        branch_ctl <= "101";
                        branch_ri_control <= '0';

                        -- Set common signals.
                        WB_enable <= '1';
                        imm_enable <= '1';
                        store_enable <= '0';
                        load_enable <= '0';
                    ELSIF (funct = "001000") THEN
                        -- JR
                        branch_ctl <= "010";
                        imm_output_internal <= (OTHERS >= '0');
                        branch_ri_control <= '1';

                        -- Output fake add instructions,
                        -- whose result will not be saved.
                        ID_Op_code <= "000000";

                        -- Set common signals.
                        WB_enable <= '0';
                        imm_enable <= '0';
                        store_enable <= '0';
                        load_enable <= '0';
                    END IF;
                ELSIF (opcode = "000010") THEN
                    -- J

                    -- We need to issue fake commands.
                    r1 <= (OTHERS => '0');
                    r2 <= (OTHERS => '0');
                    Rd <= (OTHERS => '0');
                    ID_Op_code <= (OTHERS => '0');

                    -- J-specific signals.
                    branch_ctl <= "010";
                    imm_output_internal <= to_stdlogicvector(to_bitvector(STD_LOGIC_VECTOR(resize(signed(addr), imm_output_internal'length))) SLL 2);
                    branch_ri_control <= '0';
                    link_enable <= '0';
                    link_val <= (OTHERS => '0');

                    -- Set common signals.
                    WB_enable <= '0';
                    imm_enable <= '0';
                    store_enable <= '0';
                    load_enable <= '0';

                ELSIF (opcode = "000011") THEN
                    -- JAL

                    -- We need to issue fake commands.
                    r1 <= (OTHERS => '0');
                    r2 <= (OTHERS => '0');
                    Rd <= (OTHERS => '0');
                    ID_Op_code <= (OTHERS => '0');

                    -- J-specific signals.
                    branch_ctl <= "010";
                    imm_output_internal <= to_stdlogicvector(to_bitvector(STD_LOGIC_VECTOR(resize(signed(addr), imm_output_internal'length))) SLL 2);
                    branch_ri_control <= '0';
                    link_enable <= '1';
                    link_val <= pc_in;

                    -- Set common signals.
                    WB_enable <= '0';
                    imm_enable <= '0';
                    store_enable <= '0';
                    load_enable <= '0';

                ELSIF (opcode = "101011") THEN
                    -- SW

                ELSIF (opcode = "100011") THEN
                    -- LW

                ELSE
                    -- I-type Instructions.

                END IF;

            END IF;
        END IF;

    END PROCESS;

END arch;