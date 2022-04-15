LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY ID IS
    PORT (
        -- Clock, reset
        clock, reset, dump : IN STD_LOGIC;

        -- Signals from the fetch stage.
        instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Signals from the WB stage.
        wb_write_enable : IN STD_LOGIC;
        wb_write_address : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        wb_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Signals passed to controller for forwarding 
        -- and hazard detection
        rs_idx : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        rt_idx : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        is_branch : OUT STD_LOGIC;

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
        Rd_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0) --indicate the Rd
    );
END ENTITY;

ARCHITECTURE arch OF ID IS

    SIGNAL r1 : STD_LOGIC_VECTOR(4 DOWNTO 0); -- Rs from the instruction.
    SIGNAL r2 : STD_LOGIC_VECTOR(4 DOWNTO 0); -- Rt from the instruction.
    SIGNAL branch_ctl : STD_LOGIC_VECTOR (2 DOWNTO 0); -- Branch control from the instruction.

    SIGNAL rs_out_internal : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Rs used internally.
    SIGNAL rt_out_internal : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Rt used internally.

    SIGNAL imm_output_internal : STD_LOGIC_VECTOR(31 DOWNTO 0); -- The immediate value.

    SIGNAL branch_address_internal : STD_LOGIC_VECTOR(31 DOWNTO 0); -- The calculated branch address.
    SIGNAL branch_ri_control : STD_LOGIC; -- Used to toggle between rs and imm for branch address.
    SIGNAL link_enable : STD_LOGIC; -- Enable the register to store link address.
    SIGNAL link_val : STD_LOGIC_VECTOR(31 DOWNTO 0); -- The link address.

BEGIN
    reg : ENTITY work.Registers
        PORT MAP(
            dump => dump,
            clock => clock,
            reset => reset,
            r1 => r1,
            r2 => r2,
            wb_write_enable => wb_write_enable,
            wb_write_address => wb_write_address,
            wb_write_data => wb_data,
            reg1_out => rs_out_internal,
            reg2_out => rt_out_internal,
            link_enable => link_enable,
            link_val => link_val
        );

    comp : ENTITY work.Comparator
        PORT MAP(
            branch_ctl => branch_ctl,
            reg1 => rs_out_internal,
            reg2 => rt_out_internal,
            branch_taken => branch_taken
        );

    -- Pass on register information.
    rs_idx <= r1;
    rt_idx <= r2;

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
        VARIABLE rs : STD_LOGIC_VECTOR(4 DOWNTO 0); -- For R and I instructions only.
        VARIABLE rt : STD_LOGIC_VECTOR(4 DOWNTO 0); -- For R and I instructions only.
        VARIABLE rd : STD_LOGIC_VECTOR(4 DOWNTO 0); -- For R instructions only.
        VARIABLE shamt : STD_LOGIC_VECTOR(4 DOWNTO 0); -- For R instructions only.
        VARIABLE funct : STD_LOGIC_VECTOR(5 DOWNTO 0); -- For R instructions only.
        VARIABLE imm : STD_LOGIC_VECTOR(15 DOWNTO 0); -- For I instructions only.
        VARIABLE addr : STD_LOGIC_VECTOR(25 DOWNTO 0); -- For J instructions only.
        VARIABLE is_branch_internal : STD_LOGIC;

    BEGIN

        IF (rising_edge(clock)) THEN
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
            is_branch_internal := '0';

            IF (opcode = "000000") THEN
                -- For each of the instruction
                -- below, we only need to
                -- assign ID_Op_code and WB_enable.
                IF (funct = "100000") THEN
                    -- ADD
                    ID_Op_code <= "000000";
                    imm_output_internal <= (OTHERS => '0');
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
                    imm_output_internal <= (OTHERS => '0');
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
                    imm_output_internal <= (OTHERS => '0');
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
                    imm_output_internal <= (OTHERS => '0');
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
                    imm_output_internal <= (OTHERS => '0');
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
                    imm_output_internal <= (OTHERS => '0');
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
                    imm_output_internal <= (OTHERS => '0');
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
                    imm_output_internal <= (OTHERS => '0');
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
                    imm_output_internal <= (OTHERS => '0');
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
                    imm_output_internal <= (OTHERS => '0');
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
                    imm_output_internal <= (OTHERS => '0');
                    branch_ctl <= "101";
                    branch_ri_control <= '0';

                    -- Set common signals.
                    WB_enable <= '1';
                    imm_enable <= '0';
                    store_enable <= '0';
                    load_enable <= '0';

                ELSIF (funct = "000000") THEN
                    -- SLL
                    imm_output_internal <= STD_LOGIC_VECTOR(resize(signed(shamt),
                        imm_output_internal'length));
                    rs := rt;
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
                    imm_output_internal <= STD_LOGIC_VECTOR(resize(signed(shamt),
                        imm_output_internal'length));
                    rs := rt;
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
                    imm_output_internal <= STD_LOGIC_VECTOR(resize(signed(shamt),
                        imm_output_internal'length));
                    rs := rt;
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
                    imm_output_internal <= (OTHERS => '0');
                    branch_ri_control <= '1';
                    is_branch_internal := '1';

                    -- Output fake add instructions,
                    -- whose result will not be saved.
                    ID_Op_code <= "000000";

                    -- Set common signals.
                    WB_enable <= '0';
                    imm_enable <= '0';
                    store_enable <= '0';
                    load_enable <= '0';
                END IF;

                -- For R-type instructions,
                -- fetch r1 and r2.
                r1 <= rs;
                r2 <= rt;
                Rd_out <= rd;
                link_enable <= '0';
                link_val <= (OTHERS => '0');

            ELSIF (opcode = "000010") THEN
                -- J

                -- We need to issue fake commands.
                r1 <= (OTHERS => '0');
                r2 <= (OTHERS => '0');
                Rd_out <= (OTHERS => '0');
                ID_Op_code <= (OTHERS => '0');
                is_branch_internal := '1';

                -- J-specific signals.
                branch_ctl <= "010";
                imm_output_internal <= STD_LOGIC_VECTOR(resize(unsigned(addr), imm_output_internal'length));
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
                Rd_out <= (OTHERS => '0');
                ID_Op_code <= (OTHERS => '0');
                is_branch_internal := '1';

                -- J-specific signals.
                branch_ctl <= "010";
                imm_output_internal <= STD_LOGIC_VECTOR(resize(unsigned(addr), imm_output_internal'length));
                branch_ri_control <= '0';
                link_enable <= '1';
                link_val <= pc_in;

                -- Set common signals.
                WB_enable <= '0';
                imm_enable <= '0';
                store_enable <= '0';
                load_enable <= '0';

            ELSE
                -- I-type Instructions.
                imm_enable <= '1';
                r1 <= rs;
                r2 <= rt;
                link_enable <= '0';
                link_val <= pc_in;

                IF (opcode = "101011") THEN
                    -- SW
                    Rd_out <= (OTHERS => '0');
                    ID_Op_code <= "010101";

                    -- J-specific signals.
                    branch_ctl <= "101";
                    imm_output_internal <= STD_LOGIC_VECTOR(resize(signed(imm),
                        imm_output_internal'length));
                    branch_ri_control <= '1';

                    -- Set common signals.
                    WB_enable <= '0';
                    store_enable <= '1';
                    load_enable <= '0';

                ELSIF (opcode = "010100") THEN
                    -- LW
                    Rd_out <= rt;
                    ID_Op_code <= "010101";

                    -- J-specific signals.
                    branch_ctl <= "101";
                    imm_output_internal <= STD_LOGIC_VECTOR(resize(signed(imm),
                        imm_output_internal'length));
                    branch_ri_control <= '1';

                    -- Set common signals.
                    WB_enable <= '1';
                    store_enable <= '0';
                    load_enable <= '1';

                ELSIF (opcode = "000100") THEN
                    -- BEQ
                    Rd_out <= (OTHERS => '0');
                    ID_Op_code <= (OTHERS => '0');
                    is_branch_internal := '1';

                    -- J-specific signals.
                    branch_ctl <= "000";
                    imm_output_internal <= STD_LOGIC_VECTOR(signed(pc_in) + signed(imm));
                    branch_ri_control <= '0';

                    -- Set common signals.
                    WB_enable <= '0';
                    store_enable <= '0';
                    load_enable <= '0';

                ELSIF (opcode = "000101") THEN
                    -- BNE
                    Rd_out <= (OTHERS => '0');
                    ID_Op_code <= (OTHERS => '0');
                    is_branch_internal := '1';

                    -- J-specific signals.
                    branch_ctl <= "001";
                    imm_output_internal <= STD_LOGIC_VECTOR(signed(pc_in) + signed(imm));
                    branch_ri_control <= '0';

                    -- Set common signals.
                    WB_enable <= '0';
                    store_enable <= '0';
                    load_enable <= '0';

                ELSIF (opcode = "001000") THEN
                    -- ADDI
                    Rd_out <= rt;
                    ID_Op_code <= "000010";

                    -- J-specific signals.
                    branch_ctl <= "101";
                    imm_output_internal <= STD_LOGIC_VECTOR(resize(signed(imm),
                        imm_output_internal'length));
                    branch_ri_control <= '0';

                    -- Set common signals.
                    WB_enable <= '1';
                    store_enable <= '0';
                    load_enable <= '0';

                ELSIF (opcode = "001010") THEN
                    -- SLTI
                    Rd_out <= rt;
                    ID_Op_code <= "000110";

                    -- J-specific signals.
                    branch_ctl <= "101";
                    imm_output_internal <= STD_LOGIC_VECTOR(resize(unsigned(imm),
                        imm_output_internal'length));
                    branch_ri_control <= '0';

                    -- Set common signals.
                    WB_enable <= '1';
                    store_enable <= '0';
                    load_enable <= '0';

                ELSIF (opcode = "001100") THEN
                    -- ANDI
                    Rd_out <= rt;
                    ID_Op_code <= "001011";

                    -- J-specific signals.
                    branch_ctl <= "101";
                    imm_output_internal <= STD_LOGIC_VECTOR(resize(unsigned(imm),
                        imm_output_internal'length));
                    branch_ri_control <= '0';

                    -- Set common signals.
                    WB_enable <= '1';
                    store_enable <= '0';
                    load_enable <= '0';

                ELSIF (opcode = "001101") THEN
                    -- ORI
                    Rd_out <= rt;
                    ID_Op_code <= "001100";

                    -- J-specific signals.
                    branch_ctl <= "101";
                    imm_output_internal <= STD_LOGIC_VECTOR(resize(unsigned(imm),
                        imm_output_internal'length));
                    branch_ri_control <= '0';

                    -- Set common signals.
                    WB_enable <= '1';
                    store_enable <= '0';
                    load_enable <= '0';

                ELSIF (opcode = "001110") THEN
                    -- XORI
                    Rd_out <= rt;
                    ID_Op_code <= "001101";

                    -- J-specific signals.
                    branch_ctl <= "101";
                    imm_output_internal <= STD_LOGIC_VECTOR(resize(unsigned(imm),
                        imm_output_internal'length));
                    branch_ri_control <= '0';

                    -- Set common signals.
                    WB_enable <= '1';
                    store_enable <= '0';
                    load_enable <= '0';

                ELSIF (opcode = "001111") THEN
                    -- LUI
                    Rd_out <= rt;
                    ID_Op_code <= "010000";

                    -- J-specific signals.
                    branch_ctl <= "101";
                    imm_output_internal <= STD_LOGIC_VECTOR(resize(unsigned(imm),
                        imm_output_internal'length));
                    branch_ri_control <= '0';

                    -- Set common signals.
                    WB_enable <= '1';
                    store_enable <= '0';
                    load_enable <= '0';
                END IF;
            END IF;

            is_branch <= is_branch_internal;
        END IF;

    END PROCESS;
END ARCHITECTURE;