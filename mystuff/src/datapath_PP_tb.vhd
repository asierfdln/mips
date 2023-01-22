----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: datapath_PP_tb - Behavioral
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

entity datapath_PP_tb is
    generic(
        ent_width       : integer   := 32;  -- ent_width-bit wide registers
        ent_regbits     : integer   := 5;   -- 2**ent_regbits number of registers
        ent_struct      : integer   := 8;   -- byte-structured memory...
        ent_adrbits     : integer   := 8    -- 2**ent_adrbits number of ent_struct-bit positions in memory array
    );
end datapath_PP_tb;


-- MIPS datapath_PP


architecture Behavioral of datapath_PP_tb is

    component datapath_PP is
        generic(
            g_width     : integer;  -- g_width-bit wide registers
            g_regbits   : integer;  -- 2**g_regbits number of registers
            g_struct    : integer;  -- byte-structured memory...
            g_adrbits   : integer   -- 2**g_adrbits number of g_struct-bit positions in memory array
        );
        port(
            i_clk     : in  STD_LOGIC;
            i_reset   : in  STD_LOGIC  -- reset is for PC...
        );
    end component; -- datapath_PP

    signal si_clk   : STD_LOGIC;
    signal si_reset : STD_LOGIC := '1';

begin

    datapath_DUT : datapath_PP
        generic map(
            g_width     => ent_width,   -- : integer   := 32;
            g_regbits   => ent_regbits, -- : integer   := 5;
            g_struct    => ent_struct,  -- : integer   := 8;
            g_adrbits   => ent_adrbits  -- : integer   := 8 
        )
        port map(
            i_clk       => si_clk,  -- : in  STD_LOGIC;
            i_reset     => si_reset -- : in  STD_LOGIC  -- reset is for PC...
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

        -- maintain PC and PPregisters at zero...
        si_reset    <= '1';
        wait for 2 ns;

        -- see wusup
        si_reset    <= '0';

        wait;

    end process; -- manual_signals

end Behavioral; -- datapath_PP_tb
