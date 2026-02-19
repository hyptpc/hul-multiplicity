library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.AddressMap.all;
use mylib.BusSignalTypes.all;
use mylib.AddressBook.all;

library UNISIM;
use UNISIM.VComponents.all;

entity Region2_6 is
  port(
    	        rst                      : in  std_logic;
    	        clk_trg                  : in  std_logic;
    	        clk_sys                  : in  std_logic;

	        -- DPWM ---------------------------------
    	        -- input signal --
    	        BH2_Pi                    : in  std_logic;
                Other1                    : in  std_logic;
                Other2                    : in  std_logic;
                Other3                    : in  std_logic;
                Other4                    : in  std_logic;
                Other5                    : in  std_logic;

    	        -- output signal --
    	        BH2_Pi_E03                : out std_logic;
                Other1_E03                : out std_logic;
                Other2_E03                : out std_logic;
                Other3_E03                : out std_logic;
                Other4_E03                : out std_logic;
                Other5_E03                : out std_logic;

		For_E03                   : out std_logic;

                -- Local bus --
                addrLocalBus        : in LocalAddressType;
                dataLocalBusIn      : in LocalBusInType;
                dataLocalBusOut     : out LocalBusOutType;
                reLocalBus          : in std_logic;
                weLocalBus          : in std_logic;
                readyLocalBus       : out std_logic
    );
end Region2_6;

architecture RTL of Region2_6 is
  --  attribute keep : string;

  -- other signal -------------------------------------------------------------
	constant NbitOut             : positive := 5;
	constant NbitOut_2           : positive := 2;
	constant NbitOut_6           : positive := 6;
	constant NbitOut_7           : positive := 7;
	constant NbitOut_8           : positive := 8;
	signal state_lbus          : BusProcessType;

  -- inner signal -------------------------------------------------------------
	signal in_BH2_Pi_E03           : std_logic;
	signal in_Other1_E03           : std_logic;
	signal in_Other2_E03           : std_logic;
	signal in_Other3_E03           : std_logic;
	signal in_Other4_E03           : std_logic;
	signal in_Other5_E03           : std_logic;

  -- For DPWM ------------------------------------------------------------
  -- For Delay --
	signal reg_delay_BH2_Pi        : std_logic_vector(NbitOut-1 downto 0);
	signal reg_delay_Other1        : std_logic_vector(NbitOut-1 downto 0);
	signal reg_delay_Other2        : std_logic_vector(NbitOut-1 downto 0);
	signal reg_delay_Other3        : std_logic_vector(NbitOut-1 downto 0);
	signal reg_delay_Other4        : std_logic_vector(NbitOut-1 downto 0);
	signal reg_delay_Other5        : std_logic_vector(NbitOut-1 downto 0);


  -- For PWM --
	signal reg_counter_BH2_Pi        : std_logic_vector(NbitOut-1 downto 0);
	signal reg_counter_Other1        : std_logic_vector(NbitOut-1 downto 0);
	signal reg_counter_Other2        : std_logic_vector(NbitOut-1 downto 0);
	signal reg_counter_Other3        : std_logic_vector(NbitOut-1 downto 0);
	signal reg_counter_Other4        : std_logic_vector(NbitOut-1 downto 0);
	signal reg_counter_Other5        : std_logic_vector(NbitOut-1 downto 0);

  -- For BPS --------------------------------------------------------------
        signal reg_ctrl_6  : std_logic_vector(NbitOut_6-1 downto 0);
        signal reg_coin_6  : std_logic_vector(NbitOut_6-1 downto 0);

  -- Modules  -------------------------------------------------------------
  component DPWM is
  port(
       reset             : in std_logic;
       clk_trg         : in std_logic;

       -- input signal --
       in1             : in  std_logic;
       reg_delay       : in  std_logic_vector( 4 downto 0);
       reg_counter     : in  std_logic_vector( 4 downto 0);
       -- output signal --
       out1            : out std_logic
      );
  end component;

  component BPS_6bits is
  	port(
  	     -- input signal --
             reset          : in std_logic;
             clk_trg      : in std_logic;
  	     in1          : in  std_logic;
  	     in2          : in  std_logic;
  	     in3          : in  std_logic;
  	     in4          : in  std_logic;
  	     in5          : in  std_logic;
  	     in6          : in  std_logic;
  	     reg_ctrl     : in  std_logic_vector(5 downto 0);
  	     reg_coin     : in  std_logic_vector(5 downto 0);
  	     -- output signal --
  	     out1  : out std_logic
  	    );
  end component;


begin

end RTL;
