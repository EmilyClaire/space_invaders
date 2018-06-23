library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ScratchRAM is
    Port ( DATA_IN  : in     STD_LOGIC_VECTOR (9 downto 0);
           ADR      : in     STD_LOGIC_VECTOR (7 downto 0);
           WE       : in     STD_LOGIC;
           CLK      : in     STD_LOGIC;
           DATA_OUT : out    STD_LOGIC_VECTOR (9 downto 0));
end ScratchRAM;

architecture Behavioral of ScratchRAM is
	TYPE memory is array (0 to 255) of std_logic_vector(9 downto 0);
	SIGNAL RAM: memory := (others=>(others=>'0'));
begin

	process(CLK)
	begin
		if (rising_edge(CLK)) then
	          if (WE = '1') then
			RAM(conv_integer(ADR)) <= DATA_IN;
		  end if;
		end if;
	end process;

	DATA_OUT <= RAM(conv_integer(ADR));    
	
end Behavioral;