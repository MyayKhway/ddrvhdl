library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_ctrl_test is
    Port ( CLK_I : in STD_LOGIC;
           VGA_HS_O : out STD_LOGIC;
           VGA_VS_O : out STD_LOGIC;
           active: BUFFER STD_LOGIC;
           pixel_clk: BUFFER STD_LOGIC;
           -- for the clocking wizard inputs
           reset: in STD_LOGIC;
           locked: out STD_LOGIC;
           hcntr : buffer std_logic_vector(11 downto 0);
           vcntr: buffer std_logic_vector(11 downto 0)

           );
end vga_ctrl_test;

architecture Behavioral of vga_ctrl_test is
component pixel_clock_gen
port
 (-- Clock in ports
  clk_in1           : in     std_logic;
  -- Clock out ports
  reset             : in     std_logic;
  locked            : out    std_logic;
  clk_out1          : out    std_logic

 );
end component;

  --***1280x1024@60Hz***--
  constant FRAME_WIDTH : natural := 1280;
  constant FRAME_HEIGHT : natural := 1024;
  
  constant H_FP : natural := 48; --H front porch width (pixels)
  constant H_PW : natural := 112; --H sync pulse width (pixels)
  constant H_MAX : natural := 1688; --H total period (pixels)
  
  constant V_FP : natural := 1; --V front porch width (lines)
  constant V_PW : natural := 3; --V sync pulse width (lines)
  constant V_MAX : natural := 1066; --V total period (lines)
  
  constant H_POL : std_logic := '1';
  constant V_POL : std_logic := '1';
  
  -------------------------------------------------------------------------
  
  -- VGA Controller specific signals: Counters, Sync, R, G, B
  
  -------------------------------------------------------------------------
  -- Pixel clock, in this case 108 MHz
  signal pxl_clk : std_logic;
  
  -- Horizontal and Vertical counters
  signal h_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');
  signal v_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');
  
  -- Horizontal and Vertical Sync
  signal h_sync_reg : std_logic := not(H_POL);
  signal v_sync_reg : std_logic := not(V_POL);
  -------------------------------------------------------------------------
  --Mouse pointer signals
  -------------------------------------------------------------------------
  
  -- Mouse data signals

  -----------------------------------------------------------
  -- Signals for generating the background (moving colorbar)
  -----------------------------------------------------------
--  signal cntDyn                : integer range 0 to 2**28-1; -- counter for generating the colorbar
--  signal intHcnt                : integer range 0 to H_MAX - 1;
--  signal intVcnt                : integer range 0 to V_MAX - 1;
  

begin
  
            
  clk_wiz_0_inst : pixel_clock_gen
  port map
   (
    clk_in1 => CLK_I,
    clk_out1 => pxl_clk,
    reset => reset,
    locked => locked);
       
       -- Generate Horizontal, Vertical counters and the Sync signals
       
       ---------------------------------------------------------------
         -- Horizontal counter
         process (pxl_clk)
         begin
           if (rising_edge(pxl_clk)) then
             if (h_cntr_reg = (H_MAX - 1)) then
               h_cntr_reg <= (others =>'0');
             else
               h_cntr_reg <= h_cntr_reg + 1;
             end if;
           end if;
         end process;
         
         -- Vertical counter
         process (pxl_clk)
         begin
           if (rising_edge(pxl_clk)) then
             if ((h_cntr_reg = (H_MAX - 1)) and (v_cntr_reg = (V_MAX - 1))) then
               v_cntr_reg <= (others =>'0');
             elsif (h_cntr_reg = (H_MAX - 1)) then
               v_cntr_reg <= v_cntr_reg + 1;
             end if;
           end if;
         end process;
         
         hcntr <= h_cntr_reg;
         vcntr <= v_cntr_reg;   
         -- Horizontal sync
         process (pxl_clk)
         begin
           if (rising_edge(pxl_clk)) then
             if (h_cntr_reg >= (H_FP + FRAME_WIDTH - 1)) and (h_cntr_reg < (H_FP + FRAME_WIDTH + H_PW - 1)) then
               h_sync_reg <= H_POL;
             else
               h_sync_reg <= not(H_POL);
             end if;
           end if;
         end process;
         
         -- Vertical sync
         process (pxl_clk)
         begin
           if (rising_edge(pxl_clk)) then
             if (v_cntr_reg >= (V_FP + FRAME_HEIGHT - 1)) and (v_cntr_reg < (V_FP + FRAME_HEIGHT + V_PW - 1)) then
               v_sync_reg <= V_POL;
             else
               v_sync_reg <= not(V_POL);
             end if;
           end if;
         end process;
       
       -- The active 
       
       --------------------  
         -- active signal
         active <= '1' when h_cntr_reg < FRAME_WIDTH and v_cntr_reg < FRAME_HEIGHT
                   else '0';
     -- Assign outputs
     VGA_HS_O     <= h_sync_reg;
     VGA_VS_O     <= v_sync_reg;
     pixel_clk <= pxl_clk;


end Behavioral;