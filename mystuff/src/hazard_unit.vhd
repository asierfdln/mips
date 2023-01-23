----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: hazard_unit - Behavioral
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
use IEEE.STD_LOGIC_MISC.or_reduce;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hazard_unit is
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
end hazard_unit;


-- Hazard unit for stalls and forwarding


architecture Behavioral of hazard_unit is

    -- MEorWB_toEX_ALUoperands A and B
    -- TODO CONST registeraddresszero := conv_std_logic_vector(0, g_regbits);

    -- load-arith stall PC, stall IFDE and clear DEEX
    signal s_load_arith_stall : STD_LOGIC;

    -- BEQstallstuff
    signal s_beq_stall : STD_LOGIC;

begin

    MEorWB_toEX_ALUoperandA_EX : process(
            i_reg2_addr_EX,
            i_regf_writeregaddr_ME,
            i_regfile_wen_ME,
            i_regf_writeregaddr_WB,
            i_regfile_wen_WB
        )
    begin

        -- if ((rsE != 0) AND (rsE == WriteRegM) AND RegWriteM) then
        --     ForwardAE = 10
        -- else if ((rsE != 0) AND (rsE == WriteRegW) AND RegWriteW) then
        --     ForwardAE = 01
        -- else
        --     ForwardAE = 00
            
        -- if i_reg2_addr_EX /= "00000" and i_reg2_addr_EX = i_regf_writeregaddr_ME and i_regfile_wen_ME = '1' then
        if i_reg2_addr_EX /= conv_std_logic_vector(0, g_regbits) and i_reg2_addr_EX = i_regf_writeregaddr_ME and i_regfile_wen_ME = '1' then
            o_MEorWB_toEX_ALUoperandA_EX <= "10"; -- put ME stuff into ALU
        -- elsif i_reg2_addr_EX /= "00000" and i_reg2_addr_EX = i_regf_writeregaddr_WB and i_regfile_wen_WB = '1' then
        elsif i_reg2_addr_EX /= conv_std_logic_vector(0, g_regbits) and i_reg2_addr_EX = i_regf_writeregaddr_WB and i_regfile_wen_WB = '1' then
            o_MEorWB_toEX_ALUoperandA_EX <= "01"; -- put WB stuff into ALU
        else
            o_MEorWB_toEX_ALUoperandA_EX <= "00"; -- default input into ALU
        end if;

    end process; -- MEorWB_toEX_ALUoperandA_EX

    MEorWB_toEX_ALUoperandB_EX : process(
            i_reg3_addr_EX,
            i_regf_writeregaddr_ME,
            i_regfile_wen_ME,
            i_regf_writeregaddr_WB,
            i_regfile_wen_WB
        )
    begin

        -- if ((rtE != 0) AND (rtE == WriteRegM) AND RegWriteM) then
        --     ForwardBE = 10
        -- else if ((rtE != 0) AND (rtE == WriteRegW) AND RegWriteW) then
        --     ForwardBE = 01
        -- else
        --     ForwardBE = 00
            
        -- if i_reg3_addr_EX /= "00000" and i_reg3_addr_EX = i_regf_writeregaddr_ME and i_regfile_wen_ME = '1' then
        if i_reg3_addr_EX /= conv_std_logic_vector(0, g_regbits) and i_reg3_addr_EX = i_regf_writeregaddr_ME and i_regfile_wen_ME = '1' then
            o_MEorWB_toEX_ALUoperandB_EX <= "10"; -- put ME stuff into ALU
        -- elsif i_reg3_addr_EX /= "00000" and i_reg3_addr_EX = i_regf_writeregaddr_WB and i_regfile_wen_WB = '1' then
        elsif i_reg3_addr_EX /= conv_std_logic_vector(0, g_regbits) and i_reg3_addr_EX = i_regf_writeregaddr_WB and i_regfile_wen_WB = '1' then
            o_MEorWB_toEX_ALUoperandB_EX <= "01"; -- put WB stuff into ALU
        else
            o_MEorWB_toEX_ALUoperandB_EX <= "00"; -- default input into ALU
        end if;

    end process; -- MEorWB_toEX_ALUoperandB_EX

    -- load-arith stall PC, stall IFDE and clear DEEX
        -- The code below does the following:
        --     s_load_arith_stall  <= ((i_regf_writeregaddr_EX == i_reg2_addr_DE) or (i_regf_writeregaddr_EX == i_reg3_addr_DE)) and (not i_wbsrc_ctrl_EX); -- "(not i_wbsrc_ctrl_EX)" implies LOAD, '0' routes dmem to regfile
        --         plus,
        --     "check that r1_EX is not 0" (relevant to resetting stuff and senseless LOADs...)
        --         -- this could also be accomplished by doing an OR(or_reduce(xor(reg{2,3}DE,0)))
    s_load_arith_stall <= 
        (
            (not or_reduce(i_regf_writeregaddr_EX xor i_reg2_addr_DE))
            or
            (not or_reduce(i_regf_writeregaddr_EX xor i_reg3_addr_DE))
        )
        and
        (not i_wbsrc_ctrl_EX) -- "(not i_wbsrc_ctrl_EX)" implies LOAD, '0' routes dmem to regfile
        and
        or_reduce(i_regf_writeregaddr_EX xor conv_std_logic_vector(0, g_regbits));



    o_ME_toDE_regcontents2_DE <= 
        (
            or_reduce(i_reg2_addr_DE xor conv_std_logic_vector(0, g_regbits))
        )
        and
        (
            not or_reduce(i_reg2_addr_DE xor i_regf_writeregaddr_ME)
        )
        and i_regfile_wen_ME; -- (rsD !=0) AND (rsD == WriteRegM) AND RegWriteM
    o_ME_toDE_regcontents3_DE <= 
        (
            or_reduce(i_reg3_addr_DE xor conv_std_logic_vector(0, g_regbits))
        )
        and
        (
            not or_reduce(i_reg3_addr_DE xor i_regf_writeregaddr_ME)
        )
        and i_regfile_wen_ME; -- (rtD !=0) AND (rtD == WriteRegM) AND RegWriteM

    -- BEQstallstuff
        -- stall the pipeline ({PC,IFDE}wen=0 and clear DEEX) if there is a branch at decode and:
        -- either...
        --     (1) there is an instruction in EX that will want to write into regfile
        --         and reg1addr_EX is either equal to reg2addr_DE or reg3addr_DE
        --     or
        --     (2) there is an instruction in ME that will want to write into regfile
        --         and reg1addr_ME is either equal to reg2addr_DE or reg3addr_DE
    s_beq_stall <= 
        -- BranchD
        i_beqsrc_ctrl_DE
        and
        (
            (
                -- check that we are not dealing with reg0...
                or_reduce(i_regf_writeregaddr_EX xor conv_std_logic_vector(0, g_regbits))
                and
                -- RegWriteE
                i_regfile_wen_EX
                and
                (
                    -- (WriteRegE == rsD)
                    (not or_reduce(i_regf_writeregaddr_EX xor i_reg2_addr_DE))
                    or
                    -- (WriteRegE == rtD)
                    (not or_reduce(i_regf_writeregaddr_EX xor i_reg3_addr_DE))
                )
            )
            or
            (
                -- check that we are not dealing with reg0...
                or_reduce(i_regf_writeregaddr_ME xor conv_std_logic_vector(0, g_regbits))
                and
                -- MemtoRegM
                (not i_wbsrc_ctrl_ME) -- "(not i_wbsrc_ctrl_ME)" implies LOAD, '0' routes dmem to regfile
                and
                (
                    -- (WriteRegM == rsD)
                    (not or_reduce(i_regf_writeregaddr_ME xor i_reg2_addr_DE))
                    or
                    -- (WriteRegM == rtD)
                    (not or_reduce(i_regf_writeregaddr_ME xor i_reg3_addr_DE))
                )
            )
        );

    -- ArithLoadSTORE stuff
    -- la señal del multiplexor del memWdata tiene que ser
        -- 10 cuando haya una operacion de alu justo delante en ME...
            -- cogemos el valor actualizado de reg3
            -- condicion: i_reg3_addr_EX /= conv_std_logic_vector(0, g_regbits) and i_reg3_addr_EX = i_regf_writeregaddr_ME and i_regfile_wen_ME = '1' and i_dmem_memWctrl_EX = '1'
        -- 01 cuando (no lo anterior y) haya (una load en WB o una arithopdist2)...
            -- cogemos el valor actualizado de reg3
            -- condicion: i_reg3_addr_EX /= conv_std_logic_vector(0, g_regbits) and i_reg3_addr_EX = i_regf_writeregaddr_WB and i_regfile_wen_WB = '1' and i_dmem_memWctrl_EX = '1'
        -- 00 por defecto si no se cumple alguna de las dos cosas anteriores
    MEorWB_toEX_memWdata_EX : process(
        i_reg3_addr_EX,
        i_regf_writeregaddr_ME,
        i_regfile_wen_ME,
        i_regf_writeregaddr_WB,
        i_wbsrc_ctrl_WB
    )
    begin

        -- if i_reg3_addr_EX /= conv_std_logic_vector(0, g_regbits) and i_reg3_addr_EX = i_regf_writeregaddr_ME and i_regfile_wen_ME = '1' and i_dmem_memWctrl_EX = '1' then
        if i_reg3_addr_EX /= conv_std_logic_vector(0, g_regbits) and i_reg3_addr_EX = i_regf_writeregaddr_ME and i_regfile_wen_ME = '1' then
            o_MEorWB_toEX_memWdata_EX <= "10"; -- use memWdata value from ARITHop in ME
        -- elsif i_reg3_addr_EX /= conv_std_logic_vector(0, g_regbits) and i_reg3_addr_EX = i_regf_writeregaddr_WB and i_regfile_wen_WB = '1' and i_dmem_memWctrl_EX = '1' then
        elsif i_reg3_addr_EX /= conv_std_logic_vector(0, g_regbits) and i_reg3_addr_EX = i_regf_writeregaddr_WB and i_regfile_wen_WB = '1' then
            o_MEorWB_toEX_memWdata_EX <= "01"; -- use memWdata value from LOADop or ARITHopdistance2 in WB
        else
            o_MEorWB_toEX_memWdata_EX <= "00"; -- use default memWdata value
        end if;

    end process; -- MEorWB_toEX_memWdata_EX



    -- stalls and clears
    o_stall_PC          <= s_load_arith_stall or s_beq_stall;
    o_stall_IFDE_PPregs <= s_load_arith_stall or s_beq_stall;
    o_clear_DEEX_PPregs <= s_load_arith_stall or s_beq_stall;

end Behavioral; -- hazard_unit
