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

  begin
  	combine: process(clock,reset)
    	VARIABLE mem_word_counter : INTEGER RANGE 0 TO 4;

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
		--memory address = (req_tag * block_num + block_offset)*4*4+word_offset*4 
            	m_addr <= (to_integer(unsigned(cache_storage(4*req_block_offset+mem_word_counter)(37 downto 32))) * block_num + req_block_offset)*4*4 + (mem_word_counter)*4+memory_counter;
                m_write <='1';
                         	  
		if mem_word_counter>=0 and mem_word_counter<4 then 
			--need 4 cycles to read the data from memory
	                if memory_counter>0 and memory_counter<3 then
	                	m_writedata <= cache_storage(4*req_block_offset+mem_word_counter)(((memory_counter-1+1)*8-1) downto (memory_counter-1)*8);
	                	memory_counter <=memory_counter+1;
	                elsif memory_counter=3 then 
				m_writedata <= cache_storage(4*req_block_offset+mem_word_counter)(((memory_counter-1+1)*8-1) downto (memory_counter-1)*8);                  
	                    	m_addr <= 0;
	                    	memory_counter <= memory_counter+1;
	                    	m_write <='0';
	                elsif memory_counter=4 then
	                	m_addr <= 0;
	                    	m_write <='0';
				m_writedata <= cache_storage(4*req_block_offset+mem_word_counter)(((memory_counter-1+1)*8-1) downto (memory_counter-1)*8);
	                	--set the valid bit and dirty bit and tag;
				cache_storage(4*req_block_offset+mem_word_counter)(38)<='0';
				memory_counter <=0;
				mem_word_counter := mem_word_counter+1;
                	else 
                  		memory_counter <=memory_counter+1;
                	end if;			
		end if;
                                
                if mem_word_counter=4 then
                	current_state <= Load_Memory_To_Cache;
			mem_word_counter :=0;
		end if;
                    
         when Load_Memory_To_Cache =>
            
            	--memory address = (req_tag * block_num + block_offset)*4*4+word_offset*4 
            	m_addr <= (to_integer(unsigned(req_tag)) * block_num + req_block_offset)*4*4 + (mem_word_counter)*4+memory_counter;
                m_read <='1';
                         	  
		if mem_word_counter>=0 and mem_word_counter<4 then 
			--need 4 cycles to read the data from memory
	                if memory_counter>1 and memory_counter<4 then
	                	cache_storage(4*req_block_offset+mem_word_counter)(((memory_counter-2+1)*8-1) downto (memory_counter-2)*8) <= m_readdata;
	                	memory_counter <=memory_counter+1;
	                elsif memory_counter=4 then 
				cache_storage(4*req_block_offset+mem_word_counter)(((memory_counter-2+1)*8-1) downto (memory_counter-2)*8) <= m_readdata;                  
	                    	m_addr <= 0;
	                    	memory_counter <= memory_counter+1;
	                    	m_read <='0';
	                elsif memory_counter=5 then
	                	m_addr <= 0;
	                    	m_read <='0';
				cache_storage(4*req_block_offset+mem_word_counter)(((memory_counter-2+1)*8-1) downto (memory_counter-2)*8) <= m_readdata;
	                	--set the valid bit and dirty bit and tag;
				cache_storage(4*req_block_offset+mem_word_counter)(39)<='1';
				cache_storage(4*req_block_offset+mem_word_counter)(38)<='0';
				cache_storage(4*req_block_offset+mem_word_counter)(37 downto 32) <= req_tag;
	                    	
				memory_counter <=0;
				mem_word_counter := mem_word_counter+1;
                	else 
                  		memory_counter <=memory_counter+1;
                	end if;			
		end if;
                                
                if mem_word_counter=4 then
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
			mem_word_counter :=0;
		end if;
            		
          when Read_From_Cache =>
            	s_readdata <= cache_storage(4*req_block_offset+req_word_offset)(31 downto 0);
                s_waitrequest <= '0';
            	current_state <= Buffer_State;
                
          when Write_To_Cache =>
                cache_storage(4*req_block_offset+req_word_offset)(38) <= '1';
            	cache_storage(4*req_block_offset+req_word_offset)(31 downto 0) <= s_writedata;
		s_waitrequest <= '0';
            	current_state <= Buffer_State;

          when Buffer_State =>
            	s_waitrequest <= '1';
                current_state <= IDLE;
      	end case;

  end if;
  end process;


end arch;
