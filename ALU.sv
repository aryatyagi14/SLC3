module ALU (
	input logic [15:0] A, B, 
	input logic [1:0] ALUK,
	output logic [15:0] ALU_O);

	always_comb begin
		case (ALUK)
			2'b00: ALU_O = A + B; //ADD
			2'b01: ALU_O = A & B; //AND
			2'b10: ALU_O = ~A; //NOT A
			2'b11: ALU_O = A;  //PASS A
			endcase
		end
endmodule 