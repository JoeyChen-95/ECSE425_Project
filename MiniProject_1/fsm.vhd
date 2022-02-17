-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--entity
entity FSM is
port(clk: in std_logic;
	reset: in std_logic;
    input: in std_logic_vector(7 downto 0); 
    output: out std_logic);
end FSM;

--architecture

architecture behaviour of FSM is
-- S_Code: When the code is not commented
-- S_CommentEntry: When the code is going to be commented i.e When meeting a "/"
-- S_Comment1: When the code is commented with "//"
-- S_Comment2: When the code is commented with "/*"
-- S_Comment2Exit: When the code is already commented with "/*" and going to exit commented status
--                 i.e When meeting a "*"
	type state_type is (S_Code, S_CommentEntry, S_Comment1, S_Comment2, S_Comment2Exit);
    signal current_state: state_type;
    
--begin behaviour

begin
combin: process(clk, reset)
begin

if reset'event and reset='1' then
current_state <= S_Code;

elsif clk'event and clk='1' then
	--Critical Character:
    -- ASCII: 47 "/" Binary:101111
    -- ASCII: 42 "*" Binary:101010
    -- ASCII: 10 "\n" Binary:1010
    case current_state is 
    	when S_Code => -- When the code is not commented
        	if input="101111" then -- When meeting "/", it is going to be commented
            	output <= '0';
                current_state <= S_CommentEntry;
            else -- When meeting any other char, not commented
            	output <= '0';
            	current_state <= S_Code;
            end if;
    	when S_CommentEntry => -- When the code is going to be commented
        	if input="101111" then -- When meeting "/" for the second time, it's commented by "//"
            	output <= '0';
                current_state <= S_Comment1;
            elsif input="101010" then -- When meeting "*", it's commented by "/*"
            	output <= '0';
                current_state <= S_Comment2;
            else -- When meeting any other char, still not commented, go back to code status
            	output <= '0';
                current_state <= S_Code; 
            end if;
    	when S_Comment1 => -- When the code is comment with "//"
        	if input="1010" then -- When meeting "\n", it's a new line, so exit commented status
            	output <= '1';
                current_state <= S_Code;
           	else -- When meeting any other char, still remain commented
            	output <= '1';
                current_state <= S_Comment1;
            end if;
        when S_Comment2 => -- When the code is comment with "/*"
        	if input="101010" then -- When metting "*", it's going to exit commented status 
            	output <= '1';
                current_state <= S_Comment2Exit;
            else -- When meeting any other char, still remain commented
            	output <= '1';
                current_state <= S_Comment2;
            end if;
        when S_Comment2Exit => -- When the code is going to exit commented state by "*/"
        	if input="101111" then -- When metting "/", the commented status is exited with "*/", go back to code status
            	output <= '1';
                current_state <= S_Code;
           	else -- When meeting any other char, still remain commented
            	output <= '1';
                current_state <= S_Comment2;
            end if;
        end case;
    end if;
end process;

end behaviour;
                
            	
                
        
