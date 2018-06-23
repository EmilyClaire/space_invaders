

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flag_mux is
  Port (Data_In  : in std_logic;
        Flag_Sel : in std_logic;
        Shad_Out : in std_logic;
        Data_Out : out std_logic );
end flag_mux;

architecture Behavioral of flag_mux is

signal Mux_Out : std_logic;

begin

    process(Data_In, Flag_Sel, Shad_Out)
        begin
            if (Flag_Sel = '0') then
                Mux_Out <= Data_In;
            end if;
            if (Flag_Sel = '1') then
                Mux_Out <= Shad_Out;
            end if;

    end process;

Data_Out <= Mux_Out;

end Behavioral;
