----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/03/2024 04:25:05 PM
-- Design Name: 
-- Module Name: ROM_reader - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ROM_reader is
--  Port ( );
GENERIC(
    PERIOD: INTEGER := 100000000; -- default clock so will make this chip 1 second
    SPEED: INTEGER := 1
);
Port(
    clk: in STD_LOGIC;
    data_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
);
end ROM_reader;

architecture Behavioral of ROM_reader is
COMPONENT dist_mem_gen_0
  PORT (
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    spo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) 
  );
END COMPONENT;

signal counter: INTEGER := 0;
signal one_hertz_pulse : STD_LOGIC := '0';
signal address: INTEGER := 0;
signal address_reg: STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
begin

    process (clk)
    begin
    if (rising_edge(clk)) then
        if (counter = PERIOD - 1) then
            counter <= 0;
            one_hertz_pulse <= not one_hertz_pulse;
        else counter <= counter + 1;
        end if;
    end if;
    end process;
    
    process (one_hertz_pulse)
    begin
        if (rising_edge(one_hertz_pulse)) then
            if (address = 255) then
                address <= 0;
            else address <= address + 1;
            end if;
        end if;
    end process;        
    address_reg <= std_logic_vector(TO_UNSIGNED (address, address_reg'length));
    ROM: dist_mem_gen_0 port map(
        a => address_reg,        
        spo => data_out
    );
end Behavioral;
