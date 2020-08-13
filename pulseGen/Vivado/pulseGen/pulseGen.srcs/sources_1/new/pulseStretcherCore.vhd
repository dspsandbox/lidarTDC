----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.08.2020 08:23:08
-- Design Name: 
-- Module Name: pulseStretcherCore - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pulseStretcherCore is
    Generic (COUNTER_WIDTH : integer := 8);
    
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           pulseWidth : in std_logic_vector(COUNTER_WIDTH - 1 downto 0);
           pulseIn : in STD_LOGIC;
           pulseOut : out STD_LOGIC);
end pulseStretcherCore;

architecture Behavioral of pulseStretcherCore is
    signal counter_reg : unsigned(COUNTER_WIDTH - 1 downto 0) := (others => '0');
    signal pulseWidth_reg : unsigned(COUNTER_WIDTH - 1 downto 0) := (others => '0');
    signal pulseIn_reg : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if resetn='0' then
                counter_reg <= (others => '0');
                pulseWidth_reg <= (others => '0');
                pulseIn_reg <= '0';
            else
                pulseWidth_reg <= unsigned(pulseWidth);
                pulseIn_reg <= pulseIn;
                
                if pulseIn = '1' and pulseIn_reg = '0' then
                    counter_reg <= pulseWidth_reg;
                else
                    if not(counter_reg = 0) then
                        counter_reg <= counter_reg - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
with counter_reg select pulseOut <= '0' when to_unsigned(0,counter_reg'length),
                                    '1' when others;

end Behavioral;
