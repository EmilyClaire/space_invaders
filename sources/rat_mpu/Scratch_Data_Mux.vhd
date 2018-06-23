

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity SCR_DATA_MUX is
  Port (DX : in std_logic_vector(7 downto 0);
        PC_COUNT : in std_logic_vector(9 downto 0);
        SCR_DATA_SEL : in std_logic;
        DATA_IN : out std_logic_vector (9 downto 0));
end SCR_DATA_MUX;

architecture Behavioral of SCR_DATA_MUX is

begin 
process(DX, PC_COUNT, SCR_DATA_SEL)
variable temp_SCR : std_logic_vector(9 downto 0) := "0000000000";
Begin

    if(SCR_DATA_SEL = '0')then
        temp_SCR := "00" & DX;
    end if;

    if(SCR_DATA_SEL = '1')then
        temp_SCR := PC_COUNT;
    end if;
 
DATA_IN <= temp_SCR; 
end process;
end Behavioral;