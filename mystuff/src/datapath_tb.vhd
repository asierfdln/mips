----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: datapath_tb - Behavioral
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

entity datapath_tb is
    generic(
        ent_width   : integer   := 32; -- ent_width-bit wide registers
        ent_regbits : integer   := 5   -- 2**ent_regbits number of registers
    );
end datapath_tb;


-- MIPS datapath


architecture Behavioral of datapath_tb is

    component datapath is
        generic(
            g_width   : integer   := 32; -- g_width-bit wide registers
            g_regbits : integer   := 5   -- 2**g_regbits number of registers
        );
        port(
            i_clk     : in  STD_LOGIC;
            i_reset   : in  STD_LOGIC  -- reset is for PC...
        );
    end component; -- datapath

    signal si_clk     : STD_LOGIC;
    signal si_reset   : STD_LOGIC;

begin

    datapath_DUT : datapath
        generic map(
            g_width     => ent_width,
            g_regbits   => ent_regbits
        )
        port map(
            i_clk       => si_clk,
            i_reset     => si_reset
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

        -- reset everything, puts zeros in important places...
        si_reset    <= '1';
        wait for 12 ns;

        -- see wusup
        si_reset    <= '0';

        wait;

    end process; -- manual_signals

end Behavioral; -- datapath_tb
