----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: flopenr - Behavioral
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
-- use IEEE.STD_LOGIC_UNSIGNED.all;
-- use IEEE.STD_LOGIC_ARITH.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity flopenr is
    generic(
        g_width   : integer   := 32  -- g_width-bit wide registers
    );
    port(
        i_clk     : in  STD_LOGIC;
        i_reset   : in  STD_LOGIC;
        i_wen     : in  STD_LOGIC;
        i_d       : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
        o_q       : out STD_LOGIC_VECTOR(g_width-1 downto 0)
    );
end flopenr;


-- flip-flop with enable and synchronous i_reset


architecture Behavioral of flopenr is

begin

    only_process : process(i_clk)
    begin
        if i_clk'event and i_clk = '1' then
            if i_reset = '1' then
                o_q <= STD_LOGIC_VECTOR(to_unsigned(0, g_width)); -- produce a vector of all zeros
            elsif i_wen = '1' then
                o_q <= i_d;
            end if;
        end if;
    end process; -- only_process

end Behavioral; -- flopenr
