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
entity BPS_2bits is
  port(
    clkTrg  : in std_logic;
    reset   : in std_logic;
    in1     : in std_logic;
    in2     : in std_logic;
    regCtrl : in std_logic_vector(1 downto 0);
    regCoin : in std_logic_vector(1 downto 0);
    out1    : out std_logic
    );
end BPS_2bits;

-------------------------------------------------------------------------------
architecture RTL of BPS_2bits is
  -- attribute keep : string;
  signal state_lbus : BusProcessType;
  signal sig_in1    : std_logic;
  signal sig_in2    : std_logic;
  signal BitPattern : std_logic_vector(1 downto 0);
  signal sig_out1   : std_logic;
  -- attribute keep of BitPattern   :signal is "true";

begin
  sig_in1 <= in1;
  sig_in2 <= in2;

  BitPattern(1) <= sig_in1 when (reg_ctrl(1) = '1') else '0';
  BitPattern(0) <= sig_in2 when (reg_ctrl(0) = '1') else '0';

  sig_out1 <= '1' when (reg_coin = BitPattern) else '0';

  process(clk_trg, reset)
  begin
    if (reset = '1') then
      out1 <= '0';
    elsif (clk_trg'event and clk_trg='1') then
      out1 <= sig_out1;
    end if;
  end process;
end RTL;
