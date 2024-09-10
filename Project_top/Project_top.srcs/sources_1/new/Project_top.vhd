library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Project_top is 
    port (
        clk: in std_logic;
        reset: in std_logic;
        dif_sel: in std_logic;
        btns: in std_logic_vector(3 downto 0);
        R: out std_logic_vector(3 downto 0);
        G: out std_logic_vector(3 downto 0);
        B: out std_logic_vector(3 downto 0);
        Hs: out std_logic;
        Vs: out std_logic;
        sseg_led: out std_logic_vector(6 downto 0);
        sseg_en: out std_logic_vector(3 downto 0)
    );
end entity;

architecture structural of Project_top is
    
    component controller is 
     Generic ( DEBNC_CLOCKS : INTEGER range 2 to (INTEGER'high) := 2**16;
              PORT_WIDTH : INTEGER range 1 to (INTEGER'high) := 4);
    Port (  SIGNAL_I : in  STD_LOGIC_VECTOR ((PORT_WIDTH - 1) downto 0);
           CLK_I : in  STD_LOGIC;
           SIGNAL_O : out  STD_LOGIC_VECTOR ((PORT_WIDTH - 1) downto 0)
    );
    end component;
    
    component vga_ctrl is 
        port(
        CLK_I        : IN STD_LOGIC;
		DIF_SEL      : IN STD_LOGIC;
		VGA_HS_O     : OUT STD_LOGIC;
		VGA_VS_O     : OUT STD_LOGIC;
		VGA_RED_O    : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		VGA_BLUE_O   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		VGA_GREEN_O  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		CORRECT_DATA : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		CHECK_READY  : OUT STD_LOGIC;
		-- for the clocking wizard inputs
		reset        : IN STD_LOGIC;
		locked       : OUT STD_LOGIC
        );
    end component;
    
    component sseg4digit is 
        port(
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           debounced: in std_logic_vector(3 downto 0);
           correct: in std_logic_vector(3 downto 0);
           check_ready: in std_logic;
           sseg_led : out STD_LOGIC_VECTOR (6 downto 0);
           sseg_en : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    signal correct_data_reg, debounced_outs: std_logic_vector(3 downto 0);
    signal check_ready_reg, point_output_reg: std_logic;

begin

control: controller port map(
    SIGNAL_I=>btns, SIGNAL_O=>debounced_outs, CLK_I=>clk
);

vga: vga_ctrl port map(
    CLK_I=>clk, 
    DIF_SEL=>dif_sel, 
    VGA_HS_O=>Hs, 
    VGA_VS_O=>Vs, 
    VGA_RED_O=>R, 
    VGA_GREEN_O=>G, 
    VGA_BLUE_O=>B, 
    reset=>reset,
    CORRECT_DATA=>correct_data_reg,
    CHECK_READY=>check_ready_reg
    );
 
 sseg: sseg4digit port map(
    clk=>clk,
    reset=>reset,
    debounced=>debounced_outs,
    correct=>correct_data_reg,
    check_ready=>check_ready_reg,
    sseg_led=>sseg_led,
    sseg_en=>sseg_en
 );
 
end structural;