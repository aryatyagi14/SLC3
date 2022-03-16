module ADDRMux(input logic [15:0] IR, SR1, PC,
						input logic [1:0] ADDR2MUX,
						input logic ADDR1MUX, 
						output logic [15:0] MARMUX);
						
//adder2mux
	logic [15:0] sext6bitIR, sext9bitIR, sext11bitIR, outputAddr2;
	
	always_comb begin 
		outputAddr2 = 16'd0;
		sext6bitIR = {{10{IR[5]}}, IR[5:0]};
		sext9bitIR = {{7{IR[8]}}, IR[8:0]};
		sext11bitIR = {{5{IR[10]}}, IR[10:0]};
		
		case (ADDR2MUX) 
			2'b00 :	outputAddr2 = 16'h0000;
		
			2'b01 :	outputAddr2 = sext6bitIR;
		
			2'b10	:	outputAddr2 = sext9bitIR;
			
			2'b11	:	outputAddr2 = sext11bitIR;
		endcase
		
	end
	
//adder1mux
	logic [15:0] outputAddr1;
	
	always_comb begin 
		outputAddr1 = 16'd0;
		case (ADDR1MUX) 
			1'b0 :	outputAddr1 = PC;
		
			1'b1 :	outputAddr1 = SR1;
		
		endcase
		
	end
	
	assign MARMUX = outputAddr1 + outputAddr2;
			

endmodule 