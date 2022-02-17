-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- empty entity
entity FSM_tb is
end;

-- architecture

architecture tb of FSM_tb is
	signal clk: std_logic;
    signal reset: std_logic;
    signal input: std_logic_vector(7 downto 0) :=(others=>'0');
    signal output: std_logic;
    
    component FSM
    	port (clk,reset: in std_logic;
        	  input: in std_logic_vector(7 downto 0);
              output: out std_logic);
        end component;

begin	
	-- connect Device Under Test (DUT)
	DUT: FSM port map(clk,reset,input,output);
    
    --set clock of 10 ns per clock cycle
    clock_process: process
    begin
    	clk <= '0', '1' after 5 ns;
        wait for 10 ns;
    end process;
    
    -- begin test
    inpur_input: process
    
    begin
    	reset <= '1';
        wait for 10 ns;
        reset <= '0';
        -- Test code: hello//world/try\n aaaa/*aaaaa\n *aaaaa*/exit
        input <= "01001000"; --h
        wait for 10 ns;
        input <= "01000101"; --e
        wait for 10 ns;
        input <= "01001100"; --l
        wait for 10 ns;
        input <= "01001100"; --l
        wait for 10 ns;
        input <= "01001111"; --o
        wait for 10 ns;
        input <= "00101111"; --/
        wait for 10 ns;
        input <= "00101111"; --/
        wait for 10 ns;
        input <= "01010111"; --w
        wait for 10 ns;
        input <= "01001111"; --o
        wait for 10 ns;
        input <= "01010010"; --r
        wait for 10 ns;
        input <= "01001100"; --l
        wait for 10 ns;
        input <= "01100010"; --d
        wait for 10 ns;
        input <= "00101111"; --/
        wait for 10 ns;
        input <= "01010100"; --t
        wait for 10 ns;
        input <= "01010010"; --r
        wait for 10 ns;
        input <= "01011001"; --y
        wait for 10 ns;
        input <= "00001010"; --\n
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "00101111"; --/
        wait for 10 ns;
        input <= "00101010"; --*
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "00001010"; --\n
        wait for 10 ns;
        input <= "00101010"; --*
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "01000001"; --a
        wait for 10 ns;
        input <= "00101010"; --*
        wait for 10 ns;
        input <= "00101111"; --/        
        wait for 10 ns;
        input <= "01000101"; --e
        wait for 10 ns;
        input <= "01011000"; --x
        wait for 10 ns;
        input <= "01001001"; --i
        wait for 10 ns;
        input <= "01010100"; --t
    end process;
end tb;


