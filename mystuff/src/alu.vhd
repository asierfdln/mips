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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    generic(
        width: integer
    );
    port(
        i_a         : in  STD_LOGIC_VECTOR(width-1 downto 0);
        i_b         : in  STD_LOGIC_VECTOR(width-1 downto 0);
        i_alucont   : in  STD_LOGIC_VECTOR(2 downto 0);
        o_result    : out STD_LOGIC_VECTOR(width-1 downto 0)
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


architecture Behavioral of alu is

    signal s_b2   : STD_LOGIC_VECTOR(width-1 downto 0);
    signal s_sum  : STD_LOGIC_VECTOR(width-1 downto 0);
    signal s_slt  : STD_LOGIC_VECTOR(width-1 downto 0);

begin

    -- for sub operation "i_a - i_b", see next line
    s_b2 <= not i_b when i_alucont(2) = '1' else
            i_b;
    -- s_sum signal stores value of both s_sum and sub
    s_sum <= i_a + s_b2 + i_alucont(2);
    -- s_slt should be 1 if most significant bit of s_sum is 1
    s_slt <= conv_std_logic_vector(1, width) when s_sum(width-1) = '1' else
        conv_std_logic_vector(0, width);

    with i_alucont(1 downto 0) select
        o_result <= i_a and i_b when "00",
                    i_a or  i_b when "01",
                    s_sum     when "10",
                    s_slt     when others;

end Behavioral; -- alu
