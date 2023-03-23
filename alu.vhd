library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
  Port ( 
  clk: in std_logic;
  MPG_Enable: in std_logic;
  sw: in std_logic_vector(7 downto 0);
  digits: out std_logic_vector(15 downto 0));
end alu;

architecture Behavioral of alu is
    signal sum:  std_logic_vector(15 downto 0);
    signal substraction:  std_logic_vector(15 downto 0);
    signal left_shift:  std_logic_vector(15 downto 0);
    signal right_shift:  std_logic_vector(15 downto 0);
    signal temp1: std_logic_vector(15 downto 0);
    signal temp2: std_logic_vector(15 downto 0);
    signal alu_counter: std_logic_vector(1 downto 0);
begin

    counter : process(clk)
    begin
        if rising_edge(clk) then
            if MPG_Enable = '1' then
                alu_counter <= alu_counter + 1;
            end if;
        end if;
    end process;   
      
    addition: process(sw)
    begin
        sum <= sw(3 downto 0) + sw(7 downto 4);
    end process;

    sub: process(sw)
    begin
        substraction <= sw(3 downto 0) - sw(7 downto 4);
    end process;

    left_s: process(sw)
    begin
        temp1 <= sw(5 downto 0) & "00";
        left_shift <= temp1;
    end process;
    
    right_s: process(sw)
    begin
        temp2 <= "00" & sw(7 downto 2);
        right_shift <= temp2;
    end process;
    
    mux: process(alu_counter, sum, substraction, left_shift, right_shift)
        begin
            case alu_counter is
                when "00" => digits <= sum ;
                when "01" => digits <= substraction;
                when "10" => digits <= left_shift;
                when others => digits <= right_shift;
        end case;
    end process;
end Behavioral;
