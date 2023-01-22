----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: register_file_PP - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_file_PP is
    generic(
        g_width   : integer   := 32;  -- g_width-bit wide registers
        g_regbits : integer   := 5    -- 2**g_regbits number of registers
    );
    port(
        i_clk           : in    STD_LOGIC;
        i_write_enable  : in    STD_LOGIC;
        i_reg1_addr     : in    STD_LOGIC_VECTOR(g_regbits-1 downto 0);
        i_reg2_addr     : in    STD_LOGIC_VECTOR(g_regbits-1 downto 0);
        i_reg3_addr     : in    STD_LOGIC_VECTOR(g_regbits-1 downto 0);
        i_write_data    : in    STD_LOGIC_VECTOR(g_width-1 downto 0);
        o_reg2_contents : out   STD_LOGIC_VECTOR(g_width-1 downto 0);
        o_reg3_contents : out   STD_LOGIC_VECTOR(g_width-1 downto 0)
    );
end register_file_PP;


-- three-ported register file
-- read two ports on rising edge of clock
-- write third port on rising edge of clock


architecture Behavioral of register_file_PP is

    type registers is array (2**g_regbits - 1 downto 0) of STD_LOGIC_VECTOR(g_width-1 downto 0);
    -- signal s_regs : registers;
    signal s_regs : registers := (others => (others => '0')); -- TODO temporary ñapa...

begin

    write_stuff : process(i_clk)
    begin
        if i_clk'event and i_clk = '1' then
            if i_write_enable = '1' then
                s_regs(conv_integer(i_reg1_addr)) <= i_write_data;
            end if;
        end if;
    end process; -- write_stuff

    read_reg2 : process(i_clk, i_reg2_addr, i_write_enable, i_reg1_addr)
    begin
        -- output reg2 address contents
        if (conv_integer(i_reg2_addr) = 0) then
            o_reg2_contents <= conv_std_logic_vector(0, g_width); -- register 0 holds 0
        else

            -- -- this would read registers with no write-priority, so with outdated values...
            -- o_reg2_contents <= s_regs(conv_integer(i_reg2_addr));

            -- this takes into account the write_data being entered when the write_enable is high...
            if i_write_enable = '1' and i_reg2_addr = i_reg1_addr then
                o_reg2_contents <= i_write_data;
            else
                o_reg2_contents <= s_regs(conv_integer(i_reg2_addr));
            end if;

        end if;
    end process; -- read_reg2

    read_reg3 : process(i_clk, i_reg3_addr, i_write_enable, i_reg1_addr)
    begin
        -- output reg3 address contents
        if (conv_integer(i_reg3_addr) = 0) then
            o_reg3_contents <= conv_std_logic_vector(0, g_width); -- register 0 holds 0
        else

            -- -- this would read registers with no write-priority, so with outdated values...
            -- o_reg3_contents <= s_regs(conv_integer(i_reg3_addr));

            -- this takes into account the write_data being entered when the write_enable is high...
            if i_write_enable = '1' and i_reg3_addr = i_reg1_addr then
                o_reg3_contents <= i_write_data;
            else
                o_reg3_contents <= s_regs(conv_integer(i_reg3_addr));
            end if;

        end if;
    end process; -- read_reg3

    -- -- combinational read_stuff
    -- read_stuff : process(i_reg2_addr, i_reg3_addr) begin
    --     if (conv_integer(i_reg2_addr) = 0) then
    --         o_reg2_contents <= conv_std_logic_vector(0, g_width); -- register 0 holds 0
    --     else
    --         o_reg2_contents <= s_regs(conv_integer(i_reg2_addr));
    --     end if;
    --     if (conv_integer(i_reg3_addr) = 0) then
    --         o_reg3_contents <= conv_std_logic_vector(0, g_width); -- register 0 holds 0
    --     else
    --         o_reg3_contents <= s_regs(conv_integer(i_reg3_addr));
    --     end if;
    -- end process; -- read_stuff

end Behavioral; -- register_file_PP
