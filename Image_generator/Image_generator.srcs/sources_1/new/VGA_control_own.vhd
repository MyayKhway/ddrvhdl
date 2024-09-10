LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE ieee.math_real.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY vga_ctrl IS
	PORT (
		CLK_I : IN STD_LOGIC;
		-- Hsync and Vsync goes into VGA monitor cable directly
		Hsync, Vsync : BUFFER STD_LOGIC;
		--- Hactive and Vactive go into Pixel drawer
		Hactive : BUFFER STD_LOGIC;
		Vactive : BUFFER STD_LOGIC;
		-- this is for 108 Mhz output going into image generator
		pixel_clk : BUFFER STD_LOGIC;
		--- This is signal for display enable
		active : OUT STD_LOGIC;

		-- for the clocking wizard inputs
		reset : IN STD_LOGIC;
		locked : OUT STD_LOGIC
	);
END vga_ctrl;

ARCHITECTURE Behavioral OF vga_ctrl IS
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
	COMPONENT pixel_clock_gen
		PORT (-- Clock in ports
			clk_in1 : IN std_logic;
			-- Clock out ports
			reset : IN std_logic;
			locked : OUT std_logic;
			clk_out1 : OUT std_logic
		);
	END COMPONENT;

	-- The active signal is used to signal the active region of the screen (when not blank)
	SIGNAL active_reg : std_logic := '0';
	SIGNAL Hsync_reg, Vsync_reg: std_logic;
	SIGNAL Hsync_reg_delay, Vsync_reg_delay: std_logic;
	SIGNAL Hactive_reg, Vactive_reg: std_logic;

BEGIN
	clk_wiz_0_inst : pixel_clock_gen
	PORT MAP(
		clk_in1 => CLK_I, 
		clk_out1 => pixel_clk, 
		reset => reset, 
		locked => locked);
 
		--Horizontal sync signals generation:
		PROCESS (pixel_clk)
		VARIABLE Hcount : INTEGER RANGE 0 TO H_MAX;
		BEGIN
		    if Hcount>H_MAX - 1 then
			 Hcount := 0;
			END IF;
			IF (rising_edge(pixel_clk)) THEN
				Hcount := Hcount + 1;
				if (Hcount <= (H_FP + FRAME_WIDTH - 1) and Hcount >= (H_FP + FRAME_WIDTH + H_PW - 1)) then
				    Hsync_reg <= H_POL;
				else 
				    Hsync_reg <= not(H_POL);
	            end if;
	            if (Hcount < FRAME_WIDTH) then
	               Hactive_reg <= '1';
	            else Hactive_reg <= '0';
	            end if;
			END IF;
		END PROCESS;

         -- Vertical sync
         process (pixel_clk)
         VARIABLE Vcount : INTEGER RANGE 0 TO V_MAX;
         begin
            if Vcount > V_MAX - 1 then
                Vcount := 0;
            end if;
           if (rising_edge(pixel_clk)) then
             Vcount := Vcount + 1;
             if (Vcount >= (V_FP + FRAME_HEIGHT - 1)) and (Vcount < (V_FP + FRAME_HEIGHT + V_PW - 1)) then
               Vsync_reg <= V_POL;
             else
               Vsync_reg <= not(V_POL);
             end if;
             if (Vcount < FRAME_HEIGHT) then
                Vactive_reg <= '1';
             else
                Vactive_reg <= '0';
             end if;
           end if;
         end process;
        
        -- Register outputs
        process (pixel_clk)
            begin
                if (rising_edge(pixel_clk)) then
                    Vsync_reg_delay <= Vsync_reg;
                    Hsync_reg_delay <= Hsync_reg;      
                end if;
        end process;
        
        active <= Hactive and Vactive;

END Behavioral;