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

-- IP VLNV: xilinx.com:module_ref:pulseAcq:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pulseAcq_bd_pulseAcq_0_0 IS
  PORT (
    clk : IN STD_LOGIC;
    resetn : IN STD_LOGIC;
    counterMax : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    trig : IN STD_LOGIC;
    pulse : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    timestamp : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    streamUp_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    streamUp_tvalid : OUT STD_LOGIC;
    streamUp_tlast : OUT STD_LOGIC;
    streamUp_tready : IN STD_LOGIC;
    state : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    streamUpCounter : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
  );
END pulseAcq_bd_pulseAcq_0_0;

ARCHITECTURE pulseAcq_bd_pulseAcq_0_0_arch OF pulseAcq_bd_pulseAcq_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF pulseAcq_bd_pulseAcq_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT pulseAcq IS
    GENERIC (
      CHANNELS : INTEGER;
      COUNTER_WIDTH : INTEGER;
      TIMESTAMP_WIDTH : INTEGER;
      MASK_WIDTH : INTEGER
    );
    PORT (
      clk : IN STD_LOGIC;
      resetn : IN STD_LOGIC;
      counterMax : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      trig : IN STD_LOGIC;
      pulse : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      timestamp : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      streamUp_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      streamUp_tvalid : OUT STD_LOGIC;
      streamUp_tlast : OUT STD_LOGIC;
      streamUp_tready : IN STD_LOGIC;
      state : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      streamUpCounter : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
    );
  END COMPONENT pulseAcq;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF pulseAcq_bd_pulseAcq_0_0_arch: ARCHITECTURE IS "pulseAcq,Vivado 2018.3";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF pulseAcq_bd_pulseAcq_0_0_arch : ARCHITECTURE IS "pulseAcq_bd_pulseAcq_0_0,pulseAcq,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF pulseAcq_bd_pulseAcq_0_0_arch: ARCHITECTURE IS "pulseAcq_bd_pulseAcq_0_0,pulseAcq,{x_ipProduct=Vivado 2018.3,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=pulseAcq,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,CHANNELS=8,COUNTER_WIDTH=24,TIMESTAMP_WIDTH=8,MASK_WIDTH=32}";
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF pulseAcq_bd_pulseAcq_0_0_arch: ARCHITECTURE IS "module_ref";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF streamUp_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 streamUp TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF streamUp_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 streamUp TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF streamUp_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 streamUp TVALID";
  ATTRIBUTE X_INTERFACE_PARAMETER OF streamUp_tdata: SIGNAL IS "XIL_INTERFACENAME streamUp, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF streamUp_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 streamUp TDATA";
  ATTRIBUTE X_INTERFACE_PARAMETER OF resetn: SIGNAL IS "XIL_INTERFACENAME resetn, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF resetn: SIGNAL IS "xilinx.com:signal:reset:1.0 resetn RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF clk: SIGNAL IS "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF streamUp, ASSOCIATED_RESET resetn, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF clk: SIGNAL IS "xilinx.com:signal:clock:1.0 clk CLK";
BEGIN
  U0 : pulseAcq
    GENERIC MAP (
      CHANNELS => 8,
      COUNTER_WIDTH => 24,
      TIMESTAMP_WIDTH => 8,
      MASK_WIDTH => 32
    )
    PORT MAP (
      clk => clk,
      resetn => resetn,
      counterMax => counterMax,
      trig => trig,
      pulse => pulse,
      timestamp => timestamp,
      streamUp_tdata => streamUp_tdata,
      streamUp_tvalid => streamUp_tvalid,
      streamUp_tlast => streamUp_tlast,
      streamUp_tready => streamUp_tready,
      state => state,
      streamUpCounter => streamUpCounter
    );
END pulseAcq_bd_pulseAcq_0_0_arch;
