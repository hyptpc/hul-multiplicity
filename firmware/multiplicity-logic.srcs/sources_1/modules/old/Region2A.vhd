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
entity Region2 is
  port(
    clkTrg : in std_logic;
    clkSys : in std_logic;
    reset  : in std_logic;
    -- inputs --
    inBH1    : in std_logic;
    inBH2    : in std_logic;
    inBAC    : in std_logic;
    inHTOF   : in std_logic;
    inOther1 : in std_logic;
    inOther2 : in std_logic;
    -- probe points --
    outBH1    : out std_logic;
    outBH2    : out std_logic;
    outBAC    : out std_logic;
    outHTOF   : out std_logic;
    outOther1 : out std_logic;
    outOther2 : out std_logic;
    outBeam   : out std_logic;
    -- Local bus --
    addrLocalBus    : in LocalAddressType;
    dataLocalBusIn  : in LocalBusInType;
    dataLocalBusOut : out LocalBusOutType;
    reLocalBus      : in std_logic;
    weLocalBus      : in std_logic;
    readyLocalBus   : out std_logic
    );
end Region2;

-------------------------------------------------------------------------------
architecture RTL of Region2 is
  --  attribute keep : string;
  signal state_lbus       : BusProcessType;
  -- Beam --
  signal reg_delay_bh1    : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_bh2    : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_bac    : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_htof   : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_other1 : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_other2 : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_width_bh1    : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_bh2    : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_bac    : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_htof   : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_other1 : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_other2 : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_ctrl_beam    : std_logic_vector(kNumOfInputsBeam-1 downto 0);
  signal reg_coin_beam    : std_logic_vector(kNumOfInputsBeam-1 downto 0);
  -- Modules  -------------------------------------------------------------
  component BeamSelector is
    port (
      clkTrg         : in std_logic;
      clkSys         : in std_logic;
      reset          : in std_logic;
      inBH1          : in std_logic;
      inBH2          : in std_logic;
      inBAC          : in std_logic;
      inHTOF         : in std_logic;
      inOther1       : in std_logic;
      inOther2       : in std_logic;
      outBH1         : out std_logic;
      outBH2         : out std_logic;
      outBAC         : out std_logic;
      outHTOF        : out std_logic;
      outOther1      : out std_logic;
      outOther2      : out std_logic;
      outBeam        : out std_logic;
      regDelayBH1    : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayBH2    : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayBAC    : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayHTOF   : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayOther1 : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayOther2 : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regWidthBH1    : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthBH2    : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthBAC    : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthHTOF   : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthOther1 : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthOther2 : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regCtrl        : in std_logic_vector(kNumOfInputsBeam-1 downto 0);
      regCoin        : in std_logic_vector(kNumOfInputsBeam-1 downto 0)
     );
  end component;

-------------------------------------------------------------------------------
begin
  BeamSelectorInst : BeamSelector
    port map (
      clkTrg         => clkTrg,
      clkSys         => clkSys,
      reset          => reset,
      inBH1          => inBH1,
      inBH2          => inBH2,
      inBAC          => inBAC,
      inHTOF         => inHTOF,
      inOther1       => inOther1,
      inOther2       => inOther2,
      outBH1         => outBH1,
      outBH2         => outBH2,
      outBAC         => outBAC,
      outHTOF        => outHTOF,
      outOther1      => outOther1,
      outOther2      => outOther2,
      outBeam        => outBeam,
      regDelayBH1    => reg_delay_bh1,
      regDelayBH2    => reg_delay_bh2,
      regDelayBAC    => reg_delay_bac,
      regDelayHTOF   => reg_delay_htof,
      regDelayOther1 => reg_delay_other1,
      regDelayOther2 => reg_delay_other2,
      regWidthBH1    => reg_width_bh1,
      regWidthBH2    => reg_width_bh2,
      regWidthBAC    => reg_width_bac,
      regWidthHTOF   => reg_width_htof,
      regWidthOther1 => reg_width_other1,
      regWidthOther2 => reg_width_other2,
      regCtrl        => reg_ctrl_beam,
      regCoin        => reg_coin_beam
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
          reg_delay_bh1    <= (others => '1');
          reg_delay_bh2    <= (others => '1');
          reg_delay_bac    <= (others => '1');
          reg_delay_htof   <= (others => '1');
          reg_delay_other1 <= (others => '1');
          reg_delay_other2 <= (others => '1');
          reg_width_bh1    <= (others => '1');
          reg_width_bh2    <= (others => '1');
          reg_width_bac    <= (others => '1');
          reg_width_htof   <= (others => '1');
          reg_width_other1 <= (others => '1');
          reg_width_other2 <= (others => '1');
          reg_ctrl_beam    <= (others => '1');
          reg_coin_beam    <= (others => '1');
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
            when kDLY_BH1_BEAM =>
              reg_delay_bh1 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_BH2_BEAM =>
              reg_delay_bh2 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_BAC_BEAM =>
              reg_delay_bac <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_HTOF_BEAM =>
              reg_delay_htof <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_OTH1_BEAM =>
              reg_delay_other1 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kDLY_OTH2_BEAM =>
              reg_delay_other2 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kPWM_BH1_BEAM =>
              reg_width_bh1 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_BH2_BEAM =>
              reg_width_bh2 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_BAC_BEAM =>
              reg_width_bac <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_HTOF_BEAM =>
              reg_width_htof <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_OTH1_BEAM =>
              reg_width_other1 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kPWM_OTH2_BEAM =>
              reg_width_other2 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kBPS_CTRL_BEAM =>
              reg_ctrl_beam <= dataLocalBusIn(kNumOfInputsBeam-1 downto 0);
            when kBPS_COIN_BEAM =>
              reg_coin_beam <= dataLocalBusIn(kNumOfInputsBeam-1 downto 0);
            when others =>
              null;
          end case;
          state_lbus <= Done;
        when Read =>
          case addrLocalBus is
            when kDLY_BH1_BEAM =>
              dataLocalBusOut <= reg_delay_bh1;
            when kDLY_BH2_BEAM =>
              dataLocalBusOut <= reg_delay_bh2;
            when kDLY_BAC_BEAM =>
              dataLocalBusOut <= reg_delay_bac;
            when kDLY_HTOF_BEAM =>
              dataLocalBusOut <= reg_delay_htof;
            when kDLY_OTH1_BEAM =>
              dataLocalBusOut <= reg_delay_other1;
            when kDLY_OTH2_BEAM =>
              dataLocalBusOut <= reg_delay_other2;
            when kPWM_BH1_BEAM =>
              dataLocalBusOut <= reg_width_bh1;
            when kPWM_BH2_BEAM =>
              dataLocalBusOut <= reg_width_bh2;
            when kPWM_BAC_BEAM =>
              dataLocalBusOut <= reg_width_bac;
            when kPWM_HTOF_BEAM =>
              dataLocalBusOut <= reg_width_htof;
            when kPWM_OTH1_BEAM =>
              dataLocalBusOut <= reg_width_other1;
            when kPWM_OTH2_BEAM =>
              dataLocalBusOut <= reg_width_other2;
            when kBPS_CTRL_BEAM =>
              dataLocalBusOut <= "00" & reg_ctrl_beam;
            when kBPS_COIN_BEAM =>
              dataLocalBusOut <= "00" & reg_coin_beam;
            when others =>
              dataLocalBusOut <= x"ff";
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
