library ieee;
use ieee.std_logic_1164.all;
 
entity or_gate_tb is
end or_gate_tb;
 
architecture behave of or_gate_tb is
  signal r_SIG1   : std_logic := '0';
  signal r_SIG2   : std_logic := '0';
  signal w_RESULT : std_logic;

  component or_gate is
    port (
      input_1    : in  std_logic;
      input_2    : in  std_logic;
      or_result : out std_logic);
  end component or_gate;

begin

  or_gate_INST : or_gate
    port map (
      input_1    => r_SIG1,
      input_2    => r_SIG2,
      or_result => w_RESULT
      );

  process is
  begin
    r_SIG1 <= '0';
    r_SIG2 <= '0';
    wait for 10 ns;
    r_SIG1 <= '0';
    r_SIG2 <= '1';
    wait for 10 ns;
    r_SIG1 <= '1';
    r_SIG2 <= '0';
    wait for 10 ns;
    r_SIG1 <= '1';
    r_SIG2 <= '1';
    wait for 10 ns;
  end process;

end behave;