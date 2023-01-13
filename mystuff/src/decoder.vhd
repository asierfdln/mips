----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: decoder - Behavioral
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

entity decoder is
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
end decoder;


-- Decoder, ALU control signals included


architecture Behavioral of decoder is

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
    signal curr_instr : instr_type;

begin

    only_process : process(i_opcode)
    begin
        case i_opcode is
            when "0000000" => -- ADD 0x00
                curr_instr          <= instrADD;
                o_jmpsrc_ctrl       <= '0';
                o_reg3src_ctrl      <= '1';
                o_regfile_wen       <= '1';
                o_alusrc_ctrl       <= '0';
                o_beqsrc_ctrl       <= '0';
                o_alunit_ctrl       <= "010";
                o_dmem_memWctrl     <= '0';
                o_dmem_memctrl8or32 <= '0';
                o_wbsrc_ctrl        <= '1';
            when "0000001" => -- SUB 0x01
                curr_instr           <= instrSUB;
                o_jmpsrc_ctrl        <= '0';
                o_reg3src_ctrl       <= '1';
                o_regfile_wen        <= '1';
                o_alusrc_ctrl        <= '0';
                o_beqsrc_ctrl        <= '0';
                o_alunit_ctrl        <= "110";
                o_dmem_memWctrl      <= '0';
                o_dmem_memctrl8or32 <= '0';
                o_wbsrc_ctrl         <= '1';
            when "0000010" => -- AND 0x02
                curr_instr          <= instrAND;
                o_jmpsrc_ctrl       <= '0';
                o_reg3src_ctrl      <= '1';
                o_regfile_wen       <= '1';
                o_alusrc_ctrl       <= '0';
                o_beqsrc_ctrl       <= '0';
                o_alunit_ctrl       <= "000";
                o_dmem_memWctrl     <= '0';
                o_dmem_memctrl8or32 <= '0';
                o_wbsrc_ctrl        <= '1';
            when "0000011" => -- OR 0x03
                curr_instr          <= instrOR;
                o_jmpsrc_ctrl       <= '0';
                o_reg3src_ctrl      <= '1';
                o_regfile_wen       <= '1';
                o_alusrc_ctrl       <= '0';
                o_beqsrc_ctrl       <= '0';
                o_alunit_ctrl       <= "001";
                o_dmem_memWctrl     <= '0';
                o_dmem_memctrl8or32 <= '0';
                o_wbsrc_ctrl        <= '1';
            when "0000100" => -- SLT 0x04
                curr_instr          <= instrSLT;
                o_jmpsrc_ctrl       <= '0';
                o_reg3src_ctrl      <= '1';
                o_regfile_wen       <= '1';
                o_alusrc_ctrl       <= '0';
                o_beqsrc_ctrl       <= '0';
                o_alunit_ctrl       <= "111";
                o_dmem_memWctrl     <= '0';
                o_dmem_memctrl8or32 <= '0';
                o_wbsrc_ctrl        <= '1';
            when "0000101" => -- MUL 0x05
                curr_instr          <= instrMUL;
                o_jmpsrc_ctrl       <= '0';
                o_reg3src_ctrl      <= '1';
                o_regfile_wen       <= '1';
                o_alusrc_ctrl       <= '0';
                o_beqsrc_ctrl       <= '0';
                o_alunit_ctrl       <= "011";
                o_dmem_memWctrl     <= '0';
                o_dmem_memctrl8or32 <= '0';
                o_wbsrc_ctrl        <= '1';
            when "0000111" => -- ADDI 0x07
                curr_instr          <= instrADDI;
                o_jmpsrc_ctrl       <= '0';
                o_reg3src_ctrl      <= '1';
                o_regfile_wen       <= '1';
                o_alusrc_ctrl       <= '1';
                o_beqsrc_ctrl       <= '0';
                o_alunit_ctrl       <= "010";
                o_dmem_memWctrl     <= '0';
                o_dmem_memctrl8or32 <= '0';
                o_wbsrc_ctrl        <= '1';
            when "0010000" => -- LDB 0x10
                curr_instr          <= instrLDB;
                o_jmpsrc_ctrl       <= '0';
                o_reg3src_ctrl      <= '1';
                o_regfile_wen       <= '1';
                o_alusrc_ctrl       <= '1';
                o_beqsrc_ctrl       <= '0';
                o_alunit_ctrl       <= "010";
                o_dmem_memWctrl     <= '0';
                o_dmem_memctrl8or32 <= '0';
                o_wbsrc_ctrl        <= '0';
            when "0010001" => -- LDW 0x11
                curr_instr          <= instrLDW;
                o_jmpsrc_ctrl       <= '0';
                o_reg3src_ctrl      <= '1';
                o_regfile_wen       <= '1';
                o_alusrc_ctrl       <= '1';
                o_beqsrc_ctrl       <= '0';
                o_alunit_ctrl       <= "010";
                o_dmem_memWctrl     <= '0';
                o_dmem_memctrl8or32 <= '1';
                o_wbsrc_ctrl        <= '0';
            when "0010010" => -- STB 0x12
                curr_instr          <= instrSTB;
                o_jmpsrc_ctrl       <= '0';
                o_reg3src_ctrl      <= '0';
                o_regfile_wen       <= '0';
                o_alusrc_ctrl       <= '1';
                o_beqsrc_ctrl       <= '0';
                o_alunit_ctrl       <= "010";
                o_dmem_memWctrl     <= '1';
                o_dmem_memctrl8or32 <= '0';
                o_wbsrc_ctrl        <= '0';
            when "0010011" => -- STW 0x13
                curr_instr          <= instrSTW;
                o_jmpsrc_ctrl       <= '0';
                o_reg3src_ctrl      <= '0';
                o_regfile_wen       <= '0';
                o_alusrc_ctrl       <= '1';
                o_beqsrc_ctrl       <= '0';
                o_alunit_ctrl       <= "010";
                o_dmem_memWctrl     <= '1';
                o_dmem_memctrl8or32 <= '1';
                o_wbsrc_ctrl        <= '0';
            when "0110000" => -- BEQ 0x30
                curr_instr          <= instrBEQ;
                o_jmpsrc_ctrl       <= '0';
                o_reg3src_ctrl      <= '0';
                o_regfile_wen       <= '0';
                o_alusrc_ctrl       <= '0';
                o_beqsrc_ctrl       <= '1';
                o_alunit_ctrl       <= "110";
                o_dmem_memWctrl     <= '0';
                o_dmem_memctrl8or32 <= '0';
                o_wbsrc_ctrl        <= '0';
            when "0110001" => -- JUMP 0x31
                curr_instr          <= instrJUMP;
                o_jmpsrc_ctrl       <= '1';
                o_reg3src_ctrl      <= '1';
                o_regfile_wen       <= '0';
                o_alusrc_ctrl       <= '0';
                o_beqsrc_ctrl       <= '0';
                o_alunit_ctrl       <= "000";
                o_dmem_memWctrl     <= '0';
                o_dmem_memctrl8or32 <= '0';
                o_wbsrc_ctrl        <= '0';
            when others =>
                curr_instr          <= UNKNOWN;
                o_jmpsrc_ctrl       <= '-';
                o_reg3src_ctrl      <= '-';
                o_regfile_wen       <= '-';
                o_alusrc_ctrl       <= '-';
                o_beqsrc_ctrl       <= '-';
                o_alunit_ctrl       <= "---";
                o_dmem_memWctrl     <= '-';
                o_dmem_memctrl8or32 <= '-';
                o_wbsrc_ctrl        <= '-';
        end case;
    end process; -- only_process

end Behavioral; -- decoder
