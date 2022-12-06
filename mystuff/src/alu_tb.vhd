----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: alu_tb - Behavioral
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

entity alu_tb is
    generic(
        ent_width : integer := 32 -- g_width-bit wide registers
    );
end alu_tb;


-- ALU with:
--   AND
--     alucont "000"
--   OR
--     alucont "001"
--   add
--     alucont "010"
--     for add/lb/lw/stb/stw instructions
--   sub
--     alucont "110", see slt logic for why sudden change in opcodes...
--     for sub/beq instructions
--   slt, set less than
--     alucont "111"
--     "$1 <- 1" if "$2 < $3", otherwise "$1 <- 0"


architecture Behavioral of alu_tb is

    component alu is
        generic(
            g_width : integer
        );
        port(
            i_a       : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
            i_b       : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
            i_alucont : in  STD_LOGIC_VECTOR(2 downto 0);
            o_zerodet : out STD_LOGIC;
            o_result  : out STD_LOGIC_VECTOR(g_width-1 downto 0)
        );
    end component; -- alu

    signal si_a       : STD_LOGIC_VECTOR(ent_width-1 downto 0);
    signal si_b       : STD_LOGIC_VECTOR(ent_width-1 downto 0);
    signal si_alucont : STD_LOGIC_VECTOR(2 downto 0);
    signal so_zerodet : STD_LOGIC;
    signal so_result  : STD_LOGIC_VECTOR(ent_width-1 downto 0);

begin
    
    alu_DUT : alu
        generic map(
            g_width => ent_width
        )
        port map(
            i_a       => si_a,
            i_b       => si_b,
            i_alucont => si_alucont,
            o_zerodet => so_zerodet,
            o_result  => so_result
        );

    manual_signals : process
    begin
        -- do 1 AND 3
        si_a         <= x"00000001";
        si_b         <= x"00000003";
        si_alucont   <= "000";
        wait for 5 ns;
        assert so_result  = x"00000001" report "do 1 AND 3 failed";
        assert so_zerodet =  '0'        report "do 1 AND 3 failed in zerodet";
        wait for 5 ns;
        -- do 1 OR 3
        si_a         <= x"00000001";
        si_b         <= x"00000003";
        si_alucont   <= "001";
        wait for 5 ns;
        assert so_result  = x"00000003" report "do 1 OR 3 failed";
        assert so_zerodet =  '0'        report "do 1 OR 3 failed in zerodet";
        wait for 5 ns;
        -- do 1 ADD 1
        si_a         <= x"00000001";
        si_b         <= x"00000001";
        si_alucont   <= "010";
        wait for 5 ns;
        assert so_result  = x"00000002" report "do 1 ADD 1 failed";
        assert so_zerodet =  '0'        report "do 1 ADD 1 failed in zerodet";
        wait for 5 ns;
        -- do 1 SUB 1
        si_a         <= x"00000001";
        si_b         <= x"00000001";
        si_alucont   <= "110";
        wait for 5 ns;
        assert so_result  = x"00000000" report "do 1 SUB 1 failed";
        assert so_zerodet =  '1'        report "do 1 SUB 1 failed in zerodet";
        wait for 5 ns;
        -- do 0 SUB 1
        si_a         <= x"00000000";
        si_b         <= x"00000001";
        si_alucont   <= "110";
        wait for 5 ns;
        assert so_result  = x"FFFFFFFF" report "do 1 SUB 1 failed";
        assert so_zerodet =  '0'        report "do 1 SUB 1 failed in zerodet";
        wait for 5 ns;
        -- do 1 SLT 1
        si_a         <= x"00000000";
        si_b         <= x"00000001";
        si_alucont   <= "111";
        wait for 5 ns;
        assert so_result  = x"00000001" report "do 1 SLT 0 failed";
        assert so_zerodet =  '0'        report "do 1 SLT 0 failed in zerodet";
        wait for 5 ns;
        -- reset everything to 0
        si_a         <= x"00000000";
        si_b         <= x"00000000";
        si_alucont   <= "000";
        wait;
    end process; -- manual_signals

end Behavioral; -- alu_tb
