library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_mux is
  Port ( 
            RF_WR_SEL : in std_logic_vector(1 downto 0);
            IN_PORT   : in std_logic_vector(7 downto 0);
            SP_DATA   : in std_logic_vector(7 downto 0);
            ALU_RESULT: in std_logic_vector(7 downto 0);
            SCR_DATA  : in std_logic_vector (7 downto 0);
            DIN       : out std_logic_vector (7 downto 0)
      );
end reg_mux;

architecture Behavioral of reg_mux is
signal output : std_logic_vector(7 downto 0);
begin
    Process(SP_DATA, RF_WR_SEL, IN_PORT, ALU_RESULT, SCR_DATA)
        begin 
        if(RF_WR_SEL = "00")then
            output <= ALU_RESULT;

        elsif(RF_WR_SEL = "01")then   
            output <= SCR_DATA(7 downto 0);

        elsif(RF_WR_SEL = "10")then
            output <= SP_DATA;
        
        else
            output <= IN_PORT;
        end if; 
end Process;

DIN <= output;

end Behavioral;
