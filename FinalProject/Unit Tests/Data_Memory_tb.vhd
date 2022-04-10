LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY memory_tb IS
END memory_tb;

ARCHITECTURE behaviour OF memory_tb IS

--Declare the component that you are testing:
    COMPONENT data_memory IS
        GENERIC(
            RAM_SIZE : INTEGER := 8192;
            CLOCK_PERIOD : time := 1 ns;
        );
        PORT (
            clock: IN STD_LOGIC;
            reset: in std_logic;
            writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            address: IN INTEGER RANGE 0 TO RAM_SIZE-1;
            memwrite: IN STD_LOGIC := '0';
            memread: IN STD_LOGIC := '0';
            readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        );
    END COMPONENT;

    --all the input signals with initial values
    signal clk : std_logic := '0';
    signal reset: std_logic :='0';
    constant clk_period : time := 1 ns;
    signal writedata: std_logic_vector(31 downto 0);
    signal address: INTEGER RANGE 0 TO 8191;
    signal memwrite: STD_LOGIC := '0';
    signal memread: STD_LOGIC := '0';
    signal readdata: STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN

    --dut => Device Under Test
    dut: data_memory GENERIC MAP(
   				RAM_SIZE=>8192
                )
                PORT MAP(
                    clock=>clk,
                    reset=>reset,
                    writedata=>writedata,
                    address=>address,
                    memwrite=>memwrite,
                    memread=>memread,
                    readdata=>readdata
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
    	reset<='0';
        wait for clk_period;
        reset<='1';
        wait for clk_period;
        reset<='0';
        wait for clk_period;
        address <= 13; 
        writedata <= X"aaaaaaaa";
        memwrite <= '1';
        wait for clk_period;
        memwrite <= '0';
        memread <= '1';
        wait for clk_period;
        report "KOKOKOKO";
        address <= 88;
        memwrite <= '0';
        memread <= '1';
        wait;
    END PROCESS;

 
END;
