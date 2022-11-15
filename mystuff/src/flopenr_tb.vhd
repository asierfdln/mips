----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: flopenr_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity flopenr_tb is
    generic(
        ent_width   : integer   := 32  -- width-bit wide registers
    );
end flopenr_tb;


-- flip-flop with enable and synchronous i_reset


architecture Behavioral of flopenr_tb is

    component flopenr is
        generic(
            g_width   : integer
        );
        port(
            i_clk     : in  STD_LOGIC;
            i_reset   : in  STD_LOGIC;
            i_wen     : in  STD_LOGIC;
            i_d       : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
            o_q       : out STD_LOGIC_VECTOR(g_width-1 downto 0)
        );
    end component; -- register_file


    signal si_clk     : STD_LOGIC;
    signal si_reset   : STD_LOGIC;
    signal si_wen     : STD_LOGIC;
    signal si_d       : STD_LOGIC_VECTOR(ent_width-1 downto 0);
    signal so_q       : STD_LOGIC_VECTOR(ent_width-1 downto 0);

begin

    flopenr_DUT : flopenr
        generic map(
            g_width   => ent_width
        )
        port map(
            i_clk       => si_clk,
            i_reset     => si_reset,
            i_wen       => si_wen,
            i_d         => si_d,
            o_q         => so_q
        );

    si_clk_gen : process
    begin
        si_clk <= '1';
        wait for 5 ns;
        si_clk <= '0';
        wait for 5 ns;
    end process; -- si_clk_gen

    manual_signals : process
    begin

        -- see wusup
        si_reset    <= '0';
        si_wen      <= '0';
        si_d        <= x"00000000";
        wait for 10 ns;

        -- see wusup with reset at one
        si_reset    <= '1';
        si_wen      <= '0';
        si_d        <= x"00000000";
        wait for 10 ns;

        -- write me some gudness
        si_reset    <= '0';
        si_wen      <= '1';
        si_d        <= x"69696969";
        wait for 10 ns;

        -- see wusup after writing
        si_reset    <= '0';
        si_wen      <= '0';
        si_d        <= x"00000000";
        wait for 10 ns;

        -- see wusup after writing with reset at one
        si_reset    <= '1';
        si_wen      <= '0';
        si_d        <= x"00000000";
        wait for 10 ns;

        wait;

    end process; -- manual_signals

end Behavioral; -- flopenr_tb
