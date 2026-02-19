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
entity Region2_1 is
  port(
    clk_trg            : in  std_logic;
    clk_sys            : in  std_logic;
    reset              : in  std_logic;
    -- inputs --
    inBH1           : in std_logic;
    inBH2           : in std_logic;
    inBAC           : in std_logic;
    inHTOF          : in std_logic;
    inOther1        : in std_logic;
    inOther2        : in std_logic;
    -- probe points --
    outBH1          : out std_logic;
    outBH2          : out std_logic;
    outBAC          : out std_logic;
    outHTOF         : out std_logic;
    outOther1       : out std_logic;
    outOther2       : out std_logic;
    -- out --
    outR21             : out std_logic;
    -- Local bus --
    addrLocalBus       : in LocalAddressType;
    dataLocalBusIn     : in LocalBusInType;
    dataLocalBusOut    : out LocalBusOutType;
    reLocalBus         : in std_logic;
    weLocalBus         : in std_logic;
    readyLocalBus      : out std_logic
    );
end Region2_1;

architecture RTL of Region2_1 is
  --  attribute keep : string;

  -- other signal -------------------------------------------------------------
  constant NbitOut           : positive := 5;
  constant NbitOut_2           : positive := 2;
  constant NbitOut_7           : positive := 7;
  constant NbitOut_8           : positive := 8;
  signal state_lbus          : BusProcessType;

  -- inner signal -------------------------------------------------------------
  signal sig_BEAM           : std_logic;
  signal in_SAC_or_R21           : std_logic;
  signal in_TOF_or_R21           : std_logic;
  signal in_LC_or_R21            : std_logic;
  signal in_TOF_HT_R21           : std_logic;
-- signal in_Matrix_3D_R21        : std_logic;
  signal in_Other4_R21           : std_logic;
  signal in_Other5_R21           : std_logic;

  -- For DPWM ------------------------------------------------------------
  -- For Delay --
  signal reg_delay_BH2_Pi           : std_logic_vector(NbitOut-1 downto 0);
  signal reg_delay_SAC_or           : std_logic_vector(NbitOut-1 downto 0);
  signal reg_delay_TOF_or           : std_logic_vector(NbitOut-1 downto 0);
  signal reg_delay_LC_or            : std_logic_vector(NbitOut-1 downto 0);
  signal reg_delay_TOF_HT           : std_logic_vector(NbitOut-1 downto 0);
-- signal reg_delay_Matrix_3D        : std_logic_vector(NbitOut-1 downto 0);
  signal reg_delay_Other4           : std_logic_vector(NbitOut-1 downto 0);
  signal reg_delay_Other5           : std_logic_vector(NbitOut-1 downto 0);


  -- For PWM --
  signal reg_counter_BH2_Pi           : std_logic_vector(NbitOut-1 downto 0);
  signal reg_counter_SAC_or           : std_logic_vector(NbitOut-1 downto 0);
  signal reg_counter_TOF_or           : std_logic_vector(NbitOut-1 downto 0);
  signal reg_counter_LC_or            : std_logic_vector(NbitOut-1 downto 0);
  signal reg_counter_TOF_HT           : std_logic_vector(NbitOut-1 downto 0);
-- signal reg_counter_Matrix_3D        : std_logic_vector(NbitOut-1 downto 0);
  signal reg_counter_Other4           : std_logic_vector(NbitOut-1 downto 0);
  signal reg_counter_Other5           : std_logic_vector(NbitOut-1 downto 0);

  -- For BPS --------------------------------------------------------------
  signal reg_ctrl_7  : std_logic_vector(NbitOut_7-1 downto 0);
  signal reg_coin_7  : std_logic_vector(NbitOut_7-1 downto 0);

  -- Modules  -------------------------------------------------------------
  component DPWM is
    port(
      clkTrg     : in std_logic;
      reset      : in std_logic;
      in1        : in std_logic;
      regDelay   : in std_logic_vector(4 downto 0);
      regCounter : in std_logic_vector(4 downto 0);
      out1       : out std_logic
      );
  end component;

  component BPS_7bits is
    port(
      -- input signal --
      clkTrg  : in std_logic;
      reset   : in std_logic;
      in1     : in std_logic;
      in2     : in std_logic;
      in3     : in std_logic;
      in4     : in std_logic;
      in5     : in std_logic;
      in6     : in std_logic;
      in7     : in std_logic;
      regCtrl : in std_logic_vector(6 downto 0);
      regCoin : in std_logic_vector(6 downto 0);
      -- output signal --
      out1    : out std_logic
      );
  end component;

begin
  out_BEAM_R21 <= sig_BEAM;
  SAC_or_R21   <=  in_SAC_or_R21;
  TOF_or_R21   <=  in_TOF_or_R21;
  LC_or_R21    <=  in_LC_or_R21;
  TOF_HT_R21   <=  in_TOF_HT_R21;
  Other4_R21   <=  in_Other4_R21;
  Other5_R21   <=  in_Other5_R21;

  -- DPWM ---------------------------------------------------------------------------
  BH2_Pi_Inst : DPWM
    port map(
      clkTrg     => clk_trg,
      reset      => reset,
      in1        => in_BEAM,
      regDelay   => reg_delay_BH2_Pi,
      regCounter => reg_counter_BH2_Pi,
      out1       => sig_BEAM
      );

  SAC_or_Inst : DPWM
    port map(
      clkTrg      => clk_trg,
      reset       => reset,
      in1         => SAC_or,
      regDelay   => reg_delay_SAC_or,
      regCounter => reg_counter_SAC_or,
      out1        => in_SAC_or_R21
      );

  TOF_or_Inst : DPWM
    port map(
      clkTrg      => clk_trg,
      reset       => reset,
      in1         => TOF_or,
      regDelay   => reg_delay_TOF_or,
      regCounter => reg_counter_TOF_or,
      out1        => in_TOF_or_R21
      );

  Lucite_or_Inst : DPWM
    port map(
      clkTrg      => clk_trg,
      reset       => reset,
      in1         => Lucite_or,
      regDelay   => reg_delay_LC_or,
      regCounter => reg_counter_LC_or,
      out1        => in_LC_or_R21
      );

  TOF_High_Threshold_Inst : DPWM
    port map(
      clkTrg      => clk_trg,
      reset       => reset,
      in1         => TOF_High_Threshold,
      regDelay   => reg_delay_TOF_HT,
      regCounter => reg_counter_TOF_HT,
      out1        => in_TOF_HT_R21
      );

--  Matrix_3D_Inst : DPWM
-- port map(
--     reset             => reset    ,
--     clkTrg         => clk_trg,
--
--     -- input signal --
--     in1             =>Matrix_3D        ,
--     regDelay       =>reg_delay_Matrix_3D  ,
--     regCounter     =>reg_counter_Matrix_3D,
--     -- output signal
--     out1            =>in_Matrix_3D_R21
-- );

  Other4_Inst : DPWM
    port map(
      clkTrg      => clk_trg,
      reset       => reset,
      in1         => Other4,
      regDelay   => reg_delay_Other4,
      regCounter => reg_counter_Other4,
      out1        => in_Other4_R21
      );

  Other5_Inst : DPWM
    port map(
      clkTrg      => clk_trg,
      reset       => reset,
      in1         => Other5,
      regDelay   => reg_delay_Other5,
      regCounter => reg_counter_Other5,
      out1        => in_Other5_R21
      );

  -- BPS ----------------------------------------------------------------------
  R21_BPS_Inst : BPS_7bits
    port map(
      clkTrg  => clk_trg,
      reset   => reset,
      in1     => sig_BEAM,
      in2     => in_SAC_or_R21,
      in3     => in_TOF_or_R21,
      in4     => in_LC_or_R21,
      in5     => in_TOF_HT_R21,
      in6     => in_Other4_R21,
      in7     => in_Other5_R21,
      regCtrl => reg_ctrl_7,
      regCoin => reg_coin_7,
      out1    => outR21
      );

  -- Bus process --------------------------------------------------------------
  u_BusProcess : process (clk_sys, reset)
  begin
    if (reset = '1') then
      state_lbus <= Init;
    elsif (clk_sys'event and clk_sys='1') then
      case state_lbus is
        when Init =>
          dataLocalBusOut          <= x"00";
          readyLocalBus            <= '0';
          reg_delay_BH2_Pi         <= (others => '1');
          reg_delay_SAC_or         <= (others => '1');
          reg_delay_TOF_or         <= (others => '1');
          reg_delay_LC_or          <= (others => '1');
          reg_delay_TOF_HT         <= (others => '1');
--   reg_delay_Matrix_3D      <= (others => '1');
          reg_delay_Other4         <= (others => '1');
          reg_delay_Other5         <= (others => '1');
          reg_counter_BH2_Pi       <= (others => '1');
          reg_counter_SAC_or       <= (others => '1');
          reg_counter_TOF_or       <= (others => '1');
          reg_counter_LC_or        <= (others => '1');
          reg_counter_TOF_HT       <= (others => '1');
--   reg_counter_Matrix_3D    <= (others => '1');
          reg_counter_Other4       <= (others => '1');
          reg_counter_Other5       <= (others => '1');
          reg_ctrl_7               <= (others => '1');
          reg_coin_7               <= (others => '1');
          state_lbus               <= Idle;
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
            when DLY_BH2_Pi =>
              reg_delay_BH2_Pi <= dataLocalBusIn(NbitOut-1 downto 0);
            when DLY_SAC_or =>
              reg_delay_SAC_or <= dataLocalBusIn(NbitOut-1 downto 0);
            when DLY_TOF_or =>
              reg_delay_TOF_or <= dataLocalBusIn(NbitOut-1 downto 0);
            when DLY_LC_or  =>
              reg_delay_LC_or  <= dataLocalBusIn(NbitOut-1 downto 0);
            when DLY_TOF_HT =>
              reg_delay_TOF_HT <= dataLocalBusIn(NbitOut-1 downto 0);
            -- when DLY_Matrix_3D =>
            --   reg_delay_Matrix_3D <= dataLocalBusIn(NbitOut-1 downto 0);
            when DLY_Other4 =>
              reg_delay_Other4 <= dataLocalBusIn(NbitOut-1 downto 0);
            when DLY_Other5 =>
              reg_delay_Other5 <= dataLocalBusIn(NbitOut-1 downto 0);
            when PWM_BH2_Pi =>
              reg_counter_BH2_Pi <= dataLocalBusIn(NbitOut-1 downto 0);
            when PWM_SAC_or =>
              reg_counter_SAC_or <= dataLocalBusIn(NbitOut-1 downto 0);
            when PWM_TOF_or =>
              reg_counter_TOF_or <= dataLocalBusIn(NbitOut-1 downto 0);
            when PWM_LC_or =>
              reg_counter_LC_or <= dataLocalBusIn(NbitOut-1 downto 0);
            when PWM_TOF_HT =>
              reg_counter_TOF_HT <= dataLocalBusIn(NbitOut-1 downto 0);
            -- when PWM_Matrix_3D =>
            --   reg_counter_Matrix_3D <= dataLocalBusIn(NbitOut-1 downto 0);
            when PWM_Other4 =>
              reg_counter_Other4 <= dataLocalBusIn(NbitOut-1 downto 0);
            when PWM_Other5 =>
              reg_counter_Other5 <= dataLocalBusIn(NbitOut-1 downto 0);
            when BPS_ctrl_7 =>
              reg_ctrl_7 <= dataLocalBusIn(NbitOut_7-1 downto 0);
            when BPS_coin_7 =>
              reg_coin_7 <= dataLocalBusIn(NbitOut_7-1 downto 0);
            when others => null;
          end case;
          state_lbus <= Done;
        when Read =>
          case addrLocalBus is
            when DLY_BH2_Pi => dataLocalBusOut <= "000" & reg_delay_BH2_Pi;
            when DLY_SAC_or => dataLocalBusOut <= "000" & reg_delay_SAC_or;
            when DLY_TOF_or => dataLocalBusOut <= "000" & reg_delay_TOF_or;
            when DLY_LC_or  => dataLocalBusOut <= "000" & reg_delay_LC_or;
            when DLY_TOF_HT => dataLocalBusOut <= "000" & reg_delay_TOF_HT;
            -- when DLY_Matrix_3D => dataLocalBusOut <= "000" & reg_delay_Matrix_3D;
            when DLY_Other4 => dataLocalBusOut <= "000" & reg_delay_Other4;
            when DLY_Other5 => dataLocalBusOut <= "000" & reg_delay_Other5;
            when PWM_BH2_Pi => dataLocalBusOut <= "000" & reg_counter_BH2_Pi;
            when PWM_SAC_or => dataLocalBusOut <= "000" & reg_counter_SAC_or;
            when PWM_TOF_or => dataLocalBusOut <= "000" & reg_counter_TOF_or;
            when PWM_LC_or  => dataLocalBusOut <= "000" & reg_counter_LC_or;
            when PWM_TOF_HT => dataLocalBusOut <= "000" & reg_counter_TOF_HT;
            -- when PWM_Matrix_3D => dataLocalBusOut <= "000" & reg_counter_Matrix_3D;
            when PWM_Other4 => dataLocalBusOut <= "000" & reg_counter_Other4;
            when PWM_Other5 => dataLocalBusOut <= "000" & reg_counter_Other5;
            when BPS_ctrl_7 => dataLocalBusOut <= "0" & reg_ctrl_7;
            when BPS_coin_7 => dataLocalBusOut <= "0" & reg_coin_7;
            when others => dataLocalBusOut <= x"ff";
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
