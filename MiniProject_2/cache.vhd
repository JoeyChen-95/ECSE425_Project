library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic(
	ram_size : INTEGER := 32768;
    cache_size : INTEGER := 4096;
    word_size : INTEGER := 128; -- 4096/32=128, we can store 128 words in our cache
    block_num : INTEGER := 32;
    cache_delay : time := 20 ns;
	clock_period : time := 1 ns
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

  	TYPE CACHE_DATA_STORAGE IS ARRAY(word_size-1 downto 0) OF STD_LOGIC_VECTOR(39 DOWNTO 0);
    -- 39 bit: Valid bit
    -- 38 bit: dirty bit
    -- 37-32 bits: tag bits (6 bits)
    -- 31-0 bits: data bits(One word, 32 bits) 

  	type state_type is(IDLE, Read_Command, Write_Command, Replace, Write_Back, Load_Memory_To_Cache, Read_From_Cache, Write_To_Cache,Buffer_State);

  	signal current_state: state_type;
    signal cache_storage: CACHE_DATA_STORAGE;
    signal req_block_offset: integer range 0 to 31; --32 blocks
    signal req_tag: std_logic_vector(5 downto 0); --6-bit tag
    signal req_word_offset: integer range 0 to 3; --4 words per block
    signal req_byte_offset:integer range 0 to 3; --4 bytes per word (But we don't use this variable in this project)
    signal current_access_set: std_logic_vector(39 downto 0);
    signal memory_counter : integer range 0 to 5;
    
    SIGNAL write_waitreq_reg: STD_LOGIC := '1';
	SIGNAL read_waitreq_reg: STD_LOGIC := '1';

  	begin
  	combine: process(clock,reset)
  	begin
    -- Initialization 
    IF(now < 1 ps)THEN
    m_read <= '0';
	m_write <= '0';
    s_waitrequest <= '1';
		For i in 0 to word_size-1 LOOP
			cache_storage(i)<= (others => '0');
		END LOOP;
	end if;
		
    -- When reset

  	if reset'event and reset='1' then
  		current_state <= IDLE;
        --set all signal to 0

  	elsif clock'event and clock='1' then
      	case current_state is
          	when IDLE =>
            	s_waitrequest <= '1';
            	-- Decode the s_addr(address of the cache we want to access)
            	req_word_offset <= to_integer(unsigned(s_addr(3 downto 2)));
                req_block_offset <= to_integer(unsigned(s_addr(8 downto 4)));
                req_tag <= s_addr(14 downto 9);
                current_access_set <= cache_storage(4*req_block_offset+req_word_offset);
                                 
              	if (s_read = '1' AND s_write = '1') then --cannot read and write simultanously
                  	current_state <= IDLE;
              	elsif s_read = '1' then
                  	current_state <= Read_Command;
              	elsif s_write = '1' then
                  	current_state <= Write_Command;
              	else
                  	current_state <= IDLE;
              	end if;
                
                report to_string(s_read) severity note;
                report to_string(s_write) severity note;

          	when Read_Command =>
             report to_string(current_state) severity note;
            -- read hit
            	if(current_access_set(39)='1' AND current_access_set(37 downto 32)=req_tag) then
                	current_state <= Read_From_Cache;
            -- read miss
                else
                	current_state <= Replace;
                end if;
                
          	when Write_Command =>
            report to_string(current_state) severity note;
            --write hit 
            	if(current_access_set(39)='1' AND current_access_set(37 downto 32)=req_tag) then
                	current_state <= Write_To_Cache;
            --write miss
                else
                	current_state <= Replace;
                end if;
          	when Replace =>
            	--the replace word is clean
                if current_access_set(38)='0' then
                	current_state <= Load_Memory_To_Cache;
                else
                --the replace word is ditry
                	current_state <= Write_Back;
                end if;
         	when Write_Back =>
                
                --memory address = (cache tag * block_num + block_offset)*4*4 + word_offset*4
                m_addr <= (to_integer(unsigned(current_access_set(37 downto 32))) * block_num + req_block_offset)*4*4 + req_word_offset*4+memory_counter;
                m_write <='1';
            	m_writedata <=current_access_set(((memory_counter+1)*8-1) downto memory_counter*8);
            	
                --need 4 cycles to write the data into memory
                if memory_counter<3 then
                    memory_counter <=memory_counter+1;
                else
                	m_addr <= 0;
                    memory_counter <=0;
                    m_write <='0';
					--make the data clean
					current_access_set(38)<='0';
                    current_state <= Load_Memory_To_Cache;
                end if;
                    
          	when Load_Memory_To_Cache =>
            
            	--memory address = (req_tag * block_num + block_offset)*4*4+word_offset*4 
            	m_addr <= (to_integer(unsigned(req_tag)) * block_num + req_block_offset)*4*4 + req_word_offset*4+memory_counter;
                m_read <='1';
              
                --need 4 cycles to read the data from memory
                if memory_counter>1 and memory_counter<4 then

                	current_access_set(((memory_counter-2+1)*8-1) downto (memory_counter-2)*8) <= m_readdata;
                    memory_counter <=memory_counter+1;
                elsif memory_counter=4 then 

					current_access_set(((memory_counter-2+1)*8-1) downto (memory_counter-2)*8) <= m_readdata;
                    
                    m_addr <= 0;
                    memory_counter <= memory_counter+1;
                    m_read <='0';
                elsif memory_counter=5 then
                	m_addr <= 0;
                    m_read <='0';

					current_access_set(((memory_counter-2+1)*8-1) downto (memory_counter-2)*8) <= m_readdata;
                	--set the valid bit and dirty bit and tag;
					current_access_set(39)<='1';
					current_access_set(38)<='0';
					current_access_set(37 downto 32) <= req_tag;

                    --change the state
                    if (s_read = '1' AND s_write = '1') then 
                    	--cannot read and write simultanously
                  		current_state <= IDLE;
              		elsif s_read = '1' then
                  		current_state <= Read_From_Cache;
              		elsif s_write = '1' then
                  		current_state <= Write_To_Cache;
              		else
                  		current_state <= IDLE;
              		end if;
                    memory_counter <=0;
                else 
                  	memory_counter <=memory_counter+1;
                end if;
            		
          	when Read_From_Cache =>
            	cache_storage(4*req_block_offset+req_word_offset)<=current_access_set;
            	s_readdata <= cache_storage(4*req_block_offset+req_word_offset)(31 downto 0);
                report to_string(cache_storage(4*req_block_offset+req_word_offset)(31 downto 0))  severity note;
                report to_string(s_readdata) severity note;
--                 s_read <= '0';
                s_waitrequest <= '0';
            	current_state <= Buffer_State;
                
          	when Write_To_Cache =>
				current_access_set(38) <= '1';
                current_access_set(31 downto 0) <=s_writedata;
                cache_storage(4*req_block_offset+req_word_offset)<=current_access_set;
                cache_storage(4*req_block_offset+req_word_offset)(38) <= '1';
            	cache_storage(4*req_block_offset+req_word_offset)(31 downto 0) <= s_writedata;
--                 s_write <= '0';
				s_waitrequest <= '0';
            	current_state <= Buffer_State;
            when Buffer_State =>
            	s_waitrequest <= '1';
                current_state <= IDLE;
      	end case;

  	-- make circuits here
  end if;
  end process;
  
  
  
  
	--The waitrequest signal is used to vary response time in simulation
	--Read and write should never happen at the same time.
    
-- 	waitreq_w_proc: PROCESS (s_read)
-- 	BEGIN
-- 		IF(s_read'event AND s_read = '1')THEN
-- 			write_waitreq_reg <= '0' after cache_delay, '1' after cache_delay + clock_period;

-- 		END IF;
-- 	END PROCESS;

-- 	waitreq_r_proc: PROCESS (s_write)
-- 	BEGIN
-- 		IF(s_write'event AND s_write = '1')THEN
-- 			read_waitreq_reg <= '0' after cache_delay, '1' after cache_delay + clock_period;
-- 		END IF;
-- 	END PROCESS;
-- 	s_waitrequest <= write_waitreq_reg and read_waitreq_reg;


end arch;
