-- (c) Copyright 1995-2020 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:module_ref:pulseGen:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pulseGen_bd_pulseGen_0_0 IS
  PORT (
    clk : IN STD_LOGIC;
    resetn : IN STD_LOGIC;
    trig : IN STD_LOGIC;
    pulseDuration : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    pulse : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    timestamp : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    streamDown_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    streamDown_tvalid : IN STD_LOGIC;
    streamDown_tlast : IN STD_LOGIC;
    streamDown_tready : OUT STD_LOGIC;
    state : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END pulseGen_bd_pulseGen_0_0;

ARCHITECTURE pulseGen_bd_pulseGen_0_0_arch OF pulseGen_bd_pulseGen_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF pulseGen_bd_pulseGen_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT pulseGen IS
    GENERIC (
      CHANNELS : INTEGER;
      COUNTER_WIDTH : INTEGER;
      TIMESTAMP_WIDTH : INTEGER;
      MASK_WIDTH : INTEGER
    );
    PORT (
      clk : IN STD_LOGIC;
      resetn : IN STD_LOGIC;
      trig : IN STD_LOGIC;
      pulseDuration : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      pulse : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      timestamp : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      streamDown_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      streamDown_tvalid : IN STD_LOGIC;
      streamDown_tlast : IN STD_LOGIC;
      streamDown_tready : OUT STD_LOGIC;
      state : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
  END COMPONENT pulseGen;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF pulseGen_bd_pulseGen_0_0_arch: ARCHITECTURE IS "pulseGen,Vivado 2018.3";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF pulseGen_bd_pulseGen_0_0_arch : ARCHITECTURE IS "pulseGen_bd_pulseGen_0_0,pulseGen,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF pulseGen_bd_pulseGen_0_0_arch: ARCHITECTURE IS "pulseGen_bd_pulseGen_0_0,pulseGen,{x_ipProduct=Vivado 2018.3,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=pulseGen,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,CHANNELS=8,COUNTER_WIDTH=24,TIMESTAMP_WIDTH=8,MASK_WIDTH=32}";
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF pulseGen_bd_pulseGen_0_0_arch: ARCHITECTURE IS "module_ref";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF streamDown_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 streamDown TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF streamDown_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 streamDown TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF streamDown_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 streamDown TVALID";
  ATTRIBUTE X_INTERFACE_PARAMETER OF streamDown_tdata: SIGNAL IS "XIL_INTERFACENAME streamDown, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN pulseGen_bd_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF streamDown_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 streamDown TDATA";
  ATTRIBUTE X_INTERFACE_PARAMETER OF resetn: SIGNAL IS "XIL_INTERFACENAME resetn, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF resetn: SIGNAL IS "xilinx.com:signal:reset:1.0 resetn RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF clk: SIGNAL IS "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF streamDown, ASSOCIATED_RESET resetn, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN pulseGen_bd_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF clk: SIGNAL IS "xilinx.com:signal:clock:1.0 clk CLK";
BEGIN
  U0 : pulseGen
    GENERIC MAP (
      CHANNELS => 8,
      COUNTER_WIDTH => 24,
      TIMESTAMP_WIDTH => 8,
      MASK_WIDTH => 32
    )
    PORT MAP (
      clk => clk,
      resetn => resetn,
      trig => trig,
      pulseDuration => pulseDuration,
      pulse => pulse,
      timestamp => timestamp,
      streamDown_tdata => streamDown_tdata,
      streamDown_tvalid => streamDown_tvalid,
      streamDown_tlast => streamDown_tlast,
      streamDown_tready => streamDown_tready,
      state => state
    );
END pulseGen_bd_pulseGen_0_0_arch;
