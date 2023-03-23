library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DataMemory is

  Port (clk: in std_logic;
        MemWrite: in std_logic;
        ALURes: in std_logic_vector(15 downto 0);
        RD2: in std_logic_vector(15 downto 0);
        MemData: out std_logic_vector(15 downto 0);
        ALUResOut: out std_logic_vector(15 downto 0);
        EN: in std_logic
         );
end DataMemory;

architecture Behavioral of DataMemory is
    type RAM is array (0 to 32767) of std_logic_vector (15 downto 0);
    signal RAM_Memory: RAM := (
                X"000F",
                X"000F",
                others => "0000"
        );
    signal ALUResBuffer: std_logic_vector(15 downto 0);
begin

    MEM_Write: process(clk)
    begin
        if(rising_edge(clk)) then
            if(MemWrite = '1' and EN = '1') then
                RAM_Memory(conv_integer(ALURes)) <= RD2;
            end if;
        end if;
    end process;
    
    MemData <= RAM_Memory(conv_integer(ALURes));
    ALUResBuffer <= ALURes;
    ALUResOut <= ALUResBuffer;
    
end Behavioral;
