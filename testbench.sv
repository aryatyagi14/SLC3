module testbench();

timeunit 10ns;

timeprecision 1ns;

logic [9:0] SW;
logic	Clk, Run, Continue;
logic [9:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3;
	
slc3_testtop test0(.*);
	
logic [15:0] R[8];

assign R = test0.slc.d0.regfile0.temp_reg;


always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

	
initial begin: TEST_VECTORS

Run = 1;
Continue = 1;
SW = 16'h0006;

#25 
Run = 0;
Continue = 0;

#4 
Run = 1;
Continue = 1;

#2 Run = 0;

#2 Run = 1;

#4
Continue = 0;


#20
Continue = 1;

#22
Continue = 0;

/*

#2
Continue = 1;

#4
Continue = 0;

#2
Continue = 1;


#100
Run = 1;
Continue = 1;

#2 
Run = 0;
Continue = 0;

#4 
Run = 1;
Continue = 1;

#2 Run = 0;

#2 Run = 1;

#4
Continue = 0;

#2
Continue = 1;

#4
Continue = 0;

#2
Continue = 1;


*/

end

endmodule 