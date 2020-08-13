----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.08.2020 08:21:50
-- Design Name: 
-- Module Name: pulseStretcher - Behavioral
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

library xil_defaultlib;
use xil_defaultlib.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pulseStretcher is
    Generic( PORT_WIDTH : integer := 1; 
             COUNTER_WIDTH : integer := 8);
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           pulseWidth : in std_logic_vector(COUNTER_WIDTH - 1 downto 0);
           pulseIn : in STD_LOGIC_VECTOR (PORT_WIDTH - 1 downto 0);
           pulseOut : out STD_LOGIC_VECTOR (PORT_WIDTH - 1 downto 0));
end pulseStretcher;

architecture Behavioral of pulseStretcher is
    component pulseStretcherCore
        Generic (COUNTER_WIDTH : integer);
        Port ( clk : in STD_LOGIC;
               resetn : in STD_LOGIC;
               pulseWidth : in std_logic_vector(COUNTER_WIDTH - 1 downto 0);
               pulseIn : in STD_LOGIC;
               pulseOut : out STD_LOGIC);
    end component;
begin


gen_pulseStretcher: for i in 0 to (PORT_WIDTH - 1) generate
      pulseStretcher_i : pulseStretcherCore
      generic map(
          COUNTER_WIDTH => COUNTER_WIDTH)
      port map(
          clk => clk,
          resetn => resetn,              
          pulseWidth => pulseWidth,
          pulseIn => pulseIn(i),
          pulseOut => pulseOut(i)
        );
   end generate gen_pulseStretcher;

end Behavioral;
