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
        ent_width   : integer   := 32   -- width-bit wide registers
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
            width: integer
        );
        port(
            i_a         : in  STD_LOGIC_VECTOR(width-1 downto 0);
            i_b         : in  STD_LOGIC_VECTOR(width-1 downto 0);
            i_alucont   : in  STD_LOGIC_VECTOR(2 downto 0);
            o_result    : out STD_LOGIC_VECTOR(width-1 downto 0)
        );
    end component; -- alu

    -- signal s_clk        : STD_LOGIC;
    signal s_a          : STD_LOGIC_VECTOR(ent_width-1 downto 0);
    signal s_b          : STD_LOGIC_VECTOR(ent_width-1 downto 0);
    signal s_alucont    : STD_LOGIC_VECTOR(2 downto 0);
    signal s_result     : STD_LOGIC_VECTOR(ent_width-1 downto 0);

begin
    
    alu_DUT : alu
        generic map(
            width   => ent_width
        )
        port map(
            i_a         => s_a,
            i_b         => s_b,
            i_alucont   => s_alucont,
            o_result    => s_result
        );

    -- s_clk_gen : process
    -- begin
    --     s_clk <= '1';
    --     wait for 5 ns;
    --     s_clk <= '0';
    --     wait for 5 ns;
    -- end process; -- s_clk_gen

    manual_signals : process
    begin
        -- do 1 AND 3
        s_a         <= x"00000001";
        s_b         <= x"00000003";
        s_alucont   <= "000";
        wait for 5 ns;
        assert s_result = x"00000001" report "do 1 AND 3 failed";
        wait for 5 ns;
        -- do 1 OR 3
        s_a         <= x"00000001";
        s_b         <= x"00000003";
        s_alucont   <= "001";
        wait for 5 ns;
        assert s_result = x"00000003" report "do 1 OR 3 failed";
        wait for 5 ns;
        -- do 1 ADD 1
        s_a         <= x"00000001";
        s_b         <= x"00000001";
        s_alucont   <= "010";
        wait for 5 ns;
        assert s_result = x"00000002" report "do 1 ADD 1 failed";
        wait for 5 ns;
        -- do 1 SUB 1
        s_a         <= x"00000001";
        s_b         <= x"00000001";
        s_alucont   <= "110";
        wait for 5 ns;
        assert s_result = x"00000000" report "do 1 SUB 1 failed";
        wait for 5 ns;
        -- do 1 SLT 1
        s_a         <= x"00000000";
        s_b         <= x"00000001";
        s_alucont   <= "111";
        wait for 5 ns;
        assert s_result = x"00000001" report "do 1 SLT 0 failed";
        wait for 5 ns;
        -- reset everything to 0
        s_a         <= x"00000000";
        s_b         <= x"00000000";
        s_alucont   <= "000";
        wait;
    end process; -- manual_signals

end Behavioral; -- alu_tb
