library IEEE;use
IEEE.STD_LOGIC_1164.ALL;use
IEEE.STD_LOGIC_ARITH.ALL;use
IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Stack_Pointer is
  Port (RST : in std_logic;
        LD : in std_logic;
        INCR : in std_logic;
        DECR : in std_logic;
        CLK :in std_logic;
        DATA : in std_logic_vector (7 downto 0);
        SP_OUT : out std_logic_vector (7 downto 0));
end Stack_Pointer;

architecture Behavioral of Stack_Pointer is
signal count : std_logic_vector (7 downto 0) := x"00";
begin


Process(CLK,RST,INCR,DECR)
begin

    if (rising_edge(CLK)) then
        if (RST = '1') then
            count <= x"00";
        else 
        
        if(LD = '1') then
            count <= DATA;
        end if;
        if(INCR = '1') then
            count <= count + 1;
        end if;    
        if(DECR = '1') then
            count <= count - 1; 
        end if;                      
        
       end if;
    end if;

end process;
    
    SP_OUT <= count;

end Behavioral;
