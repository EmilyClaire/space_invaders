-- 
-- A flip-flop to store the the zero, carry, and interrupt flags.
-- To be used in the RAT CPU.
-- 
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Shad_FlagReg_C is
    Port ( IN_FLAG  : in  STD_LOGIC; --flag input
           LD       : in  STD_LOGIC; --load the out_flag with the in_flag value
           CLK      : in  STD_LOGIC; --system clock
           OUT_FLAG : out  STD_LOGIC); --flag output
end Shad_FlagReg_C;

architecture Behavioral of Shad_FlagReg_C is
begin
    process(CLK)
    begin
        if( rising_edge(CLK) ) then
            if( LD = '1' ) then
                OUT_FLAG <= IN_FLAG;
         end if;
      end if;
    end process;				
end Behavioral;
