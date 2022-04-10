--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY data_memory IS
	GENERIC (
		RAM_SIZE : INTEGER := 8192;
		CLOCK_PERIOD : TIME := 1 ns;
	);
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address: IN INTEGER RANGE 0 TO RAM_SIZE-1;
		memwrite : IN STD_LOGIC;
		memread : IN STD_LOGIC;
		readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	);
END data_memory;

ARCHITECTURE rtl OF data_memory IS
	TYPE MEM IS ARRAY(RAM_SIZE - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ram_block : MEM;
    SIGNAL read_address_reg: INTEGER RANGE 0 TO RAM_SIZE-1;
BEGIN
	-- This is the main section of the SRAM model
	mem_process : PROCESS (reset, clock)
	BEGIN
		IF (rising_edge(reset)) THEN
			-- We shall reset the entire data memory
			-- to its initial value, id est, 0.
			FOR i IN 0 TO RAM_SIZE - 1 LOOP
				ram_block(i) <= X"00000000";
			END LOOP;
		END IF;
        
        if(clock'event) then
        	if(memwrite='1') then
            	ram_block(address)<=writedata;
             end if;
             if(memread='1') then
             	readdata <= ram_block(address);
             end if;
         end if;
	END PROCESS;
END rtl;