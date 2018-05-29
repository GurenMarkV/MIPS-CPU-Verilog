--Assignment 3
--Daksh Patel - 104030031
--March 9, 2018

library ieee;
library std;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity MIPS_D is
    port(
		clk		: in	std_logic;
		start	 : in	std_logic;
		rst	 : in	std_logic;
        pc_out, alu_result: out std_logic_vector(31 downto 0)
	);
	
end entity;

architecture Behavioral of MIPS_D is
    --PC
    signal PC : std_logic_vector(31 downto 0);

    --ROM
    type ROM_ARRAY is array (31 downto 0) of std_logic_vector(31 downto 0);
    signal ROM: ROM_ARRAY :=  (others =>'0');
    signal readAddr : std_logic_vector(4 downto 0);
    signal instruction : std_logic_vector(31 downto 0);

    --Control
    signal ctrlIn : std_logic_vector(5 downto 0);
    signal regDst, jump, branch, memRead, MemtoRead, memWrite, ALUSrc, regWrite : std_logic_vector;
    signal ALUOP : std_logic_vector(1 downto 0);

    --Registers
    signal readData1, readData2, writeData : std_logic_vector(31 downto 0);
    signal readReg1, readReg2, writeReg : std_logic_vector(4 downto 0);
    type REG_ARRAY is array (31 downto 0) of std_logic_vector(31 downto 0);
    signal Reg: REG_ARRAY :=  (others =>'0');

    --ALU
    signal ALU_CTRL : std_logic_vector(3 downto 0);
    signal ALUIn1, ALUIn2, ALUOut : std_logic_vector(31 downto 0);
    signal ALU0 : std_logic_vector; --Zero Flag

    --RAM
    signal addrRAM, writeDataRAM, readData : std_logic_vector(31 downto 0);
    type RAM_ARRAY is array (31 downto 0) of std_logic_vector(31 downto 0);
    signal RAM: RAM_ARRAY   :=  (others =>'0');
    
    --Adder
    




