-- -*- vhdl -*-

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;
use mylib.userfunctions.all;

library unisim;
use unisim.vcomponents.all;

-------------------------------------------------------------------------------
entity Multiplexer is
  port(
    clkTrg   : in std_logic;
    clkSys   : in std_logic;
    reset    : in std_logic;
    inDet    : in std_logic_vector(kNumOfSegDetector-1 downto 0);
    regMul   : in std_logic_vector(kMultiplicityRegSize-1 downto 0);
    regWidth : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
    outDet   : out std_logic
    );
end Multiplexer;

-------------------------------------------------------------------------------
architecture RTL of Multiplexer is
  --  attribute keep : string;
  signal state_lbus : BusProcessType;
  signal det_multiplexed : std_logic;
  -- PWM --
  component PWM is
    port(
      clkTrg   : in std_logic;
      reset    : in std_logic;
      in1      : in std_logic;
      regWidth : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      out1     : out std_logic
      );
  end component;

begin
  u_PWM : PWM
    port map (
      clkTrg   => clkTrg,
      reset    => reset,
      in1      => det_multiplexed,
      regWidth => regWidth,
      out1     => outDet
      );

  u_MultiplexProcess : process (clkTrg, reset)
  begin
    if reset = '1' then
      det_multiplexed <= '0';
    elsif (clkTrg'event and clkTrg = '1') then
      if (count_bits(inDet) >= to_integer(unsigned(regMul))) then
        det_multiplexed <= '1';
      else
        det_multiplexed <= '0';
      end if;
    end if;
  end process;
end RTL;
