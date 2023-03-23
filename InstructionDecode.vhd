library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstructionDecode is
    Port(clk: in std_logic;
        RegWrite: in std_logic;
        Instr: in std_logic_vector(15 downto 0);
        RegDst: in std_logic;
        ExtOp: in std_logic;
        WD: in std_logic_vector(15 downto 0);
        RD1: out std_logic_vector(15 downto 0);
        RD2: out std_logic_vector(15 downto 0);
        ExtImm: out std_logic_vector(15 downto 0);
        Func: out std_logic_vector(2 downto 0);
        SA: out std_logic
        );
end InstructionDecode;

architecture Behavioral of InstructionDecode is
    component reg_file
    Port (
           clk : in std_logic;
           ra1 : in std_logic_vector (3 downto 0);
           ra2 : in std_logic_vector (3 downto 0);
           wa : in std_logic_vector (3 downto 0);
           wd : in std_logic_vector (15 downto 0);
           wen : in std_logic;
           rd1 : out std_logic_vector (15 downto 0);
           rd2 : out std_logic_vector (15 downto 0)
     );
    end component;
    
    signal rtMUXrd: std_logic_vector(3 downto 0);
    signal ra1Ext: std_logic_vector(3 downto 0) := '0' & Instr(12 downto 10);
    signal ra2Ext: std_logic_vector(3 downto 0) := '0' & Instr(9 downto 7);
    
begin

    register_file: reg_file
    port map( clk => clk,
              ra1 => ra1Ext,
              ra2 => ra2Ext,
              wa  => rtMUXrd,
              wd  => WD,
              wen => RegWrite,
              rd1 => RD1,
              rd2 => RD2 );
     
     Multiplexer: process(Instr(9 downto 7), Instr(6 downto 4), RegDst)
     begin
        if(RegDst = '1') then
            rtMUXrd <= '0' & Instr(6 downto 4);
        elsif(RegDst = '0') then
            rtMUXrd <= '0' & Instr(9 downto 7);
        end if;
     end process;      
     
     ExtUnit: process(ExtOp, Instr(6 downto 0))
     begin
        ExtImm(6 downto 0) <= Instr(6 downto 0);      
        if(ExtOp = '0') then
            ExtImm(15 downto 7) <= (others => '0');
        elsif(ExtOp = '1') then
            ExtImm(15 downto 7) <= (others => Instr(6));
        end if;
     end process;
      
     func <= Instr(2 downto 0);
     sa <= Instr(3);
     
end Behavioral;
