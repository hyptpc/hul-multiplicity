-- -*- vhdl -*-

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
entity MezzanineNetAssign is
  port (
    in_mzn_u  : in std_logic_vector(31 downto 0);
    in_mzn_d  : in std_logic_vector(31 downto 0);
    out_mzn_u : out std_logic_vector(31 downto 0);
    out_mzn_d : out std_logic_vector(31 downto 0)
    );
end MezzanineNetAssign;

-------------------------------------------------------------------------------
architecture RTL of MezzanineNetAssign is

begin

  out_mzn_u( 0) <= in_mzn_u(0);
  out_mzn_u( 1) <= in_mzn_u(1);
  out_mzn_u( 2) <= in_mzn_u(2);
  out_mzn_u( 3) <= in_mzn_u(3);
  out_mzn_u( 4) <= in_mzn_u(4);
  out_mzn_u( 5) <= in_mzn_u(5);
  out_mzn_u( 6) <= in_mzn_u(6);
  out_mzn_u( 7) <= in_mzn_u(7);
  out_mzn_u( 8) <= in_mzn_u(8);
  out_mzn_u( 9) <= NOT in_mzn_u(9);
  out_mzn_u(10) <= in_mzn_u(10);
  out_mzn_u(11) <= in_mzn_u(11);
  out_mzn_u(12) <= in_mzn_u(12);
  out_mzn_u(13) <= in_mzn_u(13);
  out_mzn_u(14) <= NOT in_mzn_u(14);
  out_mzn_u(15) <= NOT in_mzn_u(15);
  out_mzn_u(16) <= in_mzn_u(16);
  out_mzn_u(17) <= in_mzn_u(17);
  out_mzn_u(18) <= in_mzn_u(18);
  out_mzn_u(19) <= in_mzn_u(19);
  out_mzn_u(20) <= in_mzn_u(20);
  out_mzn_u(21) <= in_mzn_u(21);
  out_mzn_u(22) <= in_mzn_u(22);
  out_mzn_u(23) <= in_mzn_u(23);
  out_mzn_u(24) <= in_mzn_u(24);
  out_mzn_u(25) <= NOT in_mzn_u(25);
  out_mzn_u(26) <= NOT in_mzn_u(26);
  out_mzn_u(27) <= in_mzn_u(27);
  out_mzn_u(28) <= NOT in_mzn_u(28);
  out_mzn_u(29) <= NOT in_mzn_u(29);
  out_mzn_u(30) <= in_mzn_u(30);
  out_mzn_u(31) <= in_mzn_u(31);

  out_mzn_d( 0) <= NOT in_mzn_d(0);
  out_mzn_d( 1) <= NOT in_mzn_d(1);
  out_mzn_d( 2) <= NOT in_mzn_d(2);
  out_mzn_d( 3) <= NOT in_mzn_d(3);
  out_mzn_d( 4) <= in_mzn_d(4);
  out_mzn_d( 5) <= in_mzn_d(5);
  out_mzn_d( 6) <= in_mzn_d(6);
  out_mzn_d( 7) <= in_mzn_d(7);
  out_mzn_d( 8) <= in_mzn_d(8);
  out_mzn_d( 9) <= in_mzn_d(9);
  out_mzn_d(10) <= in_mzn_d(10);
  out_mzn_d(11) <= in_mzn_d(11);
  out_mzn_d(12) <= in_mzn_d(12);
  out_mzn_d(13) <= in_mzn_d(13);
  out_mzn_d(14) <= in_mzn_d(14);
  out_mzn_d(15) <= in_mzn_d(15);
  out_mzn_d(16) <= in_mzn_d(16);
  out_mzn_d(17) <= in_mzn_d(17);
  out_mzn_d(18) <= in_mzn_d(18);
  out_mzn_d(19) <= in_mzn_d(19);
  out_mzn_d(20) <= in_mzn_d(20);
  out_mzn_d(21) <= in_mzn_d(21);
  out_mzn_d(22) <= in_mzn_d(22);
  out_mzn_d(23) <= in_mzn_d(23);
  out_mzn_d(24) <= in_mzn_d(24);
  out_mzn_d(25) <= NOT in_mzn_d(25);
  out_mzn_d(26) <= in_mzn_d(26);
  out_mzn_d(27) <= in_mzn_d(27);
  out_mzn_d(28) <= in_mzn_d(28);
  out_mzn_d(29) <= in_mzn_d(29);
  out_mzn_d(30) <= in_mzn_d(30);
  out_mzn_d(31) <= in_mzn_d(31);
end RTL;
