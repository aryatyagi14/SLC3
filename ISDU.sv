//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module ISDU (   input logic         Clk, 
									Reset,
									Run,
									Continue,
									
				input logic[3:0]    Opcode, 
				input logic         IR_5,
				input logic         IR_11,
				input logic         BEN,
				  
				output logic        LD_MAR,
									LD_MDR,
									LD_IR,
									LD_BEN,
									LD_CC,
									LD_REG,
									LD_PC,
									LD_LED, // for PAUSE instruction
									
				output logic        GatePC,
									GateMDR,
									GateALU,
									GateMARMUX,
									
				output logic [1:0]  PCMUX,
				output logic        DRMUX,
									SR1MUX,
									SR2MUX,
									ADDR1MUX,
				output logic [1:0]  ADDR2MUX,
									ALUK,
				  
				output logic        Mem_OE,
									Mem_WE
				);

	enum logic [5:0] {  Halted, 
						PauseIR1, 
						PauseIR2, 
						S_18, 
						S_33_1, 
						S_33_2, 
						S_33_3,
						S_35, 
						S_32,
						S_1,
						S_5,
						S_9,
						S_6, S_25_1, S_25_2, S_25_3, S_27,
						S_7, S_23, S_16_1, S_16_2, S_16_3,
						S_4, S_21,
						S_12,
						S_0, S_22_0}   State, Next_state;   // Internal state logic
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Halted;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		
		// Default controls signal values
		LD_MAR = 1'b0;
		LD_MDR = 1'b0;
		LD_IR = 1'b0;
		LD_BEN = 1'b0;
		LD_CC = 1'b0;
		LD_REG = 1'b0;
		LD_PC = 1'b0;
		LD_LED = 1'b0;
		 
		GatePC = 1'b0;
		GateMDR = 1'b0;
		GateALU = 1'b0;
		GateMARMUX = 1'b0;
		 
		ALUK = 2'b00;
		 
		PCMUX = 2'b00;
		DRMUX = 1'b0;
		SR1MUX = 1'b0;
		SR2MUX = 1'b0;
		ADDR1MUX = 1'b0;
		ADDR2MUX = 2'b00;
		 
		Mem_OE = 1'b0; //changed default to high, correct?
		Mem_WE = 1'b0;
	
		// Assign next state
		unique case (State)
			Halted : 
				if (Run) 
					Next_state = S_18;                      
			S_18 : 
				Next_state = S_33_1;
			// Any states involving SRAM require more than one clock cycles.
			// The exact number will be discussed in lecture.
			S_33_1 : 
				Next_state = S_33_2;
			S_33_2 : 
				Next_state = S_33_3;
			S_33_3 :
				Next_state = S_35;
			S_35 : 
				Next_state = S_32;
			// PauseIR1 and PauseIR2 are only for Week 1 such that TAs can see 
			// the values in IR.
			PauseIR1 : 
				if (~Continue) 
					Next_state = PauseIR1;
				else 
					Next_state = PauseIR2;
			PauseIR2 : 
				if (Continue) 
					Next_state = PauseIR2;
				else 
					Next_state = S_18;
			S_32 : //this state decodes what operation needs to be done and goes to that state 
				case (Opcode)
					4'b0001 : 
						Next_state = S_1; //add
					4'b0101 : 
						Next_state = S_5; //and
					4'b1001 : 
						Next_state = S_9; //not
					4'b0000 :
						Next_state = S_0; //br
					4'b1100 : 
						Next_state = S_12; //jmp
					4'b0100 : 
						Next_state = S_4; //jsr
					4'b0110 : 
						Next_state = S_6; //ldr
					4'b0111 :
						Next_state = S_7; //str
					4'b1101 :
						Next_state = PauseIR1; //pause

					default : 
						Next_state = S_18;
				endcase
				
			
			S_1 : //DR<= SR1 + OP2* setCC
				Next_state = S_18;
			S_5 : //DR<= SR1 & OP2* setCC
				Next_state = S_18;
			S_9 : //DR<= NOT(SR) setCC
				Next_state = S_18;
			
			
			S_6 : //MAR <= B + off6
				Next_state = S_25_1;
			
			
			S_25_1 : //MDR <= M[MAR]
				Next_state = S_25_2;
			S_25_2 :
				Next_state = S_25_3;
			S_25_3:
				Next_state = S_27;
			S_27 : //DR <= MDR set CC
				Next_state = S_18;
				
				
			S_7 : //MAR <= B + 0ff6
				Next_state = S_23;
			S_23 : //MDR <= SR
				Next_state = S_16_1; //do we need 3 wait states or 2?
			S_16_1 ://M[MAR] <= MDR
				Next_state = S_16_2;
			S_16_2 :
				Next_state = S_16_3;
			S_16_3:
				Next_state = S_18;
			
			
			S_4 : //R7 <= PC
				Next_state = S_21;
			S_21 : //PC <= PC + off11
				Next_state = S_18;
				
				
			S_12 : //PC <= BaseR
				Next_state = S_18;
			
			
			S_0 : //BEN - need logic for this
				begin
					if(BEN)
						Next_state = S_22_0;
					else
						Next_state = S_18;
				end
			S_22_0: //PC <= PC + off9
				Next_state = S_18;

			default : 
				Next_state = S_18;

		endcase
		
		// Assign control signals based on current state
		case (State)
			Halted: ;
			S_18 : 
				begin 
					GatePC = 1'b1;
					LD_MAR = 1'b1;
					PCMUX = 2'b00;
					LD_PC = 1'b1;
				end
			S_33_1, S_33_2 : 
				Mem_OE = 1'b1;
			S_33_3 : 
				begin 
					Mem_OE = 1'b1;
					LD_MDR = 1'b1;
				end
			S_35 : 
				begin 
					GateMDR = 1'b1;
					LD_IR = 1'b1;
				end
			PauseIR1: ;
			PauseIR2: ;
			S_32 : 
				LD_BEN = 1'b1;
				
			S_1 : //ADD
				begin 
					SR1MUX = 1'b1;
					SR2MUX = IR_5;
					ALUK = 2'b00;
					GateALU = 1'b1;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
				//	LD_BEN = 1'b1;
					DRMUX = 1'b0; 
				end

			S_5 : //AND
				begin 
					SR1MUX = 1'b1;
					SR2MUX = IR_5;
					ALUK = 2'b01;
					GateALU = 1'b1;
					LD_REG = 1'b1;
					LD_CC = 1'b1; 
				//	LD_BEN = 1'b1;
					DRMUX = 1'b0;
				end
			
			S_9 : //NOT
				begin 
					SR1MUX = 1'b1;
					SR2MUX = 1'b0;
					DRMUX = 1'b0;
					ALUK = 2'b10;
					GateALU = 1'b1;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
				//	LD_BEN = 1'b1;
				end
				
			S_6: //LDR, STR (STR States: 7, 23, 16
				begin 
					SR1MUX = 1'b1;
					ADDR2MUX = 2'b01;
					GateMARMUX = 1'b1;
					ADDR1MUX = 1'b1;
					LD_MAR = 1'b1;
				end
			S_7: 
				begin
					SR1MUX = 1'b1;
					ADDR1MUX = 1'b1;
					ADDR2MUX = 2'b01;
					LD_MAR = 1'b1;
					GateMARMUX = 1'b1;
				end
				
			S_25_1, S_25_2 :
				begin
					Mem_OE = 1'b1; //to choose bus which is MAR??
					Mem_WE = 1'b0; 
					LD_MDR = 1'b1;
				end
			S_25_3 :
				begin
					Mem_OE = 1'b1; 
					Mem_WE = 1'b0; 
					LD_MDR = 1'b1;
				end
			S_27 :
				begin 
					LD_CC = 1'b1; 
				//	LD_BEN = 1'b1;
					GateMDR = 1'b1;
					DRMUX = 1'b0;
					LD_REG = 1'b1;
				end
			
			S_23 :
				begin 
					SR1MUX = 1'b0;
					LD_MDR = 1'b1;
					GateALU = 1'b1;
					ALUK = 2'b11;
				end	
			S_16_1, S_16_2 :
				begin
					Mem_WE = 1'b1;
					Mem_OE = 1'b0;
				end
			S_16_3 :
				begin 
					Mem_WE = 1'b1;
					Mem_OE = 1'b0;
			//		GateMDR = 1'b1; 
				end
			S_4 : //JSR
				begin 
					DRMUX = IR_11;
					GatePC = 1'b1;
					LD_REG = 1'b1;
				end
			S_21 : 
				begin 
					ADDR1MUX = 1'b0;
					ADDR2MUX = 2'b11;
					LD_PC = 1'b1;
					PCMUX = 2'b10;
				end
			
			S_12 : //JMP 
				begin 
					SR1MUX = 1'b1;
					ADDR1MUX = 1'b1; 
					ADDR2MUX = 2'b00; 
					PCMUX = 2'b10;
					LD_PC = 1'b1;
				end
				
			S_0 : ;
			//	begin
				//	ADDR1MUX = 1'b0;
				// ADDR2MUX = 2'b10;
				//	PCMUX = 2'b10;
				//	LD_PC = 1'b1; //BR
			//	end
			
			S_22_0 :
				begin 
					ADDR1MUX = 1'b0;
					ADDR2MUX = 2'b10;
					PCMUX = 2'b10;
					LD_PC = 1'b1;
				end
				
				
			default : ;
		endcase
	end 

	
endmodule 