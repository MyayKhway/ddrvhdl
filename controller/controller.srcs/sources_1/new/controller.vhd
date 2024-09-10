----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2024 08:14:23 PM
-- Design Name: 
-- Module Name: controller - Behavioral
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

entity controller is
    Port ( button1 : in STD_LOGIC;
           button2 : in STD_LOGIC;
           button3 : in STD_LOGIC;
           button4 : in STD_LOGIC;
           clk: in STD_LOGIC;
           out1 : out STD_LOGIC;
           out2 : out STD_LOGIC;
           out3 : out STD_LOGIC;
           out4 : out STD_LOGIC);
end controller;

architecture control of controller is
component debounce is port(
    clk, reset_n : in std_logic;
    button: in std_logic;
    result: out std_logic
);
end component;

begin
debounce1: debounce port map(clk=>clk, reset_n=>'1', button=>button1, result=>out1);
debounce2: debounce port map(clk=>clk, reset_n=>'1', button=>button2, result=>out2);
debounce3: debounce port map(clk=>clk, reset_n=>'1', button=>button3, result=>out3);
debounce4: debounce port map(clk=>clk, reset_n=>'1', button=>button4, result=>out4);

end control;
