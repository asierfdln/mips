----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: imem - Behavioral
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

entity imem is
    generic(
        width   : integer   := 8;   -- byte-structured memory...
        adrbits : integer   := 8    -- 2**adrbits number of width-bit positions in memory array
    );
    port(
        clk             : in    STD_LOGIC;
        adr             : in    STD_LOGIC_VECTOR(adrbits-1 downto 0);
        memwrite        : in    STD_LOGIC;
        memwrite8or32   : in    STD_LOGIC;
        writedata       : in    STD_LOGIC_VECTOR(31 downto 0);
        memdata         : out   STD_LOGIC_VECTOR(31 downto 0)
    );
end imem;


-- NWeste: "external memory accessed by MIPS"
-- main-memory-like instruction memory data array thing, soon-to-be Icache...


architecture Behavioral of imem is

    -- see in process variables commented versions of "variable" type...
    -- do a CTRL+F of "variable-to-signal conversion"
    type ramtype is array (2**adrbits - 1 downto 0) of STD_LOGIC_VECTOR(width-1 downto 0);
    signal mem : ramtype;

begin

    process

        file        mem_file    : text open read_mode is "imem.dat";
        variable    L           : line;
        variable    ch          : character;
        variable    index       : integer;
        variable    result      : integer;
        -- type        ramtype is array (2**adrbits - 1 downto 0) of STD_LOGIC_VECTOR(width-1 downto 0);
        -- variable    mem         : ramtype;

    begin

        -- initialize memory from file
        -- memory in little-endian format
        -- 80020044 means mem[3] = 80 and mem[0] = 44

        for i in 0 to 255 loop -- set all contents low
            -- variable-to-signal conversion
            -- mem(conv_integer(i)) := "00000000";
            mem(conv_integer(i)) <= "00000000";
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
                -- mem(index*4+3-j) := conv_std_logic_vector(result, width);
                mem(index*4+3-j) <= conv_std_logic_vector(result, width);
            end loop;
            index := index + 1;
        end loop;

        -- read or write memory loop, sensitivity list below in a "wait"...
        loop

            -- write_stuff
            -- whahappens with 255, 254, 253 (regbits=8)?? --> loops back xD
            if clk'event and clk = '1' then
                if (memwrite = '1') then
                    if memwrite8or32 = '0' then
                        -- variable-to-signal conversion
                        -- mem(conv_integer(adr))      := writedata(7 downto 0);
                        mem(conv_integer(adr))      <= writedata(7 downto 0);
                    else
                        -- variable-to-signal conversion
                        -- mem(conv_integer(adr + 3))  := writedata(31 downto 24);
                        -- mem(conv_integer(adr + 2))  := writedata(23 downto 16);
                        -- mem(conv_integer(adr + 1))  := writedata(15 downto 8);
                        -- mem(conv_integer(adr))      := writedata(7  downto 0);
                        mem(conv_integer(adr + 3))  <= writedata(31 downto 24);
                        mem(conv_integer(adr + 2))  <= writedata(23 downto 16);
                        mem(conv_integer(adr + 1))  <= writedata(15 downto 8);
                        mem(conv_integer(adr))      <= writedata(7  downto 0);
                    end if;
                end if;
            end if;

            -- read_stuff
            -- whahappens with 255, 254, 253 (regbits=8)?? --> loops back xD
            if clk'event and clk = '1' then
                memdata <= mem(conv_integer(adr + 3))
                         & mem(conv_integer(adr + 2))
                         & mem(conv_integer(adr + 1))
                         & mem(conv_integer(adr));
            end if;

            -- sensitivity list
            wait on clk;

        end loop;

    end process;

end Behavioral; -- imem
