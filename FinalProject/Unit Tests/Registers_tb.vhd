LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY Registers_tb is
end Registers_tb;

ARCHITECTURE Registers_testbench OF Registers_tb is

	COMPONENT Registers is
    Port ( 
        dump : IN STD_LOGIC;
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        r1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        r2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        wb_write_enable : IN STD_LOGIC;
        wb_write_address : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        wb_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- For link only.
        link_enable : IN STD_LOGIC;
        link_val : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
    );     
    END COMPONENT;
    
    -- test signals
    constant clk_period : time := 1 ns;
    SIGNAL dump 	: STD_LOGIC;
    SIGNAL clock 	: STD_LOGIC;
    SIGNAL reset 	: STD_LOGIC;
    SIGNAL r1 		: STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL r2 		: STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL wb_write_enable 	: STD_LOGIC;
    SIGNAL wb_write_address : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL wb_write_data 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg1_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg2_out : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- For link only.
    SIGNAL link_enable  : STD_LOGIC;
    SIGNAL link_val 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    -- Internal
    SIGNAL mem_data	: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL line_counter : INTEGER := 0;
        
begin
  Registers_test: Registers 
  ---------Port Map of Registers ---------
  port map(
    dump => dump,
    clock => clock,
    reset => reset,
    r1 => r1,
    r2 => r2,
    wb_write_enable => wb_write_enable,
    wb_write_address => wb_write_address,
	wb_write_data => wb_write_data,
    reg1_out => reg1_out,
    reg2_out => reg2_out,
    link_enable => link_enable,
    link_val => link_val
  );
  
  
  clk_process : process
  begin
    clock <= '1';
    wait for clk_period/2;
    clock <= '0';
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
    
      wait for clk_period;
      reset <= '1';

      wait for clk_period;
      reset <= '0';
      dump <= '1';

      wait for clk_period;
      dump <= '0';
      r1 <= "00000";
      r2 <= "00001";
	
      -- WB Test
      wb_write_enable <= '1';
      wb_write_address <= "00000";
      wb_write_data <= x"00000010";
      wait for clk_period;
      ASSERT reg1_out = x"00000010" REPORT "R0 NOT WRITTEN" SEVERITY note;

      wb_write_enable <= '1';
      wb_write_address <= "00001";
      wb_write_data <= x"00000010";
      wait for clk_period;
      ASSERT reg2_out = x"00000010" REPORT "R1 NOT WRITTEN" SEVERITY error;
      
      --Link Test
      r2 <= "11111";
	  link_val <= x"00000111";
      link_enable <= '1';
      wait for clk_period;
      ASSERT reg2_out = x"00000111" REPORT "LINK FAILED" SEVERITY error;

	  dump <= '1';
      wait for clk_period;
      
      dump <= '0';
	  file_open(file_ptr, "register.txt", READ_MODE);
      wait for clk_period;

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