library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
	port (
		fetch_clk	: in std_logic;
		fetch_enable	: in std_logic;
		fetch_reset	: in std_logic;
		branch_predict	: in std_logic;
		branch_pc	: in std_logic_vector (31 downto 0);
		pc_out		: out std_logic_vector (31 downto 0);
		ins_out		: out std_logic_vector (31 downto 0)
	 );
end entity;

architecture arch of fetch is
	signal im_write_data	: std_logic_vector (31 downto 0) := (others => 'Z');
	signal im_addr		: integer range 0 to 32767 := 0;
	signal im_write		: std_logic := '0';
	signal im_read		: std_logic := '0';
	signal im_read_data	: std_logic_vector (31 downto 0) := (others => 'Z');
	signal im_wait_req	: std_logic := '0';
	signal pc_in		: std_logic_vector (31 downto 0) := (others => '0');
	signal internal_pc_out	: std_logic_vector (31 downto 0) := (others => '0');

begin
	instruction_memory : entity work.Main_Memory
	port map (
		clock 		=> fetch_clk,
		writedata 	=> im_write_data,
		address 	=> im_addr,
		memwrite 	=> im_write,
		memread 	=> im_read,
		readdata	=> im_read_data,
		waitrequest 	=> im_wait_req
	);
	
	program_counter : entity work.PC
	port map (
		pc_clk    => fetch_clk,
		pc_enable => fetch_enable,
		pc_reset  => fetch_reset,
		pc_in     => pc_in,
		pc_out    => internal_pc_out
	);

	-- Use the prediction bit to get current pc value
	with branch_predict select pc_in <= 
		branch_pc when '1',
		std_logic_vector(unsigned(internal_pc_out) + 4) when others;
	
	-- Inputs for the instruction memory
	im_addr  <= to_integer(unsigned(internal_pc_out));
	im_write <= '0';
	im_read	 <= '1';
	
	-- Outputs
	pc_out  <= std_logic_vector(unsigned(internal_pc_out) + 4);
	ins_out <= im_read_data;
	
end architecture ;
