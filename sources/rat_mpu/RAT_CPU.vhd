library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RAT_CPU is
    Port ( IN_PORT : in  STD_LOGIC_VECTOR (7 downto 0);
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           INT : in  STD_LOGIC;
           IO_STRB : out  STD_LOGIC;
           OUT_PORT : out  STD_LOGIC_VECTOR (7 downto 0);
           PORT_ID : out  STD_LOGIC_VECTOR (7 downto 0));
end RAT_CPU;

architecture Behavioral of RAT_CPU is

    component Stack_Pointer is
      port (RST : in std_logic;
        LD : in std_logic;
        INCR : in std_logic;
        DECR : in std_logic;
        CLK :in std_logic;
        DATA : in std_logic_vector (7 downto 0);
        SP_OUT : out std_logic_vector (7 downto 0));
    end component;

   component prog_rom  
      port ( ADDRESS : in std_logic_vector(9 downto 0); 
             INSTRUCTION : out std_logic_vector(17 downto 0); 
             CLK : in std_logic);  
   end component;

   component ALU
       Port ( A : in  STD_LOGIC_VECTOR (7 downto 0);
              B : in  STD_LOGIC_VECTOR (7 downto 0);
              Cin : in  STD_LOGIC;
              SEL : in  STD_LOGIC_VECTOR(3 downto 0);
              C : out  STD_LOGIC;
              Z : out  STD_LOGIC;
              Result : out  STD_LOGIC_VECTOR (7 downto 0));
   end component;

    component ScratchRAM
    Port ( DATA_IN  : in     STD_LOGIC_VECTOR (9 downto 0);
           ADR      : in     STD_LOGIC_VECTOR (7 downto 0);
           WE       : in     STD_LOGIC;
           CLK      : in     STD_LOGIC;
           DATA_OUT : out    STD_LOGIC_VECTOR (9 downto 0));
    end component;    
    
    component SCR_DATA_MUX is
      Port (DX : in std_logic_vector(7 downto 0);
            PC_COUNT : in std_logic_vector(9 downto 0);
            SCR_DATA_SEL : in std_logic;
            DATA_IN : out std_logic_vector (9 downto 0));
    end component;

   component CONTROL_UNIT
       Port ( CLK           : in   STD_LOGIC;
              C_FLAG        : in   STD_LOGIC;
              Z_FLAG        : in   STD_LOGIC;
              INT           : in   STD_LOGIC;
              RESET         : in   STD_LOGIC;
              OPCODE_HI_5   : in   STD_LOGIC_VECTOR (4 downto 0);
              OPCODE_LO_2   : in   STD_LOGIC_VECTOR (1 downto 0);
                 
              PC_RST         : out  STD_LOGIC;
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
   end component;
   
   component reg_mux 
     Port (    RF_WR_SEL : in std_logic_vector(1 downto 0);
               IN_PORT   : in std_logic_vector(7 downto 0);
               SP_DATA   : in std_logic_vector(7 downto 0);
               ALU_RESULT: in std_logic_vector(7 downto 0);
               SCR_DATA  : in std_logic_vector (7 downto 0);
               DIN       : out std_logic_vector (7 downto 0));
   end component;
   
   component SCR_MUX 
     Port (SY : in std_logic_vector(7 downto 0);
           IR : in std_logic_vector(7 downto 0);
           SP_OUT : in std_logic_vector (7 downto 0);
           SCR_ADDR_SEL : in std_logic_vector (1 downto 0);
           SCR_Output : out std_logic_vector (7 downto 0));
   end component;
   
   component ALU_MUX
     Port (SY : in std_logic_vector(7 downto 0);
           IR : in std_logic_vector(7 downto 0);
           REG_IMMED_SEL : in std_logic;
           Mux_Output : out std_logic_vector (7 downto 0));
   end component;

   component RegisterFile 
       Port ( D_IN   : in     STD_LOGIC_VECTOR (7 downto 0);
              DX_OUT : out  STD_LOGIC_VECTOR (7 downto 0);
              DY_OUT : out    STD_LOGIC_VECTOR (7 downto 0);
              ADRX   : in     STD_LOGIC_VECTOR (4 downto 0);
              ADRY   : in     STD_LOGIC_VECTOR (4 downto 0);
              WE     : in     STD_LOGIC;
              CLK    : in     STD_LOGIC);
   end component;
      
component int_input
     Port (INT_in : in std_logic;
           I_set : in std_logic;
           I_clr : in std_logic;
           clk : in std_logic;
           INT_out : out std_logic);
   end component;   
   
   component program_counter 
     Port (
           FROM_STACK  :   in std_logic_vector (9 downto 0);
           FROM_IMMED  :   in std_logic_vector (9 downto 0);
           x3FF        :   in std_logic_vector (9 downto 0);
           MUX_SEL     :   in std_logic_vector (1 downto 0);
           PC_LD       :   in std_logic;
           PC_INC      :   in std_logic;
           RST         :   in std_logic;
           CLK         :   in std_logic;
           PC_COUNT    :   out std_logic_vector (9 downto 0));           
   end component;
   
   component FlagReg_Z 
       Port ( IN_FLAG  : in  STD_LOGIC; --flag input
              LD       : in  STD_LOGIC; --load the out_flag with the in_flag value
              CLK      : in  STD_LOGIC; --system clock
              OUT_FLAG : out  STD_LOGIC); --flag output
   end component;
   
   component FlagReg_C
       Port ( IN_FLAG  : in  STD_LOGIC; --flag input
              LD       : in  STD_LOGIC; --load the out_flag with the in_flag value
              SET      : in  STD_LOGIC; --set the flag to '1'
              CLR      : in  STD_LOGIC; --clear the flag to '0'
              CLK      : in  STD_LOGIC; --system clock
              OUT_FLAG : out  STD_LOGIC); --flag output
   end component;
   
   component flag_mux is
     Port (Data_In  : in std_logic;
           Flag_Sel : in std_logic;
           Shad_Out : in std_logic;
           Data_Out : out std_logic );
   end component;
   
   component Shad_FlagReg_Z is
       Port ( IN_FLAG  : in  STD_LOGIC; --flag input
              LD       : in  STD_LOGIC; --load the out_flag with the in_flag value
              CLK      : in  STD_LOGIC; --system clock
              OUT_FLAG : out  STD_LOGIC); --flag output
   end component;
   
   component Shad_FlagReg_C is
       Port ( IN_FLAG  : in  STD_LOGIC; --flag input
              LD       : in  STD_LOGIC; --load the out_flag with the in_flag value
              CLK      : in  STD_LOGIC; --system clock
              OUT_FLAG : out  STD_LOGIC); --flag output
   end component;

   -- intermediate signals ----------------------------------
   signal s_pc_ld : std_logic := '0'; 
   signal s_pc_inc : std_logic := '0'; 
   signal s_rst : std_logic := '0'; 
   signal s_pc_mux_sel : std_logic_vector(1 downto 0) := "00"; 
   signal s_pc_count : std_logic_vector(9 downto 0) := (others => '0');   
   signal s_inst_reg : std_logic_vector(17 downto 0) := (others => '0');   
   signal s_clk : std_logic;
   
   signal s_rf_wr : std_logic;
   signal s_rf_wr_sel : std_logic_vector (1 downto 0);
   
   signal s_alu_sel : std_logic_vector (3 downto 0);
   signal s_alu_opy_sel : std_logic := '0';

   signal s_flg_ld_sel : std_logic;
   signal s_flg_shad_ld: std_logic;
   signal s_flg_shad_c_out: std_logic;
   signal s_flg_shad_z_out: std_logic;
   signal s_flg_c_set : std_logic;
   signal s_flg_c_clr : std_logic;
   signal s_flg_c_ld : std_logic;
   signal s_flg_z_ld : std_logic;
   
   signal s_scr_data_sel : std_logic := '0';
   signal s_scr_addr_sel : std_logic_vector (1 downto 0);
   signal s_scr_we : std_logic;
   
   signal s_rf_din : std_logic_vector (7 downto 0) := x"00";
   signal s_dx_out : std_logic_vector (7 downto 0);
   signal s_dy_out : std_logic_vector (7 downto 0);
   signal s_alu_b : std_logic_vector (7 downto 0);
   signal s_scr_din : std_logic_vector (9 downto 0);
   signal s_scr_addr : std_logic_vector (7 downto 0);
   signal s_scr_dout : std_logic_vector (9 downto 0);
   signal s_alu_c : std_logic;
   signal s_alu_z : std_logic;
   signal s_alu_result : std_logic_vector (7 downto 0);
   signal s_alu_mux_out : std_logic_vector (7 downto 0);
   signal s_c_flag : std_logic;
   signal s_z_flag : std_logic;
   signal s_c_mux_out: std_logic;
   signal s_z_mux_out: std_logic;
       
   signal s_dx_mux_in : std_logic_vector (7 downto 0);
   
   signal s_from_immed : std_logic_vector (9 downto 0) := "1111111111";
   
   signal s_IO_STRB : std_logic;
   
   signal s_I_FLAG_SET : std_logic;
   signal s_I_FLAG_CLR : std_logic;
    
   signal s_INT_out : std_logic;
   
   signal s_sp_ld : std_logic;
   signal s_sp_incr : std_logic;
   signal s_sp_decr : std_logic;
   signal s_sp_data_out : std_logic_vector (7 downto 0);
   
   -- helpful aliases ------------------------------------------------------------------
   alias s_ir_12_3 : std_logic_vector(9 downto 0) is s_inst_reg(12 downto 3); 
   alias s_ir_7_0 : std_logic_vector(7 downto 0) is s_inst_reg(7 downto 0);
   alias s_ir_7_3 : std_logic_vector(4 downto 0) is s_inst_reg(7 downto 3);
   alias s_ir_12_8 : std_logic_vector(4 downto 0) is s_inst_reg(12 downto 8);
   alias s_ir_1_0 : std_logic_vector(1 downto 0) is s_inst_reg(1 downto 0);
   alias s_ir_17_13 : std_logic_vector(4 downto 0) is s_inst_reg(17 downto 13);   
   
   alias s_rf_mux_scr : std_logic_vector (7 downto 0) is s_scr_dout (7 downto 0);

begin

my_prog_rom: prog_rom  
   port map( ADDRESS => s_pc_count, 
             INSTRUCTION => s_inst_reg, 
             CLK => CLK); 

my_alu: ALU
   port map ( A => s_dx_out,       
              B => s_alu_mux_out,       
              Cin => s_c_flag,     
              SEL => s_alu_sel,     
              C => s_alu_c,       
              Z => s_alu_z,       
              RESULT => s_alu_result); 
              
my_ALU_MUX: ALU_MUX
     port map (SY            => s_dy_out ,
               IR            =>  s_ir_7_0 ,
               REG_IMMED_SEL =>  s_alu_opy_sel,
               Mux_Output    =>  s_alu_mux_out);

my_SCR_MUX: SCR_MUX 
     port map (SY           => s_dy_out ,
               IR           => s_ir_7_0 ,
               SP_OUT       => s_sp_data_out,
               SCR_ADDR_SEL => s_scr_addr_sel,
               SCR_Output   => s_scr_addr);

my_reg_mux: reg_mux 
     port map (RF_WR_SEL  => s_rf_wr_sel ,
               IN_PORT    => IN_PORT,
               SP_DATA    => s_sp_data_out,
               ALU_RESULT => s_alu_result,
               SCR_DATA   => s_rf_mux_scr,
               DIN        => s_rf_din);

my_cu: CONTROL_UNIT 
   port map ( CLK           => CLK, 
              C_flag             => s_c_flag, 
              Z_flag             => s_z_flag, 
              INT           => s_INT_out, 
              RESET           => RST, 
              OPCODE_HI_5   => s_ir_17_13, 
              OPCODE_LO_2   => s_ir_1_0, 
              
              PC_LD         => s_pc_ld, 
              PC_INC        => s_pc_inc, 
              PC_RST      => s_rst, 
              PC_MUX_SEL    => s_pc_mux_sel, 
              
              SP_LD         => s_sp_ld, 
              SP_INCR => s_sp_incr,
              SP_DECR => s_sp_decr,
              
              RF_WR         => s_rf_wr, 
              RF_WR_SEL     => s_rf_wr_sel, 

              ALU_SEL       => s_alu_Sel, 
              alu_opy_sel   => s_alu_opy_sel,
              SCR_WR        => s_scr_We,  
              SCR_ADDR_SEL  => s_scr_addr_sel, 
              SCR_DATA_SEL  => s_scr_data_sel,

              FLAG_LD_SEL    => s_flg_ld_sel, 
              FLAG_C_LD     => s_flg_c_ld, 
              FLAG_C_SET    => s_flg_c_set, 
              FLAG_C_CLR    => s_flg_c_clr, 
              FLAG_SHAD_LD  => s_flg_shad_ld, 
              FLAG_Z_LD     => s_flg_z_ld,
              IO_STRB => IO_STRB,
 
              I_SET    => s_I_FLAG_SET, 
              I_CLR    => s_I_FLAG_CLR);              

my_ScratchRAM: ScratchRAM
    port map ( DATA_IN  => s_scr_din,
           ADR      => s_scr_addr,
           WE       => s_scr_we,
           CLK      => clk,
           DATA_OUT => s_scr_dout);

my_regfile: RegisterFile 
   port map ( D_IN   => s_rf_din,   
              DX_OUT => s_dx_out,   
              DY_OUT => s_dy_out,   
              ADRX   => s_ir_12_8,   
              ADRY   => s_ir_7_3,   
              WE     => s_rf_wr,   
              CLK    => clk); 


my_PC: program_counter 
   port map (
           FROM_STACK  => s_scr_dout,
           FROM_IMMED  => s_ir_12_3,
           x3FF        =>  s_from_immed,
           MUX_SEL     => s_pc_mux_sel,
           PC_LD       => s_pc_ld,
           PC_INC      => s_pc_inc,
           RST         => s_rst,
           CLK         => clk,
           PC_COUNT    => s_pc_count);

my_SCR_DATA_MUX: SCR_DATA_MUX 
    port map (
            DX   => s_dx_out,
            PC_COUNT   => s_pc_count,
            SCR_DATA_SEL   => s_scr_data_sel,
            DATA_IN   => s_scr_din);
   
   
my_FlagReg_Z: FlagReg_Z
   port map ( IN_FLAG   => s_z_mux_out, --flag input
              LD        => s_flg_z_ld, --load the out_flag with the in_flag value
              CLK       => clk, --system clock
              OUT_FLAG  => s_z_flag); --flag output
       

my_int_input: int_input
     Port map(INT_in => INT,
           I_set => s_i_flag_set,
           I_clr => s_i_flag_clr,
           clk => clk,
           INT_out => s_int_out);
  
my_FlagReg_C: FlagReg_C
    Port map( IN_FLAG   => s_c_mux_out, --flag input
           LD        => s_flg_c_ld, --load the out_flag with the in_flag value
           SET       => s_flg_c_set, --set the flag to '1'
           CLR       => s_flg_c_Clr, --clear the flag to '0'
           CLK       => clk, --system clock
           OUT_FLAG  => s_c_flag); --flag output
           
           
my_Stack_Pointer: Stack_Pointer
    port map (RST => s_rst, 
               LD => s_sp_ld,
               INCR => s_sp_incr,
               DECR  => s_sp_decr,
               CLK  => CLK,
               DATA  => s_dx_out,
               SP_OUT  => s_sp_data_out);
               
my_c_flag_mux:  flag_mux 
    port map (Data_In => s_alu_c,
              Flag_Sel => s_flg_ld_sel,
              Shad_Out => s_flg_shad_c_out,
              Data_Out => s_c_mux_out);

my_z_flag_mux:  flag_mux 
    port map (Data_In => s_alu_z,
              Flag_Sel => s_flg_ld_sel,
              Shad_Out => s_flg_shad_z_out,
              Data_Out => s_z_mux_out);
               
my_shad_flag_reg_z: Shad_FlagReg_Z 
    Port map ( IN_FLAG  => s_z_flag,
               LD       => s_flg_shad_ld,
               CLK      => clk,
               OUT_FLAG => s_flg_shad_z_out);
 
               
my_shad_flag_reg_c: Shad_FlagReg_C 
    Port map ( IN_FLAG  => s_c_flag,
               LD       => s_flg_shad_ld,       
               CLK      => clk,
               OUT_FLAG => s_flg_shad_c_out); --flag output
    
out_port <= s_dx_out;
port_id <= s_ir_7_0;

end Behavioral;
