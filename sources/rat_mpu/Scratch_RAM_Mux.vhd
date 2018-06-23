LIBRARY ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity SCR_MUX is
  Port (SY          : in std_logic_vector(7 downto 0);
        IR          : in std_logic_vector(7 downto 0);
        SP_OUT      : in std_logic_vector(7 downto 0);
        SCR_ADDR_SEL : in std_logic_vector (1 downto 0);
        SCR_Output : out std_logic_vector (7 downto 0));
end SCR_MUX;

architecture Behavioral of SCR_MUX is

begin 
process(SY, IR, SP_OUT, SCR_ADDR_SEL)
variable temp_SCR : std_logic_vector(7 downto 0) := x"00";
Begin

    if(SCR_ADDR_SEL = "00")then
        temp_SCR := SY;
    elsif(SCR_ADDR_SEL = "01")then
        temp_SCR := IR;
    elsif(SCR_ADDR_SEL = "10") then
        temp_SCR := SP_OUT;
    else
        temp_SCR := SP_OUT - 1;
    end if;
    
SCR_Output <= temp_SCR; 
end process;


end Behavioral;