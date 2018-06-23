


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity EXP8_wrapper_tb is
--  Port ( );
end EXP8_wrapper_tb;

architecture Behavioral of EXP8_wrapper_tb is

   component RAT_Wrapper
       Port ( --LEDS     : out   STD_LOGIC_VECTOR (2 downto 0);
              an     : out   STD_LOGIC_VECTOR (3 downto 0);
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
    end component;

   signal an_tb : std_logic_vector(3 downto 0) :="0000";
   signal leds_tb     : std_logic_vector(7 downto 0) :="00000000";
   signal clk_tb : std_logic :=  '0';
   signal rst_tb : std_logic :=  '0';
   signal l_int_tb: std_logic := '0';
   signal r_int_tb: std_logic := '0';
   signal shoot_int_tb: std_logic := '0';
   signal seg_tb    :   STD_LOGIC_VECTOR (7 downto 0);
   signal MISO_tb :  std_logic:= '0';
   signal SW_tb : std_logic:= '0';
   signal SS_tb :  std_logic:= '0';
   signal MOSI_tb : std_logic:= '0';
   signal SCLK_tb : std_logic:= '0';
              
   signal VGA_RGB_tb  :  std_logic_vector(7 downto 0);
   signal VGA_HS_tb   :  std_logic;
   signal VGA_VS_tb   :  std_logic;
   signal signal_x_tb :  std_logic_vector (3 downto 0);
   signal signal_y_tb :  std_logic_vector (3 downto 0);
   
   
   
  -- Clock period definitions
  constant CLK_period : time := 10 ns;
  
begin

   uut: RAT_Wrapper PORT MAP (
      seg     => leds_tb,
      an      =>    an_tb,
      RESET      => rst_tb,
      CLK      => clk_tb,
      L_INT      => l_int_tb,
      R_INT   => r_int_tb,
      SHOOT_INT => shoot_int_tb,
      MISO => miso_tb,
      SW => sw_tb,
      SS => ss_tb,
      MOSI => mosi_tb,
      SCLK => sclk_tb,
      VGA_RGB => VGA_RGB_TB,
      VGA_HS  => vga_hs_tb, 
      VGA_VS  => vga_vs_tb,
      signal_x => signal_x_tb,
      signal_y => signal_y_tb
   );

   -- Clock process definitions
   CLK_process :process
   begin
        CLK_tb <= '0';
        wait for CLK_period/2;
        CLK_tb <= '1';
        wait for CLK_period/2;
   end process;
   
      -- Stimulus process
   stim_proc: process
   begin       
      rst_tb <= '0';     
      wait for 1000ns;
      shoot_int_tb <= '1';
      wait for 510us;
      shoot_int_tb <= '0';
      wait for 510us;
      r_int_tb <= '1';
      wait for 510us;
      r_int_tb <= '0';
      wait for 510us;
      l_int_tb <='1';
      wait for 510us;
      l_int_tb <= '0';
      wait for 510us;
      
--      rst_tb <= '1';
--      wait for 50ns;
--      rst_tb <= '0';
--      wait for 2000ns;
   end process;

end Behavioral;