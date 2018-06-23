LIBRARY ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.std_logic_arith.all;

entity ALU is
  Port (A      : in std_logic_vector (7 downto 0);
        B      : in std_logic_vector (7 downto 0);
        SEL    : in std_logic_vector (3 downto 0);
        Cin    : in std_logic;
        Result : out std_logic_vector (7 downto 0);
        C      : out std_logic;
        Z      : out std_logic);
end ALU;

architecture Behavioral of ALU is

signal s_out : std_logic_vector (7 downto 0) := x"00";
signal s_c   : std_logic := '0';
signal s_z   : std_logic := '0';

begin
 process (SEL, A, B, Cin)
    variable v_outAndC: std_logic_vector (8 downto 0) := "000000000";
    variable v_out: std_logic_vector (7 downto 0):= x"00";
 begin

  case SEL is
    --ADD
    when "0000" => 
        v_outAndC := ('0' & A ) + B;
        s_c <= v_outAndC(8);
        v_out := v_outAndC(7 downto 0);
        
        if(v_out = x"00") then
            s_z <= '1';
        else
            s_z <= '0';
        end if;
               
        s_out <= v_out;
                
    --ADDC            
    when "0001" => 
        v_outAndC := ('0' & A) + B + Cin;
        s_c <= v_outAndC(8);
        v_out := v_outAndC(7 downto 0);
        
        if(v_out = x"00") then
            s_z <= '1';
        else
            s_z <= '0';
        end if;
        
        s_out <= v_out;
    
    --SUB    
    when "0010" =>
        v_outAndC := ('0' & A) - B;
        s_c <= v_outAndC(8);
        v_out := v_outAndC(7 downto 0);
        
        if(v_out = x"00") then
            s_z <= '1';
        else
            s_z <= '0';
        end if;
        
        s_out <= v_out;
        
    --SUBC
    when "0011" =>
        v_outAndC := ('0' & A) - B - Cin;
        s_c <= v_outAndC(8);
        v_out := v_outAndC(7 downto 0);
        
        if(v_out = x"00") then
            s_z <= '1';
        else
            s_z <= '0';
        end if;
        
        s_out <= v_out;
        
    --CMP    
    when "0100" =>
        v_outAndC := ('0' & A) - B;
        v_out := v_outAndC(7 downto 0);
        s_c <= v_outAndC(8);
        
        if(v_out = x"00") then
            s_z <= '1';
        else
            s_z <= '0';
        end if;

        s_out <= A;
        
    --AND    
    when "0101" =>
        v_out :=  A and B;
        s_c <= '0';
        
        if(v_out = x"00") then
            s_z <= '1';
        else
            s_z <= '0';
        end if;
        
        s_out <= v_out;
        
    --OR    
    when "0110" => 
        v_out := A or B;        
        s_c <= '0';
        if(v_out = x"00") then
            s_z <= '1';
        else
            s_z <= '0';
        end if;
        
        s_out <= v_out;
        
    --EXOR    
    when "0111" => 
        v_out := A xor B;
        s_c <= '0';
        if(v_out = x"00") then
            s_z <= '1';
        else
            s_z <= '0';
        end if;
        
        s_out <= v_out;
        
    --TEST    
    when "1000" => 
        v_out := A and B;
        s_c <= '0';
        if(v_out = x"00") then
            s_z <= '1';
        else
            s_z <= '0';
        end if;
        
        s_out <= A;
        
    --LSL    
    when "1001" => 
        v_out := A(6 downto 0) & Cin;
        s_c <= A(7);
        
        if(v_out = x"00") then
            s_z <= '1';
        else
            s_z <= '0';
        end if;
    
        s_out <= v_out;
    
    --LSR
    when "1010" => 
         v_out := Cin & A(7 downto 1);
         s_c <= A(0);
      
         if(v_out = x"00") then
             s_z <= '1';
         else
             s_z <= '0';
         end if;
         
         s_out <= v_out;
         
    --ROL     
    when "1011" => 
        v_out := A(6 downto 0) & A(7);
        s_c <= A(7);

        if(v_out = x"00") then
            s_z <= '1';
        else
            s_z <= '0';
        end if;

        s_out <= v_out;

    --ROR
    when "1100" => 
        v_out := A(0) & A(7 downto 1);
        s_c <= A(0);
        
        if(v_out = x"00") then
            s_z <= '1';
        else
            s_z <= '0';
        end if;
        
        s_out <= v_out;
        
    --ASR
    when "1101" => 
        v_out := A(7) & A(7 downto 1);
        s_c <= A(0);
        
        if(v_out = x"00") then
            s_z <= '1';
        else
            s_z <= '0';
        end if;
        
        s_out <= v_out;
        
    --MOV    
    when "1110" => 
        s_out <= B;

    --Not Used
    when others =>
         s_out <= x"FF";
         s_c <= '0';
         s_z <= '0';
 end case;
 
 end process;
 
 c <= s_c;
 z <= s_z;
 Result <= s_out;
 
end Behavioral;
