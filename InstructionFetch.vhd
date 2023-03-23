----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.03.2022 08:23:29
-- Design Name: 
-- Module Name: InstructionFetch - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstructionFetch is
  Port (clk :in std_logic;
        BranchAddress: in std_logic_vector(15 downto 0);
        JumpAddress: in std_logic_vector(15 downto 0);
        Jump: in std_logic;
        PCSrc: in std_logic;
        Instruction: out std_logic_vector(15 downto 0);
        NextPC: out std_logic_vector(15 downto 0)
         );
end InstructionFetch;

architecture Behavioral of InstructionFetch is
    
    type ROM is array (0 to 255) of std_logic_vector (15 downto 0); 
    signal Instruction_Memory: ROM := (
            -- write my assembly code here
            X"0496",
            X"4580", 
            X"4A00",
            X"2E0A",
            X"318A",
            X"0E51",
            X"0496",
            X"6680",
            X"4500",
            X"0AF0",
            others => "0000"
    );
    
    signal program_counter: std_logic_vector(15 downto 0) := X"0000";
    signal new_PC: std_logic_vector(15 downto 0) := X"0000";
    signal PC_plus_one: std_logic_vector(15 downto 0) := X"0000";
    signal BranchMUXPC: std_logic_vector(15 downto 0) := X"0000";
    

begin

    PC_plus_one <= program_counter + 1;
    
    MUX1: process(PCSrc, PC_plus_one, BranchAddress) 
    begin
        case PCSrc is
            when '0' => BranchMUXPC <= PC_plus_one;
            when '1' => BranchMUXPC <= BranchAddress;
        end case;
    end process;
    
    MUX2: process(Jump, BranchMUXPC, JumpAddress) 
    begin
        case Jump is
            when '0' => new_PC <= BranchMUXPC;
            when '1' => new_PC <= JumpAddress;
        end case;
    end process;

    PC: process(clk) 
    begin
        if(rising_edge(clk)) then 
            program_counter <= new_PC;
        end if;
    end process;
        
    NextPC <= PC_plus_one;
    Instruction <= Instruction_Memory(conv_integer(program_counter(7 downto 0)));

end Behavioral;
