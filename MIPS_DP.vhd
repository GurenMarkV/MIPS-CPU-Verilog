--Assignment 3
--Daksh Patel - 104030031
--March 15, 2018

library ieee;
library std;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity MIPS_DP is
    port(
		clk		: in	std_logic
	);
	
end entity;

architecture Behavioral of MIPS_DP is
    
     
	 --PC
    signal PC : std_logic_vector(31 downto 0) := (others => '0');

    
    type RAM_ARRAY is array (0 to 31) of std_logic_vector(31 downto 0);
    signal RAM: RAM_ARRAY := (others => (others => '0'));

    
    type REG_ARRAY is array (0 to 31) of std_logic_vector(31 downto 0);
    signal Reg: REG_ARRAY := (others => (others => '0'));
	 
	
    
    --Declare States
    -- Build an enumerated type for the state machine
    -- R_Type(addu, sltu, subu), LW, SW, BEQ, ADDIU, BNE, J, SLTIU
--    variable ADDIU : std_logic_vector(5 downto 0) := "001001";
--    variable R_Type : std_logic_vector(5 downto 0) := "000000"; 
--    variable BEQ : std_logic_vector(5 downto 0) := "000100"; 
--    variable BNE : std_logic_vector(5 downto 0) := "000101"; 
--    variable J :  std_logic_vector(5 downto 0) := "000010";
--    variable LW : std_logic_vector(5 downto 0) := "100011"; 
--    variable SLTIU : std_logic_vector(5 downto 0) := "001011";
--    variable SW : std_logic_vector(5 downto 0) := "101011"; 

	
    
begin

    process (clk)  
	 
	 --RAM
    variable addrRAM, writeDataRAM, readData : std_logic_vector(31 downto 0);
	 
	 --Registers
    variable readData1, readData2, writeData : std_logic_vector(31 downto 0);
    variable readReg1, readReg2, writeReg : std_logic_vector(4 downto 0);
	 
	 --Control
    variable ctrlIn : std_logic_vector(5 downto 0);
    variable regDst, jump, branch, memRead, MemtoReg, memWrite, ALUSrc, regWrite : std_logic;
    variable aluOP : std_logic_vector(1 downto 0);

    --Control Signals from Instruction Memory Unit
    variable immSignExt : std_logic_vector(31 downto 0); --Instruction[15:0] pre extended sign-extended
    variable jumpAddr : std_logic_vector(31 downto 0);
    variable incrPC : std_logic_vector(31 downto 0);
    variable opc, funct : std_logic_vector(5 downto 0);
    variable rs, rt, rd, shamt : std_logic_vector(4 downto 0);
    variable addr : std_logic_vector(15 downto 0);

    --ALU
    variable ALU_CTRL : std_logic_vector(3 downto 0);
    variable ALUIn1, ALUIn2, ALUOut : std_logic_vector(31 downto 0);
    variable ALU0 : std_logic; --Zero Flag

    --Adder
    variable addOut : std_logic_vector(31 downto 0); --Results for branch handling	

    variable syscall : std_logic := '0'; --Terminating Program
  
--	type STATE_ARRAY is (s0,s1,s2,s3);
--	-- Register to hold the current state
--	
--	variable state   : STATE_ARRAY;
	
	
	--ROM
    variable readAddr : std_logic_vector(4 downto 0);
	variable instruction : std_logic_vector(31 downto 0);
    type ROM_ARRAY is array (0 to 26) of std_logic_vector(31 downto 0); --This is a mess
    constant ROM: ROM_ARRAY :=(
        "00100100000010000000000000000000",
        "00100100000010010000000000000001",
        "00100100000010100000000000000000",
        "00100100000010110000000000000100",
        "00100100000011000010000000000000",
        "10101101100010100000000000000000",
        "00000001010010010101000000100001",
        "00100101100011000000000000000100",
        "00101101010000010000000000010000",
        "00010100001000001111111111111011",
        "00100101100011000000000000001000",
        "00000001010010010101000000100011",
        "10101101100010101111111111111000",
        "00000001100010110110000000100001",
        "00010001010000000000000000000001",

        "00001000000000000000000000001011", --16th line with error?

        "00100100000011000001111111111000",
        "00100100000010110000000000100000",
        "10001101100011010000000000001000",
        "00100101101011011000000000000000",
        "10101101100011010000000000001000",
        "00000001010010010101000000100001",
        "00100101100011000000000000000100",
        "00000001010010110000100000101011",
        "00010100001000001111111111111001",
        "00100100010000100000000000001010",
        "00000000000000000000000000001100"
    );
	 
	 begin
        readAddr := PC(6 downto 2);	--PC(6 downto 2);
        instruction := ROM(to_integer (unsigned(readAddr)));
        opc := instruction(31 downto 26);
        rs := instruction(25 downto 21);
        rt := instruction(20 downto 16);
        rd := instruction(15 downto 11);
        shamt := instruction(10 downto 6);
        funct := instruction(5 downto 0);
        addr := instruction(15 downto 0);

        if (opc = "000000" AND funct = "001100") then
            syscall := '1';
    
        elsif (syscall = '0') then
            --state := opc;

            if  opc = "001001" then --addiu
                regDst := '0';
                jump := '0';
                branch := '0';
                memRead := '0';
                memToReg := '0';
                aluOp := "00";
                memWrite := '0';
                aluSrc := '1';
                regWrite := '1';

            elsif opc = "000000" then --rtype
                regDst := '1';
                jump := '0';
                branch := '0';
                memRead := '0';
                MemtoReg := '0';
                ALUOP := "10";
                memWrite := '0';
                ALUSrc := '0';
                regWrite := '1';

            elsif opc = "000100" then	--beq
                regDst := '0';
                jump := '0';
                branch := '1';
                memRead := '0';
                memToReg := '0';
                aluOp := "01";
                memWrite := '0';
                aluSrc := '0';
                regWrite := '0';

			elsif opc = "000101" then	--bne
                regDst := '0';
                jump := '0';
                branch := '1';
                memRead := '0';
                memToReg := '0';
                aluOp := "01";
                memWrite := '0';
                aluSrc := '0';
                regWrite := '0';

            elsif opc = "000010" then	--jump
                regDst := '1';
                jump := '1';
                branch := '0';
                memRead := '0';
                memToReg := '0';
                aluOp := "00";
                memWrite := '0';
                aluSrc := '0';
                regWrite := '0';

			elsif opc = "100011"  then	--lw
                regDst := '0';
                jump := '0';
                branch := '0';
                memRead := '1';
                MemtoReg := '1';
                ALUOP := "00";
                memWrite := '0';
                ALUSrc := '1';
                regWrite := '1';
				

            elsif opc = "100011" then	--sltiu
                regDst := '0';
                jump := '0';
                branch := '0';
                memRead := '0';
                memToReg := '0';
                aluOp := "11";  ---ERROR?
                memWrite := '0';
                aluSrc := '1';
                regWrite := '1';

			elsif opc = "101011" then	--sw
                regDst := '0';
                jump := '0';
                branch := '0';
                memRead := '0';
                memToReg := '0';
                aluOp := "00";
                memWrite := '1';
                aluSrc := '1';
                regWrite := '0';			
            end if;




            --Extend the Sign *************Source of error?
            immSignExt(15 downto 0) := instruction(15 downto 0);
            --immSignExt(31 downto 16) := (others => instruction(15));
            immSignExt(31 downto 16) := "1111111111111111";

            --Read Registers
            --readReg1 <= rs;
            --readReg2 <= rt;
            readData1 := Reg(to_integer (unsigned(rs)));
            readData2 := Reg(to_integer (unsigned(rt)));

            --Settings up the Write Register
            if regDst = '0' then    
                writeReg := rt;
            else 
                writeReg := rd;
            end if;
            
            --ALU CONTROL 
            if aluOP = "00" then  --ADDIU, LW, SW
                ALU_CTRL := "0000";
            elsif aluOP = "01" then  --BEQ, BNE
                ALU_CTRL := "0001";
            elsif aluOP = "10" then  --R_TYPE
                if funct = "100001" then    --ADDU    
                    ALU_CTRL := "0000";
                elsif funct = "101011" then --SLTU
                    ALU_CTRL := "0010";
                elsif funct = "100011" then --SUBU
                    ALU_CTRL := "0001";
                end if;
            elsif aluOP = "11" then  --SLTIU
                ALU_CTRL := "0010";
            end if;

            --ALU Inputs
            ALUIn1 := readData1;
            if ALUSrc = '0' then    
                ALUIn2 := readData2;
            else    
                ALUIn2 := immSignExt;
            end if;

            --ALU OUTPUT
            
            if ALU_CTRL = "0000" then
                ALUOut := ALUIn1 + ALUIn2;
            elsif ALU_CTRL = "0001" then
                ALUOut := ALUIn1 - ALUIn2;
            elsif ALU_CTRL = "0010" then    
                if ALUIn1<ALUIn2 then
                    ALUOut := X"00000001";
                else 
                    ALUOut := X"00000000";
                end if;
            end if;
            
            --Zero FLag
            if ALUOut = X"00000000" then
                ALU0 := '1';
            else
                ALU0 := '0';
            end if;

            -- RAM
            addrRAM := ALUOut;
            writeDataRAM := readData2;
            if memRead = '1' then
                readData := RAM(to_integer (unsigned(addrRAM(6 downto 2))));
            end if;
            if memWrite = '1' then
                RAM(to_integer (unsigned(addrRAM(6 downto 2)))) <= writeDataRAM;
				end if;

            --Reg Write
            if memToReg = '0' then  
                writeData := ALUOut;
            else
                writeData := readData;
            end if;
            if regWrite = '1' then
                Reg(to_integer (unsigned(writeReg))) <= writeData;
            end if;

            --Increment PC
            incrPC := PC + X"00000004";
            jumpAddr := (incrPC(31 downto 28) & instruction(25 downto 0) & "00");
            addOut := incrPC + (immSignExt(29 downto 0) & "00");

            --Setting the next PC as current PC add 4 by default and then check if changes needed
            --PC <= incrPC;
            if branch = '1' then
                if ALU0 = '1' AND opc = "000100" then
                    PC <= addOut;
                elsif ALU0 = '0' AND opc = "000101" then
                    PC <= addOut;
				else 
					PC <= incrPC;
                end if;
            elsif jump = '1' then
                PC <= jumpAddr;
			else
				PC <= incrPC;
            end if;

        end if;


    end process;
end Behavioral;