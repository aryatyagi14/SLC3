module datapath (		input logic LD_MAR, LD_MDR, LD_IR, LD_REG, LD_PC,
							input logic GatePC, GateMDR, GateALU, GateMARMUX,
							input logic SR2MUX, ADDR1MUX,
							input logic MIO_EN, DRMUX, SR1MUX,
							input logic [1:0] PCMUX, ADDR2MUX, ALUK,
							input logic [15:0] MDR_In,
							input logic Clk, Reset,
							output logic [15:0] IR, MDR, MAR, bus
							//output logic BEN
);

	logic [15:0] PC;
	logic [15:0] SR1, SR2;
	logic [15:0] ALU, B;
	logic [15:0] MARMUX;
	logic [15:0] loadValueMDR;
	logic [15:0] loadPC;
	logic [3:0] muxValue;
	
	//Load in MAR
	reg_16 MARreg(.Clk(Clk), .Reset(Reset), .Load(LD_MAR), .register(bus), .Shift_Out(), .Data_Out(MAR));
	
//MDR mux
	always_comb begin 
	
		case (MIO_EN) 
			1'b0 :	loadValueMDR = bus;
		
			1'b1 :	loadValueMDR = MDR_In;
	
		endcase
		
	end
	
	reg_16 MDRreg(.Clk(Clk), .Reset(Reset), .Load(LD_MDR), .register(loadValueMDR), .Shift_Out(), .Data_Out(MDR));

	reg_16 IRreg(.Clk(Clk), .Reset(Reset), .Load(LD_IR), .register(bus), .Shift_Out(), .Data_Out(IR));

	
//PC portion
	
	
	always_comb begin 
	
		unique case (PCMUX) 
			2'b00 :	loadPC = PC + 16'd1;
		
			2'b01 :	loadPC = bus;
		
			2'b10	:	loadPC = MARMUX;
		
			default	:	loadPC = 16'bxxxx;
		endcase
		
	end
	
	
	reg_16 PCreg(.Clk(Clk), .Reset(Reset), .Load(LD_PC), .register(loadPC), .Shift_Out(), .Data_Out(PC));
	
	
	
//4 GATE MUX
	
	always_comb begin 
		muxValue[0] = GatePC;
		muxValue[1] = GateMDR;
		muxValue[2] = GateALU;
		muxValue[3] = GateMARMUX;
		
	end
	
	always_comb begin 
	
		unique case (muxValue) 
			4'b0000	:  bus = MAR; 
			4'b0001	:	bus = PC;
			4'b0010	:	bus = MDR;
			4'b0100	:	bus = ALU;
			4'b1000	:	bus = MARMUX;
			default	:	bus = 16'hxxxx;
			
		endcase
		
	end
	
	
	

	
	
//register file 
	
	reg_file regfile0(	.Clk(Clk), .Reset(Reset), .LD_REG(LD_REG), 
							.SR2(IR[2:0]),
							.DRMUX(DRMUX), .SR1MUX(SR1MUX),
							.bus(bus), .IR(IR),
							.SR1_OUT(SR1), .SR2_OUT(SR2));
	
	
//AddrMux
//this includes addr1 mux, addr2 mux and the addition of the two values
	
	ADDRMux addrmux0(		.IR(IR), .SR1(SR1), .PC(PC),
							.ADDR2MUX(ADDR2MUX),
							.ADDR1MUX(ADDR1MUX), 
							.MARMUX(MARMUX) );
														
							
//ALU and SR2MUX
	
	always_comb begin
		case (SR2MUX)
			1'b0: B = SR2;
			1'b1: B = {{11{IR[4]}},IR[4:0]}; //5 bits of IR sign extended
		endcase
	end
	
	ALU alu0(	.A(SR1), .B(B), 
						.ALUK(ALUK),
						.ALU_O(ALU));
						
//	BEN branch_en (.IR(IR), .bus(bus), .LD_BEN(LD_BEN), .LD_CC(LD_CC), .Clk(Clk), .Reset(Reset), .BEN_O(BEN));
	


endmodule 