//Assignment 3
//Daksh Patel - 104030031
//March 15, 2018


module Assign3_104030031(
	CLK
);
    //Clock and reset inputs
    input CLK;

    //PC
    reg [31:0] PC;

	//RAM
    reg [31:0] RAM[31:0];  //structure 
    reg [31:0] addrRAM, writeDataRAM;  //Inputs 
    reg [31:0] readData;  //Output 

    //ROM
    reg [31:0] ROM[31:0];  //structure
    reg [4:0] readAddr;  //input
    reg [31:0] instruction;  //output 
    
    //Control
    reg [5:0] ctrlIn;  //Input For Control Unit 
    reg regDst, jump, branch, memRead, MemtoReg, memWrite, ALUSrc, regWrite;   //Control Outputs 
    reg [1:0] ALUOP;
   
    //Registers
    reg [31:0] readData1, readData2, writeData;    //Registers Outputs 
    reg [31:0] registers [31:0];   //Register Inputs 
    reg [4:0] readReg1, readReg2, writeReg;

    //ALU
    reg [3:0] ALU_CTRL;  
    reg [31:0] ALUIn1, ALUIn2;   //ALU Inputs 
    reg [31:0] ALUOut;   //Output 
    reg ALU0;  //zero flag 

    //Adder Results used to handle branching 
    reg [31:0] addResult;

    //Controls Signals from Instruction
    reg [5:0] opc;
    reg [4:0] rs;
    reg [4:0] rt;
    reg [4:0] rd;
    reg [4:0] shamt;
    reg [5:0] funct;
    reg [15:0] addr;

    reg [31:0] immSignExt;  //Instruction[15:0] pre extended sign-extended 
    
    reg [31:0] jumpAddr;  //used to handle jumps 
    
    reg [31:0] incrPC;   //for handling the incrementation of PC
    
    reg syscall;  //for termination of program
    integer i; //For initialising RAM and Registers

    initial
	begin   //Inititialise RAM and Registers to 0
		for (i=0; i<32; i=i+1) begin
			RAM[i] = 32'b0;
			registers[i] = 32'b0;
		end
		//Input ROM 
		ROM[0]<=32'b00100100000010000000000000000000;
		ROM[1]<=32'b00100100000010010000000000000001;
		ROM[2]<=32'b00100100000010100000000000000000;
		ROM[3]<=32'b00100100000010110000000000000100;
		ROM[4]<=32'b00100100000011000010000000000000;
		ROM[5]<=32'b10101101100010100000000000000000;
		ROM[6]<=32'b00000001010010010101000000100001;
		ROM[7]<=32'b00100101100011000000000000000100;
		ROM[8]<=32'b00101101010000010000000000010000;
		ROM[9]<=32'b00010100001000001111111111111011;
		ROM[10]<=32'b00100101100011000000000000001000;
		ROM[11]<=32'b00000001010010010101000000100011;
		ROM[12]<=32'b10101101100010101111111111111000;
		ROM[13]<=32'b00000001100010110110000000100001;
		ROM[14]<=32'b00010001010000000000000000000001;
		ROM[15]<=32'b00001000000000000000000000001011;
		ROM[16]<=32'b00100100000011000001111111111000;
		ROM[17]<=32'b00100100000010110000000000100000;
		ROM[18]<=32'b10001101100011010000000000001000;
		ROM[19]<=32'b00100101101011011000000000000000;
		ROM[20]<=32'b10101101100011010000000000001000;
		ROM[21]<=32'b00000001010010010101000000100001;
		ROM[22]<=32'b00100101100011000000000000000100;
		ROM[23]<=32'b00000001010010110000100000101011;
		ROM[24]<=32'b00010100001000001111111111111001;
		ROM[25]<=32'b00100100010000100000000000001010;
		ROM[26]<=32'b00000000000000000000000000001100;
		
		PC = 32'b0;  //initial PC
		syscall = 1'b0;  //allows program to start
	end

    always @ (posedge CLK) begin
		readAddr = PC[6:2];  //address from which intruction is taken from rom
		instruction = ROM[readAddr];
		opc = instruction[31:26];
		rs = instruction[25:21];
		rt = instruction[20:16];
		rd = instruction[15:11];
		shamt = instruction[10:6];
		funct = instruction[5:0];
		addr = instruction[15:0];
			
		if (opc == 6'b000000 && funct == 6'b001100)  //for program termination 
			syscall = 1'b1;
		
		if (syscall==0) begin  
			ctrlIn = opc;
			//Control 
			case (ctrlIn) 		
				6'b000000: begin  //R Type - addu, sltu, subu 
					regDst = 1;
					jump = 0;
					branch = 0;
					memRead = 0;
					MemtoReg = 0;
					ALUOP = 2'b10;
					memWrite = 0;
					ALUSrc = 0;
					regWrite = 1;	
				end
				
				6'b100011: begin  //lw
					regDst = 0;
					jump = 0;
					branch = 0;
					memRead = 1;
					MemtoReg = 1;
					ALUOP = 2'b00;
					memWrite = 0;
					ALUSrc = 1;
					regWrite = 1;
				end
				
				6'b101011: begin  //sw
					regDst = 0;
					jump = 0;
					branch = 0;
					memRead = 0;
					MemtoReg = 0;
					ALUOP = 2'b00;
					memWrite = 1;
					ALUSrc = 1;
					regWrite = 0;
				end
				
				6'b000100: begin  //beq
					regDst = 0;
					jump = 0;
					branch = 1;
					memRead = 0;
					MemtoReg = 0;
					ALUOP = 2'b01;
					memWrite = 0;
					ALUSrc = 0;
					regWrite = 0;
				end
				
				6'b001001: begin  //addiu
					regDst = 0;
					jump = 0;
					branch = 0;
					memRead = 0;
					MemtoReg = 0;
					ALUOP = 2'b00;
					memWrite = 0;
					ALUSrc = 1;
					regWrite = 1;
				end
				
				6'b000101: begin  //bne
					regDst = 0;
					jump = 0;
					branch = 1;
					memRead = 0;
					MemtoReg = 0;
					ALUOP = 2'b01;
					memWrite = 0;
					ALUSrc = 0;
					regWrite = 0;
				end
				
				6'b000010: begin  //j
					regDst = 1;
					jump = 1;
					branch = 0;
					memRead = 0;
					MemtoReg = 0;
					ALUOP = 2'b00;
					memWrite = 0;
					ALUSrc = 0;
					regWrite = 0;
				end
				
				6'b001011: begin  //sltiu
					regDst = 0;
					jump = 0;
					branch = 0;
					memRead = 0;
					MemtoReg = 0;
					ALUOP = 2'b11;
					memWrite = 0;
					ALUSrc = 1;
					regWrite = 1;
				end
			endcase

			//Sign-extend
			immSignExt [15:0] = instruction[15:0];
			immSignExt [31:16] = {16{instruction[15]}};
			
			//Read Registers 
			//readReg1 = rs;
			//readReg2 = rt;
			readData1 = registers[rs];
			readData2 = registers[rt];
			
			//Set WriteRegister
			if (regDst==0)
				writeReg = rt;
			else
				writeReg = rd;
			
			//ALU Control
			case (ALUOP)
				2'b00: begin  //ADDIU, LW, SW
					ALU_CTRL = 4'b0000;
				end
				2'b01: begin  //BEQ, BNE
					ALU_CTRL = 4'b0001;		
				end
				2'b10: begin  //R_TYPE 
					if (funct==6'b100001)  //ADDU
						ALU_CTRL = 4'b0000;
					else if (funct==6'b101011)  //SLTU
						ALU_CTRL = 4'b0010;
					else if (funct==6'b100011)  //SUBU
						ALU_CTRL = 4'b0001;
				end
				2'b11: begin  //SLTIU
					ALU_CTRL = 4'b0010;		
				end
			endcase
		
			//ALU Inputs
			ALUIn1 = readData1;
			if (ALUSrc == 0)
				ALUIn2 = readData2;
			else
				ALUIn2 = immSignExt;
				
			//ALU OUTPUT
			case (ALU_CTRL)	
				4'b0000: begin
					ALUOut = ALUIn1 + ALUIn2;
				end			
				4'b0001: begin
					ALUOut = ALUIn1 - ALUIn2;
				end
				4'b0010: begin
					if (ALUIn1 < ALUIn2)
						ALUOut = 32'h00000001;
					else
						ALUOut = 32'b0;
				end
			endcase
			
			//Zero Flag
			if (ALUOut==32'b0)
				ALU0 = 1'b1;
			else
				ALU0 = 1'b0;

			//RAM
			addrRAM = ALUOut;	
			writeDataRAM = readData2;

			if (memRead==1)  //Reading
				readData = RAM[addrRAM[6:2]];
			
			if (memWrite==1)  //Writing
				RAM[addrRAM[6:2]] = writeDataRAM;

			//Registers Write
			if (MemtoReg==0)
				writeData = ALUOut;
			else
				writeData = readData;
			if (regWrite==1)
				registers[writeReg] = writeData;

			//Increment PC	
			incrPC = PC + 32'h00000004;  
			jumpAddr = {incrPC[31:28],instruction[25:0], 2'b00};
			ALUOut = incrPC + {immSignExt[29:0], 2'b00};
			
			//Set next PC as currentPC+4 by default, then check if needs to be changed
			PC = incrPC;
			if (branch == 1) begin //handle branching  	
				if (ALU0 == 1 && opc == 6'b000100) begin   //beq 
					PC = ALUOut;
				end 
				else if (ALU0 == 0 && opc == 6'b000101) begin //bne
					PC = ALUOut;
				end 
			end 
			else if (jump==1)
				PC = jumpAddr;
			
		end 
	end 
endmodule

