LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY PC IS
	PORT (
		-- Signals from the controller.
		pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_reset : IN STD_LOGIC;
		pc_clk : IN STD_LOGIC;

		-- Output signals.
		instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE arch OF PC IS
	SIGNAL internal_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

	IM : ENTITY work.Instruction_Memory
		PORT MAP(
			clock => pc_clk,
			reset => pc_reset,
			address => pc_in,
			readdata => instruction
		);

	-- The PC out is always 4 + PC.
	pc_out <= STD_LOGIC_VECTOR(unsigned(pc_in) + 4);

END ARCHITECTURE;