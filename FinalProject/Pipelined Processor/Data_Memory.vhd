LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY Data_Memory IS
	GENERIC (
		RAM_SIZE : INTEGER := 8192;
		CLOCK_PERIOD : TIME := 1 ns;
		MEMORY_FILE_ADDRESS : STRING := "memory.txt";
	);

	PORT (
		dump : IN STD_LOGIC;
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address : IN INTEGER RANGE 0 TO RAM_SIZE - 1;
		memwrite : IN STD_LOGIC;
		readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END Data_Memory;

ARCHITECTURE rtl OF Data_Memory IS
	TYPE MEM IS ARRAY(RAM_SIZE - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ram_block : MEM;
	SIGNAL read_address_reg : INTEGER RANGE 0 TO RAM_SIZE - 1;

BEGIN
	-- This is the main section of the SRAM model
	mem_process : PROCESS (reset, clock, dump)
		FILE file_ptr : text;
		VARIABLE bin_vector : STD_LOGIC_VECTOR(31 DOWNTO 0);
		VARIABLE file_line : line;
		VARIABLE line_content : STD_LOGIC_VECTOR (1 TO 32);

	BEGIN
		IF (rising_edge(reset)) THEN
			-- We shall reset the entire data memory
			-- to its initial value, id est, 0.
			FOR i IN 0 TO RAM_SIZE - 1 LOOP
				ram_block(i) <= x"00000000";
			END LOOP;
		END IF;

		IF (falling_edge(clock)) THEN
			IF (memwrite = '1') THEN
				ram_block(address) <= writedata;
			END IF;
		END IF;

		IF (rising_edge(dump)) THEN
			file_open(file_ptr, MEMORY_FILE_ADDRESS, WRITE_MODE);

			FOR k IN 0 TO RAM_SIZE - 1 LOOP
				-- For each register, we must translate 
				-- its content into a string.
				bin_vector := ram_block(k);
				FOR j IN 0 TO 31 LOOP
					IF (bin_vector(j) = '0') THEN
						line_content(32 - j) := '0';
					ELSIF (bin_vector(j) = '1') THEN
						line_content(32 - j) := '1';
					ELSIF (bin_vector(j) = 'U') THEN
						line_content(32 - j) := 'U';
					ELSIF (bin_vector(j) = 'X') THEN
						line_content(32 - j) := 'X';
					ELSIF (bin_vector(j) = 'Z') THEN
						line_content(32 - j) := 'Z';
					END IF;
				END LOOP;

				write(file_line, line_content, right, 32);
				writeline(file_ptr, file_line);
			END LOOP;

			file_close(file_ptr);
		END IF;
	END PROCESS;

	readdata <= ram_block(address);
END rtl;