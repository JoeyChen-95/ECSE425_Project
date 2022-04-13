-- Code your design here
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY Comparator IS
    PORT (
        branch_ctl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        reg1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_taken : OUT STD_LOGIC_VECTOR;
    );
END Comparator;

ARCHITECTURE arch OF Comparator IS
BEGIN
    -- The comparator is only used by the ID stage,
    -- for branching. In this component, we could 
    -- encounter 5 cases. For each of them, we have
    -- a specifcal branch code.
    -- 1. beq       (000)
    -- 2. bne       (001)
    -- 3. j         (010)
    -- 4. jr        (011)
    -- 5. jal       (100)
    -- 6. no branch (101)

    IF (branch_ctl = "101") THEN
        -- no branch
        branch_taken <= '0';

    ELSIF (branch_ctl = "000") THEN
        -- beq
        branch_taken <= '1' WHEN reg1 = reg2 ELSE
            '0';
    ELSIF (branch_ctl = "001") THEN
        -- bne
        branch_taken <= '1' WHEN reg1 /= reg2 ELSE
            '0';
    ELSE
        -- j, jr, and jal
        branch_taken <= '1';
    END IF;

END arch;