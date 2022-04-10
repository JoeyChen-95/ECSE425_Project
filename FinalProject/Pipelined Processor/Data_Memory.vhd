--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY data_memory IS
	GENERIC (
		RAM_SIZE : INTEGER := 8192;
		CLOCK_PERIOD : TIME := 1 ns;
        REGISTER_FILE_ADDRESS : STRING := "memory.txt";
	);
	PORT (
		dump : IN STD_LOGIC;
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address : IN INTEGER RANGE 0 TO RAM_SIZE - 1;
		memwrite : IN STD_LOGIC;
		memread : IN STD_LOGIC;
		readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	);
END data_memory;

ARCHITECTURE rtl OF data_memory IS
	TYPE MEM IS ARRAY(RAM_SIZE - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ram_block : MEM;
	SIGNAL read_address_reg : INTEGER RANGE 0 TO RAM_SIZE - 1;
BEGIN
	-- This is the main section of the SRAM model
	mem_process : PROCESS (reset, clock, dump)
    FILE file_ptr : text;
	VARIABLE file_line : line;
	VARIABLE line_content : STRING(1 TO 32);
	BEGIN

		IF (rising_edge(reset)) THEN
			-- We shall reset the entire data memory
			-- to its initial value, id est, 0.
			FOR i IN 0 TO RAM_SIZE - 1 LOOP
				ram_block(i) <= X"00000000";
			END LOOP;
		END IF;

		IF (clock'event) THEN
			IF (memwrite = '1') THEN
				ram_block(address) <= writedata;
			END IF;
			IF (memread = '1') THEN
				readdata <= ram_block(address);
			END IF;
		END IF;

		IF (rising_edge(dump)) THEN
			file_open(file_ptr, REGISTER_FILE_ADDRESS, READ_MODE);
			FOR i IN 0 TO 8191 LOOP
				line_content := to_string(ram_block(i));
				write(file_line, line_content);
				writeline(file_ptr, file_line);
			END LOOP;
        end if;
	END PROCESS;
END rtl;