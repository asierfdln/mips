----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: register_file - Behavioral
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

entity register_file is
    generic(
        width   : integer   := 32;  -- width-bit wide registers
        regbits : integer   := 5    -- 2**regbits number of registers
    );
    port(
        i_clk           : in    STD_LOGIC;
        i_write_enable  : in    STD_LOGIC;
        i_reg1_addr     : in    STD_LOGIC_VECTOR (regbits-1 downto 0);
        i_reg2_addr     : in    STD_LOGIC_VECTOR (regbits-1 downto 0);
        i_reg3_addr     : in    STD_LOGIC_VECTOR (regbits-1 downto 0);
        i_write_data    : in    STD_LOGIC_VECTOR (width-1 downto 0);
        o_reg2_contents : out   STD_LOGIC_VECTOR (width-1 downto 0);
        o_reg3_contents : out   STD_LOGIC_VECTOR (width-1 downto 0)
    );
end register_file;


-- three-ported register file
-- read two ports combinationally
-- write third port on rising edge of clock


architecture Behavioral of register_file is

    type registers is array (2**regbits - 1 downto 0) of STD_LOGIC_VECTOR(width-1 downto 0);
    signal s_regs : registers;

begin

    write_stuff : process(i_clk)
    begin
        if i_clk'event and i_clk = '1' then
            if i_write_enable = '1' then
                s_regs(conv_integer(i_reg1_addr)) <= i_write_data;
            end if;
        end if;
    end process; -- write_stuff

    read_stuff : process(i_clk)
    begin
        if i_clk'event and i_clk = '1' then
            -- output reg2 address contents
            if (conv_integer(i_reg2_addr) = 0) then
                o_reg2_contents <= conv_std_logic_vector(0, width); -- register 0 holds 0
            else
                o_reg2_contents <= s_regs(conv_integer(i_reg2_addr));
            end if;
            -- output reg3 address contents
            if (conv_integer(i_reg3_addr) = 0) then
                o_reg3_contents <= conv_std_logic_vector(0, width); -- register 0 holds 0
            else
                o_reg3_contents <= s_regs(conv_integer(i_reg3_addr));
            end if;
        end if;
    end process ; -- read_stuff

end Behavioral; -- register_file
