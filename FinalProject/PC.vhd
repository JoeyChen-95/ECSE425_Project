library ieee;
use ieee.std_logic_1164.all;

entity PC is
	port (
		pc_clk    : in std_logic;
		pc_enable : in std_logic;
		pc_reset  : in std_logic;
		pc_in     : in std_logic_vector(31 downto 0);
		pc_out    : out std_logic_vector(31 downto 0)
	);
end entity ;

architecture arch of PC is
	signal internal_pc : std_logic_vector(31 downto 0);

begin
	program_counter : process(pc_clk)
		begin
			if pc_reset = '1' then
				internal_pc <= (others => '0');
				  
			elsif rising_edge(pc_clk) and pc_enable = '1' then
				internal_pc <= pc_in;
			end if;
		end process;
		
	pc_out <= internal_pc;
end architecture ;