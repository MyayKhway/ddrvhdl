LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE ieee.math_real.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY vga_ctrl IS
	PORT (
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
END vga_ctrl;

ARCHITECTURE Behavioral OF vga_ctrl IS
	COMPONENT pixel_clk_gen
		PORT (-- Clock in ports
			clk_in1   : IN std_logic;
			-- Clock out ports
			reset     : IN std_logic;
			locked    : OUT std_logic;
			clk_out1  : OUT std_logic
		);
	END COMPONENT;
    
    -- ROM components for game files
    COMPONENT easy_seq
    PORT (
        a : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        spo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) 
    );
    END COMPONENT;
    
    COMPONENT hard_seq
    PORT (
        a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        spo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) 
    );
    END COMPONENT;
    
    
	--***1280x1024@60Hz***--
	CONSTANT FRAME_WIDTH : NATURAL := 1280;
	CONSTANT FRAME_HEIGHT : NATURAL := 1024;
 
	CONSTANT H_FP : NATURAL := 48; --H front porch width (pixels)
	CONSTANT H_PW : NATURAL := 112; --H sync pulse width (pixels)
	CONSTANT H_MAX : NATURAL := 1688; --H total period (pixels)
 
	CONSTANT V_FP : NATURAL := 1; --V front porch width (lines)
	CONSTANT V_PW : NATURAL := 3; --V sync pulse width (lines)
	CONSTANT V_MAX : NATURAL := 1066; --V total period (lines)
 
	CONSTANT H_POL : std_logic := '1';
	CONSTANT V_POL : std_logic := '1';
 
	CONSTANT blob_height : NATURAL := 150;
	CONSTANT blob_width : NATURAL := 150;
 
	CONSTANT speed : NATURAL := 15;

	-------------------------------------------------------------------------
 
	-- VGA Controller specific signals: Counters, Sync, R, G, B
 
	-------------------------------------------------------------------------
	-- Pixel clock, in this case 108 MHz
	SIGNAL blob_pos : INTEGER := 1024;
	SIGNAL pxl_clk : std_logic;
	-- The active signal is used to signal the active region of the screen (when not blank)
	SIGNAL active : std_logic;
 
	-- Horizontal and Vertical counters
	SIGNAL h_cntr_reg : std_logic_vector(11 DOWNTO 0) := (OTHERS => '0');
	SIGNAL v_cntr_reg : std_logic_vector(11 DOWNTO 0) := (OTHERS => '0');
 
	-- Pipe Horizontal and Vertical Counters
	SIGNAL h_cntr_reg_dly : std_logic_vector(11 DOWNTO 0) := (OTHERS => '0');
	SIGNAL v_cntr_reg_dly : std_logic_vector(11 DOWNTO 0) := (OTHERS => '0');
 
	-- Horizontal and Vertical Sync
	SIGNAL h_sync_reg : std_logic := NOT(H_POL);
	SIGNAL v_sync_reg : std_logic := NOT(V_POL);
	-- Pipe Horizontal and Vertical Sync
	SIGNAL h_sync_reg_dly : std_logic := NOT(H_POL);
	SIGNAL v_sync_reg_dly : std_logic := NOT(V_POL);
 
	-- VGA R, G and B signals coming from the main multiplexers
	SIGNAL vga_red_cmb : std_logic_vector(3 DOWNTO 0);
	SIGNAL vga_green_cmb : std_logic_vector(3 DOWNTO 0);
	SIGNAL vga_blue_cmb : std_logic_vector(3 DOWNTO 0);
	--The main VGA R, G and B signals, validated by active
	SIGNAL vga_red : std_logic_vector(3 DOWNTO 0);
	SIGNAL vga_green : std_logic_vector(3 DOWNTO 0);
	SIGNAL vga_blue : std_logic_vector(3 DOWNTO 0);
	-- Register VGA R, G and B signals
	SIGNAL vga_red_reg : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
	SIGNAL vga_green_reg : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
	SIGNAL vga_blue_reg : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
 
	SIGNAL game_seq_reg : std_logic_vector(3 DOWNTO 0);
	SIGNAL game_seq_reg_easy : std_logic_vector(3 DOWNTO 0);
	SIGNAL game_seq_reg_hard : std_logic_vector(3 DOWNTO 0);
	SIGNAL fetch_new_line: std_logic := '1';
	SIGNAL ROM_address_easy: std_logic_vector(6 downto 0);
	SIGNAL ROM_address_hard: std_logic_vector(7 downto 0);
 
	-------------------------------------------------------------------------
	--Mouse pointer signals
	-------------------------------------------------------------------------
 
	-- Mouse data signals

	-----------------------------------------------------------
	-- Signals for generating the background (moving colorbar)
	-----------------------------------------------------------
	-- signal cntDyn : integer range 0 to 2**28-1; -- counter for generating the colorbar
	-- signal intHcnt : integer range 0 to H_MAX - 1;
	-- signal intVcnt : integer range 0 to V_MAX - 1;
	-- Colorbar red, greeen and blue signals
	SIGNAL bg_red : std_logic_vector(3 DOWNTO 0);
	SIGNAL bg_blue : std_logic_vector(3 DOWNTO 0);
	SIGNAL bg_green : std_logic_vector(3 DOWNTO 0);
	-- Pipe the colorbar red, green and blue signals
	SIGNAL bg_red_dly : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
	SIGNAL bg_green_dly : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
	SIGNAL bg_blue_dly : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
 

BEGIN
	clk_wiz_0_inst : pixel_clk_gen
	PORT MAP(
		clk_in1   => CLK_I, 
		clk_out1  => pxl_clk, 
		reset     => reset, 
		locked    => locked); 
		
    butterfly_easy : easy_seq
    PORT MAP (
        a => ROM_address_easy,
        spo => game_seq_reg_easy
    );
    
    butterfly_hard: hard_seq
    PORT MAP (
        a => ROM_address_hard,
        spo => game_seq_reg_hard
    );
		-- Generate Horizontal, Vertical counters and the Sync signals
 
		---------------------------------------------------------------
		-- Horizontal counter
		PROCESS (pxl_clk)
		BEGIN
			IF (rising_edge(pxl_clk)) THEN
				IF (h_cntr_reg = (H_MAX - 1)) THEN
					h_cntr_reg <= (OTHERS => '0');
				ELSE
					h_cntr_reg <= h_cntr_reg + 1;
				END IF;
			END IF;
		END PROCESS;
 
		-- Vertical counter
		PROCESS (pxl_clk)
			BEGIN
				IF (rising_edge(pxl_clk)) THEN
					IF ((h_cntr_reg = (H_MAX - 1)) AND (v_cntr_reg = (V_MAX - 1))) THEN
						-- one frame done
						v_cntr_reg <= (OTHERS => '0');
						IF (blob_pos <= 0) THEN
						    fetch_new_line <= '1';
							blob_pos <= 1023;
						ELSE
							blob_pos <= blob_pos - speed;
							fetch_new_line <= '0';
						END IF;
						IF (blob_pos >=5 and blob_pos <= 205) then
						  CHECK_READY <= '1';
						ELSE CHECK_READY <= '0';
						END IF;
					ELSIF (h_cntr_reg = (H_MAX - 1)) THEN
						v_cntr_reg <= v_cntr_reg + 1;
					END IF;
				END IF;
			END PROCESS;
 
			-- Horizontal sync
			PROCESS (pxl_clk)
				BEGIN
					IF (rising_edge(pxl_clk)) THEN
						IF (h_cntr_reg >= (H_FP + FRAME_WIDTH - 1)) AND (h_cntr_reg < (H_FP + FRAME_WIDTH + H_PW - 1)) THEN
							h_sync_reg <= H_POL;
						ELSE
							h_sync_reg <= NOT(H_POL);
						END IF;
					END IF;
				END PROCESS;
 
				-- Vertical sync
				PROCESS (pxl_clk)
					BEGIN
						IF (rising_edge(pxl_clk)) THEN
							IF (v_cntr_reg >= (V_FP + FRAME_HEIGHT - 1)) AND (v_cntr_reg < (V_FP + FRAME_HEIGHT + V_PW - 1)) THEN
								v_sync_reg <= V_POL;
							ELSE
								v_sync_reg <= NOT(V_POL);
							END IF;
						END IF;
					END PROCESS;
					-- Register Inputs
 
					-------------------------------
					draw_squares : PROCESS (pxl_clk)
						VARIABLE h_cntr_int : INTEGER := conv_integer(h_cntr_reg);
						VARIABLE v_cntr_int : INTEGER := conv_integer(v_cntr_reg);
					BEGIN
					    IF DIF_SEL='0' then
					       game_seq_reg <= game_seq_reg_easy;
					    ELSE game_seq_reg <= game_seq_reg_hard;
					    END IF;
						IF (rising_edge(pxl_clk)) THEN
							IF (v_cntr_int >= blob_pos AND v_cntr_int <= blob_pos + blob_height AND h_cntr_int >= 200 AND h_cntr_int <= 200 + blob_height) THEN
								IF game_seq_reg(3) = '1' THEN
									bg_red <= "1111";
								ELSE
									bg_red <= "0000";
								END IF;
								bg_green <= "0000";
								bg_blue <= "0000";
							ELSIF (v_cntr_int >= blob_pos AND v_cntr_int <= blob_pos + blob_height AND h_cntr_int >= 200 + blob_height + 100 AND h_cntr_int <= 200 + blob_height + 100 + blob_height) THEN
								IF game_seq_reg(2) = '1' THEN
									bg_green <= "1111";
								ELSE
									bg_green <= "0000";
								END IF;
								bg_red <= "0000";
								bg_blue <= "0000";
							ELSIF (v_cntr_int >= blob_pos AND v_cntr_int <= blob_pos + blob_height AND h_cntr_int >= 200 + (2 * blob_height) + 200 AND h_cntr_int <= 200 + (3 * blob_height) + 200) THEN
								IF game_seq_reg(1) = '1' THEN
									bg_blue <= "1111";
								ELSE
									bg_blue <= "0000";
								END IF; 
								bg_red <= "0000";
								bg_green <= "0000";
							ELSIF (v_cntr_int >= blob_pos AND v_cntr_int <= blob_pos + blob_height AND h_cntr_int >= 200 + (3 * blob_height) + 300 AND h_cntr_int <= 200 + (4 * blob_height) + 300) THEN
								IF game_seq_reg(0) = '1' THEN
									bg_red <= "1111";
									bg_green <= "1111";
								ELSE
									bg_red <= "0000";
									bg_green <= "0000";
									bg_blue <= "0000";
								END IF;
							ELSE
								bg_red <= "0000";
								bg_green <= "0000";
								bg_blue <= "0000";
							END IF;
						END IF;
					END PROCESS;
                    
					-- active signal
					active <= '1' WHEN h_cntr_reg < FRAME_WIDTH AND v_cntr_reg < FRAME_HEIGHT
					          ELSE '0';
					-- Register Outputs coming from the displaying components and the horizontal and vertical counters
 
					---------------------------------------------------------------------------------------------------
					PROCESS(fetch_new_line)
					   BEGIN
					       IF (fetch_new_line = '1') then
					           IF DIF_SEL='0' then
					               ROM_address_easy <= ROM_address_easy + 1;
					           ELSE ROM_address_hard <= ROM_address_hard + 1;
					           END IF;
					       END IF;
					END PROCESS;
					
					PROCESS (pxl_clk)
						BEGIN
							IF (rising_edge(pxl_clk)) THEN
 
								bg_red_dly <= bg_red;
								bg_green_dly <= bg_green;
								bg_blue_dly <= bg_blue;
								h_cntr_reg_dly <= h_cntr_reg;
								v_cntr_reg_dly <= v_cntr_reg;

							END IF;
						END PROCESS;

						----------------------------------
 
						-- VGA Output Muxing
 
						----------------------------------

						vga_red <= bg_red_dly when conv_integer(v_cntr_reg_dly) /= 5 else "1111";
						vga_green <= bg_green_dly when conv_integer(v_cntr_reg_dly) /= 205 else "1111";
						vga_blue <= bg_blue_dly;
 
						------------------------------------------------------------
						-- Turn Off VGA RBG Signals if outside of the active screen
						-- Make a 4-bit AND logic with the R, G and B signals
						------------------------------------------------------------
						vga_red_cmb <= (active & active & active & active) AND vga_red;
						vga_green_cmb <= (active & active & active & active) AND vga_green;
						vga_blue_cmb <= (active & active & active & active) AND vga_blue;
 
 
						-- Register Outputs
						PROCESS (pxl_clk)
							BEGIN
								IF (rising_edge(pxl_clk)) THEN
									v_sync_reg_dly <= v_sync_reg;
									h_sync_reg_dly <= h_sync_reg;
									vga_red_reg <= vga_red_cmb;
									vga_green_reg <= vga_green_cmb;
									vga_blue_reg <= vga_blue_cmb; 
								END IF;
							END PROCESS;
 
							-- Assign outputs
							VGA_HS_O <= h_sync_reg_dly;
							VGA_VS_O <= v_sync_reg_dly;
							VGA_RED_O <= vga_red_reg;
							VGA_GREEN_O <= vga_green_reg;
							VGA_BLUE_O <= vga_blue_reg;
							CORRECT_DATA <= game_seq_reg;

END Behavioral;