----------------------------------------------------------------------------------
-- Company: DSPsandbox
-- Engineer: Pau Gomez
-- 
-- Create Date: 11.08.2020 09:34:40
-- Design Name: 
-- Module Name: pulseAcq - Behavioral
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



entity pulseAcq is
    
    Generic ( CHANNELS : integer range 1 to 32 := 1;
              COUNTER_WIDTH : integer := 24;
              TIMESTAMP_WIDTH : integer :=8;
              MASK_WIDTH : integer := 32);
              
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           counterMax : in STD_LOGIC_VECTOR (COUNTER_WIDTH - 1 downto 0);
           trig : in STD_LOGIC;
           pulse : in STD_LOGIC_VECTOR (CHANNELS - 1 downto 0);
           timestamp : in STD_LOGIC_VECTOR (TIMESTAMP_WIDTH - 1 downto 0);
           streamUp_tdata : out STD_LOGIC_VECTOR (MASK_WIDTH + TIMESTAMP_WIDTH + COUNTER_WIDTH - 1 downto 0);
           streamUp_tvalid : out STD_LOGIC;
           streamUp_tlast : out STD_LOGIC;
           streamUp_tready : in STD_LOGIC;
           state : out std_logic_vector (2 downto 0);
           streamUpCounter: out STD_LOGIC_VECTOR (COUNTER_WIDTH - 1 downto 0));
end pulseAcq;

architecture Behavioral of pulseAcq is
    constant zeroMask : std_logic_vector(MASK_WIDTH - 1 downto 0 ) := (others => '0');
    type state_type is (idle,run,err);
    signal state_reg : state_type := idle;
    signal counter_reg : unsigned (COUNTER_WIDTH - 1 downto 0) := (others => '0');
    signal trig_reg0 : std_logic := '0';
    signal trig_reg1 : std_logic := '0';
    signal trig_reg2 : std_logic := '0';
    signal pulse_reg0 : std_logic_vector (CHANNELS - 1 downto 0) := (others =>'0');
    signal pulse_reg1 : std_logic_vector (CHANNELS - 1 downto 0) := (others =>'0');
    signal pulse_reg2 : std_logic_vector (CHANNELS - 1 downto 0) := (others =>'0');
    signal counterMax_reg : unsigned (COUNTER_WIDTH - 1 downto 0) := (others => '0');
    signal timestamp_reg : STD_LOGIC_VECTOR (TIMESTAMP_WIDTH - 1 downto 0) := (others => '0');
    signal streamUpCounter_reg: unsigned (COUNTER_WIDTH - 1 downto 0) := (others => '0');
    signal tdata_reg  : std_logic_vector (MASK_WIDTH + TIMESTAMP_WIDTH + COUNTER_WIDTH - 1 downto 0)  := (others => '0');
    signal tvalid_reg : std_logic := '0';
    signal tready : std_logic := '0';
    signal tlast_reg : std_logic := '0';
    signal data_counter_reg : std_logic_vector (COUNTER_WIDTH - 1 downto 0) := (others => '0');
    signal data_timestamp_reg : std_logic_vector (TIMESTAMP_WIDTH -1 downto 0) := (others => '0');
    signal data_mask_reg : std_logic_vector (MASK_WIDTH -1 downto 0) := (others => '0');
    

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                state_reg <= idle;
                counter_reg <= (others => '0');
                trig_reg0 <= '0';
                trig_reg1 <= '0';
                trig_reg2 <= '0';
                pulse_reg0 <= (others => '0');
                pulse_reg1 <= (others => '0');
                pulse_reg2 <= (others => '0');
                counterMax_reg <= (others => '0');
                streamUpCounter_reg <= (others => '0');
                timestamp_reg <= (others => '0');
                tdata_reg <= (others => '0');
                tvalid_reg <= '0';
                tlast_reg <= '0';
                data_counter_reg <= (others => '0');
                data_timestamp_reg <= (others => '0');
                data_mask_reg <= (others => '0');
                
            else
               trig_reg0 <= trig;
               trig_reg1 <= trig_reg0;
               trig_reg2 <= trig_reg1;
               
               pulse_reg0 <= pulse;
               pulse_reg1 <= pulse_reg0;
               pulse_reg2 <= pulse_reg1;
               
               counterMax_reg <= unsigned(counterMax);
               timestamp_reg <= timestamp;
            
                case state_reg is
                    when idle  =>
                        counter_reg <= (others => '0');
                        tdata_reg <= (others => '0');
                        tvalid_reg <= '0';
                        tlast_reg <= '0';
                        data_counter_reg <= (others => '0');
                        data_timestamp_reg <= (others => '0');
                        data_mask_reg <= (others => '0');         
                                          
                        if trig_reg2 = '1' and trig_reg1 = '0' then
                            state_reg <= run;
                        else 
                            state_reg <= idle;
                        end if;
                        
                    when run =>
                        counter_reg <= counter_reg + 1;
                        
                        data_counter_reg <= std_logic_vector(counter_reg);
                        data_timestamp_reg <= timestamp_reg;
                        for i in 0 to CHANNELS - 1 loop
                            if (pulse_reg1(i)='0') and (pulse_reg2(i)='1') then
                                data_mask_reg(i) <= '1';    
                            else
                                data_mask_reg(i) <= '0';
                            end if;   
                        end loop;
                        
                        if counter_reg < counterMax_reg then
                            if data_mask_reg/=zeroMask then
                                tdata_reg <= data_mask_reg & data_timestamp_reg & data_counter_reg;
                                tvalid_reg <= '1';
                                tlast_reg <= '0';
                            end if;    
                        else
                            tdata_reg <= (others => '0');
                            tvalid_reg <= '1';
                            tlast_reg <= '1';
                        end if;
                        
                        if tvalid_reg='1' then
                            if tready='1' then 
                                if tlast_reg='0' then
                                    streamUpCounter_reg <= streamUpCounter_reg + 1;
                                    state_reg <= run;
                                else 
                                    state_reg <= idle;
                                end if;
                            else
                                state_reg <= err;
                            end if;
                        end if; 
                                                
                    when others => 
                        tdata_reg <= (others => '0');
                        tvalid_reg <= '1';
                        tlast_reg <= '1';    
                    
                end case;                 
            end if;
        end if;
    end process;

    streamUpCounter <= std_logic_vector(streamUpCounter_reg);
    streamUp_tdata <= tdata_reg;
    streamUp_tvalid <= tvalid_reg;
    tready <= streamUp_tready;
    streamUp_tlast <= tlast_reg;
    state <= "001" when state_reg = idle and resetn = '1' else
             "010" when state_reg = run and resetn = '1' else
             "100" when state_reg = err and resetn = '1' else
             "000";


end Behavioral;