-- Code your design here
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE std.textio.ALL;

ENTITY Registers IS
    GENERIC (
        REGISTER_FILE_ADDRESS : STRING := "register.txt";
    );
    PORT (
        dump : IN STD_LOGIC_VECTOR;
        clock : IN STD_LOGIC_VECTOR;
        reset : IN STD_LOGIC_VECTOR;
        r1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        r2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        wb_write_enable : IN STD_LOGIC;
        wb_write_address : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        wb_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    );
END Registers;

ARCHITECTURE arch OF Registers IS
    TYPE REGISTERS IS ARRAY(31 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL registers : REGISTERS;
BEGIN

    registers_process : PROCESS (clock, dump, reset)
    BEGIN
        IF (rising_edge(reset)) THEN
            -- We shall reset all register content to
            -- 0.
            FOR i IN 0 TO 31 LOOP
                registers(i) <= (OTHERS => '0');
            END LOOP;
        ELSIF (rising_edge(dump)) THEN
            -- We shall dump the register content
            -- to register.txt
        ELSIF (rising_edge(clock)) THEN
            -- We shall conduct regular 
            -- register operations., i.e.,
            -- to write data from "WB"stage
            -- back to registers. Note that
            -- we must not write back to R0.
            IF (wb_write_enable = '1' AND to_integer(unsigned_wb_write_address) /= 0) THEN
                registers(to_integer(unsigned(wb_write_address))) <= wb_write_data;
            END IF;
        END IF;

    END PROCESS;

    -- In normal operations, the read content is hardwired
    -- to the registers.
    reg1_out <= registers(to_integer(unsigned(r1)));
    reg2_out <= registers(to_integer(unsigned(r2)));

END arch;