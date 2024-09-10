library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real."log2";
use IEEE.math_real."ceil";



-- Entity declaration for the top level module
entity ImageROM is
GENERIC (
    -- Define image width and height
    constant IMAGE_WIDTH : integer := 60;
    constant IMAGE_HEIGHT : integer := 100;
    -- Define data width (single color, so 1 bit)
    constant DATA_WIDTH : integer := 1
);
  Port (
    clk : in  STD_LOGIC;
    addr : in  unsigned(IMAGE_WIDTH-1 downto 0);
    dout : out  STD_LOGIC
  );
end entity ImageROM;

-- Architecture for the top level module
architecture Behavioral of ImageROM is

  -- Component declaration for BRAM
  component bram_image is
    generic (
      DEPTH : integer;
      WIDTH : integer
    );
    port (
      clk : in  STD_LOGIC;
      addr : in  unsigned(integer(ceil(log2(real(DEPTH))))-1 downto 0);
      we : in  STD_LOGIC;
      d : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
      q : out  STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
  end component;

  -- Internal signals
  signal bram_q : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

begin

  -- BRAM instantiation
  U_bram : bram_image
  generic map (
    DEPTH => (IMAGE_WIDTH * IMAGE_HEIGHT),
    WIDTH => DATA_WIDTH
  ) port map (
    clk => clk,
    addr => addr,
    we => '0', -- Read-only mode (no writing)
    d => (others => '0'), -- Not used in read-only mode
    q => bram_q
  );

  -- Output assignment
  dout <= bram_q(0); -- Assuming single bit for color

end architecture Behavioral;