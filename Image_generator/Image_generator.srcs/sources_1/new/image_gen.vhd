----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2024 01:33:53 PM
-- Design Name: 
-- Module Name: image_gen - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


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

entity image_gen is
    Port ( Hsync : in STD_LOGIC;
           Vsync : in STD_LOGIC;
           active : in STD_LOGIC;
           pixel_clk : in STD_LOGIC;
           Hactive : in STD_LOGIC;
           Vactive : in STD_LOGIC;
           hcntr: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
           vcntr: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
           R : out STD_LOGIC_VECTOR (3 downto 0);
           G : out STD_LOGIC_VECTOR (3 downto 0);
           B : out STD_LOGIC_VECTOR (3 downto 0));
end image_gen;

architecture Behavioral of image_gen is

begin
    process(pixel_clk)
        begin
            if (rising_edge(pixel_clk)) then
                if (active = '1') then  
                        R <= (OTHERS => '0');
                        G <= "1111";
                        B <= "1111";
                else 
                    R <= (OTHERS => '0');
                    G <= (OTHERS => '0');
                    B <= (OTHERS => '0');
                end if;
            end if;
        end process;

end Behavioral;
