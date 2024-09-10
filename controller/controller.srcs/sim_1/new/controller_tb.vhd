----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2024 08:21:32 PM
-- Design Name: 
-- Module Name: controller_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_tb is
--  Port ( );
end controller_tb;

architecture test_bench of controller_tb is
component controller is port(
           button1 : in STD_LOGIC;
           button2 : in STD_LOGIC;
           button3 : in STD_LOGIC;
           button4 : in STD_LOGIC;
           clk: in STD_LOGIC;
           out1 : out STD_LOGIC;
           out2 : out STD_LOGIC;
           out3 : out STD_LOGIC;
           out4 : out STD_LOGIC
);
end component;
signal clktb : std_logic := '0';
signal b1tb, b2tb, b3tb, b4tb: std_logic;
signal o1tb, o2tb, o3tb, o4tb: std_logic;
begin
control1: controller port map
(
button1=>b1tb,
button2=>b2tb,
button3=>b3tb,
button4=>b4tb,
clk=>clktb,
out1=>o1tb,
out2=>o2tb,
out3=>o3tb,
out4=>o4tb
);

clktb <= not clktb after 20 ms;
b1tb <= '0' after 10ms, '1' after 20ms;
b2tb <= '0' after 30ms, '1' after 40ms;
b3tb <= '1' after 10ms;
b4tb <= '0' after 50ms, '1' after 100ms;

end test_bench;
