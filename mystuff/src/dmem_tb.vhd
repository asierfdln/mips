----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: dmem_tb - Behavioral
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

entity dmem_tb is
    generic(
        ent_struct      : integer   := 8;   -- byte-structured memory...
        ent_datawidth   : integer   := 32;  -- width of data ports
        ent_adrbits     : integer   := 8    -- 2**ent_adrbits number of ent_struct-bit positions in memory array
    );
end dmem_tb;


-- NWeste: "external memory accessed by MIPS"
-- main-memory-like instruction memory data array thing, soon-to-be Icache...


architecture Behavioral of dmem_tb is

    component dmem is
        generic(
            g_struct    : integer;
            g_datawidth : integer;
            g_adrbits   : integer
        );
        port(
            i_clk             : in  STD_LOGIC;
            i_adr             : in  STD_LOGIC_VECTOR(g_adrbits-1 downto 0);
            i_memWctrl        : in  STD_LOGIC;
            i_memWctrl8or32   : in  STD_LOGIC;
            i_memWdata        : in  STD_LOGIC_VECTOR(g_datawidth-1 downto 0);
            o_memRdata        : out STD_LOGIC_VECTOR(g_datawidth-1 downto 0)
        );
    end component; -- dmem

    signal si_clk            : STD_LOGIC;
    signal si_adr            : STD_LOGIC_VECTOR(ent_adrbits-1 downto 0);
    signal si_memwrite       : STD_LOGIC;
    signal si_memwrite8or32  : STD_LOGIC;
    signal si_writedata      : STD_LOGIC_VECTOR(ent_datawidth-1 downto 0);
    signal so_memdata        : STD_LOGIC_VECTOR(ent_datawidth-1 downto 0);

begin
    
    dmem_DUT : dmem
        generic map(
            g_struct    => ent_struct,
            g_datawidth => ent_datawidth,
            g_adrbits   => ent_adrbits
        )
        port map(
            i_clk             => si_clk,
            i_adr             => si_adr,
            i_memWctrl        => si_memwrite,
            i_memWctrl8or32   => si_memwrite8or32,
            i_memWdata        => si_writedata,
            o_memRdata        => so_memdata
        );

    s_clk_gen : process
    begin
        si_clk <= '1';
        wait for 5 ns;
        si_clk <= '0';
        wait for 5 ns;
    end process; -- s_clk_gen

    manual_signals : process
    begin

        -- read line 1/19
        si_adr           <= "00000000";
        si_memwrite      <= '0';
        si_memwrite8or32 <= '0';
        si_writedata     <= x"00000000";
        wait for 5 ns;
        assert so_memdata = x"80020044" report "read line 1/19 failed";
        wait for 5 ns;

        -- read line 2/19
        si_adr           <= "00000100";
        si_memwrite      <= '0';
        si_memwrite8or32 <= '0';
        si_writedata     <= x"00000000";
        wait for 5 ns;
        assert so_memdata = x"80070040" report "read line 2/19 failed";
        wait for 5 ns;

        -- read starting from byte 252
        si_adr           <= "11111100";
        si_memwrite      <= '0';
        si_memwrite8or32 <= '0';
        si_writedata     <= x"00000000";
        wait for 5 ns;
        assert so_memdata = x"00000000" report "read starting from byte 252 failed";
        wait for 5 ns;

        -- read starting from byte 253
        si_adr           <= "11111101";
        si_memwrite      <= '0';
        si_memwrite8or32 <= '0';
        si_writedata     <= x"00000000";
        wait for 5 ns;
        assert so_memdata = x"44000000" report "read starting from byte 253 failed";
        wait for 5 ns;

        -- read starting from byte 254
        si_adr           <= "11111110";
        si_memwrite      <= '0';
        si_memwrite8or32 <= '0';
        si_writedata     <= x"00000000";
        wait for 5 ns;
        assert so_memdata = x"00440000" report "read starting from byte 254 failed";
        wait for 5 ns;

        -- read starting from byte 255
        si_adr           <= "11111111";
        si_memwrite      <= '0';
        si_memwrite8or32 <= '0';
        si_writedata     <= x"00000000";
        wait for 5 ns;
        assert so_memdata = x"02004400" report "read starting from byte 255 failed";
        wait for 5 ns;

        -- read line 1/19 again
        si_adr           <= "00000000";
        si_memwrite      <= '0';
        si_memwrite8or32 <= '0';
        si_writedata     <= x"00000000";
        wait for 5 ns;
        assert so_memdata = x"80020044" report "read line 1/19 again failed";
        wait for 5 ns;

        -- write line 1/19[0]
        si_adr           <= "00000000";
        si_memwrite      <= '1';
        si_memwrite8or32 <= '0';
        si_writedata     <= x"00000069";
        wait for 10 ns;

            -- read line 1/19 after write 1/19[0]
            si_adr           <= "00000000";
            si_memwrite      <= '0';
            si_memwrite8or32 <= '0';
            si_writedata     <= x"00000000";
            wait for 5 ns;
            assert so_memdata = x"80020069" report "read line 1/19 after write 1/19[0] failed";
            wait for 5 ns;

        -- write line 1/19[1]
        si_adr           <= "00000001";
        si_memwrite      <= '1';
        si_memwrite8or32 <= '0';
        si_writedata     <= x"00000069";
        wait for 10 ns;

            -- read line 1/19 after write 1/19[1]
            si_adr           <= "00000000";
            si_memwrite      <= '0';
            si_memwrite8or32 <= '0';
            si_writedata     <= x"00000000";
            wait for 5 ns;
            assert so_memdata = x"80026969" report "read line 1/19 after write 1/19[1] failed";
            wait for 5 ns;

        -- write line 2/19
        si_adr           <= "00000100";
        si_memwrite      <= '1';
        si_memwrite8or32 <= '1';
        si_writedata     <= x"69696969";
        wait for 10 ns;

            -- read line 2/19 after write 2/19
            si_adr           <= "00000100";
            si_memwrite      <= '0';
            si_memwrite8or32 <= '0';
            si_writedata     <= x"00000000";
            wait for 5 ns;
            assert so_memdata = x"69696969" report "read line 2/19 after write 2/19 failed";
            wait for 5 ns;

        -- reset everything to 0
        si_adr           <= "00000000";
        si_memwrite      <= '0';
        si_memwrite8or32 <= '0';
        si_writedata     <= x"00000000";

        wait;

    end process; -- manual_signals

end Behavioral; -- dmem_tb
