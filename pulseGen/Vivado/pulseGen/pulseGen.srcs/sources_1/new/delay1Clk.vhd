----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.08.2020 08:24:06
-- Design Name: 
-- Module Name: delay1Clk - Behavioral
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

entity delay1Clk is
    Generic (PORT_WIDTH : INTEGER := 1);
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           dataIn : in STD_LOGIC_VECTOR (PORT_WIDTH - 1 downto 0);
           dataOut : out STD_LOGIC_VECTOR (PORT_WIDTH - 1 downto 0));
end delay1Clk;

architecture Behavioral of delay1Clk is
    signal data_reg : STD_LOGIC_VECTOR (PORT_WIDTH - 1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if resetn='0' then
                data_reg <= (others=>'0');
            else
                data_reg <= dataIn;
            end if;    
        end if;
    end process;
    
    dataOut <= data_reg;
end Behavioral;
