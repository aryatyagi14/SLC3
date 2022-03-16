module BEN ( 
	input logic [15:0] IR, bus,
	input logic LD_BEN, LD_CC, Clk, Reset,
	output logic BEN_O );
	
	logic N, Z, P, n, z, p;
	logic [2:0] IR_9to11;
	assign IR_9to11 = IR[11:9];
	
	always_ff @ (posedge Clk) begin
		if (Reset) //case reset
			BEN_O <= 1'b0;
			
		else if (LD_BEN) begin
		
			BEN_O <= ((IR_9to11 & {N, Z, P}) != 3'b000);
			
			end
			
			
		 if (LD_CC) begin //case load CC
				N <= n;
				Z <= z;
				P <= p;
			end
			
		
	end
	always_comb begin 
		n = 1'b0;
		z = 1'b0;
		p = 1'b0;
		if(bus == 16'h0000) begin //case 0
			n = 1'b0;
			z = 1'b1;
			p = 1'b0;
			end
		else if (bus[15] == 1'b1) begin //case negative
			n = 1'b1;
			z = 1'b0;
			p = 1'b0;
			end
		else if (bus[15] != 1'b1 && bus != 16'h0000) begin //case positive
			n = 1'b0;
			z = 1'b0;
			p = 1'b1;
			end
		else begin
			n = 1'bz;
			z = 1'bz;
			p = 1'bz;
			end
		end 
endmodule 