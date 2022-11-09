----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: register_file_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_file_tb is
    generic(
        ent_width   : integer   := 32;  -- width-bit wide registers
        ent_regbits : integer   := 5    -- 2**regbits number of registers
    );
end register_file_tb;


-- three-ported register file
-- read two ports on rising edge of clock
-- write third port on rising edge of clock


architecture Behavioral of register_file_tb is

    component register_file is
        generic(
            width   : integer;
            regbits : integer
        );
        port(
            i_clk           : in    STD_LOGIC;
            i_write_enable  : in    STD_LOGIC;
            i_reg1_addr     : in    STD_LOGIC_VECTOR(regbits-1 downto 0);
            i_reg2_addr     : in    STD_LOGIC_VECTOR(regbits-1 downto 0);
            i_reg3_addr     : in    STD_LOGIC_VECTOR(regbits-1 downto 0);
            i_write_data    : in    STD_LOGIC_VECTOR(width-1 downto 0);
            o_reg2_contents : out   STD_LOGIC_VECTOR(width-1 downto 0);
            o_reg3_contents : out   STD_LOGIC_VECTOR(width-1 downto 0)
        );
    end component; -- register_file

    signal s_clk            : STD_LOGIC;
    signal s_write_enable   : STD_LOGIC;
    signal s_reg1_addr      : STD_LOGIC_VECTOR(ent_regbits-1 downto 0);
    signal s_reg2_addr      : STD_LOGIC_VECTOR(ent_regbits-1 downto 0);
    signal s_reg3_addr      : STD_LOGIC_VECTOR(ent_regbits-1 downto 0);
    signal s_write_data     : STD_LOGIC_VECTOR(ent_width-1 downto 0);
    signal s_reg2_contents  : STD_LOGIC_VECTOR(ent_width-1 downto 0);
    signal s_reg3_contents  : STD_LOGIC_VECTOR(ent_width-1 downto 0);

begin
    
    register_file_DUT : register_file
        generic map(
            width   => ent_width,
            regbits => ent_regbits
        )
        port map(
            i_clk               => s_clk,
            i_write_enable      => s_write_enable,
            i_reg1_addr         => s_reg1_addr,
            i_reg2_addr         => s_reg2_addr,
            i_reg3_addr         => s_reg3_addr,
            i_write_data        => s_write_data,
            o_reg2_contents     => s_reg2_contents,
            o_reg3_contents     => s_reg3_contents
        );

    s_clk_gen : process
    begin
        s_clk <= '1';
        wait for 5 ns;
        s_clk <= '0';
        wait for 5 ns;
    end process; -- s_clk_gen

    manual_signals : process
    begin
        -- read register 0 twice
        s_write_enable  <= '0';
        s_reg1_addr     <= "00000";
        s_reg2_addr     <= "00000";
        s_reg3_addr     <= "00000";
        s_write_data    <= x"A0000000";
        wait for 10 ns;
        -- read registers 1 and 2
        s_write_enable  <= '0';
        s_reg1_addr     <= "00000";
        s_reg2_addr     <= "00001";
        s_reg3_addr     <= "00010";
        s_write_data    <= x"A0000000";
        wait for 10 ns;
        -- write into register 1
        s_write_enable  <= '1';
        s_reg1_addr     <= "00001";
        s_reg2_addr     <= "00001";
        s_reg3_addr     <= "00010";
        s_write_data    <= x"A0000000";
        wait for 10 ns;
        -- read registers 1 and 2
        s_write_enable  <= '0';
        s_reg1_addr     <= "00000";
        s_reg2_addr     <= "00001";
        s_reg3_addr     <= "00010";
        s_write_data    <= x"A0000000";
        wait for 10 ns;
        -- write into register 2
        s_write_enable  <= '1';
        s_reg1_addr     <= "00010";
        s_reg2_addr     <= "00001";
        s_reg3_addr     <= "00010";
        s_write_data    <= x"B0000000";
        wait for 10 ns;
        -- read registers 1 and 2
        s_write_enable  <= '0';
        s_reg1_addr     <= "00000";
        s_reg2_addr     <= "00001";
        s_reg3_addr     <= "00010";
        s_write_data    <= x"B0000000";
        wait for 10 ns;
        -- write into register 1 and output some register (0) while in a write...
        s_write_enable  <= '1';
        s_reg1_addr     <= "00001";
        s_reg2_addr     <= "00001";
        s_reg3_addr     <= "00000";
        s_write_data    <= x"C0000000";
        wait for 10 ns;
        -- read registers 1 and 0
        s_write_enable  <= '0';
        s_reg1_addr     <= "00000";
        s_reg2_addr     <= "00001";
        s_reg3_addr     <= "00000";
        s_write_data    <= x"C0000000";
        wait for 10 ns;
        -- write into register 0
        s_write_enable  <= '1';
        s_reg1_addr     <= "00000";
        s_reg2_addr     <= "00001";
        s_reg3_addr     <= "00010";
        s_write_data    <= x"C0000000";
        wait for 10 ns;
        -- read register 0 twice
        s_write_enable  <= '0';
        s_reg1_addr     <= "00000";
        s_reg2_addr     <= "00000";
        s_reg3_addr     <= "00000";
        s_write_data    <= x"00000000";
        wait;
    end process; -- manual_signals

end Behavioral; -- register_file_tb
