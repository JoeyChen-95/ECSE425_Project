library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is 
  port (
  	-- clock, reset, stall
    ALU_clock: in std_logic;
    ALU_reset: in std_logic;
    ALU_stall: in std_logic;
    
    -- Rs,Rt,operand, output result
    ALU_RS: in std_logic_vector(31 downto 0);
    ALU_RT_or_immediate: in std_logic_vector(31 downto 0); -- Rt or the immediate value
    ALU_operand_code: in std_logic_vector(5 downto 0);
    ALU_result_out: out std_logic_vector(31 downto 0) ;
  );

end entity ALU;


architecture ALU_architecture of ALU is 

  -- high and low part for mul and div instruction
  signal high: std_logic_vector(31 downto 0);
  signal low: std_logic_vector(31 downto 0);

  begin 

   process(ALU_RS,ALU_RT,ALU_operand_code) 

    begin  

      case ALU_operand_code is
		
      	when "000000" => --add 
          --Rd = Rs+Rt
          ALU_result_out <= std_logic_vector(unsigned(ALU_RS) + unsigned(ALU_RT_or_immediate));

       	when "000001" => --sub 
          --Rd = Rs-Rt
          ALU_result_out <= std_logic_vector(unsigned(ALU_RS) - unsigned(ALU_RT_or_immediate));
          
      	when "000010" => --addi 
          --Rd = Rs+immediate
          ALU_result_out <= std_logic_vector(unsigned(ALU_RS) + unsigned(ALU_RT_or_immediate));

       	when "000011" => --mul
          -- Rd = Rs * Rt
          high <= std_logic_vector(to_unsigned(to_integer (unsigned(ALU_RS)) * to_integer (unsigned(ALU_RT_or_immediate)), 32)) (63 downto 32);
          low <= std_logic_vector(to_unsigned(to_integer (unsigned(ALU_RS)) * to_integer (unsigned(ALU_RT_or_immediate)), 32)) (31 downto 0);
          ALU_result_out <= std_logic_vector(to_unsigned(to_integer (unsigned(ALU_RS)) * to_integer (unsigned(ALU_RT_or_immediate)), 32));
          
        when "000100" => --div
        -- Rd = Rs / Rt
          high <= std_logic_vector(to_unsigned(to_integer (unsigned(ALU_RS)) mod to_integer (unsigned(ALU_RT_or_immediate)), 32));
          low <= std_logic_vector(to_unsigned(to_integer (unsigned(ALU_RS)) / to_integer (unsigned(ALU_RT_or_immediate)), 32));
          ALU_result_out <= std_logic_vector(to_unsigned(to_integer (unsigned(ALU_RS)) / to_integer (unsigned(ALU_RT_or_immediate)), 32));
     	
        when "000101" => --slt 
          --Rd = (Rs < Rt) ? 1 : 0
          if unsigned(ALU_RS) < unsigned(ALU_RT_or_immediate) then
          	ALU_result_out <= "00000000000000000000000000000001";
          else
          	ALU_result_out <= "00000000000000000000000000000000";
          end if;

       	when "000110" => --slti 
          --slt Rd = (Rs < immediate) ? 1 : 0
          if unsigned(ALU_RS) < unsigned(ALU_RT_or_immediate) then
          	ALU_result_out <= "00000000000000000000000000000001";
          else
          	ALU_result_out <= "00000000000000000000000000000000";
          end if;
        
        when "000111" => --and
          -- Rd = Rs and Rt
          ALU_result_out<= ALU_RS and ALU_RT_or_immediate;

       	when "001000" => --or
          -- Rd = Rs or Rt
          ALU_result_out<= ALU_RS or ALU_RT_or_immediate;
          
      	when "001001" => --nor
          -- Rd = Rs nor Rt
          ALU_result_out<= ALU_RS nor ALU_RT_or_immediate;

       	when "001010" => --xor
          -- Rd = Rs xor Rt
          ALU_result_out<= ALU_RS xor ALU_RT_or_immediate;
     	
        when "001011" =>  --andi
          -- Rd = Rs and immediate
          ALU_result_out<= ALU_RS and ALU_RT_or_immediate;

        when "001100" =>  --ori
          -- Rd = Rs or immediate
          ALU_result_out<= ALU_RS or ALU_RT_or_immediate;

        when "001101" =>  --xori
          -- Rd = Rs xor immediate
          ALU_result_out<= ALU_RS xor ALU_RT_or_immediate;
        
        when "001110" =>  --mfhi
          -- move the high part to the output
          ALU_result_out <= high;

        when "001111" =>  --mflo
          -- move the low part to the output
          ALU_result_out <= low;

        when "010000" =>  --lui
          --  rt<31,16> = immed,  rt<15,0> = 0
          ALU_result_out <= ALU_RT_or_immediate (15 downto 0)  & "0000000000000000";
        
        when "010001" =>  --sll
          -- shift left by Rt bits, so load 31 - Rt bits of Rs and add Rt bits of 0
          ALU_result_out <= ALU_RS((31-to_integer(unsigned(ALU_RT_or_immediate))) downto 0) & std_logic_vector(0,to_integer(unsigned(ALU_RT_or_immediate)));

        when "010010" =>  --srl
          -- shift right by Rt bits, so Rt bits 0, and add 31 - Rt bits of Rs
          ALU_result_out <= std_logic_vector(0,to_integer(unsigned(ALU_RT_or_immediate))) & ALU_RS( 31 downto (31-to_integer(unsigned(ALU_RT_or_immediate))));
        
        when "010011" =>  --sra
          -- if the most significant bit of Rs is 1, add 1, otherwise add by zero, and with 31 - Rt bits of Rs
          if ALU_RS(31) = '0' then
          	ALU_result_out <= std_logic_vector(0,to_integer(unsigned(ALU_RT_or_immediate))) & ALU_RS( 31 downto (31-to_integer(unsigned(ALU_RT_or_immediate))));
          else 
            ALU_result_out <= std_logic_vector(1,to_integer(unsigned(ALU_RT_or_immediate))) & ALU_RS( 31 downto (31-to_integer(unsigned(ALU_RT_or_immediate))));
          end if;
          
        when "010100" =>  --lw
          -- since we use a control logic to determine whether we should load, so only calculate address
          ALU_result_out<= std_logic_vector(unsigned(ALU_RS) + unsigned(ALU_RT_or_immediate));
       
        when "010101" =>  --sw
          -- since we use a control logic to determine whether we should store, so only calculate address
          ALU_result_out<= std_logic_vector(unsigned(ALU_RS) + unsigned(ALU_RT_or_immediate));
        
        when "010110" =>  --beq
          -- since use a comparator, so only calculate the address : addr = pc + immediate
          ALU_result_out<= std_logic_vector(unsigned(ALU_RS) + unsigned(ALU_RT_or_immediate));
       
        when "010111" =>  --bne
          -- since use a comparator, so only calculate the address : addr = pc + immediate
          ALU_result_out<= std_logic_vector(unsigned(ALU_RS) + unsigned(ALU_RT_or_immediate));
          
        when "011000" =>  --j
          -- jump, address = Rs
          ALU_result_out<= ALU_RS;  
       
        when "011001" =>  --jr
          -- jump register, address = Rs
          ALU_result_out<= ALU_RS;
        
        when "011010" =>  --jal
          -- jump and link, address = Rs
          ALU_result_out<= ALU_RS;
          
        when others =>
          -- undefined instruction
		  ALU_result_out <= "00000000000000000000000000000000";

      end case;

    end process; 

end architecture ; 

