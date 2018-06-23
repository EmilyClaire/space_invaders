
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity int_input is
  Port (INT_in : in std_logic;
        I_set : in std_logic;
        I_clr : in std_logic;
        clk : in std_logic;
        INT_out : out std_logic);
end int_input;

architecture Behavioral of int_input is

signal flip_flop_out : std_logic;

begin

    process(clk) is
    begin
    
    
    
    if rising_edge(clk) then
        if (i_clr = '1') then
            flip_flop_out <= '0';
        elsif (i_set = '1') then
            flip_flop_out <= '1';
        end if;
    end if;

end process;

INT_out <= flip_flop_out and INT_in;

end Behavioral;
