----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: mux3 - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux3 is
    generic(
        g_width : integer := 32 -- g_width-bit wide registers
    );
    port(
        i_a   : in STD_LOGIC_VECTOR(g_width-1 downto 0);
        i_b   : in STD_LOGIC_VECTOR(g_width-1 downto 0);
        i_c   : in STD_LOGIC_VECTOR(g_width-1 downto 0);
        i_sel : in STD_LOGIC_VECTOR(1 downto 0);
        o_res : out STD_LOGIC_VECTOR(g_width-1 downto 0)
    );
end mux3;


-- 3-to-1 multiplexer


architecture Behavioral of mux3 is

begin

    only_process : process(i_sel, i_a, i_b, i_c)
    begin
        case i_sel is
            when "00" =>
                o_res <= i_a;
            when "01" =>
                o_res <= i_b;
            when others =>
                o_res <= i_c;
        end case;
    end process; -- only_process

end Behavioral; -- mux3
