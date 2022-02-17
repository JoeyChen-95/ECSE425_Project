library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic(
	ram_size : INTEGER := 32768;
);
port(
	clock : in std_logic;
	reset : in std_logic;
	
	-- Avalon interface --
	s_addr : in std_logic_vector (31 downto 0);
	s_read : in std_logic;
	s_readdata : out std_logic_vector (31 downto 0);
	s_write : in std_logic;
	s_writedata : in std_logic_vector (31 downto 0);
	s_waitrequest : out std_logic; 
    
	m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0);
	m_waitrequest : in std_logic
);
end cache;

architecture arch of cache is

-- declare signals here
type state_type is(IDLE, Read_Command, Write_Command, Replace, Write_Back, Load_MemoryToCache, Read_FromCache, Write_FromCache);

signal current_state: state_type;

signal s_addr : std_logic_vector (31 downto 0);

begin

-- make circuits here

combine: process(clock,reset)
begin

if reset'event and reset='1' then
current_state <= IDLE;

elsif clock'event and clock='1' then
	case current_state is
    	when IDLE =>
            if (s_read = '1' AND s_write = '1') then --cannot read and write simultanously
            	current_state <= IDLE;
            elsif s_read = '1' then
            	current_state <= Read_Command;
            elsif s_write = '1' then
            	current_state <= Write_Command;
            else
            	current_state <= IDLE;
            end if;
        when Read_Command =>
	    -- check block index first
	    

        when Write_Command =>
	    

        when Replace =>
	    if s_addr(30)='1' then 
		current_state <= Write_Back;
	    else
		current_state <= Load_MemoryToCache;
	    end if;
        when Write_Back =>
	    current_state <= Load_MemoryToCache;
        when Load_MemoryToCache =>
	    if s_read = '1' then
	    	current_state <= Read_FromCache;
	    elsif s_write = '1' then
            	current_state <= Write_FromCache;
            else
            	current_state <= IDLE;
            end if;
        when Read_FromCache =>
		current_state <= IDLE;
        when Write_FromCache =>
		current_state <= IDLE;
    end case;

end arch;