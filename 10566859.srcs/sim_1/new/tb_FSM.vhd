----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.12.2018 16:05:07
-- Design Name: 
-- Module Name: tb_FSM - Behavioral
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

entity tb_FSM is
--  Port ( );
end tb_FSM;

architecture Behavioral of tb_FSM is
signal clk, reset, we, en, start, o_done: std_logic;
signal di, do: std_logic_vector(7 downto 0);
signal addr: std_logic_vector(15 downto 0);

begin
    MEM0: entity work.rom
        port map(
            clk=>clk, 
            we=>we, 
            en=>en, 
            addr=>addr, 
            di=>di, 
            do=>do);
    FSM0: entity work.FSM
        port map(
            i_clk=>clk, 
            i_start=>start, 
            i_rst=>reset, 
            i_data=>do, 
            o_address=>addr, 
            o_en=>en, 
            o_we=>we,
            o_done => o_done, 
            o_data=>di);

    process
    begin
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        wait for 10ns;       
    end process;
    
    process
    begin
        reset <= '1';
        start <= '0';
        wait for 5ns;
        reset <= '0';
        start <= '1';
        wait for 20 ns;
        start <= '0';
        wait for 2000ns;
        
        assert false severity failure; 
    end process;
end Behavioral;
