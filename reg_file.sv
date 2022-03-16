module reg_file (		input logic Clk, Reset, LD_REG, 
							input logic [2:0] SR2,  
							input logic DRMUX, SR1MUX,
							input logic [15:0] bus, IR,
							output logic [15:0] SR1_OUT, SR2_OUT);
	
	
	logic [2:0] SR1MUX_O, DRMUX_O; //output of the MUXes
	logic [15:0] temp_reg[8]; //holds the temp register output & is decided by the value of the register 
	logic [15:0] sr1_out, sr2_out;
	logic [2:0] IR_9to11, IR_6to8;
	
	assign IR_6to8 = IR[8:6];
	assign IR_9to11 = IR[11:9];
	
	always_comb begin 
		case (DRMUX)  //DRMUX
			1'b0 :	DRMUX_O = IR_9to11;
		
			1'b1 :	DRMUX_O = 3'b111;
		
			default	:	DRMUX_O = 3'bxxx;
		endcase
	end 
	
	always_comb begin 
		case (SR1MUX) //SR1MUX
			1'b0 :	SR1MUX_O = IR_6to8;
		
			1'b1 :	SR1MUX_O = IR_9to11;

			default	:	SR1MUX_O = 3'bxxx;
		endcase
	end 
	
	
	always_ff @ (posedge Clk) begin
		if (Reset) begin//if reset is high, load 0 into either SR1 or SR2
				
				for (logic [3:0] i = 4'd0 ; i < 4'd8; i++) begin
					temp_reg[i] <= '0;
				end
				
			end 
		else if(LD_REG) begin
			case(DRMUX_O) //if we are loading from bus, input bus into temp reg
				3'b000: temp_reg[0] <= bus;
				3'b001: temp_reg[1] <= bus;
				3'b010: temp_reg[2] <= bus;
				3'b011: temp_reg[3] <= bus;
				3'b100: temp_reg[4] <= bus;
				3'b101: temp_reg[5] <= bus;
				3'b110: temp_reg[6] <= bus;
				3'b111: temp_reg[7] <= bus;
			endcase 
		end 
	end 
	
	always_ff @(posedge Clk) begin //determine which register we're loading into
		case (SR1MUX_O) 
			3'b000: sr1_out <= temp_reg[0];
			3'b001: sr1_out <= temp_reg[1];
			3'b010: sr1_out <= temp_reg[2];
			3'b011: sr1_out <= temp_reg[3];
			3'b100: sr1_out <= temp_reg[4];
			3'b101: sr1_out <= temp_reg[5];
			3'b110: sr1_out <= temp_reg[6];
			3'b111: sr1_out <= temp_reg[7];
			default: sr1_out <= 16'b0; 
		endcase
	 end
	 
	always_ff @(posedge Clk) begin
		case(SR2)
			3'b000: sr2_out <= temp_reg[0];
			3'b001: sr2_out <= temp_reg[1];
			3'b010: sr2_out <= temp_reg[2];
			3'b011: sr2_out <= temp_reg[3];
			3'b100: sr2_out <= temp_reg[4];
			3'b101: sr2_out <= temp_reg[5];
			3'b110: sr2_out <= temp_reg[6];
			3'b111: sr2_out <= temp_reg[7];
			default: sr2_out <= 16'b0; 
		endcase
	end
		
		//assigns the out values to the part of the temp value that actually has values
		assign SR1_OUT = sr1_out;
		assign SR2_OUT = sr2_out;
		
endmodule	
		