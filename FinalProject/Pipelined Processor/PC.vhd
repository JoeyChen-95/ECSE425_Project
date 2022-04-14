LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY PC IS
	PORT (
		pc_clk : IN STD_LOGIC;
		pc_enable : IN STD_LOGIC;
		pc_reset : IN STD_LOGIC;
		pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE arch OF PC IS
	SIGNAL internal_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
	program_counter : PROCESS (pc_clk)
	BEGIN
		IF pc_reset = '1' THEN
			internal_pc <= (OTHERS => '0');

		ELSIF rising_edge(pc_clk) AND pc_enable = '1' THEN
			internal_pc <= pc_in;
		END IF;
	END PROCESS;

	pc_out <= internal_pc;
END ARCHITECTURE;