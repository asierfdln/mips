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
        a         : in  STD_LOGIC_VECTOR(width-1 downto 0);
        b         : in  STD_LOGIC_VECTOR(width-1 downto 0);
        alucont   : in  STD_LOGIC_VECTOR(2 downto 0);
        result    : out STD_LOGIC_VECTOR(width-1 downto 0)
    );
end alu;


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


architecture Behavioral of alu is

    signal b2   : STD_LOGIC_VECTOR(width-1 downto 0);
    signal sum  : STD_LOGIC_VECTOR(width-1 downto 0);
    signal slt  : STD_LOGIC_VECTOR(width-1 downto 0);

begin

    -- for sub operation "a - b", see next line
    b2 <= not b when alucont(2) = '1' else
            b;
    -- sum signal stores value of both sum and sub
    sum <= a + b2 + alucont(2);
    -- slt should be 1 if most significant bit of sum is 1
    slt <= conv_std_logic_vector(1, width) when sum(width-1) = '1' else
        conv_std_logic_vector(0, width);

    with alucont(1 downto 0) select
        result <= a and b when "00",
                    a or  b when "01",
                    sum     when "10",
                    slt     when others;

end Behavioral; -- alu
