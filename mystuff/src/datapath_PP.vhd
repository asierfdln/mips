----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: datapath_PP - Behavioral
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
use IEEE.STD_LOGIC_MISC.or_reduce;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath_PP is
    generic(
        g_width     : integer   := 32;  -- g_width-bit wide registers
        g_regbits   : integer   := 5;   -- 2**g_regbits number of registers
        g_struct    : integer   := 8;   -- byte-structured memory...
        g_adrbits   : integer   := 8    -- 2**g_adrbits number of g_struct-bit positions in memory array
    );
    port(
        i_clk     : in  STD_LOGIC;
        i_reset   : in  STD_LOGIC -- reset is for PC...
    );
end datapath_PP;


-- MIPS datapath_PP


architecture Behavioral of datapath_PP is

    -- Debugging signals

    type instr_type is (
        instrADD,
        instrSUB,
        instrAND,
        instrOR,
        instrSLT,
        instrMUL,
        instrADDI,
        instrLDB,
        instrLDW,
        instrSTB,
        instrSTW,
        instrBEQ,
        instrJUMP,
        UNKNOWN
    );
    signal curr_instr_IF : instr_type;
    signal curr_instr_DE : instr_type;
    signal curr_instr_EX : instr_type;
    signal curr_instr_ME : instr_type;
    signal curr_instr_WB : instr_type;


    -- Component declaration

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

    component register_file_PP is
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
    end component; -- register_file_PP

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

    component flopenr_1bit is
        port(
            i_clk   : in  STD_LOGIC;
            i_reset : in  STD_LOGIC;
            i_wen   : in  STD_LOGIC;
            i_d     : in  STD_LOGIC;
            o_q     : out STD_LOGIC
        );
    end component; -- flopenr_1bit

    component mux3 is
        generic(
            g_width : integer := 32  -- g_width-bit wide registers
        );
        port(
            i_a   : in STD_LOGIC_VECTOR(g_width-1 downto 0);
            i_b   : in STD_LOGIC_VECTOR(g_width-1 downto 0);
            i_c   : in STD_LOGIC_VECTOR(g_width-1 downto 0);
            i_sel : in STD_LOGIC_VECTOR(1 downto 0);
            o_res : out STD_LOGIC_VECTOR(g_width-1 downto 0)
        );
    end component; -- mux3

    component hazard_unit is
        generic(
            g_width   : integer   := 32;  -- g_width-bit wide registers
            g_regbits : integer   := 5    -- 2**g_regbits number of registers
        );
        port(
            -- MEorWB_toEX_ALUoperands A and B
            i_reg2_addr_EX               : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_reg3_addr_EX               : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_regf_writeregaddr_ME       : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_regfile_wen_ME             : in  STD_LOGIC;
            i_regf_writeregaddr_WB       : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_regfile_wen_WB             : in  STD_LOGIC;
            o_MEorWB_toEX_ALUoperandA_EX : out STD_LOGIC_VECTOR(1 downto 0);
            o_MEorWB_toEX_ALUoperandB_EX : out STD_LOGIC_VECTOR(1 downto 0);
            -- load-arith stall PC, stall IFDE and clear DEEX
            i_regf_writeregaddr_EX       : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_reg2_addr_DE               : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_reg3_addr_DE               : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_wbsrc_ctrl_EX              : in  STD_LOGIC;
            o_stall_PC                   : out STD_LOGIC;
            o_stall_IFDE_PPregs          : out STD_LOGIC;
            o_clear_DEEX_PPregs          : out STD_LOGIC;
            -- BEQstallstuff
            i_beqsrc_ctrl_DE             : in  STD_LOGIC;
            i_regfile_wen_EX             : in  STD_LOGIC;
            i_wbsrc_ctrl_ME              : in  STD_LOGIC;
            o_ME_toDE_regcontents2_DE    : out STD_LOGIC;
            o_ME_toDE_regcontents3_DE    : out STD_LOGIC;
            -- ArithLoadSTORE stuff
            i_wbsrc_ctrl_WB              : in  STD_LOGIC;
            o_MEorWB_toEX_memWdata_EX    : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component; -- hazard_unit


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
        -- signal s_pcp4orbranch_value                 : STD_LOGIC_VECTOR(g_width-1 downto 0);
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


    -- Pipeline stage signals
        -- IF-DE
    signal s_IF_reset                    : STD_LOGIC;
    signal s_IF_wen                      : STD_LOGIC;
        signal s_pcreg_outvalue_DE       : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_pcreg_outvalue_plus4_DE : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_imem_outdata_DE         : STD_LOGIC_VECTOR(g_width-1 downto 0);
            signal s_changepcval         : STD_LOGIC;
            signal s_beqorjmp            : STD_LOGIC_VECTOR(g_width-1 downto 0);
        -- DE-EX
    signal s_DE_reset                                  : STD_LOGIC;
    signal s_DE_wen                                    : STD_LOGIC;
        signal s_regfile_wen_EX                        : STD_LOGIC;
        signal s_dmem_memWctrl_EX                      : STD_LOGIC;
        signal s_dmem_memctrl8or32_EX                  : STD_LOGIC;
        signal s_wbsrc_ctrl_EX                         : STD_LOGIC;
        signal s_alusrc_ctrl_EX                        : STD_LOGIC;
        signal s_alunit_ctrl_EX                        : STD_LOGIC_VECTOR(s_alunit_ctrl'length-1 downto 0);
        signal s_regfile_reg2out_EX                    : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_regfile_reg3out_EX                    : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_pcreg_outvalue_EX                     : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_regf_writeregaddr_EX                  : STD_LOGIC_VECTOR(g_regbits-1 downto 0);
        signal s_imem_instrMtype_offset32bit_EX        : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_imem_outdata_EX                       : STD_LOGIC_VECTOR(g_width-1 downto 0);
            signal s_regfoutssame                      : STD_LOGIC;
        -- EX-ME
    signal s_EX_reset                    : STD_LOGIC;
    signal s_EX_wen                      : STD_LOGIC;
        signal s_regfile_wen_ME          : STD_LOGIC;
        signal s_dmem_memWctrl_ME        : STD_LOGIC;
        signal s_dmem_memctrl8or32_ME    : STD_LOGIC;
        signal s_wbsrc_ctrl_ME           : STD_LOGIC;
        signal s_pcreg_outvalue_ME       : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_regf_writeregaddr_ME    : STD_LOGIC_VECTOR(g_regbits-1 downto 0);
        signal s_alunit_outval_ME        : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_regfile_reg3out_ME      : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_imem_outdata_ME         : STD_LOGIC_VECTOR(g_width-1 downto 0);
        -- ME-WB
    signal s_ME_reset                    : STD_LOGIC;
    signal s_ME_wen                      : STD_LOGIC;
        signal s_regfile_wen_WB          : STD_LOGIC;
        signal s_wbsrc_ctrl_WB           : STD_LOGIC;
        signal s_pcreg_outvalue_WB       : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_regf_writeregaddr_WB    : STD_LOGIC_VECTOR(g_regbits-1 downto 0);
        signal s_dmem_outdata_WB         : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_alunit_outval_WB        : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_imem_outdata_WB         : STD_LOGIC_VECTOR(g_width-1 downto 0);


    -- Hazard unit signals and deriv. signals
        -- stalls and clears
        signal s_stall_PC                   : STD_LOGIC;
        signal s_stall_IFDE_PPregs          : STD_LOGIC;
        signal s_clear_DEEX_PPregs          : STD_LOGIC;
        -- IF-DE
        -- DE-EX
        signal s_reg2_addr_EX               : STD_LOGIC_VECTOR(g_regbits-1 downto 0);
        signal s_reg3_addr_EX               : STD_LOGIC_VECTOR(g_regbits-1 downto 0);
        signal s_MEorWB_toEX_ALUoperandA_EX : STD_LOGIC_VECTOR(1 downto 0);
        signal s_MEorWB_toEX_ALUoperandB_EX : STD_LOGIC_VECTOR(1 downto 0);
            signal s_aluopA_hazardmuxout    : STD_LOGIC_VECTOR(g_width-1 downto 0);
            signal s_aluopB_hazardmuxout    : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_ME_toDE_regcontents2_DE    : STD_LOGIC;
        signal s_ME_toDE_regcontents3_DE    : STD_LOGIC;
            signal s_beqopA                 : STD_LOGIC_VECTOR(g_width-1 downto 0);
            signal s_beqopB                 : STD_LOGIC_VECTOR(g_width-1 downto 0);
        signal s_MEorWB_toEX_memWdata_EX    : STD_LOGIC_VECTOR(1 downto 0);
            signal s_memWdatamuxEXout_EX        : STD_LOGIC_VECTOR(g_width-1 downto 0);
        -- EX-ME
        -- ME-WB

begin

    -- Pipeline registers --> IF-DE

        s_IF_reset  <= i_reset or '0' or (s_changepcval and not s_stall_IFDE_PPregs);
        s_IF_wen    <= '1' and (not s_stall_IFDE_PPregs);

            r_pcreg_outvalue_plus4_DE : flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,                    -- : in  STD_LOGIC;
                    i_reset => s_IF_reset,               -- : in  STD_LOGIC;
                    i_wen   => s_IF_wen,                 -- : in  STD_LOGIC;
                    i_d     => s_pcreg_outvalue_plus4,   -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_pcreg_outvalue_plus4_DE -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_pcreg_outvalue_DE : flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,              -- : in  STD_LOGIC;
                    i_reset => s_IF_reset,         -- : in  STD_LOGIC;
                    i_wen   => s_IF_wen,           -- : in  STD_LOGIC;
                    i_d     => s_pcreg_outvalue,   -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_pcreg_outvalue_DE -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_imem_outdata_DE : flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,            -- : in  STD_LOGIC;
                    i_reset => s_IF_reset,       -- : in  STD_LOGIC;
                    i_wen   => s_IF_wen,         -- : in  STD_LOGIC;
                    i_d     => s_imem_outdata,   -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_imem_outdata_DE -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

    -- Pipeline registers --> DE-EX

        s_DE_reset  <= i_reset or s_clear_DEEX_PPregs;
        s_DE_wen    <= '1';

            r_regfile_wen_EX: flopenr_1bit
                port map(
                    i_clk   => i_clk,            -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,       -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,         -- : in  STD_LOGIC;
                    i_d     => s_regfile_wen,    -- : in  STD_LOGIC;
                    o_q     => s_regfile_wen_EX  -- : out STD_LOGIC
                );

            r_dmem_memWctrl_EX: flopenr_1bit
                port map(
                    i_clk   => i_clk,              -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,         -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,           -- : in  STD_LOGIC;
                    i_d     => s_dmem_memWctrl,    -- : in  STD_LOGIC;
                    o_q     => s_dmem_memWctrl_EX  -- : out STD_LOGIC
                );

            r_dmem_memctrl8or32_EX: flopenr_1bit
                port map(
                    i_clk   => i_clk,                  -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,             -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,               -- : in  STD_LOGIC;
                    i_d     => s_dmem_memctrl8or32,    -- : in  STD_LOGIC;
                    o_q     => s_dmem_memctrl8or32_EX  -- : out STD_LOGIC
                );

            r_wbsrc_ctrl_EX: flopenr_1bit
                port map(
                    i_clk   => i_clk,           -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,      -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,        -- : in  STD_LOGIC;
                    i_d     => s_wbsrc_ctrl,    -- : in  STD_LOGIC;
                    o_q     => s_wbsrc_ctrl_EX  -- : out STD_LOGIC
                );

            r_pcreg_outvalue_EX : flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,               -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,          -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,            -- : in  STD_LOGIC;
                    i_d     => s_pcreg_outvalue_DE, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_pcreg_outvalue_EX  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_regf_writeregaddr_EX : flopenr
                generic map(
                    g_width => g_regbits -- : integer
                )
                port map(
                    i_clk   => i_clk,                           -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,                      -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,                        -- : in  STD_LOGIC;
                    -- TODO this is hardcoded, use g_regbits and mapping info...
                    i_d     => s_imem_outdata_DE(24 downto 20), -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_regf_writeregaddr_EX           -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_alusrc_ctrl_EX: flopenr_1bit
                port map(
                    i_clk   => i_clk,            -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,       -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,         -- : in  STD_LOGIC;
                    i_d     => s_alusrc_ctrl,    -- : in  STD_LOGIC;
                    o_q     => s_alusrc_ctrl_EX  -- : out STD_LOGIC
                );

            r_alunit_ctrl_EX: flopenr
                generic map(
                    g_width => s_alunit_ctrl'length -- : integer
                )
                port map(
                    i_clk   => i_clk,            -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,       -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,         -- : in  STD_LOGIC;
                    i_d     => s_alunit_ctrl,    -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_alunit_ctrl_EX  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_regfile_reg2out_EX: flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,                -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,           -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,             -- : in  STD_LOGIC;
                    i_d     => s_regfile_reg2out,    -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_regfile_reg2out_EX  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_regfile_reg3out_EX: flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,                -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,           -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,             -- : in  STD_LOGIC;
                    i_d     => s_regfile_reg3out,    -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_regfile_reg3out_EX  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_imem_instrMtype_offset32bit_EX: flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,                            -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,                       -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,                         -- : in  STD_LOGIC;
                    i_d     => s_imem_instrMtype_offset32bit,    -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_imem_instrMtype_offset32bit_EX  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_imem_outdata_EX : flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,             -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,        -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,          -- : in  STD_LOGIC;
                    i_d     => s_imem_outdata_DE, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_imem_outdata_EX  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

    -- Pipeline registers --> EX-ME

        s_EX_reset  <= i_reset or '0';
        s_EX_wen    <= '1';

            r_regfile_wen_ME: flopenr_1bit
                port map(
                    i_clk   => i_clk,            -- : in  STD_LOGIC;
                    i_reset => s_EX_reset,       -- : in  STD_LOGIC;
                    i_wen   => s_EX_wen,         -- : in  STD_LOGIC;
                    i_d     => s_regfile_wen_EX, -- : in  STD_LOGIC;
                    o_q     => s_regfile_wen_ME  -- : out STD_LOGIC
                );

            r_dmem_memWctrl_ME: flopenr_1bit
                port map(
                    i_clk   => i_clk,              -- : in  STD_LOGIC;
                    i_reset => s_EX_reset,         -- : in  STD_LOGIC;
                    i_wen   => s_EX_wen,           -- : in  STD_LOGIC;
                    i_d     => s_dmem_memWctrl_EX, -- : in  STD_LOGIC;
                    o_q     => s_dmem_memWctrl_ME  -- : out STD_LOGIC
                );

            r_dmem_memctrl8or32_ME: flopenr_1bit
                port map(
                    i_clk   => i_clk,                  -- : in  STD_LOGIC;
                    i_reset => s_EX_reset,             -- : in  STD_LOGIC;
                    i_wen   => s_EX_wen,               -- : in  STD_LOGIC;
                    i_d     => s_dmem_memctrl8or32_EX, -- : in  STD_LOGIC;
                    o_q     => s_dmem_memctrl8or32_ME  -- : out STD_LOGIC
                );

            r_wbsrc_ctrl_ME: flopenr_1bit
                port map(
                    i_clk   => i_clk,           -- : in  STD_LOGIC;
                    i_reset => s_EX_reset,      -- : in  STD_LOGIC;
                    i_wen   => s_EX_wen,        -- : in  STD_LOGIC;
                    i_d     => s_wbsrc_ctrl_EX, -- : in  STD_LOGIC;
                    o_q     => s_wbsrc_ctrl_ME  -- : out STD_LOGIC
                );

            r_pcreg_outvalue_ME : flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,               -- : in  STD_LOGIC;
                    i_reset => s_EX_reset,          -- : in  STD_LOGIC;
                    i_wen   => s_EX_wen,            -- : in  STD_LOGIC;
                    i_d     => s_pcreg_outvalue_EX, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_pcreg_outvalue_ME  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_regf_writeregaddr_ME : flopenr
                generic map(
                    g_width => g_regbits -- : integer
                )
                port map(
                    i_clk   => i_clk,                  -- : in  STD_LOGIC;
                    i_reset => s_EX_reset,             -- : in  STD_LOGIC;
                    i_wen   => s_EX_wen,               -- : in  STD_LOGIC;
                    i_d     => s_regf_writeregaddr_EX, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_regf_writeregaddr_ME  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_alunit_outval_ME : flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,              -- : in  STD_LOGIC;
                    i_reset => s_EX_reset,         -- : in  STD_LOGIC;
                    i_wen   => s_EX_wen,           -- : in  STD_LOGIC;
                    i_d     => s_alunit_outval,    -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_alunit_outval_ME  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_regfile_reg3out_ME: flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,                -- : in  STD_LOGIC;
                    i_reset => s_EX_reset,           -- : in  STD_LOGIC;
                    i_wen   => s_EX_wen,             -- : in  STD_LOGIC;
                    -- i_d     => s_regfile_reg3out_EX, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    i_d     => s_memWdatamuxEXout_EX, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_regfile_reg3out_ME  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_imem_outdata_ME : flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,             -- : in  STD_LOGIC;
                    i_reset => s_EX_reset,        -- : in  STD_LOGIC;
                    i_wen   => s_EX_wen,          -- : in  STD_LOGIC;
                    i_d     => s_imem_outdata_EX, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_imem_outdata_ME  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

    -- Pipeline registers --> ME-WB

        s_ME_reset  <= i_reset or '0';
        s_ME_wen    <= '1';

            r_regfile_wen_WB: flopenr_1bit
                port map(
                    i_clk   => i_clk,            -- : in  STD_LOGIC;
                    i_reset => s_ME_reset,       -- : in  STD_LOGIC;
                    i_wen   => s_ME_wen,         -- : in  STD_LOGIC;
                    i_d     => s_regfile_wen_ME, -- : in  STD_LOGIC;
                    o_q     => s_regfile_wen_WB  -- : out STD_LOGIC
                );

            r_wbsrc_ctrl_WB: flopenr_1bit
                port map(
                    i_clk   => i_clk,           -- : in  STD_LOGIC;
                    i_reset => s_ME_reset,      -- : in  STD_LOGIC;
                    i_wen   => s_ME_wen,        -- : in  STD_LOGIC;
                    i_d     => s_wbsrc_ctrl_ME, -- : in  STD_LOGIC;
                    o_q     => s_wbsrc_ctrl_WB  -- : out STD_LOGIC
                );

            r_pcreg_outvalue_WB : flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,               -- : in  STD_LOGIC;
                    i_reset => s_ME_reset,          -- : in  STD_LOGIC;
                    i_wen   => s_ME_wen,            -- : in  STD_LOGIC;
                    i_d     => s_pcreg_outvalue_ME, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_pcreg_outvalue_WB  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_regf_writeregaddr_WB : flopenr
                generic map(
                    g_width => g_regbits -- : integer
                )
                port map(
                    i_clk   => i_clk,                  -- : in  STD_LOGIC;
                    i_reset => s_ME_reset,             -- : in  STD_LOGIC;
                    i_wen   => s_ME_wen,               -- : in  STD_LOGIC;
                    i_d     => s_regf_writeregaddr_ME, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_regf_writeregaddr_WB  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_dmem_outdata_WB : flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,             -- : in  STD_LOGIC;
                    i_reset => s_ME_reset,        -- : in  STD_LOGIC;
                    i_wen   => s_ME_wen,          -- : in  STD_LOGIC;
                    i_d     => s_dmem_outdata,    -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_dmem_outdata_WB  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_alunit_outval_WB : flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,              -- : in  STD_LOGIC;
                    i_reset => s_ME_reset,         -- : in  STD_LOGIC;
                    i_wen   => s_ME_wen,           -- : in  STD_LOGIC;
                    i_d     => s_alunit_outval_ME, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_alunit_outval_WB  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_imem_outdata_WB : flopenr
                generic map(
                    g_width => g_width -- : integer
                )
                port map(
                    i_clk   => i_clk,             -- : in  STD_LOGIC;
                    i_reset => s_ME_reset,        -- : in  STD_LOGIC;
                    i_wen   => s_ME_wen,          -- : in  STD_LOGIC;
                    i_d     => s_imem_outdata_ME, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_imem_outdata_WB  -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

    -- Hazard unit pipeline registers --> IF-DE
    -- Hazard unit pipeline registers --> DE-EX

            r_reg2_addr_EX : flopenr
                generic map(
                    g_width => g_regbits -- : integer
                )
                port map(
                    i_clk   => i_clk,                           -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,                      -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,                        -- : in  STD_LOGIC;
                    -- TODO this is hardcoded, use g_regbits and mapping info...
                    i_d     => s_imem_outdata_DE(19 downto 15), -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_reg2_addr_EX                   -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

            r_reg3_addr_EX : flopenr
                generic map(
                    g_width => g_regbits -- : integer
                )
                port map(
                    i_clk   => i_clk,         -- : in  STD_LOGIC;
                    i_reset => s_DE_reset,    -- : in  STD_LOGIC;
                    i_wen   => s_DE_wen,      -- : in  STD_LOGIC;
                    i_d     => s_r1r3orr3r3,  -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
                    o_q     => s_reg3_addr_EX -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
                );

    -- Hazard unit pipeline registers --> EX-ME
    -- Hazard unit pipeline registers --> ME-WB

    -- Decoder
    decodunit : decoder
        port map(
            i_opcode            => s_imem_outdata_DE(31 downto 25), -- : in  STD_LOGIC_VECTOR(6 downto 0);
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
        s_pcreg_wen <= '1' and (not s_stall_PC);

        -- increase of PC by 4
        s_pcreg_outvalue_plus4 <= STD_LOGIC_VECTOR(unsigned(s_pcreg_outvalue) + 4);

        pcsrc : mux2 generic map(g_width) port map(s_pcreg_outvalue_plus4, s_beqorjmp, s_changepcval, s_pcreg_invalue);
            s_changepcval <= s_branchtaken or s_jmpsrc_ctrl;

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

        -- TODO this is hardcoded, use g_regbits and mapping info...
        r1r3src : mux2 generic map(g_regbits) port map(s_imem_outdata_DE(24 downto 20), s_imem_outdata_DE(14 downto 10), s_reg3src_ctrl, s_r1r3orr3r3);
            -- s_reg3src_ctrl <= '0'; -- mapped to decoder

        -- -- below magic trick does the same as below...
        -- s_imem_instrMtype_offset32bit(14 downto 0)                                  <= s_imem_outdata_DE(14 downto 0);
        -- s_imem_instrMtype_offset32bit(s_imem_instrMtype_offset32bit'left downto 15) <= (s_imem_instrMtype_offset32bit'left downto 15 => s_imem_outdata_DE(14));
        s_imem_instrMtype_offset32bit        <= STD_LOGIC_VECTOR(resize(signed(s_imem_outdata_DE(14 downto 0)), s_imem_instrMtype_offset32bit'length));
        s_imem_instrMtype_offset32bit_2shift <= STD_LOGIC_VECTOR(shift_left(unsigned(s_imem_instrMtype_offset32bit), 2));
        s_branchtarget                       <= STD_LOGIC_VECTOR(unsigned(s_pcreg_outvalue_plus4_DE) + unsigned(s_imem_instrMtype_offset32bit_2shift));

        -- beqsrc : mux2 generic map(g_width) port map(s_pcreg_outvalue_plus4_DE, s_branchtarget, s_branchtaken, s_pcp4orbranch_value);
        --     -- s_beqsrc_ctrl <= '0'; -- mapped to decoder

        s_jump_value <= s_pcreg_outvalue_plus4_DE(31 downto 27) & s_imem_outdata_DE(24 downto 0) & "00";

        jmpsrc : mux2 generic map(g_width) port map(s_branchtarget, s_jump_value, s_jmpsrc_ctrl, s_beqorjmp);


    -- Register file
    regfile : register_file_PP
        generic map(
            g_width   => g_width,  -- : integer
            g_regbits => g_regbits -- : integer
        )
        port map(
            i_clk           => i_clk,                        -- : in    STD_LOGIC;
            -- i_write_enable  => s_regfile_wen,                -- : in    STD_LOGIC;
            i_write_enable  => s_regfile_wen_WB,             -- : in    STD_LOGIC;
            -- TODO this is hardcoded, use g_regbits and mapping info...
            -- i_reg1_addr     => s_imem_outdata_DE(24 downto 20), -- : in    STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_reg1_addr     => s_regf_writeregaddr_WB,          -- : in    STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_reg2_addr     => s_imem_outdata_DE(19 downto 15), -- : in    STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_reg3_addr     => s_r1r3orr3r3,                 -- : in    STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_write_data    => s_datawb_regfile,             -- : in    STD_LOGIC_VECTOR(g_width-1 downto 0);
            o_reg2_contents => s_regfile_reg2out,            -- : out   STD_LOGIC_VECTOR(g_width-1 downto 0);
            o_reg3_contents => s_regfile_reg3out             -- : out   STD_LOGIC_VECTOR(g_width-1 downto 0)
        );
        -- s_regfile_wen <= '0'; -- mapped to decoder

        s_branchtaken <= s_regfoutssame and s_beqsrc_ctrl;
            -- s_regfoutssame <= not or_reduce(s_regfile_reg2out xor s_regfile_reg3out);
            s_regfoutssame <= not or_reduce(s_beqopA xor s_beqopB);
                beqopA : mux2 generic map(g_width) port map(s_regfile_reg2out, s_alunit_outval_ME, s_ME_toDE_regcontents2_DE, s_beqopA);
                beqopB : mux2 generic map(g_width) port map(s_regfile_reg3out, s_alunit_outval_ME, s_ME_toDE_regcontents3_DE, s_beqopB);

        alusrc : mux2 generic map(g_width) port map(s_aluopB_hazardmuxout, s_imem_instrMtype_offset32bit_EX, s_alusrc_ctrl_EX, s_alusrc_operand);
            -- s_alusrc_ctrl <= '0'; -- mapped to decoder

        aluopA : mux3 generic map(g_width) port map(s_regfile_reg2out_EX, s_datawb_regfile, s_alunit_outval_ME, s_MEorWB_toEX_ALUoperandA_EX, s_aluopA_hazardmuxout);
        aluopB : mux3 generic map(g_width) port map(s_regfile_reg3out_EX, s_datawb_regfile, s_alunit_outval_ME, s_MEorWB_toEX_ALUoperandB_EX, s_aluopB_hazardmuxout);

        memWdatamuxEX : mux3 generic map(g_width) port map(s_regfile_reg3out_EX, s_datawb_regfile, s_alunit_outval_ME, s_MEorWB_toEX_memWdata_EX, s_memWdatamuxEXout_EX);

    -- ALU
    alunit : alu
        generic map(
            g_width => g_width -- : integer
        )
        port map(
            i_a       => s_aluopA_hazardmuxout, -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
            i_b       => s_alusrc_operand,      -- : in  STD_LOGIC_VECTOR(g_width-1 downto 0);
            i_alucont => s_alunit_ctrl_EX,      -- : in  STD_LOGIC_VECTOR(2 downto 0);
            o_zerodet => s_alunit_zerodet,      -- : out STD_LOGIC;
            o_result  => s_alunit_outval        -- : out STD_LOGIC_VECTOR(g_width-1 downto 0)
        );
        -- s_alunit_ctrl <= "000"; -- mapped to decoder

        -- s_branchtaken <= s_alunit_zerodet and s_beqsrc_ctrl;

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
            i_adr          => s_alunit_outval_ME(g_adrbits-1 downto 0), -- : in    STD_LOGIC_VECTOR(g_adrbits-1 downto 0);
            i_memWctrl     => s_dmem_memWctrl_ME,                    -- : in    STD_LOGIC;
            i_memctrl8or32 => s_dmem_memctrl8or32_ME,                -- : in    STD_LOGIC;
            i_memWdata     => s_regfile_reg3out_ME,                  -- : in    STD_LOGIC_VECTOR(g_datawidth-1 downto 0);
            o_memRdata     => s_dmem_outdata                         -- : out   STD_LOGIC_VECTOR(g_datawidth-1 downto 0)
        );
        -- s_dmem_memWctrl     <= '0'; -- mapped to decoder
        -- s_dmem_memctrl8or32 <= '0'; -- mapped to decoder

        wbsrc : mux2 generic map(g_width) port map(s_dmem_outdata_WB, s_alunit_outval_WB, s_wbsrc_ctrl_WB, s_datawb_regfile);
            -- s_wbsrc_ctrl <= '0'; -- mapped to decoder

    hz_unit : hazard_unit
        generic map(
            g_width   => g_width,  -- : integer;
            g_regbits => g_regbits -- : integer
        )
        port map(
            -- MEorWB_toEX_ALUoperands A and B
            i_reg2_addr_EX               => s_reg2_addr_EX,               -- : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_reg3_addr_EX               => s_reg3_addr_EX,               -- : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_regf_writeregaddr_ME       => s_regf_writeregaddr_ME,       -- : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_regfile_wen_ME             => s_regfile_wen_ME,             -- : in  STD_LOGIC;
            i_regf_writeregaddr_WB       => s_regf_writeregaddr_WB,       -- : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_regfile_wen_WB             => s_regfile_wen_WB,             -- : in  STD_LOGIC;
            o_MEorWB_toEX_ALUoperandA_EX => s_MEorWB_toEX_ALUoperandA_EX, -- : out STD_LOGIC_VECTOR(1 downto 0);
            o_MEorWB_toEX_ALUoperandB_EX => s_MEorWB_toEX_ALUoperandB_EX, -- : out STD_LOGIC_VECTOR(1 downto 0)
            -- load-arith stall PC, stall IFDE and clear DEEX
            i_regf_writeregaddr_EX       => s_regf_writeregaddr_EX,          -- : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_reg2_addr_DE               => s_imem_outdata_DE(19 downto 15), -- : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_reg3_addr_DE               => s_r1r3orr3r3,                    -- : in  STD_LOGIC_VECTOR(g_regbits-1 downto 0);
            i_wbsrc_ctrl_EX              => s_wbsrc_ctrl_EX,                 -- : in  STD_LOGIC;
            o_stall_PC                   => s_stall_PC,                      -- : out STD_LOGIC;
            o_stall_IFDE_PPregs          => s_stall_IFDE_PPregs,             -- : out STD_LOGIC;
            o_clear_DEEX_PPregs          => s_clear_DEEX_PPregs,             -- : out STD_LOGIC;
            -- BEQstallstuff
            i_beqsrc_ctrl_DE             => s_beqsrc_ctrl,                   -- : in  STD_LOGIC;
            i_regfile_wen_EX             => s_regfile_wen_EX,                -- : in  STD_LOGIC;
            i_wbsrc_ctrl_ME              => s_wbsrc_ctrl_ME,                 -- : in  STD_LOGIC;
            o_ME_toDE_regcontents2_DE    => s_ME_toDE_regcontents2_DE,       -- : out STD_LOGIC;
            o_ME_toDE_regcontents3_DE    => s_ME_toDE_regcontents3_DE,       -- : out STD_LOGIC;
            -- ArithLoadSTORE stuff
            i_wbsrc_ctrl_WB              => s_wbsrc_ctrl_WB,          -- : in  STD_LOGIC;
            o_MEorWB_toEX_memWdata_EX    => s_MEorWB_toEX_memWdata_EX -- : out STD_LOGIC_VECTOR(1 downto 0)
        );



    IF_process : process(s_imem_outdata)
    begin
        case s_imem_outdata(31 downto 25) is
            when "0000000" => -- ADD 0x00
                curr_instr_IF <= instrADD;
            when "0000001" => -- SUB 0x01
                curr_instr_IF <= instrSUB;
            when "0000010" => -- AND 0x02
                curr_instr_IF <= instrAND;
            when "0000011" => -- OR 0x03
                curr_instr_IF <= instrOR;
            when "0000100" => -- SLT 0x04
                curr_instr_IF <= instrSLT;
            when "0000101" => -- MUL 0x05
                curr_instr_IF <= instrMUL;
            when "0000111" => -- ADDI 0x07
                curr_instr_IF <= instrADDI;
            when "0010000" => -- LDB 0x10
                curr_instr_IF <= instrLDB;
            when "0010001" => -- LDW 0x11
                curr_instr_IF <= instrLDW;
            when "0010010" => -- STB 0x12
                curr_instr_IF <= instrSTB;
            when "0010011" => -- STW 0x13
                curr_instr_IF <= instrSTW;
            when "0110000" => -- BEQ 0x30
                curr_instr_IF <= instrBEQ;
            when "0110001" => -- JUMP 0x31
                curr_instr_IF <= instrJUMP;
            when others =>
                curr_instr_IF <= UNKNOWN;
        end case;
    end process; -- IF_process

    DE_process : process(s_imem_outdata_DE)
    begin
        case s_imem_outdata_DE(31 downto 25) is
            when "0000000" => -- ADD 0x00
                curr_instr_DE <= instrADD;
            when "0000001" => -- SUB 0x01
                curr_instr_DE <= instrSUB;
            when "0000010" => -- AND 0x02
                curr_instr_DE <= instrAND;
            when "0000011" => -- OR 0x03
                curr_instr_DE <= instrOR;
            when "0000100" => -- SLT 0x04
                curr_instr_DE <= instrSLT;
            when "0000101" => -- MUL 0x05
                curr_instr_DE <= instrMUL;
            when "0000111" => -- ADDI 0x07
                curr_instr_DE <= instrADDI;
            when "0010000" => -- LDB 0x10
                curr_instr_DE <= instrLDB;
            when "0010001" => -- LDW 0x11
                curr_instr_DE <= instrLDW;
            when "0010010" => -- STB 0x12
                curr_instr_DE <= instrSTB;
            when "0010011" => -- STW 0x13
                curr_instr_DE <= instrSTW;
            when "0110000" => -- BEQ 0x30
                curr_instr_DE <= instrBEQ;
            when "0110001" => -- JUMP 0x31
                curr_instr_DE <= instrJUMP;
            when others =>
                curr_instr_DE <= UNKNOWN;
        end case;
    end process; -- DE_process

    EX_process : process(s_imem_outdata_EX)
    begin
        case s_imem_outdata_EX(31 downto 25) is
            when "0000000" => -- ADD 0x00
                curr_instr_EX <= instrADD;
            when "0000001" => -- SUB 0x01
                curr_instr_EX <= instrSUB;
            when "0000010" => -- AND 0x02
                curr_instr_EX <= instrAND;
            when "0000011" => -- OR 0x03
                curr_instr_EX <= instrOR;
            when "0000100" => -- SLT 0x04
                curr_instr_EX <= instrSLT;
            when "0000101" => -- MUL 0x05
                curr_instr_EX <= instrMUL;
            when "0000111" => -- ADDI 0x07
                curr_instr_EX <= instrADDI;
            when "0010000" => -- LDB 0x10
                curr_instr_EX <= instrLDB;
            when "0010001" => -- LDW 0x11
                curr_instr_EX <= instrLDW;
            when "0010010" => -- STB 0x12
                curr_instr_EX <= instrSTB;
            when "0010011" => -- STW 0x13
                curr_instr_EX <= instrSTW;
            when "0110000" => -- BEQ 0x30
                curr_instr_EX <= instrBEQ;
            when "0110001" => -- JUMP 0x31
                curr_instr_EX <= instrJUMP;
            when others =>
                curr_instr_EX <= UNKNOWN;
        end case;
    end process; -- EX_process

    ME_process : process(s_imem_outdata_ME)
    begin
        case s_imem_outdata_ME(31 downto 25) is
            when "0000000" => -- ADD 0x00
                curr_instr_ME <= instrADD;
            when "0000001" => -- SUB 0x01
                curr_instr_ME <= instrSUB;
            when "0000010" => -- AND 0x02
                curr_instr_ME <= instrAND;
            when "0000011" => -- OR 0x03
                curr_instr_ME <= instrOR;
            when "0000100" => -- SLT 0x04
                curr_instr_ME <= instrSLT;
            when "0000101" => -- MUL 0x05
                curr_instr_ME <= instrMUL;
            when "0000111" => -- ADDI 0x07
                curr_instr_ME <= instrADDI;
            when "0010000" => -- LDB 0x10
                curr_instr_ME <= instrLDB;
            when "0010001" => -- LDW 0x11
                curr_instr_ME <= instrLDW;
            when "0010010" => -- STB 0x12
                curr_instr_ME <= instrSTB;
            when "0010011" => -- STW 0x13
                curr_instr_ME <= instrSTW;
            when "0110000" => -- BEQ 0x30
                curr_instr_ME <= instrBEQ;
            when "0110001" => -- JUMP 0x31
                curr_instr_ME <= instrJUMP;
            when others =>
                curr_instr_ME <= UNKNOWN;
        end case;
    end process; -- ME_process

    WB_process : process(s_imem_outdata_WB)
    begin
        case s_imem_outdata_WB(31 downto 25) is
            when "0000000" => -- ADD 0x00
                curr_instr_WB <= instrADD;
            when "0000001" => -- SUB 0x01
                curr_instr_WB <= instrSUB;
            when "0000010" => -- AND 0x02
                curr_instr_WB <= instrAND;
            when "0000011" => -- OR 0x03
                curr_instr_WB <= instrOR;
            when "0000100" => -- SLT 0x04
                curr_instr_WB <= instrSLT;
            when "0000101" => -- MUL 0x05
                curr_instr_WB <= instrMUL;
            when "0000111" => -- ADDI 0x07
                curr_instr_WB <= instrADDI;
            when "0010000" => -- LDB 0x10
                curr_instr_WB <= instrLDB;
            when "0010001" => -- LDW 0x11
                curr_instr_WB <= instrLDW;
            when "0010010" => -- STB 0x12
                curr_instr_WB <= instrSTB;
            when "0010011" => -- STW 0x13
                curr_instr_WB <= instrSTW;
            when "0110000" => -- BEQ 0x30
                curr_instr_WB <= instrBEQ;
            when "0110001" => -- JUMP 0x31
                curr_instr_WB <= instrJUMP;
            when others =>
                curr_instr_WB <= UNKNOWN;
        end case;
    end process; -- WB_process

end Behavioral; -- datapath_PP
