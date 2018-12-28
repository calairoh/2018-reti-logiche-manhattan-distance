-- Single-Port Block RAM Write-First Mode (recommended template) --
-- File: rams_02.vhd --
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 

entity rom is port
(
 clk : in std_logic; 
 we : in std_logic; 
 en : in std_logic; 
 addr : in std_logic_vector(15 downto 0); 
 di : in std_logic_vector(7 downto 0); 
 do : out std_logic_vector(7 downto 0)
 ); 
end rom;

architecture syn of rom is 
type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);
signal RAM : ram_type; 
begin 
    process(clk) 
    begin 
        RAM(0) <= "00110100";
        RAM(1) <= "01010111";
        RAM(2) <= "01110111";
        RAM(3) <= "10111101";
        RAM(4) <= "11111100";
        RAM(5) <= "10011101";
        RAM(6) <= "00110111";
        RAM(7) <= "10000001";
        RAM(8) <= "10000000";
        RAM(9) <= "10111111";
        RAM(10) <= "00011101";
        RAM(11) <= "10000001";
        RAM(12) <= "10000000";
        RAM(13) <= "10101011";
        RAM(14) <= "10101000";
        RAM(15) <= "00000001";
        RAM(16) <= "00000000";
        RAM(17) <= "10000000";
        RAM(18) <= "10000000";
        
        if clk'event and clk = '1' then 
            if en = '1' then 
                if we = '1' then 
                    RAM(conv_integer(addr)) <= di;
                    do <= di;
                else 
                    do <= RAM(conv_integer(addr));
                end if;
            end if; 
        end if; 
    end process;
end syn;