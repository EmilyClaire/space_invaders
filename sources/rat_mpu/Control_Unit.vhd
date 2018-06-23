----------------------------------------------------------------------------------
-- Company:  CPE 233
-- -------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CONTROL_UNIT is
    Port ( CLK           : in   STD_LOGIC;
           C_FLAG        : in   STD_LOGIC;
           Z_FLAG        : in   STD_LOGIC;
           INT           : in   STD_LOGIC;
		   RESET         : in   STD_LOGIC;
		   OPCODE_HI_5   : in   STD_LOGIC_VECTOR (4 downto 0);
		   OPCODE_LO_2   : in   STD_LOGIC_VECTOR (1 downto 0);
			  
           PC_RST        : out  STD_LOGIC;
		   PC_LD         : out  STD_LOGIC;
		   PC_INC        : out  STD_LOGIC;
           PC_MUX_SEL    : out  STD_LOGIC_VECTOR (1 downto 0);
		   
           SP_LD         : out  STD_LOGIC;
		   SP_INCR       : out  STD_LOGIC;
		   SP_DECR       : out  STD_LOGIC;

           RF_WR         : out  STD_LOGIC;
		   RF_WR_SEL     : out  STD_LOGIC_VECTOR (1 downto 0);

           ALU_OPY_SEL   : out  STD_LOGIC;
           ALU_SEL       : out  STD_LOGIC_VECTOR (3 downto 0);
		   
           SCR_WR        : out  STD_LOGIC;
           SCR_ADDR_SEL  : out  STD_LOGIC_VECTOR (1 downto 0);
		   SCR_DATA_SEL  : out  STD_LOGIC;
		   
           FLAG_LD_SEL   : out  STD_LOGIC;
		   FLAG_SHAD_LD  : out  STD_LOGIC;
		   
           FLAG_C_LD     : out  STD_LOGIC;
           FLAG_C_SET    : out  STD_LOGIC;
           FLAG_C_CLR    : out  STD_LOGIC;
           
           FLAG_Z_LD     : out  STD_LOGIC;
           FLAG_Z_SET    : out  STD_LOGIC;
           FLAG_Z_CLR    : out  STD_LOGIC;
		   
           I_SET         : out  STD_LOGIC;
           I_CLR         : out  STD_LOGIC;
		   IO_STRB       : out  STD_LOGIC);
end CONTROL_UNIT;

architecture Behavioral of CONTROL_UNIT is

   type state_type is (ST_init, ST_fet, ST_exec, ST_Int);
      signal PS,NS : state_type;
	
	
	signal sig_OPCODE_7: std_logic_vector (6 downto 0);
begin
   -- concatenate the all opcodes into a 7-bit complete opcode for
	-- easy instruction decoding.
   sig_OPCODE_7 <= OPCODE_HI_5 & OPCODE_LO_2;

   sync_p: process (CLK, NS, RESET)
	begin
	   if (RESET = '1') then
		  PS <= ST_init;
	   elsif (rising_edge(CLK)) then
		      PS <= NS;
		end if;
	end process sync_p;

   comb_p: process (sig_OPCODE_7, PS, NS)
   
   begin
     
    -- This is the default block for all signals set in the STATE cases.  Note that any output values desired 
    -- to be different from these values shown below will be assigned in the individual case statements for 
	-- each STATE.  Please note that that this "default" set of values must be stated for each individual case
    -- statement.  We have a case statement for CPU states and then an embedded case statement for OPCODE 
    -- resolution. 

    PC_LD          <= '0';     RF_WR          <= '0';       FLAG_C_LD      <= '0';      I_SET          <= '0';
    PC_INC         <= '0';     RF_WR_SEL      <= "00";       FLAG_C_SET     <= '0';     I_CLR          <= '0';
	PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';
                               ALU_SEL        <= "0000";                               FLAG_LD_SEL    <= '0';
	SP_LD          <= '0';
                                  FLAG_Z_LD      <= '0';     FLAG_SHAD_LD   <= '0';
	SP_INCR        <= '0';
	     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
	SP_DECR        <= '0';
	     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0'; 
	                                                           
	IO_STRB        <= '0';     PC_RST            <= '0';  SCR_DATA_SEL <= '0';
	                                              
	case PS is
	
		   -- STATE: the init cycle ------------------------------------
			-- Initialize all control outputs to non-active states and reset the PC and SP to all zeros.
		when ST_init => 
		    NS <= ST_fet;	
			
			    PC_RST <= '1';
				
         -- STATE: the fetch cycle -----------------------------------
         when ST_fet => 
		    NS <= ST_exec;	
			
			  PC_INC <= '1';
		
-----------------------------------------		           
          when ST_int =>
             NS <= ST_fet;
             
             
             PC_LD          <= '1';     RF_WR          <= '0';       FLAG_C_LD      <= '0';     I_SET        <= '0';
             PC_INC         <= '0';     RF_WR_SEL      <= "00";       FLAG_C_SET    <= '0';     I_CLR          <= '1';
             PC_MUX_SEL     <= "10";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '1';
                                        ALU_SEL        <= "0000";                               FLAG_LD_SEL    <= '0';
             SP_LD          <= '1';     
             FLAG_Z_LD      <= '0';     FLAG_SHAD_LD   <= '1';
             SP_INCR        <= '0';  
             SCR_WR         <= '1';     FLAG_Z_SET     <= '0';      SCR_DATA_SEL <= '1';
             SP_DECR        <= '1'; 
             SCR_ADDR_SEL   <=  "11";   FLAG_Z_CLR     <= '1';                 
                                                                                   
             IO_STRB        <= '0';     PC_RST         <= '0'; 
             
			
        -- STATE: the execute cycle ---------------------------------
		when ST_exec => 
                if(INT = '1') then
                    NS <= ST_int;
                else
			        NS <= ST_fet;
			    end if;
				
				
				-- This is the default block for all signals set in the OPCODE cases.  Note that any output values desired 
				-- to be different from these values shown below will be assigned in the individual case statements for 
				-- each opcode.
				
				PC_LD          <= '0';     RF_WR          <= '0';       FLAG_C_LD      <= '0';      I_SET          <= '0';
				PC_INC         <= '0';     RF_WR_SEL      <= "00";       FLAG_C_SET     <= '0';     I_CLR          <= '0';
				PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';
				                           ALU_SEL        <= "0000";                               FLAG_LD_SEL    <= '0';
				SP_LD          <= '0'; 
                                 FLAG_Z_LD      <= '0';     FLAG_SHAD_LD   <= '0';  SCR_DATA_SEL <= '0';
				SP_INCR        <= '0'; 
				    SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
                SP_DECR        <= '0';
                     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                 
                                                                                      
                IO_STRB        <= '0';     PC_RST            <= '0'; 
	
				
				case sig_OPCODE_7 is	
				
		
					-- ADD R-imm -------------------
           when "1010000" | "1010001" | "1010010" | "1010011" =>   
           
            PC_LD          <= '0';     RF_WR          <= '1';       FLAG_C_LD      <= '1';     I_SET          <= '0';
           PC_INC         <= '0';     RF_WR_SEL      <= "00";       FLAG_C_SET     <= '0';     I_CLR          <= '0';
           PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '1';       FLAG_C_CLR     <= '0';
                                      ALU_SEL        <= "0000";                               FLAG_LD_SEL    <= '0';
           SP_LD          <= '0';   
                           FLAG_Z_LD      <= '1';     FLAG_SHAD_LD   <= '0';
           SP_INCR        <= '0';     
           SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
           SP_DECR        <= '0';   
           SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                 
                                                                                 
           IO_STRB        <= '0';     PC_RST            <= '0';  SCR_DATA_SEL <= '0';
           
           
					-- ADD R-R -------------------
  when "0000100" =>   
  
  PC_LD          <= '0';     RF_WR          <= '1';       FLAG_C_LD      <= '1';     I_SET          <= '0';
  PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
  PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';
                             ALU_SEL        <= "0000";                               FLAG_LD_SEL    <= '0';
  SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';
  SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
  SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";       FLAG_Z_CLR     <= '0';    SCR_DATA_SEL <= '0';               
                                                                        
  IO_STRB        <= '0';     PC_RST            <= '0'; 
  
  
  					-- ADDC R-Imm -------------------
when "1010100" | "1010101" | "1010110" |"1010111" =>   

PC_LD          <= '0';     RF_WR          <= '1';       FLAG_C_LD      <= '1';     I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '1';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0001"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <=  "00";       FLAG_Z_CLR     <= '0';      SCR_DATA_SEL <= '0';                                                    
IO_STRB        <= '0';     PC_RST            <= '0'; 
  
  					-- ADDC R-R -------------------
when "0000101" =>   

PC_LD          <= '0';     RF_WR          <= '1';       FLAG_C_LD      <= '1';     I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';
           ALU_SEL        <= "0001";                               FLAG_LD_SEL    <= '0';
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <=  "00";       FLAG_Z_CLR     <= '0';      SCR_DATA_SEL <= '0';     
                                                      
IO_STRB        <= '0';     PC_RST            <= '0'; 


  					-- AND R-R -------------------
when "0000000" =>   

PC_LD          <= '0';     RF_WR          <= '1';       FLAG_C_LD      <= '0';     I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '1';     ALU_SEL        <= "0101"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <=  "00";       FLAG_Z_CLR     <= '0';     SCR_DATA_SEL <= '0';                                                
IO_STRB        <= '0';     PC_RST         <= '0'; 
  
  
  
    					-- AND R-Imm -------------------
when "1000000" | "1000001" | "1000010" |"1000011" =>   

PC_LD          <= '0';     RF_WR          <= '1';       FLAG_C_LD      <= '0';     I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '1';       FLAG_C_CLR     <= '1';     ALU_SEL        <= "0101"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';     SCR_DATA_SEL <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <=  "00";       FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 

		
    					-- ASR  -------------------
when "0100100" =>   

PC_LD          <= '0';     RF_WR          <= '1';       FLAG_C_LD      <= '1';     I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "1101"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';     SCR_DATA_SEL <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <=  "00";       FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 		



    					-- BRCC  -------------------
when "0010101" =>   

if (C_FLAG = '0') then
    PC_LD <= '1';
else
    PC_LD <= '0';
end if;

RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';     SCR_DATA_SEL <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <=  "00";       FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	



    					-- BRCS  -------------------
when "0010100" =>   

if (C_FLAG = '1') then
    PC_LD <= '1';
else
    PC_LD <= '0';
end if;

RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';     SCR_DATA_SEL <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <=  "00";       FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	



    					-- BREQ  -------------------
when "0010010" =>   

if (z_FLAG = '1') then
    PC_LD <= '1';
else
    PC_LD <= '0';
end if;

RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';     SCR_DATA_SEL <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <=  "00";       FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	


    					-- BRNE  -------------------
when "0010011" =>   

if (Z_FLAG = '0') then
    PC_LD <= '1';
else
    PC_LD <= '0';
end if;

RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';     SCR_DATA_SEL <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <=  "00";       FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	



    					-- CALL  -------------------
when "0010001" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET          <= '0';   PC_LD          <= '1';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '1';       FLAG_Z_SET     <= '0';
SP_DECR        <= '1';     SCR_ADDR_SEL   <= "11";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '1';


    					-- CLC  -------------------
when "0110000" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET          <= '0';    PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '1';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';



    					-- CMP r-r  -------------------
when "0001000" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '1';       I_SET          <= '0';   PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0100"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';


    					-- CMP r-imm  -------------------
when "1100000" | "1100001" | "1100010" | "1100011" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '1';       I_SET          <= '0';    PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '1';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0100"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';


    					-- IN  -------------------
when "1100100" | "1100101" | "1100110" | "1100111" =>   



RF_WR          <= '1';     FLAG_C_LD      <= '0';       I_SET          <= '0';   PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "11";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';


    					-- LD R-R  -------------------
when "0001010" =>   



RF_WR          <= '1';     FLAG_C_LD      <= '0';       I_SET          <= '0';    PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "01";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';




    					-- LD R-Imm  -------------------
when "1110000" | "1110001" | "1110010" | "1110011" =>   

RF_WR          <= '1';     FLAG_C_LD      <= '0';       I_SET          <= '0';     PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "01";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "01";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';

    					-- LSL  -------------------
when "0100000" =>   

RF_WR          <= '1';     FLAG_C_LD      <= '1';       I_SET          <= '0';     PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "1001"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';



    					-- LSR  -------------------
when "0100001" =>   



RF_WR          <= '1';     FLAG_C_LD      <= '1';       I_SET          <= '0';     PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "1010"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';



    					-- OR R-R  -------------------
when "0000001" =>   



RF_WR          <= '1';     FLAG_C_LD      <= '0';       I_SET          <= '0';    PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '1';     ALU_SEL        <= "0110"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';




    					-- OR R-Imm  -------------------
when "1000100" | "1000101" | "1000110" | "1000111" =>   



RF_WR          <= '1';     FLAG_C_LD      <= '0';       I_SET          <= '0';   PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '1';       FLAG_C_CLR     <= '1';     ALU_SEL        <= "0110"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';





    					-- POP  -------------------
when "0100110" =>   



RF_WR          <= '1';     FLAG_C_LD      <= '0';       I_SET          <= '0';    PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "01";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '1';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "10";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';



    					-- PUSH  -------------------
when "0100101" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET          <= '0';    PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '1';       FLAG_Z_SET     <= '0';
SP_DECR        <= '1';     SCR_ADDR_SEL   <= "11";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';




    					-- RET  -------------------
when "0110010" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET          <= '0';    PC_LD          <= '1';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "01";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '1';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "10";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';





    					-- ROL  -------------------
when "0100010" =>   



RF_WR          <= '1';     FLAG_C_LD      <= '1';       I_SET          <= '0';     PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "1011"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';




    					-- ROR  -------------------
when "0100011" =>   



RF_WR          <= '1';     FLAG_C_LD      <= '1';       I_SET          <= '0';    PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "1100"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';




    					-- SEC  -------------------
when "0110001" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET          <= '0';     PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '1';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';

					
					

    					-- ST R-R  -------------------
when "0001011" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET          <= '0';     PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '1';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';



    					-- ST R-Imm  -------------------
when "1110100" | "1110101" | "1110110" |"1110111" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET        <= '0';   PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '1';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "01";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0'; 	    SCR_DATA_SEL   <= '0';
			
			
					
    					-- SUB R-R  -------------------
when "0000110" =>   



RF_WR          <= '1';     FLAG_C_LD      <= '1';       I_SET          <= '0';     PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0010"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0';       SCR_DATA_SEL   <= '0';


    					-- SUB R-Imm  -------------------
when "1011000" | "1011001" | "1011010" | "1011011" =>   



RF_WR          <= '1';     FLAG_C_LD      <= '1';       I_SET          <= '0';   PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '1';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0010"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0';       SCR_DATA_SEL   <= '0';




    					-- SUBC R-R  -------------------
when "0000111" =>   



RF_WR          <= '1';     FLAG_C_LD      <= '1';       I_SET        <= '0';    PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0011"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0';       SCR_DATA_SEL   <= '0';





    					-- SUBC R-Imm  -------------------
when "1011100" | "1011101" | "1011110" | "1011111" =>   



RF_WR          <= '1';     FLAG_C_LD      <= '1';       I_SET          <= '0';   PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '1';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0011"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0';       SCR_DATA_SEL   <= '0';



    					-- TEST R-R  -------------------
when "0000011" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET        <= '0';    PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '1';     ALU_SEL        <= "1000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0';       SCR_DATA_SEL   <= '0';



    					-- TEST R-Imm  -------------------
when "1001100" | "1001101" | "1001110" | "1001111" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET          <= '0';   PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '1';       FLAG_C_CLR     <= '1';     ALU_SEL        <= "1000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0';       SCR_DATA_SEL   <= '0';


    					-- WSP  -------------------
when "0101000" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET          <= '0';    PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '1';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0';       SCR_DATA_SEL   <= '0';



					
					
-- BRN -------------------
when "0010000" =>   
             
PC_LD          <= '1';     RF_WR          <= '0';       FLAG_C_LD      <= '0';     I_SET         <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";       FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';
ALU_SEL        <= "0000";                               FLAG_LD_SEL    <= '0';
SP_LD          <= '0';   
FLAG_Z_LD      <= '0';     FLAG_SHAD_LD   <= '0';
SP_INCR        <= '0';     
SCR_WR         <= '0';       FLAG_Z_SET     <= '0';  SCR_DATA_SEL <= '0';
SP_DECR        <= '0';   
SCR_ADDR_SEL   <=  "00";      FLAG_Z_CLR     <= '0';                 
                                                                                     
IO_STRB        <= '0';     PC_RST            <= '0'; 

-- EXOR reg-reg  --------
when "0000010" =>					
PC_LD          <= '0';     RF_WR          <= '1';       FLAG_C_LD      <= '0';     I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";       FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '1';
ALU_SEL        <= "0111";                               FLAG_LD_SEL    <= '0';
SP_LD          <= '0';
FLAG_Z_LD      <= '1';     FLAG_SHAD_LD   <= '0';
SP_INCR        <= '0'; 
SCR_WR         <= '0';       FLAG_Z_SET     <= '0';  SCR_DATA_SEL <= '0';
SP_DECR        <= '0';
SCR_ADDR_SEL   <=  "00";      FLAG_Z_CLR     <= '0';                 
                                                                                     
IO_STRB        <= '0';     PC_RST            <= '0'; 
               
							   
-- EXOR reg-immed  ------
when "1001000" | "1001001" | "1001010" | "1001011" =>					

PC_LD          <= '0';     RF_WR          <= '1';       FLAG_C_LD      <= '0';     I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";       FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '1';       FLAG_C_CLR     <= '1';
ALU_SEL        <= "0111";                               FLAG_LD_SEL    <= '0';
SP_LD          <= '0'; 
FLAG_Z_LD      <= '1';     FLAG_SHAD_LD   <= '0';
SP_INCR        <= '0';  
SCR_WR         <= '0';       FLAG_Z_SET     <= '0';  SCR_DATA_SEL <= '0';
SP_DECR        <= '0';   
SCR_ADDR_SEL   <=  "00";      FLAG_Z_CLR     <= '0';                 
                                                                                     
IO_STRB        <= '0';     PC_RST            <= '0'; 

               


--MOV , Rd <- Rs
when "0001001" =>  
                

PC_LD          <= '0';     RF_WR          <= '1';       FLAG_C_LD      <= '0';     I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";       FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';
ALU_SEL        <= "1110";                               FLAG_LD_SEL    <= '0';
SP_LD          <= '0';   
FLAG_Z_LD      <= '0';     FLAG_SHAD_LD   <= '0';
SP_INCR        <= '0'; 
SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';
SCR_ADDR_SEL   <=  "00";      FLAG_Z_CLR     <= '0';       SCR_DATA_SEL <= '0';          
                                                                                     
IO_STRB        <= '0';     PC_RST            <= '0'; 

      

--MOV , Rd <- Immed
when "1101100" | "1101101" | "1101110" | "1101111" =>  
                

PC_LD          <= '0';     RF_WR          <= '1';       FLAG_C_LD      <= '0';     I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";       FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '1';       FLAG_C_CLR     <= '0';
ALU_SEL        <= "1110";                               FLAG_LD_SEL    <= '0';
SP_LD          <= '0';    
FLAG_Z_LD      <= '0';     FLAG_SHAD_LD   <= '0';
SP_INCR        <= '0'; 
SCR_WR         <= '0';       FLAG_Z_SET     <= '0';   SCR_DATA_SEL <= '0';
SP_DECR        <= '0'; 
SCR_ADDR_SEL   <=  "00";      FLAG_Z_CLR     <= '0';                 
                                                                                     
IO_STRB        <= '0';     PC_RST            <= '0'; 

    
--OUT
when "1101000" | "1101001" | "1101010" | "1101011" =>             

PC_LD          <= '0';     RF_WR          <= '0';       FLAG_C_LD      <= '0';     I_SET          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";       FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';
ALU_SEL        <= "0000";                               FLAG_LD_SEL    <= '0';
SP_LD          <= '0';    
FLAG_Z_LD      <= '0';     FLAG_SHAD_LD   <= '0';
SP_INCR        <= '0';  
SCR_WR         <= '0';       FLAG_Z_SET     <= '0';    SCR_DATA_SEL <= '0';
SP_DECR        <= '0';  
SCR_ADDR_SEL   <=  "00";      FLAG_Z_CLR     <= '0';                 
                                                                                     
IO_STRB        <= '1';     PC_RST            <= '0'; 

    					-- RETIE  -------------------
when "0110111" =>   

RF_WR          <= '0';     FLAG_C_LD      <= '1';       I_SET          <= '1';     PC_LD          <= '1';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "01";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '1';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '1';
SP_INCR        <= '1';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "10";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0';       SCR_DATA_SEL   <= '0';

    					-- RETID  -------------------
when "0110110" =>   

RF_WR          <= '0';     FLAG_C_LD      <= '1';       I_SET          <= '0';     PC_LD          <= '1';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '1';
PC_MUX_SEL     <= "01";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '1';     FLAG_Z_LD      <= '1';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '1';
SP_INCR        <= '1';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "10";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0';       SCR_DATA_SEL   <= '0';


    					-- SEI  -------------------
when "0110100" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET          <= '1';     PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '0';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0';       SCR_DATA_SEL   <= '0';


    					-- CLI  -------------------
when "0110101" =>   



RF_WR          <= '0';     FLAG_C_LD      <= '0';       I_SET        <= '0';     PC_LD          <= '0';
PC_INC         <= '0';     RF_WR_SEL      <= "00";      FLAG_C_SET     <= '0';     I_CLR          <= '1';
PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';     ALU_SEL        <= "0000"; 
SP_LD          <= '0';     FLAG_Z_LD      <= '0';       FLAG_SHAD_LD   <= '0';     FLAG_LD_SEL    <= '0';
SP_INCR        <= '0';     SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
SP_DECR        <= '0';     SCR_ADDR_SEL   <= "00";      FLAG_Z_CLR     <= '0';                                                          
IO_STRB        <= '0';     PC_RST         <= '0';       SCR_DATA_SEL   <= '0';


			   			   	   
              when others =>		
                  -- repeat the default block here to avoid incompletely specified outputs and hence avoid
                  -- the problem of inadvertently created latches within the synthesized system.						

				  PC_LD          <= '0';     RF_WR          <= '0';       FLAG_C_LD      <= '0';     I_SET        <= '0';
				  PC_INC         <= '0';     RF_WR_SEL      <= "00";       FLAG_C_SET     <= '0';     I_CLR          <= '0';
				  PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';
				                             ALU_SEL        <= "0000";                               FLAG_LD_SEL    <= '0';
				  SP_LD          <= '0';
			                                  FLAG_Z_LD      <= '0';     FLAG_SHAD_LD   <= '0';
				  SP_INCR        <= '0';  
			   SCR_WR         <= '0';       FLAG_Z_SET     <= '0';
				  SP_DECR        <= '0'; 
			    SCR_ADDR_SEL   <=  "00";      FLAG_Z_CLR     <= '0';                 
				                                                                        
				  IO_STRB        <= '0';     PC_RST            <= '0';      SCR_DATA_SEL <= '0';
				  
           end case;

          when others => 
			   NS <= ST_fet;
			    
            -- repeat the default block here to avoid incompletely specified outputs and hence avoid
            -- the problem of inadvertently created latches within the synthesized system.
			
            PC_LD          <= '0';     RF_WR          <= '0';       FLAG_C_LD      <= '0';     I_SET        <= '0';
            PC_INC         <= '0';     RF_WR_SEL      <= "00";       FLAG_C_SET     <= '0';     I_CLR          <= '0';
            PC_MUX_SEL     <= "00";    ALU_OPY_SEL    <= '0';       FLAG_C_CLR     <= '0';
                                       ALU_SEL        <= "0000";                               FLAG_LD_SEL    <= '0';
            SP_LD          <= '0';     
                                         FLAG_Z_LD      <= '0';     FLAG_SHAD_LD   <= '0';
            SP_INCR        <= '0';  
               SCR_WR         <= '0';       FLAG_Z_SET     <= '0';      SCR_DATA_SEL <= '0';
            SP_DECR        <= '0'; 
                SCR_ADDR_SEL   <=  "00";      FLAG_Z_CLR     <= '0';                 
                                                                                  
            IO_STRB        <= '0';     PC_RST            <= '0'; 
			
	    end case;
	     	     
   end process comb_p;
   
end Behavioral;


