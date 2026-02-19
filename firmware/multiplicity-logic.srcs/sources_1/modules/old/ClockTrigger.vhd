-- -*- vhdl -*-

library ieee;
use ieee.std_logic_1164.all;
library mylib;
use mylib.addressmap.all;

-------------------------------------------------------------------------------
entity ClockTrigger is
  port(
    clock        : in std_logic;
    clockTrigger : out std_logic_vector(kNumOfClockTrigger-1 downto 0)
    );
end ClockTrigger;

-------------------------------------------------------------------------------
architecture RTL of ClockTrigger is

begin
  process (clock)
  begin
    if (clock'event and clock='1') then
      clockTrigger(0) <= '1';
      wait for 1sec/2;
      clockTrigger(0) <= '0';
      wait for 1sec/2;
    end if;
  end process;

  process (clock)
  begin
    if (clock'event and clock='1') then
      clockTrigger(1) <= '1';
      wait for 100ms/2;
      clockTrigger(1) <= '0';
      wait for 100ms/2;
    end if;
  end process;

  process (clock)
  begin
    if (clock'event and clock='1') then
      clockTrigger(2) <= '1';
      wait for 10ms/2;
      clockTrigger(2) <= '0';
      wait for 10ms/2;
    end if;
  end process;

  process (clock)
  begin
    if (clock'event and clock='1') then
      clockTrigger(3) <= '1';
      wait for 1ms/2;
      clockTrigger(3) <= '0';
      wait for 1ms/2;
    end if;
  end process;

  process (clock)
  begin
    if (clock'event and clock='1') then
      clockTrigger(4) <= '1';
      wait for 100us/2;
      clockTrigger(4) <= '0';
      wait for 100us/2;
    end if;
  end process;

  process (clock)
  begin
    if (clock'event and clock='1') then
      clockTrigger(5) <= '1';
      wait for 10us/2;
      clockTrigger(5) <= '0';
      wait for 10us/2;
    end if;
  end process;

  process (clock)
  begin
    if (clock'event and clock='1') then
      clockTrigger(6) <= '1';
      wait for 1us/2;
      clockTrigger(6) <= '0';
      wait for 1us/2;
    end if;
  end process;

  process
  begin
    clockTrigger(7) <= '1';
    wait for 100ns/2;
    clockTrigger(7) <= '0';
    wait for 100ns/2;
  end process;


end RTL;
