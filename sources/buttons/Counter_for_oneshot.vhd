library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity counter is
    Port ( RST    : in  STD_LOGIC;
           CLK    : in  STD_LOGIC;
           INC    : in  STD_LOGIC;
           COUNT  : out STD_LOGIC_VECTOR (7 downto 0));
end counter;

architecture Behavioral of counter is

   signal s_count : std_logic_vector (7 downto 0) := "00000000";
   
begin

    proc: process(CLK, RST, INC, s_count)
    begin
       if(rising_edge(CLK)) then
          if(RST = '1') then             -- synchronous reset
             s_count <= "00000000";
          elsif(INC = '1') then
             s_count <= s_count + '1';
          end if;       
        end if;
    end process proc;
    
    COUNT <= s_count;

end Behavioral;
