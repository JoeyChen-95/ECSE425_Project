LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.ALL;

ENTITY MEM IS
    PORT (
        --From Controller
        clk : IN STD_LOGIC;

        reset : IN STD_LOGIC;

        data_in_forward : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 

        forward_select : IN STD_LOGIC; -- Original: data_in_selected

        --From EX
        in_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- connect ex_mem_data_out

        in_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- connect ex_ALU_result_out

        access_memory_write : IN STD_LOGIC; -- connect register out

        access_memory_load : IN STD_LOGIC; -- connect storeen out

        access_reg_address_add_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- connect with ex)dest_regadd_out 

        access_reg_address_in : IN STD_LOGIC; -- connect ex_reg_en_out

        -- TO WB
        out_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => 'Z');
        access_reg_out : OUT STD_LOGIC;
        access_reg_add_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
    );
END MEM;

ARCHITECTURE behavior OF MEM IS

    SIGNAL memory_in_address : INTEGER RANGE 0 TO 8191; -- address to read/write in data_memory
    SIGNAL memory_write_data : STD_LOGIC_VECTOR (31 DOWNTO 0); -- the data which we want to write into data_memory
    SIGNAL memory_out_data : STD_LOGIC_VECTOR (31 DOWNTO 0); -- the data which we read from data_memory

BEGIN
    memorydata : ENTITY data_memory
        PORT MAP(
            clock => clk,
            reset => reset,
            writedata => memory_write_data,
            address => memory_in_address,
            memwrite => access_memory_write,
            memread => access_memory_load,
            readdata => memory_out_data
        );
    -- Decide which data to write in
    -- If forward_select==1, write in the forwarding data.
    -- If forward_select==0 , write in the normal data in.
    WITH forward_select SELECT memory_write_data <=
        data_in_forward WHEN '1',
        in_data WHEN OTHERS;

    -- Decide whether to pass data out
    -- If acess_memory_load==1, pass the data out.
    -- If access_memory_load==0, pass 0.
    WITH access_memory_load SELECT out_data <=
        memory_out_data WHEN '1',
        x"00000000" WHEN OTHERS;

    -- Transform 32-bit address into the integer address which data_memory needs
    memory_in_address <= to_integer(unsigned(in_address));

    -- Copy and send to WB
    access_reg_out <= access_reg_address_in; --just send to WB stage 
    access_reg_add_out <= access_reg_address_add_in; -- just send to WB stage
END behavior;