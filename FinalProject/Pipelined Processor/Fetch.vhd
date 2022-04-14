LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fetch IS
	PORT (
		fetch_clk : IN STD_LOGIC;
		fetch_enable : IN STD_LOGIC;
		fetch_reset : IN STD_LOGIC;
		branch_predict : IN STD_LOGIC;
		branch_pc : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		pc_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		ins_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE arch OF fetch IS
	SIGNAL im_write_data : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => 'Z');
	SIGNAL im_addr : INTEGER RANGE 0 TO 32767 := 0;
	SIGNAL im_write : STD_LOGIC := '0';
	SIGNAL im_read : STD_LOGIC := '0';
	SIGNAL im_read_data : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => 'Z');
	SIGNAL im_wait_req : STD_LOGIC := '0';
	SIGNAL pc_in : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL internal_pc_out : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');

BEGIN
	instruction_memory : ENTITY work.Main_Memory
		PORT MAP(
			clock => fetch_clk,
			writedata => im_write_data,
			address => im_addr,
			memwrite => im_write,
			memread => im_read,
			readdata => im_read_data,
			waitrequest => im_wait_req
		);

	program_counter : ENTITY work.PC
		PORT MAP(
			pc_clk => fetch_clk,
			pc_enable => fetch_enable,
			pc_reset => fetch_reset,
			pc_in => pc_in,
			pc_out => internal_pc_out
		);

	-- Use the prediction bit to get current pc value
	WITH branch_predict SELECT pc_in <=
		branch_pc WHEN '1',
		STD_LOGIC_VECTOR(unsigned(internal_pc_out) + 4) WHEN OTHERS;

	-- Inputs for the instruction memory
	im_addr <= to_integer(unsigned(internal_pc_out));
	im_write <= '0';
	im_read <= '1';

	-- Outputs
	pc_out <= STD_LOGIC_VECTOR(unsigned(internal_pc_out) + 4);
	ins_out <= im_read_data;

END ARCHITECTURE;