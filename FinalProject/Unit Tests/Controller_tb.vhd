LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.ALL;

ENTITY Controller_tb IS
END Controller_tb;

ARCHITECTURE arch OF Controller_tb IS

    -- test signals
    CONSTANT clk_period : TIME := 1 ns;
    SIGNAL clk, reset, dump, enable : STD_LOGIC;

BEGIN

    processor : ENTITY work.Controller
        PORT MAP(
            clk => clk,
            reset => reset,
            dump => dump,
            enable => enable
        );

    -- Clock process setup
    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR clk_period/2;
        clk <= '0';
        WAIT FOR clk_period/2;
    END PROCESS;

    test_process : PROCESS

        -- First we must load test programs.
        reset <= '1';
        enable <= '0';
        dump <= '0';
        WAIT FOR 10 * clk_period;

        -- Then, after some clock cycles,
        -- we shall start the process.
        WAIT UNTIL rising_edge(clk);
        reset <= '0';
        enable <= '1';
        dump <= '0';
        WAIT FOR 10 * clk_period;

        -- Finally, when the program terminates,
        -- we shall suspend execution and output
        -- memory and registers.
        WAIT FOR rising_edge(clk);
        reset <= '0';
        enable <= '0';
        dump <= '1';

        WAIT;

    BEGIN
    END PROCESS;
END ARCHITECTURE;