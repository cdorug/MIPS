-- Mono Pulse Generator (MPG)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mono_pulse_gen is
    Port (
        clk    : in STD_LOGIC;
        btn    : in std_logic_vector(4 downto 0);
        enable : out std_logic_vector(4 downto 0) 
    );
end mono_pulse_gen;

architecture Behavioral of mono_pulse_gen is

    signal s_counter : std_logic_vector(15 downto 0) := B"0000_0000_0000_0000";
    signal s_q1      : std_logic_vector(4 downto 0)  := "00000";
    signal s_q2      : std_logic_vector(4 downto 0)  := "00000";
    signal s_q3      : std_logic_vector(4 downto 0)  := "00000";

begin

    counter : process(clk)
    begin
        if rising_edge(clk) then
            s_counter <= s_counter + 1;
        end if;
    end process; -- counter

    first_reg : process(clk, btn)
    begin
        if rising_edge(clk) then
            if s_counter = X"FFFF" then
                s_q1 <= btn;
            end if;
        end if;
    end process; -- first_reg

    second_reg : process(clk)
    begin
        if rising_edge(clk) then
            s_q2 <= s_q1;
        end if;
    end process; -- second_reg

    third_reg : process(clk)
    begin
        if rising_edge(clk) then            
            s_q3 <= s_q2;            
        end if;
    end process; -- third_reg

    enable <= s_q2 and not s_q3; -- AND gate at the end

end Behavioral;