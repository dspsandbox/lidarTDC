----------------------------------------------------------------------------------
-- Company: DSPsandbox
-- Engineer: Pau Gomez
-- 
-- Create Date: 17.08.2020 07:53:29
-- Design Name: 
-- Module Name: IDDR_inputStretcher - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

entity IDDR_inputStretcher is
    Generic(PORT_WIDTH : integer := 1);
    Port ( clk : in STD_LOGIC;
           dataIn : in STD_LOGIC_VECTOR (PORT_WIDTH - 1 downto 0);
           dataOut : out STD_LOGIC_VECTOR (PORT_WIDTH - 1 downto 0));
end IDDR_inputStretcher;

architecture Behavioral of IDDR_inputStretcher is
    signal D : STD_LOGIC_VECTOR (PORT_WIDTH - 1 downto 0);
    signal Q1 : STD_LOGIC_VECTOR (PORT_WIDTH - 1 downto 0);
    signal Q2 : STD_LOGIC_VECTOR (PORT_WIDTH - 1 downto 0);
begin
    GEN_IDDR: for i in 0 to PORT_width - 1 generate
        IDDR_inst : IDDR 
        generic map (
        DDR_CLK_EDGE => "SAME_EDGE_PIPELINED", -- "OPPOSITE_EDGE", "SAME_EDGE" 
                                       -- or "SAME_EDGE_PIPELINED" 
        INIT_Q1 => '0', -- Initial value of Q1: '0' or '1'
        INIT_Q2 => '0', -- Initial value of Q2: '0' or '1'
        SRTYPE => "SYNC") -- Set/Reset type: "SYNC" or "ASYNC" 
        port map (
        Q1 => Q1(i), -- 1-bit output for positive edge of clock 
        Q2 => Q2(i), -- 1-bit output for negative edge of clock
        C => clk,   -- 1-bit clock input
        CE => '1', -- 1-bit clock enable input
        D => D(i),   -- 1-bit DDR data input
        R => '0',   -- 1-bit reset
        S => '0'    -- 1-bit set
        );    
    end generate GEN_IDDR;
    
    D <= dataIn;

    GEN_OR: for i in 0 to PORT_width - 1 generate
	   dataOut(I) <= Q1(i) or Q2(i);	
    end generate GEN_OR;  
       
end Behavioral;
