-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

-- Code your testbench here
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY WB_tb IS
END WB_tb;

ARCHITECTURE behaviour OF WB_tb IS
    COMPONENT WB IS
        PORT (
            clk : IN STD_LOGIC;
            mem_WB_enable : in std_logic;
            mem_WB_address : in STD_LOGIC_VECTOR (4 DOWNTO 0);
            mem_WB_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                -- WB Output
    		WB_enable_out : OUT STD_LOGIC;
    		WB_address_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0); -- This 31 should be modified to reg_adrsize
    		WB_data_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
    		WB_forwarding_data : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)            
        );
    END COMPONENT;

    -- Input
    CONSTANT clk_period : TIME := 1 ns;
    SIGNAL clk : STD_LOGIC;
    SIGNAL mem_WB_enable : STD_LOGIC;
    SIGNAL mem_WB_address : STD_LOGIC_VECTOR (4 DOWNTO 0); -- This 31 should be modified to reg_adrsize
    SIGNAL mem_WB_data : STD_LOGIC_VECTOR (31 DOWNTO 0);

    -- WB Output
    signal WB_enable_out : STD_LOGIC;
    signal WB_address_out : STD_LOGIC_VECTOR (4 DOWNTO 0); -- This 31 should be modified to reg_adrsize
    signal WB_data_out : STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal WB_forwarding_data : STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN
    dut : WB
    PORT MAP(
        clk => clk,
        mem_WB_enable => mem_WB_enable,
        mem_WB_address => mem_WB_address,
        mem_WB_data => mem_WB_data,
        WB_enable_out => WB_enable_out,
        WB_address_out => WB_address_out,
        WB_data_out => WB_data_out,
        WB_forwarding_data => WB_forwarding_data
    );

    -- Clock process setup
    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR clk_period/2;
        clk <= '0';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Test process begins
    test_process : PROCESS
   	BEGIN
       WAIT FOR clk_period;
		mem_WB_data <= x"aaaaaaaa";
        mem_WB_enable <= '1';
        mem_WB_address <= "11111";
        -- Reset
    wait;

    END PROCESS;
END;
