library IEEE;use 
IEEE.STD_LOGIC_1164.ALL;

entity program_counter is
  Port (
        FROM_STACK  :   in std_logic_vector (9 downto 0);
        FROM_IMMED  :   in std_logic_vector (9 downto 0);
        x3FF        :   in std_logic_vector (9 downto 0);
        MUX_SEL     :   in std_logic_vector (1 downto 0);
        PC_LD       :   in std_logic;
        PC_INC      :   in std_logic;
        RST         :   in std_logic;
        CLK         :   in std_logic;
        PC_COUNT    :   out std_logic_vector (9 downto 0) 
        );
        
end program_counter;

architecture Structural of program_counter is
    component pc
    port(
        Din_PC      : in std_logic_vector (9 downto 0);
        PC_LD_PC    : in std_logic;
        PC_INC_PC   : in std_logic;
        RST_PC      : in std_logic;
        CLK_PC      : in std_logic;
        PC_COUNT_PC : out std_logic_vector (9 downto 0));
    end component;

    component mux
    port( 
        FROM_IMMED_MUX : in  std_logic_vector(9 downto 0);
        FROM_STACK_MUX : in  std_logic_vector(9 downto 0);
        x3FF_MUX       : in  std_logic_vector(9 downto 0);
        MUX_SEL_MUX    : in  std_logic_vector(1 downto 0);
        OUTPUT_MUX     : out std_logic_vector(9 downto 0));
    end component;

--The signal that sends the mux output to the pc
signal data_in_sig : std_logic_vector (9 downto 0);

begin

R1: mux port map ( 
                 FROM_IMMED_MUX => FROM_IMMED,
                 FROM_STACK_MUX => FROM_STACK,
                 x3FF_MUX       => x3FF,
                 MUX_SEL_MUX    => MUX_SEL,
                 OUTPUT_MUX     => data_in_sig
                 );

R2: pc port map (
                 Din_PC      => data_in_sig,
                 PC_LD_PC    => PC_LD,
                 PC_INC_PC   => PC_INC,
                 RST_PC      => RST,
                 CLK_PC      => CLK,
                 PC_COUNT_PC => PC_COUNT
                );

end Structural;
