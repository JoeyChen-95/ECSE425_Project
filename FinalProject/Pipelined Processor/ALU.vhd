LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU IS
  PORT (
    -- Rs,Rt,operand, output result
    ALU_RS : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    ALU_RT_or_immediate : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Rt or the immediate value
    ALU_operand_code : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    ALU_result_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );

END ENTITY ALU;
ARCHITECTURE ALU_architecture OF ALU IS

  -- High and low part for multiplication and division. 
  SIGNAL high : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL low : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

  PROCESS (ALU_RS, ALU_RT_or_immediate, ALU_operand_code)
    VARIABLE sig_int : INTEGER; -- used for dynamic generating 1s in the sra 
    VARIABLE long : STD_LOGIC_VECTOR(63 DOWNTO 0);

  BEGIN
    CASE ALU_operand_code IS

      WHEN "000000" =>
        -- ADD 
        -- Rd = Rs+Rt
        ALU_result_out <= STD_LOGIC_VECTOR(signed(ALU_RS) + signed(ALU_RT_or_immediate));
        
      WHEN "000001" =>
        -- SUB 
        -- Rd = Rs-Rt
        ALU_result_out <= STD_LOGIC_VECTOR(signed(ALU_RS) - signed(ALU_RT_or_immediate));
      
      WHEN "000010" =>
        -- ADDI 
        -- Rd = Rs+immediate
        ALU_result_out <= STD_LOGIC_VECTOR(signed(ALU_RS) + signed(ALU_RT_or_immediate));
      
      WHEN "000011" =>
        -- MUL
        -- Rd = Rs * Rt
        long := STD_LOGIC_VECTOR(signed(ALU_RS) * signed(ALU_RT_or_immediate));
        high <= long (63 DOWNTO 32);
        low <= long(31 DOWNTO 0);
        ALU_result_out <= (OTHERS => '0');
      
      WHEN "000100" =>
        -- DIV
        -- Rd = Rs / Rt
        high <= STD_LOGIC_VECTOR(signed(ALU_RS) MOD signed(ALU_RT_or_immediate));
        low <= STD_LOGIC_VECTOR(signed(ALU_RS) / signed(ALU_RT_or_immediate));
        ALU_result_out <= (OTHERS => '0');
      
      WHEN "000101" =>
        -- SLT 
        -- Rd = (Rs < Rt) ? 1 : 0
        IF signed(ALU_RS) < signed(ALU_RT_or_immediate) THEN
          ALU_result_out <= (0 => '1', OTHERS => '0');
        ELSE
          ALU_result_out <= (OTHERS => '0');
        END IF;
      
      WHEN "000110" =>
        -- SLTI 
        -- slt Rd = (Rs < immediate) ? 1 : 0
        IF unsigned(ALU_RS) < unsigned(ALU_RT_or_immediate) THEN
          ALU_result_out <= (0 => '1', OTHERS => '0');
        ELSE
          ALU_result_out <= (OTHERS => '0');
        END IF;
      
      WHEN "000111" =>
        -- AND
        -- Rd = Rs and Rt
        ALU_result_out <= ALU_RS AND ALU_RT_or_immediate;
      
      WHEN "001000" =>
        -- OR
        -- Rd = Rs or Rt
        ALU_result_out <= ALU_RS OR ALU_RT_or_immediate;
      
      WHEN "001001" =>
        -- NOR
        -- Rd = Rs nor Rt
        ALU_result_out <= ALU_RS NOR ALU_RT_or_immediate;
      
      WHEN "001010" =>
        -- XOR
        -- Rd = Rs xor Rt
        ALU_result_out <= ALU_RS XOR ALU_RT_or_immediate;
      
      WHEN "001011" =>
        -- ANDI
        -- Rd = Rs and immediate
        ALU_result_out <= ALU_RS AND ALU_RT_or_immediate;
      
      WHEN "001100" =>
        -- ORI
        -- Rd = Rs or immediate
        ALU_result_out <= ALU_RS OR ALU_RT_or_immediate;
      
      WHEN "001101" =>
        -- XORI
        -- Rd = Rs xor immediate
        ALU_result_out <= ALU_RS XOR ALU_RT_or_immediate;
      
      WHEN "001110" =>
        -- MFHI
        -- Move the high part to the output.
        ALU_result_out <= high;
      
      WHEN "001111" =>
        -- MFLO
        -- Move the low part to the output.
        ALU_result_out <= low;
      
      WHEN "010000" =>
        -- LUI
        -- rt<31,16> = immed,  rt<15,0> = 0
        ALU_result_out <= ALU_RT_or_immediate (15 DOWNTO 0) & "0000000000000000";
      
      WHEN "010001" =>
        -- SLL
        -- Shift left by Rt bits, and thus 
        -- we have (32 - Rt) bits of Rs, followed
        -- by Rt bits of 0.
        ALU_result_out <= ALU_RS((31 - to_integer(unsigned(ALU_RT_or_immediate))) DOWNTO 0) & STD_LOGIC_VECTOR(to_unsigned(0, to_integer(unsigned(ALU_RT_or_immediate))));
      
      WHEN "010010" =>
        -- SRL
        -- Shift right by Rt bits, so 
        -- we have Rt 0s, followed by (32 - Rt) bits of Rs.
        ALU_result_out <= STD_LOGIC_VECTOR(to_unsigned(0, to_integer(unsigned(ALU_RT_or_immediate)))) & ALU_RS(31 DOWNTO (to_integer(unsigned(ALU_RT_or_immediate))));
      
      WHEN "010011" =>
        -- SRA
        -- If the most significant bit of Rs is 1, 
        -- we shall fill vacant spots with 1s, otherwise with 0s. 
        -- The lower parts are filled with first (32 - Rt)
        -- digits of Rs.
        IF ALU_RS(31) = '0' THEN
          ALU_result_out <= STD_LOGIC_VECTOR(to_unsigned(0, to_integer(unsigned(ALU_RT_or_immediate)))) & ALU_RS(31 DOWNTO (to_integer(unsigned(ALU_RT_or_immediate))));
        ELSE
          IF (to_integer(unsigned(ALU_RT_or_immediate))) = 0 THEN
            ALU_result_out <= ALU_RS;
          ELSE
            sig_int := 1;
            FOR n IN 0 TO (to_integer(unsigned(ALU_RT_or_immediate))) - 1 LOOP
              sig_int := sig_int * 2;
            END LOOP;
            ALU_result_out <= STD_LOGIC_VECTOR(to_unsigned(sig_int - 1, to_integer(unsigned(ALU_RT_or_immediate)))) & ALU_RS(31 DOWNTO (to_integer(unsigned(ALU_RT_or_immediate))));
          END IF;
        END IF;
      
      WHEN "010100" =>
        -- LW
        -- Calculate the target memory address for load.
        ALU_result_out <= STD_LOGIC_VECTOR(unsigned(ALU_RS) + unsigned(ALU_RT_or_immediate));
      
      WHEN "010101" =>
        -- SW
        -- Calculate the target memory address for store.
        ALU_result_out <= STD_LOGIC_VECTOR(unsigned(ALU_RS) + unsigned(ALU_RT_or_immediate));
      
      WHEN OTHERS =>
        -- Undefined instruction
        ALU_result_out <= (OTHERS => '0');
    END CASE;
  END PROCESS;
END ARCHITECTURE;
