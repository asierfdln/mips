----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: datapath - Behavioral
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

entity datapath is
    generic(
        g_width     : integer   := 32;  -- g_width-bit wide registers
        g_regbits   : integer   := 5;   -- 2**g_regbits number of registers
        g_memwidth  : integer   := 8;   -- byte-structured memory...
        g_adrbits   : integer   := 8    -- 2**g_adrbits number of g_memwidth-bit positions in memory array
    );
    port(
        i_clk     : in  STD_LOGIC;
        i_reset   : in  STD_LOGIC -- reset is for PC...
    );
end datapath;


-- MIPS datapath


architecture Behavioral of datapath is

    component flopenr is
        generic(
            g_width   : integer
        );
        port(
            i_clk     : in  STD_LOGIC;
            i_reset   : in  STD_LOGIC;
            i_wen     : in  STD_LOGIC;
            i_d       : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
            o_q       : out STD_LOGIC_VECTOR(g_width-1 downto 0)
        );
    end component; -- flopenr

    component imem is
        generic(
            g_width   : integer;
            g_adrbits : integer
        );
        port(
            i_clk             : in    STD_LOGIC;
            i_adr             : in    STD_LOGIC_VECTOR(g_adrbits-1 downto 0);
            i_memWctrl        : in    STD_LOGIC;
            i_memWctrl8or32   : in    STD_LOGIC;
            i_memWdata        : in    STD_LOGIC_VECTOR(31 downto 0);
            o_memRdata        : out   STD_LOGIC_VECTOR(31 downto 0)
        );
    end component; -- imem

    -- PC register signals
    signal s_pc_register_outvalue       : STD_LOGIC_VECTOR(g_width-1 downto 0);
    signal s_pc_register_invalue        : STD_LOGIC_VECTOR(g_width-1 downto 0);
    signal s_pc_register_writeenable    : STD_LOGIC;

    -- Instruction memory signals
    signal dummy_o_memRdata             : STD_LOGIC_VECTOR(31 downto 0);

begin

    -- increase of PC
    s_pc_register_invalue <= s_pc_register_outvalue + 4;

    -- PC register
    pc_register : flopenr
        generic map(
            g_width => g_width
        )
        port map(
            i_clk   => i_clk,
            i_reset => i_reset,
            i_wen   => '1',
            i_d     => s_pc_register_invalue,
            o_q     => s_pc_register_outvalue
        );

    -- Instruction memory
    instruction_mem : imem
        generic map(
            g_width     => g_memwidth,
            g_adrbits   => g_adrbits
        )
        port map(
            i_clk           => i_clk,
            i_adr           => s_pc_register_outvalue(g_adrbits-1 downto 0),
            i_memWctrl      => '0',
            i_memWctrl8or32 => '0',
            i_memWdata      => conv_std_logic_vector(0, 32),
            o_memRdata      => dummy_o_memRdata
        );

end Behavioral; -- datapath
