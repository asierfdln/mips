----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: alu - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_MISC.or_reduce;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    generic(
        g_width: integer
    );
    port(
        i_a         : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
        i_b         : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
        i_alucont   : in  STD_LOGIC_VECTOR(2 downto 0);
        o_zerodet   : out STD_LOGIC;
        o_result    : out STD_LOGIC_VECTOR(g_width-1 downto 0)
    );
end alu;


-- ALU with:
--   AND
--     i_alucont "000"
--   OR
--     i_alucont "001"
--   add
--     i_alucont "010"
--     for add/lb/lw/stb/stw instructions
--   sub
--     i_alucont "110", see s_slt logic for why sudden change in opcodes...
--     for sub/beq instructions
--   slt, set less than
--     i_alucont "111"
--     "$1 <- 1" if "$2 < $3", otherwise "$1 <- 0"
--   MUL, multiply std_logic_vectors
--     i_alucont "011"


architecture Behavioral of alu is

    signal s_b2   : STD_LOGIC_VECTOR(g_width-1 downto 0);
    signal s_sum  : STD_LOGIC_VECTOR(g_width-1 downto 0);
    signal s_slt  : STD_LOGIC_VECTOR(g_width-1 downto 0);
    signal preout : STD_LOGIC_VECTOR(g_width-1 downto 0);

    signal resmul      : STD_LOGIC_VECTOR((g_width * 2)-1 downto 0);
    signal resmul_lsbs : STD_LOGIC_VECTOR(g_width-1 downto 0);

begin

    -- always multiply and then select output for LSBs...
    resmul      <= i_a * i_b;
    resmul_lsbs <= resmul(g_width-1 downto 0);

    -- for sub operation "i_a - i_b", see next line
    s_b2 <= not i_b when i_alucont(2) = '1' else
            i_b;

    -- s_sum signal stores value of both s_sum and s_sub (s_sub is not a thing...)
    s_sum <= i_a + s_b2 + i_alucont(2);

    -- s_slt should be 1 if most significant bit of s_sum is 1
    s_slt <= conv_std_logic_vector(1, g_width) when s_sum(g_width-1) = '1' else
             conv_std_logic_vector(0, g_width);

    with i_alucont select
        preout <= i_a and i_b when "000",
                  i_a or  i_b when "001",
                  s_sum       when "010", -- addition
                  s_sum       when "110", -- subtraction
                  resmul_lsbs when "011", -- multiplication
                  s_slt       when others;

    o_result  <= preout;
    o_zerodet <= not or_reduce(preout);

end Behavioral; -- alu
