----------------------------------------------------------------------------------
-- Company:  RAT Technologies (a subdivision of Cal Poly CENG)
-- Engineer:  Various RAT rats
--
-- Create Date:    02/03/2017
-- Module Name:    RAT_wrapper - Behavioral
-- Target Devices:  Basys3
-- Description: Wrapper for RAT CPU. This model provides a template to interfaces
--    the RAT CPU to the Basys3 development board.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAT_wrapper is
    Port ( an     : out   STD_LOGIC_VECTOR (3 downto 0);
           seg    : out   STD_LOGIC_VECTOR (7 downto 0);
           --SWITCHES : in    STD_LOGIC_VECTOR (7 downto 0);
           RESET    : in    STD_LOGIC;
           L_INT      : in    STD_LOGIC;
           R_INT    : in STD_LOGIC;
           SHOOT_INT: in STD_LOGIC;
           CLK      : in    STD_LOGIC;
           MISO : in std_logic;
           SW : in std_logic;
           SS : out std_logic;
           MOSI : out std_logic;
           SCLK : out std_logic;
           
           
           VGA_RGB  : out std_logic_vector(7 downto 0);
           VGA_HS   : out std_logic;
           VGA_VS   : out std_logic;
           signal_x : out std_logic_vector (3 downto 0);
           signal_y : out std_logic_vector (3 downto 0));
end RAT_wrapper;

architecture Behavioral of RAT_wrapper is

   -- INPUT PORT IDS -------------------------------------------------------------
   -- Right now, the only possible inputs are the switches
   -- In future labs you can add more port IDs, and you'll have
   -- to add constants here for the mux below
   --CONSTANT SWITCHES_ID : STD_LOGIC_VECTOR (7 downto 0) := X"20";
   -------------------------------------------------------------------------------
   
   -------------------------------------------------------------------------------
   -- OUTPUT PORT IDS ------------------------------------------------------------
   -- In future labs you can add more port IDs
   CONSTANT LEDS_ID       : STD_LOGIC_VECTOR (7 downto 0) := x"40";
   CONSTANT SSEG_CNTR_ID : STD_LOGIC_VECTOR (7 downto 0) := x"60";
   CONSTANT SSEG_VAL_ID:    STD_LOGIC_VECTOR (7 downto 0) := x"80";
   
   
   CONSTANT INTERRUPT_ID : STD_LOGIC_VECTOR (7 downto 0) := x"20";
   
   CONSTANT VGA_READ_ID : STD_LOGIC_VECTOR(7 downto 0) := x"93";
   CONSTANT VGA_HADDR_ID : STD_LOGIC_VECTOR(7 downto 0) := x"90";
   CONSTANT VGA_LADDR_ID : STD_LOGIC_VECTOR(7 downto 0) := x"91";
   CONSTANT VGA_WRITE_ID : STD_LOGIC_VECTOR(7 downto 0) := x"92";   
   -------------------------------------------------------------------------------

   -- Declare RAT_CPU ------------------------------------------------------------
   component RAT_CPU
       Port ( 
              IN_PORT  : in  STD_LOGIC_VECTOR (7 downto 0);
              OUT_PORT : out STD_LOGIC_VECTOR (7 downto 0);
              PORT_ID  : out STD_LOGIC_VECTOR (7 downto 0);
              IO_STRB  : out STD_LOGIC;
              RST    : in  STD_LOGIC;
              INT   : in  STD_LOGIC;
              CLK      : in  STD_LOGIC);
   end component RAT_CPU;
   
   
--component jstksteptop
-- Port(
--       clk : in std_logic;
--       rst : in std_logic;
--       --sw_en : in std_logic_vector (1 downto 0);
--       sw : in std_logic;
--       jstk_input_ss_0 : out std_logic;
--       jstk_input_miso_2 : in std_logic;
--       jstk_input_sclk_3 : out std_logic;
--       an : out std_logic_vector (3 downto 0);
--       seg : out std_logic_vector (7 downto 0);
--       LEDS : out std_logic_vector (2 downto 0);
--       signal_x : out std_logic_vector (3 downto 0);
--       signal_y : out std_logic_vector (3 downto 0));
-- end component;
   
   
   
   component clk_div 
       Port (       
                    CLK : in std_logic;
                   FCLK : out std_logic);
   end component;
   
   
   component vgaDriverBuffer is
      Port (
            CLK : in std_logic;
            we : in std_logic;
            wa   : in std_logic_vector (10 downto 0);
            wd   : in std_logic_vector (7 downto 0);
            Rout : out std_logic_vector(2 downto 0);
            Gout : out std_logic_vector(2 downto 0);
            Bout : out std_logic_vector(1 downto 0);
            HS   : out std_logic;
            VS   : out std_logic;
            pixelData : out std_logic_vector(7 downto 0));
   end component;
   
   
   component sseg_dec_uni
       Port (       
                    COUNT1 : in std_logic_vector(13 downto 0); 
                    COUNT2 : in std_logic_vector(7 downto 0);
                       SEL : in std_logic_vector(1 downto 0);
                     dp_oe : in std_logic;
                        dp : in std_logic_vector(1 downto 0);                       
                       CLK : in std_logic;
                      SIGN : in std_logic;
                     VALID : in std_logic;
                   DISP_EN : out std_logic_vector(3 downto 0);
                  SEGMENTS : out std_logic_vector(7 downto 0));
   end component sseg_dec_uni;
   
   
   
   component db_1shot_FSM is
       Port ( 
                A    : in STD_LOGIC;
              CLK  : in STD_LOGIC;
              A_DB : out STD_LOGIC);
   end component db_1shot_FSM;
   
   
   -------------------------------------------------------------------------------

   -- Signals for connecting RAT_CPU to RAT_wrapper -------------------------------
   signal s_input_port  : std_logic_vector (7 downto 0);
   signal s_output_port : std_logic_vector (7 downto 0);
   signal s_port_id     : std_logic_vector (7 downto 0) := x"20";
   signal s_load        : std_logic;
   signal s_sseg_cntr   : std_logic_vector (7 downto 0);
   signal s_sseg_val    : std_logic_vector (7 downto 0);
   signal s_cnt1_assign : std_logic_vector (13 downto 0);
   signal s_dbn_int     : std_logic;
   signal s_clk         : std_logic;
   signal s_interrupt   : std_logic; -- not yet used
   signal s_int_port    : std_logic_vector(7 downto 0):=x"00";
   signal s_reset       : std_logic;
   signal s_LEDS     :   STD_LOGIC_VECTOR (2 downto 0);
   
   signal s_ints : std_logic_vector(3 downto 0);
   
   signal s_r_int    : std_logic := '0';
   signal s_shoot_int : std_logic := '0';
   signal s_l_int    : std_logic := '0';
   signal s_right_int    : std_logic := '0';
   signal s_left_int    : std_logic := '0';
   signal s_left_int_2    : std_logic := '0';
   signal s_left_int_3    : std_logic := '0';
   signal s_posdata  :std_logic_vector (9 downto 0);
      signal r_vga_we   : std_logic;                       -- Write enable
   signal r_vga_wa   : std_logic_vector(10 downto 0);   -- The address to read from / write to  
   signal r_vga_wd   : std_logic_vector(7 downto 0);    -- The pixel data to write to the framebuffer
   signal r_vgaData  : std_logic_vector(7 downto 0);    -- The pixel data read from the framebuffer
   
   signal s_signal_x : std_logic_vector (3 downto 0);
   signal s_signal_y : std_logic_vector (3 downto 0);
   
   
   -- Register definitions for output devices ------------------------------------
   -- add signals for any added outputs
   signal r_LEDS        : std_logic_vector (7 downto 0);
   signal s_pushbutton_shoot : std_logic_vector (2 downto 0);
   -------------------------------------------------------------------------------

begin


   -- Instantiate RAT_CPU --------------------------------------------------------
   CPU: RAT_CPU
   port map(  IN_PORT  => s_input_port,
              OUT_PORT => s_output_port,
              PORT_ID  => s_port_id,
              RST    => s_reset,
              IO_STRB  => s_load,
              INT   => s_interrupt,
              CLK      => s_CLK);
              
     
    s_cnt1_assign <= "000000" & s_SSEG_val;
    
    my_sseg_dec_uni : sseg_dec_uni
    port map (       COUNT1 => s_cnt1_assign,
                     COUNT2 => s_sseg_val,
                     SEL => s_SSEG_cntr (7 downto 6),
                     dp_oe => s_sseg_cntr(2),
                     dp => s_sseg_cntr (5 downto 4),                       
                     CLK => CLK,
                     SIGN => s_sseg_cntr(1),
                     VALID => s_sseg_cntr(0),
                     DISP_EN => an,
                     SEGMENTS => seg);
              
        my_clk_div : clk_div 
             port map (CLK => CLK,
                       FCLK => s_clk
                       );
          
   VGA: vgaDriverBuffer
   port map(CLK => CLK,
            WE => r_vga_we,
            WA => r_vga_wa,
            WD => r_vga_wd,
            Rout => VGA_RGB(7 downto 5),
            Gout => VGA_RGB(4 downto 2),
            Bout => VGA_RGB(1 downto 0),
            HS => VGA_HS,
            VS => VGA_VS,
            pixelData => r_vgaData);     

              
--    my_db_1shot_FSM : db_1shot_FSM 
--        port map ( A    => L_INT,
--                   CLK  => s_clk,
--                   A_DB => s_dbn_int);
                   
                   
--   my_PmodJSTK_Demo : PmodJSTK_Demo
--                   port map(
--                       CLK => CLK,
--                       RST => RESET,
--                       MISO => MISO,
--                       SW => SW,
--                       SS => SS,
--                       MOSI => MOSI,
--                       SCLK => SCLK,
--                       LED => s_LEDS,
--                        AN => an,
--                        SEG => seg);
                        
                        
--  my_jstksteptop : jstksteptop
--                         port map(
--                               clk => CLK,
--                               rst => RESET,
--                               --sw_en =>,
--                               sw => SW,
--                               jstk_input_ss_0 => SS,
--                               jstk_input_miso_2 => MISO,
--                               jstk_input_sclk_3 => SCLK,
--                               --an => an,
--                               --seg => seg,
--                               LEDS => s_pushbutton_shoot,
--                               signal_x => s_signal_x,
--                               signal_y => s_signal_y);

--s_left_int <= s_signal_x(0);
--s_right_int <= s_signal_y(0);                  
                                
                      
    my_db_reset : db_1shot_FSM 
                                port map ( A    => RESET,
                                           CLK  => s_clk,
                                           A_DB => s_reset );

    my_db_L_INT : db_1shot_FSM 
                                port map ( A    => l_int,
                                           CLK  => s_clk,
                                           A_DB => s_l_int);
                                           
                                           
    my_db_R_INT : db_1shot_FSM 
                               port map ( A    => r_int,
                                          CLK  => s_clk,
                                          A_DB => s_r_int);
    my_db_shoot : db_1shot_FSM 
                              port map ( A    => shoot_int,
                                         CLK  => s_clk,
                                         A_DB => s_shoot_int);

    s_interrupt <= s_shoot_int or s_r_int or s_l_int;
--    s_interrupt <= shoot_int or r_int or l_int;

--s_int_port (7 downto 3) <= "00000";
--s_int_port(2) <= l_int;
--s_int_port(1) <= shoot_int;
--s_int_port(0) <= r_int;



--    process(s_ints)
--    begin
--        case s_ints is
--        when "100" =>  s_int_port <= x"02";
--        when "001" =>  s_int_port <= x"01";
--        when "010" => s_int_port <= x"03";
--        when others => s_int_port <= s_int_port; 
--        end case;
--    end process;

--process (l_int, shoot_int, r_int)
--begin
--    if (r_int = '1') then
--        s_int_port <= x"01";
--    elsif (shoot_int = '1') then
--        s_int_port <= x"02";
--    elsif (l_int = '1') then
--        s_int_port <= x"04";
--    else
--        s_int_port <= s_int_port;
--    end if;
    
-- end process;

--process (l_int, shoot_int, r_int)
--begin
--    if (r_int = '1') then
--        s_int_port <= x"01";
--    else
--        if (l_int = '1') then
--            s_int_port <= x"02";
--        else
--            if (shoot_int = '1') then
--                s_int_port <= x"05";
--            else
--            s_int_port <= s_int_port;
--            end if;
--        end if;
--    end if;
--end process;

process (s_shoot_int, s_l_int, s_r_int)
begin
            if (s_r_int = '1') then
                s_int_port <= x"01";
            elsif (s_shoot_int = '1') then
                s_int_port <= x"02";
            elsif (rising_edge(s_l_int)) then
                s_int_port <= x"04";
            end if;
            
end process;


   -------------------------------------------------------------------------------
   -- MUX for selecting what input to read ---------------------------------------
   -- add conditions and connections for any added PORT IDs
   -------------------------------------------------------------------------------
   inputs: process(s_port_id, s_int_port)
   begin
      if (s_port_id  = INTERRUPT_ID) then
            
          s_input_port <= s_int_port;
                          
      else
        s_input_port <= x"00";
      end if;
   end process inputs;
--   -------------------------------------------------------------------------------


   -------------------------------------------------------------------------------
   -- MUX for updating output registers ------------------------------------------
   -- Register updates depend on rising clock edge and asserted load signal
   -- add conditions and connections for any added PORT IDs
   -------------------------------------------------------------------------------
   outputs: process(CLK, RESET)
   begin
      if(RESET = '1') then
        s_sseg_val <= x"00";
      end if;
      if (rising_edge(CLK)) then

         if( s_port_id = VGA_WRITE_ID and s_load = '1') then
                   r_vga_we <= '1';
                else
                   r_vga_we <= '0';
                end if;
         if (s_load = '1') then
          
             --the register definition for the LEDS
            if (s_port_id = LEDS_ID) then
               r_LEDS <= s_output_port;
            elsif(s_port_id = SSEG_CNTR_ID) then
                s_sseg_CNTR <= s_output_port;
            elsif(s_port_id = SSEG_VAL_ID) then
                s_sseg_VAL <= s_output_port;
            elsif (s_port_id = VGA_HADDR_ID) then
                   r_vga_wa(10 downto 6) <= s_output_port(4 downto 0);
            elsif (s_port_id = VGA_LADDR_ID) then
                   r_vga_wa(5 downto 0) <= s_output_port(5 downto 0);
            elsif (s_port_id = VGA_WRITE_ID) then
                   r_vga_wd <= s_output_port;
            end if;                  
           end if;
       end if;
        end process outputs;
   -------------------------------------------------------------------------------

   -- Register Interface Assignments ---------------------------------------------
   -- add all outputs that you added to this design
--   LEDS <= r_LEDS;

 end Behavioral;