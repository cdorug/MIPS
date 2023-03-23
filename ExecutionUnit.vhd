library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ExecutionUnit is
    Port(PC: in std_logic_vector(15 downto 0);
         RD1: in std_logic_vector(15 downto 0);
         RD2: in std_logic_vector(15 downto 0);
         ExtImm: in std_logic_vector(15 downto 0);
         SA: in std_logic;
         func: in std_logic_vector(2 downto 0);
         ALUSrc: in std_logic;
         ALUOp: in std_logic_vector(1 downto 0);
         BranchAddress: out std_logic_vector(15 downto 0);
         Zero: out std_logic;
         ALURes: inout std_logic_vector(15 downto 0)
         );
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is
    signal ALUInput_2: std_logic_vector(15 downto 0);
    signal ALUFunc: std_logic_vector(3 downto 0);
    signal ALUControl: std_logic_vector(3 downto 0) := "0000";
    signal ALUResSLL: std_logic_vector(15 downto 0);
    signal ALUResSRL: std_logic_vector(15 downto 0);
    signal ALUResSRA: std_logic_vector(15 downto 0);

begin
    
    rd2MUXExt: process(ALUSrc, RD2, ExtImm)
    begin
        if(ALUSrc = '1') then
            ALUInput_2 <= ExtImm;
        elsif(ALUSrc = '0') then
            ALUInput_2 <= RD2;
        end if;
    end process;
    
    ALUFunction: process(func)
    begin
        case func is
            when "000" => ALUFunc <= "0000"; -- ADD
            when "001" => ALUFunc <= "0001"; -- SUBTRACT
            when "010" => ALUFunc <= "0010"; -- SLL
            when "011" => ALUFunc <= "0011"; -- SRL
            when "100" => ALUFunc <= "0100"; -- AND
            when "101" => ALUFunc <= "0101"; -- OR
            when "110" => ALUFunc <= "0110"; -- XOR
            when "111" => ALUFunc <= "0111"; -- SRA
        end case;
    end process;
    
    ALUCtrl: process(ALUOp, ALUFunc)
    begin
        case ALUOp is
            when "00" => ALUControl <= "1000"; -- JUMP, no operation;
            when "01" => ALUControl <= ALUFunc; -- R type
            when "10" => ALUControl <= "0000"; -- ADD 
            when "11" => ALUControl <= "0001"; -- SUBTRACT
        end case;
    end process;
    
    ALUResSLL <= ALUInput_2(14 downto 0) & '0' when SA = '1' else ALUInput_2;
    ALUResSRL <= '0' & ALUInput_2(15 downto 1) when SA = '1' else ALUInput_2;
    ALUResSRA <= ALUInput_2(15) & ALUInput_2(15 downto 1) when SA = '1' else ALUInput_2;
    
    ALU: process(ALUControl, RD1, RD2, ALUInput_2, ALUResSLL, ALUResSRL, ALUResSRA)
    begin
        case ALUControl is
            when "0000" => ALURes <= RD1 + ALUInput_2; -- ADD;
            when "0001" => ALURes <= RD2 - ALUInput_2; -- SUBTRACT
            when "0010" => ALURes <= ALUResSLL; -- SLL                                        
            when "0011" => ALURes <= ALUResSRL; -- SRL
            when "0100" => ALURes <= RD1 AND ALUInput_2; -- AND
            when "0101" => ALURes <= RD1 OR ALUInput_2; -- OR
            when "0110" => ALURes <= RD1 XOR ALUInput_2; -- XOR
            when "0111" => ALURes <= ALUResSRA; -- SRA
            when "1000" => ALURes <= ALUInput_2; -- NO OP
            when others => null ;
        end case;
    end process;
    
    Zero <= '1' when ALURes = X"0000" else '0';
    BranchAddress <= PC + ExtImm;


end Behavioral;
