-- -*- vhdl -*-

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity BPS_10bits is
  port(
    clkTrg  : in std_logic;
    reset   : in std_logic;
    in1     : in std_logic;
    in2     : in std_logic;
    in3     : in std_logic;
    in4     : in std_logic;
    in5     : in std_logic;
    in6     : in std_logic;
    in7     : in std_logic;
    in8     : in std_logic;
    in9     : in std_logic;
    in10    : in std_logic;
    regCtrl : in std_logic_vector(9 downto 0);
    regCoin : in std_logic_vector(9 downto 0);
    out1    : out std_logic
    );
end BPS_10bits;

-------------------------------------------------------------------------------
architecture RTL of BPS_10bits is
  attribute keep : string;
  signal state_lbus  : BusProcessType;
  signal sig_in1     : std_logic;
  signal sig_in2     : std_logic;
  signal sig_in3     : std_logic;
  signal sig_in4     : std_logic;
  signal sig_in5     : std_logic;
  signal sig_in6     : std_logic;
  signal sig_in7     : std_logic;
  signal sig_in8     : std_logic;
  signal sig_in9     : std_logic;
  signal sig_in10    : std_logic;
  signal bit_pattern : std_logic_vector(9 downto 0);
  signal sig_out1    : std_logic;
  -- attribute keep of bit_pattern   :signal is "true";

begin
  sig_in1  <= in1;
  sig_in2  <= in2;
  sig_in3  <= in3;
  sig_in4  <= in4;
  sig_in5  <= in5;
  sig_in6  <= in6;
  sig_in7  <= in7;
  sig_in8  <= in8;
  sig_in9  <= in9;
  sig_in10 <= in10;

  bit_pattern(9) <= sig_in1  when (regCtrl(9) = '1') else '0';
  bit_pattern(8) <= sig_in2  when (regCtrl(8) = '1') else '0';
  bit_pattern(7) <= sig_in3  when (regCtrl(7) = '1') else '0';
  bit_pattern(6) <= sig_in4  when (regCtrl(6) = '1') else '0';
  bit_pattern(5) <= sig_in5  when (regCtrl(5) = '1') else '0';
  bit_pattern(4) <= sig_in6  when (regCtrl(4) = '1') else '0';
  bit_pattern(3) <= sig_in7  when (regCtrl(3) = '1') else '0';
  bit_pattern(2) <= sig_in8  when (regCtrl(2) = '1') else '0';
  bit_pattern(1) <= sig_in9  when (regCtrl(1) = '1') else '0';
  bit_pattern(0) <= sig_in10 when (regCtrl(0) = '1') else '0';

  sig_out1 <= '1' when (bit_pattern = regCoin) else '0';

  process(clkTrg, reset)
  begin
    if (reset = '1') then
      out1 <= '0';
    elsif (clkTrg'event and clkTrg='1') then
      out1 <= sig_out1;
    end if;
  end process;
end RTL;
