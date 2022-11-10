----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: imem_tb - Behavioral
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

entity imem_tb is
    generic(
        ent_width   : integer   := 8;   -- byte-structured memory...
        ent_adrbits : integer   := 8    -- 2**adrbits number of width-bit positions in memory array
    );
end imem_tb;


-- NWeste: "external memory accessed by MIPS"
-- main-memory-like instruction memory data array thing, soon-to-be Icache...


architecture Behavioral of imem_tb is

    component imem is
        generic(
            width   : integer;
            adrbits : integer
        );
        port(
            clk             : in    STD_LOGIC;
            adr             : in    STD_LOGIC_VECTOR(adrbits-1 downto 0);
            memwrite        : in    STD_LOGIC;
            memwrite8or32   : in    STD_LOGIC;
            writedata       : in    STD_LOGIC_VECTOR(31 downto 0);
            memdata         : out   STD_LOGIC_VECTOR(31 downto 0)
        );
    end component; -- imem

    signal s_clk            : STD_LOGIC;
    signal s_adr            : STD_LOGIC_VECTOR(ent_adrbits-1 downto 0);
    signal s_memwrite       : STD_LOGIC;
    signal s_memwrite8or32  : STD_LOGIC;
    signal s_writedata      : STD_LOGIC_VECTOR(31 downto 0);
    signal s_memdata        : STD_LOGIC_VECTOR(31 downto 0);

begin
    
    imem_DUT : imem
        generic map(
            width   => ent_width,
            adrbits => ent_adrbits
        )
        port map(
            clk             => s_clk,
            adr             => s_adr,
            memwrite        => s_memwrite,
            memwrite8or32   => s_memwrite8or32,
            writedata       => s_writedata,
            memdata         => s_memdata
        );

    s_clk_gen : process
    begin
        s_clk <= '1';
        wait for 5 ns;
        s_clk <= '0';
        wait for 5 ns;
    end process; -- s_clk_gen

    manual_signals : process
    begin

        -- read line 1/19
        s_adr           <= "00000000";
        s_memwrite      <= '0';
        s_memwrite8or32 <= '0';
        s_writedata     <= x"00000000";
        wait for 5 ns;
        assert s_memdata = x"80020044" report "read line 1/19 failed";
        wait for 5 ns;

        -- read line 2/19
        s_adr           <= "00000100";
        s_memwrite      <= '0';
        s_memwrite8or32 <= '0';
        s_writedata     <= x"00000000";
        wait for 5 ns;
        assert s_memdata = x"80070040" report "read line 2/19 failed";
        wait for 5 ns;

        -- read starting from byte 252
        s_adr           <= "11111100";
        s_memwrite      <= '0';
        s_memwrite8or32 <= '0';
        s_writedata     <= x"00000000";
        wait for 5 ns;
        assert s_memdata = x"00000000" report "read starting from byte 252 failed";
        wait for 5 ns;

        -- read starting from byte 253
        s_adr           <= "11111101";
        s_memwrite      <= '0';
        s_memwrite8or32 <= '0';
        s_writedata     <= x"00000000";
        wait for 5 ns;
        assert s_memdata = x"44000000" report "read starting from byte 253 failed";
        wait for 5 ns;

        -- read starting from byte 254
        s_adr           <= "11111110";
        s_memwrite      <= '0';
        s_memwrite8or32 <= '0';
        s_writedata     <= x"00000000";
        wait for 5 ns;
        assert s_memdata = x"00440000" report "read starting from byte 254 failed";
        wait for 5 ns;

        -- read starting from byte 255
        s_adr           <= "11111111";
        s_memwrite      <= '0';
        s_memwrite8or32 <= '0';
        s_writedata     <= x"00000000";
        wait for 5 ns;
        assert s_memdata = x"02004400" report "read starting from byte 255 failed";
        wait for 5 ns;

        -- read line 1/19 again
        s_adr           <= "00000000";
        s_memwrite      <= '0';
        s_memwrite8or32 <= '0';
        s_writedata     <= x"00000000";
        wait for 5 ns;
        assert s_memdata = x"80020044" report "read line 1/19 again failed";
        wait for 5 ns;

        -- write line 1/19[0]
        s_adr           <= "00000000";
        s_memwrite      <= '1';
        s_memwrite8or32 <= '0';
        s_writedata     <= x"00000069";
        wait for 10 ns;

            -- read line 1/19 after write 1/19[0]
            s_adr           <= "00000000";
            s_memwrite      <= '0';
            s_memwrite8or32 <= '0';
            s_writedata     <= x"00000000";
            wait for 5 ns;
            assert s_memdata = x"80020069" report "read line 1/19 after write 1/19[0] failed";
            wait for 5 ns;

        -- write line 1/19[1]
        s_adr           <= "00000001";
        s_memwrite      <= '1';
        s_memwrite8or32 <= '0';
        s_writedata     <= x"00000069";
        wait for 10 ns;

            -- read line 1/19 after write 1/19[1]
            s_adr           <= "00000000";
            s_memwrite      <= '0';
            s_memwrite8or32 <= '0';
            s_writedata     <= x"00000000";
            wait for 5 ns;
            assert s_memdata = x"80026969" report "read line 1/19 after write 1/19[1] failed";
            wait for 5 ns;

        -- write line 2/19
        s_adr           <= "00000100";
        s_memwrite      <= '1';
        s_memwrite8or32 <= '1';
        s_writedata     <= x"69696969";
        wait for 10 ns;

            -- read line 2/19 after write 2/19
            s_adr           <= "00000100";
            s_memwrite      <= '0';
            s_memwrite8or32 <= '0';
            s_writedata     <= x"00000000";
            wait for 5 ns;
            assert s_memdata = x"69696969" report "read line 2/19 after write 2/19 failed";
            wait for 5 ns;

        -- reset everything to 0
        s_adr           <= "00000000";
        s_memwrite      <= '0';
        s_memwrite8or32 <= '0';
        s_writedata     <= x"00000000";

        wait;

    end process; -- manual_signals

end Behavioral; -- imem_tb
