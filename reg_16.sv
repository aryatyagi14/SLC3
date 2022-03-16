module reg_16 (input  logic Clk, Reset, Load,
              input  logic [15:0]  register,
              output logic Shift_Out,
              output logic [15:0]  Data_Out);

	always_comb begin
	
		Shift_Out = Data_Out[0];
		
	end
	
	always_ff @ (posedge Clk) begin
	 
		if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
			 Data_Out <= 16'h0000;
			  
		else if (Load)
			 Data_Out <= register;
		 
   end

endmodule

