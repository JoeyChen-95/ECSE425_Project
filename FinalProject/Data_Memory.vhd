--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY data_memory IS
	GENERIC (
		RAM_SIZE : INTEGER := 8192;
		CLOCK_PERIOD : TIME := 1 ns
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		memwrite : IN STD_LOGIC;
		memread : IN STD_LOGIC;
		readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		waitrequest : OUT STD_LOGIC
	);
END data_memory;

ARCHITECTURE rtl OF data_memory IS
	TYPE MEM IS ARRAY(RAM_SIZE - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ram_block : MEM;
	VARIABLE write_waitreq_reg : STD_LOGIC := '1';
	VARIABLE read_waitreq_reg : STD_LOGIC := '1';
BEGIN
	-- This is the main section of the SRAM model
	reset_process : PROCESS (reset)
	BEGIN
		IF (rising_edge(reset)) THEN
			-- We shall reset the entire data memory
			-- to its initial value, id est, 0.
			FOR i IN 0 TO RAM_SIZE - 1 LOOP
				ram_block(i) <= (OTHERS => '0');
			END LOOP;
		END IF;

	END PROCESS;

	readdata <= ram_block(to_integer(unsigned(address)));

	-- The waitrequest signal is used to vary response time in simulation
	-- Read and write should never happen at the same time.
	waitreq_w_proc : PROCESS (memwrite)
	BEGIN
		IF (rising_edge(memwrite)) THEN
			ram_block(to_integer(unsigned(address))) <= write_data;
			write_waitreq_reg <= '0', '1' AFTER CLOCK_PERIOD;
		END IF;
	END PROCESS;

	waitreq_r_proc : PROCESS (memread)
	BEGIN
		IF (rising_edge(memread)) THEN
			read_waitreq_reg <= '0' AFTER mem_delay, '1' AFTER mem_delay + CLOCK_PERIOD;
		END IF;
	END PROCESS;
	
	waitrequest <= write_waitreq_reg AND read_waitreq_reg;
END rtl;