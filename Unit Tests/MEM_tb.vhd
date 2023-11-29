-- Code your testbench here
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY MEM_tb IS
END MEM_tb;

ARCHITECTURE behaviour OF MEM_tb IS
    COMPONENT MEM IS
        PORT (
        	dump : in std_logic;
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            data_forward : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            
            --From EX
            mem_in_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- connect ex_mem_data_out
            in_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- connect ex_ALU_result_out
            write_enable : IN STD_LOGIC := '0'; -- connect register out
            load_enable: in std_logic := '0';
            dest_reg : IN STD_LOGIC_VECTOR(4 DOWNTO 0); 
            enable_writeback : IN STD_LOGIC; -- connect ex_reg_en_out
            
            -- TO WB
            out_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => 'Z');
            wb_enable : OUT STD_LOGIC;
            wb_dest_reg : OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
        );
    END COMPONENT;

    -- Input
    CONSTANT clk_period : TIME := 1 ns;
    signal dump : std_logic;
    SIGNAL clk : STD_LOGIC;
    SIGNAL reset : STD_LOGIC;
    SIGNAL data_forward : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_in_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL in_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := X"00000000";
    SIGNAL write_enable : STD_LOGIC;
    signal load_enable : std_logic;
    signal dest_reg : STD_LOGIC_VECTOR(4 DOWNTO 0);
    signal enable_writeback : STD_LOGIC;
    
    -- Output
    SIGNAL out_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => 'Z');
    signal wb_enable : std_logic;
    signal wb_dest_reg : STD_LOGIC_VECTOR (4 DOWNTO 0);
    SIGNAL mem_data	: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL line_counter : INTEGER := 0;
    
BEGIN
    dut : MEM
    PORT MAP(
    	dump => dump,
        clk => clk,
        reset => reset,
        data_forward => data_forward,
        mem_in_data => mem_in_data,
        in_address => in_address,
        write_enable => write_enable,
        load_enable => load_enable,
        dest_reg => dest_reg,
        enable_writeback => enable_writeback,
        out_data => out_data,
        wb_enable => wb_enable,
        wb_dest_reg => wb_dest_reg
    );

    -- Clock process setup
    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR clk_period/2;
        clk <= '0';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Test process begins
    test_process : process
      FILE file_ptr 		: text;
      VARIABLE file_line 	: line;
      VARIABLE line_content : STRING(1 TO 32);
      VARIABLE char 		: CHARACTER := '0';
      VARIABLE mem_out	: STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
      
    BEGIN
        -- Reset
        WAIT FOR clk_period;
        reset <= '0';
        dump <= '0';
        WAIT FOR clk_period;
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        mem_in_data <= x"aaaaaaaa";
-- Test 1        
        -- First read
        WAIT FOR clk_period;
        write_enable <= '0';
        load_enable <= '1';
        in_address <= x"00000ddc";
        ASSERT out_data = x"00000000" REPORT "INIT UNSUCCESSFUL" SEVERITY error;
-- Test 2        
        -- First write, write in data
        WAIT FOR clk_period;
        in_address <= x"00000001";
        write_enable <= '1';
        load_enable <= '0';
        
        -- Second read, vertify if first write is successful
        WAIT FOR clk_period;
        write_enable <= '0';
        load_enable<='1';
        WAIT FOR clk_period;
        ASSERT out_data = x"aaaaaaaa" REPORT "WRITE 1 UNSUCCESSFUL" SEVERITY error;
-- Test 3        
        -- Second write, write in the forwarding data
        WAIT FOR clk_period;
        in_address <= x"00000030";
        write_enable <= '1';
        load_enable <= '0';
        
        -- Third read, vertify if second write is successful
        WAIT FOR clk_period;
        write_enable <= '0';
        load_enable <= '1';
        WAIT FOR clk_period;
        ASSERT out_data = x"aaaaaaaa" REPORT "WRITE 2 UNSUCCESSFUL" SEVERITY error;
-- Test 4        
        -- Set the load bit to 0, vertify if the out_data equal to the input address
        WAIT FOR clk_period;
        write_enable <= '0';
        load_enable <= '0';
        in_address <= x"00000bbb";
        WAIT FOR clk_period;
        ASSERT out_data = x"00000bbb" REPORT "OUTDATA NOT EQUAL TO IN_ADDRESS WHEN LOAD_ENABLE IS 0" SEVERITY error;
  		WAIT FOR clk_period;      
        
        
        
        
        
        dump <= '1';
   		
        wait for clk_period;
        dump <= '0';
		file_open(file_ptr, "memory.txt", READ_MODE);

        WHILE NOT endfile(file_ptr) LOOP
            readline(file_ptr, file_line);
            read(file_line, line_content);

            FOR i IN 1 TO 32 LOOP
              char := line_content(i);
              IF (char = '0') THEN
                mem_out(32 - i) := '0';
              ELSE
                mem_out(32 - i) := '1';
              END IF;
            END LOOP;
            mem_data <= mem_out;
            line_counter <= line_counter + 1;
            wait for clk_period;
        END LOOP;  

        file_close(file_ptr);
        
        WAIT;
    END PROCESS;
END;
