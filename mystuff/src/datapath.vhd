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
-- use IEEE.STD_LOGIC_UNSIGNED.all;
-- use IEEE.STD_LOGIC_ARITH.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath is
    generic(
        g_width     : integer   := 32;  -- g_width-bit wide registers
        g_regbits   : integer   := 5;   -- 2**g_regbits number of registers
        g_struct    : integer   := 8;   -- byte-structured memory...
     -- old parameter for {i,d}memories, register width is also width of memory data ports
     -- g_datawidth : integer   := 32;  -- width of data ports
        g_adrbits   : integer   := 8    -- 2**g_adrbits number of g_struct-bit positions in memory array
    );
    port(
        i_clk     : in  STD_LOGIC;
        i_reset   : in  STD_LOGIC -- reset is for PC...
    );
end datapath;


-- MIPS datapath


architecture Behavioral of datapath is

    component decoder is
        port(
            i_opcode            : in  STD_LOGIC_VECTOR(6 downto 0);
            o_jmpsrc_ctrl       : out STD_LOGIC;
            o_reg3src_ctrl      : out STD_LOGIC;
            o_regfile_wen       : out STD_LOGIC;
            o_alusrc_ctrl       : out STD_LOGIC;
            o_beqsrc_ctrl       : out STD_LOGIC;
            o_alunit_ctrl       : out STD_LOGIC_VECTOR(2 downto 0);
            o_dmem_memWctrl     : out STD_LOGIC;
            o_dmem_memctrl8or32 : out STD_LOGIC;
            o_wbsrc_ctrl        : out STD_LOGIC
        );
    end component; -- decoder

    component flopenr is
        generic(
            g_width : integer
        );
        port(
            i_clk   : in  STD_LOGIC;
            i_reset : in  STD_LOGIC;
            i_wen   : in  STD_LOGIC;
            i_d     : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
            o_q     : out STD_LOGIC_VECTOR(g_width-1 downto 0)
        );
    end component; -- flopenr

    component imem is
        generic(
            g_struct    : integer;
            g_datawidth : integer;
            g_adrbits   : integer
        );
        port(
            i_clk          : in  STD_LOGIC;
            i_adr          : in  STD_LOGIC_VECTOR(g_adrbits-1 downto 0);
            i_memWctrl     : in  STD_LOGIC;
            i_memctrl8or32 : in  STD_LOGIC;
            i_memWdata     : in  STD_LOGIC_VECTOR(g_datawidth-1 downto 0);
            o_memRdata     : out STD_LOGIC_VECTOR(g_datawidth-1 downto 0)
        );
    end component; -- imem

    component register_file is
        generic(
            g_width   : integer;
            g_regbits : integer
        );
        port(
            i_clk           : in  STD_LOGIC;
            i_write_enable  : in  STD_LOGIC;
            i_reg1_addr     : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_reg2_addr     : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_reg3_addr     : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_write_data    : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
            o_reg2_contents : out STD_LOGIC_VECTOR(g_width-1 downto 0);
            o_reg3_contents : out STD_LOGIC_VECTOR(g_width-1 downto 0)
        );
    end component; -- register_file

    component alu is
        generic(
            g_width: integer
        );
        port(
            i_a       : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
            i_b       : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
            i_alucont : in  STD_LOGIC_VECTOR(2 downto 0);
            o_zerodet : out STD_LOGIC;
            o_result  : out STD_LOGIC_VECTOR(g_width-1 downto 0)
        );
    end component; -- alu

    component dmem is
        generic(
            g_struct    : integer;
            g_datawidth : integer;
            g_adrbits   : integer
        );
        port(
            i_clk          : in  STD_LOGIC;
            i_adr          : in  STD_LOGIC_VECTOR(g_adrbits-1 downto 0);
            i_memWctrl     : in  STD_LOGIC;
            i_memctrl8or32 : in  STD_LOGIC;
            i_memWdata     : in  STD_LOGIC_VECTOR(g_datawidth-1 downto 0);
            o_memRdata     : out STD_LOGIC_VECTOR(g_datawidth-1 downto 0)
        );
    end component; -- dmem

    component mux2 is
        generic(
            g_width : integer := 32  -- g_width-bit wide registers
        );
        port(
            i_a   : in STD_LOGIC_VECTOR(g_width-1 downto 0);
            i_b   : in STD_LOGIC_VECTOR(g_width-1 downto 0);
            i_sel : in STD_LOGIC;
            o_res : out STD_LOGIC_VECTOR(g_width-1 downto 0)
        );
    end component; -- mux2

    -- PC register signals
    signal s_pcreg_wen      : STD_LOGIC;
    signal s_pcreg_invalue  : STD_LOGIC_VECTOR(g_width-1 downto 0);
    signal s_pcreg_outvalue : STD_LOGIC_VECTOR(g_width-1 downto 0);

        signal s_pcreg_outvalue_plus4 : STD_LOGIC_VECTOR(g_width-1 downto 0);


    -- Instruction memory signals
    signal s_imem_memWctrl     : STD_LOGIC;
    signal s_imem_memctrl8or32 : STD_LOGIC;
    signal s_imem_memWdata     : STD_LOGIC_VECTOR(g_width-1 downto 0);
    signal s_imem_outdata      : STD_LOGIC_VECTOR(g_width-1 downto 0);

        signal s_reg3src_ctrl                       : STD_LOGIC;
        signal s_r1r3orr3r3                         : STD_LOGIC_VECTOR(g_regbits-1 downto 0);
        signal s_imem_instrMtype_offset32bit        : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_imem_instrMtype_offset32bit_2shift : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_beqsrc_ctrl                        : STD_LOGIC;
        signal s_branchtarget                       : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_pcp4orbranch_value                 : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_jmpsrc_ctrl                        : STD_LOGIC;
        signal s_jump_value                         : STD_LOGIC_VECTOR(g_width-1 downto 0);


    -- Register file signals
    signal s_regfile_wen         : STD_LOGIC;
    signal s_regfile_reg2out     : STD_LOGIC_VECTOR(g_width-1 downto 0);
    signal s_regfile_reg3out     : STD_LOGIC_VECTOR(g_width-1 downto 0);

        signal s_alusrc_ctrl    : STD_LOGIC;
        signal s_alusrc_operand : STD_LOGIC_VECTOR(g_width-1 downto 0);


    -- ALU signals
    signal s_alunit_ctrl    : STD_LOGIC_VECTOR(2 downto 0);
    signal s_alunit_outval  : STD_LOGIC_VECTOR(g_width-1 downto 0);
    signal s_alunit_zerodet : STD_LOGIC;

        signal s_branchtaken : STD_LOGIC;


    -- Data memory signals
    signal s_dmem_memWctrl     : STD_LOGIC;
    signal s_dmem_memctrl8or32 : STD_LOGIC;
    signal s_dmem_outdata      : STD_LOGIC_VECTOR(g_width-1 downto 0);

        signal s_wbsrc_ctrl     : STD_LOGIC;
        signal s_datawb_regfile : STD_LOGIC_VECTOR(g_width-1 downto 0);


begin

    -- Decoder
    decodunit : decoder
        port map(
            i_opcode            => s_imem_outdata(31 downto 25), -- : in  STD_LOGIC_VECTOR(6 downto 0);
            o_jmpsrc_ctrl       => s_jmpsrc_ctrl,                -- : out STD_LOGIC;
            o_reg3src_ctrl      => s_reg3src_ctrl,               -- : out STD_LOGIC;
            o_regfile_wen       => s_regfile_wen,                -- : out STD_LOGIC;
            o_alusrc_ctrl       => s_alusrc_ctrl,                -- : out STD_LOGIC;
            o_beqsrc_ctrl       => s_beqsrc_ctrl,                -- : out STD_LOGIC;
            o_alunit_ctrl       => s_alunit_ctrl,                -- : out STD_LOGIC_VECTOR(2 downto 0);
            o_dmem_memWctrl     => s_dmem_memWctrl,              -- : out STD_LOGIC;
            o_dmem_memctrl8or32 => s_dmem_memctrl8or32,          -- : out STD_LOGIC;
            o_wbsrc_ctrl        => s_wbsrc_ctrl                  -- : out STD_LOGIC
        );


    -- PC register
    pc_register : flopenr
        generic map(
            g_width => g_width -- : integer
        )
        port map(
            i_clk   => i_clk,           -- : in  STD_LOGIC;
            i_reset => i_reset,         -- : in  STD_LOGIC;
            i_wen   => s_pcreg_wen,     -- : in  STD_LOGIC;
            i_d     => s_pcreg_invalue, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
            o_q     => s_pcreg_outvalue -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
        );
        s_pcreg_wen <= '1';

        -- increase of PC by 4
        s_pcreg_outvalue_plus4 <= STD_LOGIC_VECTOR(unsigned(s_pcreg_outvalue) + 4);


    -- Instruction memory
    instruction_mem : imem
        generic map(
            g_struct    => g_struct, -- : integer;
            g_datawidth => g_width,  -- : integer;
            g_adrbits   => g_adrbits -- : integer
        )
        port map(
            i_clk           => i_clk,                                  -- : in    STD_LOGIC;
            -- TODO this could break if i_adr has more bits than PC...
            i_adr          => s_pcreg_outvalue(g_adrbits-1 downto 0), -- : in    STD_LOGIC_VECTOR(g_adrbits-1 downto 0);
            i_memWctrl     => s_imem_memWctrl,                        -- : in    STD_LOGIC;
            i_memctrl8or32 => s_imem_memctrl8or32,                    -- : in    STD_LOGIC;
            i_memWdata     => s_imem_memWdata,                        -- : in    STD_LOGIC_VECTOR(g_datawidth-1 downto 0);
            o_memRdata     => s_imem_outdata                          -- : out   STD_LOGIC_VECTOR(g_datawidth-1 downto 0)
        );
        s_imem_memWctrl     <= '0';                                       -- TODO caches stuff, if time...
        s_imem_memctrl8or32 <= '1';                                       -- TODO caches stuff, if time...
        s_imem_memWdata     <= STD_LOGIC_VECTOR(to_unsigned(0, g_width)); -- TODO caches stuff, if time...

        r1r3src : mux2 generic map(g_regbits) port map(s_imem_outdata(24 downto 20), s_imem_outdata(14 downto 10), s_reg3src_ctrl, s_r1r3orr3r3);
            -- s_reg3src_ctrl <= '0'; -- mapped to decoder

        -- -- below magic trick does the same as below...
        -- s_imem_instrMtype_offset32bit(14 downto 0)                                  <= s_imem_outdata(14 downto 0);
        -- s_imem_instrMtype_offset32bit(s_imem_instrMtype_offset32bit'left downto 15) <= (s_imem_instrMtype_offset32bit'left downto 15 => s_imem_outdata(14));
        s_imem_instrMtype_offset32bit        <= STD_LOGIC_VECTOR(resize(signed(s_imem_outdata(14 downto 0)), s_imem_instrMtype_offset32bit'length));
        s_imem_instrMtype_offset32bit_2shift <= STD_LOGIC_VECTOR(shift_left(unsigned(s_imem_instrMtype_offset32bit), 2));
        s_branchtarget                       <= STD_LOGIC_VECTOR(unsigned(s_pcreg_outvalue_plus4) + unsigned(s_imem_instrMtype_offset32bit_2shift));

        beqsrc : mux2 generic map(g_width) port map(s_pcreg_outvalue_plus4, s_branchtarget, s_branchtaken, s_pcp4orbranch_value);
            -- s_beqsrc_ctrl <= '0'; -- mapped to decoder

        s_jump_value <= s_pcreg_outvalue_plus4(31 downto 27) & s_imem_outdata(24 downto 0) & "00";

        jmpsrc : mux2 generic map(g_width) port map(s_pcp4orbranch_value, s_jump_value, s_jmpsrc_ctrl, s_pcreg_invalue);


    -- Register file
    regfile : register_file
        generic map(
            g_width   => g_width,  -- : integer
            g_regbits => g_regbits -- : integer
        )
        port map(
            i_clk           => i_clk,                        -- : in    STD_LOGIC;
            i_write_enable  => s_regfile_wen,                -- : in    STD_LOGIC;
            i_reg1_addr     => s_imem_outdata(24 downto 20), -- : in    STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_reg2_addr     => s_imem_outdata(19 downto 15), -- : in    STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_reg3_addr     => s_r1r3orr3r3,                 -- : in    STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_write_data    => s_datawb_regfile,             -- : in    STD_LOGIC_VECTOR(g_width-1 downto 0);
            o_reg2_contents => s_regfile_reg2out,            -- : out   STD_LOGIC_VECTOR(g_width-1 downto 0);
            o_reg3_contents => s_regfile_reg3out             -- : out   STD_LOGIC_VECTOR(g_width-1 downto 0)
        );
        -- s_regfile_wen <= '0'; -- mapped to decoder

        alusrc : mux2 generic map(g_width) port map(s_regfile_reg3out, s_imem_instrMtype_offset32bit, s_alusrc_ctrl, s_alusrc_operand);
            -- s_alusrc_ctrl <= '0'; -- mapped to decoder


    -- ALU
    alunit : alu
        generic map(
            g_width => g_width -- : integer
        )
        port map(
            i_a       => s_regfile_reg2out, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
            i_b       => s_alusrc_operand,  -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
            i_alucont => s_alunit_ctrl,     -- : in  STD_LOGIC_VECTOR(2 downto 0);
            o_zerodet => s_alunit_zerodet,  -- : out STD_LOGIC;
            o_result  => s_alunit_outval    -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
        );
        -- s_alunit_ctrl <= "000"; -- mapped to decoder

        s_branchtaken <= s_alunit_zerodet and s_beqsrc_ctrl;


    -- Data memory
    data_mem : dmem
        generic map(
            g_struct    => g_struct, -- : integer;
            g_datawidth => g_width,  -- : integer;
            g_adrbits   => g_adrbits -- : integer
        )
        port map(
            i_clk           => i_clk,                                 -- : in    STD_LOGIC;
            -- TODO this could break if i_adr has more bits than s_alunit_outval...
            i_adr          => s_alunit_outval(g_adrbits-1 downto 0), -- : in    STD_LOGIC_VECTOR(g_adrbits-1 downto 0);
            i_memWctrl     => s_dmem_memWctrl,                       -- : in    STD_LOGIC;
            i_memctrl8or32 => s_dmem_memctrl8or32,                   -- : in    STD_LOGIC;
            i_memWdata     => s_regfile_reg3out,                     -- : in    STD_LOGIC_VECTOR(g_datawidth-1 downto 0);
            o_memRdata     => s_dmem_outdata                         -- : out   STD_LOGIC_VECTOR(g_datawidth-1 downto 0)
        );
        -- s_dmem_memWctrl     <= '0'; -- mapped to decoder
        -- s_dmem_memctrl8or32 <= '0'; -- mapped to decoder

        wbsrc : mux2 generic map(g_width) port map(s_dmem_outdata, s_alunit_outval, s_wbsrc_ctrl, s_datawb_regfile);
            -- s_wbsrc_ctrl <= '0'; -- mapped to decoder

end Behavioral; -- datapath
