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
entity BPS_8bits is
  port(
    clk_trg  : in std_logic;
    reset    : in std_logic;
    in1      : in std_logic;
    in2      : in std_logic;
    in3      : in std_logic;
    in4      : in std_logic;
    in5      : in std_logic;
    in6      : in std_logic;
    in7      : in std_logic;
    in8      : in std_logic;
    reg_ctrl : in std_logic_vector(7 downto 0);
    reg_coin : in std_logic_vector(7 downto 0);
    out_1    : out std_logic
    );
end BPS_8bits;

-------------------------------------------------------------------------------
architecture RTL of BPS_8bits is
  attribute keep : string;
  constant NbitOut  : positive := 8;
  signal state_lbus : BusProcessType;
  signal sig_in1    : std_logic;
  signal sig_in2    : std_logic;
  signal sig_in3    : std_logic;
  signal sig_in4    : std_logic;
  signal sig_in5    : std_logic;
  signal sig_in6    : std_logic;
  signal sig_in7    : std_logic;
  signal sig_in8    : std_logic;
  signal BitPattern : std_logic_vector(NbitOut-1 downto 0);
  signal sig_out1   : std_logic;
  -- attribute keep of BitPattern   :signal is "true";

begin
  sig_in1 <= in1;
  sig_in2 <= in2;
  sig_in3 <= in3;
  sig_in4 <= in4;
  sig_in5 <= in5;
  sig_in6 <= in6;
  sig_in7 <= in7;
  sig_in8 <= in8;

  BitPattern(7) <= sig_in1 when (reg_ctrl(7) = '1') else '0';
  BitPattern(6) <= sig_in2 when (reg_ctrl(6) = '1') else '0';
  BitPattern(5) <= sig_in3 when (reg_ctrl(5) = '1') else '0';
  BitPattern(4) <= sig_in4 when (reg_ctrl(4) = '1') else '0';
  BitPattern(3) <= sig_in5 when (reg_ctrl(3) = '1') else '0';
  BitPattern(2) <= sig_in6 when (reg_ctrl(2) = '1') else '0';
  BitPattern(1) <= sig_in7 when (reg_ctrl(1) = '1') else '0';
  BitPattern(0) <= sig_in8 when (reg_ctrl(0) = '1') else '0';

  sig_out1 <= '1' when (BitPattern = reg_coin) else '0';

  process(clk_trg, reset)
  begin
    if (reset = '1') then
      out_1 <= '0';
    elsif (clk_trg'event and clk_trg='1') then
      out_1 <= sig_out1;
    end if;
  end process;
end RTL;
