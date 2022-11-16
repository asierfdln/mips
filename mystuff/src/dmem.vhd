----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: dmem - Behavioral
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
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dmem is
    generic(
        g_width   : integer   := 8;   -- byte-structured memory...
        g_adrbits : integer   := 8    -- 2**g_adrbits number of g_width-bit positions in memory array
    );
    port(
        i_clk             : in    STD_LOGIC;
        i_adr             : in    STD_LOGIC_VECTOR(g_adrbits-1 downto 0);
        i_memWctrl        : in    STD_LOGIC;
        i_memWctrl8or32   : in    STD_LOGIC;
        -- TO-DO this "31" is hardcoded...
        i_memWdata        : in    STD_LOGIC_VECTOR(31 downto 0);
        -- TO-DO this "31" is hardcoded...
        o_memRdata        : out   STD_LOGIC_VECTOR(31 downto 0)
    );
end dmem;


-- NWeste: "external memory accessed by MIPS"
-- main-memory-like instruction memory data array thing, soon-to-be Icache...


architecture Behavioral of dmem is

    -- see in process variables commented versions of "variable" type...
    -- do a CTRL+F of "variable-to-signal conversion"
    type ramtype is array (2**g_adrbits - 1 downto 0) of STD_LOGIC_VECTOR(g_width-1 downto 0);
    signal s_mem : ramtype;

begin

    process

        file        mem_file    : text open read_mode is "dmem.dat";
        variable    L           : line;
        variable    ch          : character;
        variable    index       : integer;
        variable    result      : integer;
        -- variable-to-signal conversion
        -- type        ramtype is array (2**g_adrbits - 1 downto 0) of STD_LOGIC_VECTOR(g_width-1 downto 0);
        -- variable    s_mem         : ramtype;

    begin

        -- initialize memory from file
        -- memory in little-endian format
        -- 80020044 means s_mem[3] = 80 and s_mem[0] = 44

        for i in 0 to 255 loop -- set all contents low
            -- variable-to-signal conversion
            -- s_mem(conv_integer(i)) := "00000000";
            s_mem(conv_integer(i)) <= "00000000";
        end loop;
        index := 0;
        while not endfile(mem_file) loop
            readline(mem_file, L);
            for j in 0 to 3 loop
                result := 0;
                    for i in 1 to 2 loop
                        read(L, ch);
                        if '0' <= ch and ch <= '9' then 
                            result := result*16 + character'pos(ch)-character'pos('0');
                        elsif 'a' <= ch and ch <= 'f' then
                            result := result*16 + character'pos(ch)-character'pos('a')+10;
                        else report "Format error on line " & integer'image(index)
                            severity error;
                        end if;
                    end loop;
                -- variable-to-signal conversion
                -- s_mem(index*4+3-j) := conv_std_logic_vector(result, g_width);
                s_mem(index*4+3-j) <= conv_std_logic_vector(result, g_width);
            end loop;
            index := index + 1;
        end loop;

        -- read or write memory loop, sensitivity list below in a "wait"...
        loop

            -- write_stuff
            -- whahappens with 255, 254, 253 (adrbits=8)?? --> loops back xD
            if i_clk'event and i_clk = '1' then
                if (i_memWctrl = '1') then
                    if i_memWctrl8or32 = '0' then
                        -- variable-to-signal conversion
                        -- s_mem(conv_integer(i_adr))      := i_memWdata(7 downto 0);
                        s_mem(conv_integer(i_adr))      <= i_memWdata(7 downto 0);
                    else
                        -- variable-to-signal conversion
                        -- s_mem(conv_integer(i_adr + 3))  := i_memWdata(31 downto 24);
                        -- s_mem(conv_integer(i_adr + 2))  := i_memWdata(23 downto 16);
                        -- s_mem(conv_integer(i_adr + 1))  := i_memWdata(15 downto 8);
                        -- s_mem(conv_integer(i_adr))      := i_memWdata(7  downto 0);
                        s_mem(conv_integer(i_adr + 3))  <= i_memWdata(31 downto 24);
                        s_mem(conv_integer(i_adr + 2))  <= i_memWdata(23 downto 16);
                        s_mem(conv_integer(i_adr + 1))  <= i_memWdata(15 downto 8);
                        s_mem(conv_integer(i_adr))      <= i_memWdata(7  downto 0);
                    end if;
                end if;
            end if;

            -- read_stuff
            -- whahappens with 255, 254, 253 (adrbits=8)?? --> loops back xD
            o_memRdata <= s_mem(conv_integer(i_adr + 3))
                        & s_mem(conv_integer(i_adr + 2))
                        & s_mem(conv_integer(i_adr + 1))
                        & s_mem(conv_integer(i_adr));

            -- sensitivity list
            wait on i_clk, i_adr;

        end loop;

    end process;

end Behavioral; -- dmem
