library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port(
        clk : in  std_logic;
        btn : in  std_logic_vector(4 downto 0);
        sw  : in  std_logic_vector(15 downto 0);
        led : out std_logic_vector(15 downto 0);
        an  : out std_logic_vector(3 downto 0);
        cat : out std_logic_vector(6 downto 0)
    );
end test_env;

architecture Behavioral of test_env is

    component InstructionFetch
      Port (clk :in std_logic;
           BranchAddress: in std_logic_vector(15 downto 0);
           JumpAddress: in std_logic_vector(15 downto 0);
           Jump: in std_logic;
           PCSrc: in std_logic;
           Instruction: out std_logic_vector(15 downto 0);
           NextPC: out std_logic_vector(15 downto 0)
            );
    end component;
    
    component mono_pulse_gen
        Port(clk    : in  STD_LOGIC;
             btn    : in  std_logic_vector(4 downto 0);
             enable : out std_logic_vector(4 downto 0));
    end component;
    
    component display
        Port(digits : in std_logic_vector(15 downto 0);
            cat: out std_logic_vector(6 downto 0);
            an: out std_logic_vector(3 downto 0);
            clk: in std_logic);
    end component;
    
    component InstructionDecode
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
    end component;
    
    component DataMemory
        Port (clk: in std_logic;
            MemWrite: in std_logic;
            ALURes: in std_logic_vector(15 downto 0);
            RD2: in std_logic_vector(15 downto 0);
            MemData: out std_logic_vector(15 downto 0);
            ALUResOut: out std_logic_vector(15 downto 0);
            EN: std_logic
             );
    end component;
    
    component ExecutionUnit
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
    end component;

    signal s_counter_enable : std_logic_vector(4 downto 0) := "00000";
    signal displayInput: std_logic_vector(15 downto 0) := X"0000";

    signal BranchAddressDefault: std_logic_vector(15 downto 0) := X"000A";
    signal JumpAddressDefault: std_logic_vector(15 downto 0) := X"0000";
    signal InstructionOutput: std_logic_vector(15 downto 0);
    signal PCOutput: std_logic_vector(15 downto 0);
    
    -- output from Instruction Decode
    signal ReadData1: std_logic_vector(15 downto 0);
    signal ReadData2: std_logic_vector(15 downto 0);
    signal ExtImmediate: std_logic_vector(15 downto 0);
    signal func: std_logic_vector(2 downto 0);
    signal shift_amount: std_logic;
    
    -- output from Execution Unit
    signal BranchAddressBuff: std_logic_vector(15 downto 0) := X"0000";
    signal ZeroFlag: std_logic;
    signal ALUResBuff: std_logic_vector(15 downto 0);
    
    -- output from Data Memory
    signal ALUResBuffFromDataMemory: std_logic_vector(15 downto 0);
    signal MemDataBuff: std_logic_vector(15 downto 0);
    
    -- output from WriteBack
    signal WriteBack: std_logic_vector(15 downto 0);
    
    -- Jump Address
    signal JumpAddressBuff: std_logic_vector(15 downto 0) := X"0000";
    
    -- main control signals
    signal RegWrite: std_logic;
    signal RegDst: std_logic;
    signal ExtOp: std_logic;
    signal MemtoReg: std_logic;
    signal MemWrite: std_logic;
    signal JumpControl: std_logic;
    signal ALUSrc: std_logic;
    signal BranchOnEqual: std_logic;
    signal BranchOnGreaterOrEqualToZero: std_logic;
    signal BranchOnLessThanZero: std_logic;
    signal PCSrcControl: std_logic;
    signal ALUOp: std_logic_vector(1 downto 0);
    
    -- Pipeline registers
    signal InF_ID: std_logic_vector(31 downto 0);
    signal ID_EX: std_logic_vector(74 downto 0);
    signal EX_MEM: std_logic_vector(56 downto 0);
    signal MEM_WB: std_logic_vector(37 downto 0);
    
begin

     MainControl: process(InstructionOutput(15 downto 13))
    begin
        case InstructionOutput(15 downto 13) is
            when "000" =>
                -- R format
                RegWrite <= '1';
                RegDst <= '1';
                ExtOp <= '0';
                MemtoReg <= '0';
                MemWrite <= '0';
                JumpControl <= '0';      
                ALUSrc <= '0';
                BranchOnEqual <= '0';
                BranchOnGreaterOrEqualToZero <= '0';
                BranchOnLessThanZero <= '0';
                ALUOp <= "01";
            when "001" =>
                -- ADD Immediate
                RegWrite <= '1';
                RegDst <= '0';
                ExtOp <= '1'; 
                MemtoReg <= '0';
                MemWrite <= '1';
                JumpControl <= '0';      
                ALUSrc <= '1';
                BranchOnEqual <= '0';
                BranchOnGreaterOrEqualToZero <= '0';
                BranchOnLessThanZero <= '0';
                ALUOp <= "10"; -- Add operation
            when "010" =>
                -- LOAD WORD
                RegWrite <= '1';
                RegDst <= '0';
                ExtOp <= '1';
                MemtoReg <= '1';
                MemWrite <= '0';
                JumpControl <= '0';      
                ALUSrc <= '1';
                BranchOnEqual <= '0';
                BranchOnGreaterOrEqualToZero <= '0';
                BranchOnLessThanZero <= '0';
                ALUOp <= "10"; -- Add operation
            when "011" =>
                -- STORE WORD
                RegWrite <= '0';
                RegDst <= '0';
                ExtOp <= '1';
                MemtoReg <= '1';
                MemWrite <= '1';
                JumpControl <= '0';      
                ALUSrc <= '1';
                BranchOnEqual <= '0';
                BranchOnGreaterOrEqualToZero <= '0';
                BranchOnLessThanZero <= '0';
                ALUOp <= "10"; -- Add operation
            when "100" =>
                -- BRANCH ON EQUAL
                RegWrite <= '0';
                RegDst <= '0';
                ExtOp <= '1';
                MemtoReg <= '1';
                MemWrite <= '0';
                JumpControl <= '0';      
                ALUSrc <= '0';
                BranchOnEqual <= '1';
                BranchOnGreaterOrEqualToZero <= '0';
                BranchOnLessThanZero <= '0';
                ALUOp <= "11"; -- Subtract operation
            when "101" =>
                -- BRANCH ON GREATER OR EQUAL TO ZERO
                RegWrite <= '0';
                RegDst <= '0';
                ExtOp <= '1';
                MemtoReg <= '1';
                MemWrite <= '0';
                JumpControl <= '0';      
                ALUSrc <= '0';
                BranchOnEqual <= '0';
                BranchOnGreaterOrEqualToZero <= '1';
                BranchOnLessThanZero <= '0';
                ALUOp <= "11"; -- Subtract operation
            when "110" =>
                -- BRANCH ON LESS THAN ZERO
                RegWrite <= '0';
                RegDst <= '0';
                ExtOp <= '1';
                MemtoReg <= '1';
                MemWrite <= '0';
                JumpControl <= '0';      
                ALUSrc <= '0';
                BranchOnEqual <= '0';
                BranchOnGreaterOrEqualToZero <= '0';
                BranchOnLessThanZero <= '1';
                ALUOp <= "11"; -- Subtract operation
            when "111" =>
                -- JUMP
                RegWrite <= '0';
                RegDst <= '0';
                ExtOp <= '1';
                MemtoReg <= '0';
                MemWrite <= '0';
                JumpControl <= '1';      
                ALUSrc <= '0';
                BranchOnEqual <= '0';
                BranchOnGreaterOrEqualToZero <= '0';
                BranchOnLessThanZero <= '0';
                ALUOp <= "00"; -- No operation
        end case;
    end process;
    
    instrDecode: InstructionDecode
        Port map(clk => s_counter_enable(0),
                 RegWrite => RegWrite,
                 Instr => InstructionOutput,
                 RegDst => RegDst,
                 ExtOp => ExtOp,
                 WD => WriteBack,
                 RD1 => ReadData1,
                 RD2 => ReadData2,
                 ExtImm => ExtImmediate,
                 Func => func,
                 SA => shift_amount
                );
    
    JumpAddressBuff <= "000" & InstructionOutput(12 downto 0);
        
    instrFetch: InstructionFetch
        port map(
            clk => s_counter_enable(0),
            BranchAddress => BranchAddressBuff,
            JumpAddress => JumpAddressBuff,
            Jump => JumpControl,
            PCSrc => PCSrcControl,
            Instruction => InstructionOutput,
            NextPC => PCOutput
        );
    
    execUnit: ExecutionUnit
        port map(PC => PCOutput,
                 RD1 => ReadData1,
                 RD2 => ReadData2,
                 ExtImm => ExtImmediate,
                 SA => shift_amount,
                 func => func,
                 ALUSrc => ALUSrc,
                 ALUOp => ALUOp,
                 BranchAddress => BranchAddressBuff,
                 Zero => ZeroFlag,
                 ALURes => ALUResBuff
                 );
    
    datMemory: DataMemory
        port map(clk => s_counter_enable(0),
                 MemWrite => MemWrite,
                 ALURes => ALUResBuff,
                 RD2 => ReadData2,
                 MemData => MemDataBuff,
                 ALUResOut => ALUResBuffFromDataMemory,
                 EN => '1'
                 );
                 
    WriteBackUnit: process(MemtoReg, MemDataBuff, ALUResBuffFromDataMemory)
    begin
        if(MemtoReg = '1') then
            WriteBack <= MemDataBuff;
        elsif(MemtoReg = '0') then
            WriteBack <= ALUResBuffFromDataMemory;
        end if;
    end process;
    
    BranchControlUnit: process(BranchOnEqual, BranchOnGreaterOrEqualToZero, BranchOnLessThanZero, ZeroFlag, ReadData1)
    begin
        PCSrcControl <= '0';
        if(BranchOnEqual = '1') then
            if(ZeroFlag = '1') then
                PCSrcControl <= '1';
            end if;
        end if;  
        if(BranchOnGreaterOrEqualToZero = '1') then
            if(ReadData1 >= 0) then
                PCSrcControl <= '1';
            end if;
        end if;
        if(BranchOnLessThanZero = '1') then
            if(ReadData1 < 0) then
                PCSrcControl <= '1';
            end if;
        end if;
    end process;
                 
    mpg1 : mono_pulse_gen
        port map(
            clk    => clk,
            btn    => btn,
            enable => s_counter_enable
        );
    
    SSDControl: process(sw(7 downto 5), InstructionOutput, PCOutput, ReadData1, ReadData2, ExtImmediate, ALUResBuff, MemDataBuff, ReadData2)
    begin
        case sw(7 downto 5) is
            when "000" => displayInput <= InstructionOutput;
            when "001" => displayInput <= PCOutput;
            when "010" => displayInput <= ReadData1; 
            when "011" => displayInput <= ReadData2;
            when "100" => displayInput <= ExtImmediate;
            when "101" => displayInput <= ALUResBuff;
            when "110" => displayInput <= MemDataBuff;
            when "111" => displayInput <= ReadData2; -- WD
        end case;
    end process;
    
    led <= ALUResBuffFromDataMemory;
        
    hextodisplay: display
        port map(
            digits => displayInput,
            an => an,
            cat => cat,
            clk => clk
        );
    
end Behavioral;