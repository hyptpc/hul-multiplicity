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
--architecture RTL of Multiplexer is
--  --  attribute keep : string;
--  signal state_lbus : BusProcessType;
--  signal det_multiplexed : std_logic;
--  -- PWM --
--  component PWM is
--    port(
--      clkTrg   : in std_logic;
--      reset    : in std_logic;
--      in1      : in std_logic;
--      regWidth : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
--      out1     : out std_logic
--      );
--  end component;

--begin
--  u_PWM : PWM
--    port map (
--      clkTrg   => clkTrg,
--      reset    => reset,
--      in1      => det_multiplexed,
--      regWidth => regWidth,
--      out1     => outDet
--      );

--  u_MultiplexProcess : process (clkTrg, reset)
--  begin
--    if reset = '1' then
--      det_multiplexed <= '0';
--    elsif (clkTrg'event and clkTrg = '1') then
--      if (count_bits(inDet) >= to_integer(unsigned(regMul))) then
--        det_multiplexed <= '1';
--      else
--        det_multiplexed <= '0';
--      end if;
--    end if;
--  end process;
--end RTL;


-- Architecture RTL of Multiplexer replaces the above full text
architecture RTL of Multiplexer is
  ----------------------------------------------------------------
  -- Existing
  ----------------------------------------------------------------
  signal state_lbus      : BusProcessType;
  signal det_multiplexed : std_logic;

  ----------------------------------------------------------------
  -- 8bit popcount (0..8)
  ----------------------------------------------------------------
  -- function popcount8(slv : std_logic_vector(7 downto 0)) return unsigned is
  --   variable c : unsigned(3 downto 0) := (others => '0');
  -- begin
  --   for i in 0 to 7 loop
  --     if slv(i) = '1' then
  --       c := c + 1;
  --     end if;
  --   end loop;
  --   return c;
  -- end function;

  ----------------------------------------------------------------
  -- 4bit popcount (0..4)
  ----------------------------------------------------------------
  function popcount4(slv : std_logic_vector(3 downto 0)) return unsigned is
    variable c : unsigned(2 downto 0) := (others => '0');
  begin
    for i in 0 to 3 loop
      if slv(i) = '1' then
        c := c + 1;
      end if;
    end loop;
    return c;
  end function;

  ----------------------------------------------------------------
  -- Split settings (* CHUNK used instead of GROUP as it is a reserved word)
  ----------------------------------------------------------------
  constant NSEG   : integer := kNumOfSegDetector;     -- e.g., 64
  constant CHUNK  : integer := 4;                     -- Count every 4 bits
  constant NCHUNK : integer := NSEG / CHUNK;          -- 16
  constant WSUM   : integer := kMultiplicityRegSize;  -- Bit width of sum/threshold
  -- assert (NSEG mod CHUNK = 0) report "NSEG must be multiple of CHUNK" severity FAILURE;

  ----------------------------------------------------------------
  -- Signals for pipeline
  ----------------------------------------------------------------
  type u4_vec is array (natural range <>) of unsigned(2 downto 0);
  type sum_vec is array (natural range <>) of unsigned(WSUM-1 downto 0);
  
  signal s0_cnt   : u4_vec(0 to NCHUNK-1);                 -- Stage 1: Number of set bits in 4 lines (comb)
  signal s0_reg   : u4_vec(0 to NCHUNK-1);                 -- 1-cycle register for above
  
  -- Tree adder pipeline stages
  signal sum_tree_s1     : sum_vec(0 to NCHUNK/4-1);       -- 4 values after 1st add stage (comb)
  signal sum_tree_s1_r   : sum_vec(0 to NCHUNK/4-1);       -- 1-cycle register
  signal sum_tree_s2     : unsigned(WSUM-1 downto 0);      -- 2 values after 2nd add stage (comb)
  
  --signal sum1     : unsigned(WSUM-1 downto 0);             -- Summation result (registered)
  signal sum1_tmp : unsigned(WSUM-1 downto 0);             -- Temporary variable for summation
  signal regMul_d : unsigned(WSUM-1 downto 0);             -- 1-cycle delay for threshold
begin
  ----------------------------------------------------------------
  -- PWM (original). Adjusted entity prefix to match library:
  --   mylib.PWM / work.PWM / xil_defaultlib.PWM
  ----------------------------------------------------------------
  u_PWM : entity mylib.PWM
    port map (
      clkTrg   => clkTrg,
      reset    => reset,
      in1      => det_multiplexed,
      regWidth => regWidth,
      out1     => outDet
    );

  ----------------------------------------------------------------
  -- 1) Popcount for every 8 bits (combinatorial)
  ----------------------------------------------------------------
  gen_pc : for g in 0 to NCHUNK-1 generate
    s0_cnt(g) <= popcount4( inDet(g*CHUNK + CHUNK-1 downto g*CHUNK) );
  end generate;

  ----------------------------------------------------------------
  -- 2) Partial count + threshold 1-cycle register (pipeline stage)
  ----------------------------------------------------------------
  stage0_reg : process(clkTrg, reset)
  begin
    if reset = '1' then
      for g in 0 to NCHUNK-1 loop
        s0_reg(g) <= (others => '0');
      end loop;
    elsif rising_edge(clkTrg) then
      for g in 0 to NCHUNK-1 loop
        s0_reg(g) <= s0_cnt(g);
      end loop;
    end if;
  end process;

  ----------------------------------------------------------------
  -- 3) Summation tree with pipelined binary tree (fast parallel)
  ----------------------------------------------------------------
  -- Stage 1: First level of additions (16 -> 4 values)
  gen_sum_tree_s1 : for g in 0 to NCHUNK/4-1 generate
    sum_tree_s1(g) <= resize(s0_reg(4*g), WSUM) + resize(s0_reg(4*g+1), WSUM) + resize(s0_reg(4*g+2), WSUM) + resize(s0_reg(4*g+3), WSUM);
  end generate;

  -- Register stage 1 for pipelining
  stage1_pipe : process(clkTrg, reset)
  begin
    if reset = '1' then
      sum_tree_s1_r <= (others => (others => '0'));
    elsif rising_edge(clkTrg) then
      sum_tree_s1_r <= sum_tree_s1;
    end if;
  end process;

  -- Stage 2: Second level of additions (4 -> 1 values)
  sum_tree_s2 <= sum_tree_s1_r(0) + sum_tree_s1_r(1) + sum_tree_s1_r(2) + sum_tree_s1_r(3);

  ----------------------------------------------------------------
  -- 4) Compare and register (Output delayed by +1 cycle)
  ----------------------------------------------------------------
  u_MultiplexProcess : process (clkTrg, reset)
  begin
    if reset = '1' then
      regMul_d <= (others => '0');
      det_multiplexed <= '0';
      sum1_tmp <= (others => '0');
    elsif rising_edge(clkTrg) then
      -- 1 PP
      sum1_tmp <= sum_tree_s2;
      regMul_d <= unsigned(regMul);
      if (sum1_tmp >= regMul_d) then
        det_multiplexed <= '1';
      else
        det_multiplexed <= '0';
      end if;
    end if;
  end process;

end RTL;
