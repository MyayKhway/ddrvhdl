----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2024 05:20:27 PM
-- Design Name: 
-- Module Name: blob - Behavioral
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

entity blob is
--  Port ( );
    GENERIC (
        WIDTH: INTEGER := 150;
        HEIGHT: INTEGER := 150;
        COLOR: STD_LOGIC_VECTOR := "111111110000" --Yellow
    );
    Port (
        X_IN, H_COUNT_IN: IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        Y_IN, V_COUNT_IN: IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        PIXEL_OUT: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
end blob;

architecture Behavioral of blob is
signal PIXEL_OUT_REG : STD_LOGIC_VECTOR(11 DOWNTO 0);
begin
    process (X_IN, H_COUNT_IN, Y_IN, V_COUNT_IN)
    BEGIN
        IF ((H_COUNT_IN >= X_IN and H_COUNT_IN < (X_IN + WIDTH)) and (V_COUNT_IN >= Y_IN and V_COUNT_IN < (Y_IN + HEIGHT))) then
            PIXEL_OUT_REG <= COLOR;
        else PIXEL_OUT_REG <= "000000000000";
        end IF;
    end process;
    PIXEL_OUT <= PIXEL_OUT_REG;
end Behavioral;
