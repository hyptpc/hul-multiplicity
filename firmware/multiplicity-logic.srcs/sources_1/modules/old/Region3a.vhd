-- -*- vhdl -*-

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

library unisim;
use unisim.vcomponents.all;

-------------------------------------------------------------------------------
entity Region3 is
  port(
    clkTrg : in std_logic;
    clkSys : in std_logic;
    reset  : in std_logic;
    -- inputs --
    inBeam   : in std_logic;
    inPvac   : in std_logic;
    inFac    : in std_logic;
    inTof    : in std_logic;
    inLac    : in std_logic;
    inWc     : in std_logic;
    inMtx2d1 : in std_logic;
    inMtx2d2 : in std_logic;
    inMtx3d  : in std_logic;
    inOther3 : in std_logic;
    inOther4 : in std_logic;
    -- probe points --
    outBeam   : out std_logic;
    outPvac   : out std_logic;
    outFac    : out std_logic;
    outTof    : out std_logic;
    outLac    : out std_logic;
    outWc     : out std_logic;
    outMtx2d1 : out std_logic;
    outMtx2d2 : out std_logic;
    outMtx3d  : out std_logic;
    outOther3 : out std_logic;
    outOther4 : out std_logic;
    outScat   : out std_logic;
    -- Local bus --
    addrLocalBus    : in LocalAddressType;
    dataLocalBusIn  : in LocalBusInType;
    dataLocalBusOut : out LocalBusOutType;
    reLocalBus      : in std_logic;
    weLocalBus      : in std_logic;
    readyLocalBus   : out std_logic
    );
end Region3;

-------------------------------------------------------------------------------
architecture RTL of Region3 is
  --  attribute keep : string;
  signal state_lbus       : BusProcessType;
  -- Beam --
  signal reg_delay_beam   : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_pvac   : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_fac    : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_tof    : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_lac    : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_wc     : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_mtx2d1 : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_mtx2d2 : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_mtx3d  : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_other3 : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_other4 : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_width_beam   : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_pvac   : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_fac    : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_tof    : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_lac    : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_wc     : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_mtx2d1 : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_mtx2d2 : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_mtx3d  : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_other3 : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_other4 : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_ctrl_scat    : std_logic_vector(kNumOfInputsScat-1 downto 0);
  signal reg_coin_scat    : std_logic_vector(kNumOfInputsScat-1 downto 0);

  -- Modules  -------------------------------------------------------------
  component ScatSelector is
    port (
      clkTrg         : in std_logic;
      clkSys         : in std_logic;
      reset          : in std_logic;
      inBeam         : in std_logic;
      inPvac         : in std_logic;
      inFac          : in std_logic;
      inTof          : in std_logic;
      inLac          : in std_logic;
      inWc           : in std_logic;
      inMtx2d1       : in std_logic;
      inMtx2d2       : in std_logic;
      inMtx3d        : in std_logic;
      inOther3       : in std_logic;
      inOther4       : in std_logic;
      outBeam        : out std_logic;
      outPvac        : out std_logic;
      outFac         : out std_logic;
      outTof         : out std_logic;
      outLac         : out std_logic;
      outWc          : out std_logic;
      outMtx2d1      : out std_logic;
      outMtx2d2      : out std_logic;
      outMtx3d       : out std_logic;
      outOther3      : out std_logic;
      outOther4      : out std_logic;
      outScat        : out std_logic;
      regDelayBeam   : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayPvac   : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayFac    : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayTof    : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayLac    : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayWc     : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayMtx2d1 : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayMtx2d2 : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayMtx3d  : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayOther3 : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayOther4 : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regWidthBeam   : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthPvac   : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthFac    : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthTof    : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthLac    : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthWc     : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthMtx2d1 : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthMtx2d2 : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthMtx3d  : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthOther3 : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthOther4 : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regCtrl        : in std_logic_vector(kNumOfInputsScat-1 downto 0);
      regCoin        : in std_logic_vector(kNumOfInputsScat-1 downto 0)
      );
  end component;

-------------------------------------------------------------------------------
begin
  ScatSelectorInst : ScatSelector
    port map (
      clkTrg         => clkTrg,
      clkSys         => clkSys,
      reset          => reset,
      inBeam         => inBeam,
      inPvac         => inPvac,
      inFac          => inFac,
      inTof          => inTof,
      inLac          => inLAC,
      inWc           => inWC,
      inMtx2d1       => inMtx2d1,
      inMtx2d2       => inMtx2d2,
      inMtx3d        => inMtx3d,
      inOther3       => inOther3,
      inOther4       => inOther4,
      outBeam        => outBeam,
      outPvac        => outPvac,
      outFac         => outFac,
      outTof         => outTof,
      outLac         => outLac,
      outWc          => outWc,
      outMtx2d1      => outMtx2d1,
      outMtx2d2      => outMtx2d2,
      outMtx3d       => outMtx3d,
      outOther3      => outOther3,
      outOther4      => outOther4,
      outScat        => outScat,
      regDelayBeam   => reg_delay_beam,
      regDelayPvac   => reg_delay_pvac,
      regDelayFac    => reg_delay_fac,
      regDelayTof    => reg_delay_tof,
      regDelayLac    => reg_delay_lac,
      regDelayWc     => reg_delay_wc,
      regDelayMtx2d1 => reg_delay_mtx2d1,
      regDelayMtx2d2 => reg_delay_mtx2d2,
      regDelayMtx3d  => reg_delay_mtx3d,
      regDelayOther3 => reg_delay_other3,
      regDelayOther4 => reg_delay_other4,
      regWidthBeam   => reg_width_beam,
      regWidthPvac   => reg_width_pvac,
      regWidthFac    => reg_width_fac,
      regWidthTof    => reg_width_tof,
      regWidthLac    => reg_width_lac,
      regWidthWc     => reg_width_wc,
      regWidthMtx2d1 => reg_width_mtx2d1,
      regWidthMtx2d2 => reg_width_mtx2d2,
      regWidthMtx3d  => reg_width_mtx3d,
      regWidthOther3 => reg_width_other3,
      regWidthOther4 => reg_width_other4,
      regCtrl        => reg_ctrl_scat,
      regCoin        => reg_coin_scat
      );

  -- Bus process --------------------------------------------------------------
  u_BusProcess : process (clkSys, reset)
  begin
    if (reset = '1') then
      state_lbus <= Init;
    elsif (clkSys'event and clkSys='1') then
      case state_lbus is
        when Init =>
          dataLocalBusOut  <= x"00";
          readyLocalBus    <= '0';
          reg_delay_beam   <= (others => '1');
          reg_delay_pvac   <= (others => '1');
          reg_delay_fac    <= (others => '1');
          reg_delay_tof    <= (others => '1');
          reg_delay_lac    <= (others => '1');
          reg_delay_wc     <= (others => '1');
          reg_delay_mtx2d1 <= (others => '1');
          reg_delay_mtx2d2 <= (others => '1');
          reg_delay_mtx3d  <= (others => '1');
          reg_delay_other3 <= (others => '1');
          reg_delay_other4 <= (others => '1');
          reg_width_beam   <= (others => '1');
          reg_width_pvac   <= (others => '1');
          reg_width_fac    <= (others => '1');
          reg_width_tof    <= (others => '1');
          reg_width_lac    <= (others => '1');
          reg_width_wc     <= (others => '1');
          reg_width_mtx2d1 <= (others => '1');
          reg_width_mtx2d2 <= (others => '1');
          reg_width_mtx3d  <= (others => '1');
          reg_width_other3 <= (others => '1');
          reg_width_other4 <= (others => '1');
          reg_ctrl_scat    <= (others => '1');
          reg_coin_scat    <= (others => '1');
          state_lbus       <= Idle;
        when Idle =>
          readyLocalBus <= '0';
          if (weLocalBus = '1' or reLocalBus = '1') then
            state_lbus <= Connect;
          end if;
        when Connect =>
          if (weLocalBus = '1') then
            state_lbus <= Write;
          else
            state_lbus <= Read;
          end if;
        when Write =>
          case addrLocalBus is
            when kDLY_BEAM_SCAT =>
              reg_delay_beam <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_PVAC_SCAT =>
              reg_delay_pvac <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_FAC_SCAT =>
              reg_delay_fac <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_TOF_SCAT =>
              reg_delay_tof <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_LAC_SCAT =>
              reg_delay_lac <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_WC_SCAT =>
              reg_delay_wc <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_M2D1_SCAT =>
              reg_delay_mtx2d1 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_M2D2_SCAT =>
              reg_delay_mtx2d2 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_M3D_SCAT =>
              reg_delay_mtx3d <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_OTH3_SCAT =>
              reg_delay_other3 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_OTH4_SCAT =>
              reg_delay_other4 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kPWM_BEAM_SCAT =>
              reg_width_beam <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_PVAC_SCAT =>
              reg_width_pvac <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_FAC_SCAT =>
              reg_width_fac <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_TOF_SCAT =>
              reg_width_tof <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_LAC_SCAT =>
              reg_width_lac <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_WC_SCAT =>
              reg_width_wc <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_M2D1_SCAT =>
              reg_width_mtx2d1 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_M2D2_SCAT =>
              reg_width_mtx2d2 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_M3D_SCAT =>
              reg_width_mtx3d <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_OTH3_SCAT =>
              reg_width_other3 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_OTH4_SCAT =>
              reg_width_other4 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kBPS_CTRL_SCAT =>
              reg_ctrl_scat <= dataLocalBusIn(kNumOfInputsScat-1 downto 0);
            when kBPS_COIN_SCAT =>
              reg_coin_scat <= dataLocalBusIn(kNumOfInputsScat-1 downto 0);
            when others =>
              null;
          end case;
          state_lbus <= Done;
        when Read =>
          case addrLocalBus is
            when kDLY_BEAM_SCAT =>
              dataLocalBusOut <= reg_delay_beam;
            when kDLY_PVAC_SCAT =>
              dataLocalBusOut <= reg_delay_pvac;
            when kDLY_FAC_SCAT =>
              dataLocalBusOut <= reg_delay_fac;
            when kDLY_TOF_SCAT =>
              dataLocalBusOut <= reg_delay_tof;
            when kDLY_LAC_SCAT =>
              dataLocalBusOut <= reg_delay_lac;
            when kDLY_WC_SCAT =>
              dataLocalBusOut <= reg_delay_wc;
            when kDLY_M2D1_SCAT =>
              dataLocalBusOut <= reg_delay_mtx2d1;
            when kDLY_M2D2_SCAT =>
              dataLocalBusOut <= reg_delay_mtx2d2;
            when kDLY_M3D_SCAT =>
              dataLocalBusOut <= reg_delay_mtx3d;
            when kDLY_OTH3_SCAT =>
              dataLocalBusOut <= reg_delay_other3;
            when kDLY_OTH4_SCAT =>
              dataLocalBusOut <= reg_delay_other4;
            when kPWM_BEAM_SCAT =>
              dataLocalBusOut <= reg_width_beam;
            when kPWM_PVAC_SCAT =>
              dataLocalBusOut <= reg_width_pvac;
            when kPWM_FAC_SCAT =>
              dataLocalBusOut <= reg_width_fac;
            when kPWM_TOF_SCAT =>
              dataLocalBusOut <= reg_width_tof;
            when kPWM_LAC_SCAT =>
              dataLocalBusOut <= reg_width_lac;
            when kPWM_WC_SCAT =>
              dataLocalBusOut <= reg_width_wc;
            when kPWM_M2D1_SCAT =>
              dataLocalBusOut <= reg_width_mtx2d1;
            when kPWM_M2D2_SCAT =>
              dataLocalBusOut <= reg_width_mtx2d2;
            when kPWM_M3D_SCAT =>
              dataLocalBusOut <= reg_width_mtx3d;
            when kPWM_OTH3_SCAT =>
              dataLocalBusOut <= reg_width_other3;
            when kPWM_OTH4_SCAT =>
              dataLocalBusOut <= reg_width_other4;
            when others =>
              case addrLocalBus(11 downto 4) is
                when kBPS_CTRL_SCAT(11 downto 4) =>
                  if (addrLocalBus(1 downto 0) = "00") then
                    dataLocalBusOut <=
                      reg_ctrl_scat(kDataWidth-1 downto 0);
                  else
                    dataLocalBusOut <=
                      "00000" & reg_ctrl_scat(kNumOfInputsScat-1 downto kDataWidth);
                  end if;
                when kBPS_COIN_SCAT(11 downto 4) =>
                  if (addrLocalBus(1 downto 0) = "00") then
                    dataLocalBusOut <=
                      reg_coin_scat(kDataWidth-1 downto 0);
                  else
                    dataLocalBusOut <=
                      "00000" & reg_coin_scat(kNumOfInputsScat-1 downto kDataWidth);
                  end if;
                when others =>
                  dataLocalBusOut <= x"ff";
              end case;
          end case;
          state_lbus <= Done;
        when Done =>
          readyLocalBus <= '1';
          if (weLocalBus='0' and reLocalBus='0') then
            state_lbus <= Idle;
          end if;
        when others =>
          state_lbus <= Init;
      end case;
    end if;
  end process u_BusProcess;
end RTL;
