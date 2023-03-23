library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity display is
     Port (
        digits : in std_logic_vector(15 downto 0);
        cat: out std_logic_vector(6 downto 0);
        an: out std_logic_vector(3 downto 0);
        clk: in std_logic
        );
end display;

architecture Behavioral of display is
    signal output_mux1: std_logic_vector(3 downto 0);
    signal refreshing_counter: std_logic_vector(15 downto 0);
begin

      refresh : process(clk)
                begin
                    if rising_edge(clk) then
                            refreshing_counter <= refreshing_counter + 1;
                    end if;
      end process;      
 
    mux1: process(digits, refreshing_counter(15 downto 14))
    begin
        case refreshing_counter(15 downto 14) is
            when "00" => output_mux1 <= digits(3 downto 0) ;
            when "01" => output_mux1 <= digits(7 downto 4);
            when "10" => output_mux1 <= digits(11 downto 8);
            when others => output_mux1 <= digits(15 downto 12);
    end case;
    end process;
    
    mux2: process(refreshing_counter(15 downto 14))
    begin
        case refreshing_counter(15 downto 14) is
            when "00" => an <= B"1110";
            when "01" => an <= B"1101";
            when "10" => an <= B"1011";
            when others => an <= B"0111";
    end case;
    end process;
    
    with output_mux1 SELect
       cat<= "1111001" when "0001",   --1
             "0100100" when "0010",   --2
             "0110000" when "0011",   --3
             "0011001" when "0100",   --4
             "0010010" when "0101",   --5
             "0000010" when "0110",   --6
             "1111000" when "0111",   --7
             "0000000" when "1000",   --8
             "0010000" when "1001",   --9
             "0001000" when "1010",   --A
             "0000011" when "1011",   --b
             "1000110" when "1100",   --C
             "0100001" when "1101",   --d
             "0000110" when "1110",   --E
             "0001110" when "1111",   --F
             "1000000" when others;   --0
             
end Behavioral;
