LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY memory_tb IS
END memory_tb;

ARCHITECTURE behaviour OF memory_tb IS

--Declare the component that you are testing:
    COMPONENT memory IS
        GENERIC(
            ram_size : INTEGER := 32768;
            mem_delay : time := 1 ns;
            clock_period : time := 1 ns
        );
        PORT (
            clock: IN STD_LOGIC;
            writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            address: IN std_logic_vector(31 downto 0);
            memwrite: IN STD_LOGIC := '0';
            memread: IN STD_LOGIC := '0';
            readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            waitrequest: OUT STD_LOGIC
        );
    END COMPONENT;

    --all the input signals with initial values
    signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
    signal writedata: std_logic_vector(31 downto 0);
    signal address: std_logic_vector(31 downto 0);
    signal memwrite: STD_LOGIC := '0';
    signal memread: STD_LOGIC := '0';
    signal readdata: STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal waitrequest: STD_LOGIC;

BEGIN

    --dut => Device Under Test
    dut: memory GENERIC MAP(
            ram_size => 15
                )
                PORT MAP(
                    clk,
                    writedata,
                    address,
                    memwrite,
                    memread,
                    readdata,
                    waitrequest
                );

    clk_process : process
    BEGIN
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    test_process : process
    BEGIN
        wait for clk_period;
        address <= x"00000000"; 
        writedata <= X"12345678";
        memwrite <= '1';
        wait for clk_period;
        memwrite <= '0';
        memread <= '1';
        report to_string(address) severity note;
        wait until rising_edge(waitrequest);
        memread <= '0';
        wait for clk_period;
        address <= x"00000000"; 
        writedata <= X"abcd1234";
        memwrite <= '1';
        wait for clk_period;
        memwrite<='0';
        wait until rising_edge(waitrequest);
        memread <= '0';
        wait;

    END PROCESS;

 
END;
