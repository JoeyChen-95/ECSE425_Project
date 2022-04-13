LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.textio.ALL;

ENTITY Instruction_Memory IS
    GENERIC (
        -- We only need to store at most 1024 instructions.
        RAM_SIZE : INTEGER := 1024;
        CLOCK_PERIOD : TIME := 1 ns;
        INSTRUCTION_FILE_ADDRESS : STRING := "code.txt";
        BITS_IN_INSTRUCTION : INTEGER := 32
    );
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        address : IN INTEGER RANGE 0 TO RAM_SIZE - 1;
        readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END Instruction_Memory;

ARCHITECTURE rtl OF Instruction_Memory IS
    TYPE MEM IS ARRAY(RAM_SIZE - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ram_block : MEM;
BEGIN

    -- We have two processes in the instruction memory.
    -- 1. To initialize, or to reset, the instruction memory, we
    --    shall read from the instruction file, and store these instructions
    --    in our instruction memory.
    -- 2. Ordinary fetching instructions. We shall return fetched instructions.

    -- This si the process for resetting the
    -- instruction memory.
    initialize_process : PROCESS (reset)
        FILE file_ptr : text;
        VARIABLE file_line : line;
        VARIABLE line_content : STRING(1 TO BITS_IN_INSTRUCTION);
        FILE file_read_ptr : text;
        VARIABLE instruction : STD_LOGIC_VECTOR(BITS_IN_INSTRUCTION - 1 DOWNTO 0);
        VARIABLE char : CHARACTER := '0';
        VARIABLE instruction_counter : INTEGER := 0;

    BEGIN
        IF (rising_edge(reset)) THEN
            instruction_counter := 0;
            file_open(file_ptr, INSTRUCTION_FILE_ADDRESS, READ_MODE);

            -- Read instructions line by line
            -- from the file, and then parse
            -- each bit of that instruction
            -- to a vector.
            WHILE NOT endfile(file_ptr) LOOP
                readline(file_ptr, file_line);
                read(file_line, line_content);
                
                FOR i IN 1 TO BITS_IN_INSTRUCTION LOOP
                    char := line_content(i);
                    IF (char = '0') THEN
                        instruction(BITS_IN_INSTRUCTION - i) := '0';
                    ELSE
                        instruction(BITS_IN_INSTRUCTION - i) := '1';
                    END IF;
                END LOOP;
						
                -- Store the current instruction into memory.
	    	IF instruction_counter < 1024 THEN
			ram_block(instruction_counter) <= instruction;
		    	instruction_counter := instruction_counter + 1;
		END IF;
            END LOOP;
	    file_close(file_ptr);
        END IF;
    END PROCESS;

    readdata <= ram_block(address);

END rtl;
