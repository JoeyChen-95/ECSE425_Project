-- Code your testbench here
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MEM_tb IS
END MEM_tb;

ARCHITECTURE behaviour OF MEM_tb IS
    COMPONENT MEM IS
        PORT (
        	dump : in std_logic;
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_in_forward : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 
            forward_select : IN STD_LOGIC; -- Original: data_in_selected
            --From EX
            in_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- connect ex_mem_data_out
            in_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- connect ex_ALU_result_out
            access_memory_write : IN STD_LOGIC := '0'; -- connect register out
            access_memory_load : IN STD_LOGIC := '1'; -- connect storeen out
            access_reg_address_add_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- connect with ex)dest_regadd_out 
            access_reg_address_in : IN STD_LOGIC; -- connect ex_reg_en_out
            -- TO WB
            out_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => 'Z');
            access_reg_out : OUT STD_LOGIC;
            access_reg_add_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        );
    END COMPONENT;

    -- Input
    CONSTANT clk_period : TIME := 1 ns;
    signal dump : std_logic;
    SIGNAL clk : STD_LOGIC;
    SIGNAL reset : STD_LOGIC;
    SIGNAL data_in_forward : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL forward_select : STD_LOGIC := '0';
    SIGNAL in_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL in_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := X"00000000";
    SIGNAL access_memory_write : STD_LOGIC;
    SIGNAL access_memory_load : STD_LOGIC;
    SIGNAL access_reg_address_add_in : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL access_reg_address_in : STD_LOGIC;
    -- Output
    SIGNAL out_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => 'Z');
    SIGNAL access_reg_out : STD_LOGIC;
    SIGNAL access_reg_add_out : STD_LOGIC_VECTOR (4 DOWNTO 0);

BEGIN
    dut : MEM
    PORT MAP(
    	dump => dump,
        clk => clk,
        reset => reset,
        data_in_forward => data_in_forward,
        forward_select => forward_select,
        in_data => in_data,
        in_address => in_address,
        access_memory_write => access_memory_write,
        access_memory_load => access_memory_load,
        access_reg_address_add_in => access_reg_address_add_in,
        access_reg_address_in => access_reg_address_in,
        out_data => out_data,
        access_reg_out => access_reg_out,
        access_reg_add_out => access_reg_add_out
    );

    -- Clock process setup
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;
    
    dump_process : PROCESS
    BEGIN
        dump <= '0';
        WAIT FOR 25*clk_period;
        dump <= '1';
        WAIT FOR 25*clk_period;
    END PROCESS;

    -- Test process begins
    test_process : PROCESS
    BEGIN
        -- Reset
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR clk_period;
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        -- First read
        WAIT FOR clk_period;
        access_memory_load <= '1';
        access_memory_write <= '0';
        in_address <= x"00000ddc";
        ASSERT out_data = x"00000000" REPORT "Initialization unsuccessful" SEVERITY error;
        -- First write, write in normal data
        WAIT FOR clk_period;
        in_data <= x"abcdabcd";
        data_in_forward <= x"dcbadcba";
        access_memory_load <= '0';
        access_memory_write <= '1';
        -- Second read, vertify if first write is successful
        WAIT FOR clk_period;
        access_memory_load <= '1';
        access_memory_write <= '0';
        WAIT FOR clk_period;
        ASSERT out_data = x"abcdabcd" REPORT "Write1 unsuccessful" SEVERITY error;
        -- Second write, write in the forwarding data
        WAIT FOR clk_period;
        forward_select <= '1';
        access_memory_load <= '0';
        access_memory_write <= '1';
        -- Third read, vertify if second write is successful
        WAIT FOR clk_period;
        access_memory_load <= '1';
        access_memory_write <= '0';
        WAIT FOR clk_period;
        ASSERT out_data = x"dcbadcba" REPORT "Write2 unsuccessful" SEVERITY error;
        WAIT;
    END PROCESS;
END;