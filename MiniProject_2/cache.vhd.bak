library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic(
	ram_size : INTEGER := 32768;
    cache_size : INTEGER := 4096;
    word_size : INTEGER := 128; -- 4096/32=128, we can store 128 words in our cache
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

-- add Finite State Machine here
architecture arch of cache is

  	TYPE CACHE_STORAGE IS ARRAY(word_size-1 downto 0) OF STD_LOGIC_VECTOR(39 DOWNTO 0);
    -- 0 bit: Valid bit
    -- 1 bit: dirty bit
    -- 2-7 bits: tag bits (6 bits)
    -- 8-39 bits: data bits(One word, 32 bits) 

  	type state_type is(IDLE, Read_Command, Write_Command, Replace, Write_Back, Load_MemoryToCache, Read_FromCache, Write_FromCache);

  	signal current_state: state_type;
    signal cache_storage: CACHE_STORAGE;
    signal req_block_offset: integer range 0 to 31; --32 blocks
    signal req_tag: std_logic_vector(5 downto 0); --6-bit tag
    signal req_word_offset: integer range 0 to 3; --4 words per block
    signal req_byte_offset:integer range 0 to 3; --4 bytes per word (But we don't use this variable in this project)
    signal current_access_set: std_logic_vector(39 downto 0);
    

  	begin
  	combine: process(clock,reset)
  	begin
    -- Initialization 
    IF(now < 1 ps)THEN
		For i in 0 to word_size-1 LOOP
			cache_storage(i)<='0';
		END LOOP;
	end if;
    -- When reset

  	if reset'event and reset='1' then
  		current_state <= IDLE;

  	elsif clock'event and clock='1' then
      	case current_state is
          	when IDLE =>
            -- Decode the s_addr(address of the cache we want to access)
            	req_word_offset <= to_integer(unsigned(s_addr(3 downto 2)));
                req_block_offset <= to_integer(unsigned(s_addr(8 downto 4)));
                req_tag <= s_addr(14 downto 9);
                current_access_set <= cache_memory(4*req_block_offset+req_block_offset)
                
                
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
            -- read hit
            	if(current_access_set(0)='1' AND current_access_set(7 downto 2)=req_tag) then
                	current_state <= Read_FromCache;
            -- read miss
                else
                	current_state <= Replace;
                end if;
          	when Write_Command =>
            --write hit
            	if(current_access_set(0)='1' AND current_access_set(7 downto 2)=req_tag AND current_access_set(1)='1') then
                	current_state <= Write_FromCache;
            --write miss
                else
                	current_state <= Replace;
                end if;
          	when Replace =>
         	when Write_Back =>
          	when Load_MemoryToCache =>
          	when Read_FromCache =>
          	when Write_FromCache =>
      	end case;

  	-- make circuits here
  end if;
  end process;

end arch;