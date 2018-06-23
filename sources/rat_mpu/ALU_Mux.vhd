----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/11/2017 05:40:28 PM
-- Design Name: 
-- Module Name: ALU_MUX - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU_MUX is
  Port (SY : in std_logic_vector(7 downto 0);
        IR : in std_logic_vector(7 downto 0);
        REG_IMMED_SEL : in std_logic;
        Mux_Output : out std_logic_vector (7 downto 0));
end ALU_MUX;

architecture Behavioral of ALU_MUX is

begin 
process(SY, IR, REG_IMMED_SEL)
variable temp_ALU : std_logic_vector(7 downto 0) := x"00";
Begin

    if(REG_IMMED_SEL = '0')then
        temp_ALU := SY;
    end if;

    if(REG_IMMED_SEL = '1')then
        temp_ALU := IR;
    end if;
 
Mux_Output <= temp_ALU; 
end process;
end Behavioral;