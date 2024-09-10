library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA_top is
--  Port ( );
    port(
        CLK_IN, reset: in std_logic;
        Hsync, Vsync : out std_logic;
        R,G,B: OUT std_logic_vector(3 downto 0)
    );
end VGA_top;

architecture structural of VGA_top is
    
    component vga_ctrl_test is port(
        CLK_I : in STD_LOGIC;
        VGA_HS_O : out STD_LOGIC;
        VGA_VS_O : out STD_LOGIC;
        active: BUFFER STD_LOGIC;
        pixel_clk: BUFFER STD_LOGIC;
           -- for the clocking wizard inputs
        reset: in STD_LOGIC;
        locked: out STD_LOGIC;
        hcntr: BUFFER STD_LOGIC_VECTOR(11 DOWNTO 0);
        vcntr: BUFFER STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    end component;
    
    component image_gen is port(
        Hsync : in STD_LOGIC;
        Vsync : in STD_LOGIC;
        active : in STD_LOGIC;
        pixel_clk : in STD_LOGIC;
        Hactive : in STD_LOGIC;
        Vactive : in STD_LOGIC;
        hcntr: buffer std_logic_vector(11 downto 0);
        vcntr: buffer std_logic_vector(11 downto 0);
        R : out STD_LOGIC_VECTOR (3 downto 0);
        G : out STD_LOGIC_VECTOR (3 downto 0);
        B : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;
    signal Hsync_reg, Vsync_reg, Hactive_reg, Vactive_reg,pixel_clk_reg, active_reg: std_logic;
    signal hcntr_reg, vcntr_reg: std_logic_vector(11 downto 0);
begin
    controller: vga_ctrl_test port map(
        CLK_I=>CLK_IN,
        VGA_HS_O=>Hsync_reg,
        VGA_VS_O=>Vsync_reg,
        active=>active_reg,
        pixel_clk=>pixel_clk_reg,
        reset=>reset,
        hcntr=>hcntr_reg,
        vcntr=>vcntr_reg       
        );
    image_generator: image_gen port map(
        Hsync=>Hsync_reg,
        Vsync=>Vsync_reg,
        active=>active_reg,
        pixel_clk=>pixel_clk_reg,
        hcntr=>hcntr_reg,
        vcntr=>vcntr_reg,
        Hactive=>Hactive_reg,
        Vactive=>Vactive_reg,
        R=>R,
        G=>G,
        B=>B
    );
    Hsync <= Hsync_reg;
    Vsync <= Vsync_reg;
end structural;
