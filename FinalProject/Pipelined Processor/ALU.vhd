LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU IS
  PORT (
    -- clock, reset, stall
    ALU_clock : IN STD_LOGIC;
    --     ALU_reset: in std_logic;
    --     ALU_stall: in std_logic;

    -- Rs,Rt,operand, output result
    ALU_RS : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    ALU_RT_or_immediate : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Rt or the immediate value
    ALU_operand_code : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    ALU_result_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );

END ENTITY ALU;
ARCHITECTURE ALU_architecture OF ALU IS

  -- high and low part for mul and div instruction
  SIGNAL high : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL low : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

  PROCESS (ALU_RS, ALU_RT_or_immediate, ALU_operand_code)
    VARIABLE sig_int : INTEGER; -- used for dynamic generating 1s in the sra 
    VARIABLE long : STD_LOGIC_VECTOR(63 DOWNTO 0);

  BEGIN

    CASE ALU_operand_code IS

      WHEN "000000" => --add 
        --Rd = Rs+Rt
        ALU_result_out <= STD_LOGIC_VECTOR(signed(ALU_RS) + signed(ALU_RT_or_immediate));

      WHEN "000001" => --sub 
        --Rd = Rs-Rt
        ALU_result_out <= STD_LOGIC_VECTOR(signed(ALU_RS) - signed(ALU_RT_or_immediate));

      WHEN "000010" => --addi 
        --Rd = Rs+immediate
        ALU_result_out <= STD_LOGIC_VECTOR(signed(ALU_RS) + signed(ALU_RT_or_immediate));

      WHEN "000011" => --mul
        -- Rd = Rs * Rt
        long := STD_LOGIC_VECTOR(signed(ALU_RS) * signed(ALU_RT_or_immediate));
        high <= long (63 DOWNTO 32);
        low <= long(31 DOWNTO 0);
        ALU_result_out <= (OTHERS => '0');

      WHEN "000100" => --div
        -- Rd = Rs / Rt
        high <= STD_LOGIC_VECTOR(signed(ALU_RS) MOD signed(ALU_RT_or_immediate));
        low <= STD_LOGIC_VECTOR(signed(ALU_RS) / signed(ALU_RT_or_immediate));
        ALU_result_out <= (OTHERS => '0');

      WHEN "000101" => --slt 
        --Rd = (Rs < Rt) ? 1 : 0
        IF signed(ALU_RS) < signed(ALU_RT_or_immediate) THEN
          ALU_result_out <= "00000000000000000000000000000001";
        ELSE
          ALU_result_out <= "00000000000000000000000000000000";
        END IF;

      WHEN "000110" => --slti 
        --slt Rd = (Rs < immediate) ? 1 : 0
        IF unsigned(ALU_RS) < unsigned(ALU_RT_or_immediate) THEN
          ALU_result_out <= "00000000000000000000000000000001";
        ELSE
          ALU_result_out <= "00000000000000000000000000000000";
        END IF;

      WHEN "000111" => --and
        -- Rd = Rs and Rt
        ALU_result_out <= ALU_RS AND ALU_RT_or_immediate;

      WHEN "001000" => --or
        -- Rd = Rs or Rt
        ALU_result_out <= ALU_RS OR ALU_RT_or_immediate;

      WHEN "001001" => --nor
        -- Rd = Rs nor Rt
        ALU_result_out <= ALU_RS NOR ALU_RT_or_immediate;

      WHEN "001010" => --xor
        -- Rd = Rs xor Rt
        ALU_result_out <= ALU_RS XOR ALU_RT_or_immediate;

      WHEN "001011" => --andi
        -- Rd = Rs and immediate
        ALU_result_out <= ALU_RS AND ALU_RT_or_immediate;

      WHEN "001100" => --ori
        -- Rd = Rs or immediate
        ALU_result_out <= ALU_RS OR ALU_RT_or_immediate;

      WHEN "001101" => --xori
        -- Rd = Rs xor immediate
        ALU_result_out <= ALU_RS XOR ALU_RT_or_immediate;

      WHEN "001110" => --mfhi
        -- move the high part to the output
        ALU_result_out <= high;

      WHEN "001111" => --mflo
        -- move the low part to the output
        ALU_result_out <= low;

      WHEN "010000" => --lui
        --  rt<31,16> = immed,  rt<15,0> = 0
        ALU_result_out <= ALU_RT_or_immediate (15 DOWNTO 0) & "0000000000000000";

      WHEN "010001" => --sll
        -- shift left by Rt bits, so load 31 - Rt bits of Rs and add Rt bits of 0
        ALU_result_out <= ALU_RS((31 - to_integer(unsigned(ALU_RT_or_immediate))) DOWNTO 0) & STD_LOGIC_VECTOR(to_unsigned(0, to_integer(unsigned(ALU_RT_or_immediate))));

      WHEN "010010" => --srl
        -- shift right by Rt bits, so Rt bits 0, and add 31 - Rt bits of Rs
        ALU_result_out <= STD_LOGIC_VECTOR(to_unsigned(0, to_integer(unsigned(ALU_RT_or_immediate)))) & ALU_RS(31 DOWNTO (to_integer(unsigned(ALU_RT_or_immediate))));

      WHEN "010011" => --sra
        -- if the most significant bit of Rs is 1, add 1, otherwise add by zero, and with 31 - Rt bits of Rs
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

      WHEN "010100" => --lw
        -- since we use a control logic to determine whether we should load, so only calculate address
        ALU_result_out <= STD_LOGIC_VECTOR(unsigned(ALU_RS) + unsigned(ALU_RT_or_immediate));

      WHEN "010101" => --sw
        -- since we use a control logic to determine whether we should store, so only calculate address
        ALU_result_out <= STD_LOGIC_VECTOR(unsigned(ALU_RS) + unsigned(ALU_RT_or_immediate));

      WHEN "010110" => --beq
        -- since use a comparator, so only calculate the address : addr = pc + immediate
        ALU_result_out <= STD_LOGIC_VECTOR(unsigned(ALU_RS) + unsigned(ALU_RT_or_immediate));

      WHEN "010111" => --bne
        -- since use a comparator, so only calculate the address : addr = pc + immediate
        ALU_result_out <= STD_LOGIC_VECTOR(unsigned(ALU_RS) + unsigned(ALU_RT_or_immediate));

      WHEN "011000" => --j
        -- jump, address = Rs
        ALU_result_out <= ALU_RT_or_immediate;

      WHEN "011001" => --jr
        -- jump register, address = Rs
        ALU_result_out <= ALU_RS;

      WHEN "011010" => --jal
        -- jump and link, address = Rs
        ALU_result_out <= ALU_RS;

      WHEN OTHERS =>
        -- undefined instruction
        ALU_result_out <= "00000000000000000000000000000000";

    END CASE;

  END PROCESS;

END ARCHITECTURE;