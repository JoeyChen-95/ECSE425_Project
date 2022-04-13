LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY Data_Memory_tb IS
END Data_Memory_tb;

ARCHITECTURE behaviour OF Data_Memory_tb IS
    COMPONENT Data_Memory IS
      PORT (
          dump 		: IN STD_LOGIC;
          clock 	: IN STD_LOGIC;
          reset 	: IN STD_LOGIC;
          writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
          address 	: IN INTEGER RANGE 0 TO 8192 - 1;
          memwrite 	: IN STD_LOGIC;
          readdata 	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
      );
    END COMPONENT;
    
    --input
    CONSTANT clk_period : TIME := 1 ns;
    SIGNAL dump 	 	: STD_LOGIC;
    SIGNAL clk	 	 	: STD_LOGIC;
    SIGNAL reset 	 	: STD_LOGIC;
    SIGNAL writedata 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL address 		: INTEGER RANGE 0 TO 8192 - 1;
    SIGNAL memwrite 	: STD_LOGIC;
    
    -- output
    SIGNAL readdata : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL mem_data	: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL line_counter : INTEGER := 0;

BEGIN
    DM : Data_Memory
    PORT MAP(
        dump => dump,
        clock => clk,
        reset => reset,
        writedata => writedata,
        address => address,
        memwrite => memwrite,
        readdata => readdata
    );

    ---------Clock Setup---------
  	clk_process : process
  	begin
    	clk <= '1';
    	wait for clk_period/2;
    	clk <= '0';
    	wait for clk_period/2;
  	end process;
  
  
  test_process : process
    FILE file_ptr 		: text;
    VARIABLE file_line 	: line;
    VARIABLE line_content : STRING(1 TO 32);
    VARIABLE char 		: CHARACTER := '0';
    VARIABLE mem_out	: STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    
    begin
    -- Reset
      wait for clk_period;
      dump <= '0';
      reset <= '0';
      memwrite <= '0';
    
      wait for clk_period;
      reset <= '1';

      wait for clk_period;
      reset <= '0';
      dump <= '1';

      wait for clk_period;
      dump <= '0';
      file_open(file_ptr, "memory.txt", READ_MODE);

      --First Line
      wait for clk_period;
      address <= 0;
      ASSERT readdata = x"00000000" REPORT "DATA RESET UNSUCESSFUL" SEVERITY error;

      --Last Line
      wait for clk_period;
      address <= 8191;
      ASSERT readdata = x"00000000" REPORT "DATA RESET UNSUCESSFUL" SEVERITY error;
	  
      --First Line Write
      wait for clk_period;
      memwrite <= '1';
      address <= 0;
      writedata <= x"12345678";
      wait for clk_period;
      ASSERT readdata = x"12345678" REPORT "DATA WRITE UNSUCESSFUL" SEVERITY error;
	
      --Forth Line Write
      wait for clk_period;
      address <= 3;
      writedata <= x"87654321";
      wait for clk_period;
      ASSERT readdata = x"87654321" REPORT "DATA WRITE UNSUCESSFUL" SEVERITY error;
      
      --Ninth Line Write
      wait for clk_period;
      address <= 8;
      writedata <= x"AAABBBCC";
      wait for clk_period;
      ASSERT readdata = x"AAABBBCC" REPORT "DATA WRITE UNSUCESSFUL" SEVERITY error;

	  wait for clk_period;
      memwrite <= '0';
      dump <= '1';
      
      wait for clk_period;
      dump <= '0';

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
  end process;
end architecture;
  