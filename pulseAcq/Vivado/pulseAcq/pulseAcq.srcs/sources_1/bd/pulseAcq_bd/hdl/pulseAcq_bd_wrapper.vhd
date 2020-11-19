--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
--Date        : Wed Nov 18 09:56:11 2020
--Host        : 5CD010B25T running 64-bit major release  (build 9200)
--Command     : generate_target pulseAcq_bd_wrapper.bd
--Design      : pulseAcq_bd_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity pulseAcq_bd_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    clk_10 : in STD_LOGIC;
    led0_b : out STD_LOGIC_VECTOR ( 0 to 0 );
    led0_g : out STD_LOGIC_VECTOR ( 0 to 0 );
    led0_r : out STD_LOGIC_VECTOR ( 0 to 0 );
    pulse : in STD_LOGIC_VECTOR ( 7 downto 0 );
    shield_i2c_scl_io : inout STD_LOGIC;
    shield_i2c_sda_io : inout STD_LOGIC;
    timestamp : in STD_LOGIC_VECTOR ( 7 downto 0 );
    trig : in STD_LOGIC
  );
end pulseAcq_bd_wrapper;

architecture STRUCTURE of pulseAcq_bd_wrapper is
  component pulseAcq_bd is
  port (
    led0_b : out STD_LOGIC_VECTOR ( 0 to 0 );
    led0_g : out STD_LOGIC_VECTOR ( 0 to 0 );
    led0_r : out STD_LOGIC_VECTOR ( 0 to 0 );
    trig : in STD_LOGIC;
    pulse : in STD_LOGIC_VECTOR ( 7 downto 0 );
    timestamp : in STD_LOGIC_VECTOR ( 7 downto 0 );
    clk_10 : in STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    shield_i2c_scl_i : in STD_LOGIC;
    shield_i2c_scl_o : out STD_LOGIC;
    shield_i2c_scl_t : out STD_LOGIC;
    shield_i2c_sda_i : in STD_LOGIC;
    shield_i2c_sda_o : out STD_LOGIC;
    shield_i2c_sda_t : out STD_LOGIC
  );
  end component pulseAcq_bd;
  component IOBUF is
  port (
    I : in STD_LOGIC;
    O : out STD_LOGIC;
    T : in STD_LOGIC;
    IO : inout STD_LOGIC
  );
  end component IOBUF;
  signal shield_i2c_scl_i : STD_LOGIC;
  signal shield_i2c_scl_o : STD_LOGIC;
  signal shield_i2c_scl_t : STD_LOGIC;
  signal shield_i2c_sda_i : STD_LOGIC;
  signal shield_i2c_sda_o : STD_LOGIC;
  signal shield_i2c_sda_t : STD_LOGIC;
begin
pulseAcq_bd_i: component pulseAcq_bd
     port map (
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      clk_10 => clk_10,
      led0_b(0) => led0_b(0),
      led0_g(0) => led0_g(0),
      led0_r(0) => led0_r(0),
      pulse(7 downto 0) => pulse(7 downto 0),
      shield_i2c_scl_i => shield_i2c_scl_i,
      shield_i2c_scl_o => shield_i2c_scl_o,
      shield_i2c_scl_t => shield_i2c_scl_t,
      shield_i2c_sda_i => shield_i2c_sda_i,
      shield_i2c_sda_o => shield_i2c_sda_o,
      shield_i2c_sda_t => shield_i2c_sda_t,
      timestamp(7 downto 0) => timestamp(7 downto 0),
      trig => trig
    );
shield_i2c_scl_iobuf: component IOBUF
     port map (
      I => shield_i2c_scl_o,
      IO => shield_i2c_scl_io,
      O => shield_i2c_scl_i,
      T => shield_i2c_scl_t
    );
shield_i2c_sda_iobuf: component IOBUF
     port map (
      I => shield_i2c_sda_o,
      IO => shield_i2c_sda_io,
      O => shield_i2c_sda_i,
      T => shield_i2c_sda_t
    );
end STRUCTURE;
