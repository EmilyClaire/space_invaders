library IEEE;use
IEEE.STD_LOGIC_1164.ALL;

entity mux is 
port( FROM_IMMED_MUX : in  std_logic_vector(9 downto 0);
      FROM_STACK_MUX : in  std_logic_vector(9 downto 0);
      x3FF_MUX       : in  std_logic_vector(9 downto 0);
      MUX_SEL_MUX    : in  std_logic_vector(1 downto 0);
      OUTPUT_MUX     : out std_logic_vector(9 downto 0));

end mux;

Architecture behavioral of mux is
Begin

Process(FROM_IMMED_MUX, FROM_STACK_MUX, x3ff_MUX, MUX_SEL_MUX)
variable temp : std_logic_vector(9 downto 0);
Begin

if(MUX_SEL_MUX = "00")then
temp := FROM_IMMED_MUX;

elsif(MUX_SEL_MUX = "01")then  
temp := FROM_STACK_MUX;

elsif(MUX_SEL_MUX = "10")then
temp := x3FF_MUX;

else
temp := "1111111111"; -- returns -1 because got an invalid option of "11"
end if; 

OUTPUT_MUX <= temp;
end Process;
end behavioral; 