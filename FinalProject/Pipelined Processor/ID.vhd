-- Code your design here
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY ID IS
    PORT (
        -- clock, reset, stall
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        stall : IN STD_LOGIC;

        -- Signals from the fetch stage.
        instruction_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
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
BEGIN
END arch;