----------------------------------------------------------------------------------
-- Company: Politecnico di Milano
-- Student: Davide Calabrò 
-- 
-- Create Date: 19.12.2018 15:08:55
-- Design Name: FSM
-- Module Name: FSM - Behavioral
-- Project Name: Reti Logiche - Project
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
use IEEE.NUMERIC_STD.ALL;

entity FSM is
    port(
        i_clk, i_start, i_rst: in std_logic;
        o_done, o_en, o_we: out std_logic;
        i_data: in std_logic_vector(7 downto 0);
        o_address: out std_logic_vector(15 downto 0);
        o_data: out std_logic_vector(7 downto 0)
    );
end FSM;

architecture arch of FSM is
    ---------------------------------------------------------------
    -- Utils Constants
    constant ADDRUNDEFINED: std_logic_vector := "UUUUUUUUUUUUUUUU";
    -- Constants addresses setup and final write states
    constant ADDRCENTROIDX: std_logic_vector := "0000000000010001";
    constant ADDRCENTROIDY: std_logic_vector := "0000000000010010";
    constant ADDRINBITMASK: std_logic_vector := "0000000000000000";
    constant ADDROUTBITMASK: std_logic_vector := "0000000000010011";
    constant MAXDISTANCEVALUE: unsigned := "111111111";
    ---------------------------------------------------------------
    
    ---------------------------------------------------------------
    -- States management
    type eg_state_type is (
        idle, 
        read_setup, 
        read_setup_rcv, 
        validate, 
        read_centroid,
        read_centroid_rcv,
        difference,
        distance,
        comparison,
        write_mask,
        done);
    signal state_reg, state_next: eg_state_type;
    ---------------------------------------------------------------
    
    ---------------------------------------------------------------
    -- Counters
    signal counter_reg, counter_next: unsigned(1 downto 0);
    signal centroid_counter_reg, centroid_counter_next: unsigned(2 downto 0);
    signal curr_address_reg, curr_address_next: unsigned(15 downto 0);
    ---------------------------------------------------------------
    
    ---------------------------------------------------------------
    -- Internal check signals
    --signal en_comparison, en_write_mask: std_logic;
    ---------------------------------------------------------------
    
    ---------------------------------------------------------------
    -- Internal values
    signal in_bitmask_reg, out_bitmask_reg, centroid_bitmask_reg: std_logic_vector(0 to 7);
    signal main_centroid_x_reg, main_centroid_y_reg: std_logic_vector(7 downto 0);    
    signal curr_centroid_x_reg, curr_centroid_y_reg: std_logic_vector(7 downto 0);
    signal curr_distance_x_reg, curr_distance_y_reg: unsigned(7 downto 0);
    signal curr_distance_reg, max_distance_reg, max_distance_next: unsigned(8 downto 0);
    ---------------------------------------------------------------
begin

    process(i_clk, i_rst) 
    begin
        if i_rst = '1' then
            state_reg <= idle;
            counter_reg <= "00";
            centroid_counter_reg <= "000";
            curr_address_reg <= "0000000000000001";
            max_distance_reg <= MAXDISTANCEVALUE;            
        elsif i_clk'event and i_clk = '1' then
            state_reg <= state_next;
            counter_reg <= counter_next;
            centroid_counter_reg <= centroid_counter_next;
            curr_address_reg <= curr_address_next;
            max_distance_reg <= max_distance_next;
        end if;    
    end process;
    
    process(i_start, state_reg, counter_reg, centroid_counter_reg)
    begin
        case state_reg is
        --------------------- IDLE -------------------------
            when idle =>
                -- Counters and signals
                counter_next <= "00";
                centroid_counter_next <= "000";
                curr_address_next <= "0000000000000001";
                max_distance_next <= MAXDISTANCEVALUE;
                out_bitmask_reg <= "00000000";
                -- States
                state_next <= idle;
                if i_start = '1' then
                    state_next <= read_setup;
                end if;
                o_done <= '0';
        --------------------- READ SETUP -------------------------
            when read_setup =>
                case counter_reg is
                    when "00" =>
                        o_we <= '0';
                        o_en <= '1';
                        o_address <= ADDRINBITMASK;
                    when "01" => 
                        o_we <= '0';
                        o_en <= '1';
                        o_address <= ADDRCENTROIDX;
                    when "10" =>
                        o_we <= '0';
                        o_en <= '1';
                        o_address <= ADDRCENTROIDY;
                    when others => null;
                end case;       
                state_next <= read_setup_rcv;
                o_done <=  '0';
        --------------------- READ SETUP RCV -------------------------    
            when read_setup_rcv =>
                state_next <= read_setup;            
            
                case counter_reg is
                    when "00" =>
                        in_bitmask_reg <= i_data;
                        o_en <= '0';
                        o_address <= ADDRUNDEFINED;                      
                    when "01" =>
                        main_centroid_x_reg <= i_data;
                        o_en <= '0';
                        o_address <= ADDRUNDEFINED;
                    when "10" =>
                        main_centroid_y_reg <= i_data;
                        o_en <= '0';
                        o_address <= ADDRUNDEFINED;
                    when others => null;
                end case;                
                counter_next <= counter_next + 1;  
                
                if counter_reg = "10" then
                    state_next <= validate;
                end if;
                o_done <= '0';
        --------------------- VALIDATE -------------------------
            when validate =>
                state_next <= validate;
            
                --en_comparison <= in_bitmask_reg(to_integer(centroid_counter_reg));                
                counter_next <= "00";
                
                --if centroid_counter_reg = "111" then
                --    en_write_mask <= '1';
                --end if;
                
                if in_bitmask_reg(to_integer(centroid_counter_reg)) = '1' then
                    state_next <= read_centroid;
                else 
                    curr_address_next <= curr_address_next + 2;
                    centroid_counter_next <= centroid_counter_next + 1;
                    
                    -- In caso l'ultimo centroide non sia da verificare, passo direttamente alla scrittura della maschera
                    if centroid_counter_reg = "111" then
                        state_next <= write_mask;
                    end if;
                end if;
        --------------------- READ CENTROID -------------------------
            when read_centroid =>
                o_we <= '0';
                o_en <= '1';
                o_address <= std_logic_vector(curr_address_reg);
                
                state_next <= read_centroid_rcv;
        --------------------- READ CENTROID RECEIVE -------------------------
            when read_centroid_rcv =>
                o_we <= '0';
                o_en <= '0';
                o_address <= ADDRUNDEFINED;
                
                case counter_reg is
                    when "00" => curr_centroid_x_reg <= i_data;
                    when "01" => curr_centroid_y_reg <= i_data;
                    when others => null;
                end case;
                
                curr_address_next <= curr_address_next + 1;                                
                
                state_next <= difference;
        --------------------- DIFFERENCE -------------------------
            when difference =>
                case counter_reg is
                    when "00" => 
                        if curr_centroid_x_reg > main_centroid_x_reg then
                            curr_distance_x_reg <= unsigned(curr_centroid_x_reg) - unsigned(main_centroid_x_reg);
                        else
                            curr_distance_x_reg <=  unsigned(main_centroid_x_reg) - unsigned(curr_centroid_x_reg);  
                        end if;
                        
                    when "01" => 
                        if curr_centroid_y_reg > main_centroid_y_reg then
                            curr_distance_y_reg <= unsigned(curr_centroid_y_reg) - unsigned(main_centroid_y_reg);
                        else
                            curr_distance_y_reg <=  unsigned(main_centroid_y_reg) - unsigned(curr_centroid_y_reg);  
                        end if;
                                              
                    when others => null;                                  
                end case;
                
                counter_next <= counter_next + 1;
                state_next <= read_centroid;
                
                if counter_reg = "01" then
                    state_next <= distance;
                end if;
        --------------------- DISTANCE -------------------------    
            when distance =>
                curr_distance_reg <= unsigned('0' & curr_distance_x_reg) + unsigned('0' & curr_distance_y_reg);
                
                case centroid_counter_reg is
                    when "000" => centroid_bitmask_reg <= "10000000";
                    when "001" => centroid_bitmask_reg <= "01000000";
                    when "010" => centroid_bitmask_reg <= "00100000";
                    when "011" => centroid_bitmask_reg <= "00010000";
                    when "100" => centroid_bitmask_reg <= "00001000";
                    when "101" => centroid_bitmask_reg <= "00000100";
                    when "110" => centroid_bitmask_reg <= "00000010";
                    when "111" => centroid_bitmask_reg <= "00000001";
                    when others => null;
                end case;
                
                state_next <= comparison;               
        --------------------- COMPARISON -----------------------
            when comparison =>
                if curr_distance_reg < max_distance_reg then
                    out_bitmask_reg <= centroid_bitmask_reg;
                    max_distance_next <= curr_distance_reg;
                elsif curr_distance_reg = max_distance_reg then
                    out_bitmask_reg <= out_bitmask_reg or centroid_bitmask_reg;
                end if;
                            
                centroid_counter_next <= centroid_counter_next + 1;
                            
                state_next <= validate;                
                if centroid_counter_reg = "111" then
                    state_next <= write_mask;
                end if;
        --------------------- WRITE MASK -------------------------      
            when write_mask =>
                o_en <= '1';
                o_we <= '1';
                o_address <= ADDROUTBITMASK;
                o_data <= out_bitmask_reg;
                
                state_next <= done;                     
        --------------------- DONE -------------------------    
            when done =>
                o_done <= '1';
                                
        end case;
    
    
    end process;

end arch;
