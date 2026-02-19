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
entity BPS_6bits is
  port(
    clkTrg  : in std_logic;
    reset   : in std_logic;
    in1     : in std_logic;
    in2     : in std_logic;
    in3     : in std_logic;
    in4     : in std_logic;
    in5     : in std_logic;
    in6     : in std_logic;
    regCtrl : in std_logic_vector(5 downto 0);
    regCoin : in std_logic_vector(5 downto 0);
    out1    : out std_logic
    );
end BPS_6bits;

-------------------------------------------------------------------------------
architecture RTL of BPS_6bits is
  --  attribute keep : string;
  signal bit_pattern : std_logic_vector(5 downto 0);
  signal sig_out1    : std_logic;
  --   attribute keep of bit_pattern   :signal is "true";

begin
  bit_pattern(5) <= in1 when (regCtrl(5) ='1') else '0';
  bit_pattern(4) <= in2 when (regCtrl(4) ='1') else '0';
  bit_pattern(3) <= in3 when (regCtrl(3) ='1') else '0';
  bit_pattern(2) <= in4 when (regCtrl(2) ='1') else '0';
  bit_pattern(1) <= in5 when (regCtrl(1) ='1') else '0';
  bit_pattern(0) <= in6 when (regCtrl(0) ='1') else '0';

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
