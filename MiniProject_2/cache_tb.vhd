library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_tb is
end cache_tb;

architecture behavior of cache_tb is
-------Cache Component-------
component cache is
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
end component;
-------Memory Component-------
component memory is 
GENERIC(
    ram_size : INTEGER := 32768;
    mem_delay : time := 10 ns;
    clock_period : time := 1 ns
);
PORT (
    clock: IN STD_LOGIC;
    writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    address: IN INTEGER RANGE 0 TO ram_size-1;
    memwrite: IN STD_LOGIC;
    memread: IN STD_LOGIC;
    readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    waitrequest: OUT STD_LOGIC
);
end component;
	
---------Test Signal---------
signal reset : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal s_addr : std_logic_vector (31 downto 0);
signal s_read : std_logic := '0';
signal s_readdata : std_logic_vector (31 downto 0);
signal s_write :  std_logic := '0';
signal s_writedata : std_logic_vector (31 downto 0);
signal s_waitrequest : std_logic;

signal m_addr : integer range 0 to 2147483647;
signal m_read :  std_logic := '0';
signal m_readdata : std_logic_vector (7 downto 0);
signal m_write :  std_logic := '0';
signal m_writedata : std_logic_vector (7 downto 0);
signal m_waitrequest : std_logic; 

signal check_current_memory : std_logic_vector (31 downto 0);
signal block_num: INTEGER := 32;
signal word_num : INTEGER := 128;

begin

-- Connect the components which we instantiated above to their
-- respective signals.
dut: cache 
---------Port Map of Cache---------
port map(
    clock => clk,
    reset => reset,

    s_addr => s_addr,
    s_read => s_read,
    s_readdata => s_readdata,
    s_write => s_write,
    s_writedata => s_writedata,
    s_waitrequest => s_waitrequest,

    m_addr => m_addr,
    m_read => m_read,
    m_readdata => m_readdata,
    m_write => m_write,
    m_writedata => m_writedata,
    m_waitrequest => m_waitrequest
);
---------Port Map of Memory---------
MEM : memory
port map (
    clock => clk,
    writedata => m_writedata,
    address => m_addr,
    memwrite => m_write,
    memread => m_read,
    readdata => m_readdata,
    waitrequest => m_waitrequest
);
				
---------Clock Setup---------
clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process : process
begin

-- put your tests here

--We have 16 conditions
--1. read, valid, clean, tagEqual
--2. read, valid, clean, !tagEqual
--3. read, valid, !clean, tagEqual
--4. read, valid, !clean, !tagEqual
--5. read, !valid, clean, tagEqual
--6. read, !valid, clean, !tagEqual
--7. read, !valid, !clean, tagEqual
--8. read, !valid, !clean, !tagEqual
--9. !read, valid, clean, tagEqual
--10. !read, valid, clean, !tagEqual
--11. !read, valid, !clean, tagEqual
--12. !read, valid, !clean, !tagEqual
--13. !read, !valid, clean, tagEqual
--14. !read, !valid, clean, !tagEqual
--15. !read, !valid, !clean, tagEqual
--16. !read, !valid, !clean, !tagEqual

wait for clk_period;
reset<='1';
wait for clk_period;
reset<='0';
wait for clk_period;

-- simple block replacement test 
-- 	s_addr <= X"00001111"; -- block 10001, tag 001000, word + byte : 0001
--     s_writedata <= X"00000001";
--     s_write<= '1';
--     wait until rising_edge(s_waitrequest);
--     s_write <= '0';

-- wait for clk_period;

--     s_addr <= X"00001111";
--     s_read <= '1';
--     wait until rising_edge(s_waitrequest);
--     s_read <= '0';
    
-- wait for clk_period;
    
-- 	s_addr <= X"00001315"; -- block 10001, tag 001001, word+ byte : 0101
--     s_read <='1';
--     wait until rising_edge(s_waitrequest);
--     s_read <= '0';
    
-- wait for clk_period;
    
--     s_addr <= X"00001311"; -- block 10001, tag 001001, word+ byte : 0001
--     s_read <='1';
--     wait until rising_edge(s_waitrequest);
--     s_read <= '0';



--5. read, !valid, clean, tagEqual
s_addr <= X"00000051";--at 0 word and 00101=5block,tag 000000
s_read <= '1';
wait until rising_edge(s_waitrequest);
assert s_readdata = x"53525150" report "read unsuccessful case 5" severity error;
s_read<='0';

wait for clk_period;

--13. write, !valid, clean, tagEqual
s_addr <= X"00000061";--at 0 word and 00110=6block,tag 000000
s_writedata <= X"00000010";
s_write <= '1';
wait until rising_edge(s_waitrequest);
s_write <= '0';

wait for clk_period;

--3. read, valid, !clean, tagEqual
s_addr <= X"00000061";--at 0 word and 00110=6block,tag 000000
s_read <= '1';
wait until rising_edge(s_waitrequest);
assert s_readdata = x"00000010" report "write unsuccessful case 4 or read unsuccessful case 3" severity error;
s_read <= '0';

wait for clk_period;

-- 6. read, !valid, clean, !tagEqual
s_addr <= X"00002091";--at 0 word and 01001=9block,tag 010000
s_read <= '1';
wait until rising_edge(s_waitrequest);
assert s_readdata = x"93929190" report "read unsuccessful case 6" severity error;
s_read<='0';

wait for clk_period;

-- 1. read, valid, clean, tagEqual
s_addr <= X"00002091";--at 0 word and 01001=9block,tag 010000
s_read <= '1';
wait until rising_edge(s_waitrequest);
assert s_readdata = x"93929190" report "read unsuccessful case 1" severity error;
s_read<='0';

wait for clk_period;

--2. read, valid, clean, !tagEqual
s_addr <= X"00002891";--at 0 word and 01001=9block,tag 010100
s_read <= '1';
wait until rising_edge(s_waitrequest);
assert s_readdata = x"93929190" report "read unsuccessful case 2" severity error;
s_read <= '0';

wait for clk_period;

-- 14. write, !valid, clean, !tagEqual
s_addr <= X"00001111";--at 0 word and 10001=17block,tag 001000
s_writedata <= X"00000011";
s_write <= '1';
wait until rising_edge(s_waitrequest);
s_write <= '0';

wait for clk_period;

-- 3. read, valid, !clean, tagEqual
s_addr <= X"00001111";--at 0 word and 10001=17block,tag 001000
s_write <= '0';
s_read <= '1';
wait until rising_edge(s_waitrequest);
assert s_readdata = x"00000011" report "write unsuccessful case 14" severity error;
s_read <= '0';

wait for clk_period;

-- 9. write, valid, !clean, tagEqual
s_addr <= X"00001111";--at 0 word and 10001=17block,tag 001000
s_writedata <= X"00000013";
s_read <= '0';
s_write <= '1';
wait until rising_edge(s_waitrequest);
s_write <= '0';

wait for clk_period;

-- 3. read, valid, !clean, tagEqual
s_addr <= X"00001111";--at 0 word and 10001=17block,tag 001000
s_write <= '0';
s_read <= '1';
wait until rising_edge(s_waitrequest);
assert s_readdata = x"00000013" report "write unsuccessful case 9" severity error;
s_read <= '0';

wait for clk_period;

-- 4. read, valid, !clean, !tagEqual
s_addr <= X"00001311";--at 0 word and 10001=17block,tag 001001
s_read <= '1';
wait until rising_edge(s_waitrequest);
assert s_readdata = x"13121110" report "write unsuccessful case 9 or read unsuccessful case 4" severity error;
s_read <='0';

wait for clk_period;

-- 10. write, valid, clean, !tagEqual
s_addr <= X"00001711";--at 0 word and 10001=17block,tag 001011
s_writedata <= X"00000014";
s_write <= '1';
wait until rising_edge(s_waitrequest);
s_write <= '0';

wait for clk_period;

--3. read, valid, !clean, tagEqual
s_addr <= X"00001711";--at 0 word and 10001=17block,tag 001010
s_read <= '1';
wait until rising_edge(s_waitrequest);
assert s_readdata = x"00000014" report "write unsuccessful case 10" severity error;
s_read <= '0';

wait for clk_period;

--11. write, valid, !clean, tagEqual
s_addr <= X"00001715";--at 0 word and 10001=17block,tag 001011, word 1
s_writedata <= X"00000015";
s_write <= '1';
wait until rising_edge(s_waitrequest);
s_write <= '0';

wait for clk_period;

--3. read, valid, !clean, tagEqual
s_addr <= X"00001715";--at 0 word and 10001=17block,tag 001010
s_read <= '1';
wait until rising_edge(s_waitrequest);
assert s_readdata = x"00000015" report "write unsuccessful case 10" severity error;
s_read <= '0';

wait for clk_period;

-- 12. write, valid, !clean, !tagEqual
s_addr <= X"00001511";--at 0 word and 10001=17block,tag 001010
s_writedata <= X"00000016";
s_write <= '1';
wait until rising_edge(s_waitrequest);
s_write <= '0';

wait for clk_period;

--3. read, valid, !clean, tagEqual
s_addr <= X"00001511";--at 0 word and 10001=17block,tag 001010
s_read <= '1';
wait until rising_edge(s_waitrequest);
assert s_readdata = x"00000016" report "write unsuccessful case 10" severity error;
s_read <= '0';

wait for clk_period;

--3. read, valid, !clean, tagEqual
s_addr <= X"00001515";--at 0 word and 10001=17block,tag 001010, word 1
s_read <= '1';
wait until rising_edge(s_waitrequest);
assert s_readdata = x"17161514" report "write unsuccessful case 10" severity error;
s_read <= '0';

wait for clk_period;


--The rest cases (5,7,8,13,15,16) are impossible. 

	
end process;
	
end;
