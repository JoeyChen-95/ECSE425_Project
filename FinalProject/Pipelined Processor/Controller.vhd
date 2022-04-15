LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
LIBRARY work;
USE work.ALL;

ENTITY Controller IS
    PORT (
        -- We only accept clk, reset, and dump signals
        -- from the testbench.
        clk, reset, dump : IN STD_LOGIC;
    );

END ENTITY;

ARCHITECTURE behavior OF Controller IS

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- ++++++++++++++++++++++    PC    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- PC Input Signals
    pc_in_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- PC Output Signals
    pc_out_instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
    pc_out_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- ++++++++++++++++++++++    ID    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- ID Input Signals
    id_in_instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
    id_in_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);
    id_in_wb_write_enable : STD_LOGIC;
    id_in_wb_write_address : STD_LOGIC_VECTOR(4 DOWNTO 0);
    id_in_wb_data : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- ID Output Signals
    id_out_rs_idx : STD_LOGIC_VECTOR(4 DOWNTO 0);
    id_out_rt_idx : STD_LOGIC_VECTOR(4 DOWNTO 0);
    id_out_branch_taken : STD_LOGIC;
    it_out_branch_address : STD_LOGIC_VECTOR(31 DOWNTO 0);
    id_out_rs : STD_LOGIC_VECTOR (31 DOWNTO 0);
    id_out_rt : STD_LOGIC_VECTOR (31 DOWNTO 0);
    id_out_imm : STD_LOGIC_VECTOR(31 DOWNTO 0);
    id_out_opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
    id_out_wb_enable : STD_LOGIC;
    id_out_store_enable : STD_LOGIC;
    id_out_imm_enable : STD_LOGIC;
    id_out_load_enable : STD_LOGIC;
    id_out_rd : STD_LOGIC_VECTOR(4 DOWNTO 0);

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- ++++++++++++++++++++++    EX    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- EX Input Signals
    SIGNAL ex_in_opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL ex_in_rs : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_in_rt : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_in_imm : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_in_rd : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL ex_in_ex_forward : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL ex_in_mem_forward : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL ex_in_store_enable : STD_LOGIC;
    SIGNAL ex_in_load_enable : STD_LOGIC;
    SIGNAL ex_in_imm_enable : STD_LOGIC;
    SIGNAL ex_in_wb_enable : STD_LOGIC;

    -- EX Output Signals
    SIGNAL ex_out_wb_enable : STD_LOGIC;
    SIGNAL ex_out_store_enable : STD_LOGIC;
    SIGNAL ex_out_load_enable : STD_LOGIC;
    SIGNAL ex_out_rd : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL ex_out_mem_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_out_alu_data : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- EX Control Signals
    SIGNAL ex_control_rs_select_forwarding : STD_LOGIC;
    SIGNAL ex_control_rt_select_forwarding : STD_LOGIC;
    SIGNAL ex_control_rs_select_forwarding_mem : STD_LOGIC;
    SIGNAL ex_control_rt_select_forwarding_mem : STD_LOGIC;

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- +++++++++++++++++++++    MEM    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- MEM Input Signals
    SIGNAL mem_in_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_in_address : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_in_write_enable : STD_LOGIC;
    SIGNAL mem_in_load_enable : STD_LOGIC;
    SIGNAL mem_in_rd : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL mem_in_wb_enable : STD_LOGIC;

    -- MEM Output Signals
    SIGNAL mem_data_forward : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_out_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_out_wb_enable : STD_LOGIC;
    SIGNAL mem_out_rd : STD_LOGIC_VECTOR (4 DOWNTO 0);

    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- ++++++++++++++++++++++    WB    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- WB Input
    wb_in_wb_enable : STD_LOGIC;
    wb_in_wb_rd : STD_LOGIC_VECTOR (4 DOWNTO 0);
    wb_in_wb_data : STD_LOGIC_VECTOR (31 DOWNTO 0);

    -- WB Output
    wb_out_enable : STD_LOGIC;
    wb_out_rd : STD_LOGIC_VECTOR (4 DOWNTO 0);
    wb_out_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
    wb_out_forwarding_data : STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- ++++++++++++++++++++++    PC    +++++++++++++++++++++++++
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ID_Stage : PC
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
    ID_Stage : ID
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
    EX_Stage : EX
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
    EX_Stage : MEM
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
    EX_Stage : MEM
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

    controller_process : PROCESS (clk, reset)

        -- These internal variables are used for
        -- hazard detection.
        VARIABLE id_reg1_internal : unsigned(5 DOWNTO 0);
        VARIABLE id_reg2_internal : unsigned(5 DOWNTO 0);
    BEGIN
        IF (rising_edge(reset)) THEN
                -- set all input signal to 0
                pc_in_pc <= (OTHERS => '0');
                id_in_instruction <= (OTHERS => '0');
                id_in_pc<= (OTHERS => '0');
                id_in_wb_write_enable<= (OTHERS => '0');
                id_in_wb_write_address<= (OTHERS => '0');
                id_in_wb_data<= (OTHERS => '0');
                ex_in_imm<= (OTHERS => '0');
                ex_in_wb_enable<= (OTHERS => '0');
                ex_in_store_enable<= (OTHERS => '0');
                ex_in_load_enable<= (OTHERS => '0');
                ex_in_imm_enable<= (OTHERS => '0');
                ex_in_rd<= (OTHERS => '0');
                ex_in_ex_forward<= (OTHERS => '0');
                ex_in_mem_forward<= (OTHERS => '0');
                mem_in_data<= (OTHERS => '0');
                mem_in_address<= (OTHERS => '0');
                mem_in_write_enable<= (OTHERS => '0');
                mem_in_load_enable<= (OTHERS => '0');
                mem_in_rd<= (OTHERS => '0');
                mem_in_wb_enable<= (OTHERS => '0');
                wb_in_wb_enable<= (OTHERS => '0');
                wb_in_wb_rd<= (OTHERS => '0');
                wb_in_wb_data<= (OTHERS => '0');

                -- stall other process, add $0, $0, $0
                ex_in_rs <= (OTHERS => '0');
                ex_in_rt <= (OTHERS => '0');
                ex_control_rs_select_forwarding <= '0';
                ex_control_rs_select_forwarding_mem <='0';
                ex_control_rt_select_forwarding <= '0';
                ex_control_rt_select_forwarding_mem <= '0';
                ex_in_opcode <= "000000";

            
        end if;

        IF (falling_edge(clk)) THEN
            -- The controller only works at
            -- the falling edge of the clock.
        
            id_reg1_internal := id_out_rs_idx ;
            id_reg2_internal := id_out_rt_idx ;

            -- hazard detection
            -- only one is Read after write
            if (wb_out_rd = id_reg1_internal or wb_out_rd = id_reg2_internal) then   

                -- stall other process, add $0, $0, $0
                ex_in_rs <= (OTHERS => '0');
                ex_in_rt <= (OTHERS => '0');
                ex_control_rs_select_forwarding <= '0';
                ex_control_rs_select_forwarding_mem <='0';
                ex_control_rt_select_forwarding <= '0';
                ex_control_rt_select_forwarding_mem <= '0';
                ex_in_opcode <= "000000";

                ex_in_wb_enable<= (OTHERS => '0');
                ex_in_store_enable<= (OTHERS => '0');
                ex_in_load_enable<= (OTHERS => '0');
                ex_in_imm_enable<= (OTHERS => '0');

            elsif (id_out_branch_taken = '1') then
                -- branch taken, jump to the calculated branch address
                pc_in_pc  <= id_out_branch_address;            
                id_in_instruction<= (OTHERS => '0');
                
                ex_in_rs <= (OTHERS => '0');
                ex_in_rt <= (OTHERS => '0');
                ex_control_rs_select_forwarding <= '0';
                ex_control_rs_select_forwarding_mem <='0';
                ex_control_rt_select_forwarding <= '0';
                ex_control_rt_select_forwarding_mem <= '0';
                ex_in_opcode <= "000000";

                ex_in_wb_enable<= (OTHERS => '0');
                ex_in_store_enable<= (OTHERS => '0');
                ex_in_load_enable<= (OTHERS => '0');
                ex_in_imm_enable<= (OTHERS => '0');

            else
                -- pass signals to next stage
                --IF TO IF
                pc_in_pc  <= pc_out_pc;

                -- IF to ID
                id_in_instruction<= pc_out_instruction;
                id_in_pc  <= pc_out_pc;
                
                -- ID to EX
                ex_in_rs <= id_out_rs;
                ex_in_rt <= id_out_rt;
                ex_in_imm <= id_out_imm;
                ex_in_opcode <= id_out_opcode;
                ex_in_wb_enable <= id_out_wb_enable;
                ex_in_store_enable <= id_out_store_enable;
                ex_in_imm_enable  <= id_out_imm_enable;
                ex_in_load_enable <= id_out_load_enable;
                ex_in_rd <= id_out_rd;

                --select the mux control signal
                if (id_reg1_internal =ex_out_rd and id_reg2_internal= ex_out_rd) then
                    -- both need excution stage result forwarding,just select the result of excution since it is the most recent data
                    ex_control_rs_select_forwarding <= '0';
                    ex_control_rs_select_forwarding_mem <='1';
                    ex_control_rt_select_forwarding <= '0';
                    ex_control_rt_select_forwarding_mem <= '1';                        
                elsif (id_reg1_internal =ex_out_rd and id_reg2_internal /= ex_out_rd) then
                    if (id_reg2_internal = mem_out_rd) then 
                        -- rs is using the result from excution, but rt is using  the result from memory stage
                        ex_control_rs_select_forwarding <= '0';
                        ex_control_rs_select_forwarding_mem <='1';
                        ex_control_rt_select_forwarding <= '1';
                        ex_control_rt_select_forwarding_mem <= '1';
                    else
                        -- rs is using the result from excution, but rt does not use the forwarding signal
                        ex_control_rs_select_forwarding <= '0';
                        ex_control_rs_select_forwarding_mem <='1';
                        ex_control_rt_select_forwarding <= '0';
                        ex_control_rt_select_forwarding_mem <= '0';   
                    end if;
                elsif (id_reg1_internal /=ex_out_rd and id_reg2_internal = ex_out_rd) then 
                    if (id_reg1_internal = mem_out_rd) then
                        -- rs does not use result of ex, but use result of mem, rt use the result from ex
                        ex_control_rs_select_forwarding <= '1';
                        ex_control_rs_select_forwarding_mem <='1';
                        ex_control_rt_select_forwarding <= '0';
                        ex_control_rt_select_forwarding_mem <= '1';                            
                    else
                        -- rs does not use forwarding signal, rt use the result from ex
                        ex_control_rs_select_forwarding <= '0';
                        ex_control_rs_select_forwarding_mem <='0';
                        ex_control_rt_select_forwarding <= '0';
                        ex_control_rt_select_forwarding_mem <= '1';   
                    end if;
                elsif (id_reg1_internal /=ex_out_rd and id_reg2_internal /= ex_out_rd) then 
                    if (id_reg1_internal = mem_out_rd and id_reg2_internal = mem_out_rd) then  
                        -- rs does not use result of ex, but use result of mem, rt does not use result of ex, but use result of mem,
                        ex_control_rs_select_forwarding <= '1';
                        ex_control_rs_select_forwarding_mem <='1';
                        ex_control_rt_select_forwarding <= '1';
                        ex_control_rt_select_forwarding_mem <= '1';  
                    elsif (id_reg1_internal = mem_out_rd and id_reg2_internal /= mem_out_rd) then  
                        -- rs does not use result of ex, but use result of mem, rt does not use forward signal
                        ex_control_rs_select_forwarding <= '1';
                        ex_control_rs_select_forwarding_mem <='1';
                        ex_control_rt_select_forwarding <= '0';
                        ex_control_rt_select_forwarding_mem <= '0'; 
                    elsif (id_reg1_internal /= mem_out_rd and id_reg2_internal = mem_out_rd) then  
                        -- rs does not use forward signal, rt does not use result of ex, but use result of mem,
                        ex_control_rs_select_forwarding <= '0';
                        ex_control_rs_select_forwarding_mem <='0';
                        ex_control_rt_select_forwarding <= '1';
                        ex_control_rt_select_forwarding_mem <= '1'; 
                    else
                        -- both rs and rt do not use forward signal 
                        ex_control_rs_select_forwarding <= '0';
                        ex_control_rs_select_forwarding_mem <='0';
                        ex_control_rt_select_forwarding <= '0';
                        ex_control_rt_select_forwarding_mem <= '0';                             
                    end if; 
                end if;

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

                -- WB to ID
                wb_write_enable  <= wb_out_enable;
                wb_write_address <= wb_out_rd;
                wb_data  <= wb_out_data;    


            end if;

        END IF;
    END PROCESS

    -- allow to write back to register file
    id_in_wb_write_enable  <= wb_out_enable;
    id_in_wb_write_address <= wb_out_rd;
    id_in_wb_data  <= wb_out_data;

END ARCHITECTURE;
