library IEEE;use
IEEE.STD_LOGIC_1164.ALL;use
IEEE.STD_LOGIC_ARITH.ALL;use
IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pc is 

port(
    Din_PC      : in std_logic_vector (9 downto 0);
    PC_LD_PC    : in std_logic;
    PC_INC_PC   : in std_logic;
    RST_PC      : in std_logic;
    CLK_PC      : in std_logic;
    PC_COUNT_PC : out std_logic_vector (9 downto 0));
end pc;

Architecture behavioral of pc is
    signal count : std_logic_vector (9 downto 0);
Begin

Process(RST_PC, PC_INC_PC, PC_LD_PC, CLK_PC)
    begin
    if (rising_edge(CLK_PC)) then
        if (RST_PC = '1') then
            count <= "0000000000";
        elsif(PC_LD_PC = '1') then
            count <= Din_PC;
        elsif(PC_INC_PC = '1') then
            count <= count + 1;                        
        end if;
    end if;
    end process;
    
    PC_COUNT_PC <= count;
    
end behavioral;