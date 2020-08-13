----------------------------------------------------------------------------------
-- Company: DSPsandbox
-- Engineer: Pau Gomez
-- 
-- Create Date: 25.07.2020 09:29:56
-- Design Name: 
-- Module Name: pulseGen - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;



entity pulseGen is
    
    Generic ( CHANNELS : integer range 1 to 32 := 1;
              COUNTER_WIDTH : integer := 24;
              TIMESTAMP_WIDTH : integer :=8;
              MASK_WIDTH : integer := 32);
              
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           trig : in STD_LOGIC;
           pulse : out STD_LOGIC_VECTOR (CHANNELS - 1 downto 0);
           timestamp : out STD_LOGIC_VECTOR (TIMESTAMP_WIDTH - 1 downto 0);
           streamDown_tdata : in STD_LOGIC_VECTOR (MASK_WIDTH + TIMESTAMP_WIDTH + COUNTER_WIDTH - 1 downto 0);
           streamDown_tvalid : in STD_LOGIC;
           streamDown_tlast : in STD_LOGIC;
           streamDown_tready : out STD_LOGIC;
           state : out std_logic_vector (2 downto 0);
           streamDownCounter : out STD_LOGIC_VECTOR(COUNTER_WIDTH - 1 downto 0));
end pulseGen;

architecture Behavioral of pulseGen is
    type state_type is (idle,run,err);
    signal state_reg : state_type := idle;
    signal counter_reg : unsigned (COUNTER_WIDTH - 1 downto 0) := (others => '0');
    signal trig_reg : std_logic := '0';
    signal pulse_reg : std_logic_vector (CHANNELS - 1 downto 0) := (others =>'0');
    signal tready_reg : std_logic := '0';
    signal tdata : STD_LOGIC_VECTOR (MASK_WIDTH + TIMESTAMP_WIDTH + COUNTER_WIDTH - 1 downto 0);
    signal tvalid : std_logic;
    signal tlast : std_logic ;
    signal tlast_reg : std_logic := '0';
    signal data_counter_reg : unsigned (COUNTER_WIDTH - 1 downto 0) := (others => '0');
    signal data_timestamp : std_logic_vector (TIMESTAMP_WIDTH -1 downto 0) := (others => '0');
    signal data_timestamp_reg : std_logic_vector (TIMESTAMP_WIDTH -1 downto 0) := (others => '0');
    signal data_mask_reg : std_logic_vector (MASK_WIDTH -1 downto 0) := (others => '0');
    signal streamDownCounter_reg : unsigned (COUNTER_WIDTH - 1 downto 0) := (others => '0');
    

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                state_reg <= idle;
                counter_reg <= (others => '0');
                trig_reg <= '0';
                pulse_reg <= (others => '0');
                tready_reg <= '0'; 
                tlast_reg <= '0';
                data_counter_reg <= (others => '0');
                data_timestamp_reg <= (others => '0');
                data_mask_reg <= (others => '0');
                streamDownCounter_reg <= (others => '0');
                
            else
               trig_reg <= trig;
            
                case state_reg is
                    when idle  =>
                        counter_reg <= (others => '0');
                        pulse_reg <= (others => '0');
                        tready_reg <= '0';
                        tlast_reg <= '0';
                        data_counter_reg <= (others => '0');
                        data_timestamp_reg <= (others => '0');
                        data_mask_reg <= (others => '0');  
                                          
                        if trig = '1' and trig_reg = '0' then
                            state_reg <= run;
                            streamDownCounter_reg <= (others => '0');
                        else 
                            state_reg <= idle;
                        end if;
                        
                    when run =>
                        counter_reg <= counter_reg + 1;
                        if (tready_reg = '1' and counter_reg = unsigned(tdata(COUNTER_WIDTH - 1 downto 0))) then
                            pulse_reg <= tdata(CHANNELS + TIMESTAMP_WIDTH + COUNTER_WIDTH - 1 downto TIMESTAMP_WIDTH + COUNTER_WIDTH);
                            tready_reg <= '1';
                        else
                            if (tready_reg = '0' and counter_reg = data_counter_reg) then 
                                pulse_reg <= data_mask_reg(CHANNELS -1 downto 0);
                                tready_reg <= '1';
                            else
                                pulse_reg <= (others => '0');
                                tready_reg <= '0';
                            end if;
                        end if;
                        
                        if tready_reg = '1' then
                            if tlast_reg = '1' then 
                                state_reg <= idle;   
                            else                                 
                                if tvalid = '1' then
                                    data_counter_reg <= unsigned(tdata(COUNTER_WIDTH - 1 downto 0));
                                    data_timestamp_reg <= tdata(TIMESTAMP_WIDTH + COUNTER_WIDTH - 1 downto COUNTER_WIDTH);
                                    data_mask_reg <= tdata(MASK_WIDTH + TIMESTAMP_WIDTH + COUNTER_WIDTH - 1 downto TIMESTAMP_WIDTH + COUNTER_WIDTH);
                                    tlast_reg <= tlast;
                                    streamDownCounter_reg <= streamDownCounter_reg + 1 ;  
                                else
                                    state_reg <= err;
                                end if;
                            end if;
                        else
                            state_reg <= run;
                        end if;
                         
                    when others => 
                        --flush DMA
                        tready_reg <= '1';     
                end case;                 
            end if;
        end if;
    end process;

    pulse <= pulse_reg;
    timestamp <= data_timestamp_reg;
    streamDown_tready <= tready_reg;
    tdata <= streamDown_tdata;
    tvalid <= streamDown_tvalid;
    tlast <= streamDown_tlast;
    state <= "001" when state_reg = idle and resetn = '1' else
             "010" when state_reg = run and resetn = '1' else
             "100" when state_reg = err and resetn = '1' else
             "000";
    streamDownCounter <= std_logic_vector(streamDownCounter_reg);

end Behavioral;
